import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import 'sale_models.dart';

class SaleRepository {
  final AppDatabase _db;

  SaleRepository(this._db);

  Future<SaleReceipt> saveSale({
    required List<SaleLineInput> lines,
    required int channelId,
    required PaymentMode payment,
    int? customerId,
    int paidMinor = 0,
    int? accountId,
    int? editingSaleId,
  }) {
    return _db.transaction(() async {
      if (lines.isEmpty) {
        throw ArgumentError('Add at least one item.');
      }
      final total = lines.fold<int>(
          0, (sum, line) => sum + line.qty * line.unitPriceMinor);
      final resolvedPaid = _resolvePaid(payment, paidMinor, total);
      final status = _statusFor(total, resolvedPaid);

      if (payment == PaymentMode.partial &&
          (resolvedPaid <= 0 || resolvedPaid >= total)) {
        throw ArgumentError('Enter an amount lower than the total.');
      }
      if (resolvedPaid > total) {
        throw ArgumentError('Payment cannot exceed the total.');
      }
      if (status != 'paid' && customerId == null) {
        throw ArgumentError('Choose a customer for an unpaid sale.');
      }
      if (resolvedPaid > 0 && accountId == null) {
        throw ArgumentError('Choose where the money was received.');
      }

      final originalItems = editingSaleId == null
          ? <SaleItem>[]
          : await (_db.select(_db.saleItems)
                ..where((item) => item.saleId.equals(editingSaleId)))
              .get();
      final originalQty = <int, int>{};
      for (final item in originalItems) {
        originalQty[item.productId] =
            (originalQty[item.productId] ?? 0) + item.qty;
      }

      final products = <int, Product>{};
      for (final line in lines) {
        final product = await _getProduct(line.productId);
        if (product == null) {
          throw StateError('A product in this sale no longer exists.');
        }
        products[line.productId] = product;
        final available = product.stock + (originalQty[line.productId] ?? 0);
        if (line.qty > available && !line.allowAboveStock) {
          throw StateError('Not enough stock for ${product.name}.');
        }
      }

      String? customerName;
      if (customerId != null) {
        customerName = (await (_db.select(_db.customers)
                  ..where((customer) => customer.id.equals(customerId)))
                .getSingleOrNull())
            ?.name;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      int saleId;
      if (editingSaleId == null) {
        saleId = await _db.into(_db.sales).insert(
              SalesCompanion.insert(
                customerId: Value(customerId),
                channelId: channelId,
                totalMinor: total,
                status: Value(status),
                createdAt: now,
              ),
            );
      } else {
        saleId = editingSaleId;
        final existing = await (_db.select(_db.sales)
              ..where((sale) => sale.id.equals(saleId)))
            .getSingleOrNull();
        if (existing == null) {
          throw StateError('This sale no longer exists.');
        }
        await _restoreStock(originalItems);
        await (_db.delete(_db.saleItems)
              ..where((item) => item.saleId.equals(saleId)))
            .go();
        await (_db.delete(_db.payments)
              ..where((payment) => payment.saleId.equals(saleId)))
            .go();
        await _deleteSaleMovements(saleId);
        await (_db.update(_db.sales)..where((sale) => sale.id.equals(saleId)))
            .write(
          SalesCompanion(
            customerId: Value(customerId),
            channelId: Value(channelId),
            totalMinor: Value(total),
            status: Value(status),
          ),
        );
      }

      for (final line in lines) {
        await _db.into(_db.saleItems).insert(
              SaleItemsCompanion.insert(
                saleId: saleId,
                productId: line.productId,
                qty: line.qty,
                unitPriceMinor: line.unitPriceMinor,
                unitCostMinor: line.unitCostMinor,
              ),
            );
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: line.productId,
                type: 'sale',
                qty: -line.qty,
                unitCostMinor: Value(line.unitCostMinor),
                note: Value('Sale #$saleId'),
                createdAt: now,
              ),
            );
        await _db.customUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          variables: [Variable<int>(line.qty), Variable<int>(line.productId)],
        );
      }

      if (resolvedPaid > 0) {
        await _db.into(_db.payments).insert(
              PaymentsCompanion.insert(
                saleId: saleId,
                accountId: accountId!,
                amountMinor: resolvedPaid,
                paidAt: now,
              ),
            );
      }

      return SaleReceipt(
        saleId: saleId,
        customerName: customerName,
        status: status,
        lines: [
          for (final line in lines)
            SaleReceiptLine(
              name: products[line.productId]!.name,
              qty: line.qty,
              unitPriceMinor: line.unitPriceMinor,
            ),
        ],
        totalMinor: total,
        paidMinor: resolvedPaid,
        dueMinor: total - resolvedPaid,
      );
    });
  }

  Future<SaleReceipt> saveQuickSale({
    required int productId,
    required int qty,
    required int unitPriceMinor,
    required int accountId,
  }) async {
    final product = await _getProduct(productId);
    if (product == null) {
      throw StateError('A product in this sale no longer exists.');
    }
    final channelId = await _defaultChannelId();
    return saveSale(
      lines: [
        SaleLineInput(
          productId: productId,
          qty: qty,
          unitPriceMinor: unitPriceMinor,
          unitCostMinor: product.costMinor,
          allowAboveStock: true,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      accountId: accountId,
    );
  }

  Future<RecordPaymentResult> recordPayment({
    required int saleId,
    required int amountMinor,
    required int accountId,
    DateTime? paidAt,
  }) {
    return _db.transaction(() async {
      final sale = await (_db.select(_db.sales)
            ..where((sale) => sale.id.equals(saleId)))
          .getSingleOrNull();
      if (sale == null) {
        throw StateError('This sale no longer exists.');
      }
      final paid = await _sumPayments(saleId);
      final due = sale.totalMinor - paid;
      if (amountMinor <= 0 || amountMinor > due) {
        throw ArgumentError('Enter an amount up to the amount due.');
      }
      final now = paidAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;
      await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              saleId: saleId,
              accountId: accountId,
              amountMinor: amountMinor,
              paidAt: now,
            ),
          );
      final newPaid = paid + amountMinor;
      final status = _statusFor(sale.totalMinor, newPaid);
      await (_db.update(_db.sales)..where((row) => row.id.equals(saleId)))
          .write(SalesCompanion(status: Value(status)));
      return RecordPaymentResult(
        paidMinor: newPaid,
        dueMinor: sale.totalMinor - newPaid,
        status: status,
      );
    });
  }

  Future<void> undoSale(int saleId) async {
    await _db.transaction(() async {
      final items = await (_db.select(_db.saleItems)
            ..where((item) => item.saleId.equals(saleId)))
          .get();
      await _restoreStock(items);
      await (_db.delete(_db.payments)
            ..where((payment) => payment.saleId.equals(saleId)))
          .go();
      await _deleteSaleMovements(saleId);
      await (_db.delete(_db.saleItems)
            ..where((item) => item.saleId.equals(saleId)))
          .go();
      await (_db.delete(_db.sales)..where((sale) => sale.id.equals(saleId)))
          .go();
    });
  }

  Future<DeletedSale?> deleteSale(int saleId) {
    return _db.transaction(() async {
      final detail = await getSaleDetail(saleId);
      if (detail == null) return null;
      final items = await (_db.select(_db.saleItems)
            ..where((item) => item.saleId.equals(saleId)))
          .get();
      await _restoreStock(items);
      await (_db.delete(_db.payments)
            ..where((payment) => payment.saleId.equals(saleId)))
          .go();
      await _deleteSaleMovements(saleId);
      await (_db.delete(_db.saleItems)
            ..where((item) => item.saleId.equals(saleId)))
          .go();
      await (_db.delete(_db.sales)..where((sale) => sale.id.equals(saleId)))
          .go();
      return DeletedSale(
        sale: detail.sale,
        lines: detail.lines,
        payments: detail.payments,
      );
    });
  }

  Future<void> restoreSale(DeletedSale deleted) {
    return _db.transaction(() async {
      await _db.into(_db.sales).insert(
            SalesCompanion.insert(
              id: Value(deleted.sale.id),
              customerId: Value(deleted.sale.customerId),
              channelId: deleted.sale.channelId,
              totalMinor: deleted.sale.totalMinor,
              status: Value(deleted.sale.status),
              createdAt: deleted.sale.createdAt,
              legacyExtraCostMinor: Value(deleted.sale.legacyExtraCostMinor),
            ),
          );
      for (final line in deleted.lines) {
        await _db.into(_db.saleItems).insert(
              SaleItemsCompanion.insert(
                saleId: deleted.sale.id,
                productId: line.productId,
                qty: line.qty,
                unitPriceMinor: line.unitPriceMinor,
                unitCostMinor: line.unitCostMinor,
              ),
            );
        await _db.customUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          variables: [Variable<int>(line.qty), Variable<int>(line.productId)],
        );
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: line.productId,
                type: 'sale',
                qty: -line.qty,
                unitCostMinor: Value(line.unitCostMinor),
                note: Value('Sale #${deleted.sale.id}'),
                createdAt: deleted.sale.createdAt,
              ),
            );
      }
      for (final payment in deleted.payments) {
        await _db.into(_db.payments).insert(
              PaymentsCompanion.insert(
                saleId: deleted.sale.id,
                accountId: payment.accountId,
                amountMinor: payment.amountMinor,
                paidAt: payment.paidAt,
                note: Value(payment.note),
              ),
            );
      }
    });
  }

  Stream<List<SaleSummary>> watchSales() {
    return _db
        .customSelect(
          '''
SELECT s.id AS id,
       s.created_at AS created_at,
       s.total_minor AS total_minor,
       s.status AS status,
       s.channel_id AS channel_id,
       c.name AS customer_name,
       COALESCE(ch.name, '') AS channel_name,
       COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.sale_id = s.id), 0) AS paid_minor,
       COALESCE((SELECT SUM(si.qty) FROM sale_items si WHERE si.sale_id = s.id), 0) AS item_count,
       COALESCE((SELECT GROUP_CONCAT(pr.name || ' ×' || si.qty, ', ')
                 FROM sale_items si
                 JOIN products pr ON pr.id = si.product_id
                 WHERE si.sale_id = s.id), '') AS items_label,
       COALESCE((SELECT SUM(si.qty * (si.unit_price_minor - si.unit_cost_minor))
                 FROM sale_items si WHERE si.sale_id = s.id), 0) AS profit_minor
FROM sales s
LEFT JOIN customers c ON c.id = s.customer_id
LEFT JOIN channels ch ON ch.id = s.channel_id
ORDER BY s.created_at DESC, s.id DESC
''',
          readsFrom: {
            _db.sales,
            _db.customers,
            _db.channels,
            _db.payments,
            _db.saleItems,
            _db.products,
          },
        )
        .watch()
        .map(
          (rows) => rows.map((row) {
            final total = row.read<int>('total_minor');
            final paid = row.read<int>('paid_minor');
            return SaleSummary(
              id: row.read<int>('id'),
              createdAt: row.read<int>('created_at'),
              totalMinor: total,
              status: row.read<String>('status'),
              channelId: row.read<int>('channel_id'),
              customerName: row.read<String?>('customer_name'),
              channelName: row.read<String>('channel_name'),
              paidMinor: paid,
              dueMinor: total - paid,
              itemCount: row.read<int>('item_count'),
              itemsLabel: row.read<String>('items_label'),
              profitMinor: row.read<int>('profit_minor'),
            );
          }).toList(),
        );
  }

  Stream<SaleDetail?> watchSaleDetail(int saleId) {
    final trigger = _db.customSelect(
      'SELECT id FROM sales WHERE id = ?',
      variables: [Variable<int>(saleId)],
      readsFrom: {
        _db.sales,
        _db.customers,
        _db.channels,
        _db.saleItems,
        _db.payments,
        _db.products,
      },
    ).watch();
    return trigger.asyncMap((_) => getSaleDetail(saleId));
  }

  Future<SaleDetail?> getSaleDetail(int saleId) async {
    final sale = await (_db.select(_db.sales)
          ..where((sale) => sale.id.equals(saleId)))
        .getSingleOrNull();
    if (sale == null) return null;

    Customer? customer;
    if (sale.customerId != null) {
      customer = await (_db.select(_db.customers)
            ..where((row) => row.id.equals(sale.customerId!)))
          .getSingleOrNull();
    }
    final channel = await (_db.select(_db.channels)
          ..where((row) => row.id.equals(sale.channelId)))
        .getSingleOrNull();

    final itemRows = await _db.customSelect(
      '''
SELECT si.id AS id, si.product_id AS product_id, si.qty AS qty,
       si.unit_price_minor AS unit_price_minor,
       si.unit_cost_minor AS unit_cost_minor,
       pr.name AS product_name
FROM sale_items si
JOIN products pr ON pr.id = si.product_id
WHERE si.sale_id = ?
ORDER BY si.id
''',
      variables: [Variable<int>(saleId)],
      readsFrom: {_db.saleItems, _db.products},
    ).get();
    final lines = itemRows
        .map(
          (row) => SaleLine(
            id: row.read<int>('id'),
            productId: row.read<int>('product_id'),
            productName: row.read<String>('product_name'),
            qty: row.read<int>('qty'),
            unitPriceMinor: row.read<int>('unit_price_minor'),
            unitCostMinor: row.read<int>('unit_cost_minor'),
          ),
        )
        .toList();

    final paymentRows = await _db.customSelect(
      '''
SELECT p.id AS id, p.account_id AS account_id, p.amount_minor AS amount_minor,
       p.paid_at AS paid_at, p.note AS note,
       COALESCE(a.name, '') AS account_name
FROM payments p
LEFT JOIN accounts a ON a.id = p.account_id
WHERE p.sale_id = ?
ORDER BY p.paid_at, p.id
''',
      variables: [Variable<int>(saleId)],
      readsFrom: {_db.payments, _db.accounts},
    ).get();
    final payments = paymentRows
        .map(
          (row) => PaymentInfo(
            id: row.read<int>('id'),
            accountId: row.read<int>('account_id'),
            accountName: row.read<String>('account_name'),
            amountMinor: row.read<int>('amount_minor'),
            paidAt: row.read<int>('paid_at'),
            note: row.read<String?>('note'),
          ),
        )
        .toList();

    final paid = payments.fold<int>(0, (sum, p) => sum + p.amountMinor);
    final profit =
        lines.fold<int>(0, (sum, line) => sum + line.lineProfitMinor);

    return SaleDetail(
      sale: sale,
      customerName: customer?.name,
      customerPhone: customer?.phone,
      channelName: channel?.name ?? '',
      lines: lines,
      payments: payments,
      paidMinor: paid,
      dueMinor: sale.totalMinor - paid,
      profitMinor: profit,
    );
  }

  Stream<List<Product>> watchRecentProducts({int limit = 8}) {
    return _productSalesQuery(
      'ORDER BY MAX(s.created_at) DESC, p.name LIMIT ${limit.abs()}',
    );
  }

  Stream<List<Product>> watchTopSoldProducts({int limit = 8}) {
    return _productSalesQuery(
      'ORDER BY SUM(si.qty) DESC, p.name LIMIT ${limit.abs()}',
    );
  }

  Future<SalesDefaults> loadDefaults() async {
    final lastSale = await (_db.select(_db.sales)
          ..orderBy([
            (sale) => OrderingTerm(
                expression: sale.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    final lastPayment = await (_db.select(_db.payments)
          ..orderBy([
            (payment) => OrderingTerm(
                expression: payment.paidAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    final firstChannel = await (_db.select(_db.channels)
          ..orderBy([(channel) => OrderingTerm(expression: channel.sort)])
          ..limit(1))
        .getSingleOrNull();
    return SalesDefaults(
      channelId: lastSale?.channelId ?? firstChannel?.id,
      accountId: lastPayment?.accountId,
    );
  }

  Stream<List<Product>> _productSalesQuery(String ordering) {
    return _db
        .customSelect(
          '''
SELECT p.id AS id, p.name AS name, p.price_minor AS price_minor,
       p.cost_minor AS cost_minor, p.stock AS stock,
       p.low_stock_at AS low_stock_at, p.note AS note, p.archived AS archived
FROM products p
JOIN sale_items si ON si.product_id = p.id
JOIN sales s ON s.id = si.sale_id
WHERE p.archived = 0
GROUP BY p.id
$ordering
''',
          readsFrom: {_db.products, _db.saleItems, _db.sales},
        )
        .watch()
        .map(
          (rows) => rows.map(_productFromRow).toList(),
        );
  }

  Product _productFromRow(QueryRow row) {
    return Product(
      id: row.read<int>('id'),
      name: row.read<String>('name'),
      priceMinor: row.read<int>('price_minor'),
      costMinor: row.read<int>('cost_minor'),
      stock: row.read<int>('stock'),
      lowStockAt: row.read<int>('low_stock_at'),
      note: row.read<String?>('note'),
      archived: row.read<bool>('archived'),
    );
  }

  Future<Product?> _getProduct(int id) {
    return (_db.select(_db.products)..where((product) => product.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> _sumPayments(int saleId) async {
    final row = await _db.customSelect(
      'SELECT COALESCE(SUM(amount_minor), 0) AS paid FROM payments WHERE sale_id = ?',
      variables: [Variable<int>(saleId)],
      readsFrom: {_db.payments},
    ).getSingle();
    return row.read<int>('paid');
  }

  Future<void> _restoreStock(List<SaleItem> items) async {
    for (final item in items) {
      await _db.customUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        variables: [Variable<int>(item.qty), Variable<int>(item.productId)],
      );
    }
  }

  Future<void> _deleteSaleMovements(int saleId) async {
    await (_db.delete(_db.stockMovements)
          ..where(
            (movement) =>
                movement.type.equals('sale') &
                movement.note.equals('Sale #$saleId'),
          ))
        .go();
  }

  int _resolvePaid(PaymentMode mode, int paidMinor, int total) {
    switch (mode) {
      case PaymentMode.paid:
        return total;
      case PaymentMode.partial:
        return paidMinor;
      case PaymentMode.due:
        return 0;
    }
  }

  String _statusFor(int total, int paid) {
    if (total <= 0 || paid >= total) return 'paid';
    if (paid <= 0) return 'due';
    return 'partial';
  }

  Future<int> _defaultChannelId() async {
    final channel = await (_db.select(_db.channels)
          ..orderBy([
            (channel) => OrderingTerm(expression: channel.sort),
            (channel) => OrderingTerm(expression: channel.id),
          ])
          ..limit(1))
        .getSingleOrNull();
    if (channel != null) return channel.id;
    return _db.into(_db.channels).insert(
          ChannelsCompanion.insert(name: 'In person'),
        );
  }
}

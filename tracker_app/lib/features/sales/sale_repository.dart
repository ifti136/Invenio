import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class QuickSaleReceipt {
  final int saleId;
  final String productName;
  final int qty;
  final int unitPriceMinor;
  final int totalMinor;
  final int paidMinor;
  final int dueMinor;

  const QuickSaleReceipt({
    required this.saleId,
    required this.productName,
    required this.qty,
    required this.unitPriceMinor,
    required this.totalMinor,
    required this.paidMinor,
    required this.dueMinor,
  });
}

class SaleRepository {
  final AppDatabase _db;

  SaleRepository(this._db);

  Future<QuickSaleReceipt> saveQuickSale({
    required int productId,
    required int qty,
    required int unitPriceMinor,
    required int accountId,
  }) {
    return _db.transaction(() async {
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingle();
      final channelId = await _defaultChannelId();
      final now = DateTime.now().millisecondsSinceEpoch;
      final total = qty * unitPriceMinor;

      final saleId = await _db.into(_db.sales).insert(
            SalesCompanion.insert(
              channelId: channelId,
              totalMinor: total,
              createdAt: now,
              status: const Value('paid'),
            ),
          );
      await _db.into(_db.saleItems).insert(
            SaleItemsCompanion.insert(
              saleId: saleId,
              productId: productId,
              qty: qty,
              unitPriceMinor: unitPriceMinor,
              unitCostMinor: product.costMinor,
            ),
          );
      await _db.into(_db.stockMovements).insert(
            StockMovementsCompanion.insert(
              productId: productId,
              type: 'sale',
              qty: -qty,
              unitCostMinor: Value(product.costMinor),
              note: Value('Sale #$saleId'),
              createdAt: now,
            ),
          );
      await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              saleId: saleId,
              accountId: accountId,
              amountMinor: total,
              paidAt: now,
            ),
          );

      final statement = _db.update(_db.products)
        ..where((p) => p.id.equals(productId));
      await statement.write(
        ProductsCompanion(stock: Value(product.stock - qty)),
      );

      return QuickSaleReceipt(
        saleId: saleId,
        productName: product.name,
        qty: qty,
        unitPriceMinor: unitPriceMinor,
        totalMinor: total,
        paidMinor: total,
        dueMinor: 0,
      );
    });
  }

  Future<void> undoSale(int saleId) async {
    await _db.transaction(() async {
      final items = await (_db.select(_db.saleItems)
            ..where((item) => item.saleId.equals(saleId)))
          .get();
      for (final item in items) {
        final product = await (_db.select(_db.products)
              ..where((p) => p.id.equals(item.productId)))
            .getSingleOrNull();
        if (product == null) continue;
        final statement = _db.update(_db.products)
          ..where((p) => p.id.equals(item.productId));
        await statement.write(
          ProductsCompanion(stock: Value(product.stock + item.qty)),
        );
      }
      await (_db.delete(_db.payments)
            ..where((payment) => payment.saleId.equals(saleId)))
          .go();
      await (_db.delete(_db.stockMovements)
            ..where(
              (movement) =>
                  movement.type.equals('sale') &
                  movement.note.equals('Sale #$saleId'),
            ))
          .go();
      await (_db.delete(_db.saleItems)
            ..where((item) => item.saleId.equals(saleId)))
          .go();
      await (_db.delete(_db.sales)..where((sale) => sale.id.equals(saleId)))
          .go();
    });
  }

  Future<int> _defaultChannelId() async {
    final channel = await (_db.select(_db.channels)
          ..orderBy([(c) => OrderingTerm(expression: c.sort)])
          ..limit(1))
        .getSingleOrNull();
    if (channel != null) return channel.id;
    return _db.into(_db.channels).insert(
          ChannelsCompanion.insert(name: 'In person'),
        );
  }
}

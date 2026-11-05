import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class CustomerDue {
  final int customerId;
  final String name;
  final String? phone;
  final int dueMinor;
  final int oldestCreatedAt;
  final int saleCount;

  const CustomerDue({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.dueMinor,
    required this.oldestCreatedAt,
    required this.saleCount,
  });
}

class DueSale {
  final int id;
  final int totalMinor;
  final int paidMinor;
  final int dueMinor;
  final int createdAt;
  final String status;

  const DueSale({
    required this.id,
    required this.totalMinor,
    required this.paidMinor,
    required this.dueMinor,
    required this.createdAt,
    required this.status,
  });
}

class DuePayment {
  final int id;
  final int saleId;
  final int amountMinor;
  final int paidAt;
  final String accountName;

  const DuePayment({
    required this.id,
    required this.saleId,
    required this.amountMinor,
    required this.paidAt,
    required this.accountName,
  });
}

class CustomerDueDetail {
  final int customerId;
  final String name;
  final String? phone;
  final List<DueSale> sales;
  final List<DuePayment> payments;
  final int dueMinor;

  const CustomerDueDetail({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.sales,
    required this.payments,
    required this.dueMinor,
  });

  int? get oldestCreatedAt => sales.isEmpty ? null : sales.first.createdAt;
}

class CustomerPaymentResult {
  final int appliedMinor;
  final int dueMinor;

  const CustomerPaymentResult({
    required this.appliedMinor,
    required this.dueMinor,
  });
}

class DuesRepository {
  final AppDatabase _db;

  DuesRepository(this._db);

  Stream<List<CustomerDue>> watchDues() {
    return _db
        .customSelect(
          '''
SELECT c.id AS customer_id, c.name AS name, c.phone AS phone,
       SUM(x.due_minor) AS due_minor,
       MIN(x.created_at) AS oldest_created_at,
       COUNT(*) AS sale_count
FROM (
  SELECT s.id AS id, s.customer_id AS customer_id, s.created_at AS created_at,
         s.total_minor
         - COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.sale_id = s.id), 0) AS due_minor
  FROM sales s
) x
JOIN customers c ON c.id = x.customer_id
WHERE x.due_minor > 0
GROUP BY c.id
ORDER BY due_minor DESC, c.name
''',
          readsFrom: {
            _db.sales,
            _db.customers,
            _db.payments,
          },
        )
        .watch()
        .map(
          (rows) => rows.map((row) {
            return CustomerDue(
              customerId: row.read<int>('customer_id'),
              name: row.read<String>('name'),
              phone: row.read<String?>('phone'),
              dueMinor: row.read<int>('due_minor'),
              oldestCreatedAt: row.read<int>('oldest_created_at'),
              saleCount: row.read<int>('sale_count'),
            );
          }).toList(),
        );
  }

  Stream<CustomerDueDetail?> watchDueDetail(int customerId) {
    return _db
        .customSelect(
          'SELECT id FROM customers WHERE id = ?',
          variables: [Variable<int>(customerId)],
          readsFrom: {
            _db.customers,
            _db.sales,
            _db.payments,
            _db.accounts,
          },
        )
        .watch()
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          return getDueDetail(customerId);
        });
  }

  Future<CustomerDueDetail?> getDueDetail(int customerId) async {
    final customer = await (_db.select(_db.customers)
          ..where((row) => row.id.equals(customerId)))
        .getSingleOrNull();
    if (customer == null) return null;

    final saleRows = await _db.customSelect(
      '''
SELECT s.id AS id, s.total_minor AS total_minor, s.created_at AS created_at,
       s.status AS status,
       COALESCE(SUM(p.amount_minor), 0) AS paid_minor
FROM sales s
LEFT JOIN payments p ON p.sale_id = s.id
WHERE s.customer_id = ?
GROUP BY s.id
HAVING s.total_minor - COALESCE(SUM(p.amount_minor), 0) > 0
ORDER BY s.created_at ASC, s.id ASC
''',
      variables: [Variable<int>(customerId)],
      readsFrom: {_db.sales, _db.payments},
    ).get();

    final paymentRows = await _db.customSelect(
      '''
SELECT p.id AS id, p.sale_id AS sale_id, p.amount_minor AS amount_minor,
       p.paid_at AS paid_at, COALESCE(a.name, 'Account') AS account_name
FROM payments p
JOIN sales s ON s.id = p.sale_id
LEFT JOIN accounts a ON a.id = p.account_id
WHERE s.customer_id = ?
ORDER BY p.paid_at DESC, p.id DESC
''',
      variables: [Variable<int>(customerId)],
      readsFrom: {_db.payments, _db.sales, _db.accounts},
    ).get();

    final sales = saleRows.map((row) {
      final total = row.read<int>('total_minor');
      final paid = row.read<int>('paid_minor');
      return DueSale(
        id: row.read<int>('id'),
        totalMinor: total,
        paidMinor: paid,
        dueMinor: total - paid,
        createdAt: row.read<int>('created_at'),
        status: row.read<String>('status'),
      );
    }).toList();

    return CustomerDueDetail(
      customerId: customer.id,
      name: customer.name,
      phone: customer.phone,
      sales: sales,
      payments: paymentRows
          .map(
            (row) => DuePayment(
              id: row.read<int>('id'),
              saleId: row.read<int>('sale_id'),
              amountMinor: row.read<int>('amount_minor'),
              paidAt: row.read<int>('paid_at'),
              accountName: row.read<String>('account_name'),
            ),
          )
          .toList(),
      dueMinor: sales.fold(0, (sum, sale) => sum + sale.dueMinor),
    );
  }

  Future<CustomerPaymentResult> recordCustomerPayment({
    required int customerId,
    required int amountMinor,
    required int accountId,
    int? saleId,
  }) {
    return _db.transaction(() async {
      if (amountMinor <= 0) {
        throw ArgumentError('Enter an amount greater than zero.');
      }
      final customer = await (_db.select(_db.customers)
            ..where((row) => row.id.equals(customerId)))
          .getSingleOrNull();
      if (customer == null) {
        throw StateError('This customer no longer exists.');
      }
      final account = await (_db.select(_db.accounts)
            ..where((row) => row.id.equals(accountId)))
          .getSingleOrNull();
      if (account == null) {
        throw StateError('This account no longer exists.');
      }

      final rows = await _db.customSelect(
        '''
SELECT s.id AS id, s.total_minor AS total_minor,
       COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.sale_id = s.id), 0) AS paid_minor,
       s.created_at AS created_at
FROM sales s
WHERE s.customer_id = ?
ORDER BY s.created_at ASC, s.id ASC
''',
        variables: [Variable<int>(customerId)],
        readsFrom: {_db.sales, _db.payments},
      ).get();

      final unpaid = <({int id, int total, int paid})>[];
      for (final row in rows) {
        final total = row.read<int>('total_minor');
        final paid = row.read<int>('paid_minor');
        if (total - paid > 0) {
          unpaid.add((id: row.read<int>('id'), total: total, paid: paid));
        }
      }
      if (saleId != null) {
        unpaid.removeWhere((sale) => sale.id != saleId);
        if (unpaid.isEmpty) {
          throw StateError('This sale is already paid.');
        }
      }
      final totalDue =
          unpaid.fold<int>(0, (sum, sale) => sum + (sale.total - sale.paid));
      if (totalDue <= 0) {
        throw StateError('This customer has no dues.');
      }
      if (amountMinor > totalDue) {
        throw ArgumentError('Amount is more than the amount due.');
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      var remaining = amountMinor;
      for (final sale in unpaid) {
        if (remaining <= 0) break;
        final due = sale.total - sale.paid;
        final applied = remaining < due ? remaining : due;
        await _db.into(_db.payments).insert(
              PaymentsCompanion.insert(
                saleId: sale.id,
                accountId: accountId,
                amountMinor: applied,
                paidAt: now,
              ),
            );
        final newPaid = sale.paid + applied;
        final status =
            newPaid >= sale.total ? 'paid' : (newPaid <= 0 ? 'due' : 'partial');
        await (_db.update(_db.sales)..where((row) => row.id.equals(sale.id)))
            .write(SalesCompanion(status: Value(status)));
        remaining -= applied;
      }

      final detail = await getDueDetail(customerId);
      return CustomerPaymentResult(
        appliedMinor: amountMinor,
        dueMinor: detail?.dueMinor ?? 0,
      );
    });
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../db/app_database.dart';

class CsvFile {
  final String name;
  final String content;

  const CsvFile({required this.name, required this.content});
}

String encodeCsv(List<List<String>> rows) {
  return rows.map((row) => row.map(csvField).join(',')).join('\n');
}

String csvField(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

class CsvExportService {
  final AppDatabase _db;

  CsvExportService(this._db);

  Future<List<CsvFile>> buildFiles() async {
    final sales = await _db.customSelect(
      '''
SELECT s.id AS id, s.created_at AS created_at,
       COALESCE(c.name, 'Walk-in') AS customer,
       COALESCE(ch.name, '') AS channel,
       s.total_minor AS total_minor, s.status AS status
FROM sales s
LEFT JOIN customers c ON c.id = s.customer_id
LEFT JOIN channels ch ON ch.id = s.channel_id
ORDER BY s.created_at ASC, s.id ASC
''',
      readsFrom: {_db.sales, _db.customers, _db.channels},
    ).get();

    final saleItems = await _db.customSelect(
      '''
SELECT si.sale_id AS sale_id, s.created_at AS created_at,
       COALESCE(p.name, 'Deleted product') AS product,
       si.qty AS qty, si.unit_price_minor AS unit_price_minor,
       si.unit_cost_minor AS unit_cost_minor
FROM sale_items si
JOIN sales s ON s.id = si.sale_id
LEFT JOIN products p ON p.id = si.product_id
ORDER BY s.created_at ASC, si.sale_id ASC, si.id ASC
''',
      readsFrom: {_db.saleItems, _db.sales, _db.products},
    ).get();

    final payments = await _db.customSelect(
      '''
SELECT p.id AS id, p.sale_id AS sale_id, p.paid_at AS paid_at,
       COALESCE(a.name, '') AS account,
       p.amount_minor AS amount_minor, COALESCE(p.note, '') AS note
FROM payments p
LEFT JOIN accounts a ON a.id = p.account_id
ORDER BY p.paid_at ASC, p.id ASC
''',
      readsFrom: {_db.payments, _db.accounts},
    ).get();

    final expenses = await _db.customSelect(
      '''
SELECT e.id AS id, e.date AS date,
       COALESCE(ec.name, 'Expense') AS category,
       COALESCE(a.name, '') AS account,
       e.amount_minor AS amount_minor, COALESCE(e.note, '') AS note
FROM expenses e
LEFT JOIN expense_categories ec ON ec.id = e.category_id
LEFT JOIN accounts a ON a.id = e.account_id
ORDER BY e.date ASC, e.id ASC
''',
      readsFrom: {_db.expenses, _db.expenseCategories, _db.accounts},
    ).get();

    final accounts = await _db.customSelect(
      '''
SELECT a.id AS id, a.name AS name,
       a.opening_balance_minor AS opening_balance_minor,
       a.archived AS archived,
       a.opening_balance_minor
       + COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.account_id = a.id), 0)
       - COALESCE((SELECT SUM(sm.qty * COALESCE(sm.unit_cost_minor, 0)) FROM stock_movements sm WHERE sm.account_id = a.id), 0)
       - COALESCE((SELECT SUM(e.amount_minor) FROM expenses e WHERE e.account_id = a.id), 0)
       - COALESCE((SELECT SUM(t.amount_minor) FROM transfers t WHERE t.from_account_id = a.id), 0)
       + COALESCE((SELECT SUM(t.amount_minor) FROM transfers t WHERE t.to_account_id = a.id), 0)
       + COALESCE((SELECT SUM(adj.amount_minor) FROM adjustments adj WHERE adj.account_id = a.id), 0)
       AS balance_minor
FROM accounts a
ORDER BY a.id
''',
      readsFrom: {
        _db.accounts,
        _db.payments,
        _db.stockMovements,
        _db.expenses,
        _db.transfers,
        _db.adjustments,
      },
    ).get();

    final files = <CsvFile>[];

    if (sales.isNotEmpty) {
      files.add(
        CsvFile(
          name: 'sales.csv',
          content: encodeCsv([
            ['id', 'date', 'customer', 'channel', 'total_minor', 'status'],
            for (final row in sales)
              [
                '${row.read<int>('id')}',
                _date(row.read<int>('created_at')),
                row.read<String>('customer'),
                row.read<String>('channel'),
                '${row.read<int>('total_minor')}',
                row.read<String>('status'),
              ],
          ]),
        ),
      );
    }

    if (saleItems.isNotEmpty) {
      files.add(
        CsvFile(
          name: 'sale_items.csv',
          content: encodeCsv([
            [
              'sale_id',
              'date',
              'product',
              'qty',
              'unit_price_minor',
              'unit_cost_minor',
              'revenue_minor',
              'profit_minor',
            ],
            for (final row in saleItems)
              [
                '${row.read<int>('sale_id')}',
                _date(row.read<int>('created_at')),
                row.read<String>('product'),
                '${row.read<int>('qty')}',
                '${row.read<int>('unit_price_minor')}',
                '${row.read<int>('unit_cost_minor')}',
                '${row.read<int>('qty') * row.read<int>('unit_price_minor')}',
                '${row.read<int>('qty') * (row.read<int>('unit_price_minor') - row.read<int>('unit_cost_minor'))}',
              ],
          ]),
        ),
      );
    }

    if (payments.isNotEmpty) {
      files.add(
        CsvFile(
          name: 'payments.csv',
          content: encodeCsv([
            ['id', 'sale_id', 'date', 'account', 'amount_minor', 'note'],
            for (final row in payments)
              [
                '${row.read<int>('id')}',
                '${row.read<int>('sale_id')}',
                _date(row.read<int>('paid_at')),
                row.read<String>('account'),
                '${row.read<int>('amount_minor')}',
                row.read<String>('note'),
              ],
          ]),
        ),
      );
    }

    if (expenses.isNotEmpty) {
      files.add(
        CsvFile(
          name: 'expenses.csv',
          content: encodeCsv([
            ['id', 'date', 'category', 'account', 'amount_minor', 'note'],
            for (final row in expenses)
              [
                '${row.read<int>('id')}',
                _date(row.read<int>('date')),
                row.read<String>('category'),
                row.read<String>('account'),
                '${row.read<int>('amount_minor')}',
                row.read<String>('note'),
              ],
          ]),
        ),
      );
    }

    final hasTransactions =
        sales.isNotEmpty || payments.isNotEmpty || expenses.isNotEmpty;
    final hasAccountValue = accounts.any(
      (row) =>
          row.read<int>('opening_balance_minor') != 0 ||
          row.read<int>('balance_minor') != 0,
    );
    if (hasTransactions || hasAccountValue) {
      files.add(
        CsvFile(
          name: 'accounts.csv',
          content: encodeCsv([
            [
              'id',
              'name',
              'opening_balance_minor',
              'balance_minor',
              'archived',
            ],
            for (final row in accounts)
              [
                '${row.read<int>('id')}',
                row.read<String>('name'),
                '${row.read<int>('opening_balance_minor')}',
                '${row.read<int>('balance_minor')}',
                row.read<int>('archived') == 1 ? 'true' : 'false',
              ],
          ]),
        ),
      );
    }

    return files;
  }

  Future<void> share() async {
    final files = await buildFiles();
    if (files.isEmpty) {
      throw const CsvExportEmptyException();
    }
    final dir = await getTemporaryDirectory();
    final attachments = <XFile>[];
    for (final file in files) {
      final target = File(p.join(dir.path, file.name));
      await target.writeAsString(file.content);
      attachments.add(XFile(target.path));
    }
    await Share.shareXFiles(
      attachments,
      subject: 'Invenio CSV export',
      text: 'Invenio CSV export',
    );
  }

  String _date(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds)
          .toIso8601String()
          .substring(0, 10);
}

class CsvExportEmptyException implements Exception {
  const CsvExportEmptyException();
}

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportService(ref.watch(appDatabaseProvider));
});

Future<void> shareCsvExport(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(csvExportServiceProvider).share();
  } on CsvExportEmptyException {
    messenger.showSnackBar(
      const SnackBar(
        content:
            Text('Nothing to export yet. Make a sale or add an expense first.'),
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not create the CSV export.')),
    );
  }
}

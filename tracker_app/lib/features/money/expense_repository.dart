import 'package:drift/drift.dart';

import '../../db/app_database.dart';
import '../settings/account_repository.dart';

class ExpenseItem {
  final Expense expense;
  final String categoryName;
  final String accountName;

  const ExpenseItem({
    required this.expense,
    required this.categoryName,
    required this.accountName,
  });
}

class DeletedExpense {
  final Expense expense;
  final String categoryName;
  final String accountName;

  const DeletedExpense({
    required this.expense,
    required this.categoryName,
    required this.accountName,
  });
}

class ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepository(this._db);

  Stream<List<ExpenseItem>> watchExpenses() {
    return _db
        .customSelect(
          '''
SELECT e.id, e.category_id, e.account_id, e.amount_minor, e.note, e.date,
       COALESCE(ec.name, 'Expense') AS category_name,
       COALESCE(a.name, 'Account') AS account_name
FROM expenses e
LEFT JOIN expense_categories ec ON ec.id = e.category_id
LEFT JOIN accounts a ON a.id = e.account_id
ORDER BY e.date DESC, e.id DESC
''',
          readsFrom: {
            _db.expenses,
            _db.expenseCategories,
            _db.accounts,
          },
        )
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<ExpenseItem?> getExpense(int id) async {
    final row = await _db.customSelect(
      '''
SELECT e.id, e.category_id, e.account_id, e.amount_minor, e.note, e.date,
       COALESCE(ec.name, 'Expense') AS category_name,
       COALESCE(a.name, 'Account') AS account_name
FROM expenses e
LEFT JOIN expense_categories ec ON ec.id = e.category_id
LEFT JOIN accounts a ON a.id = e.account_id
WHERE e.id = ?
''',
      variables: [Variable<int>(id)],
      readsFrom: {
        _db.expenses,
        _db.expenseCategories,
        _db.accounts,
      },
    ).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  ExpenseItem _fromRow(QueryRow row) {
    return ExpenseItem(
      expense: Expense(
        id: row.read<int>('id'),
        categoryId: row.read<int>('category_id'),
        accountId: row.read<int>('account_id'),
        amountMinor: row.read<int>('amount_minor'),
        note: row.read<String?>('note'),
        date: row.read<int>('date'),
      ),
      categoryName: row.read<String>('category_name'),
      accountName: row.read<String>('account_name'),
    );
  }

  Future<int> addExpense({
    required int categoryId,
    required int accountId,
    required int amountMinor,
    required DateTime date,
    String? note,
    bool allowNegative = false,
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError('Enter an amount greater than zero.');
    }
    await _requireAccount(accountId);
    if (!allowNegative) {
      final balance = await _balance(accountId);
      if (balance < amountMinor) {
        throw NegativeBalanceException(
          availableMinor: balance,
          amountMinor: amountMinor,
        );
      }
    }
    return _db.into(_db.expenses).insert(
          ExpensesCompanion.insert(
            categoryId: categoryId,
            accountId: accountId,
            amountMinor: amountMinor,
            note: Value(note),
            date: _dateValue(date),
          ),
        );
  }

  Future<void> updateExpense({
    required int id,
    required int categoryId,
    required int accountId,
    required int amountMinor,
    required DateTime date,
    String? note,
    bool allowNegative = false,
  }) async {
    if (amountMinor <= 0) {
      throw ArgumentError('Enter an amount greater than zero.');
    }
    final existing = await (_db.select(_db.expenses)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      throw StateError('This expense no longer exists.');
    }
    await _requireAccount(accountId);
    if (!allowNegative) {
      var available = await _balance(accountId);
      if (existing.accountId == accountId) {
        available += existing.amountMinor;
      }
      if (available < amountMinor) {
        throw NegativeBalanceException(
          availableMinor: available,
          amountMinor: amountMinor,
        );
      }
    }
    await (_db.update(_db.expenses)..where((row) => row.id.equals(id))).write(
      ExpensesCompanion(
        categoryId: Value(categoryId),
        accountId: Value(accountId),
        amountMinor: Value(amountMinor),
        note: Value(note),
        date: Value(_dateValue(date)),
      ),
    );
  }

  Future<DeletedExpense?> deleteExpense(int id) async {
    final item = await getExpense(id);
    if (item == null) return null;
    await (_db.delete(_db.expenses)..where((row) => row.id.equals(id))).go();
    return DeletedExpense(
      expense: item.expense,
      categoryName: item.categoryName,
      accountName: item.accountName,
    );
  }

  Future<void> restoreExpense(DeletedExpense deleted) async {
    await _db.into(_db.expenses).insert(
          ExpensesCompanion.insert(
            id: Value(deleted.expense.id),
            categoryId: deleted.expense.categoryId,
            accountId: deleted.expense.accountId,
            amountMinor: deleted.expense.amountMinor,
            note: Value(deleted.expense.note),
            date: deleted.expense.date,
          ),
        );
  }

  Future<void> _requireAccount(int accountId) async {
    final account = await (_db.select(_db.accounts)
          ..where((row) => row.id.equals(accountId)))
        .getSingleOrNull();
    if (account == null) {
      throw StateError('This account no longer exists.');
    }
  }

  Future<int> _balance(int accountId) async {
    final row = await _db.customSelect(
      '''
SELECT a.opening_balance_minor
       + COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.account_id = a.id), 0)
       - COALESCE((SELECT SUM(sm.qty * COALESCE(sm.unit_cost_minor, 0)) FROM stock_movements sm WHERE sm.account_id = a.id), 0)
       - COALESCE((SELECT SUM(e.amount_minor) FROM expenses e WHERE e.account_id = a.id), 0)
       - COALESCE((SELECT SUM(t.amount_minor) FROM transfers t WHERE t.from_account_id = a.id), 0)
       + COALESCE((SELECT SUM(t.amount_minor) FROM transfers t WHERE t.to_account_id = a.id), 0)
       + COALESCE((SELECT SUM(adj.amount_minor) FROM adjustments adj WHERE adj.account_id = a.id), 0)
       AS balance_minor
FROM accounts a WHERE a.id = ?
''',
      variables: [Variable<int>(accountId)],
      readsFrom: {
        _db.accounts,
        _db.payments,
        _db.stockMovements,
        _db.expenses,
        _db.transfers,
        _db.adjustments,
      },
    ).getSingle();
    return row.read<int>('balance_minor');
  }
}

int _dateValue(DateTime date) =>
    DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

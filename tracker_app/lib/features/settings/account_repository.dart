import 'package:drift/drift.dart';

import '../../core/utils/date_period.dart';
import '../../db/app_database.dart';

class AccountBalance {
  final Account account;
  final int balanceMinor;

  const AccountBalance({required this.account, required this.balanceMinor});
}

class LedgerEntry {
  final int id;
  final String kind;
  final String title;
  final String? subtitle;
  final int amountMinor;
  final int createdAt;
  final int? saleId;
  final int runningMinor;

  const LedgerEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.amountMinor,
    required this.createdAt,
    required this.saleId,
    required this.runningMinor,
  });

  bool get isIn => amountMinor > 0;
}

class AccountLedger {
  final Account account;
  final int balanceMinor;
  final List<LedgerEntry> entries;

  const AccountLedger({
    required this.account,
    required this.balanceMinor,
    required this.entries,
  });

  List<LedgerEntry> entriesFor(DatePeriod period, {DateTime? now}) {
    return entries
        .where(
          (entry) => period.contains(
            DateTime.fromMillisecondsSinceEpoch(entry.createdAt),
            now: now,
          ),
        )
        .toList();
  }

  int inMinor(DatePeriod period, {DateTime? now}) {
    return entriesFor(period, now: now)
        .where((entry) => entry.amountMinor > 0)
        .fold(0, (sum, entry) => sum + entry.amountMinor);
  }

  int outMinor(DatePeriod period, {DateTime? now}) {
    return entriesFor(period, now: now)
        .where((entry) => entry.amountMinor < 0)
        .fold(0, (sum, entry) => sum - entry.amountMinor);
  }
}

class NegativeBalanceException implements Exception {
  final int availableMinor;
  final int amountMinor;

  const NegativeBalanceException({
    required this.availableMinor,
    required this.amountMinor,
  });

  @override
  String toString() => 'This would leave the account below zero.';
}

class TransferResult {
  final int transferId;
  final int fromBalanceMinor;
  final int toBalanceMinor;

  const TransferResult({
    required this.transferId,
    required this.fromBalanceMinor,
    required this.toBalanceMinor,
  });
}

class AccountRepository {
  final AppDatabase _db;

  AccountRepository(this._db);

  Stream<List<Account>> watchAccounts({bool includeArchived = false}) {
    final query = _db.select(_db.accounts);
    if (!includeArchived) {
      query.where((a) => a.archived.equals(false));
    }
    query.orderBy([(a) => OrderingTerm(expression: a.id)]);
    return query.watch();
  }

  Stream<List<AccountBalance>> watchBalances({bool includeArchived = false}) {
    final archivedFilter = includeArchived ? '' : 'WHERE a.archived = 0';
    return _db
        .customSelect(
          '''
SELECT a.id, a.name, a.opening_balance_minor, a.archived,
       a.opening_balance_minor
       + COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.account_id = a.id), 0)
       - COALESCE((SELECT SUM(sm.qty * COALESCE(sm.unit_cost_minor, 0)) FROM stock_movements sm WHERE sm.account_id = a.id), 0)
       - COALESCE((SELECT SUM(e.amount_minor) FROM expenses e WHERE e.account_id = a.id), 0)
       - COALESCE((SELECT SUM(t.amount_minor) FROM transfers t WHERE t.from_account_id = a.id), 0)
       + COALESCE((SELECT SUM(t.amount_minor) FROM transfers t WHERE t.to_account_id = a.id), 0)
       + COALESCE((SELECT SUM(adj.amount_minor) FROM adjustments adj WHERE adj.account_id = a.id), 0)
       AS balance_minor
FROM accounts a
$archivedFilter
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
        )
        .watch()
        .map(
          (rows) => rows.map((row) {
            final archived = row.read<int>('archived') == 1;
            return AccountBalance(
              account: Account(
                id: row.read<int>('id'),
                name: row.read<String>('name'),
                openingBalanceMinor: row.read<int>('opening_balance_minor'),
                archived: archived,
              ),
              balanceMinor: row.read<int>('balance_minor'),
            );
          }).toList(),
        );
  }

  Future<Account?> getAccount(int id) {
    return (_db.select(_db.accounts)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> getBalance(int accountId) async {
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
    ).getSingleOrNull();
    return row?.read<int>('balance_minor') ?? 0;
  }

  Stream<AccountLedger?> watchLedger(int accountId) {
    return _db
        .customSelect(
          'SELECT id FROM accounts WHERE id = ?',
          variables: [Variable<int>(accountId)],
          readsFrom: {
            _db.accounts,
            _db.payments,
            _db.stockMovements,
            _db.expenses,
            _db.transfers,
            _db.adjustments,
            _db.sales,
            _db.customers,
            _db.products,
            _db.expenseCategories,
          },
        )
        .watch()
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          return getLedger(accountId);
        });
  }

  Future<AccountLedger?> getLedger(int accountId) async {
    final account = await getAccount(accountId);
    if (account == null) return null;
    final rows = await _db
        .customSelect(
          '''
SELECT 'payment' AS kind, p.id AS entry_id, p.paid_at AS created_at,
       p.amount_minor AS amount_minor,
       'Sale #' || p.sale_id AS title,
       COALESCE(c.name, 'Walk-in') AS subtitle,
       p.sale_id AS sale_id
FROM payments p
LEFT JOIN sales s ON s.id = p.sale_id
LEFT JOIN customers c ON c.id = s.customer_id
WHERE p.account_id = ?
UNION ALL
SELECT 'expense', e.id, e.date, -e.amount_minor,
       COALESCE(ec.name, 'Expense'), COALESCE(e.note, ''), NULL
FROM expenses e
LEFT JOIN expense_categories ec ON ec.id = e.category_id
WHERE e.account_id = ?
UNION ALL
SELECT 'restock', sm.id, sm.created_at,
       -(sm.qty * COALESCE(sm.unit_cost_minor, 0)),
       'Restock · ' || pr.name, COALESCE(sm.note, ''), NULL
FROM stock_movements sm
JOIN products pr ON pr.id = sm.product_id
WHERE sm.account_id = ? AND sm.type = 'restock'
UNION ALL
SELECT 'transferOut', t.id, t.created_at, -t.amount_minor,
       'Transfer → ' || COALESCE(a.name, 'Account'), COALESCE(t.note, ''), NULL
FROM transfers t
LEFT JOIN accounts a ON a.id = t.to_account_id
WHERE t.from_account_id = ?
UNION ALL
SELECT 'transferIn', t.id, t.created_at, t.amount_minor,
       'Transfer ← ' || COALESCE(a.name, 'Account'), COALESCE(t.note, ''), NULL
FROM transfers t
LEFT JOIN accounts a ON a.id = t.from_account_id
WHERE t.to_account_id = ?
UNION ALL
SELECT 'adjustment', adj.id, adj.created_at, adj.amount_minor,
       'Adjustment', COALESCE(adj.note, ''), NULL
FROM adjustments adj
WHERE adj.account_id = ?
ORDER BY created_at ASC, entry_id ASC
''',
          variables: List.generate(6, (_) => Variable<int>(accountId)),
          readsFrom: {
            _db.payments,
            _db.sales,
            _db.customers,
            _db.expenses,
            _db.expenseCategories,
            _db.stockMovements,
            _db.products,
            _db.transfers,
            _db.accounts,
            _db.adjustments,
          },
        )
        .get();

    var running = account.openingBalanceMinor;
    final entries = <LedgerEntry>[];
    for (final row in rows) {
      final amount = row.read<int>('amount_minor');
      running += amount;
      entries.add(
        LedgerEntry(
          id: row.read<int>('entry_id'),
          kind: row.read<String>('kind'),
          title: row.read<String>('title'),
          subtitle: row.read<String?>('subtitle'),
          amountMinor: amount,
          createdAt: row.read<int>('created_at'),
          saleId: row.read<int?>('sale_id'),
          runningMinor: running,
        ),
      );
    }

    return AccountLedger(
      account: account,
      balanceMinor: running,
      entries: entries,
    );
  }

  Future<int> addAccount({
    required String name,
    required int openingBalanceMinor,
  }) {
    return _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            name: name,
            openingBalanceMinor: Value(openingBalanceMinor),
          ),
        );
  }

  Future<void> updateAccount({
    required int id,
    required String name,
    required int openingBalanceMinor,
  }) async {
    final statement = _db.update(_db.accounts)..where((a) => a.id.equals(id));
    await statement.write(
      AccountsCompanion(
        name: Value(name),
        openingBalanceMinor: Value(openingBalanceMinor),
      ),
    );
  }

  Future<void> setArchived(int id, bool archived) async {
    final statement = _db.update(_db.accounts)..where((a) => a.id.equals(id));
    await statement.write(
      AccountsCompanion(archived: Value(archived)),
    );
  }

  Future<TransferResult> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required int amountMinor,
    String? note,
    bool allowNegative = false,
  }) async {
    if (fromAccountId == toAccountId) {
      throw ArgumentError('Choose two different accounts.');
    }
    if (amountMinor <= 0) {
      throw ArgumentError('Enter an amount greater than zero.');
    }
    final from = await getAccount(fromAccountId);
    final to = await getAccount(toAccountId);
    if (from == null || to == null) {
      throw StateError('One of these accounts no longer exists.');
    }
    final fromBalance = await getBalance(fromAccountId);
    if (!allowNegative && fromBalance < amountMinor) {
      throw NegativeBalanceException(
        availableMinor: fromBalance,
        amountMinor: amountMinor,
      );
    }
    final id = await _db.into(_db.transfers).insert(
          TransfersCompanion.insert(
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            amountMinor: amountMinor,
            note: Value(note),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    return TransferResult(
      transferId: id,
      fromBalanceMinor: fromBalance - amountMinor,
      toBalanceMinor: await getBalance(toAccountId),
    );
  }

  Future<int> addAdjustment({
    required int accountId,
    required int amountMinor,
    String? note,
  }) async {
    if (amountMinor == 0) {
      throw ArgumentError(
          'Enter a new balance that differs from the current one.');
    }
    final account = await getAccount(accountId);
    if (account == null) {
      throw StateError('This account no longer exists.');
    }
    return _db.into(_db.adjustments).insert(
          AdjustmentsCompanion.insert(
            accountId: accountId,
            amountMinor: amountMinor,
            note: Value(note),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }
}

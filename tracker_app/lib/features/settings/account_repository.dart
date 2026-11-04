import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class AccountBalance {
  final Account account;
  final int balanceMinor;

  const AccountBalance({required this.account, required this.balanceMinor});
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
    final statement = _db.update(_db.accounts)
      ..where((a) => a.id.equals(id));
    await statement.write(
      AccountsCompanion(
        name: Value(name),
        openingBalanceMinor: Value(openingBalanceMinor),
      ),
    );
  }

  Future<void> setArchived(int id, bool archived) async {
    final statement = _db.update(_db.accounts)
      ..where((a) => a.id.equals(id));
    await statement.write(
      AccountsCompanion(archived: Value(archived)),
    );
  }
}

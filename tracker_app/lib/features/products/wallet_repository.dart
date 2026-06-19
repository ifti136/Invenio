import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../core/utils/stream_utils.dart';

part 'wallet_repository.g.dart';

class WalletWithBalance {
  final int walletId;
  final String name;
  final double balance;

  WalletWithBalance(
      {required this.walletId, required this.name, required this.balance});
}

@Riverpod(keepAlive: true)
WalletRepository walletRepository(Ref ref) {
  return WalletRepository(ref.watch(appDatabaseProvider));
}

class WalletRepository {
  final AppDatabase _db;

  WalletRepository(this._db);

  Future<List<Wallet>> getWallets() async {
    return await _db.select(_db.wallets).get();
  }

  Future<Wallet?> getWalletById(int id) async {
    return (_db.select(_db.wallets)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<WalletWithBalance>> getWalletWithBalances() async {
    final wallets = await getWallets();

    final salesQuery = await _db
        .customSelect(
          'SELECT wallet_id, SUM(total) as total FROM sales GROUP BY wallet_id',
        )
        .get();
    final salesMap = <int, double>{};
    for (var row in salesQuery) {
      final id = row.read<int?>('wallet_id');
      if (id != null) {
        salesMap[id] = row.read<double?>('total') ?? 0.0;
      }
    }

    final expensesQuery = await _db
        .customSelect(
          'SELECT wallet_id, SUM(amount) as total FROM expenses GROUP BY wallet_id',
        )
        .get();
    final expensesMap = <int, double>{};
    for (var row in expensesQuery) {
      final id = row.read<int?>('wallet_id');
      if (id != null) {
        expensesMap[id] = row.read<double?>('total') ?? 0.0;
      }
    }

    final transfersOutQuery = await _db
        .customSelect(
          'SELECT from_wallet_id, SUM(amount) as total FROM transfers GROUP BY from_wallet_id',
        )
        .get();
    final transfersOutMap = <int, double>{};
    for (var row in transfersOutQuery) {
      final id = row.read<int?>('from_wallet_id');
      if (id != null) {
        transfersOutMap[id] = row.read<double?>('total') ?? 0.0;
      }
    }

    final transfersInQuery = await _db
        .customSelect(
          'SELECT to_wallet_id, SUM(amount) as total FROM transfers GROUP BY to_wallet_id',
        )
        .get();
    final transfersInMap = <int, double>{};
    for (var row in transfersInQuery) {
      final id = row.read<int?>('to_wallet_id');
      if (id != null) {
        transfersInMap[id] = row.read<double?>('total') ?? 0.0;
      }
    }

    return wallets.map((w) {
      final balance = w.openingBalance +
          (salesMap[w.id] ?? 0.0) -
          (expensesMap[w.id] ?? 0.0) -
          (transfersOutMap[w.id] ?? 0.0) +
          (transfersInMap[w.id] ?? 0.0);
      return WalletWithBalance(walletId: w.id, name: w.name, balance: balance);
    }).toList();
  }

  Stream<List<WalletWithBalance>> watchWalletsWithBalances() {
    return combineLatest4(
      _db.select(_db.wallets).watch(),
      _db.select(_db.sales).watch(),
      _db.select(_db.expenses).watch(),
      _db.select(_db.transfers).watch(),
      (wallets, sales, expenses, transfers) {
        final salesMap = <int, double>{};
        for (final s in sales) {
          if (s.walletId != null) {
            salesMap[s.walletId!] = (salesMap[s.walletId!] ?? 0.0) + s.total;
          }
        }
        final expensesMap = <int, double>{};
        for (final e in expenses) {
          if (e.walletId != null) {
            expensesMap[e.walletId!] =
                (expensesMap[e.walletId!] ?? 0.0) + e.amount;
          }
        }
        final transfersOutMap = <int, double>{};
        final transfersInMap = <int, double>{};
        for (final t in transfers) {
          transfersOutMap[t.fromWalletId] =
              (transfersOutMap[t.fromWalletId] ?? 0.0) + t.amount;
          transfersInMap[t.toWalletId] =
              (transfersInMap[t.toWalletId] ?? 0.0) + t.amount;
        }
        return wallets.map((w) {
          final balance = w.openingBalance +
              (salesMap[w.id] ?? 0.0) -
              (expensesMap[w.id] ?? 0.0) -
              (transfersOutMap[w.id] ?? 0.0) +
              (transfersInMap[w.id] ?? 0.0);
          return WalletWithBalance(
              walletId: w.id, name: w.name, balance: balance);
        }).toList();
      },
    );
  }

  Future<int> createWallet(
      String name, String type, double openingBalance, bool isActive) async {
    return await _db.into(_db.wallets).insert(
          WalletsCompanion(
            name: drift.Value(name),
            type: drift.Value(type),
            openingBalance: drift.Value(openingBalance),
            isActive: drift.Value(isActive),
            createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<bool> updateWallet(int id, String name, String type,
      double openingBalance, bool isActive) async {
    final count =
        await (_db.update(_db.wallets)..where((t) => t.id.equals(id))).write(
      WalletsCompanion(
        name: drift.Value(name),
        type: drift.Value(type),
        openingBalance: drift.Value(openingBalance),
        isActive: drift.Value(isActive),
      ),
    );
    return count > 0;
  }

  Future<int?> getLastUsedWalletId() async {
    final lastSale = await (_db.select(_db.sales)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.date)]))
        .get();
    final lastExpense = await (_db.select(_db.expenses)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.date)]))
        .get();

    if (lastSale.isEmpty && lastExpense.isEmpty) return null;

    if (lastSale.isEmpty) return lastExpense.first.walletId;
    if (lastExpense.isEmpty) return lastSale.first.walletId;

    return lastSale.first.date > lastExpense.first.date
        ? lastSale.first.walletId
        : lastExpense.first.walletId;
  }

  Future<int> deleteWallet(int id) async {
    return await (_db.delete(_db.wallets)..where((t) => t.id.equals(id))).go();
  }
}

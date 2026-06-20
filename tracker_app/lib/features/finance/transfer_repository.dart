import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../products/wallet_repository.dart';

part 'transfer_repository.g.dart';

class TransferWithDetails {
  final Transfer transfer;
  final String fromWalletName;
  final String toWalletName;

  TransferWithDetails({
    required this.transfer,
    required this.fromWalletName,
    required this.toWalletName,
  });
}

@Riverpod(keepAlive: true)
TransferRepository transferRepository(Ref ref) {
  return TransferRepository(ref.watch(appDatabaseProvider), ref);
}

class TransferRepository {
  final AppDatabase _db;
  final Ref _ref;

  TransferRepository(this._db, this._ref);

  Future<List<Transfer>> getTransfers() async {
    return await _db.select(_db.transfers).get();
  }

  Future<List<TransferWithDetails>> getTransfersWithDetails() async {
    final transfers = await _db.select(_db.transfers).get();
    final wallets = await _db.select(_db.wallets).get();
    final walletMap = {for (final w in wallets) w.id: w.name};

    return transfers.reversed.map((t) {
      return TransferWithDetails(
        transfer: t,
        fromWalletName: walletMap[t.fromWalletId] ?? 'Unknown',
        toWalletName: walletMap[t.toWalletId] ?? 'Unknown',
      );
    }).toList();
  }

  Future<Transfer> createTransfer(
    int fromWalletId,
    int toWalletId,
    double amount, {
    String? note,
  }) async {
    if (fromWalletId == toWalletId) {
      throw ArgumentError('Cannot transfer to the same wallet');
    }
    if (amount <= 0) {
      throw ArgumentError('Transfer amount must be positive');
    }

    final repo = _ref.read(walletRepositoryProvider);
    final balances = await repo.getWalletWithBalances();
    final fromBalance = balances.firstWhere(
      (w) => w.walletId == fromWalletId,
    );
    if (fromBalance.balance < amount) {
      throw StateError(
        'Insufficient balance in ${fromBalance.name}. '
        'Available: ${fromBalance.balance.toStringAsFixed(2)}',
      );
    }

    final id = await _db.into(_db.transfers).insert(
          TransfersCompanion.insert(
            fromWalletId: fromWalletId,
            toWalletId: toWalletId,
            amount: amount,
            note: drift.Value(note),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    return await (_db.select(_db.transfers)..where((t) => t.id.equals(id)))
        .getSingle();
  }
}

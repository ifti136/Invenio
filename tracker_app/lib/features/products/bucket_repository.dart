import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../core/utils/stream_utils.dart';

part 'bucket_repository.g.dart';

class BucketWithAvailable {
  final int id;
  final String name;
  final double allocatedAmount;
  final double spent;
  final double available;
  final String? color;

  BucketWithAvailable({
    required this.id,
    required this.name,
    required this.allocatedAmount,
    required this.spent,
    required this.available,
    this.color,
  });
}

@Riverpod(keepAlive: true)
BucketRepository bucketRepository(Ref ref) {
  return BucketRepository(ref.watch(appDatabaseProvider));
}

class BucketRepository {
  BucketRepository(this._db);
  final AppDatabase _db;

  Stream<List<BudgetBucket>> watchAll() {
    final q = _db.select(_db.budgetBuckets)
      ..orderBy([(b) => OrderingTerm.asc(b.name)]);
    return q.watch();
  }

  Future<BudgetBucket?> getById(int id) {
    return (_db.select(_db.budgetBuckets)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> create({
    required String name,
    required double allocatedAmount,
    String? color,
  }) {
    return _db.into(_db.budgetBuckets).insert(
          BudgetBucketsCompanion.insert(
            name: name,
            allocatedAmount: Value(allocatedAmount),
            color: Value(color),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required double allocatedAmount,
    String? color,
  }) async {
    await (_db.update(_db.budgetBuckets)..where((b) => b.id.equals(id))).write(
      BudgetBucketsCompanion(
        name: Value(name),
        allocatedAmount: Value(allocatedAmount),
        color: Value(color),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.budgetBuckets)..where((b) => b.id.equals(id))).go();
  }

  Future<List<BucketWithAvailable>> getBucketWithAvailables() async {
    final buckets = await _db.select(_db.budgetBuckets).get();

    final expenses = await _db.select(_db.expenses).get();
    final spentMap = <int, double>{};
    for (final e in expenses) {
      if (e.bucketId != null) {
        spentMap[e.bucketId!] = (spentMap[e.bucketId!] ?? 0.0) + e.amount;
      }
    }

    return buckets.map((bucket) {
      final spent = spentMap[bucket.id] ?? 0.0;
      return BucketWithAvailable(
        id: bucket.id,
        name: bucket.name,
        allocatedAmount: bucket.allocatedAmount,
        spent: spent,
        available: bucket.allocatedAmount - spent,
        color: bucket.color,
      );
    }).toList();
  }

  Stream<List<BucketWithAvailable>> watchBucketsWithAvailable() {
    return combineLatest2(
      _db.select(_db.budgetBuckets).watch(),
      _db.select(_db.expenses).watch(),
      (buckets, expenses) {
        final spentMap = <int, double>{};
        for (final e in expenses) {
          if (e.bucketId != null) {
            spentMap[e.bucketId!] = (spentMap[e.bucketId!] ?? 0.0) + e.amount;
          }
        }
        return buckets.map((bucket) {
          final spent = spentMap[bucket.id] ?? 0.0;
          return BucketWithAvailable(
            id: bucket.id,
            name: bucket.name,
            allocatedAmount: bucket.allocatedAmount,
            spent: spent,
            available: bucket.allocatedAmount - spent,
            color: bucket.color,
          );
        }).toList();
      },
    );
  }

  Future<List<(Expense, Wallet)>> getExpensesForBucket(int bucketId) async {
    final query = _db.select(_db.expenses).join([
      innerJoin(_db.wallets, _db.wallets.id.equalsExp(_db.expenses.walletId)),
    ])
      ..where(_db.expenses.bucketId.equals(bucketId));

    final rows = await query.get();
    return rows
        .map((row) => (row.readTable(_db.expenses), row.readTable(_db.wallets)))
        .toList();
  }
}

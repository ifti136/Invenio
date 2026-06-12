import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/expenses_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/wallets_table.dart';
import 'tables/allocation_rules_table.dart';
import 'tables/budget_buckets_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Products, Sales, Expenses, StockMovements, Wallets, AllocationRules, BudgetBuckets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(products, products.alertEnabled);
        await m.addColumn(sales, sales.isDiscounted);
        await m.addColumn(sales, sales.normalPrice);
      }
      if (from < 3) {
        await customStatement('DROP TABLE IF EXISTS wallets');
        await customStatement('DROP TABLE IF EXISTS allocation_rules');
        await m.createTable(wallets);
        await m.createTable(allocationRules);
        await m.addColumn(sales, sales.walletId);
        await m.addColumn(sales, sales.ownership);
        await m.addColumn(expenses, expenses.walletId);
        await m.addColumn(expenses, expenses.ownership);
        await m.addColumn(expenses, expenses.allocationRuleId);

        // Use custom SQL for data migration
        await customStatement('INSERT INTO wallets (name, type, openingBalance, isActive, createdAt) VALUES (\'Cash\', \'cash\', 0.0, 1, ${DateTime.now().millisecondsSinceEpoch})');
        await customStatement('UPDATE sales SET walletId = (SELECT id FROM wallets WHERE name = \'Cash\')');
        await customStatement('UPDATE expenses SET walletId = (SELECT id FROM wallets WHERE name = \'Cash\')');
      }
      if (from < 4) {
        await m.createTable(budgetBuckets);
        await m.addColumn(expenses, expenses.bucketId);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tracker.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

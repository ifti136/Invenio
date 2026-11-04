import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_path.dart';
import 'tables/accounts_table.dart';
import 'tables/channels_table.dart';
import 'tables/customers_table.dart';
import 'tables/expense_categories_table.dart';
import 'tables/expenses_table.dart';
import 'tables/payments_table.dart';
import 'tables/products_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/sales_table.dart';
import 'tables/settings_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/transfers_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Products,
  StockMovements,
  Customers,
  Channels,
  ExpenseCategories,
  Accounts,
  Sales,
  SaleItems,
  Payments,
  Expenses,
  Transfers,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaults();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedDefaults() async {
    await batch((b) {
      b.insertAll(channels, [
        ChannelsCompanion.insert(name: 'In person', sort: const Value(0)),
        ChannelsCompanion.insert(name: 'Online', sort: const Value(1)),
      ]);
      b.insertAll(expenseCategories, [
        ExpenseCategoriesCompanion.insert(name: 'Ads', sort: const Value(0)),
        ExpenseCategoriesCompanion.insert(
          name: 'Delivery',
          sort: const Value(1),
        ),
        ExpenseCategoriesCompanion.insert(
          name: 'Packaging',
          sort: const Value(2),
        ),
        ExpenseCategoriesCompanion.insert(name: 'Other', sort: const Value(3)),
      ]);
      b.insert(settings, const SettingsCompanion());
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await appDatabaseFile();
    return NativeDatabase.createInBackground(file);
  });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

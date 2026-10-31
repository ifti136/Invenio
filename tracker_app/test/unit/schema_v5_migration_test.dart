import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:tracker/db/app_database.dart';

void main() {
  late File dbFile;
  AppDatabase? db;

  setUp(() async {
    dbFile = File('test_migration.db');
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  tearDown(() async {
    await db?.close();
    db = null;
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  AppDatabase openV4() {
    return AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (raw) {
          raw.execute('PRAGMA user_version = 4');
          raw.execute(
              'CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, stock INTEGER NOT NULL DEFAULT 0, cost_price REAL NOT NULL, low_stock_threshold INTEGER NOT NULL DEFAULT 3, alert_enabled INTEGER NOT NULL DEFAULT 1, note TEXT, created_at INTEGER NOT NULL)');
          raw.execute(
              'CREATE TABLE sales (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL, selling_price REAL NOT NULL, total REAL NOT NULL, platform TEXT NOT NULL, payment_status TEXT NOT NULL, customer_name TEXT, is_discounted INTEGER NOT NULL DEFAULT 0, normal_price REAL, date INTEGER NOT NULL, created_at INTEGER NOT NULL, wallet_id INTEGER, ownership TEXT NOT NULL DEFAULT \'business\', FOREIGN KEY (product_id) REFERENCES products (id))');
          raw.execute(
              'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, category TEXT NOT NULL, note TEXT, date INTEGER NOT NULL, created_at INTEGER NOT NULL, wallet_id INTEGER, ownership TEXT NOT NULL DEFAULT \'business\', allocation_rule_id INTEGER, bucket_id INTEGER)');
          raw.execute(
              'CREATE TABLE stock_movements (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER NOT NULL, quantity INTEGER NOT NULL, type TEXT NOT NULL, note TEXT, date INTEGER NOT NULL, FOREIGN KEY (product_id) REFERENCES products (id))');
          raw.execute(
              'CREATE TABLE wallets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, opening_balance REAL NOT NULL DEFAULT 0, is_active INTEGER NOT NULL DEFAULT 1, created_at INTEGER NOT NULL)');
          raw.execute(
              'CREATE TABLE allocation_rules (id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT NOT NULL, percentage REAL NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0, is_active INTEGER NOT NULL DEFAULT 1, created_at INTEGER NOT NULL)');
          raw.execute(
              'CREATE TABLE budget_buckets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, allocated_amount REAL NOT NULL, color TEXT, created_at INTEGER NOT NULL)');

          raw.execute(
              'INSERT INTO products (name, cost_price, stock, low_stock_threshold, alert_enabled, created_at) VALUES (\'v4 Product\', 10.0, 100, 10, 1, 123456789)');
          raw.execute(
              'INSERT INTO sales (product_id, quantity, selling_price, total, platform, payment_status, is_discounted, normal_price, date, created_at, wallet_id, ownership) VALUES (1, 1, 20.0, 20.0, \'facebook\', \'paid\', 0, 20.0, 123456789, 123456789, 1, \'business\')');
        },
      ),
    );
  }

  test('Schema v5: Migration from v4 preserves data and creates new tables',
      () async {
    db = openV4();

    await db!.customStatement(
        'INSERT INTO add_on_types (name, is_active, created_at) VALUES (\'Gift Wrap\', 1, 1700000000000)');
    await db!.customStatement(
        'INSERT INTO sale_add_ons (sale_id, add_on_type_id, quantity, cost) VALUES (1, 1, 1, 5.0)');

    final products = await db!.select(db!.products).get();
    expect(products.length, 1);
    expect(products.first.name, 'v4 Product');
    expect(products.first.costPrice, 10.0);

    final sales = await db!.select(db!.sales).get();
    expect(sales.length, 1);
    expect(sales.first.total, 20.0);
  });

  test('Schema v5: sale_add_ons FK constraint prevents invalid saleId',
      () async {
    db = AppDatabase.forTesting(NativeDatabase(dbFile));
    final addOnTypeId = await db!.into(db!.addOnTypes).insert(
          AddOnTypesCompanion.insert(
            name: 'Test',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    expect(
      () async => await db!.into(db!.saleAddOns).insert(
            SaleAddOnsCompanion.insert(
              saleId: 9999,
              addOnTypeId: addOnTypeId,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}

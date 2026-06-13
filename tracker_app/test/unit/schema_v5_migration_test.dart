import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:tracker/db/app_database.dart';

void main() {
  late AppDatabase db;
  late File dbFile;

  setUp(() async {
    dbFile = File('test_migration.db');
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    db = AppDatabase.forTesting(NativeDatabase(dbFile));
  });

  tearDown(() async {
    await db.close();
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  });

  test('Schema v5: Migration from v4 preserves data and creates new tables',
      () async {
    // 1. Setup v4 state
    final v4Db = AppDatabase.forTesting(NativeDatabase(dbFile));
    await v4Db.customStatement('PRAGMA user_version = 4');

    await v4Db.customStatement(
        'CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, costPrice REAL NOT NULL, stock INTEGER NOT NULL, lowStockThreshold INTEGER NOT NULL, alertEnabled BOOLEAN NOT NULL, createdAt INTEGER NOT NULL)');
    await v4Db.customStatement(
        'CREATE TABLE sales (id INTEGER PRIMARY KEY AUTOINCREMENT, productId INTEGER NOT NULL, quantity INTEGER NOT NULL, sellingPrice REAL NOT NULL, total REAL NOT NULL, platform TEXT NOT NULL, paymentStatus TEXT NOT NULL, customerName TEXT, isDiscounted BOOLEAN NOT NULL, normalPrice REAL, date INTEGER NOT NULL, createdAt INTEGER NOT NULL, walletId INTEGER, ownership TEXT, FOREIGN KEY (productId) REFERENCES products (id))');
    await v4Db.customStatement(
        'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, category TEXT NOT NULL, note TEXT, date INTEGER NOT NULL, createdAt INTEGER NOT NULL, walletId INTEGER, ownership TEXT, bucketId INTEGER)');
    await v4Db.customStatement(
        'CREATE TABLE stock_movements (id INTEGER PRIMARY KEY AUTOINCREMENT, productId INTEGER NOT NULL, quantity INTEGER NOT NULL, type TEXT NOT NULL, note TEXT, date INTEGER NOT NULL, FOREIGN KEY (productId) REFERENCES products (id))');
    await v4Db.customStatement(
        'CREATE TABLE wallets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, openingBalance REAL NOT NULL, isActive BOOLEAN NOT NULL, createdAt INTEGER NOT NULL)');
    await v4Db.customStatement(
        'CREATE TABLE allocation_rules (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, percentage REAL NOT NULL, isActive BOOLEAN NOT NULL, createdAt INTEGER NOT NULL)');
    await v4Db.customStatement(
        'CREATE TABLE budget_buckets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, allocatedAmount REAL NOT NULL, color TEXT, createdAt INTEGER NOT NULL)');

    await v4Db.customStatement(
        'INSERT INTO products (name, costPrice, stock, lowStockThreshold, alertEnabled, createdAt) VALUES (\'v4 Product\', 10.0, 100, 10, 1, 123456789)');
    await v4Db.customStatement(
        'INSERT INTO sales (productId, quantity, sellingPrice, total, platform, paymentStatus, isDiscounted, normalPrice, date, createdAt, walletId, ownership) VALUES (1, 1, 20.0, 20.0, \'facebook\', \'paid\', 0, 20.0, 123456789, 123456789, 1, \'business\')');

    await v4Db.close();

    // 2. Trigger migration to v5
    db = AppDatabase.forTesting(NativeDatabase(dbFile));

    // 3. Verify v5 tables exist
    try {
      await db.customStatement(
          'INSERT INTO add_on_types (name, defaultAmount, isActive, createdAt) VALUES (\'Gift Wrap\', 5.0, 1, 1700000000000)');
      await db.customStatement(
          'INSERT INTO sale_add_ons (saleId, addOnTypeId, quantity, cost, createdAt) VALUES (1, 1, 1, 5.0, 1700000000000)');
    } catch (e) {
      fail('Failed to insert into v5 tables: $e');
    }

    // 4. Verify data preservation
    final products = await db.select(db.products).get();
    expect(products.length, 1);
    expect(products.first.name, 'v4 Product');
    expect(products.first.costPrice, 10.0);

    final sales = await db.select(db.sales).get();
    expect(sales.length, 1);
    expect(sales.first.total, 20.0);
  });

  test('Schema v5: sale_add_ons FK constraint prevents invalid saleId',
      () async {
    final addOnTypeId = await db.into(db.addOnTypes).insert(
          AddOnTypesCompanion.insert(
            name: 'Test',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    expect(
      () async => await db.into(db.saleAddOns).insert(
            SaleAddOnsCompanion.insert(
              saleId: 999,
              addOnTypeId: addOnTypeId,
              quantity: Value(1),
              cost: Value(1.0),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}

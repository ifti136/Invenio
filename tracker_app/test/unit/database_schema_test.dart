import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('schema version is 7', () {
    expect(db.schemaVersion, 7);
  });

  test('all 12 v7 tables are created', () async {
    final tables = [
      db.select(db.products),
      db.select(db.stockMovements),
      db.select(db.customers),
      db.select(db.channels),
      db.select(db.expenseCategories),
      db.select(db.expenses),
      db.select(db.accounts),
      db.select(db.sales),
      db.select(db.saleItems),
      db.select(db.payments),
      db.select(db.transfers),
      db.select(db.settings),
    ];
    for (final table in tables) {
      await table.get();
    }
  });

  test('seeds default channels and expense categories', () async {
    final channels = await db.select(db.channels).get();
    final categories = await db.select(db.expenseCategories).get();

    expect(channels.map((c) => c.name), ['In person', 'Online']);
    expect(
      categories.map((c) => c.name),
      ['Ads', 'Delivery', 'Packaging', 'Other'],
    );
  });

  test('seeds a settings row', () async {
    final settings = await db.select(db.settings).getSingle();
    expect(settings.currencySymbol, '\u09F3');
    expect(settings.shopName, isNull);
  });

  test('product money fields use integer minor units', () async {
    final id = await db.into(db.products).insert(
          ProductsCompanion.insert(
            name: 'Wired Mouse',
            priceMinor: 1250,
            costMinor: 800,
          ),
        );
    final product = await (db.select(db.products)
          ..where((p) => p.id.equals(id)))
        .getSingle();

    expect(product.priceMinor, 1250);
    expect(product.costMinor, 800);
    expect(product.stock, 0);
    expect(product.lowStockAt, 3);
    expect(product.archived, false);
  });
}

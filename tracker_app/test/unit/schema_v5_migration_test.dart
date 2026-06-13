import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../../lib/db/app_database.dart';
import '../../lib/db/tables/add_on_types_table.dart';
import '../../lib/db/tables/sale_add_ons_table.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Schema v5: add_on_types table is functional', () async {
    final id = await db.into(db.addOnTypes).insert(
          AddOnTypesCompanion.insert(
            name: 'Gift Wrap',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    expect(id, greaterThan(0));

    final type = await (db.select(db.addOnTypes)..where((t) => t.id.equals(id))).getSingle();
    expect(type.name, 'Gift Wrap');
    expect(type.isActive, true);
  });

  test('Schema v5: sale_add_ons table is functional and respects FKs', () async {
    // 1. Create a product
    final productId = await db.into(db.products).insert(
          ProductsCompanion.insert(
            name: 'Test Product',
            costPrice: 10.0,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // 2. Create a sale
    final saleId = await db.into(db.sales).insert(
          SalesCompanion.insert(
            productId: productId,
            quantity: 1,
            sellingPrice: 20.0,
            total: 20.0,
            platform: 'facebook',
            paymentStatus: 'paid',
            date: DateTime.now().millisecondsSinceEpoch,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // 3. Create an add-on type
    final addOnTypeId = await db.into(db.addOnTypes).insert(
          AddOnTypesCompanion.insert(
            name: 'Premium Box',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // 4. Associate add-on with sale
    final saleAddOnId = await db.into(db.saleAddOns).insert(
          SaleAddOnsCompanion.insert(
            saleId: saleId,
            addOnTypeId: addOnTypeId,
            quantity: Value(2),
            cost: Value(5.0),
          ),
        );
    expect(saleAddOnId, greaterThan(0));

    final entry = await (db.select(db.saleAddOns)..where((s) => s.id.equals(saleAddOnId))).getSingle();
    expect(entry.saleId, saleId);
    expect(entry.addOnTypeId, addOnTypeId);
    expect(entry.quantity, 2);
    expect(entry.cost, 5.0);
  });

  test('Schema v5: sale_add_ons FK constraint prevents invalid saleId', () async {
    final addOnTypeId = await db.into(db.addOnTypes).insert(
          AddOnTypesCompanion.insert(
            name: 'Test',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // Try to insert a sale_add_on with a non-existent saleId
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

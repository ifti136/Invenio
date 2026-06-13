import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_repository.dart';

void main() {
  late AppDatabase db;
  late ProductRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProductRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('create()', () {
    test('returns positive id', () async {
      final id = await repo.create(name: 'Widget', stock: 10, costPrice: 5.0);
      expect(id, greaterThan(0));
    });

    test('correct fields', () async {
      final id = await repo.create(
        name: 'Widget',
        stock: 10,
        costPrice: 5.0,
        lowStockThreshold: 2,
        note: 'test note',
      );
      final product = await repo.getById(id);
      expect(product!.name, 'Widget');
      expect(product.stock, 10);
      expect(product.costPrice, 5.0);
      expect(product.lowStockThreshold, 2);
      expect(product.note, 'test note');
    });

    test('writes initial movement', () async {
      final id = await repo.create(name: 'Widget', stock: 10, costPrice: 5.0);
      final movements = await repo.watchMovements(id).first;
      expect(movements.length, 1);
      expect(movements.first.type, 'initial');
      expect(movements.first.quantity, 10);
    });

    test('stock 0 movement', () async {
      final id = await repo.create(name: 'Widget', stock: 0, costPrice: 5.0);
      final movements = await repo.watchMovements(id).first;
      expect(movements, isEmpty);
    });
  });

  group('restock()', () {
    test('increases stock', () async {
      final id = await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      await repo.restock(productId: id, quantity: 3);
      final product = await repo.getById(id);
      expect(product!.stock, 8);
    });

    test('writes restock movement with note', () async {
      final id = await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      await repo.restock(productId: id, quantity: 3, note: 'reorder');
      final movements = await repo.watchMovements(id).first;
      expect(movements.length, 2);
      expect(movements.first.type, 'restock');
      expect(movements.first.quantity, 3);
      expect(movements.first.note, 'reorder');
    });
  });

  group('adjustStock()', () {
    test('positive delta', () async {
      final id = await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      await repo.adjustStock(productId: id, newStock: 10);
      final product = await repo.getById(id);
      expect(product!.stock, 10);
    });

    test('negative delta', () async {
      final id = await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      await repo.adjustStock(productId: id, newStock: 2);
      final product = await repo.getById(id);
      expect(product!.stock, 2);
    });

    test('writes adjustment movement', () async {
      final id = await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      await repo.adjustStock(productId: id, newStock: 10, note: 'count fix');
      final movements = await repo.watchMovements(id).first;
      expect(movements.first.type, 'adjustment');
      expect(movements.first.quantity, 5);
      expect(movements.first.note, 'count fix');
    });
  });

  group('update()', () {
    test('name only', () async {
      final id = await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      await repo.update(
          id: id,
          name: 'Gadget',
          costPrice: 5.0,
          lowStockThreshold: 5,
          alertEnabled: true);
      final product = await repo.getById(id);
      expect(product!.name, 'Gadget');
      expect(product.lowStockThreshold, 5);
    });

    test('null note leaves unchanged', () async {
      final id = await repo.create(
        name: 'Widget',
        stock: 5,
        costPrice: 5.0,
        note: 'original',
      );
      await repo.update(
          id: id,
          name: 'Widget',
          costPrice: 5.0,
          lowStockThreshold: 5,
          alertEnabled: true);
      final product = await repo.getById(id);
      expect(product!.note, 'original');
    });
  });

  group('watchAll()', () {
    test('empty list', () async {
      final products = await repo.watchAll().first;
      expect(products, isEmpty);
    });

    test('updated after insert', () async {
      await repo.create(name: 'Widget', stock: 5, costPrice: 5.0);
      final products = await repo.watchAll().first;
      expect(products.length, 1);
    });
  });
}

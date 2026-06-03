import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/formatters.dart';
import '../../db/app_database.dart';

part 'product_repository.g.dart';

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(appDatabaseProvider));
}

class ProductRepository {
  ProductRepository(this._db);
  final AppDatabase _db;

  Stream<List<Product>> watchAll() {
    final q = _db.select(_db.products)
      ..orderBy([(p) => OrderingTerm.asc(p.name)]);
    return q.watch();
  }

  Future<Product?> getById(int id) {
    return (_db.select(_db.products)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> create({
    required String name,
    required int stock,
    required double costPrice,
    int? lowStockThreshold,
    String? note,
  }) {
    return _db.transaction(() async {
      final id = await _db.into(_db.products).insert(
            ProductsCompanion.insert(
              name: name,
              costPrice: costPrice,
              stock: Value(stock),
              lowStockThreshold: Value(lowStockThreshold ?? 5),
              note: Value(note),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      if (stock > 0) {
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: id,
                quantity: stock,
                type: 'initial',
                date: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
      return id;
    });
  }

  Future<void> update({
    required int id,
    required String name,
    required int lowStockThreshold,
    String? note,
  }) async {
    await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
      ProductsCompanion(
        name: Value(name),
        lowStockThreshold: Value(lowStockThreshold),
        note: note != null ? Value(note) : Value.absent(),
      ),
    );
  }

  Future<void> restock({
    required int productId,
    required int quantity,
    String? note,
  }) {
    return _db.transaction(() async {
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingle();
      await (_db.update(_db.products)..where((p) => p.id.equals(productId)))
          .write(ProductsCompanion(
        stock: Value(product.stock + quantity),
      ));
      await _db.into(_db.stockMovements).insert(
            StockMovementsCompanion.insert(
              productId: productId,
              quantity: quantity,
              type: 'restock',
              note: Value(note),
              date: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    });
  }

  Future<void> adjustStock({
    required int productId,
    required int newStock,
    String? note,
  }) {
    return _db.transaction(() async {
      final product = await (_db.select(_db.products)
            ..where((p) => p.id.equals(productId)))
          .getSingle();
      final delta = newStock - product.stock;
      await (_db.update(_db.products)..where((p) => p.id.equals(productId)))
          .write(ProductsCompanion(stock: Value(newStock)));
      if (delta != 0) {
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: productId,
                quantity: delta,
                type: 'adjustment',
                note: Value(note),
                date: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.products)..where((p) => p.id.equals(id))).go();
  }

  Stream<List<StockMovement>> watchMovements(int productId) {
    final q = _db.select(_db.stockMovements)
      ..where((m) => m.productId.equals(productId))
      ..orderBy([(m) => OrderingTerm.desc(m.date)]);
    return q.watch();
  }

  String stockLabel(int stock, int? threshold) {
    final t = threshold ?? 5;
    if (stock <= 0) return 'Out of stock';
    if (stock <= t) return 'Low stock ($stock left)';
    return 'In stock: ${formatQuantity(stock.toDouble())}';
  }
}

import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class ProductStats {
  final int products;
  final int lowStock;
  final int outOfStock;
  final int stockValueMinor;

  const ProductStats({
    required this.products,
    required this.lowStock,
    required this.outOfStock,
    required this.stockValueMinor,
  });

  static const empty = ProductStats(
    products: 0,
    lowStock: 0,
    outOfStock: 0,
    stockValueMinor: 0,
  );
}

class ProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  Stream<List<Product>> watchProducts({bool includeArchived = false}) {
    final query = _db.select(_db.products);
    if (!includeArchived) {
      query.where((p) => p.archived.equals(false));
    }
    query.orderBy([(p) => OrderingTerm(expression: p.name)]);
    return query.watch();
  }

  Stream<ProductStats> watchStats() {
    return watchProducts().map((products) {
      var low = 0;
      var out = 0;
      var value = 0;
      for (final product in products) {
        if (product.stock <= 0) {
          out++;
        } else if (product.stock <= product.lowStockAt) {
          low++;
        }
        value += product.stock * product.costMinor;
      }
      return ProductStats(
        products: products.length,
        lowStock: low,
        outOfStock: out,
        stockValueMinor: value,
      );
    });
  }

  Stream<Product?> watchProduct(int id) {
    return (_db.select(_db.products)..where((p) => p.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<Product?> getProduct(int id) {
    return (_db.select(_db.products)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<StockMovement>> watchMovements(int productId) {
    final query = _db.select(_db.stockMovements)
      ..where((m) => m.productId.equals(productId))
      ..orderBy([
        (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        (m) => OrderingTerm(expression: m.id, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<int> createProduct({
    required String name,
    required int priceMinor,
    required int costMinor,
    required int initialStock,
    required int lowStockAt,
    String? note,
    required bool archived,
  }) {
    return _db.transaction(() async {
      final id = await _db.into(_db.products).insert(
            ProductsCompanion.insert(
              name: name,
              priceMinor: priceMinor,
              costMinor: costMinor,
              stock: Value(initialStock),
              lowStockAt: Value(lowStockAt),
              note: Value(note),
              archived: Value(archived),
            ),
          );
      if (initialStock != 0) {
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: id,
                type: 'initial',
                qty: initialStock,
                unitCostMinor: Value(costMinor),
                note: const Value('Opening stock'),
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
      return id;
    });
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required int priceMinor,
    required int costMinor,
    required int stock,
    required int lowStockAt,
    String? note,
    required bool archived,
  }) async {
    await _db.transaction(() async {
      final existing = await getProduct(id);
      if (existing == null) return;
      final statement = _db.update(_db.products)..where((p) => p.id.equals(id));
      await statement.write(
        ProductsCompanion(
          name: Value(name),
          priceMinor: Value(priceMinor),
          costMinor: Value(costMinor),
          stock: Value(stock),
          lowStockAt: Value(lowStockAt),
          note: Value(note),
          archived: Value(archived),
        ),
      );
      final difference = stock - existing.stock;
      if (difference != 0) {
        await _db.into(_db.stockMovements).insert(
              StockMovementsCompanion.insert(
                productId: id,
                type: 'adjustment',
                qty: difference,
                unitCostMinor: Value(costMinor),
                note: const Value('Stock adjusted'),
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      }
    });
  }

  Future<void> restock({
    required int productId,
    required int qty,
    required int unitCostMinor,
    int? accountId,
    String? note,
  }) async {
    await _db.transaction(() async {
      final product = await getProduct(productId);
      if (product == null) return;
      final statement = _db.update(_db.products)
        ..where((p) => p.id.equals(productId));
      await statement.write(
        ProductsCompanion(
          stock: Value(product.stock + qty),
          costMinor: Value(unitCostMinor),
        ),
      );
      await _db.into(_db.stockMovements).insert(
            StockMovementsCompanion.insert(
              productId: productId,
              type: 'restock',
              qty: qty,
              unitCostMinor: Value(unitCostMinor),
              accountId: Value(accountId),
              note: Value(note),
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    });
  }
}

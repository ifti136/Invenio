import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart' as drift;
import '../../db/app_database.dart';
import 'product_repository.dart';

part 'product_provider.g.dart';

@riverpod
Stream<List<Product>> productList(Ref ref) {
  return ref.watch(productRepositoryProvider).watchAll();
}

@riverpod
class ProductFilter extends _$ProductFilter {
  @override
  ProductFilterState build() => const ProductFilterState();

  void setSearch(String s) => state = state.copyWith(search: s);
  void setStockFilter(StockFilter f) => state = state.copyWith(stock: f);
  void clear() => state = const ProductFilterState();
}

enum StockFilter { all, low, out }

class ProductFilterState {
  final String search;
  final StockFilter stock;
  const ProductFilterState({this.search = '', this.stock = StockFilter.all});

  ProductFilterState copyWith({String? search, StockFilter? stock}) =>
      ProductFilterState(
        search: search ?? this.search,
        stock: stock ?? this.stock,
      );
}

@riverpod
List<Product> filteredProductList(Ref ref) {
  final async = ref.watch(productListProvider);
  final filter = ref.watch(productFilterProvider);
  final all = async.value ?? const <Product>[];
  if (all.isEmpty) return all;
  final search = filter.search.trim().toLowerCase();
  return all.where((p) {
    if (search.isNotEmpty && !p.name.toLowerCase().contains(search)) {
      return false;
    }
    switch (filter.stock) {
      case StockFilter.all:
        return true;
      case StockFilter.low:
        return p.stock > 0 && p.stock <= p.lowStockThreshold;
      case StockFilter.out:
        return p.stock <= 0;
    }
  }).toList();
}

@riverpod
Future<Product?> productById(Ref ref, int id) {
  return ref.watch(productRepositoryProvider).getById(id);
}

@riverpod
Stream<List<StockMovement>> productMovements(Ref ref, int productId) {
  return ref.watch(productRepositoryProvider).watchMovements(productId);
}

@riverpod
Stream<List<Sale>> productSales(Ref ref, int productId) {
  final db = ref.watch(appDatabaseProvider);
  final q = db.select(db.sales)
    ..where((s) => s.productId.equals(productId))
    ..orderBy([(s) => drift.OrderingTerm.desc(s.date)])
    ..limit(20);
  return q.watch();
}

class ProductStats {
  final int totalProducts;
  final int outOfStock;
  final int lowStock;
  final double totalStockValue;
  const ProductStats({
    required this.totalProducts,
    required this.outOfStock,
    required this.lowStock,
    required this.totalStockValue,
  });
}

ProductStats computeProductStats(List<Product> products) {
  var out = 0, low = 0;
  double value = 0;
  for (final p in products) {
    value += p.stock * p.costPrice;
    if (p.stock <= 0) {
      out++;
    } else if (p.stock <= p.lowStockThreshold) {
      low++;
    }
  }
  return ProductStats(
    totalProducts: products.length,
    outOfStock: out,
    lowStock: low,
    totalStockValue: value,
  );
}

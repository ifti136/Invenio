import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(appDatabaseProvider));
});

final allProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts(
        includeArchived: true,
      );
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});

final productStatsProvider = StreamProvider<ProductStats>((ref) {
  return ref.watch(productRepositoryProvider).watchStats();
});

final lowStockCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(productRepositoryProvider)
      .watchStats()
      .map((stats) => stats.lowStock);
});

final productProvider = StreamProvider.family<Product?, int>((ref, id) {
  return ref.watch(productRepositoryProvider).watchProduct(id);
});

final productMovementsProvider =
    StreamProvider.family<List<StockMovement>, int>((ref, productId) {
  return ref.watch(productRepositoryProvider).watchMovements(productId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'customer_repository.dart';
import 'sale_models.dart';
import 'sale_repository.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(ref.watch(appDatabaseProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(appDatabaseProvider));
});

final customersProvider = StreamProvider<List<Customer>>((ref) {
  return ref.watch(customerRepositoryProvider).watchCustomers();
});

final salesListProvider = StreamProvider<List<SaleSummary>>((ref) {
  return ref.watch(saleRepositoryProvider).watchSales();
});

final saleDetailProvider =
    StreamProvider.family<SaleDetail?, int>((ref, saleId) {
  return ref.watch(saleRepositoryProvider).watchSaleDetail(saleId);
});

final salesDefaultsProvider = FutureProvider<SalesDefaults>((ref) {
  return ref.watch(saleRepositoryProvider).loadDefaults();
});

final recentProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(saleRepositoryProvider).watchRecentProducts();
});

final topSoldProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(saleRepositoryProvider).watchTopSoldProducts();
});

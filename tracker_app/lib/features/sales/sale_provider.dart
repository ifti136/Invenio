import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import 'sale_repository.dart';

part 'sale_provider.g.dart';

@riverpod
Stream<List<Sale>> saleList(Ref ref) {
  return ref.watch(saleRepositoryProvider).watchAll();
}

@riverpod
Stream<List<Sale>> filteredSaleList(Ref ref, SaleFilter filter) {
  return ref.watch(saleRepositoryProvider).watchFiltered(filter);
}

@riverpod
Future<Sale?> saleDetail(Ref ref, int id) {
  return ref.watch(saleRepositoryProvider).getById(id);
}

@riverpod
Future<Sale?> lastSellingPrice(Ref ref, int productId) {
  return ref.watch(saleRepositoryProvider).lastSellingPriceFor(productId);
}

class SaleStats {
  final int count;
  final double revenue;
  final double estimatedProfit;
  final int dueCount;

  const SaleStats({
    required this.count,
    required this.revenue,
    required this.estimatedProfit,
    required this.dueCount,
  });
}

SaleStats computeSaleStats(List<Sale> sales, Map<int, double> costByProductId) {
  var revenue = 0.0;
  var profit = 0.0;
  var due = 0;
  for (final s in sales) {
    revenue += s.total;
    final cost = costByProductId[s.productId];
    if (cost != null) {
      profit += s.total - (s.quantity * cost);
    }
    if (s.paymentStatus == 'due') due++;
  }
  return SaleStats(
    count: sales.length,
    revenue: revenue,
    estimatedProfit: profit,
    dueCount: due,
  );
}

@riverpod
Future<Map<int, double>> productCostMap(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final all = await db.select(db.products).get();
  return {for (final p in all) p.id: p.costPrice};
}

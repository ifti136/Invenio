import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../models/dashboard_summary.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardSummary> dashboard(Ref ref) async {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final startOfDay =
      DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  final endOfDay =
      DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

  final todaySales = await (db.select(db.sales)
        ..where((t) =>
            t.date.isBiggerOrEqualValue(startOfDay) &
            t.date.isSmallerOrEqualValue(endOfDay)))
      .get();

  final todayExpenses = await (db.select(db.expenses)
        ..where((t) =>
            t.date.isBiggerOrEqualValue(startOfDay) &
            t.date.isSmallerOrEqualValue(endOfDay)))
      .get();

  final allProducts = await db.select(db.products).get();
  final productMap = {for (final p in allProducts) p.id: p};

  double grossProfit = 0;
  double fbProfit = 0;
  double offlineProfit = 0;
  double revenue = 0;

  for (final s in todaySales) {
    final product = productMap[s.productId];
    if (product == null) continue;
    final profit = s.sellingPrice - product.costPrice;
    grossProfit += profit * s.quantity;
    revenue += s.total;
    if (s.platform == 'facebook') {
      fbProfit += profit * s.quantity;
    } else {
      offlineProfit += profit * s.quantity;
    }
  }

  final totalExpenses = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);

  final dueAmount = await (db.select(db.sales)
        ..where((t) => t.paymentStatus.equals('due')))
      .get()
      .then((rows) => rows.fold(0.0, (sum, s) => sum + s.total));

  final lowStock =
      allProducts.where((p) => p.stock < p.lowStockThreshold).toList();

  return DashboardSummary(
    salesToday: todaySales.length,
    revenueToday: revenue,
    grossProfitToday: grossProfit,
    netProfitToday: grossProfit - totalExpenses,
    totalDue: dueAmount,
    facebookProfit: fbProfit,
    offlineProfit: offlineProfit,
    lowStockProducts: lowStock,
  );
}

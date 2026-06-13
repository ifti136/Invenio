import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../models/dashboard_summary.dart';
import '../../core/utils/profit_calculator.dart';
import '../products/wallet_repository.dart';
import '../products/bucket_repository.dart';

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
            t.ownership.equals('business') &
            t.date.isBiggerOrEqualValue(startOfDay) &
            t.date.isSmallerOrEqualValue(endOfDay)))
      .get();

  final allAddOns = await (db.select(db.saleAddOns)
        ..where((s) => s.saleId.isIn(todaySales.map((s) => s.id))))
      .get();

  final addOnsMap = {
    for (final s in todaySales)
      s.id: allAddOns.where((a) => a.saleId == s.id).toList()
  };

  final todayExpenses = await (db.select(db.expenses)
        ..where((t) =>
            t.ownership.equals('business') &
            t.date.isBiggerOrEqualValue(startOfDay) &
            t.date.isSmallerOrEqualValue(endOfDay)))
      .get();

  final allProducts = await db.select(db.products).get();
  final productMap = {for (final p in allProducts) p.id: p};

  double grossProfit = 0;
  double fbRevenue = 0;
  double offlineRevenue = 0;
  double revenue = 0;

  for (final s in todaySales) {
    final product = productMap[s.productId];
    if (product == null) continue;

    final addOns = addOnsMap[s.id] ?? [];
    final netProfit =
        ProfitCalculator.calculateNetProfit(s, product.costPrice, addOns);

    grossProfit += netProfit;
    revenue += s.total;
    if (s.platform == 'facebook') {
      fbRevenue += s.total;
    } else {
      offlineRevenue += s.total;
    }
  }

  final totalExpenses = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);

  final dueAmount = await (db.select(db.sales)
        ..where((t) =>
            t.ownership.equals('business') & t.paymentStatus.equals('due')))
      .get()
      .then((rows) => rows.fold(0.0, (sum, s) => sum + s.total));

  final lowStock = allProducts
      .where((p) => p.alertEnabled && p.stock <= p.lowStockThreshold)
      .toList();

  // Calculate sales for the last 7 days
  final salesLast7Days = <double>[];
  for (int i = 6; i >= 0; i--) {
    final date = DateTime.now().subtract(Duration(days: i));
    final start =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    final count = await (db.select(db.sales)
          ..where((t) =>
              t.ownership.equals('business') &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end)))
        .get()
        .then((rows) => rows.length.toDouble());
    salesLast7Days.add(count);
  }

  return DashboardSummary(
    salesToday: todaySales.length,
    revenueToday: revenue,
    grossProfitToday: grossProfit,
    netProfitToday: grossProfit - totalExpenses,
    totalDue: dueAmount,
    facebookRevenue: fbRevenue,
    offlineRevenue: offlineRevenue,
    lowStockProducts: lowStock,
    salesLast7Days: salesLast7Days,
  );
}

@riverpod
Stream<List<WalletBalance>> walletBalances(Ref ref) {
  return ref.watch(walletRepositoryProvider).watchWalletsWithBalances();
}

@riverpod
Stream<List<BucketBalance>> bucketAvailables(Ref ref) {
  return ref.watch(bucketRepositoryProvider).watchBucketsWithAvailable();
}

@riverpod
Stream<double> currentDue(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.sales)
    ..where(
        (t) => t.ownership.equals('business') & t.paymentStatus.equals('due'));
  return query.watch().map((rows) => rows.fold(0.0, (sum, s) => sum + s.total));
}

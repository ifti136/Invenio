import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../models/monthly_report.dart';

part 'report_repository.g.dart';

@Riverpod(keepAlive: true)
ReportRepository reportRepository(Ref ref) {
  return ReportRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Future<List<DailySnapshot>> dailySnapshots(Ref ref, int year, int month) {
  return ref.watch(reportRepositoryProvider).dailySnapshots(year, month);
}

@riverpod
Future<List<MonthlySummary>> monthlySummaries(Ref ref, int year) {
  return ref.watch(reportRepositoryProvider).monthlySummaries(year);
}

@riverpod
Future<List<ProductReportRow>> productReport(Ref ref) {
  return ref.watch(reportRepositoryProvider).productReport();
}

class ReportRepository {
  ReportRepository(this._db);
  final AppDatabase _db;

  Future<List<DailySnapshot>> dailySnapshots(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final sales = await (_db.select(_db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              s.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final expenses = await (_db.select(_db.expenses)
          ..where((e) =>
              e.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              e.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final products = await _db.select(_db.products).get();
    final costMap = {for (final p in products) p.id: p.costPrice};

    final salesByDay = <String, List<Sale>>{};
    for (final s in sales) {
      final key = _dayKey(s.date);
      salesByDay.putIfAbsent(key, () => []).add(s);
    }
    final expensesByDay = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = _dayKey(e.date);
      expensesByDay.putIfAbsent(key, () => []).add(e);
    }

    final days = <DailySnapshot>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final key = _dayKeyFromDate(date);
      final daySales = salesByDay[key] ?? [];
      final dayExpenses = expensesByDay[key] ?? [];

      var revenue = 0.0;
      var profit = 0.0;
      for (final s in daySales) {
        final cost = costMap[s.productId] ?? 0;
        revenue += s.total;
        profit += s.total - (s.quantity * cost);
      }
      var expTotal = 0.0;
      for (final e in dayExpenses) {
        expTotal += e.amount;
      }

      days.add(DailySnapshot(
        date: date,
        revenue: revenue,
        profit: profit,
        expenses: expTotal,
      ));
    }
    return days;
  }

  Future<List<MonthlySummary>> monthlySummaries(int year) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);

    final sales = await (_db.select(_db.sales)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              s.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final expenses = await (_db.select(_db.expenses)
          ..where((e) =>
              e.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              e.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final products = await _db.select(_db.products).get();
    final costMap = {for (final p in products) p.id: p.costPrice};

    final salesByMonth = <int, List<Sale>>{};
    for (final s in sales) {
      final m = DateTime.fromMillisecondsSinceEpoch(s.date).month;
      salesByMonth.putIfAbsent(m, () => []).add(s);
    }
    final expensesByMonth = <int, List<Expense>>{};
    for (final e in expenses) {
      final m = DateTime.fromMillisecondsSinceEpoch(e.date).month;
      expensesByMonth.putIfAbsent(m, () => []).add(e);
    }

    const labels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final months = <MonthlySummary>[];
    for (var m = 1; m <= 12; m++) {
      final monthSales = salesByMonth[m] ?? [];
      final monthExpenses = expensesByMonth[m] ?? [];

      var revenue = 0.0;
      var profit = 0.0;
      for (final s in monthSales) {
        final cost = costMap[s.productId] ?? 0;
        revenue += s.total;
        profit += s.total - (s.quantity * cost);
      }
      var expTotal = 0.0;
      for (final e in monthExpenses) {
        expTotal += e.amount;
      }

      months.add(MonthlySummary(
        month: m,
        label: labels[m - 1],
        revenue: revenue,
        profit: profit,
        expenses: expTotal,
        salesCount: monthSales.length,
      ));
    }
    return months;
  }

  Future<List<ProductReportRow>> productReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final query = _db.select(_db.sales);
    if (from != null) {
      query.where(
          (s) => s.date.isBiggerOrEqualValue(from.millisecondsSinceEpoch));
    }
    if (to != null) {
      query.where(
          (s) => s.date.isSmallerOrEqualValue(to.millisecondsSinceEpoch));
    }
    final sales = await query.get();
    final products = await _db.select(_db.products).get();
    final productMap = {for (final p in products) p.id: p};

    final grouped = <int, List<Sale>>{};
    for (final s in sales) {
      grouped.putIfAbsent(s.productId, () => []).add(s);
    }

    return grouped.entries.map((e) {
      final product = productMap[e.key];
      final name = product?.name ?? 'Deleted product';
      final cost = product?.costPrice ?? 0;
      var qty = 0;
      var rev = 0.0;
      for (final s in e.value) {
        qty += s.quantity;
        rev += s.total;
      }
      final profit = rev - (qty * cost);
      return ProductReportRow(
        productId: e.key,
        productName: name,
        quantitySold: qty,
        revenue: rev,
        profit: profit,
        costPrice: cost,
      );
    }).toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  static String _dayKey(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}-${_p(d.month)}-${_p(d.day)}';
  }

  static String _dayKeyFromDate(DateTime d) {
    return '${d.year}-${_p(d.month)}-${_p(d.day)}';
  }

  static String _p(int v) => v.toString().padLeft(2, '0');
}

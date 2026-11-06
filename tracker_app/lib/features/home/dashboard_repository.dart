import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class TodayStats {
  final int salesCount;
  final int revenueMinor;
  final int profitMinor;

  const TodayStats({
    required this.salesCount,
    required this.revenueMinor,
    required this.profitMinor,
  });

  static const TodayStats empty = TodayStats(
    salesCount: 0,
    revenueMinor: 0,
    profitMinor: 0,
  );

  bool get isEmpty => salesCount == 0 && revenueMinor == 0 && profitMinor == 0;
}

class DashboardRepository {
  final AppDatabase _db;

  DashboardRepository(this._db);

  Stream<TodayStats> watchTodayStats({DateTime? now}) {
    final current = now ?? DateTime.now();
    final start = DateTime(
      current.year,
      current.month,
      current.day,
    ).millisecondsSinceEpoch;
    final end = DateTime(
      current.year,
      current.month,
      current.day + 1,
    ).millisecondsSinceEpoch;

    return _db
        .customSelect(
          '''
SELECT COUNT(*) AS sales_count,
       COALESCE(SUM(x.revenue_minor), 0) AS revenue_minor,
       COALESCE(SUM(x.profit_minor), 0) AS profit_minor
FROM (
  SELECT s.id AS id,
         COALESCE(SUM(si.qty * si.unit_price_minor), 0) AS revenue_minor,
         COALESCE(SUM(si.qty * (si.unit_price_minor - si.unit_cost_minor)), 0) AS profit_minor
  FROM sales s
  LEFT JOIN sale_items si ON si.sale_id = s.id
  WHERE s.created_at >= ? AND s.created_at < ?
  GROUP BY s.id
) x
''',
          variables: [Variable<int>(start), Variable<int>(end)],
          readsFrom: {_db.sales, _db.saleItems},
        )
        .watchSingle()
        .map(
          (row) => TodayStats(
            salesCount: row.read<int>('sales_count'),
            revenueMinor: row.read<int>('revenue_minor'),
            profitMinor: row.read<int>('profit_minor'),
          ),
        );
  }
}

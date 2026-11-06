import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../db/app_database.dart';

enum ReportPreset { week, month, year, custom }

enum ReportGranularity { day, month }

class ReportRange {
  final DateTime start;
  final DateTime end;
  final ReportGranularity granularity;

  const ReportRange({
    required this.start,
    required this.end,
    required this.granularity,
  });

  factory ReportRange.week(DateTime now) {
    final today = _dayStart(now);
    return ReportRange(
      start: DateTime(today.year, today.month, today.day - 6),
      end: DateTime(today.year, today.month, today.day + 1),
      granularity: ReportGranularity.day,
    );
  }

  factory ReportRange.month(DateTime now) {
    return ReportRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1),
      granularity: ReportGranularity.day,
    );
  }

  factory ReportRange.year(DateTime now) {
    return ReportRange(
      start: DateTime(now.year),
      end: DateTime(now.year + 1),
      granularity: ReportGranularity.month,
    );
  }

  factory ReportRange.custom(DateTime start, DateTime end) {
    final first = _dayStart(start);
    final last = _dayStart(end);
    final span = last.difference(first).inDays + 1;
    return ReportRange(
      start: first,
      end: DateTime(last.year, last.month, last.day + 1),
      granularity: span > 31 ? ReportGranularity.month : ReportGranularity.day,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReportRange &&
      other.start == start &&
      other.end == end &&
      other.granularity == granularity;

  @override
  int get hashCode => Object.hash(start, end, granularity);
}

class ProfitLoss {
  final int revenueMinor;
  final int cogsMinor;
  final int expensesMinor;

  const ProfitLoss({
    required this.revenueMinor,
    required this.cogsMinor,
    required this.expensesMinor,
  });

  static const ProfitLoss empty =
      ProfitLoss(revenueMinor: 0, cogsMinor: 0, expensesMinor: 0);

  int get grossProfitMinor => revenueMinor - cogsMinor;

  int get netProfitMinor => grossProfitMinor - expensesMinor;

  double get margin => revenueMinor == 0 ? 0 : netProfitMinor / revenueMinor;

  bool get isEmpty => revenueMinor == 0 && expensesMinor == 0;
}

class ReportBucket {
  final String label;
  final int revenueMinor;
  final int profitMinor;

  const ReportBucket({
    required this.label,
    required this.revenueMinor,
    required this.profitMinor,
  });
}

class ProductBreakdown {
  final int productId;
  final String name;
  final int qty;
  final int revenueMinor;
  final int profitMinor;

  const ProductBreakdown({
    required this.productId,
    required this.name,
    required this.qty,
    required this.revenueMinor,
    required this.profitMinor,
  });
}

class ChannelBreakdown {
  final int channelId;
  final String name;
  final int qty;
  final int revenueMinor;
  final int profitMinor;

  const ChannelBreakdown({
    required this.channelId,
    required this.name,
    required this.qty,
    required this.revenueMinor,
    required this.profitMinor,
  });
}

class ReportData {
  final ProfitLoss pnl;
  final List<ReportBucket> buckets;
  final List<ProductBreakdown> products;
  final List<ChannelBreakdown> channels;

  const ReportData({
    required this.pnl,
    required this.buckets,
    required this.products,
    required this.channels,
  });

  bool get isEmpty => pnl.isEmpty;
}

class ReportRepository {
  final AppDatabase _db;

  ReportRepository(this._db);

  Stream<ReportData> watchReport(ReportRange range) {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.sales,
            _db.saleItems,
            _db.products,
            _db.channels,
            _db.expenses,
          },
        )
        .watch()
        .asyncMap((_) => getReport(range));
  }

  Future<ReportData> getReport(ReportRange range) async {
    final start = range.start.millisecondsSinceEpoch;
    final end = range.end.millisecondsSinceEpoch;

    final itemRows = await _db.customSelect(
      '''
SELECT s.id AS sale_id, s.channel_id AS channel_id, s.created_at AS created_at,
       si.product_id AS product_id, si.qty AS qty,
       si.unit_price_minor AS unit_price_minor,
       si.unit_cost_minor AS unit_cost_minor,
       COALESCE(p.name, 'Deleted product') AS product_name,
       COALESCE(c.name, 'Unknown channel') AS channel_name
FROM sale_items si
JOIN sales s ON s.id = si.sale_id
LEFT JOIN products p ON p.id = si.product_id
LEFT JOIN channels c ON c.id = s.channel_id
WHERE s.created_at >= ? AND s.created_at < ?
ORDER BY s.created_at ASC, s.id ASC
''',
      variables: [Variable<int>(start), Variable<int>(end)],
      readsFrom: {
        _db.sales,
        _db.saleItems,
        _db.products,
        _db.channels,
      },
    ).get();

    final expenseRow = await _db.customSelect(
      'SELECT COALESCE(SUM(amount_minor), 0) AS total FROM expenses WHERE date >= ? AND date < ?',
      variables: [Variable<int>(start), Variable<int>(end)],
      readsFrom: {_db.expenses},
    ).getSingle();

    final buckets = _emptyBuckets(range);
    final products = <int, _MutableBreakdown>{};
    final channels = <int, _MutableBreakdown>{};
    var revenue = 0;
    var cogs = 0;

    for (final row in itemRows) {
      final qty = row.read<int>('qty');
      final unitPrice = row.read<int>('unit_price_minor');
      final unitCost = row.read<int>('unit_cost_minor');
      final lineRevenue = qty * unitPrice;
      final lineProfit = qty * (unitPrice - unitCost);
      revenue += lineRevenue;
      cogs += qty * unitCost;

      final productId = row.read<int>('product_id');
      final productName = row.read<String>('product_name');
      final product = products.putIfAbsent(
        productId,
        () => _MutableBreakdown(productName),
      );
      product.qty += qty;
      product.revenueMinor += lineRevenue;
      product.profitMinor += lineProfit;

      final channelId = row.read<int>('channel_id');
      final channelName = row.read<String>('channel_name');
      final channel = channels.putIfAbsent(
        channelId,
        () => _MutableBreakdown(channelName),
      );
      channel.qty += qty;
      channel.revenueMinor += lineRevenue;
      channel.profitMinor += lineProfit;

      final createdAt = DateTime.fromMillisecondsSinceEpoch(
        row.read<int>('created_at'),
      );
      final index = _bucketIndex(range, createdAt);
      if (index >= 0 && index < buckets.length) {
        buckets[index] = ReportBucket(
          label: buckets[index].label,
          revenueMinor: buckets[index].revenueMinor + lineRevenue,
          profitMinor: buckets[index].profitMinor + lineProfit,
        );
      }
    }

    final productList = products.entries
        .map(
          (entry) => ProductBreakdown(
            productId: entry.key,
            name: entry.value.name,
            qty: entry.value.qty,
            revenueMinor: entry.value.revenueMinor,
            profitMinor: entry.value.profitMinor,
          ),
        )
        .toList()
      ..sort((a, b) => b.revenueMinor.compareTo(a.revenueMinor));

    final channelList = channels.entries
        .map(
          (entry) => ChannelBreakdown(
            channelId: entry.key,
            name: entry.value.name,
            qty: entry.value.qty,
            revenueMinor: entry.value.revenueMinor,
            profitMinor: entry.value.profitMinor,
          ),
        )
        .toList()
      ..sort((a, b) => b.revenueMinor.compareTo(a.revenueMinor));

    return ReportData(
      pnl: ProfitLoss(
        revenueMinor: revenue,
        cogsMinor: cogs,
        expensesMinor: expenseRow.read<int>('total'),
      ),
      buckets: buckets,
      products: productList,
      channels: channelList,
    );
  }

  List<ReportBucket> _emptyBuckets(ReportRange range) {
    final buckets = <ReportBucket>[];
    if (range.granularity == ReportGranularity.day) {
      final days = range.end.difference(range.start).inDays;
      final dayFormat = DateFormat(days <= 7 ? 'E' : 'd');
      for (var i = 0; i < days; i++) {
        final date = DateTime(
          range.start.year,
          range.start.month,
          range.start.day + i,
        );
        buckets.add(
          ReportBucket(
            label: dayFormat.format(date),
            revenueMinor: 0,
            profitMinor: 0,
          ),
        );
      }
      return buckets;
    }

    final monthFormat = DateFormat('MMM');
    var cursor = DateTime(range.start.year, range.start.month);
    while (cursor.isBefore(range.end)) {
      buckets.add(
        ReportBucket(
          label: monthFormat.format(cursor),
          revenueMinor: 0,
          profitMinor: 0,
        ),
      );
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return buckets;
  }

  int _bucketIndex(ReportRange range, DateTime createdAt) {
    if (range.granularity == ReportGranularity.month) {
      return (createdAt.year - range.start.year) * 12 +
          (createdAt.month - range.start.month);
    }
    final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return date.difference(range.start).inDays;
  }
}

class _MutableBreakdown {
  final String name;
  int qty = 0;
  int revenueMinor = 0;
  int profitMinor = 0;

  _MutableBreakdown(this.name);
}

DateTime _dayStart(DateTime date) => DateTime(date.year, date.month, date.day);

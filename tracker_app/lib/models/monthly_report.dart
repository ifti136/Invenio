class DailySnapshot {
  final DateTime date;
  final double revenue;
  final double profit;
  final double expenses;

  const DailySnapshot({
    required this.date,
    required this.revenue,
    required this.profit,
    required this.expenses,
  });

  double get netProfit => profit - expenses;
}

class MonthlySummary {
  final int month;
  final String label;
  final double revenue;
  final double profit;
  final double expenses;
  final int salesCount;

  const MonthlySummary({
    required this.month,
    required this.label,
    required this.revenue,
    required this.profit,
    required this.expenses,
    required this.salesCount,
  });

  double get netProfit => profit - expenses;
}

class ProductReportRow {
  final int productId;
  final String productName;
  final int quantitySold;
  final double revenue;
  final double profit;
  final double costPrice;

  const ProductReportRow({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
    required this.profit,
    required this.costPrice,
  });

  double get marginPct =>
      revenue > 0 ? ((profit / revenue) * 100) : 0;
}

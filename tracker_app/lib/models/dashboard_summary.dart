import '../db/app_database.dart';

class DashboardSummary {
  final int salesToday;
  final double revenueToday;
  final double grossProfitToday;
  final double netProfitToday;
  final double totalDue;
  final double facebookProfit;
  final double offlineProfit;
  final List<Product> lowStockProducts;

  const DashboardSummary({
    required this.salesToday,
    required this.revenueToday,
    required this.grossProfitToday,
    required this.netProfitToday,
    required this.totalDue,
    required this.facebookProfit,
    required this.offlineProfit,
    required this.lowStockProducts,
  });
}

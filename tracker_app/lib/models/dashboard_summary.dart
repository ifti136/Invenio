import '../db/app_database.dart';

class DashboardSummary {
  final int salesToday;
  final double revenueToday;
  final double grossProfitToday;
  final double netProfitToday;
  final double totalDue;
  final double facebookRevenue;
  final double offlineRevenue;
  final List<Product> lowStockProducts;
  final List<double> salesLast7Days;

  const DashboardSummary({
    required this.salesToday,
    required this.revenueToday,
    required this.grossProfitToday,
    required this.netProfitToday,
    required this.totalDue,
    required this.facebookRevenue,
    required this.offlineRevenue,
    required this.lowStockProducts,
    required this.salesLast7Days,
  });
}

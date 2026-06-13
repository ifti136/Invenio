import 'package:tracker/db/tables/sales_table.dart';
import 'package:tracker/db/tables/sale_add_ons_table.dart';

class ProfitCalculator {
  /// Calculates the gross profit for a single sale item (excluding add-ons).
  /// Formula: (sellingPrice - costPrice) * quantity
  static double calculateGrossProfit(Sale sale) {
    return (sale.sellingPrice - sale.costPrice) * sale.quantity;
  }

  /// Calculates the total cost of all add-ons associated with a sale.
  /// Formula: Σ (addOn.cost * addOn.quantity)
  static double calculateAddOnCost(List<SaleAddOn> addOns) {
    return addOns.fold(0.0, (sum, item) => sum + (item.cost * item.quantity));
  }

  /// Calculates the net profit for a sale, subtracting add-on costs from gross profit.
  /// Formula: ((sellingPrice - costPrice) * quantity) - Σ addOnAmounts
  static double calculateNetProfit(Sale sale, List<SaleAddOn> addOns) {
    return calculateGrossProfit(sale) - calculateAddOnCost(addOns);
  }
}

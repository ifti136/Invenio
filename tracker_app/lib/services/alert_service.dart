import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../db/app_database.dart';

part 'alert_service.g.dart';

@Riverpod(keepAlive: true)
AlertService alertService(Ref ref) => AlertService();

sealed class AppAlert {
  const AppAlert();
  String get message;
  IconHint get icon;
}

class BelowCostAlert extends AppAlert {
  final double costPrice;
  final double sellingPrice;
  const BelowCostAlert({required this.costPrice, required this.sellingPrice});

  @override
  String get message =>
      'Selling at ৳${sellingPrice.toStringAsFixed(2)} is below your cost of ৳${costPrice.toStringAsFixed(2)} — you will lose money on this sale.';

  @override
  IconHint get icon => IconHint.warning;
}

class LowStockAlert extends AppAlert {
  final int newStock;
  final int threshold;
  const LowStockAlert({required this.newStock, required this.threshold});

  @override
  String get message =>
      'After this sale, stock will be $newStock — below the low-stock threshold of $threshold. Restock soon.';

  @override
  IconHint get icon => IconHint.lowStock;
}

class MarginDropAlert extends AppAlert {
  final double lastMarginPct;
  final double currentMarginPct;
  const MarginDropAlert({
    required this.lastMarginPct,
    required this.currentMarginPct,
  });

  @override
  String get message =>
      'Margin dropped from ${lastMarginPct.toStringAsFixed(0)}% to ${currentMarginPct.toStringAsFixed(0)}% vs. the last sale.';

  @override
  IconHint get icon => IconHint.margin;
}

enum IconHint { warning, lowStock, margin }

class AlertService {
  List<AppAlert> checkSale({
    required Product product,
    required int quantity,
    required double sellingPrice,
    Sale? lastSale,
  }) {
    final alerts = <AppAlert>[];

    if (sellingPrice < product.costPrice) {
      alerts.add(BelowCostAlert(
        costPrice: product.costPrice,
        sellingPrice: sellingPrice,
      ));
    }

    final newStock = product.stock - quantity;
    if (newStock >= 0 &&
        newStock <= product.lowStockThreshold &&
        product.alertEnabled) {
      alerts.add(LowStockAlert(
        newStock: newStock,
        threshold: product.lowStockThreshold,
      ));
    }

     if (lastSale != null && lastSale.sellingPrice > 0 && product.costPrice > 0) {
       final lastMargin =
           ((lastSale.sellingPrice - product.costPrice) / lastSale.sellingPrice) *
               100;
       final currentMargin =
           ((sellingPrice - product.costPrice) / sellingPrice) * 100;
       if (currentMargin < lastMargin - 10) {
         alerts.add(MarginDropAlert(
           lastMarginPct: lastMargin,
           currentMarginPct: currentMargin,
         ));
       }
     }

    return alerts;
  }

  List<Product> checkLowStock(List<Product> products) {
    return products
        .where((p) =>
            p.stock <= p.lowStockThreshold &&
            p.alertEnabled)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}

import 'package:flutter_test/flutter_test.dart';
import '../../lib/db/app_database.dart';
import '../../lib/services/alert_service.dart';

void main() {
  late AlertService service;

  setUp(() {
    service = AlertService();
  });

  group('BelowCostAlert', () {
    test('fires when selling < cost', () {
      final product = _product(costPrice: 10.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 8.0,
      );
      expect(alerts.whereType<BelowCostAlert>().length, 1);
    });

    test('not when == cost', () {
      final product = _product(costPrice: 10.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 10.0,
      );
      expect(alerts.whereType<BelowCostAlert>(), isEmpty);
    });

    test('not when > cost', () {
      final product = _product(costPrice: 10.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 12.0,
      );
      expect(alerts.whereType<BelowCostAlert>(), isEmpty);
    });

    test('carries correct values', () {
      final product = _product(costPrice: 10.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 8.0,
      );
      final alert = alerts.whereType<BelowCostAlert>().first;
      expect(alert.costPrice, 10.0);
      expect(alert.sellingPrice, 8.0);
    });
  });

  group('LowStockAlert', () {
    test('fires when stock < threshold', () {
      final product = _product(stock: 3, lowStockThreshold: 5);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 15.0,
      );
      expect(alerts.whereType<LowStockAlert>().length, 1);
    });

    test('fires when at threshold (newStock == threshold)', () {
      final product = _product(stock: 6, lowStockThreshold: 5);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 15.0,
      );
      expect(alerts.whereType<LowStockAlert>().length, 1);
    });

    test('not when > threshold', () {
      final product = _product(stock: 10, lowStockThreshold: 5);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 15.0,
      );
      expect(alerts.whereType<LowStockAlert>(), isEmpty);
    });

    test('fires at stock 0', () {
      final product = _product(stock: 0, lowStockThreshold: 5);
      final alerts = service.checkSale(
        product: product,
        quantity: 0,
        sellingPrice: 15.0,
      );
      expect(alerts.whereType<LowStockAlert>().length, 1);
    });

    test('carries correct values', () {
      final product = _product(stock: 5, lowStockThreshold: 10);
      final alerts = service.checkSale(
        product: product,
        quantity: 3,
        sellingPrice: 15.0,
      );
      final alert = alerts.whereType<LowStockAlert>().first;
      expect(alert.newStock, 2);
      expect(alert.threshold, 10);
    });
  });

   group('MarginDropAlert', () {
     test('fires when >10pp drop (actual threshold is 10pp)', () {
       final product = _product(costPrice: 10.0);
       final last = _sale(sellingPrice: 100.0); // margin 90%
       final alerts = service.checkSale(
         product: product,
         quantity: 1,
         sellingPrice: 40.0, // margin 60% — 30pp drop > 10
         lastSale: last,
       );
       expect(alerts.whereType<MarginDropAlert>().length, 1);
     });

      test('not at exactly 10pp drop', () {
        final product = _product(costPrice: 10.0);
        final last = _sale(sellingPrice: 100.0); // margin 90%
        // margin 80% (at 50 selling price) — exactly 10pp drop
        final alerts = service.checkSale(
          product: product,
          quantity: 1,
          sellingPrice: 50.0,
          lastSale: last,
        );
        expect(alerts.whereType<MarginDropAlert>(), isEmpty);
      });

    test('not without lastSale', () {
      final product = _product(costPrice: 10.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 8.0,
      );
      expect(alerts.whereType<MarginDropAlert>(), isEmpty);
    });

    test('not when costPrice is 0', () {
      final product = _product(costPrice: 0);
      final last = _sale(sellingPrice: 100.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 8.0,
        lastSale: last,
      );
      expect(alerts.whereType<MarginDropAlert>(), isEmpty);
    });

    test('carries correct values', () {
      final product = _product(costPrice: 10.0);
      final last = _sale(sellingPrice: 100.0);
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 20.0,
        lastSale: last,
      );
      final alert = alerts.whereType<MarginDropAlert>().first;
      expect(alert.lastMarginPct, greaterThan(alert.currentMarginPct));
    });
  });

  group('Multiple alerts', () {
    test('fires BelowCost AND LowStock together', () {
      final product = _product(
        costPrice: 10.0,
        stock: 2,
        lowStockThreshold: 5,
      );
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 5.0,
      );
      expect(alerts.whereType<BelowCostAlert>().length, 1);
      expect(alerts.whereType<LowStockAlert>().length, 1);
    });

    test('empty when all healthy', () {
      final product = _product(
        costPrice: 10.0,
        stock: 20,
        lowStockThreshold: 5,
      );
      final alerts = service.checkSale(
        product: product,
        quantity: 1,
        sellingPrice: 15.0,
      );
      expect(alerts, isEmpty);
    });
  });
}

Product _product({
  int id = 1,
  String name = 'Test',
  int stock = 10,
  double costPrice = 10.0,
  int lowStockThreshold = 5,
  String? note,
}) {
  return Product(
    id: id,
    name: name,
    stock: stock,
    costPrice: costPrice,
    lowStockThreshold: lowStockThreshold,
    alertEnabled: true,
    note: note,
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );
}

  Sale _sale({
    int id = 1,
    int productId = 1,
    int quantity = 1,
    double sellingPrice = 100.0,
    double total = 100.0,
    String platform = 'facebook',
    String paymentStatus = 'paid',
    String? customerName,
  }) {
    return Sale(
      id: id,
      productId: productId,
      quantity: quantity,
      sellingPrice: sellingPrice,
      total: total,
      platform: platform,
      paymentStatus: paymentStatus,
      customerName: customerName,
      isDiscounted: false,
      normalPrice: null,
      date: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      ownership: 'business',
    );
  }


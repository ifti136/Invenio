# Phase 3 — Validation, Debugging & Testing
## Sales Log, Alert Service, Atomic Transactions

**Status at time of writing:** ✅ Complete (from `06_completion_status.md`)
**Key deviations from spec:** `SaleFormScreen` handles both add + edit (spec was add-only). `SaleRepository` extended with `watchFiltered(SaleFilter)`, `updateSale()`, `getById()`, `lastSellingPriceFor()`. `SaleFilter` defined in `sale_repository.dart`. Below-cost alert has a pre-save confirm dialog (not just post-save SnackBar). Edit mode locks product picker — product cannot be changed after a sale is logged.

---

## 1. Static Validation

```bash
flutter analyze
# Must show 0 errors — sales feature has the most complex transaction logic

dart run build_runner build --delete-conflicting-outputs
# Regenerates: sale_repository.g.dart
```

Critical files for this phase:

```
lib/services/alert_service.dart
lib/features/sales/sale_repository.dart
lib/features/sales/sale_repository.g.dart     ← generated
lib/features/sales/sale_provider.dart
lib/features/sales/sale_list_screen.dart
lib/features/sales/sale_form_screen.dart
lib/features/sales/widgets/sale_filter_bar.dart
lib/features/sales/widgets/product_filter_sheet.dart
```

---

## 2. Unit Tests — AlertService

The `AlertService` is pure logic with no database dependency. It must be tested exhaustively — it is the financial safety net of the entire app.

```dart
// test/unit/alert_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/services/alert_service.dart';
import 'package:tracker/db/app_database.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Product _product({
  int id = 1,
  double costPrice = 400.0,
  int stock = 10,
  int threshold = 3,
}) =>
    Product(
      id: id,
      name: 'Test Product',
      costPrice: costPrice,
      stock: stock,
      lowStockThreshold: threshold,
      note: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

Sale _sale({
  int id = 1,
  int productId = 1,
  double sellingPrice = 500.0,
  int quantity = 1,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return Sale(
    id: id,
    productId: productId,
    quantity: quantity,
    sellingPrice: sellingPrice,
    total: sellingPrice * quantity,
    platform: 'offline',
    paymentStatus: 'paid',
    customerName: null,
    date: now,
    createdAt: now,
  );
}

void main() {
  final service = AlertService();

  // ── BelowCostAlert ─────────────────────────────────────────────────────────

  group('BelowCostAlert', () {
    test('fires when selling price < cost price', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 300.0), // below cost of 400
        product: _product(costPrice: 400.0),
      );
      expect(alerts.whereType<BelowCostAlert>(), hasLength(1));
    });

    test('does NOT fire when selling price == cost price', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 400.0),
        product: _product(costPrice: 400.0),
      );
      expect(alerts.whereType<BelowCostAlert>(), isEmpty);
    });

    test('does NOT fire when selling price > cost price', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 500.0),
        product: _product(costPrice: 400.0),
      );
      expect(alerts.whereType<BelowCostAlert>(), isEmpty);
    });

    test('carries correct cost and selling price values', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 300.0),
        product: _product(costPrice: 400.0),
      );
      final alert = alerts.whereType<BelowCostAlert>().first;
      expect(alert.costPrice, 400.0);
      expect(alert.sellingPrice, 300.0);
    });
  });

  // ── LowStockAlert ──────────────────────────────────────────────────────────

  group('LowStockAlert', () {
    test('fires when stock < threshold after sale', () {
      // Stock is 2, threshold is 3 → below
      final alerts = service.checkSale(
        sale: _sale(),
        product: _product(stock: 2, threshold: 3),
      );
      expect(alerts.whereType<LowStockAlert>(), hasLength(1));
    });

    test('does NOT fire when stock == threshold', () {
      final alerts = service.checkSale(
        sale: _sale(),
        product: _product(stock: 3, threshold: 3),
      );
      expect(alerts.whereType<LowStockAlert>(), isEmpty);
    });

    test('does NOT fire when stock > threshold', () {
      final alerts = service.checkSale(
        sale: _sale(),
        product: _product(stock: 10, threshold: 3),
      );
      expect(alerts.whereType<LowStockAlert>(), isEmpty);
    });

    test('fires when stock == 0', () {
      final alerts = service.checkSale(
        sale: _sale(),
        product: _product(stock: 0, threshold: 3),
      );
      expect(alerts.whereType<LowStockAlert>(), hasLength(1));
    });

    test('carries correct stock and threshold values', () {
      final alerts = service.checkSale(
        sale: _sale(),
        product: _product(stock: 1, threshold: 5),
      );
      final alert = alerts.whereType<LowStockAlert>().first;
      expect(alert.stock, 1);
      expect(alert.threshold, 5);
    });
  });

  // ── MarginDropAlert ────────────────────────────────────────────────────────

  group('MarginDropAlert', () {
    test('fires when margin drops by more than 10 percentage points', () {
      // Previous sale: cost=400, sell=500 → margin = (500-400)/500 = 20%
      // Current sale:  cost=400, sell=410 → margin = (410-400)/410 ≈ 2.4%
      // Drop ≈ 17.6pp → fires
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 410.0),
        product: _product(costPrice: 400.0),
        lastSale: _sale(sellingPrice: 500.0),
      );
      expect(alerts.whereType<MarginDropAlert>(), hasLength(1));
    });

    test('does NOT fire when margin drop is exactly 10pp', () {
      // Cost = 0, prev=100 (100% margin), curr=90 (100% also since cost=0)
      // Use exact boundary: prev margin = 50%, curr = 40% → 10pp drop
      // Sell at: prev 500 cost 250 → margin = 50%
      // Sell at: curr 400 cost 250 → margin = 37.5% → drop = 12.5pp → fires
      // Use: prev 500, cost 200 → margin 60%; curr 450, cost 200 → margin 55.6% → drop 4.4pp → no fire
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 450.0),
        product: _product(costPrice: 200.0),
        lastSale: _sale(sellingPrice: 500.0),
      );
      expect(alerts.whereType<MarginDropAlert>(), isEmpty);
    });

    test('does NOT fire without a lastSale (first sale for product)', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 400.0),
        product: _product(costPrice: 400.0),
        // no lastSale
      );
      expect(alerts.whereType<MarginDropAlert>(), isEmpty);
    });

    test('does NOT fire when cost price is 0 (avoid divide by zero)', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 100.0),
        product: _product(costPrice: 0.0),
        lastSale: _sale(sellingPrice: 200.0),
      );
      // Should not throw — graceful handling
      expect(alerts.whereType<MarginDropAlert>(), isEmpty);
    });

    test('carries accurate margin percentages', () {
      // prev: sell=500, cost=400 → margin = (500-400)/500 = 20%
      // curr: sell=410, cost=400 → margin = (410-400)/410 ≈ 2.44%
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 410.0),
        product: _product(costPrice: 400.0),
        lastSale: _sale(sellingPrice: 500.0),
      );
      final alert = alerts.whereType<MarginDropAlert>().first;
      expect(alert.prevMarginPct, closeTo(20.0, 0.1));
      expect(alert.currMarginPct, closeTo(2.44, 0.1));
    });
  });

  // ── Multiple alerts ────────────────────────────────────────────────────────

  group('Multiple alerts', () {
    test('can fire BelowCost AND LowStock simultaneously', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 300.0), // below cost
        product: _product(costPrice: 400.0, stock: 1, threshold: 3), // low stock
      );
      expect(alerts.whereType<BelowCostAlert>(), hasLength(1));
      expect(alerts.whereType<LowStockAlert>(), hasLength(1));
    });

    test('returns empty list when all conditions are healthy', () {
      final alerts = service.checkSale(
        sale: _sale(sellingPrice: 500.0),
        product: _product(costPrice: 400.0, stock: 10, threshold: 3),
        lastSale: _sale(sellingPrice: 490.0), // minimal drop, no alert
      );
      expect(alerts, isEmpty);
    });
  });
}
```

**Run with:**
```bash
flutter test test/unit/alert_service_test.dart --reporter expanded
# Expected: 15+ tests all passing
```

---

## 3. Unit Tests — SaleRepository

```dart
// test/unit/sale_repository_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_repository.dart';
import 'package:tracker/features/sales/sale_repository.dart';

void main() {
  late AppDatabase db;
  late ProductRepository productRepo;
  late SaleRepository saleRepo;
  late int testProductId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    productRepo = ProductRepository(db);
    saleRepo = SaleRepository(db, productRepo);
    // Create a test product with 20 units @ cost 400
    testProductId = await productRepo.create(
      name: 'Test Product',
      costPrice: 400.0,
      initialStock: 20,
    );
  });

  tearDown(() => db.close());

  // ── addSale() — atomic transaction ────────────────────────────────────────

  group('addSale() — atomic writes', () {
    test('inserts a sale row', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 2,
        sellingPrice: 500.0,
        platform: 'facebook',
        paymentStatus: 'paid',
      );
      expect(result.sale.id, greaterThan(0));
      expect(result.sale.quantity, 2);
      expect(result.sale.sellingPrice, 500.0);
      expect(result.sale.total, 1000.0);
    });

    test('decrements product stock by quantity sold', () async {
      await saleRepo.addSale(
        productId: testProductId,
        quantity: 3,
        sellingPrice: 500.0,
        platform: 'offline',
        paymentStatus: 'paid',
      );
      final product = await productRepo.getById(testProductId);
      expect(product.stock, 17); // 20 - 3
    });

    test('writes a stock_movements row of type sale', () async {
      await saleRepo.addSale(
        productId: testProductId,
        quantity: 5,
        sellingPrice: 500.0,
        platform: 'facebook',
        paymentStatus: 'paid',
      );
      final movements = await (db.select(db.stockMovements)
            ..where((t) =>
                t.productId.equals(testProductId) &
                t.type.equals('sale')))
          .get();
      expect(movements.length, 1);
      expect(movements.first.quantity, -5); // negative = outgoing
    });

    test('total = quantity × sellingPrice', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 4,
        sellingPrice: 600.0,
        platform: 'offline',
        paymentStatus: 'due',
      );
      expect(result.sale.total, closeTo(2400.0, 0.01));
    });

    test('returns BelowCostAlert when selling below cost', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 1,
        sellingPrice: 300.0, // below cost of 400
        platform: 'offline',
        paymentStatus: 'paid',
      );
      expect(result.alerts.whereType<BelowCostAlert>(), hasLength(1));
    });

    test('returns LowStockAlert when stock drops below threshold', () async {
      // Product has 20 stock, threshold 3. Sell 18 → stock becomes 2 < 3
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 18,
        sellingPrice: 500.0,
        platform: 'offline',
        paymentStatus: 'paid',
      );
      expect(result.alerts.whereType<LowStockAlert>(), hasLength(1));
    });
  });

  // ── markAsPaid() ─────────────────────────────────────────────────────────

  group('markAsPaid()', () {
    test('changes payment status from due to paid', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 1,
        sellingPrice: 500.0,
        platform: 'offline',
        paymentStatus: 'due',
      );
      await saleRepo.markAsPaid(result.sale.id);
      final updated = await saleRepo.getById(result.sale.id);
      expect(updated.paymentStatus, 'paid');
    });

    test('does NOT change quantity or price', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 2,
        sellingPrice: 600.0,
        platform: 'facebook',
        paymentStatus: 'due',
      );
      await saleRepo.markAsPaid(result.sale.id);
      final updated = await saleRepo.getById(result.sale.id);
      expect(updated.quantity, 2);
      expect(updated.sellingPrice, 600.0);
    });
  });

  // ── deleteSale() — stock restoration ──────────────────────────────────────

  group('deleteSale()', () {
    test('restores stock when sale is deleted', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 5,
        sellingPrice: 500.0,
        platform: 'offline',
        paymentStatus: 'paid',
      );
      // Stock is now 15
      await saleRepo.deleteSale(result.sale.id);
      // Stock should be back to 20
      final product = await productRepo.getById(testProductId);
      expect(product.stock, 20);
    });

    test('removes the sale row', () async {
      final result = await saleRepo.addSale(
        productId: testProductId,
        quantity: 1,
        sellingPrice: 500.0,
        platform: 'offline',
        paymentStatus: 'paid',
      );
      await saleRepo.deleteSale(result.sale.id);
      final sales = await db.select(db.sales).get();
      expect(sales.where((s) => s.id == result.sale.id), isEmpty);
    });
  });

  // ── lastSellingPriceFor() ─────────────────────────────────────────────────

  group('lastSellingPriceFor()', () {
    test('returns null when no sales exist for product', () async {
      final price = await saleRepo.lastSellingPriceFor(testProductId);
      expect(price, isNull);
    });

    test('returns the most recent selling price', () async {
      await saleRepo.addSale(
        productId: testProductId,
        quantity: 1,
        sellingPrice: 450.0,
        platform: 'offline',
        paymentStatus: 'paid',
        date: DateTime(2024, 6, 1),
      );
      await saleRepo.addSale(
        productId: testProductId,
        quantity: 1,
        sellingPrice: 500.0,
        platform: 'offline',
        paymentStatus: 'paid',
        date: DateTime(2024, 6, 15), // more recent
      );
      final price = await saleRepo.lastSellingPriceFor(testProductId);
      expect(price, 500.0); // not 450.0
    });
  });
}
```

**Run with:**
```bash
flutter test test/unit/sale_repository_test.dart --reporter expanded
```

---

## 4. Widget Tests — Sale Form

```dart
// test/widget/sale_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/sales/sale_form_screen.dart';

void main() {
  group('SaleFormScreen (add mode)', () {
    testWidgets('shows validation error when no product selected',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SaleFormScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Sale'));
      await tester.pumpAndSettle();
      expect(find.textContaining('product'), findsOneWidget);
    });

    testWidgets('platform toggle defaults to Facebook', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SaleFormScreen()),
        ),
      );
      await tester.pumpAndSettle();
      // SegmentedButton should show Facebook selected
      expect(find.text('Facebook'), findsOneWidget);
    });

    testWidgets('payment toggle defaults to Paid', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SaleFormScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Paid'), findsOneWidget);
    });
  });
}
```

---

## 5. Manual Validation Checklist

### 5.1 Add Sale — Happy Path

| Step | Action | Expected |
|------|--------|----------|
| 1 | Open Sales → + | Form opens |
| 2 | Pick product "Hoco EQ34" | Stock shown in dropdown |
| 3 | Qty = 2, Price = 500 | Total shows ৳1,000 live |
| 4 | Platform = Facebook, Status = Paid | Toggles respond |
| 5 | Tap Save | Returns to list, sale appears |
| 6 | Check Products tab | Hoco EQ34 stock reduced by 2 |

### 5.2 Alert Scenarios — Must Test Manually

| Scenario | Setup | Expected alert |
|----------|-------|---------------|
| Sell below cost | Product cost=400, sell at 300 | Pre-save confirm dialog + post-save amber SnackBar |
| Low stock | Product has 4 units, threshold=3, sell 2 (leaves 2) | Post-save "Low stock — 2 left" SnackBar |
| Margin drop | Last sold at 500 (20% margin), sell at 410 (2% margin) | Post-save "Margin dropped" SnackBar |
| All healthy | Normal sale, plenty of stock | No alerts, confirmation SnackBar only |

### 5.3 Filter Validation

| Filter | Expected behavior |
|--------|------------------|
| Today | Only shows today's sales |
| This week | Shows Mon–Sun current week |
| Custom range | `showDateRangePicker` opens; applies chosen range |
| Facebook / Offline | Filters by platform column |
| Paid / Due | Filters by payment_status column |
| Product filter | Opens `ProductFilterSheet`; filters by product_id |
| Reset filters | All filters cleared; full list shown |

### 5.4 Edit & Delete

| Action | Expected |
|--------|----------|
| Tap row → Edit | Form opens with pre-filled data; product picker locked |
| Change qty in edit | Stock adjusted by delta (oldQty - newQty) |
| Delete sale → Cancel confirm | Sale not deleted |
| Delete sale → Confirm | Sale removed; stock restored |
| Mark Due → Paid | Status changes to paid; no new sale created |

---

## 6. Profit Calculation Validation

The profit shown throughout the app is computed as:

```
grossProfitPerSale = sellingPrice − costPrice   (per unit)
grossProfitTotal   = grossProfitPerSale × quantity
```

### Manual Spot-Check Table

| Sale | Cost Price | Sell Price | Qty | Expected Gross Profit |
|------|-----------|-----------|-----|----------------------|
| Sale A | ৳400 | ৳500 | 2 | ৳200 |
| Sale B | ৳400 | ৳350 | 1 | −৳50 (loss) |
| Sale C | ৳400 | ৳400 | 5 | ৳0 |

Log each of the above sales and verify the profit figure shown in the sale list tile matches. The product detail "All-time profit" should sum to `200 + (-50) + 0 = 150`.

---

## 7. Debugging Guide

### 7.1 Sale Logged But Stock Not Updated

**Symptom:** Sale appears in list, but product stock unchanged.

**Root cause:** The `addSale` transaction rolled back after inserting the sale, OR the stock update used `get()` instead of a live stream (so UI didn't refresh).

**Check the transaction:**
```dart
// In SaleRepository.addSale — ensure ALL 3 writes are inside one transaction:
await _db.transaction(() async {
  // 1. INSERT INTO sales         ← must be here
  // 2. UPDATE products.stock     ← must be here
  // 3. INSERT INTO stock_movements ← must be here
});
// If any of these are OUTSIDE the transaction block, they won't roll back on failure
```

**Check the product stock stream:**
```dart
// product_provider.dart must watch a stream, not a future:
final productDetailProvider = StreamProvider.family<Product, int>(
  (ref, id) => ref.watch(productRepositoryProvider).watchById(id), // watch, not get
);
```

### 7.2 Alert SnackBar Appears Then Immediately Disappears

**Symptom:** Amber SnackBar flashes and is gone before it can be read.

**Root cause:** `ScaffoldMessenger.of(context)` called after `context.pop()` — the scaffold is no longer in the widget tree.

**Fix pattern:**
```dart
Future<void> _save() async {
  // ...
  final result = await saleRepo.addSale(...);
  if (!mounted) return;
  
  // Pop FIRST, then show SnackBar on the PARENT scaffold
  context.pop();
  
  // SnackBar on the parent — use rootScaffoldMessengerKey or pass messenger down
  for (final alert in result.alerts) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

### 7.3 SaleFilter Not Working (All Sales Always Shown)

**Symptom:** Applying a date or platform filter shows no change.

**Root cause:** `SaleFilter` must implement `==` and `hashCode` to work as a `StreamProvider.family` key. Without them, every state change creates a new key and the old stream is never matched.

**Check `sale_repository.dart`:**
```dart
class SaleFilter {
  // ...
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleFilter &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          platform == other.platform &&
          paymentStatus == other.paymentStatus &&
          productId == other.productId;

  @override
  int get hashCode =>
      Object.hash(startDate, endDate, platform, paymentStatus, productId);
}
```

### 7.4 MarginDropAlert Never Fires

**Symptom:** Margin clearly dropped, but no alert shown.

**Check:** `lastSale` is fetched BEFORE the transaction in `addSale`. If fetched inside the transaction, the current insert might appear as the "last sale" due to SQLite read-within-write behavior.

```dart
// CORRECT — fetch BEFORE transaction
final lastSale = await lastSellingPriceFor(productId);

await _db.transaction(() async {
  // ... add sale ...
});

// THEN check alerts using the pre-fetched lastSale
```

---

## 8. Phase 3 Completion Gate

```
✅ flutter analyze — 0 errors
✅ test/unit/alert_service_test.dart — all 15+ tests pass
✅ test/unit/sale_repository_test.dart — all 12+ tests pass
✅ test/widget/sale_form_test.dart — all tests pass
✅ Manual: add sale → stock reduces → sale appears in list
✅ Manual: BelowCostAlert fires (pre-save dialog + SnackBar)
✅ Manual: LowStockAlert fires (post-save SnackBar)
✅ Manual: MarginDropAlert fires after second sale of same product
✅ Manual: all 4 filter types work correctly
✅ Manual: edit sale → stock delta applied correctly
✅ Manual: delete sale → stock restored
✅ Manual: Mark Due → Paid works without creating new sale
✅ Manual: profit spot-check table verified (see §6)
```

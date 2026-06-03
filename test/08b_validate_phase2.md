# Phase 2 — Validation, Debugging & Testing
## Products: Repository, Screens, Widgets

**Status at time of writing:** ✅ Complete (from `06_completion_status.md`)
**Key deviation from spec:** `ProductRepository` extends spec with `watchSales()`, `watchStockMovements()`, `adjustStock()`. `ProductProvider` uses non-codegen `StreamProvider`/`FutureProvider.family` instead of `@riverpod` codegen. FR-P03 cost-change prompt collapsed to single confirm dialog.

---

## 1. Static Validation

```bash
flutter analyze
# Must show 0 errors before any product testing begins

# Re-run build_runner if product_repository.dart was changed:
dart run build_runner build --delete-conflicting-outputs
```

Specific files `flutter analyze` must pass for this phase:

```
lib/features/products/product_repository.dart
lib/features/products/product_repository.g.dart    ← generated
lib/features/products/product_provider.dart
lib/features/products/product_list_screen.dart
lib/features/products/product_detail_screen.dart
lib/features/products/product_form_screen.dart
lib/features/products/widgets/product_tile.dart
lib/features/products/widgets/stock_badge.dart
lib/features/products/widgets/restock_sheet.dart
lib/features/products/widgets/sale_list_item.dart
lib/features/products/widgets/stock_movement_item.dart
```

---

## 2. Unit Tests — ProductRepository

```dart
// test/unit/product_repository_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_repository.dart';

void main() {
  late AppDatabase db;
  late ProductRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProductRepository(db);
  });

  tearDown(() => db.close());

  // ── create() ───────────────────────────────────────────────────────────────

  group('create()', () {
    test('returns a positive id', () async {
      final id = await repo.create(
        name: 'Hoco EQ34',
        costPrice: 350.0,
        initialStock: 10,
      );
      expect(id, greaterThan(0));
    });

    test('inserts product with correct fields', () async {
      final id = await repo.create(
        name: 'JBL Clip',
        costPrice: 800.0,
        initialStock: 5,
        note: 'Black',
        threshold: 2,
      );
      final product =
          await (db.select(db.products)..where((t) => t.id.equals(id)))
              .getSingle();
      expect(product.name, 'JBL Clip');
      expect(product.costPrice, 800.0);
      expect(product.stock, 5);
      expect(product.note, 'Black');
      expect(product.lowStockThreshold, 2);
    });

    test('writes an initial stock_movements row (type: initial)', () async {
      final id = await repo.create(
        name: 'Test',
        costPrice: 100.0,
        initialStock: 8,
      );
      final movements = await (db.select(db.stockMovements)
            ..where((t) => t.productId.equals(id)))
          .get();
      expect(movements.length, 1);
      expect(movements.first.type, 'initial');
      expect(movements.first.quantity, 8);
    });

    test('initial stock of 0 writes a movement with quantity 0', () async {
      final id = await repo.create(
        name: 'No Stock',
        costPrice: 50.0,
        initialStock: 0,
      );
      final movements = await (db.select(db.stockMovements)
            ..where((t) => t.productId.equals(id)))
          .get();
      expect(movements.first.quantity, 0);
    });
  });

  // ── restock() ──────────────────────────────────────────────────────────────

  group('restock()', () {
    test('increases product stock correctly', () async {
      final id = await repo.create(
          name: 'P1', costPrice: 100.0, initialStock: 5);
      await repo.restock(id, 10);
      final product = await repo.getById(id);
      expect(product.stock, 15);
    });

    test('writes a restock movement row', () async {
      final id = await repo.create(
          name: 'P2', costPrice: 100.0, initialStock: 0);
      await repo.restock(id, 20, note: 'Supplier delivery');
      final movements = await (db.select(db.stockMovements)
            ..where((t) =>
                t.productId.equals(id) & t.type.equals('restock')))
          .get();
      expect(movements.length, 1);
      expect(movements.first.quantity, 20);
      expect(movements.first.note, 'Supplier delivery');
    });
  });

  // ── adjustStock() ──────────────────────────────────────────────────────────

  group('adjustStock()', () {
    test('positive delta increases stock', () async {
      final id = await repo.create(
          name: 'P3', costPrice: 100.0, initialStock: 5);
      await repo.adjustStock(id, 3, 'Found extras');
      final product = await repo.getById(id);
      expect(product.stock, 8);
    });

    test('negative delta decreases stock', () async {
      final id = await repo.create(
          name: 'P4', costPrice: 100.0, initialStock: 10);
      await repo.adjustStock(id, -4, 'Lost/damaged');
      final product = await repo.getById(id);
      expect(product.stock, 6);
    });

    test('writes adjustment movement with correct type', () async {
      final id = await repo.create(
          name: 'P5', costPrice: 100.0, initialStock: 10);
      await repo.adjustStock(id, -2, 'Correction');
      final movements = await (db.select(db.stockMovements)
            ..where((t) =>
                t.productId.equals(id) & t.type.equals('adjustment')))
          .get();
      expect(movements.length, 1);
      expect(movements.first.quantity, -2);
    });
  });

  // ── update() ───────────────────────────────────────────────────────────────

  group('update()', () {
    test('changes name only', () async {
      final id = await repo.create(
          name: 'Old Name', costPrice: 100.0, initialStock: 1);
      await repo.update(id, name: 'New Name');
      final product = await repo.getById(id);
      expect(product.name, 'New Name');
      expect(product.costPrice, 100.0); // unchanged
    });

    test('changes cost price only', () async {
      final id = await repo.create(
          name: 'Product', costPrice: 100.0, initialStock: 1);
      await repo.update(id, costPrice: 150.0);
      final product = await repo.getById(id);
      expect(product.costPrice, 150.0);
      expect(product.name, 'Product'); // unchanged
    });

    test('null fields leave existing values intact', () async {
      final id = await repo.create(
          name: 'X', costPrice: 99.0, initialStock: 5, note: 'Red');
      await repo.update(id); // all nulls
      final product = await repo.getById(id);
      expect(product.name, 'X');
      expect(product.costPrice, 99.0);
      expect(product.note, 'Red');
    });
  });

  // ── watchAll() ─────────────────────────────────────────────────────────────

  group('watchAll()', () {
    test('emits empty list when no products exist', () async {
      final products = await repo.watchAll().first;
      expect(products, isEmpty);
    });

    test('emits updated list after insert', () async {
      await repo.create(name: 'A', costPrice: 100.0, initialStock: 1);
      await repo.create(name: 'B', costPrice: 200.0, initialStock: 2);
      final products = await repo.watchAll().first;
      expect(products.length, 2);
    });
  });

  // ── Profit calculation (derived from product stats) ────────────────────────

  group('per-product profit stats', () {
    test('profit = sellingPrice - costPrice per unit', () {
      // This is a pure calculation — no DB needed
      const costPrice = 350.0;
      const sellingPrice = 500.0;
      const quantity = 3;
      final profit = (sellingPrice - costPrice) * quantity;
      expect(profit, closeTo(450.0, 0.01));
    });

    test('negative profit when sold below cost', () {
      const costPrice = 500.0;
      const sellingPrice = 400.0;
      final profit = sellingPrice - costPrice;
      expect(profit, isNegative);
    });
  });
}
```

**Run with:**
```bash
flutter test test/unit/product_repository_test.dart --reporter expanded
```

---

## 3. Widget Tests — Product Screens

```dart
// test/widget/product_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/products/product_form_screen.dart';

void main() {
  group('ProductFormScreen (add mode)', () {
    Widget buildSubject() => const ProviderScope(
          child: MaterialApp(home: ProductFormScreen()),
        );

    testWidgets('renders name, cost price, stock, threshold, note fields',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
      // GlassTextField uses label — use find.text
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('shows error when name is empty on save', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Tap Save without filling anything
      await tester.tap(find.text('Save Product'));
      await tester.pumpAndSettle();
      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('shows error when cost price is zero', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      // Fill name but leave cost at 0
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Widget');
      await tester.tap(find.text('Save Product'));
      await tester.pumpAndSettle();
      expect(find.textContaining('greater than 0'), findsOneWidget);
    });
  });

  group('StockBadge', () {
    testWidgets('shows green badge for stock > threshold', (tester) async {
      // TODO: render StockBadge(stock: 10, threshold: 3) and verify color
    });

    testWidgets('shows amber badge for stock == threshold', (tester) async {
      // TODO: render StockBadge(stock: 3, threshold: 3) and verify color
    });

    testWidgets('shows red badge for stock < threshold', (tester) async {
      // TODO: render StockBadge(stock: 1, threshold: 3) and verify color
    });
  });
}
```

---

## 4. Manual Validation Checklist

### 4.1 Product List Screen

| Action | Expected result |
|--------|----------------|
| Open Products tab (empty state) | "No products yet. Tap + to add one." visible |
| Tap FAB (+) | Product form opens |
| Add product: name="Hoco EQ34", cost=350, stock=10 | Product appears in list |
| Stock badge colour | Green (stock 10 > threshold 3) |
| Search "Hoco" | Only matching product shown |
| Search "zzz" | No-match empty state shown |

### 4.2 Product Form Screen

| Field | Validation |
|-------|-----------|
| Name empty → Save | Error shown, no save |
| Cost price = 0 → Save | Error: must be > 0 |
| Stock = 0 → Save | Valid (0 stock allowed) |
| Threshold = 0 → Save | Valid (disables low-stock alert effectively) |
| Edit: change cost price | Confirm dialog appears before save |

### 4.3 Product Detail Screen

| Element | Expected |
|---------|----------|
| Header: stock count | Matches actual stock |
| Header: cost price | Matches product record |
| Header: all-time profit | Sum of (selling − cost) × qty for all sales |
| Restock button | Opens restock sheet |
| Sales tab | Lists all sales for this product |
| Stock log tab | Lists all movements (initial, restock, sale, adjustment) |
| Price History tab | Line chart plotted from all past selling prices |

### 4.4 Restock / Adjustment Sheet

| Scenario | Expected |
|----------|----------|
| Restock: qty=5 | Stock increases by 5; movement row (type: restock) written |
| Adjustment: -3 | Stock decreases by 3; movement row (type: adjustment, qty: -3) |
| Save with no quantity | Error — quantity required |
| Projected stock line | Shows current + delta before saving |

---

## 5. Debugging Guide

### 5.1 Stock Count Mismatch

**Symptom:** Product shows wrong stock count on detail screen.

**Diagnosis steps:**
1. Open the Stock Log tab on the product detail screen.
2. Manually sum: `initial + restock - sales - |adjustments|`
3. Compare to displayed stock.

**Query to verify directly (add to a debug button temporarily):**
```dart
// Manual stock reconciliation query
final movements = await (db.select(db.stockMovements)
      ..where((t) => t.productId.equals(productId))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
    .get();
final reconstructed = movements.fold(0, (sum, m) => sum + m.quantity);
debugPrint('Stored stock: ${product.stock}');
debugPrint('Reconstructed from movements: $reconstructed');
// These must match
```

**Fix:** If mismatch exists, a `restock` or `adjustStock` transaction failed mid-write. Use `db.transaction()` wrapping for all multi-step mutations.

### 5.2 Product Provider Not Updating After Insert

**Symptom:** New product added but list doesn't refresh.

**Root cause:** `productListProvider` uses `StreamProvider` which must be backed by `watchAll()` (a `watch()` query), not `get()`.

**Check:** In `product_provider.dart`:
```dart
// CORRECT — uses watch() → stream
final productListProvider = StreamProvider.autoDispose<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).watchAll(),
);

// WRONG — uses get() → Future, no reactive update
// Don't do this:
final productListProvider = FutureProvider((ref) =>
    ref.watch(productRepositoryProvider).getAll());
```

### 5.3 Build Runner Errors on product_repository.g.dart

**Symptom:** `Could not find generated class _$ProductRepositoryProvider`

**Fix sequence:**
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

If error persists, check that `part 'product_repository.g.dart';` is at the top of `product_repository.dart` and the `@Riverpod(keepAlive: true)` annotation is on the function, not the class.

### 5.4 `GlassDialogAction` Returns Null

**Symptom:** Confirm dialog for cost-price change dismisses without returning a value.

**Root cause:** `showGlassDialog<bool>` must have `GlassDialogAction<bool>` — the generic type must match.

```dart
// CORRECT
final confirmed = await showGlassDialog<bool>(
  context: context,
  title: 'Update cost price?',
  content: 'This affects profit calculations.',
  actions: [
    GlassDialogAction<bool>(label: 'Cancel', value: false),
    GlassDialogAction<bool>(label: 'Confirm', value: true),
  ],
);
// confirmed is bool? — null if user taps outside dialog
```

---

## 6. Phase 2 Completion Gate

```
✅ flutter analyze — 0 errors
✅ test/unit/product_repository_test.dart — all tests pass (≥14 tests)
✅ test/widget/product_form_test.dart — all tests pass
✅ Manual: add product, appears in list with correct stock badge
✅ Manual: search filter works
✅ Manual: edit product — cost change confirm dialog shown
✅ Manual: restock sheet — stock increases, movement logged
✅ Manual: adjustment sheet — stock changes, movement logged
✅ Manual: product detail shows correct stats (stock, cost, profit)
✅ Manual: Sales tab and Stock Log tab populate after sales are logged
✅ Manual: Price History chart plots after at least 1 sale
```

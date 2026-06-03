# Phase 5 — Validation, Debugging & Testing
## Reports, Dashboard, Export Service

**Status at time of writing:** ⬜ Not started
**Agent:** Agent B owns this phase entirely
**Cross-agent dependency:** Requires `expenseRepositoryProvider` from Agent A (Phase 4) — specifically `totalForPeriod(start, end)`. Do not start `ReportRepository` until Agent A passes `expense_contract_test.dart`.

---

## 1. Pre-Implementation Checklist

Before writing any Phase 5 code:

```bash
# 1. Agent A's contract test must pass
flutter test test/unit/expense_contract_test.dart --reporter expanded
# All 5 tests must be green

# 2. Overall analysis clean
flutter analyze   # 0 errors

# 3. Required existing files
ls lib/features/expenses/expense_repository.dart   # Agent A done
ls lib/features/dashboard/dashboard_screen.dart    # placeholder — you'll replace
ls lib/features/reports/reports_screen.dart        # placeholder — you'll replace
ls lib/models/                                     # you'll create all 4 model files
```

---

## 2. Static Validation

```bash
dart run build_runner build --delete-conflicting-outputs
# Phase 5 code that uses @riverpod needs a regeneration pass

flutter analyze
# Must show 0 errors
```

Files owned by Agent B that must pass analysis:

```
lib/models/dashboard_summary.dart
lib/models/daily_report.dart
lib/models/monthly_report.dart
lib/models/product_report.dart
lib/features/dashboard/dashboard_screen.dart
lib/features/dashboard/dashboard_provider.dart
lib/features/dashboard/widgets/summary_row.dart
lib/features/dashboard/widgets/platform_cards.dart
lib/features/dashboard/widgets/low_stock_banner.dart
lib/features/reports/reports_screen.dart
lib/features/reports/daily_report_screen.dart
lib/features/reports/monthly_report_screen.dart
lib/features/reports/product_report_screen.dart
lib/features/reports/report_provider.dart
lib/features/reports/widgets/chart_table_toggle.dart
lib/features/reports/widgets/bar_chart_widget.dart
lib/features/reports/widgets/line_chart_widget.dart
lib/features/reports/widgets/report_table.dart
lib/services/export_service.dart
```

---

## 3. Unit Tests — Profit Calculation (Core Logic)

Profit calculations are pure functions. Test them in isolation before wiring to the DB.

```dart
// test/unit/profit_calculation_test.dart

import 'package:flutter_test/flutter_test.dart';

// These mirror the logic in ReportRepository —
// test the math before wiring to the database.

double grossProfitPerSale(
    {required double sellingPrice,
    required double costPrice,
    required int quantity}) =>
    (sellingPrice - costPrice) * quantity;

double grossProfitPeriod(List<Map<String, dynamic>> sales) =>
    sales.fold(0.0, (sum, s) =>
        sum + grossProfitPerSale(
          sellingPrice: s['sellingPrice'] as double,
          costPrice: s['costPrice'] as double,
          quantity: s['quantity'] as int,
        ));

double netProfit(double grossProfit, double totalExpenses) =>
    grossProfit - totalExpenses;

double marginPercent(double sellingPrice, double costPrice) =>
    sellingPrice > 0 ? (sellingPrice - costPrice) / sellingPrice * 100 : 0;

void main() {
  // ── Gross profit per sale ─────────────────────────────────────────────────

  group('grossProfitPerSale()', () {
    test('positive profit when sold above cost', () {
      final profit = grossProfitPerSale(
          sellingPrice: 500, costPrice: 400, quantity: 1);
      expect(profit, closeTo(100.0, 0.01));
    });

    test('profit multiplied by quantity', () {
      final profit = grossProfitPerSale(
          sellingPrice: 500, costPrice: 400, quantity: 3);
      expect(profit, closeTo(300.0, 0.01));
    });

    test('negative profit when sold below cost', () {
      final profit = grossProfitPerSale(
          sellingPrice: 300, costPrice: 400, quantity: 2);
      expect(profit, closeTo(-200.0, 0.01));
    });

    test('zero profit when sold at cost price', () {
      final profit = grossProfitPerSale(
          sellingPrice: 400, costPrice: 400, quantity: 5);
      expect(profit, closeTo(0.0, 0.01));
    });
  });

  // ── Gross profit period ───────────────────────────────────────────────────

  group('grossProfitPeriod()', () {
    test('sums correctly across multiple sales', () {
      final sales = [
        {'sellingPrice': 500.0, 'costPrice': 400.0, 'quantity': 2},  // +200
        {'sellingPrice': 300.0, 'costPrice': 400.0, 'quantity': 1},  // -100
        {'sellingPrice': 600.0, 'costPrice': 400.0, 'quantity': 1},  // +200
      ];
      final gross = grossProfitPeriod(sales);
      expect(gross, closeTo(300.0, 0.01));
    });

    test('returns 0 for empty sales list', () {
      expect(grossProfitPeriod([]), 0.0);
    });
  });

  // ── Net profit ────────────────────────────────────────────────────────────

  group('netProfit()', () {
    test('gross minus expenses', () {
      expect(netProfit(1000.0, 300.0), closeTo(700.0, 0.01));
    });

    test('negative net profit when expenses exceed gross', () {
      expect(netProfit(200.0, 500.0), closeTo(-300.0, 0.01));
    });

    test('zero expenses returns gross as net', () {
      expect(netProfit(800.0, 0.0), closeTo(800.0, 0.01));
    });
  });

  // ── Platform breakdown ────────────────────────────────────────────────────

  group('platform breakdown', () {
    test('correctly splits facebook and offline profit', () {
      final allSales = [
        {'sellingPrice': 500.0, 'costPrice': 400.0, 'quantity': 2,
         'platform': 'facebook'},  // +200
        {'sellingPrice': 600.0, 'costPrice': 400.0, 'quantity': 1,
         'platform': 'offline'},   // +200
        {'sellingPrice': 500.0, 'costPrice': 400.0, 'quantity': 1,
         'platform': 'facebook'},  // +100
      ];
      final fb = grossProfitPeriod(
          allSales.where((s) => s['platform'] == 'facebook').toList());
      final offline = grossProfitPeriod(
          allSales.where((s) => s['platform'] == 'offline').toList());
      expect(fb, closeTo(300.0, 0.01));
      expect(offline, closeTo(200.0, 0.01));
    });
  });

  // ── Margin % ──────────────────────────────────────────────────────────────

  group('marginPercent()', () {
    test('50% margin when cost is half of selling price', () {
      expect(marginPercent(500, 250), closeTo(50.0, 0.1));
    });

    test('0% margin when selling at cost', () {
      expect(marginPercent(400, 400), closeTo(0.0, 0.1));
    });

    test('returns 0 when selling price is 0 (avoid division by zero)', () {
      expect(marginPercent(0, 0), 0.0);
    });

    test('negative margin when selling below cost', () {
      expect(marginPercent(300, 400), isNegative);
    });
  });
}
```

**Run with:**
```bash
flutter test test/unit/profit_calculation_test.dart --reporter expanded
```

---

## 4. Unit Tests — DashboardProvider Logic

```dart
// test/unit/dashboard_provider_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_repository.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/expenses/expense_repository.dart';
import 'package:tracker/models/expense_filter.dart';

// Direct DB test (no Riverpod) — tests the underlying query logic
void main() {
  late AppDatabase db;
  late ProductRepository productRepo;
  late SaleRepository saleRepo;
  late ExpenseRepository expenseRepo;
  late int productId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    productRepo = ProductRepository(db);
    saleRepo = SaleRepository(db, productRepo);
    expenseRepo = ExpenseRepository(db);
    productId = await productRepo.create(
        name: 'Widget', costPrice: 400.0, initialStock: 50);
  });

  tearDown(() => db.close());

  group('Dashboard — today\'s figures', () {
    test('sales today count is correct', () async {
      await saleRepo.addSale(
        productId: productId, quantity: 1, sellingPrice: 500,
        platform: 'facebook', paymentStatus: 'paid',
        date: DateTime.now(), // today
      );
      await saleRepo.addSale(
        productId: productId, quantity: 2, sellingPrice: 500,
        platform: 'offline', paymentStatus: 'paid',
        date: DateTime(2024, 1, 1), // NOT today
      );

      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day)
          .millisecondsSinceEpoch;
      final end = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .millisecondsSinceEpoch;
      final todaySales = await (db.select(db.sales)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end)))
          .get();
      expect(todaySales.length, 1);
    });

    test('gross profit today is sum of (sell - cost) * qty', () async {
      await saleRepo.addSale(
        productId: productId, quantity: 2, sellingPrice: 500,
        platform: 'facebook', paymentStatus: 'paid', date: DateTime.now(),
      );
      // Expected: (500 - 400) * 2 = 200
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day)
          .millisecondsSinceEpoch;
      final end = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .millisecondsSinceEpoch;
      final todaySales = await (db.select(db.sales)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end)))
          .get();
      final product = await productRepo.getById(productId);
      double gross = 0;
      for (final s in todaySales) {
        gross += (s.sellingPrice - product.costPrice) * s.quantity;
      }
      expect(gross, closeTo(200.0, 0.01));
    });

    test('total due = sum of all unpaid sales (not just today)', () async {
      await saleRepo.addSale(
        productId: productId, quantity: 1, sellingPrice: 600,
        platform: 'offline', paymentStatus: 'due', date: DateTime(2024, 1, 1),
      );
      await saleRepo.addSale(
        productId: productId, quantity: 1, sellingPrice: 400,
        platform: 'facebook', paymentStatus: 'due', date: DateTime.now(),
      );
      await saleRepo.addSale(
        productId: productId, quantity: 1, sellingPrice: 500,
        platform: 'offline', paymentStatus: 'paid', date: DateTime.now(),
      );
      final dueSales = await (db.select(db.sales)
            ..where((t) => t.paymentStatus.equals('due')))
          .get();
      final totalDue = dueSales.fold(0.0, (sum, s) => sum + s.total);
      expect(totalDue, closeTo(1000.0, 0.01)); // 600 + 400
    });

    test('low stock products list excludes products above threshold', () async {
      // productId has stock 50 - sales; initially 50, threshold 3 → not low
      final lowId = await productRepo.create(
          name: 'Low', costPrice: 100, initialStock: 1); // stock 1, threshold 3
      final products = await db.select(db.products).get();
      final lowStock = products
          .where((p) => p.stock < p.lowStockThreshold)
          .toList();
      expect(lowStock.length, 1);
      expect(lowStock.first.id, lowId);
    });
  });
}
```

---

## 5. Unit Tests — ExportService

```dart
// test/unit/export_service_test.dart

import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_repository.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/expenses/expense_repository.dart';
import 'package:tracker/models/expense_filter.dart';
import 'package:tracker/services/export_service.dart';

void main() {
  late AppDatabase db;
  late ExportService exportService;
  late ProductRepository productRepo;
  late SaleRepository saleRepo;
  late ExpenseRepository expenseRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    productRepo = ProductRepository(db);
    saleRepo = SaleRepository(db, productRepo);
    expenseRepo = ExpenseRepository(db);
    exportService = ExportService(db);
  });

  tearDown(() => db.close());

  group('ExportService', () {
    test('does not throw when no data exists for the month', () async {
      expect(
        () => exportService.buildWorkbook(DateTime(2024, 6)),
        returnsNormally,
      );
    });

    test('workbook includes sales for the correct month only', () async {
      final productId = await productRepo.create(
          name: 'Widget', costPrice: 400.0, initialStock: 10);
      // June sale — should be exported
      await saleRepo.addSale(
        productId: productId, quantity: 1, sellingPrice: 500,
        platform: 'offline', paymentStatus: 'paid',
        date: DateTime(2024, 6, 15),
      );
      // May sale — should NOT appear in June export
      await saleRepo.addSale(
        productId: productId, quantity: 1, sellingPrice: 450,
        platform: 'facebook', paymentStatus: 'paid',
        date: DateTime(2024, 5, 10),
      );
      final workbook = await exportService.buildWorkbook(DateTime(2024, 6));
      // Sales sheet is index 0
      final salesSheet = workbook.worksheets[0];
      // Row 1 is header; row 2 is the June sale; no row 3
      expect(salesSheet.getRangeByIndex(2, 1).getText(), isNotNull);
      expect(salesSheet.getRangeByIndex(3, 1).getText(), isEmpty);
      workbook.dispose();
    });

    test('workbook has 3 sheets: Sales, Expenses, Summary', () async {
      final workbook = await exportService.buildWorkbook(DateTime(2024, 6));
      expect(workbook.worksheets.count, 3);
      expect(workbook.worksheets[0].name, 'Sales');
      expect(workbook.worksheets[1].name, 'Expenses');
      expect(workbook.worksheets[2].name, 'Summary');
      workbook.dispose();
    });

    test('summary sheet contains gross profit cell', () async {
      final productId = await productRepo.create(
          name: 'P', costPrice: 400.0, initialStock: 5);
      await saleRepo.addSale(
        productId: productId, quantity: 2, sellingPrice: 600,
        platform: 'facebook', paymentStatus: 'paid',
        date: DateTime(2024, 6, 1),
      ); // Gross profit = (600-400)*2 = 400
      final workbook = await exportService.buildWorkbook(DateTime(2024, 6));
      final summary = workbook.worksheets[2];
      // Find the cell containing the gross profit value — check it's non-empty
      expect(summary.getRangeByName('B2').getText(), isNotEmpty);
      workbook.dispose();
    });
  });
}

// Note: ExportService.buildWorkbook() is a testable internal method
// that returns a Workbook object without triggering share_plus.
// Add this method to export_service.dart alongside exportMonth():
//
// Future<Workbook> buildWorkbook(DateTime month) async { ... }
// Future<void> exportMonth(DateTime month) async {
//   final workbook = await buildWorkbook(month);
//   final bytes = workbook.saveAsStream();
//   workbook.dispose();
//   // ... write file and share
// }
```

---

## 6. Widget Tests — Reports & Dashboard

```dart
// test/widget/dashboard_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/dashboard/dashboard_screen.dart';

void main() {
  group('DashboardScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pump(); // don't pumpAndSettle — async provider
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('shows stat sections headings', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      // These headings should always be present, even with no data
      expect(find.text('Sales Today'), findsOneWidget);
      expect(find.text('Profit Today'), findsOneWidget);
    });
  });
}

// test/widget/chart_toggle_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/features/reports/widgets/chart_table_toggle.dart';

void main() {
  group('ChartTableToggle', () {
    testWidgets('shows chart when showChart is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChartTableToggle(
            showChart: true,
            onToggle: () {},
            chart: const Text('CHART_CONTENT'),
            table: const Text('TABLE_CONTENT'),
          ),
        ),
      );
      expect(find.text('CHART_CONTENT'), findsOneWidget);
      expect(find.text('TABLE_CONTENT'), findsNothing);
    });

    testWidgets('shows table when showChart is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChartTableToggle(
            showChart: false,
            onToggle: () {},
            chart: const Text('CHART_CONTENT'),
            table: const Text('TABLE_CONTENT'),
          ),
        ),
      );
      expect(find.text('TABLE_CONTENT'), findsOneWidget);
      expect(find.text('CHART_CONTENT'), findsNothing);
    });

    testWidgets('toggle button text changes based on showChart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChartTableToggle(
            showChart: true,
            onToggle: () {},
            chart: const Text('Chart'),
            table: const Text('Table'),
          ),
        ),
      );
      expect(find.text('Show Table'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ChartTableToggle(
            showChart: false,
            onToggle: () {},
            chart: const Text('Chart'),
            table: const Text('Table'),
          ),
        ),
      );
      expect(find.text('Show Chart'), findsOneWidget);
    });

    testWidgets('onToggle callback fires when toggle tapped', (tester) async {
      var toggled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ChartTableToggle(
            showChart: true,
            onToggle: () => toggled = true,
            chart: const Text('C'),
            table: const Text('T'),
          ),
        ),
      );
      await tester.tap(find.text('Show Table'));
      expect(toggled, isTrue);
    });
  });
}
```

**Run all Phase 5 tests:**
```bash
flutter test test/unit/profit_calculation_test.dart --reporter expanded
flutter test test/unit/dashboard_provider_test.dart --reporter expanded
flutter test test/unit/export_service_test.dart --reporter expanded
flutter test test/widget/dashboard_test.dart --reporter expanded
flutter test test/widget/chart_toggle_test.dart --reporter expanded
```

---

## 7. Manual Validation Checklist

### 7.1 Dashboard

| Element | Expected with data |
|---------|--------------------|
| Sales Today count | Exact count of today's sales |
| Revenue Today | Sum of all today's `total` values |
| Gross Profit Today | Sum of `(sell - cost) * qty` for today |
| Net Profit Today | Gross − today's expenses |
| Total Due | Sum of all unpaid `total` across ALL dates |
| Facebook profit card | Sum of `(sell - cost) * qty` for platform='facebook', today |
| Offline profit card | Same for platform='offline' |
| Low Stock section | Products where `stock < lowStockThreshold` |
| Low stock tile tap | Navigates to `/products/:id` detail screen |

### 7.2 Daily Report

| Scenario | Expected |
|----------|---------|
| Select today (with data) | Shows today's sales + expenses |
| Select a past date | Shows data for that date only |
| Chart view | Revenue and profit bars visible |
| Table view | Rows for each sale + expense; totals row at bottom |
| Toggle Chart ↔ Table | AnimatedSwitcher transitions, state preserved |
| No data for selected date | Empty state message shown |

### 7.3 Monthly Report

| Scenario | Expected |
|----------|---------|
| Current month | Bar chart shows bars for each day that had a sale |
| Previous month | Data for that month shown |
| Bar chart | Grey bar = revenue, accent bar = profit, side by side |
| Table view | One row per day with revenue + profit; totals at bottom |
| Platform split | Facebook profit + Offline profit shown correctly |
| Top products | 5 products sorted by highest profit for the period |
| Export button | Opens Android share sheet with `.xlsx` file |

### 7.4 Product Report

| Scenario | Expected |
|----------|---------|
| Select product with sales | Stats populated |
| Units sold | Matches sum of qty across all sales for that product |
| Average sell price | Sum of all selling prices / number of sales |
| Highest sell price | Maximum selling price across all sales |
| Lowest sell price | Minimum selling price across all sales |
| Price history chart (line) | Each dot = a sale, ordered by date |
| Table view | Lists every sale with date, qty, sell price, profit |
| Product with no sales | "No sales recorded" empty state |

### 7.5 Export Validation

| Check | Expected |
|-------|---------|
| Tap "Export Month" | System share sheet opens |
| File name | `tracker_YYYY_MM.xlsx` |
| Sales sheet | One row per sale in the month |
| Expenses sheet | One row per expense in the month |
| Summary sheet | Gross profit, net profit, platform split, top 5 |
| Open in Excel/Sheets | No formatting errors, all numbers correct |
| Export for empty month | File generated with headers only, no crash |

---

## 8. Debugging Guide

### 8.1 Dashboard Shows Zero for Everything

**Symptom:** All stat cards show ৳0 or 0 even with data in the database.

**Root cause candidates:**

1. Date boundary bug — `startOfDay` and `endOfDay` timestamps are calculated wrong.
```dart
// CORRECT
final today = DateTime.now();
final start = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
final end = DateTime(today.year, today.month, today.day, 23, 59, 59, 999).millisecondsSinceEpoch;

// WRONG — this uses current time as start, excluding sales earlier today
final start = DateTime.now().millisecondsSinceEpoch;
```

2. `productMap` lookup fails — product deleted after sale was recorded.
```dart
for (final s in todaySales) {
  final product = productMap[s.productId];
  if (product == null) continue; // ← safe skip, but logs should show this
  debugPrint('Processing sale ${s.id}: product=${product.name}');
}
```

### 8.2 Bar Chart Renders Blank / Crashes

**Symptom:** `MonthlyReportScreen` shows empty chart area or throws a `RangeError`.

**Root cause:** `dailySnapshots` list is empty OR contains `NaN` values (division by zero in margin calc).

**Fix:**
```dart
// Guard against empty snapshots
if (snapshots.isEmpty) return const SizedBox.shrink();

// Guard against NaN in profit values
final safeProfit = profit.isNaN || profit.isInfinite ? 0.0 : profit;
```

**fl_chart `BarChart` null check:**
```dart
// barGroups must not be empty — fl_chart throws if the list is empty
barGroups: snapshots.isEmpty
    ? [BarChartGroupData(x: 0, barRods: [])] // safe placeholder
    : snapshots.asMap().entries.map(...).toList(),
```

### 8.3 Export File Generates But Shows Wrong Numbers

**Symptom:** Excel file opens, numbers in it don't match the in-app reports.

**Root cause:** `ExportService` and `ReportRepository` query the same data independently. If one uses a different date boundary (e.g., `end of month = last day at 00:00` instead of `23:59:59`), totals diverge.

**Fix:** Extract the month boundary into a shared utility:
```dart
// lib/core/utils/date_utils.dart
class TrackerDateUtils {
  static DateTime monthStart(DateTime month) =>
      DateTime(month.year, month.month, 1);

  static DateTime monthEnd(DateTime month) =>
      DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
}
// Use this in BOTH ReportRepository and ExportService
```

### 8.4 `expenseRepositoryProvider` Not Available

**Symptom:** Compile error in `DashboardProvider` or `ReportRepository` referencing `expenseRepositoryProvider`.

**Fix:**
1. Confirm Agent A has run `dart run build_runner build`.
2. Add the import:
   ```dart
   import 'package:tracker/features/expenses/expense_repository.dart';
   ```
3. Call:
   ```dart
   final totalExpenses = await ref
       .read(expenseRepositoryProvider)
       .totalForPeriod(start, end);
   ```

### 8.5 AnimatedSwitcher Causes Chart to Flicker

**Symptom:** Toggling chart ↔ table causes a flash of wrong content.

**Root cause:** `AnimatedSwitcher` uses the child's `runtimeType` as the key by default. Both chart and table are `Widget` — so it doesn't detect a change.

**Fix:** Always use `KeyedSubtree` or explicit `key:` on chart and table widgets:
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  child: showChart
      ? KeyedSubtree(key: const ValueKey('chart'), child: chart)
      : KeyedSubtree(key: const ValueKey('table'), child: table),
),
```

---

## 9. Phase 5 Completion Gate

```
✅ flutter analyze — 0 errors
✅ test/unit/profit_calculation_test.dart — all 14+ tests pass
✅ test/unit/dashboard_provider_test.dart — all 4 tests pass
✅ test/unit/export_service_test.dart — all 4 tests pass
✅ test/widget/dashboard_test.dart — all tests pass
✅ test/widget/chart_toggle_test.dart — all 4 tests pass
✅ Manual: Dashboard — all 7 stat elements verified against actual data
✅ Manual: Daily report — chart + table toggle works; date navigation works
✅ Manual: Monthly report — bar chart renders; correct day-by-day data
✅ Manual: Product report — line chart plots; table shows correct sales
✅ Manual: Platform split — Facebook + Offline correctly separated
✅ Manual: Export — .xlsx file opens in Excel/Sheets with correct data (3 sheets)
✅ Manual: Export for empty month — no crash, headers only
✅ Manual: Low stock alert tap on dashboard navigates to product detail
✅ Update 06_completion_status.md Phase 5 rows to ✅
```

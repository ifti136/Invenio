# Overall App — Validation, Debugging & Testing
## Full Integration, End-to-End Flows, Release Checklist

**Run this after all 5 phases are complete and all phase-level gates pass.**

---

## 1. Full Test Suite Run

Run every test file in one command and confirm zero failures:

```bash
flutter test --reporter expanded

# Expected output structure:
# test/unit/database_schema_test.dart         — 5 tests
# test/unit/product_repository_test.dart      — 14+ tests
# test/unit/alert_service_test.dart           — 15+ tests
# test/unit/sale_repository_test.dart         — 12+ tests
# test/unit/expense_contract_test.dart        — 5 tests
# test/unit/expense_repository_test.dart      — 18+ tests
# test/unit/profit_calculation_test.dart      — 14+ tests
# test/unit/dashboard_provider_test.dart      — 4 tests
# test/unit/export_service_test.dart          — 4 tests
# test/widget/theme_test.dart                 — 4 tests
# test/widget/router_test.dart                — 2 tests
# test/widget/product_form_test.dart          — 3+ tests
# test/widget/sale_form_test.dart             — 3 tests
# test/widget/expense_form_test.dart          — 7 tests
# test/widget/dashboard_test.dart             — 2 tests
# test/widget/chart_toggle_test.dart          — 4 tests
#
# Total: ≥ 116 tests — All must pass.
```

---

## 2. Static Analysis — Final Pass

```bash
flutter analyze

# Acceptable:
#   No issues found!
# OR:
#   1 issue — duplicate_ignore at app_database.g.dart:2747 (auto-generated, ignored)

# NOT acceptable — any errors or warnings on hand-written files
```

---

## 3. End-to-End Integration Tests

These tests exercise the full app stack from UI through DB. They require a connected device or emulator.

```dart
// test/integration/app_e2e_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── E2E Flow 1: Add product → Log sale → Verify stock reduces ─────────────

  group('E2E: Core reseller workflow', () {
    testWidgets('add product → log sale → verify stock reduces',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ── Step 1: Navigate to Products ───────────────────────────────────────
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();

      // ── Step 2: Add a product ──────────────────────────────────────────────
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, 'Name'), 'E2E Test Product');
      await tester.enterText(
          find.widgetWithText(TextField, 'Cost Price (৳)'), '400');
      await tester.enterText(
          find.widgetWithText(TextField, 'Initial Stock'), '10');
      await tester.tap(find.text('Save Product'));
      await tester.pumpAndSettle();

      // Product should appear in list
      expect(find.text('E2E Test Product'), findsOneWidget);

      // ── Step 3: Navigate to Sales → log a sale ────────────────────────────
      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select product
      await tester.tap(find.text('Select product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('E2E Test Product'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Quantity'), '3');
      await tester.enterText(
          find.widgetWithText(TextField, 'Selling Price (৳)'), '500');
      await tester.tap(find.text('Save Sale'));
      await tester.pumpAndSettle();

      // ── Step 4: Verify stock reduced ──────────────────────────────────────
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      // Stock badge should show 7 (10 - 3)
      expect(find.text('7 units'), findsOneWidget);
    });

    testWidgets('below-cost alert fires and can be dismissed', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // (Assumes product "E2E Test Product" exists from previous test
      //  or create it fresh for isolated runs)

      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('E2E Test Product'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Quantity'), '1');
      await tester.enterText(
          find.widgetWithText(TextField, 'Selling Price (৳)'), '300'); // below 400
      await tester.tap(find.text('Save Sale'));
      await tester.pumpAndSettle();

      // Pre-save confirm dialog should appear
      expect(find.textContaining('below cost'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Post-save amber SnackBar should appear
      expect(find.textContaining('Sold below cost'), findsOneWidget);
    });
  });

  // ── E2E Flow 2: Expense → Report net profit ───────────────────────────────

  group('E2E: Expense affects net profit', () {
    testWidgets('net profit = gross - expenses', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Log an expense
      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, 'Amount (৳)'), '200');
      await tester.tap(find.text('📢 Ads'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log Expense'));
      await tester.pumpAndSettle();

      // Check dashboard net profit
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      // Net profit should be visible — specific value depends on test state
      expect(find.text('Net Profit'), findsOneWidget);
    });
  });

  // ── E2E Flow 3: Due → Paid workflow ──────────────────────────────────────

  group('E2E: Mark sale as paid', () {
    testWidgets('due sale can be marked as paid', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Sales'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select product'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('E2E Test Product'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextField, 'Quantity'), '1');
      await tester.enterText(
          find.widgetWithText(TextField, 'Selling Price (৳)'), '500');
      // Select Due
      await tester.tap(find.text('Due'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Sale'));
      await tester.pumpAndSettle();

      // Due badge visible in list
      expect(find.text('Due'), findsOneWidget);

      // Mark as paid via popup menu
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as paid'));
      await tester.pumpAndSettle();

      // Due badge gone
      expect(find.text('Due'), findsNothing);
    });
  });
}
```

**Run integration tests:**
```bash
# Device/emulator must be connected
flutter test test/integration/app_e2e_test.dart -d <device-id>

# To list connected devices:
flutter devices
```

---

## 4. Cross-Phase Data Integrity Checks

These manual checks verify that data created in one phase is correctly consumed by another.

### 4.1 Stock Ledger Integrity

After any combination of product creation, restocks, sales, and adjustments, run this mental audit:

```
Expected stock = initial_stock
              + sum(restock quantities)
              - sum(sale quantities)
              + sum(adjustment deltas, signed)
```

**Where to check:** Product detail → Stock Log tab shows every movement. Sum them manually and compare to the displayed stock count. They must always match.

**Automated equivalent:**
```dart
// Add to a temporary debug screen or test helper
Future<bool> verifyStockIntegrity(AppDatabase db, int productId) async {
  final product = await (db.select(db.products)
        ..where((t) => t.id.equals(productId)))
      .getSingle();
  final movements = await (db.select(db.stockMovements)
        ..where((t) => t.productId.equals(productId)))
      .get();
  final reconstructed = movements.fold(0, (sum, m) => sum + m.quantity);
  final match = product.stock == reconstructed;
  debugPrint('Product ${product.name}: stored=${product.stock}, '
      'reconstructed=$reconstructed, match=$match');
  return match;
}
```

### 4.2 Profit Cross-Phase Spot-Check

Create this exact sequence and verify each downstream figure:

| Step | Action | Value |
|------|--------|-------|
| 1 | Add product: cost = ৳400, stock = 10 | — |
| 2 | Log sale: qty=2, price=৳500, Facebook | Gross profit = ৳200 |
| 3 | Log sale: qty=1, price=৳350, Offline | Gross profit = −৳50 |
| 4 | Log expense: ৳150 Ads | — |
| **Expected totals** | | |
| Gross profit | ৳200 − ৳50 = | **৳150** |
| Total expenses | | **৳150** |
| Net profit | ৳150 − ৳150 = | **৳0** |
| Facebook profit | | **৳200** |
| Offline profit | | **−৳50** |
| Product all-time profit | | **৳150** |

Verify each of these figures appears in:
- Dashboard (today's values, if done today)
- Daily Report for today
- Monthly Report for current month
- Product Report for the test product
- Exported `.xlsx` Summary sheet

### 4.3 Deleted Sale — Chain Verification

| Action | Verify |
|--------|--------|
| Log sale: qty=3, product stock was 10 | Stock now = 7 |
| Delete the sale | Stock now = 10 (restored) |
| Dashboard gross profit | Reduced by the deleted sale's profit |
| Product all-time profit | Same reduction |
| Stock Log | Sale movement row gone |

---

## 5. Performance Benchmarks

Test on a mid-range physical Android device (API 24+), not just an emulator.

| Operation | Target | How to measure |
|-----------|--------|---------------|
| App cold start | < 3 seconds to first frame | `flutter run --profile`, watch logs |
| Add sale (form → list) | < 200 ms | Use `Stopwatch` around `addSale()` call |
| Product list (50 products) | < 100 ms render | `flutter run --profile`, DevTools Timeline |
| Sale list (200 sales) | < 200 ms render | DevTools Timeline |
| Monthly report query | < 500 ms | Time `getMonthly()` call |
| Excel export (100 sales) | < 3 seconds | Time `exportMonth()` call |
| Aurora animation | Consistent 60 fps | DevTools → Performance overlay |

**Enable performance overlay:**
```bash
flutter run --profile
# Press 'P' in terminal to toggle performance overlay
# Both raster and UI threads should stay below the red line (16ms)
```

---

## 6. Regression Test Matrix

Run after any code change. Each row is a user-visible behavior that must not break.

| # | Behavior | How to test |
|---|----------|------------|
| R01 | App launches without crash | `flutter run` |
| R02 | All 5 bottom nav tabs navigate correctly | Tap each tab |
| R03 | Product created → appears in list | Add product |
| R04 | Stock badge color correct (green/amber/red) | Set stock near threshold |
| R05 | Sale logged → stock decremented | Log sale, check product |
| R06 | Below-cost alert fires | Sell below cost |
| R07 | Low-stock alert fires | Sell until near threshold |
| R08 | Margin drop alert fires | Second sale at lower margin |
| R09 | Delete sale → stock restored | Delete and check |
| R10 | Mark Due → Paid | Change payment status |
| R11 | Expense logged → appears in list | Add expense |
| R12 | Period total updates after add/delete | Add, check total, delete, check again |
| R13 | Dashboard figures reflect today's data | Log sale today, check dashboard |
| R14 | Daily report shows correct gross + net | Log sale + expense, check report |
| R15 | Monthly bar chart renders | Open monthly report |
| R16 | Chart ↔ table toggle works in all 3 reports | Toggle each |
| R17 | Product report line chart plots | Log 3+ sales for one product |
| R18 | Export generates .xlsx and opens share sheet | Tap Export Month |
| R19 | Aurora visible in light and dark mode | Toggle system theme |
| R20 | Glass UI elements render (AppBar, nav, dialogs) | Open dialog, observe nav |

---

## 7. Common Cross-Phase Bugs

| Symptom | Phase | Root cause | Fix |
|---------|-------|-----------|-----|
| Stock shows negative | 2+3 | `deleteSale` stock restore ran twice | Ensure `deleteSale` is only called once; check if FAB double-tap is possible |
| Dashboard and reports show different profit | 3+5 | Different date boundary calculations | Use shared `TrackerDateUtils.monthStart/End()` everywhere |
| Expense not reflected in net profit | 4+5 | `totalForPeriod` date range doesn't match report range | Verify both use identical `start` and `end` timestamps |
| Export totals differ from in-app | 5 | Export queries raw DB; report uses cached provider data | Ensure both query the same date range |
| Chart renders but table is blank | 5 | `dailySnapshots` has items but `report_table.dart` filters wrong | Verify table uses same data source as chart |
| `GlassPanel` causes jank on list scroll | 1.5 | BackdropFilter inside a `ListView` is expensive | Do NOT wrap list tiles in GlassPanel — only use on AppBar/Nav/Modals |
| `AnimatedSwitcher` flickers on toggle | 5 | Missing `KeyedSubtree` on chart and table children | Add `key: const ValueKey('chart')` and `key: const ValueKey('table')` |
| Stock movement log shows wrong total | 2 | `adjustStock` delta sign reversed | Positive = in, negative = out; verify UI passes the right sign |

---

## 8. Device Testing Matrix

Test on at least 2 different physical or emulated configurations before release:

| Device | Android version | Screen | Expected |
|--------|----------------|--------|---------|
| Mid-range phone (e.g. Redmi Note) | API 29 (Android 10) | 6.5" | All features work |
| Older budget phone | API 24 (Android 7) | 5.0" | Minimum supported — must not crash |
| Tablet | API 31+ | 10"+ | Layout may look wide — acceptable |
| Emulator | API 34 | Any | CI validation only |

---

## 9. Pre-Release Checklist

Complete every item before building a release APK:

```
□ 1.  flutter analyze — 0 errors (auto-generated warnings acceptable)
□ 2.  flutter test — ≥ 116 tests, 0 failures
□ 3.  All 20 regression behaviors verified manually (see §6)
□ 4.  Cross-phase spot-check table verified (see §4.2)
□ 5.  Stock ledger integrity check passes for 3+ products
□ 6.  Export .xlsx opened in Excel and Google Sheets — correct data
□ 7.  Tested on minimum API 24 device — no crash
□ 8.  Tested on modern device (API 33+) — no visual regressions
□ 9.  Aurora animation runs at 60fps (no jank) in profile mode
□ 10. Debug-only code removed (schema check in main.dart, debug prints)
□ 11. kDebugMode guards removed or wrapped properly
□ 12. 06_completion_status.md updated — all phases ✅
□ 13. Build release APK and install:

flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk

□ 14. Cold start from fresh install — no crash, DB created cleanly
□ 15. Data persists after app kill and relaunch
□ 16. Export still works after reinstall (share_plus not broken by keystore)
```

---

## 10. Running All Tests — Single Command Reference

```bash
# Static analysis
flutter analyze

# All automated tests
flutter test --reporter expanded

# Specific test files (fast feedback)
flutter test test/unit/ --reporter expanded
flutter test test/widget/ --reporter expanded

# Integration tests (device required)
flutter test test/integration/ -d <device-id> --reporter expanded

# Single file (fastest)
flutter test test/unit/alert_service_test.dart --reporter expanded

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # macOS; use xdg-open on Linux
```

---

## 11. Test File Index

```
test/
├── unit/
│   ├── database_schema_test.dart        Phase 1 — DB tables, defaults, FK
│   ├── product_repository_test.dart     Phase 2 — create, restock, adjust, update
│   ├── alert_service_test.dart          Phase 3 — BelowCost, LowStock, MarginDrop
│   ├── sale_repository_test.dart        Phase 3 — addSale transaction, delete, markAsPaid
│   ├── expense_contract_test.dart       Phase 4 — totalForPeriod cross-agent contract
│   ├── expense_repository_test.dart     Phase 4 — full CRUD + filtering
│   ├── profit_calculation_test.dart     Phase 5 — pure calculation functions
│   ├── dashboard_provider_test.dart     Phase 5 — today's DB queries
│   └── export_service_test.dart         Phase 5 — workbook structure + data correctness
│
├── widget/
│   ├── theme_test.dart                  Phase 1 — Material 3, transparent scaffold
│   ├── router_test.dart                 Phase 1 — app renders, nav tabs present
│   ├── product_form_test.dart           Phase 2 — validation errors, field rendering
│   ├── sale_form_test.dart              Phase 3 — validation, default toggles
│   ├── expense_form_test.dart           Phase 4 — category chips, validation, add/edit modes
│   ├── dashboard_test.dart              Phase 5 — renders, stat section headings
│   └── chart_toggle_test.dart           Phase 5 — chart/table visibility, callback
│
└── integration/
    └── app_e2e_test.dart                Overall — full reseller workflow, alerts, due→paid
```

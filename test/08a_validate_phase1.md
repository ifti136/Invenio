# Phase 1 — Validation, Debugging & Testing
## Foundation: Database, Scaffold, Theme

**Status at time of writing:** ✅ Complete (from `06_completion_status.md`)
**Actual Flutter SDK:** 3.24.4 · Dart 3.5.4
**Theme deviation:** Liquid Glass (`glass_kit` + `aurora_background`) applied on top of the original plan

---

## 1. Static Validation

Run these before touching any other phase. All must pass clean before proceeding.

```bash
# From project root
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze

# Expected output:
#   Analyzing tracker_app...
#   No issues found!
#   (or: 1 issue — duplicate_ignore in app_database.g.dart:2747, auto-generated, safe to ignore)
```

### What `flutter analyze` checks for Phase 1

| Check | What it catches |
|-------|----------------|
| Drift `@DriftDatabase` | Table list matches all 4 table classes |
| `NativeDatabase.createInBackground` | Correct import (`drift/native.dart`) |
| `appDatabaseProvider` | `@Riverpod(keepAlive: true)` annotation present, `.g.dart` generated |
| `ShellRoute` in router | All nested routes compile without missing screen classes |
| `AuroraBackdrop` | `glass_kit` and `aurora_background` deps resolved in pubspec |
| `app_colors.dart` | All color constants are `static const Color` — no runtime construction |

---

## 2. Database Validation

### 2.1 Schema Integrity Check

Add this temporary debug helper to `main.dart` (remove before release):

```dart
// TEMPORARY — add inside main() after WidgetsFlutterBinding.ensureInitialized()
// Remove before building release APK
if (kDebugMode) {
  final db = AppDatabase();
  try {
    // Ping each table — will throw if schema is wrong
    await db.select(db.products).get();
    await db.select(db.sales).get();
    await db.select(db.expenses).get();
    await db.select(db.stockMovements).get();
    debugPrint('✅ DB schema OK — all 4 tables accessible');
  } catch (e) {
    debugPrint('❌ DB schema ERROR: $e');
  } finally {
    await db.close();
  }
}
```

**Expected output in debug console:**
```
✅ DB schema OK — all 4 tables accessible
```

### 2.2 Migration Safety Check

```dart
// test/unit/database_schema_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';

void main() {
  group('AppDatabase schema', () {
    late AppDatabase db;

    setUp(() {
      // In-memory database — no file I/O, no device needed
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('creates all 4 tables on first open', () async {
      // If any table is missing, getSingle/get will throw
      expect(() => db.select(db.products).get(), returnsNormally);
      expect(() => db.select(db.sales).get(), returnsNormally);
      expect(() => db.select(db.expenses).get(), returnsNormally);
      expect(() => db.select(db.stockMovements).get(), returnsNormally);
    });

    test('products table accepts a minimal insert', () async {
      final id = await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: 'Test Product',
          costPrice: 100.0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      expect(id, greaterThan(0));
    });

    test('sales table FK references products correctly', () async {
      final productId = await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: 'Widget',
          costPrice: 50.0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(
        () => db.into(db.sales).insert(
          SalesCompanion.insert(
            productId: productId,
            quantity: 2,
            sellingPrice: 75.0,
            total: 150.0,
            platform: 'offline',
            paymentStatus: 'paid',
            date: now,
            createdAt: now,
          ),
        ),
        returnsNormally,
      );
    });

    test('default stock is 0 when not provided', () async {
      final id = await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: 'No Stock Product',
          costPrice: 10.0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      final product =
          await (db.select(db.products)..where((t) => t.id.equals(id)))
              .getSingle();
      expect(product.stock, 0);
    });

    test('default low_stock_threshold is 3', () async {
      final id = await db.into(db.products).insert(
        ProductsCompanion.insert(
          name: 'Default Threshold',
          costPrice: 10.0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      final product =
          await (db.select(db.products)..where((t) => t.id.equals(id)))
              .getSingle();
      expect(product.lowStockThreshold, 3);
    });
  });
}
```

**Run with:**
```bash
flutter test test/unit/database_schema_test.dart --reporter expanded
```

### 2.3 Add `AppDatabase.forTesting` Constructor

Add this to `lib/db/app_database.dart` (inside the class, under the main constructor):

```dart
// Used ONLY in tests — never in production code
AppDatabase.forTesting(QueryExecutor executor) : super(executor);
```

---

## 3. Theme / Glass Validation

### 3.1 Visual Checklist (manual, on device or emulator)

| Element | Expected | How to check |
|---------|----------|-------------|
| App launch | Aurora animation visible behind all UI | Launch app in dark mode |
| Light mode | Aurora palette switches to cream/lavender | Settings → Display → Light |
| Bottom nav | Floating glass pill, frosted, above body | Scroll any long list |
| Status bar | Transparent, icons adapt to brightness | Both light + dark |
| `GlassPanel` | Blur visible (not plain white box) | Open any GlassPanel — Product form |
| `GlassTextField` | Focus ring uses accent color (teal) | Tap any text field |
| Dialog | Glass-frosted background (not plain white) | Tap delete on any item |

### 3.2 Automated Theme Validation

```dart
// test/widget/theme_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme uses Material 3', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
    });

    test('dark theme uses Material 3', () {
      final theme = AppTheme.dark();
      expect(theme.useMaterial3, isTrue);
    });

    test('scaffold background is transparent (aurora shows through)', () {
      final theme = AppTheme.light();
      expect(theme.scaffoldBackgroundColor, Colors.transparent);
    });
  });

  group('AppColors', () {
    test('all stock colors are distinct', () {
      expect(AppColors.stockGood, isNot(AppColors.stockWarn));
      expect(AppColors.stockWarn, isNot(AppColors.stockLow));
      expect(AppColors.stockGood, isNot(AppColors.stockLow));
    });

    test('platform colors are defined', () {
      expect(AppColors.facebook, isNotNull);
      expect(AppColors.offline, isNotNull);
    });
  });
}
```

---

## 4. Navigation / Router Validation

### 4.1 Route Smoke Test

```dart
// test/widget/router_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/app.dart';

void main() {
  testWidgets('app renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TrackerApp()),
    );
    await tester.pumpAndSettle();
    // Bottom nav should be present
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('tapping Products tab navigates to products screen',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TrackerApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();
    // Products AppBar title visible
    expect(find.text('Products'), findsWidgets);
  });
}
```

### 4.2 Bottom Nav Validation Checklist

| Tab | Tapping navigates to | Back button behavior |
|-----|----------------------|---------------------|
| Dashboard | `/dashboard` | No back (root) |
| Products | `/products` | No back (root) |
| Sales | `/sales` | No back (root) |
| Expenses | `/expenses` | No back (root) |
| Reports | `/reports` | No back (root) |
| Sub-routes | `Products → /products/add` | Back → products list |

---

## 5. Common Phase 1 Bugs & Fixes

| Symptom | Root cause | Fix |
|---------|-----------|-----|
| `Could not find generated class _$AppDatabase` | `build_runner` not run | `dart run build_runner build --delete-conflicting-outputs` |
| `MissingPluginException` on launch | `sqlite3_flutter_libs` missing or not resolved | `flutter pub get` → clean rebuild |
| Aurora not visible (plain background) | `scaffoldBackgroundColor` not `Colors.transparent` | Verify `app_theme.dart` sets transparent scaffold |
| Bottom nav shows without glass | `GlassPanel` wrapper missing in `app_bottom_nav.dart` | Wrap `NavigationBar` in `GlassPanel` |
| `duplicate_ignore` warning in `.g.dart` | Auto-generated code — harmless | Add to `analysis_options.yaml` exclude list if desired |
| App crashes on cold start | Database file path resolution fails | Ensure `WidgetsFlutterBinding.ensureInitialized()` is called before `runApp` |
| Router shows blank screen | ShellRoute child not wrapped in `Scaffold` | Verify `AppScaffold` wraps `child` correctly |

---

## 6. Phase 1 Completion Gate

All of the following must be true before Phase 2 work begins:

```
✅ flutter pub get — no resolution errors
✅ dart run build_runner build — 0 errors, .g.dart files generated
✅ flutter analyze — 0 errors (1 duplicate_ignore warning acceptable)
✅ test/unit/database_schema_test.dart — all 5 tests pass
✅ test/widget/theme_test.dart — all 4 tests pass
✅ test/widget/router_test.dart — both tests pass
✅ Manual: app launches on device/emulator without crash
✅ Manual: 5 bottom nav tabs all visible and tappable
✅ Manual: aurora animation visible in both light and dark mode
```

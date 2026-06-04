# Scaffolding — Inventory & Economy Tracker

## 1. Prerequisites

Ensure the following are installed before running any commands:

| Tool | Version | Check |
|------|---------|-------|
| Flutter SDK | ≥ 3.16.0 | `flutter --version` |
| Dart SDK | ≥ 3.2.0 | included with Flutter |
| Android Studio | ≥ Hedgehog | for emulator + SDK |
| Android SDK | API 34 (target), API 24 (min) | via SDK Manager |
| Java | 17 | `java --version` |
| Git | any | `git --version` |

---

## 2. Project Initialisation

### Step 1 — Create the project

```bash
flutter create \
  --org com.yourname \
  --project-name tracker \
  --platforms android \
  tracker_app

cd tracker_app
```

### Step 2 — Clean out boilerplate

```bash
# Remove the default counter demo
rm lib/main.dart
rm test/widget_test.dart
```

### Step 3 — Set minimum SDK version

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24       // Android 7.0
        targetSdkVersion 34
        compileSdkVersion 34
    }
}
```

### Step 4 — Add dependencies

Replace `pubspec.yaml` dependencies section:

```yaml
dependencies:
  flutter:
    sdk: flutter

  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  go_router: ^13.0.0

  fl_chart: ^0.66.0

  syncfusion_flutter_xlsio: ^24.0.0
  share_plus: ^7.2.0

  intl: ^0.19.0
  uuid: ^4.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  drift_dev: ^2.14.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
```

```bash
flutter pub get
```

---

## 3. Folder Structure Creation

Run this script from the project root to create all required directories and empty placeholder files:

```bash
#!/bin/bash
# scaffold.sh — run once from project root

# Core
mkdir -p lib/core/theme lib/core/utils lib/core/widgets

# Database
mkdir -p lib/db/tables

# Features
for feature in dashboard products sales expenses reports; do
  mkdir -p lib/features/$feature/widgets
done

# Services & Models
mkdir -p lib/services lib/models

# Tests
mkdir -p test/unit test/widget test/integration

echo "✓ Folder structure created"
```

```bash
chmod +x scaffold.sh && ./scaffold.sh
```

---

## 4. Entry Point Files

### `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: TrackerApp(),
    ),
  );
}
```

### `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'core/theme/app_theme.dart';

class TrackerApp extends ConsumerWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

---

## 5. Database Bootstrap

### `lib/db/app_database.dart`

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/expenses_table.dart';
import 'tables/stock_movements_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Products, Sales, Expenses, StockMovements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tracker.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
```

---

## 6. Router Bootstrap

### `lib/router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/products/product_list_screen.dart';
import 'features/products/product_detail_screen.dart';
import 'features/products/product_form_screen.dart';
import 'features/sales/sale_list_screen.dart';
import 'features/sales/sale_form_screen.dart';
import 'features/expenses/expense_list_screen.dart';
import 'features/expenses/expense_form_screen.dart';
import 'features/reports/reports_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppScaffold(child: child),
        routes: [
          GoRoute(path: '/dashboard',
              builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: '/products',
            builder: (_, __) => const ProductListScreen(),
            routes: [
              GoRoute(path: 'add',
                  builder: (_, __) => const ProductFormScreen()),
              GoRoute(
                path: ':id',
                builder: (_, s) => ProductDetailScreen(
                    id: int.parse(s.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/sales',
            builder: (_, __) => const SaleListScreen(),
            routes: [
              GoRoute(path: 'add',
                  builder: (_, __) => const SaleFormScreen()),
            ],
          ),
          GoRoute(
            path: '/expenses',
            builder: (_, __) => const ExpenseListScreen(),
            routes: [
              GoRoute(path: 'add',
                  builder: (_, __) => const ExpenseFormScreen()),
            ],
          ),
          GoRoute(path: '/reports',
              builder: (_, __) => const ReportsScreen()),
        ],
      ),
    ],
  );
}
```

---

## 7. Bottom Navigation Shell

### `lib/core/widgets/app_bottom_nav.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.dashboard_outlined,    label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.inventory_2_outlined,  label: 'Products',  path: '/products'),
    (icon: Icons.receipt_long_outlined, label: 'Sales',     path: '/sales'),
    (icon: Icons.wallet_outlined,       label: 'Expenses',  path: '/expenses'),
    (icon: Icons.bar_chart_outlined,    label: 'Reports',   path: '/reports'),
  ];

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) =>
            context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}
```

---

## 8. Theme Bootstrap

### `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.accent,
    brightness: Brightness.light,
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.accent,
    brightness: Brightness.dark,
  );
}
```

---

## 9. Code Generation

After creating the database tables and provider files, run:

```bash
# Generate drift DAOs and Riverpod providers
dart run build_runner build --delete-conflicting-outputs
```

Re-run this command any time you:
- Add or modify a drift `Table` class
- Add or modify a `@riverpod` annotated function
- Add a new file with `part '*.g.dart'`

For continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 10. Placeholder Screens

Create a minimal placeholder for each screen while building features incrementally:

```dart
// Example: lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard — coming soon')),
    );
  }
}
```

Repeat this pattern for:
- `ProductListScreen`
- `ProductDetailScreen`
- `ProductFormScreen`
- `SaleListScreen`
- `SaleFormScreen`
- `ExpenseListScreen`
- `ExpenseFormScreen`
- `ReportsScreen`

---

## 11. First Run Verification

```bash
# Connect an Android device or start emulator, then:
flutter run

# Expected: app launches, bottom nav shows 5 tabs, no crashes
# Tap each tab — placeholder text appears for each
```

If the build fails, check:
1. `flutter doctor` — all required SDK components installed
2. `dart run build_runner build` was run after adding drift tables
3. `minSdkVersion 24` is set in `android/app/build.gradle`

---

## 12. Git Initialisation

```bash
git init
git add .
git commit -m "chore: initial scaffold — Flutter + drift + Riverpod + go_router"
```

Recommended branch strategy:
```
main          ← stable, always runnable
dev           ← active development
feature/XXX   ← one branch per phase
```

```bash
git checkout -b dev
git checkout -b feature/phase-2-products
```

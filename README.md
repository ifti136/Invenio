# Invenio — Inventory & Economy Tracker

A fully offline Flutter Android app for a single owner-operator small reseller to manage inventory, log sales, track expenses, and view profit analytics. No authentication, no cloud sync — just a clean, fast, local-first business tool.

## Features

### Products
- Create, edit, and delete products with name, cost price, and notes
- Restock with tracked stock movements (initial / restock / adjustment / sale)
- Per-product low-stock alerts and full stock history
- Searchable product list with stat cards (count, low stock, out of stock, total value)

### Sales
- Log sales with quantity, selling price, platform (Facebook / Offline), payment status (Paid / Due), and optional customer name
- Live profit preview before saving
- Below-cost and low-stock alert dialogs on save
- Margin drop detection vs. last sale
- Filterable sales list (date, platform, payment, product)
- Mark as paid, edit, and delete with confirmation

### Expenses
- Log expenses by category (Ads / Delivery / Packaging / Misc)
- Date-filtered list with monthly totals
- Feed into net profit calculations across all views

### Reports & Export
- Dashboard with today's stats (sales, revenue, gross/net profit, due, platform breakdown, low stock)
- Daily and monthly bar charts with revenue vs. profit
- Product-level performance report
- Excel export (Sales + Expenses + Summary sheets) via share

### Design
- Liquid Glass UI — `glass_kit` panels, aurora animated background, transparent scaffold
- Material 3 with custom color system
- 5-tab bottom navigation with glass chrome

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24.4, Dart 3.5.4 |
| Target | Android (min API 24) |
| Database | Drift (SQLite) — fully offline |
| State | Riverpod (codegen) |
| Routing | go_router (ShellRoute + 5 tabs) |
| Charts | fl_chart |
| Export | syncfusion_flutter_xlsio + share_plus |
| Theme | glass_kit + aurora_background |

## Getting Started

### Prerequisites
- Flutter SDK 3.24.4+ (`flutter --version`)
- Android Studio or VS Code with Flutter plugin
- An Android device or emulator (API 24+)

### Setup

```bash
# Clone the repo
git clone https://github.com/ifti136/Invenio.git
cd Invenio

# Install dependencies
cd tracker_app
flutter pub get

# Run code generation (Drift, Riverpod, go_router)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Build APK

```bash
cd tracker_app

# Release APK (universal)
flutter build apk --release

# Split APK by ABI (smaller per-device)
flutter build apk --split-per-abi --release

# App bundle (recommended for Play Store)
flutter build appbundle --release
```

The APK is output to `tracker_app/build/app/outputs/flutter-apk/`.

### Development Commands

```bash
cd tracker_app

# Code generation (Drift, Riverpod, go_router)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes (auto-regenerate)
dart run build_runner watch --delete-conflicting-outputs

# Static analysis
flutter analyze

# Run tests
# Pure-logic tests (no native deps needed):
flutter test test/unit/alert_service_test.dart test/unit/profit_calculation_test.dart

# Full suite (requires libsqlite3-dev on Linux):
sudo apt install libsqlite3-dev
flutter test --reporter expanded
```

## Project Structure

```
tracker_app/
├── lib/
│   ├── main.dart                        Entry point
│   ├── app.dart                         MaterialApp.router + aurora backdrop
│   ├── router.dart                      go_router: ShellRoute + 5 tabs + nested routes
│   ├── core/
│   │   ├── background/                  Aurora animated background
│   │   ├── theme/                       AppColors + AppTheme (light/dark)
│   │   ├── widgets/                     GlassPanel, GlassTextField, GlassDialog, etc.
│   │   └── utils/                       formatters (money, date, quantity)
│   ├── db/
│   │   ├── app_database.dart            Drift database + Riverpod provider
│   │   └── tables/                      Products, Sales, Expenses, StockMovements
│   ├── features/
│   │   ├── dashboard/                   Summary stats, platform breakdown
│   │   ├── products/                    CRUD, restock, stock movements
│   │   ├── sales/                       Log, filter, edit, mark as paid
│   │   ├── expenses/                    Log, filter, edit
│   │   └── reports/                     Charts, tables, export
│   ├── models/                          DashboardSummary, DailySnapshot, MonthlySummary
│   └── services/                        AlertService, ExportService
└── test/                                Test suite (see below)
```

## Testing

The test suite lives in `tracker_app/test/` with 15 files (~95 test cases):

```
test/
├── REPORT.md                  Test report with per-phase breakdown
├── unit/
│   ├── alert_service_test.dart        16 tests (pure logic)
│   ├── profit_calculation_test.dart   14 tests (pure functions)
│   ├── database_schema_test.dart      5 tests
│   ├── product_repository_test.dart   14 tests
│   ├── sale_repository_test.dart      10 tests
│   ├── expense_repository_test.dart   14 tests
│   ├── dashboard_provider_test.dart   4 tests
│   └── export_service_test.dart       3 tests
└── widget/
    ├── theme_test.dart                5 tests (pure theme)
    ├── chart_toggle_test.dart         4 tests (pure widget)
    ├── router_test.dart               2 tests
    ├── product_form_test.dart         2 tests
    ├── sale_form_test.dart            2 tests
    ├── expense_form_test.dart         4 tests
    └── dashboard_test.dart            2 tests
```

### Running Tests

```bash
cd tracker_app

# Pure-logic tests (no native deps needed)
flutter test test/unit/alert_service_test.dart test/unit/profit_calculation_test.dart

# All tests (requires libsqlite3-dev on Linux)
sudo apt install libsqlite3-dev
flutter test --reporter expanded
```

## Documentation

Detailed specs live in `instructions/`:

| File | Content |
|------|---------|
| `01_requirements.md` | Functional + non-functional requirements |
| `02_system_design.md` | Architecture, state management, routing |
| `03_code_specs.md` | Per-file code contracts |
| `04_scaffolding.md` | Initial project scaffold |
| `05_implementation.md` | Full implementation spec (active feature spec) |
| `06_completion_status.md` | Live checklist — updated after every build |

## License

Private. Not for redistribution.

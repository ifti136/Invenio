# Invenio — Inventory & Economy Tracker

Invenio is a solo-owner Flutter Android app for a small reseller to track
inventory, log sales, record expenses, and see daily profit — fully offline,
no auth, no cloud sync. It is one APK that installs and works on a phone
without ever touching the network, designed for a single person running
sales on Facebook Marketplace and in person.

## Features

### Products
- Create, edit, and delete products with name, cost price, and notes
- Restock with tracked stock movements (initial / restock / adjustment / sale)
- Per-product low-stock alerts and per-product alert toggle (on/off)
- Full stock-movement history per product
- Searchable product list with stat cards (count, low stock, out of stock, total value)

### Sales
- Log sales with quantity, selling price, platform (Facebook / Offline),
  payment status (Paid / Due), and optional customer name
- Live profit preview before saving
- Below-cost, low-stock, and margin-drop alerts
- Quick-sell bottom sheet per product (one tap from the product grid)
- Discounted sales (price + loss tracked separately)
- Filterable sales list (date range, platform, payment, product)
- Mark as paid, edit, and delete with confirmation

### Expenses
- Log expenses by category (Ads / Delivery / Packaging / Misc)
- Date-filtered list with monthly totals and preset ranges
- Feeds into net profit calculations across all report views

### Reports & Export
- Dashboard with today's stats (sales, revenue, gross/net profit, due,
  platform breakdown, low stock)
- Daily, monthly, and product bar charts with revenue vs. profit
- Product-level performance report
- Excel export (Sales + Expenses + Summary sheets) via the Android share sheet

### BFMS (Budget & Financial Management)
- Multi-wallet tracking (Cash, Bank, etc.)
- Automated allocation rules for sales revenue
- Budget buckets for expense tracking and financial planning

### Design
- Liquid Glass UI — `glass_kit` panels + animated aurora background
- Material 3 with a custom color system (teal `#1D9E75` accent)
- 6-tab bottom navigation with glass chrome
- Custom launcher icon and splash screen

## Tech stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24.4, Dart 3.5.4 |
| Target | Android (min API 24) |
| Database | drift (SQLite) — fully offline, schema v4 |
| State | Riverpod (codegen) |
| Routing | go_router 15 — `StatefulShellRoute.indexedStack` (6 tabs) |
| Charts | fl_chart 0.69 |
| Export | syncfusion_flutter_xlsio 27.1.55 + share_plus |
| Theme | glass_kit 4.0.2 + aurora_background 1.0.2 |
| Icons | flutter_launcher_icons 0.14.4 |

## Getting started

### Prerequisites
- Flutter SDK 3.24.4+ (`flutter --version`)
- Android Studio or VS Code with the Flutter plugin
- An Android device or emulator (API 24+)

### Setup

```bash
git clone https://github.com/ifti136/Invenio.git
cd Invenio/tracker_app

flutter pub get
dart run build_runner build --delete-conflicting-outputs
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

## Project structure

```
Invenio/
├── README.md                  ← you are here
├── AGENTS.md                  ← AI-agent conventions (opencode)
├── docs/                      ← full documentation (start at docs/README.md)
│   ├── README.md
│   ├── ARCHITECTURE.md        ← human-readable one-pager
│   ├── CHANGELOG.md           ← phase log + bug list
│   ├── HISTORY.md             ← per-phase regression narrative
│   ├── DESIGN.md              ← visual design spec
│   └── instructions/          ← pre-implementation specs
└── tracker_app/
    ├── README.md              ← pointer to root README + docs
    ├── lib/                   ← Dart source (see folder map in ARCHITECTURE.md)
    ├── test/                  ← 8 unit + 7 widget test files + REPORT.md
    ├── assets/icon/           ← launcher icon source (invenio.png)
    ├── pubspec.yaml
    └── android/               ← Android Gradle config; min SDK 24
```

## Documentation

The full documentation is in [`docs/`](docs/README.md). Start with
[`docs/README.md`](docs/README.md) — it is the index and tells you which
doc to read for what.

| If you want to … | Read |
|---|---|
| Understand the project in 5 minutes | [`docs/README.md`](docs/README.md) |
| See the key tech choices and trade-offs | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| See what was built, in order | [`docs/CHANGELOG.md`](docs/CHANGELOG.md) |
| Understand what broke and why | [`docs/HISTORY.md`](docs/HISTORY.md) |
| Look up a color or screen layout | [`docs/DESIGN.md`](docs/DESIGN.md) |
| Read the detailed specs (requirements, design, code contracts, scaffold, implementation) | [`docs/instructions/`](docs/instructions/) |
| Check the test status and known limitations | [`tracker_app/test/REPORT.md`](tracker_app/test/REPORT.md) |
| Get oriented as an AI coding agent | [`AGENTS.md`](AGENTS.md) |

## Testing

The test suite lives in `tracker_app/test/` — 8 unit files + 7 widget files,
**100 / 100 passing** in the current state. See
[`tracker_app/test/REPORT.md`](tracker_app/test/REPORT.md) for the per-file
breakdown, the `libsqlite3.so` symlink trick for Linux CI, and the
`glass_kit` / `aurora_background` headless workarounds.

```bash
cd tracker_app

# Pure-logic tests (no native deps needed)
flutter test test/unit/alert_service_test.dart test/unit/profit_calculation_test.dart

# Full suite (requires libsqlite3.so; see test/REPORT.md for the Linux symlink)
flutter test --reporter expanded
```

## License

Private. Not for redistribution.

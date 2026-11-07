# Invenio — Inventory & Money Tracker

Invenio is a solo-owner Flutter Android app for a small reseller to manage
inventory, log sales, track money and expenses, and view profit analytics.
It is fully offline — no auth, no cloud sync — and ships as one APK that works
on a phone without ever touching the network.

Version **3.6.7+27** · Clean Ledger design · Schema v8 (13 tables).

Releases follow phase-based sub-sub-versioning, **`v3.<phase>.<change>`**:
`v3.0.0` is the Clean Ledger baseline, Phase 0 changes are `v3.0.x`, and each
later phase starts its own series (`v3.1.1`, `v3.2.1`, … `v3.6.1`). See
[`docs/CHANGELOG.md`](docs/CHANGELOG.md) for the full history.

## Features

### Home
- Total money, per-account chips, dues, and low-stock count
- Today's sales, revenue, and profit with tap-through deep links
- Setup and zero-state cards with a primary action

### Inventory
- Product catalog with search, low/out-of-stock filters, and stat cards
- Add/edit products with price, cost, stock, low-stock threshold, and notes
- Product detail with a merged stock/purchase timeline
- Restock with optional cash-out from an account
- Stock movements: initial, restock, adjustment, sale

### Sales
- Quick Sell in one line, plus a full multi-line cart
- Editable prices, discounts, below-cost and above-stock warnings
- Paid in full / Part / Later, customer create-on-the-fly, and account routing
- Atomic save: sale, cost-snapshotted lines, stock moves, and payments
- Day-grouped sales log with search and date/channel/status filters
- Sale detail with record payment, share receipt, edit, delete, and undo

### Money
- Accounts with derived live balances and a running ledger
- Transfers between accounts without touching profit
- Balance adjustments with a visible ledger entry
- Dues grouped by customer with FIFO or sale-specific payments
- Expenses with categories, account deduction, filters, and monthly totals

### Reports
- Week, month, year, and custom ranges
- Profit & loss, margin, trend chart, and product/channel breakdowns
- CSV export of sales, line items, payments, expenses, and balances
- SQLite backup export and daily automatic local backup

### Design & accessibility
- Clean Ledger Material 3: flat tonal surfaces, 1 px outlines, teal
  `#1D9E75`, light/dark/system
- No blur, gradients, shadows, or animated backgrounds
- Every content screen has loading, empty, filtered-empty, and error states
- 200% text scale verified on a 360 dp viewport; contrast-tested tokens

## Tech stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.24.4, Dart 3.5.4 |
| Target | Android (min API 24) |
| Database | drift (SQLite), schema v8 (13 tables) |
| State | Riverpod |
| Routing | go_router 15 — `StatefulShellRoute.indexedStack` (5 tabs) |
| Charts | fl_chart 0.69 |
| Export | CSV + SQLite file via `share_plus` |
| Prefs | `shared_preferences` |
| Icons | `flutter_launcher_icons` |

Money is always stored as integer minor units and rendered through `Money`.
No `double`/`REAL` money columns.

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

# App bundle
flutter build appbundle --release
```

The APK is written to `tracker_app/build/app/outputs/flutter-apk/`.

## Testing

The suite lives in `tracker_app/test/` and is currently **58 / 58 passing**
with `flutter analyze` clean. See
[`tracker_app/test/REPORT.md`](tracker_app/test/REPORT.md) for the per-file
breakdown and the Linux `libsqlite3.so` workaround.

```bash
cd tracker_app

# Linux: make sqlite3 resolvable for drift tests
ln -sf /usr/lib64/libsqlite3.so.0 /tmp/libsqlite3.so

LD_LIBRARY_PATH=/tmp flutter test --reporter expanded
```

## Project structure

```
Invenio/
├── README.md                  ← you are here
├── docs/                      ← full documentation (start at docs/README.md)
│   ├── README.md              ← index
│   ├── ARCHITECTURE.md        ← tech choices and folder map
│   ├── CHANGELOG.md           ← consolidated release history
│   ├── DESIGN.md              ← Clean Ledger visual spec
│   └── invenio overhaul.pdf   ← master spec (v2.3)
├── .planning/ROADMAP.md       ← Phase 0–6 plan
└── tracker_app/
    ├── README.md              ← app pointer
    ├── lib/                   ← Dart source
    ├── test/                  ← unit + widget tests + REPORT.md
    ├── assets/icon/           ← launcher icon source
    ├── pubspec.yaml
    └── android/               ← Android Gradle config; min SDK 24
```

## Documentation

Start with [`docs/README.md`](docs/README.md).

| If you want to … | Read |
|---|---|
| Understand the project in 5 minutes | [`docs/README.md`](docs/README.md) |
| See the key tech choices and trade-offs | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| See what shipped, in order | [`docs/CHANGELOG.md`](docs/CHANGELOG.md) |
| Look up a color, spacing token, or screen layout | [`docs/DESIGN.md`](docs/DESIGN.md) |
| Check test status and known limitations | [`tracker_app/test/REPORT.md`](tracker_app/test/REPORT.md) |

## Known limitations

- SQLite **restore** is not implemented; export and daily backups are.
  Restore needs an approved file-picker dependency.
- The app has not been verified on a physical device from this environment.
- No cloud sync, barcode scanning, invoices, or push notifications by design.

## License

MIT License. See [`LICENSE`](LICENSE).

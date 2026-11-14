# Invenio — tracker_app

The Flutter app for [Invenio](../README.md), an inventory and money tracker
for a single owner-operator small reseller. Fully offline, Android min SDK 24.

The root README is the canonical entry point for features, setup, and build
instructions. Design and architecture live at the repo root:
[`../DESIGN.md`](../DESIGN.md) and [`../ARCHITECTURE.md`](../ARCHITECTURE.md).

## Version

Current: **3.7.1+31** · Clean Ledger · Schema v8 (13 tables). Releases follow
`v3.<phase>.<change>` (base `v3.0.0`); release history lives in git history.

## What is in this app

- Five tabs: Home, Sales, Inventory, Money, Reports; Settings from Home.
- Product catalog, stock timeline, and restock with cash-out.
- Quick Sell and a full multi-line cart with atomic saves.
- Accounts, ledger, transfers, dues, and expenses.
- Dashboard, P&L reports, charts, CSV export, and SQLite backups.
- Material 3 Clean Ledger theme with light, dark, and system modes.
- Runtime art in `assets/` (app mark, nav, illustrations, splash); launcher
  layers and source art live in [`branding/`](branding/README.md).

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Test

```bash
# Linux: make sqlite3 resolvable for drift tests
ln -sf /usr/lib64/libsqlite3.so.0 /tmp/libsqlite3.so

LD_LIBRARY_PATH=/tmp flutter test --reporter expanded
```

Current status: **63 / 63 passing**; `flutter analyze` clean. See
[`test/REPORT.md`](test/REPORT.md).

# Invenio — tracker_app

The Flutter app for [Invenio](../README.md), an inventory and money tracker
for a single owner-operator small reseller. Fully offline, Android min SDK 24.

The root README is the canonical entry point for features, setup, and build
instructions. Full documentation is in [`../docs/`](../docs/README.md).

## Version

Current: **3.6.6+26** · Clean Ledger · Schema v8 (13 tables). Releases follow
`v3.<phase>.<change>` (base `v3.0.0`); see [`../docs/CHANGELOG.md`](../docs/CHANGELOG.md).

## What is in this app

- Five tabs: Home, Sales, Inventory, Money, Reports; Settings from Home.
- Product catalog, stock timeline, and restock with cash-out.
- Quick Sell and a full multi-line cart with atomic saves.
- Accounts, ledger, transfers, dues, and expenses.
- Dashboard, P&L reports, charts, CSV export, and SQLite backups.
- Material 3 Clean Ledger theme with light, dark, and system modes.

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

Current status: **58 / 58 passing**; `flutter analyze` clean. See
[`test/REPORT.md`](test/REPORT.md).

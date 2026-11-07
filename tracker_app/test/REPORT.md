# Test Report — Invenio (tracker_app)

**Date:** 2026-11-06
**Flutter SDK:** 3.24.4 · **Dart:** 3.5.4
**Status:** **58 / 58 passing** · `flutter analyze` clean.

## Summary

- Unit tests: **53 / 53**
- Widget tests: **9 / 9** (including 5 at 200% text scale)
- Total: **58 / 58** — full pass

The suite is fully offline and uses in-memory drift databases. No network,
emulator, or device is required.

## Layout

```
test/
├── unit/
│   ├── money_test.dart                  6 — minor units, parsing, arithmetic, formatting
│   ├── database_schema_test.dart        5 — v8, 13 tables, seeds, integer money columns
│   ├── inventory_sales_test.dart        7 — restock overdraw guard, quick sell, multi-line stock, cost snapshots, undo
│   ├── sales_cart_test.dart             6 — merge, atomic save, failure, edit, delete/restore
│   ├── money_accounts_test.dart         4 — balances, transfers, profit neutrality, periods
│   ├── dues_test.dart                   4 — grouping, FIFO, sale-specific, overpayment guard
│   ├── expenses_test.dart               5 — balance/ledger, edit, delete/restore, negative guard, dates
│   ├── reports_test.dart                8 — dashboard, P&L, breakdowns, ranges, CSV
│   └── contrast_test.dart               4 — 4.5:1 text and 3:1 outline in light/dark
└── widget/
    ├── empty_state_test.dart            2 — content + primary action, action hidden
    ├── router_test.dart                 1 — 5-tab Clean Ledger shell
    ├── first_run_test.dart              1 — setup saves a payment source and completes
    └── text_scale_test.dart             5 — Home, Sales, Inventory, Money, Reports at 200%
```

## Running the suite

```bash
cd tracker_app

# Linux only: make sqlite3 resolvable for drift tests
ln -sf /usr/lib64/libsqlite3.so.0 /tmp/libsqlite3.so

LD_LIBRARY_PATH=/tmp flutter test --reporter expanded
```

### Why the Linux symlink

Drift-backed tests use `AppDatabase.forTesting(NativeDatabase.memory())`.
On many Linux distributions the native `sqlite3` library is not on the
loader path, so the test binary cannot start. Either install it system-wide
(`sudo apt install libsqlite3-dev`) or use the symlink above. macOS and
Windows include the library with Flutter / `sqlite3_flutter_libs`.

## Coverage notes

- **Money safety:** every monetary column is integer minor units; `Money`
  owns parsing and formatting. Tests cover negatives and locale formatting.
- **Atomic sales:** a failed multi-line sale leaves no partial rows; a
  successful sale drops every product's stock and snapshots each cost.
- **Historical profit:** editing a product's cost after a sale does not change
  the saved line cost or the reported profit.
- **Derived balances:** opening balance + payments − expenses − paid restocks
  + net transfers + adjustments, with transfers excluded from profit.
- **Dues:** FIFO allocation by default, sale-specific payments, and an
  overpayment guard.
- **Reports:** revenue, COGS, expenses, gross/net profit, margin, bucket
  filling, and CSV escaping including commas, quotes, CR, and LF.
- **Accessibility:** 200% text scale on a 360 dp viewport pumps the five key
  screens and asserts no render exception; contrast tests check 4.5:1 text
  and 3:1 outline pairs in light and dark.

## Known limitations

- **Restore is not implemented.** Export and daily local backups work; a
  file-picker dependency is required before restore can ship.
- **No device run in this environment.** `flutter test` and `flutter analyze`
  are green, but launcher icon, splash, share sheet, and file export should
  be verified with `flutter run -d <device>`.
- No cloud sync, barcode scanning, invoicing, or push notifications by design.

## Manual verification still recommended

- [ ] Launch and first-run setup on a real device
- [ ] Product add/edit, restock with cash-out, and stock history
- [ ] Quick Sell, multi-line sale, part payment, edit, delete/undo
- [ ] Account ledger, transfer, adjustment, expense, and dues payment
- [ ] Reports ranges, chart, breakdowns, and CSV share sheet
- [ ] Manual backup export and daily backup file
- [ ] Light, dark, and system themes at normal and 200% font scale

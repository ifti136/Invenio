# Architecture

A short, opinionated overview of the technical decisions behind Invenio,
written for a reviewer who wants to know *why* the codebase looks the way it
does. Pair this with [`CHANGELOG.md`](CHANGELOG.md) (what shipped) and
[`DESIGN.md`](DESIGN.md) (the visual system).

---

## What this is

A solo-owner Flutter Android app for a small reseller. It tracks inventory,
logs sales, tracks money and expenses, and computes profit. No login, no
cloud, one user, one device, one local database. The APK installs and works
offline.

## Why offline-first

The target user runs a small operation from their phone, often in
environments with poor connectivity. They are the only person who will see
the data, so a backend would add latency, cost, and a privacy surface for no
benefit. The local SQLite database is the source of truth. The schema is
normalized enough that a future sync layer could be added, but sync is not on
the roadmap.

## Why Drift (SQLite)

- **Typed queries** — the schema is checked at compile time through
  `drift_dev` codegen, so a column typo is a build error.
- **Migrations are first-class** — `schemaVersion` plus `onUpgrade` keeps
  schema changes auditable. The v3 overhaul treats the app as new (fresh
  schema v7, no legacy import) and later added v8 for the `adjustments` table.
- **Reactive streams** — `select(...).watch()` emits whenever rows change,
  which pairs cleanly with Riverpod `StreamProvider` for a live UI without
  polling or manual invalidation.
- **SQL is the right tool** — profit reports, monthly aggregations, and
  top-N queries are straightforward in SQL.

## Why Riverpod

- Reactive dependency injection without `BuildContext` reads.
- Repositories and services stay UI-agnostic and testable.
- Family providers parameterise queries (sale by id, product by id,
  report by range).
- `appDatabaseProvider` is kept alive for the app lifetime; screen data
  providers dispose with their listeners.
- The cart lives in the root provider scope so a Quick Sell can hand off to
  the full New Sale form.

## Why go_router with `StatefulShellRoute.indexedStack`

- Declarative routes and deep links are first-class.
- `indexedStack` keeps the five tab branches mounted, preserving scroll
  position and provider state across tab switches.
- Nested routes express detail/edit screens naturally, for example
  `/inventory/:id`, `/sales/:id`, `/money/accounts/:id`, and
  `/money/dues/:customerId`.

## Money rules

- All money is stored as **integer minor units** (`int`); never `double` or
  `REAL`.
- The `Money` value class owns parsing, arithmetic, formatting, and negative
  handling. UI renders through `MoneyText`.
- The currency symbol comes from `settings.currency_symbol` through a
  reactive provider, with `৳` as the fallback.
- Sale line items snapshot `unit_cost_minor`, so later product cost edits do
  not rewrite historical profit.

## Data model (schema v8)

13 tables:

`products`, `stock_movements`, `sales`, `sale_items`, `payments`,
`customers`, `channels`, `accounts`, `transfers`, `expenses`,
`expense_categories`, `settings`, `adjustments`.

Key invariants:

- Account balances are derived: opening balance + payments − expenses − paid
  restocks + net transfers + adjustments. There is no stored balance column.
- Transfers move money between accounts and never affect revenue or profit.
- Paid restocks reduce cash but are inventory cost, not an expense.
- Dues are unpaid sale balances grouped per customer; payments apply FIFO by
  default or to a chosen sale.
- Multi-line sales, their line items, stock movements, and payments are
  written in one transaction.

## UI architecture

- One `AppTheme` from `ColorScheme.fromSeed(0xFF1D9E75)` with light, dark,
  and system modes. No theme picker or theme enums.
- Clean Ledger: flat tonal surfaces, 1 px outlines, Material 3 components,
  4/8/12/16/24/32 spacing, 16 px cards, 12 px buttons/inputs, 24 px hero,
  28 px sheets.
- Every content screen implements loading, true-empty (icon + title +
  sentence + primary action), filtered-empty (Clear filters), and error
  (Retry) states.
- Hero money uses `FittedBox` and chips/badges scale down internally so the
  UI survives 200% font scale on a 360 dp viewport.

## Backups and export

- `BackupService` checkpoints WAL and copies the SQLite file; a daily copy
  is written under the app documents directory. Manual export shares the file
  through `share_plus`.
- CSV export is pure Dart and quotes commas, quotes, CR, and LF. It writes
  sales, sale items, payments, expenses, and derived balances, and reports
  “no data” instead of producing empty files.
- Restore is intentionally deferred until a file-picker dependency is
  approved.

## Known trade-offs

| Trade-off | Detail |
|---|---|
| No restore picker | Export and daily backups work; restore needs an approved dependency. |
| No cloud sync | Deliberate: single user, offline-first. |
| Linux test prerequisite | Drift tests need `libsqlite3.so`; see [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md). |
| No barcode / invoicing / push | Explicitly out of scope. |
| Device verification | The suite is green, but the app has not been run on a physical device from this environment. |

## Folder map

```
tracker_app/
├── lib/
│   ├── main.dart              — entry point; wraps the app in ProviderScope
│   ├── app.dart               — MaterialApp.router, theme, first-run gate
│   ├── router.dart            — go_router StatefulShellRoute (5 tabs)
│   ├── core/
│   │   ├── money/             — Money value class
│   │   ├── theme/             — AppColors, AppTheme, tokens
│   │   ├── utils/             — date periods and input parsing
│   │   └── widgets/           — EmptyState, MoneyText, tiles, chips
│   ├── db/                    — drift database, 13 table definitions, codegen
│   ├── features/
│   │   ├── home/              — dashboard and today aggregates
│   │   ├── inventory/         — products, detail timeline, restock
│   │   ├── sales/             — cart, saveSale, log, detail, receipts
│   │   ├── money/             — accounts, ledger, transfers, dues, expenses
│   │   ├── reports/           — ranges, P&L, charts, breakdowns, CSV
│   │   ├── settings/          — settings hub, sources, names, backup
│   │   └── onboarding/        — first-run setup
│   └── services/              — backup service
├── test/                      — unit + widget tests; see REPORT.md
├── assets/icon/               — launcher icon source
└── android/                   — Android Gradle config; min SDK 24
```

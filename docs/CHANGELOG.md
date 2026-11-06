# Changelog

All notable changes to Invenio, newest first. This file is the single source
of truth for release history; the former `HISTORY.md` and `VERSION_HISTORY.md`
were folded into it, and pre-overhaul narrative remains in git history.

Current release: **v3.6.3+23** · Schema **v8** (13 tables).

## Versioning

Releases use phase-based sub-sub-versioning: **`v3.<phase>.<change>`**.

- `v3.0.0` is the Clean Ledger overhaul baseline.
- Phase 0 changes are `v3.0.1`, `v3.0.2`, …
- Phase 1 starts at `v3.1.1`, Phase 2 at `v3.2.1`, … Phase 6 at `v3.6.1`.
- The scheme was applied retroactively to the Phase 0–6 history below.

---

## Phase 6 — Polish & QA

### v3.6.3 — Documentation consolidation and phase-based versioning
- Consolidated `HISTORY.md` and `VERSION_HISTORY.md` into this changelog and
  removed the old files.
- Adopted `v3.<phase>.<change>` and applied it retrospectively from `v3.0.0`
  through this release.
- Refreshed the root and app READMEs, docs index, architecture notes, project
  state, decision log, and test report.
- Version `3.6.3+23`.

### v3.6.2 — Contrast, 200% font scale, and final QA
- Added contrast tests for every light and dark text/surface pair at 4.5:1 and
  for `outline` on `surface` at 3:1; tuned warning and tertiary tokens.
- Added 200% text-scale widget coverage on a 360 dp viewport for Home, Sales,
  Inventory, Money, and Reports.
- Fixed overflows with `FittedBox`, `Wrap`, flexible rows, and horizontally
  scrollable segmented controls in product tiles, stock/status chips, hero
  money, report tables, P&L rows, account rows, and payment/theme selectors.
- Added semantic labels and tooltips for quantity steppers.
- Added final QA tests for atomic multi-line stock drops and cost-snapshotted
  profit.
- `flutter analyze` clean; **57 / 57 tests passing**.

### v3.6.1 — Required states and accessibility fixes
- Audited every content screen for loading, true-empty, filtered-empty (Clear
  filters), and error (Retry) states.
- Reworked Home's today card error state into a clear message with a `Retry`
  action.
- Kept empty states first-class: icon, title, one sentence, and a primary
  action, with no blank screens.

---

## Phase 5 — Home & Reports

### v3.5.3 — CSV export
- Escaped CSV export of sales, line items, payments, expenses, and derived
  balances through the Android share sheet.
- Reports "no data" instead of writing an empty file.
- SQLite backup export and daily automatic local backup.

### v3.5.2 — Reports P&L, chart, and breakdowns
- Week, month, year, and custom ranges.
- Profit & loss, margin, trend chart, and product/channel breakdowns.
- Empty and filtered-empty states for every report section.

### v3.5.1 — Reactive home dashboard
- Total money, account chips, customer dues, and low-stock count.
- Today's sales, revenue, and profit cards with tap-through deep links.
- Setup and zero-state cards with a primary action.

---

## Phase 4 — Money & Expenses

### v3.4.4 — Operating expenses
- Expenses with categories, account deduction, day-precision dates, filters,
  monthly totals, edit, delete, and undo.

### v3.4.3 — Customer dues and reminders
- Dues grouped by customer with FIFO or sale-specific payments.
- Shareable reminders and per-customer detail.

### v3.4.2 — Account ledger and adjustments
- Running-balance ledger with This month / Last month / This year / All time
  periods.
- Balance adjustments stored in the `adjustments` table and shown in the
  ledger.

### v3.4.1 — Accounts overview and transfers
- Derived account balances: opening balance + payments − expenses − paid
  restocks + net transfers + adjustments. No stored balance column.
- Transfers with same-account and negative-source guards; transfers never
  change profit.

---

## Phase 3 — Sales

### v3.3.4 — Sales log, detail, payments, receipts, edit, and delete
- Day-grouped sales log with search and date/channel/status filters.
- Sale detail with record payment, share receipt (no cost or profit shown),
  edit, and delete with undo.

### v3.3.3 — Quick Sell
- One-line Quick Sell with undo.
- Hand-off from Quick Sell into the full multi-line cart.

### v3.3.2 — Product picker and new sale form
- Searchable product picker with inline quantity selection.
- Paid in full / Part / Later, customer selection with inline create, and
  account selection for received money.
- Editable prices, discounts, and above-stock/below-cost warnings.

### v3.3.1 — Cart and atomic `saveSale`
- `CartController` with per-product merge and edit-sale seeding.
- Atomic transaction writes the sale, cost-snapshotted line items, stock
  movements, and payments; edit restores prior stock and re-applies.

---

## Phase 2 — Inventory

### v3.2.3 — Restock and cash out
- Restock with optional cash-out from an account.
- Stock movements: `initial`, `restock`, `adjustment`, `sale`; restock updates
  last cost and never writes an expense.

### v3.2.2 — Product form and detail timeline
- Add/edit product form with price, cost, stock, low-stock threshold, and
  notes.
- Product detail with a merged stock/purchase timeline and archived handling.

### v3.2.1 — Inventory repository and list
- Reactive product repository and providers.
- Catalog with search, low/out-of-stock filters, and stat cards.

---

## Phase 1 — Foundation & Shell

### v3.1.4 — First-run setup and full settings
- First-run setup for shop name, currency, and first payment source.
- Settings hub: shop name, payment sources, channels, categories, currency,
  theme mode, manual export, daily auto-backup toggle, CSV export, and a
  double-confirmed clear-all-data.

### v3.1.3 — Five-tab shell, routing, and empty states
- Five-tab `StatefulShellRoute.indexedStack`: Home, Sales, Inventory, Money,
  Reports. Settings opens from the Home app bar.
- Shared empty-state widget and screen-level loading/error scaffolding.
- Deep links into filtered screens.

### v3.1.2 — Shared widgets
- `EmptyState`, `MoneyText`, product tiles, status/stock chips, sale bars, and
  money/section cards.
- Flat tonal cards and sheets with 1 px outlines.

### v3.1.1 — Material 3 theme and tokens
- One `AppTheme` from `ColorScheme.fromSeed(0xFF1D9E75)` with light, dark, and
  system modes; no theme picker or theme enums.
- Clean Ledger tokens: 4/8/12/16/24/32 spacing, 16 px cards, 12 px
  buttons/inputs, 24 px hero, 28 px sheets, pill chips.
- Retired multi-theme migration logic.

---

## Phase 0 — Foundation

### v3.0.3 — Fresh schema and backup service
- Fresh database at `invenio_v7.sqlite` (schema v7), later advanced to v8
  with the `adjustments` table; 13 tables, seeded channels/categories/settings.
- No legacy-data migration.
- Backup service: WAL checkpoint + SQLite export via `share_plus`, plus a
  daily local backup. Restore intentionally deferred.

### v3.0.2 — Money value class and formatting
- `Money` value class: integer minor units only, arithmetic, parsing, and
  locale formatting.
- Reactive currency symbol from settings with a `৳` fallback.
- `MoneyText` renders with tabular figures.

### v3.0.1 — Remove Liquid Glass and old UI
- Removed `glass_kit`, `aurora_background`, and
  `syncfusion_flutter_xlsio`.
- Deleted the aurora backdrop, glass panels, four-theme picker, and old
  Liquid Glass screens.
- Excel export replaced by CSV; SQLite file export uses `share_plus`.

### v3.0.0 — Clean Ledger baseline
- Adopted `docs/invenio overhaul.pdf` (v2.3) as the master spec.
- Rewrote `docs/DESIGN.md` for Clean Ledger and marked Liquid Glass
  superseded.
- Greenfield rebuild on top of the existing Flutter project.

---

## Earlier history

Pre-overhaul releases are condensed here; full detail lives in git history.

- **v2.1.2+19** — Fixed the blank gray launch screen by always returning a
  `MaterialApp`-family root, adding a fail-open walkthrough init gate and
  regression tests.
- **v2.1.1+18** — First-run walkthrough with shop-name capture, MIT license,
  root/app READMEs.
- **v2.1.0+17** — About section.
- **v2.0.0+16** — POS-style restyle: teal `#1D9E75`, rounded cards, 5-slot
  nav, receipt sheet, BDT default.
- **v1.6.1+15** — Theme cleanup, expense-form layout fix, contrast fixes.
- **v1.6.0+14** — Glassmorphism restoration and a four-theme system.
- **v1.4.0–v1.5.1** — Wallet transfers, finance tab, routing fixes.
- **v0.1.0–v1.3.3** — Initial Liquid Glass build, products/sales/expenses,
  budgets, reports, Excel export, and the glass layout fixes that followed.

Liquid Glass is retired. Its implementation and regression history live only
in git history before `v3.0.0`.

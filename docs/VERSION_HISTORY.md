# Version History

A complete log of every version of Invenio, from initial scaffold to the current
build. Each entry maps to one or more git commits. Dates are commit-author dates.

**Current version:** `1.3.2+5` · Schema v5 · 9 tables · 100/100 tests passing

---

## Pre-release

### v0.0.1 — Foundation
**Date:** 2026-06-02  
**Commit:** `c30860e` / `f0151c5`

- Initial Flutter scaffold with `flutter create`
- 4 Drift tables: `Products`, `Sales`, `Expenses`, `StockMovements` (Schema v1)
- `AppDatabase` with `NativeDatabase.createInBackground`, Riverpod singleton
- go_router `ShellRoute` with 5 bottom tabs: Dashboard, Products, Sales, Expenses, Reports
- Material 3 light + dark theme seeded from teal accent (`#1D9E75`)
- Placeholder screens for all 5 tabs

---

### v0.1.0 — Liquid Glass Theme
**Date:** 2026-06-02  
**Commit:** `83280c9` / `14153a2`

- Added `glass_kit: ^4.0.2` + `aurora_background: ^1.0.2`
- `AuroraBackdrop` widget — 3 animated waves (teal, indigo, magenta)
- `GlassPanel` / `GlassPanel.flush` — frosted + non-frosted variants
- `GlassTextField` — `TextFormField`-backed with validator / input formatters
- `showGlassDialog<T>()` + `GlassDialogAction<T>` — typed return values
- Material 3 theme with transparent `scaffoldBackgroundColor`
- Floating glass bottom nav (`kBottomNavHeight = 76` cap for `glass_kit` workaround)
- `kBottomNavClearance = 100` exposed for inner scroll lists
- 🐛 **Known bug:** Bottom nav renders full-screen (glass_kit `SizedBox.expand`)
- 🐛 **Known bug:** Body hidden under aurora on device

---

### v0.2.0 — Products
**Date:** 2026-06-02  
**Commit:** `09c9d45` / `24b3486`

- Product CRUD with name, cost price, initial stock, optional note
- Per-product low-stock threshold (default 3) and alert toggle
- Restock with tracked stock movements (initial / restock / sale / adjustment)
- Searchable product list with stat cards (count, low, out, value)
- Recent sales + stock-movement history per product

---

### v0.3.0 — Sales
**Date:** 2026-06-03  
**Commit:** `927b7eb` / `a2d1472`

- Sale log with product, quantity, selling price, platform (Facebook / Offline), payment status (Paid / Due), customer name
- Live total + estimated profit preview before save
- Below-cost, low-stock, and margin-drop alerts via `AlertService`
- Filterable sales list (date range, platform, payment, product)
- Mark as paid, edit, delete (with confirmation)

---

### v0.4.0 — Expenses
**Date:** 2026-06-03  
**Commit:** `f6cf35e`

- Expense CRUD with category enum (Ads / Delivery / Packaging / Misc)
- Date-filter bar with presets (Today, This week, This month, etc.) and custom range picker
- Monthly totals display
- Feeds into net profit in all report views

---

### v0.5.0 — Reports & Export
**Date:** 2026-06-03  
**Commit:** `de53049`

- Dashboard with today's stats (sales, revenue, gross/net profit, due, platform breakdown, low stock)
- Daily, monthly, and product bar charts via `fl_chart 0.69`
- Excel export (`syncfusion_flutter_xlsio 27.1.55`) with 3 sheets: Sales, Expenses, Summary (gross/net profit, platform split, top 5 products)
- Share via `share_plus`

---

### v0.5.1 — Bug Fixes (BUG-001 to BUG-009)
**Date:** 2026-06-03  
**Commit:** `ba726f9`

- Fixed Excel export missing Summary sheet (BUG-001)
- Fixed Mark-as-paid invalidating wrong provider (BUG-002)
- Fixed edit routes conflicting with detail routes (BUG-003)
- Fixed margin-drop threshold from 15pp to 10pp (BUG-004)
- Fixed deleted sale leaving ghost stock movement (BUG-005)
- Fixed `lastSellingPrice` returning `Sale?` instead of `double?` (BUG-006)
- Fixed `_LowStockSection` extending `ConsumerWidget` unnecessarily (BUG-007)
- Fixed `dateAsDateTime` scoped to one file instead of shared (BUG-008)
- Legacy boilerplate test replaced with smoke test (BUG-009)

---

### v0.5.2 — Bug Fixes (BUG-010 to BUG-016) + Test Suite
**Date:** 2026-06-03  
**Commit:** `e16f679`, `cd17cc1`, `f93eb87`, `034663e`, `5ca4a17`

- Fixed `/sales/:id` rendering the wrong screen (BUG-010)
- Fixed low-stock tiles not tappable (BUG-011)
- Fixed stacked `BackdropFilter` in forms → GPU jank (BUG-012)
- Fixed search using raw `TextField` instead of `GlassTextField` (BUG-013)
- Fixed dead ternary in stats (BUG-014)
- Fixed export targeting wrong month on yearly tab (BUG-015)
- Fixed cascade operator misuse in export sort/take (BUG-016)
- Full test suite: **100/100 passing** (8 unit + 7 widget files)
- Comprehensive README with features, setup, and testing guide
- Dep upgrades, Android toolchain changes, BUG_REPORT.md

---

### v0.6.0 — Liquid Glass Visual Alignment
**Date:** 2026-06-04  
**Commit:** `2d0ba48`

- `SheetDragHandle` widget extracted (40×4 px pill, shared across all bottom sheets)
- `ChipThemeData` added; product-list filter chips themed teal on select
- Sheet chrome (radius / margin / padding) aligned to DESIGN.md on Quick Sell, Discount, Product Filter, and Restock sheets
- 🐛 **Known bug:** All form screens render blank (glass_kit `SizedBox.expand`)

---

### v0.6.1 — Layout Diagnostic Placeholders
**Date:** 2026-06-05  
**Commit:** `c4c16ed`

- Added `DebugBorders`, `DebugAppBar`, `kDebugLayout` toggle across all screens
- `TEST TAP` `FilledButton`s on every screen for diagnosing render regions
- Debug overlays on every `GlassPanel`, `GlassTextField`, and `+` button
- **Not a fix** — diagnostics only; all removed in v0.6.4

---

### v0.6.2 — Form-Screen Blank Fix (H1+H2+H3)
**Date:** 2026-06-05  
**Commit:** `5bea30a`

- Added `GlassPanel.noBlur` constructor flag (defaults to `false`)
- Applied `noBlur: true` to all 3 form-level `GlassPanel`s
- Added `DebugContainer` widget for tight intrinsic-size contexts
- Added FORM (purple) and LIST (cyan) diagnostic borders
- 🐛 **New bug:** GlassTextField itself still collapses in unbounded parents

---

### v0.6.3 — GlassTextField Permanent Fix
**Date:** 2026-06-05  
**Commit:** `6bd54d3`

- Root cause: `glass_kit`'s `GlassContainer` wraps child in `SizedBox.expand` → 0×0 in unbounded parents
- Permanent fix: `GlassTextField`'s internal `GlassPanel` gets `noBlur: true`, rendering as plain `Container`
- Restored `Column(crossAxisAlignment: stretch)` on all 3 form panels
- `flutter analyze` 0 issues · `flutter test` 100/100

---

### v0.6.4 — Cleanup & DB Integration
**Date:** 2026-06-05  
**Commit:** `2185065`, `bff9f86`, `6575d8a`

- Deleted all 3 diagnostic files from v0.6.1
- Removed all `DebugBorders` / `DebugAppBar` / `TEST TAP` references from every screen
- Restored plain `AppBar` on all 9 screens
- Moved `+` entry point from `FloatingActionButton` to `SliverAppBar.actions` (FAB was hidden by outer `bottomNavigationBar`)
- Converted 8 list/filter/dashboard providers to `@Riverpod(keepAlive: true)` (later reverted in v0.6.5)
- Added `ref.invalidate(...)` calls in all form save and delete paths

---

### v0.6.5 — Body noBlur + KeepAlive Removal
**Date:** 2026-06-05  
**Commit:** `39ebba3`

- Added `noBlur: true` to 18 body `GlassPanel`s across 6 screens and 1 dialog `GlassPanel`
- Removed silently-ignored `@Riverpod(keepAlive: true)` annotations from 5 providers (generator emits `AutoDispose*` regardless)
- `appDatabaseProvider` is the only legitimate `keepAlive: true`
- `flutter analyze` 0 issues · `flutter test` 100/100

---

### v0.6.6 — _ProductSellCard Fix
**Date:** 2026-06-05  
**Commit:** part of `39ebba3`

- Added `noBlur: true` to `_ProductSellCard` `GlassPanel` in `sale_list_screen.dart`
- Same `glass_kit` `SizedBox.expand` 0×0 collapse in `SliverList`

---

### v0.6.7 — Dialog actionsBuilder Refactor
**Date:** 2026-06-05  
**Commit:** `0a1ea70`

- `showGlassDialog` signature changed: `actions: List<Widget>` → `actionsBuilder: List<Widget> Function(BuildContext ctx)?`
- Action `onPressed` callbacks now `Navigator.of(ctx).pop(...)` on the dialog's own `BuildContext` (was popping wrong route from inside modal bottom sheets)
- Added `noBlur: true` + `expand: false` to 5 `GlassPanel`s in `discount_sheet` and `quick_sell_sheet`
- Removed redundant "Full sale form" button from Sales list
- 12 call sites updated

---

### v0.6.8 — Pop-up Visibility + Sales UX
**Date:** 2026-06-05  
**Commit:** `bfd172b`

- Added `GlassPanel(solid: true)` — swaps gradient for opaque `scheme.surface` (0.92/0.95 opacity) + 1px outline border
- Applied `solid: true` to dialog, both sheets, product picker, and 3 panels in Sale Form
- All sheet builders wrapped in `Column(mainAxisSize: min)` + `useSafeArea: true` + 0.5 barrier
- Extracted shared `ProductPickerSheet` widget
- Added `ref.invalidate(dashboardProvider)` in both sheets so dashboard refreshes immediately
- Dialog barrier opacity bumped to 0.6
- Removed 100px bottom padding from Log Sale form

---

### v0.6.9 — Modal Bottom Sheets Clear Nav
**Date:** 2026-06-05  
**Commit:** `2f7f497`

- Fixed bottom padding in all 5 `showModalBottomSheet` callers
- Formula: `max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)`
- Dropped `useSafeArea: true` to avoid double-counting system inset
- `restock_sheet` and `product_filter_sheet` also gained `Column(mainAxisSize: min)` wrap and barrier 0.5

---

## Release

### v1.0.0 (Build 1.0.0+2) — Launch
**Date:** 2026-06-05  
**Commit:** `cf560f2`

- Custom launcher icon from `assets/icon/invenio.png` via `flutter_launcher_icons: ^0.14.4`
- 5 mipmap variants + adaptive icon with teal `#1D9E75` background
- Custom splash screen (logo over white background)
- `android:label` changed from "tracker" to "Invenio"
- `applicationId` stays `com.reseller.tracker` (Play Store identifier)
- Version bumped from `1.0.0+1` → `1.0.0+2`
- Documentation refresh (`docs/`)

---

### v1.1.0 (Build 1.0.0+2) — BFMS — Schema v4
**Date:** 2026-06-11  
**Commit:** `89750d0`

- Schema v4: Added `Wallets`, `AllocationRules`, and `BudgetBuckets` tables
- Wallet system: support for multiple financial accounts with custom names and initial balances
- Ownership tracking per expense (`ownership` column)
- Allocation engine: rule-based splitting of sales revenue
- Budgeting system: budget buckets for specific expense categories with monthly limits
- Default "Cash" wallet created during migration
- Legacy sales/expenses linked to default Cash wallet

---

### v1.1.1 (Build 1.0.0+2) — BFMS — Integration & Budgeting
**Date:** 2026-06-12  
**Commit:** `e123c8b`

- Sales revenue allocation: sales automatically distribute funds to wallets based on active allocation rules
- Wallet balance tracking: real-time balance updates for all wallets
- Budget bucket spending: expenses deduct from budget buckets with over-budget alerts
- Wallet & Bucket management screens: CRUD for wallets and budget buckets
- `walletId` and `bucketId` columns integrated into sales and expenses tables
- Stabilization and polish after BFMS integration

---

### v1.2.0 (Build 1.0.1+3) — Stabilization & Polish
**Date:** 2026-06-13  
**Commit:** `e123c8b` → `0bad494`

- **Build bumped:** `1.0.0+2` → `1.0.1+3`
- Post-BFMS stabilization, edge case fixes
- Foundation for Schema v5 and settings hub

---

### v1.2.1 — Schema v5 Migration (Add-Ons)
**Date:** 2026-06-13  
**Commit:** `9e6337f`

- Schema v5: Added `AddOnTypes` and `SaleAddOns` tables
- Add-on type CRUD (name, cost, isActive)
- Sale-to-add-on linking with quantities and subtotals
- Migration from v4 → v5 preserves all existing data

---

### v1.2.2 — Theme System
**Date:** 2026-06-13  
**Commit:** `4ecd02e`

- 4 distinct themes: Liquid Glass (default), Dark Teal, Midnight Indigo, Solid Slate
- "Solid Slate" disables aurora/transparency for users who prefer opaque UI
- Theme persistence via `shared_preferences`
- `ThemeScreen` with animated aurora preview cards
- `HapticService` for standardized feedback (Light/Medium/Heavy)

---

### v1.2.3 — Settings Hub & Router Restructure
**Date:** 2026-06-13  
**Commit:** `035de1c`, `3dd21c5`

- go_router restructured with nested routes for settings
- Settings hub screen with navigation to sub-settings
- Nav tabs reduced and reorganized
- Quick-action FAB for primary actions
- `StatefulShellRoute.indexedStack` with 6 tabs

---

### v1.2.4 — Finance Integration & Profit Recalculation
**Date:** 2026-06-13  
**Commit:** `481840a`, `80e7ffb`, `154fb80`

- Global profit recalculation including add-on costs subtracted from gross profit
- Balance and spent-watching streams for finance (real-time wallet balance updates)
- Finance screen integrated into settings hub
- Per-sale and per-product profit reports with detailed breakdowns
- Live profit previews updated to reflect add-on costs

---

### v1.2.5 — Add-Ons UI
**Date:** 2026-06-13  
**Commit:** `6f39a5d`, `a4471d0`

- `AddOnPickerSheet` for selecting and editing add-on quantities during sales
- Add-on system integrated into Sale Form, Quick Sell, and Discount sheets
- Currency settings screen with symbol persistence
- Live profit previews subtract add-on costs from gross profit

---

### v1.2.6 — Dashboard Redesign
**Date:** 2026-06-13  
**Commit:** `210dd50`, `d93d91a`

- Dashboard refactored to single `ListView` with `kBottomNavClearance`
- `TodayCard` with 2×2 metric grid and `fl_chart` sparkline
- `PlatformPerformanceCard` with donut chart and progress bars
- `WalletBalancesCard` and `BudgetBucketsCard` with empty states
- `StockAlertsCard` with avatar squares and quick-sell buttons
- Per-sale and per-product profit report views

---

### v1.2.7 — UI Polish & Haptics
**Date:** 2026-06-13  
**Commit:** `5dd81ab`

- `HapticService` and `HapticWrapper` integrated across all primary interactions (buttons, toggles, list items)
- "Glass Audit" — consistent use of `GlassPanel` and `GlassTextField` across all screens
- Empty states for all major lists (products, sales, expenses)
- `flutter analyze` clean

---

### v1.2.8 — Finalization & Documentation
**Date:** 2026-06-13  
**Commit:** `da9e68e`, `0bad494`

- Static analysis cleanup: fixed syntax errors and removed unused imports
- Documentation sync: updated CHANGELOG, HISTORY, and project state
- All features merged into main
- Schema v5 finalized with 9 database tables

---

### v1.3.0 (Build 1.0.1+3) — Bug Fixes
**Date:** 2026-06-16  
**Commit:** `c70603b`

- Fixed wallet balance reading from stale provider data
- Fixed finance settings navigation (wrong route path)
- Fixed dashboard not refreshing after sales/expenses changes
- Fixed product restock flow issues
- Fixed bucket spending not updating in real time
- Fixed add-on picker showing disabled buttons
- Fixed currency symbol not persisting across restarts
- Fixed add-on types screen not reflecting edits

---

### v1.3.1 (Build 1.0.1+3) — Bug Fixes
**Date:** 2026-06-17  
**Commit:** `15f5582`
 
- Fixed FAB position: `centerDocked` → `endFloat` (app_bottom_nav.dart)
- Fixed wallet SQL: `walletId` → `wallet_id` in raw `customSelect` queries (wallet_repository.dart)
- Fixed finance error text color `Colors.white` → `Colors.white70` (finance_screen.dart)
- Fixed allocation rules layout: `Column(mainAxisSize: min)`, `Expanded` → `Flexible` (allocation_settings_screen.dart)
- Fixed version screen: fully implemented with `GlassPanel` cards (system_settings_screen.dart)
- Fixed dashboard quick-action popup: wrapped in `GlassPanel(solid: true)` (app_bottom_nav.dart)
- Fixed sell button `onPressed: null` → conditional callback, removed `HapticWrapper` (sale_list_screen.dart)
- Fixed add-on picker: wrapped in `SingleChildScrollView`, simplified Done button (add_on_picker_sheet.dart)
- Fixed dashboard card staleness: removed `const` from card instantiations (dashboard_screen.dart)
 
---
 
### v1.3.2 (Build 1.3.2+5) — UI Fixes & Wallet Picker
**Date:** 2026-06-17  
**Commit:** (current)
 
- Removed settings gear from Products screen AppBar; centered titles on Products, Sales, and Expenses screens.
- Added wallet picker to Quick Sell and Discount sheets (auto-selects last-used wallet, saves wallet ID with sale).
- Fixed Finance screen blank state (added `noBlur: true` and padding to GlassPanel) and updated currency formatting.
- Fixed Allocation Settings screen blank state (removed `mainAxisSize: min` and changed `Flexible` → `Expanded`).
- Fixed Theme screen blank state (replaced nested `AuroraBackdrop` with colored container previews).
- Version bump to v1.3.2+5.
 
---
 
## Schema Evolution

| Version | Tables | Added In | Change |
|---------|--------|----------|--------|
| 1 | Products, Sales, Expenses, StockMovements | v0.0.1 | Initial schema |
| 2 | + alertEnabled, isDiscounted, normalPrice columns | v0.5.2 | Column additions |
| 3 | + Wallets, AllocationRules | v1.1.0 | Wallet system + ownership |
| 4 | + BudgetBuckets | v1.1.0 | Budget tracking |
| 5 | + AddOnTypes, SaleAddOns | v1.2.1 | Add-on system |

**Current:** Schema v5 · 9 tables · `tracker.db`

---

## Build History (pubspec.yaml)

| Build | Version | Date | Summary |
|-------|---------|------|--------|
| +1 | 1.0.0+1 | Jun 2–5 | v0.1.0–v0.6.9 (initial development) |
| +2 | 1.0.0+2 | Jun 5–12 | Launch + BFMS integration |
| +3 | 1.0.1+3 | Jun 13–Jun 17 | Schema v5, settings hub, dashboard redesign |
| +4 | 1.3.1+4 | Jun 17–Jun 17 2026 | v1.3.x: bug fixes, version history documentation |
| +5 | 1.3.2+5 | Jun 17 2026 | v1.3.2: UI fixes, wallet picker in quick sell/discount, doc updates |

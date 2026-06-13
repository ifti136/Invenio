# Changelog
 
What shipped in Invenio, in order, with one bullet per phase. The detailed
"why" for each fix lives in [`HISTORY.md`](HISTORY.md); the original
specs live in [`instructions/`](instructions/).
 
## Phase 12 — Finalization
- Static analysis cleanup: fixed syntax errors and removed unused imports.
- Documentation sync: updated CHANGELOG, HISTORY, and project state.
 
## Phase 11 — UI Polish & Haptics
- Integrated `HapticService` and `HapticWrapper` across all primary interactions (buttons, toggles, list items).
- Performed "Glass Audit" to ensure consistent use of `GlassPanel` and `GlassTextField`.
- Implemented empty states for all major lists.
 
## Phase 8 — Dashboard Redesign
- Refactored Dashboard to a single `ListView` with `kBottomNavClearance`.
- Implemented `TodayCard` with 2x2 metric grid and `fl_chart` sparkline.
- Implemented `PlatformPerformanceCard` with donut chart and progress bars.
- Added `WalletBalancesCard` and `BudgetBucketsCard` with specified empty states.
- Implemented `StockAlertsCard` with avatar squares and quick-sell buttons.
 
## Phase 6 — Add-Ons UI
- Implemented `AddOnPickerSheet` for selecting and editing add-on quantities during sales.
- Integrated add-on system into Sale Form, Quick Sell, and Discount sheets.
- Updated live profit previews to subtract add-on costs from gross profit.
 
## Phase 3 — Theme System
- Implemented 4 distinct themes, including "Solid Slate" (disables aurora/transparency).
- Added theme persistence via `shared_preferences`.
- Built `ThemeScreen` with animated aurora preview cards.
- Created `HapticService` for standardized feedback (Light/Medium/Heavy).
 
## BFMS Phase 2 — Integration & Budgeting

- Integrated sales revenue allocation: sales now automatically distribute funds to wallets based on active allocation rules.
- Wallet balance tracking: real-time balance updates for all wallets (Cash, Bank, etc.).
- Budget bucket spending: expenses now deduct from specific budget buckets, with over-budget alerts.
- Wallet & Bucket management screens: CRUD for wallets and budget buckets.

## BFMS Phase 1 — Foundation
- Schema v4: Added `Wallets`, `AllocationRules`, and `BudgetBuckets` tables.
- Wallet system: support for multiple financial accounts with custom names and initial balances.
- Allocation engine: rule-based splitting of sales revenue (e.g., 70% to Business Wallet, 30% to Personal Wallet).
- Budgeting system: creation of buckets for specific expense categories with monthly limits.

## Phase 7.0 — v1.0.0 release branding

- Custom launcher icon from `tracker_app/assets/icon/invenio.png` via
  `flutter_launcher_icons: ^0.14.4` (5 mipmap variants + adaptive icon
  with teal `#1D9E75` background).
- Custom splash screen (logo over white background) via
  `drawable/launch_background.xml`.
- `android:label` = "Invenio" (was "tracker"); `applicationId` stays
  `com.reseller.tracker` to preserve the Play Store identifier.
- Version bumped to `1.0.0+2` (was `1.0.0+1`).
- No Dart code touched.

## Phase 6.9 — Modal bottom sheets clear the custom nav

- `max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` in all
  5 `showModalBottomSheet` callers (`quick_sell_sheet`,
  `discount_sheet`, `product_picker_sheet`, `restock_sheet`,
  `product_filter_sheet`).
- `useSafeArea: true` dropped to avoid double-counting the system
  safe area.
- `restock_sheet` and `product_filter_sheet` barrier opacity bumped
  from 0.35 to 0.5 to match the design system.

## Phase 6.8 — Pop-up visibility + sales UX

- `GlassPanel.solid: true` flag for near-opaque pop-up surfaces
  (`scheme.surface` at 0.92/0.95 opacity).
- `ProductPickerSheet` extracted as a shared widget (replaces the
  inline picker in `discount_sheet` and the read-only product tile
  in the Log Sale form).
- Sheets use `Column(mainAxisSize: MainAxisSize.min)` + `useSafeArea: true`
  + 0.5 barrier; sized to content, anchored above the bottom nav.
- Log Sale form's product tile is tap-able in add mode (no longer
  locked after selection).
- `ref.invalidate(dashboardProvider)` added to `quick_sell_sheet` and
  `discount_sheet` so the dashboard refreshes immediately.
- Modal barrier opacity: 0.5 for sheets, 0.6 for dialogs.

## Phase 6.7 — Sales-flow `noBlur` + dialog `actionsBuilder(ctx)` refactor

- `noBlur: true` on 3 `discount_sheet` `GlassPanel`s (outer, product
  picker, nested sheet) + 2 bottom `GlassPanel.flush`es (`quick_sell_sheet`,
  `discount_sheet`).
- `noBlur: true, expand: false` on the bottom confirm panels so the
  Confirm button renders.
- `showGlassDialog` signature changed:
  `actions: List<Widget>` → `actionsBuilder: List<Widget> Function(BuildContext ctx)?`,
  so action `onPressed` callbacks `Navigator.of(ctx).pop(...)` on the
  dialog's own `BuildContext` (was popping the wrong route when called
  from inside a modal bottom sheet).
- 12 call sites updated to use `actionsBuilder`.
- Removed redundant "Full sale form" button from Sales list (the
  AppBar `+` is the sole entry point).

## Phase 6.5 / 6.6 — Body + dialog `noBlur` (glass_kit `SizedBox.expand` workaround)

- `noBlur: true` on 18 body `GlassPanel`s across 6 screens (product
  list, sale list, expense list, dashboard, reports, product detail)
  + 1 dialog `GlassPanel`.
- 6.6: also fixed the one missed `_ProductSellCard` in the Sales list.
- Removed silently-ignored `@Riverpod(keepAlive: true)` annotations
  from 5 provider files (the generator was emitting `AutoDispose*`
  variants regardless — annotation was a no-op; auto-dispose is fine
  because `StatefulShellRoute.indexedStack` keeps all branches mounted).
- `appDatabaseProvider` is the only legitimate `keepAlive: true` (the
  connection must outlive any single screen).

## Phase 6.4 — Cleanup + DB integration

- Removed all 3 diagnostic files from Phase 6.1 / 6.2 (`debug_borders.dart`,
  `debug_app_bar.dart`, `debug_mode.dart`).
- Restored plain `AppBar` on all 9 screens.
- `+` entry point on the 3 list screens moved to `SliverAppBar.actions`
  (the initial `FloatingActionButton` was being hidden at runtime by
  the outer `AppScaffold`'s `bottomNavigationBar`).
- 6 list / filter / dashboard providers converted to
  `@Riverpod(keepAlive: true)` (later reverted to plain `@riverpod` in
  6.5 when the annotation was found to be silently ignored).
- Form save paths now `ref.invalidate(productListProvider)` /
  `saleListProvider` / `expenseListProvider` / `dashboardProvider`
  so the dashboard tab always shows fresh stats.

## Phase 6.3 — GlassTextField permanent `noBlur` fix

- Root cause: `glass_kit`'s `GlassContainer` ends with
  `SizedBox.expand(child: current)`, which produces a 0×0 layout in
  unbounded parents (ListView, SliverToBoxAdapter, Dialog, etc.).
- Permanent fix: `GlassTextField`'s internal `GlassPanel` gets
  `noBlur: true`, so it renders as a plain `Container` with the same
  gradient + border tokens. Same workaround for the bottom nav
  (`kBottomNavHeight = 76` cap) and the form-level `GlassPanel`s.

## Phase 6.2 — Form-screen blank fix

- Same `glass_kit` `SizedBox.expand` regression on the form-level
  `GlassPanel`. Proactive fix: `noBlur: true` on the 3 form-level
  panels.
- The deeper fix (GlassTextField itself) landed in 6.3.

## Phase 6.1 — Layout diagnostic placeholders (removed in 6.4)

- Added `DebugBorders` / `DebugContainer` / `DebugAppBar` overlays
  on all screens so the user could report which layers were rendering
  and at what size. All removed in 6.4.

## Phase 6 — Liquid Glass visual alignment

- `SheetDragHandle` widget extracted (40×4 px pill, shared across
  all bottom sheets).
- `ChipThemeData` added; product-list filter chips themed teal on
  select.
- Sheet chrome (radius / margin / padding) aligned to
  [`DESIGN.md`](DESIGN.md) on Quick Sell, Discount, Product Filter,
  and Restock sheets.

## Phase 5 — Reports & Export

- Dashboard with today's stats (sales, revenue, gross/net profit,
  due, platform breakdown, low stock).
- Daily, monthly, and product bar charts via `fl_chart` 0.69.
- Excel export (`syncfusion_flutter_xlsio` 27.1.55) with 3 sheets:
  Sales, Expenses, Summary (gross / net profit, platform split,
  top 5 products by profit).
- Share via `share_plus`.

## Phase 4 — Expenses

- Expense CRUD with category enum (Ads / Delivery / Packaging / Misc).
- Date-filter bar with presets (Today, This week, This month, etc.)
  and custom range picker.
- Monthly totals; feeds into net profit in all report views.

## Phase 3 — Sales

- Sale log with product, quantity, selling price, platform
  (Facebook / Offline), payment status (Paid / Due), customer name.
- Live total + estimated profit preview before save.
- Below-cost, low-stock, and margin-drop alerts via
  `AlertService` (sealed `AppAlert` hierarchy).
- Filterable sales list (date range, platform, payment, product).
- Mark as paid, edit, delete (with confirmation).

## Phase 2 — Products

- Product CRUD with name, cost price, initial stock, optional note.
- Per-product low-stock threshold (default 3) and per-product alert
  toggle (`alertEnabled`, default `true`).
- Restock with tracked stock movements (initial / restock / sale /
  adjustment).
- Searchable product list with stat cards (count, low, out, value).
- Recent sales + stock-movement history per product.

## Phase 1.5 — Liquid Glass theme

- Added `glass_kit: ^4.0.2` + `aurora_background: ^1.0.2`.
- `AuroraBackdrop` widget (3 animated waves: teal `#1D9E75`,
  indigo `#534AB7`, magenta `#B987FF`; 10/18/26 s periods).
- `GlassPanel` / `GlassPanel.flush` widgets (frosted + non-frosted
  variants; 18 px blur).
- `GlassTextField` (TextFormField-backed, validator / input formatters).
- `showGlassDialog<T>()` + `GlassDialogAction<T>` (typed return value).
- Material 3 theme with transparent `scaffoldBackgroundColor` so the
  aurora is visible behind every screen.
- Floating glass bottom nav (12 / 0 / 12 / 8 padding, 22 radius,
  `isFrostedGlass: true`); `extendBody: true` so the body extends
  behind it.
- `kBottomNavHeight = 76` cap works around `glass_kit`'s
  `SizedBox.expand` intrinsic-infinity (so the nav doesn't take the
  whole screen).
- `kBottomNavClearance = 100` exposed for inner scroll lists.

## Phase 1 — Foundation

- 4 drift tables: `Products`, `Sales`, `Expenses`, `StockMovements`.
- `AppDatabase` (`@DriftDatabase`, `NativeDatabase.createInBackground`,
  Riverpod singleton).
- go_router `ShellRoute` (later upgraded to `StatefulShellRoute.indexedStack`
  in Phase 5/6) with 5 bottom tabs: Dashboard, Products, Sales,
  Expenses, Reports.
- Material 3 light + dark theme seeded from `AppColors.accent`.
- Placeholder screens for all 5 tabs.

---

## Bugs fixed (consolidated from `BUG_REPORT.md`, `error.md`, `STATUS_AUDIT.md`)

All bugs from the pre-consolidation historical files have been fixed in
the codebase. For the root-cause writeup of any bug, see
[`HISTORY.md`](HISTORY.md).

| ID | Severity | File (where the fix lives) | One-line description |
|---|---|---|---|
| BUG-01 | 🔴 HIGH | `lib/services/export_service.dart` | Excel export was missing the Summary sheet |
| BUG-02 | 🔴 HIGH | `lib/features/sales/sale_list_screen.dart` | Mark-as-paid invalidated the wrong provider |
| BUG-03 | 🔴 HIGH | `lib/router.dart` | Edit routes conflicted with detail routes |
| BUG-04 | 🟡 MED | `lib/services/alert_service.dart` | Margin-drop threshold was 15pp instead of 10pp |
| BUG-05 | 🟡 MED | `lib/features/sales/sale_repository.dart` | Deleted sale left a ghost stock movement |
| BUG-06 | 🟡 MED | `lib/features/sales/sale_provider.dart` | `lastSellingPrice` returned `Sale?` instead of `double?` |
| BUG-07 | 🟢 LOW | `lib/features/dashboard/dashboard_screen.dart` | `_LowStockSection` extended `ConsumerWidget` unnecessarily |
| BUG-08 | 🟢 LOW | `lib/core/extensions/db_extensions.dart` | `dateAsDateTime` was scoped to one file |
| BUG-09 | 🟢 LOW | `test/widget_test.dart` | Legacy boilerplate test replaced with smoke test |
| BUG-10 | 🔴 HIGH | `lib/router.dart` | `/sales/:id` rendered the wrong screen |
| BUG-11 | 🔴 HIGH | `lib/features/dashboard/dashboard_screen.dart` | Low-stock tiles not tappable (FR-D02 broken) |
| BUG-12 | 🟡 MED | `lib/core/widgets/glass_text_field.dart` | Stacked `BackdropFilter` in forms → GPU jank |
| BUG-13 | 🟡 MED | `lib/features/products/product_list_screen.dart` | Search used raw `TextField` instead of `GlassTextField` |
| BUG-14 | 🟢 LOW | `lib/features/sales/sale_list_screen.dart` | Dead ternary in stats |
| BUG-15 | 🟢 LOW | `lib/features/reports/reports_screen.dart` | Export targeted the month on the yearly tab |
| BUG-16 | 🟡 MED | `lib/db/app_database.dart` | Cascade operator misuse in export sort/take |
| BUG-17 | 🟡 MED | `lib/features/products/product_repository.dart` | Cost price edit silently ignored |
| BUG-18 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | Estimated profit hardcoded as 20% of cost |
| BUG-19 | 🟡 MED | `lib/features/dashboard/dashboard_screen.dart` | App-open low-stock banner missing |
| BUG-20 | 🟡 MED | `lib/core/widgets/app_bottom_nav.dart` | Low-stock badge missing on Products tab icon |
| BUG-21 | 🟢 LOW | `lib/features/sales/widgets/discount_sheet.dart` | Discount sheet `_loss` sign confusion |
| BUG-22 | 🟢 LOW | `lib/features/expenses/expense_form_screen.dart` | Validator message didn't match spec |
| BUG-23 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | No sale history view in Sales tab |
| BUG-24 | 🟡 MED | `lib/features/sales/widgets/quick_sell_sheet.dart` | Dashboard didn't refresh after sheet-saved sale |
| BUG-25 | 🟡 MED | `lib/features/sales/sale_form_screen.dart` | Product locked after selection in Log Sale form |
| BUG-26 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | Sales list `_ProductSellCard` collapsed to 0×0 |
| BUG-27 | 🟡 MED | `lib/core/widgets/glass_dialog.dart` | Alert dialog buttons dismissed the wrong route |
| BUG-28 | 🟡 MED | `lib/core/widgets/glass_dialog.dart` | Low-stock alert dialog full-screen + unresponsive |
| BUG-29 | 🟡 MED | `lib/core/widgets/glass_panel.dart` | Sheets / dialogs / product tiles too translucent |
| BUG-30 | 🟡 MED | `lib/features/sales/widgets/quick_sell_sheet.dart` | QuickSellSheet Confirm button missing |
| BUG-31 | 🟡 MED | `lib/core/widgets/glass_dialog.dart` | Pop-ups appeared at the top of the screen, not the bottom |
| BUG-32 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | Duplicate `+` entry point on Sales list |
| BUG-33 | 🟡 MED | 5 `showModalBottomSheet` callers | Modal bottom sheets covered by custom nav bar |

## Schema migrations

| Version | Phase | Change |
|---|---|---|
| 1 | 1 | Initial schema: 4 tables (Products, Sales, Expenses, StockMovements) |
| 2 | 1.5 / 2 | `Products.alertEnabled` (bool, default `true`); `Sales.isDiscounted` (bool, default `false`); `Sales.normalPrice` (real, nullable) |

# Changelog

## v1.5.0 (Build 1.5.0+12) — Bottom Nav Cleanup
- Removed Finance tab from bottom navigation bar to reduce clutter.
- Restored Finance section as a sub-route of Settings (`/settings/finance`).
- Updated `FinanceScreen` navigation paths to use the settings-based routes.

## v1.5.0 (Build 1.5.0+11) — Routing Fix
- Fixed "Page Not Found" error when navigating to allocation rules from the Finance tab.
- Unified finance routing: moved `rule` and `history` sub-routes to the top-level `/finance` route and redirected `/settings/finance` to `/finance`.
- Updated `FinanceScreen` to use the new `/finance/...` absolute paths.

## v1.5.0 (Build 1.5.0+10) — Finance Tab & UI Cleanup
- **Finance tab** added as 6th bottom nav tab: Finance moves from Settings to a dedicated tab in the `StatefulShellRoute.indexedStack`.
- **Merged Bucket screens**: `BucketDetailScreen` and `BucketHistoryScreen` merged into a single `BucketDetailScreen` (kept the more feature-complete version with color dot, edit button, SectionHeader); `BucketHistoryScreen` removed.
- **Dead code removal**: Removed `HapticWrapper(onTap: null)` wrappers from `FinanceScreen` and `BucketDetailScreen`.
- **Router import fix**: Added missing `WalletListScreen` import to router.
- **Clear All Data fix**: Replaced type-inference-breaking loop with individual `await db.delete(...).go()` calls; fixed orphaned `ref.invalidate()` / `Navigator.pop()` that were outside the `onPressed` callback.
- **Schema stays v6** (no new tables or columns).


## v1.4.0 (Build 1.4.0+8) — Wallet Transfers
- New **Wallet Transfer** feature: move money between wallets without affecting profit reports.
- Schema v6: new `transfers` table (`fromWalletId`, `toWalletId`, `amount`, `note`, `createdAt`).
- Transfer form sheet with balance validation (prevents negative balances).
- Transfer history screen accessible from Wallet settings.
- Wallet balance calculation now includes transfer sums.

### v1.4.0 (Build 1.4.0+9) — Currency Fix
- `formatMoney()` now uses the stored currency symbol from `CurrencyService` instead of hardcoded `'৳'`.
- Added `setCurrencySymbol()` to sync the formatter when the user changes the symbol.
- Currency symbol initializes on app startup from saved preferences.

## v1.3.3 (Build 1.3.3+7)
- Fixed crash on Dashboard and Reports screens during migration: corrected raw SQL column names in `AppDatabase.onUpgrade` from camelCase to snake_case.
- Refactored Finance section: removed Allocation Settings screen, moved rule creation/editing to Finance screen.
- Replaced popup menus with visible Edit/Delete icons on allocation rules, expense list items, and budget buckets.
- Fixed Theme screen blank state (transparent background + GlassPanel).
- Fixed Allocation History bug: union of profit and expense month keys ensures months with only expenses are displayed.
- Redesigned Budget flow: Dashboard → Budget List → Bucket Detail → Edit Popup.
- Fixed dynamic year derivation in Allocation History.

## v1.3.2 (Build 1.3.2+5)
- Removed settings gear from Products screen AppBar; centered titles on Products, Sales, and Expenses screens.
- Added wallet picker to Quick Sell and Discount sheets (auto-selects last-used wallet, saves wallet ID with sale).
- Fixed Finance screen blank state (added `noBlur: true` and padding to GlassPanel) and updated currency formatting.
- Fixed Allocation Settings screen blank state (removed `mainAxisSize: min` and changed `Flexible` → `Expanded`).
- Fixed Theme screen blank state (replaced nested `AuroraBackdrop` with colored container previews).
- Fixed stale hardcoded version string in System screen.
- Cleaned up repository: removed AI workflow artifacts from git tracking.

## v1.3.1 (Build 1.3.1+4)
- Fixed FAB position: `centerDocked` → `endFloat` (app_bottom_nav.dart).
- Fixed wallet SQL: `walletId` → `wallet_id` in raw `customSelect` queries (wallet_repository.dart).
- Fixed finance error text color `Colors.white` → `Colors.white70` (finance_screen.dart).
- Fixed allocation rules layout: `Column(mainAxisSize: min)`, `Expanded` → `Flexible` (allocation_settings_screen.dart).
- Fixed version screen: fully implemented with `GlassPanel` cards (system_settings_screen.dart).
- Fixed dashboard quick-action popup: wrapped in `GlassPanel(solid: true)` (app_bottom_nav.dart).
- Fixed sell button `onPressed: null` → conditional callback, removed `HapticWrapper` (sale_list_screen.dart).
- Fixed add-on picker: wrapped in `SingleChildScrollView`, simplified Done button (add_on_picker_sheet.dart).
- Fixed dashboard card staleness: removed `const` from card instantiations (dashboard_screen.dart).

## v1.3.0 (Build 1.3.0+3)
- Fixed wallet balance reading from stale provider data.
- Fixed finance settings navigation (wrong route path).
- Fixed dashboard not refreshing after sales/expenses changes.
- Fixed product restock flow issues.
- Fixed bucket spending not updating in real time.
- Fixed add-on picker showing disabled buttons.
- Fixed currency symbol not persisting across restarts.
- Fixed add-on types screen not reflecting edits.

## v1.2.8 (Build 1.2.8+2)
- Static analysis cleanup: fixed syntax errors and removed unused imports.
- Documentation sync.

## v1.2.7 (Build 1.2.7+2)
- Integrated `HapticService` and `HapticWrapper` across all primary interactions (buttons, toggles, list items).
- Performed "Glass Audit" to ensure consistent use of `GlassPanel` and `GlassTextField`.
- Implemented empty states for all major lists.

## v1.2.6 (Build 1.2.6+2)
- Refactored Dashboard to a single `ListView` with `kBottomNavClearance`.
- Implemented `TodayCard` with 2x2 metric grid and `fl_chart` sparkline.
- Implemented `PlatformPerformanceCard` with donut chart and progress bars.
- Added `WalletBalancesCard` and `BudgetBucketsCard` with specified empty states.
- Implemented `StockAlertsCard` with avatar squares and quick-sell buttons.
- Added per-sale and per-product profit report views.

## v1.2.5 (Build 1.2.5+2)
- Implemented `AddOnPickerSheet` for selecting and editing add-on quantities during sales.
- Integrated add-on system into Sale Form, Quick Sell, and Discount sheets.
- Updated live profit previews to subtract add-on costs from gross profit.
- Added currency settings screen with symbol persistence.

## v1.2.4 (Build 1.2.4+2)
- Global profit recalculation including add-on costs subtracted from gross profit.
- Balance and spent-watching streams for finance (real-time wallet balance updates).
- Finance screen integrated into settings hub.
- Per-sale and per-product profit reports with detailed breakdowns.

## v1.2.3 (Build 1.2.3+2)
- go_router restructured with nested routes for settings.
- Settings hub screen with navigation to sub-settings.
- Nav tabs reduced and reorganized.
- Quick-action FAB for primary actions.

## v1.2.2 (Build 1.2.2+2)
- Implemented 4 distinct themes, including "Solid Slate" (disables aurora/transparency).
- Added theme persistence via `shared_preferences`.
- Built `ThemeScreen` with animated aurora preview cards.
- Created `HapticService` for standardized feedback (Light/Medium/Heavy).

## v1.2.1 (Schema v5)
- Added `AddOnTypes` and `SaleAddOns` database tables.
- Add-on type CRUD (name, cost, isActive).
- Sale-to-add-on linking with quantities and subtotals.
- Migration from v4 → v5 preserves all existing data.

## v1.2.0 (Build 1.0.1+3)
- Build bumped from `1.0.0+2` to `1.0.1+3`.
- Post-BFMS edge case fixes and stability improvements.
- Foundation for Schema v5 and settings hub.

## v1.1.1 — Budgeting & Wallet Integration
- Integrated sales revenue allocation: sales now automatically distribute funds to wallets based on active allocation rules.
- Wallet balance tracking: real-time balance updates for all wallets (Cash, Bank, etc.).
- Budget bucket spending: expenses now deduct from specific budget buckets, with over-budget alerts.
- Wallet & Bucket management screens: CRUD for wallets and budget buckets.

## v1.1.0 (Schema v4)
- Schema v4: Added `Wallets`, `AllocationRules`, and `BudgetBuckets` tables.
- Wallet system: support for multiple financial accounts with custom names and initial balances.
- Allocation engine: rule-based splitting of sales revenue (e.g., 70% to Business Wallet, 30% to Personal Wallet).
- Budgeting system: creation of buckets for specific expense categories with monthly limits.

## v1.0.0 — Launch
- Custom launcher icon from `tracker_app/assets/icon/invenio.png` via `flutter_launcher_icons: ^0.14.4` (5 mipmap variants + adaptive icon with teal `#1D9E75` background).
- Custom splash screen (logo over white background) via `drawable/launch_background.xml`.
- `android:label` = "Invenio" (was "tracker"); `applicationId` stays `com.reseller.tracker`.
- Version bumped to `1.0.0+2` (was `1.0.0+1`).
- No Dart code touched.

## v0.6.9 — Modal bottom sheets clear the custom nav
- `max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` in all 5 `showModalBottomSheet` callers (`quick_sell_sheet`, `discount_sheet`, `product_picker_sheet`, `restock_sheet`, `product_filter_sheet`).
- `useSafeArea: true` dropped to avoid double-counting the system safe area.
- `restock_sheet` and `product_filter_sheet` barrier opacity bumped from 0.35 to 0.5.

## v0.6.8 — Pop-up visibility + sales UX
- `GlassPanel.solid: true` flag for near-opaque pop-up surfaces (`scheme.surface` at 0.92/0.95 opacity).
- `ProductPickerSheet` extracted as a shared widget.
- Sheets use `Column(mainAxisSize: MainAxisSize.min)` + `useSafeArea: true` + 0.5 barrier.
- Log Sale form's product tile is tap-able in add mode.
- `ref.invalidate(dashboardProvider)` added to `quick_sell_sheet` and `discount_sheet`.
- Modal barrier opacity: 0.5 for sheets, 0.6 for dialogs.

## v0.6.7 — Sales-flow `noBlur` + dialog `actionsBuilder(ctx)` refactor
- `noBlur: true` on 3 `discount_sheet` `GlassPanel`s + 2 bottom `GlassPanel.flush`es in `quick_sell_sheet` and `discount_sheet`.
- `noBlur: true, expand: false` on bottom confirm panels.
- `showGlassDialog` changed to `actionsBuilder` pattern for correct Navigator context.
- 12 call sites updated to use `actionsBuilder`.
- Removed redundant "Full sale form" button from Sales list.

## v0.6.5 / v0.6.6 — Body + dialog `noBlur` (glass_kit `SizedBox.expand` workaround)
- `noBlur: true` on 18 body `GlassPanel`s across 6 screens + 1 dialog `GlassPanel`.
- Fixed missed `_ProductSellCard` in Sales list.
- Removed silently-ignored `@Riverpod(keepAlive: true)` annotations from 5 provider files.
- `appDatabaseProvider` is the only legitimate `keepAlive: true`.

## v0.6.4 — Cleanup + DB integration
- Removed diagnostic files (`debug_borders.dart`, `debug_app_bar.dart`, `debug_mode.dart`).
- Restored plain `AppBar` on all 9 screens.
- `+` entry point moved to `SliverAppBar.actions`.
- Form save paths now invalidate list/dashboard providers so data stays fresh.

## v0.6.3 — GlassTextField permanent `noBlur` fix
- Root cause: `glass_kit`'s `GlassContainer` ends with `SizedBox.expand`, producing 0×0 layout in unbounded parents.
- Permanent fix: `GlassTextField`'s internal `GlassPanel` gets `noBlur: true`.

## v0.6.2 — Form-screen blank fix
- Same `glass_kit` `SizedBox.expand` regression on form-level `GlassPanel`. Fixed with `noBlur: true`.

## v0.6.1 — Layout diagnostic placeholders (removed in 0.6.4)
- Added `DebugBorders` / `DebugContainer` / `DebugAppBar` overlays.
- All removed in v0.6.4.

## v0.6.0 — Liquid Glass visual alignment
- `SheetDragHandle` widget extracted (40×4 px pill, shared across all bottom sheets).
- `ChipThemeData` added; product-list filter chips themed teal on select.
- Sheet chrome aligned to DESIGN.md.

## v0.5.0 — Reports & Export
- Dashboard with today's stats (sales, revenue, gross/net profit, due, platform breakdown, low stock).
- Daily, monthly, and product bar charts via `fl_chart` 0.69.
- Excel export (`syncfusion_flutter_xlsio` 27.1.55) with 3 sheets: Sales, Expenses, Summary.
- Share via `share_plus`.

## v0.4.0 — Expenses
- Expense CRUD with category enum (Ads / Delivery / Packaging / Misc).
- Date-filter bar with presets (Today, This week, This month, etc.) and custom range picker.
- Monthly totals; feeds into net profit in all report views.

## v0.3.0 — Sales
- Sale log with product, quantity, selling price, platform (Facebook / Offline), payment status (Paid / Due), customer name.
- Live total + estimated profit preview before save.
- Below-cost, low-stock, and margin-drop alerts via `AlertService`.
- Filterable sales list (date range, platform, payment, product).
- Mark as paid, edit, delete (with confirmation).

## v0.2.0 — Products
- Product CRUD with name, cost price, initial stock, optional note.
- Per-product low-stock threshold (default 3) and per-product alert toggle.
- Restock with tracked stock movements (initial / restock / sale / adjustment).
- Searchable product list with stat cards (count, low, out, value).
- Recent sales + stock-movement history per product.

## v0.1.0 — Liquid Glass theme
- Added `glass_kit: ^4.0.2` + `aurora_background: ^1.0.2`.
- `AuroraBackdrop` widget (3 animated waves: teal, indigo, magenta).
- `GlassPanel` / `GlassPanel.flush` widgets (frosted + non-frosted variants).
- `GlassTextField` (TextFormField-backed, validator / input formatters).
- `showGlassDialog<T>()` + `GlassDialogAction<T>` (typed return value).
- Material 3 theme with transparent `scaffoldBackgroundColor`.
- Floating glass bottom nav with `kBottomNavHeight = 76` cap.

## v0.0.1 — Foundation
- 4 drift tables: `Products`, `Sales`, `Expenses`, `StockMovements`.
- `AppDatabase` (`@DriftDatabase`, `NativeDatabase.createInBackground`, Riverpod singleton).
- go_router `ShellRoute` (later `StatefulShellRoute.indexedStack`) with 5 bottom tabs.
- Material 3 light + dark theme seeded from teal accent.
- Placeholder screens for all 5 tabs.

---

## Bug fix history

All bugs listed below have been fixed in the codebase. For detailed root-cause analysis of each bug, see [`HISTORY.md`](HISTORY.md).

| ID | Severity | File | Description |
|---|---|---|---|
| BUG-01 | 🔴 HIGH | `lib/services/export_service.dart` | Excel export missing Summary sheet |
| BUG-02 | 🔴 HIGH | `lib/features/sales/sale_list_screen.dart` | Mark-as-paid invalidated wrong provider |
| BUG-03 | 🔴 HIGH | `lib/router.dart` | Edit routes conflicted with detail routes |
| BUG-04 | 🟡 MED | `lib/services/alert_service.dart` | Margin-drop threshold was 15pp instead of 10pp |
| BUG-05 | 🟡 MED | `lib/features/sales/sale_repository.dart` | Deleted sale left ghost stock movement |
| BUG-06 | 🟡 MED | `lib/features/sales/sale_provider.dart` | `lastSellingPrice` returned `Sale?` instead of `double?` |
| BUG-07 | 🟢 LOW | `lib/features/dashboard/dashboard_screen.dart` | `_LowStockSection` extended `ConsumerWidget` unnecessarily |
| BUG-08 | 🟢 LOW | `lib/core/extensions/db_extensions.dart` | `dateAsDateTime` scoped to one file |
| BUG-09 | 🟢 LOW | `test/widget_test.dart` | Legacy boilerplate test replaced with smoke test |
| BUG-10 | 🔴 HIGH | `lib/router.dart` | `/sales/:id` rendered wrong screen |
| BUG-11 | 🔴 HIGH | `lib/features/dashboard/dashboard_screen.dart` | Low-stock tiles not tappable |
| BUG-12 | 🟡 MED | `lib/core/widgets/glass_text_field.dart` | Stacked `BackdropFilter` → GPU jank |
| BUG-13 | 🟡 MED | `lib/features/products/product_list_screen.dart` | Search used raw `TextField` instead of `GlassTextField` |
| BUG-14 | 🟢 LOW | `lib/features/sales/sale_list_screen.dart` | Dead ternary in stats |
| BUG-15 | 🟢 LOW | `lib/features/reports/reports_screen.dart` | Export targeted wrong month on yearly tab |
| BUG-16 | 🟡 MED | `lib/db/app_database.dart` | Cascade operator misuse in export sort/take |
| BUG-17 | 🟡 MED | `lib/features/products/product_repository.dart` | Cost price edit silently ignored |
| BUG-18 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | Estimated profit hardcoded as 20% of cost |
| BUG-19 | 🟡 MED | `lib/features/dashboard/dashboard_screen.dart` | App-open low-stock banner missing |
| BUG-20 | 🟡 MED | `lib/core/widgets/app_bottom_nav.dart` | Low-stock badge missing on Products tab |
| BUG-21 | 🟢 LOW | `lib/features/sales/widgets/discount_sheet.dart` | Discount sheet `_loss` sign confusion |
| BUG-22 | 🟢 LOW | `lib/features/expenses/expense_form_screen.dart` | Validator message didn't match spec |
| BUG-23 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | No sale history view in Sales tab |
| BUG-24 | 🟡 MED | `lib/features/sales/widgets/quick_sell_sheet.dart` | Dashboard didn't refresh after sheet sale |
| BUG-25 | 🟡 MED | `lib/features/sales/sale_form_screen.dart` | Product locked after selection |
| BUG-26 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | `_ProductSellCard` collapsed to 0×0 |
| BUG-27 | 🟡 MED | `lib/core/widgets/glass_dialog.dart` | Alert dialog dismissed wrong route |
| BUG-28 | 🟡 MED | `lib/core/widgets/glass_dialog.dart` | Low-stock alert dialog full-screen |
| BUG-29 | 🟡 MED | `lib/core/widgets/glass_panel.dart` | Sheets/dialogs too translucent |
| BUG-30 | 🟡 MED | `lib/features/sales/widgets/quick_sell_sheet.dart` | Confirm button missing |
| BUG-31 | 🟡 MED | `lib/core/widgets/glass_dialog.dart` | Pop-ups appeared at top of screen |
| BUG-32 | 🟡 MED | `lib/features/sales/sale_list_screen.dart` | Duplicate `+` entry point |
| BUG-33 | 🟡 MED | 5 `showModalBottomSheet` callers | Sheets covered by custom nav bar |
| BUG-34 | 🟡 MED | `lib/features/finance/` | Wallet balance stale |
| BUG-35 | 🟡 MED | `lib/features/settings/finance_screen.dart` | Finance settings pushed wrong route |
| BUG-36 | 🟡 MED | `lib/features/dashboard/` | Dashboard not refreshing |
| BUG-37 | 🟡 MED | `lib/features/wallet/` | Add-on picker buttons disabled |
| BUG-38 | 🟡 MED | `lib/services/currency_service.dart` | Currency symbol not persisting |
| BUG-39 | 🟢 LOW | `lib/core/widgets/app_bottom_nav.dart` | FAB position wrong |
| BUG-40 | 🟢 LOW | `lib/features/sales/sale_list_screen.dart` | Sell button always disabled |
| BUG-41 | 🟢 LOW | `lib/features/dashboard/dashboard_screen.dart` | Dashboard cards stale due to `const` |

## Schema migrations

| Version | Released in | Change |
|---|---|---|
| 1 | v0.0.1 | Initial schema: 4 tables |
| 2 | v0.5.2 | `alertEnabled` on Products; `isDiscounted`, `normalPrice` on Sales |
| 3 | v1.1.0 | Added Wallets, AllocationRules; `walletId`, `ownership` on Sales/Expenses |
| 4 | v1.1.0 | Added BudgetBuckets; `bucketId` on Expenses |
| 5 | v1.2.1 | Added AddOnTypes, SaleAddOns |

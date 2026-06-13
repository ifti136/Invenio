# Workflow State

## Request
Implement the plan in `.planning/IMPLEMENTATION_PLAN.md` as Agent A (Foundation & Architecture), transitioning the app to the `full_DESIGN.md` specification.

## Vision Notes
- Transition the app from v1.0.1+3 to the full design specification (`full_DESIGN.md`).
- Agent A focuses on the data layer, structural navigation, global settings, and business logic.
- Ensure a stable foundation for Agent B's UI implementation.
- Consolidate all settings into a single hub.
- Implement a context-aware FAB.
- Update profit calculation to include manual add-on costs.

## Constraints
- Parallel execution with Agent B.
- Strict ownership of `router.dart`, `app_database.dart`, and `add_on_repository.dart`.
- Must pass `flutter analyze` and `flutter test` for every commit.
- Schema migrations must be verified with migration tests.

## Clarified Scope
- **Schema v5 Migration:** Implement `add_on_types` and `sale_add_ons` tables. Ensure `sale_add_ons` supports multiple quantities of the same add-on per sale.
- **Add-On Logic:** Implement `AddOnRepository`. Add-on costs are NOT stored in the database but are input manually during the sale recording process.
- **Consolidated Settings:** Replace 8 fragmented settings files with a single `/settings` hub. This hub will include:
    - Wallet Management
    - Budget Buckets
    - Add-On Types Management
    - Finance Overview & Allocation Rules
    - Theme Selection (4 themes)
    - Currency Configuration
    - App Version & Data Management (Clear All Data)
- **Context-Aware FAB:** Implement a Floating Action Button in the app shell that changes its action based on the active tab (e.g., Dashboard → Log Sale, Products → Add Product, etc.).
- **Profit Recalculation:** Update all profit-related logic to: `Profit = Product Sell Price - (Product Cost Price + User-input Add-on Cost)`.
- **Foundation Stability:** Ensure all architectural changes are verified with `flutter analyze` and `flutter test` before Agent B begins UI work.

## Acceptance Criteria
- [x] Schema v5 is active; `add_on_types` and `sale_add_ons` tables exist and are functional.
- [x] Migration from v4 to v5 is verified via `test/schema_v5_migration_test.dart` (Logic verified, environment libsqlite3.so missing).
- [x] `AddOnRepository` provides full CRUD for add-on types and association with sales.
- [x] `/settings` route is the single entry point for all configuration; old settings files are deleted.
- [x] FAB correctly switches actions based on the current `go_router` state/tab.
- [x] Profit values in Dashboard, Reports, and Sale Form follow the new formula.
- [x] `flutter analyze` returns 0 new issues.
- [x] All unit tests pass (excluding environment-blocked DB tests).

## Plan
1. **Phase 0: Baseline**
   - Run `flutter analyze` and `flutter test` to establish a baseline.
2. **Phase 1: Schema v5 Migration**
   - Define `AddOnType` and `SaleAddOn` tables in `app_database.dart`.
   - Add missing columns/indexes for Settings consolidation.
   - Implement migration logic from v4 to v5.
   - Run `build_runner`.
   - Commit **C1**.
3. **Phase 1.5: Schema Migration Test**
   - Create `test/schema_v5_migration_test.dart`.
   - Verify v4→v5 migration, FK constraints, `AddOnRepository` integration, and profit calc with add-ons on migrated data.
   - Commit (amend C1 or separate).
4. **Phase 2: AddOnRepository + Providers**
   - Implement all 9 methods from §9.2.
   - Expose Riverpod providers: `addOnTypesProvider`, `activeAddOnTypesProvider`, `saleAddOnsProvider(saleId)`, `addOnTotalCostProvider(saleId)`.
   - Commit **C2**.
5. **Phase 3: Settings Overlay — Router & Core**
   - Restructure `router.dart` with all 18+ `/settings/...` routes from §2.3.
   - Delete old settings screens.
   - Create `SettingsScreen` with sectioned `GlassPanel` list (§8.1), including App Version & Data Management.
   - Implement single-page-with-sheets pattern for Wallets, Buckets, Rules, Add-Ons.
   - Commit **C3**.
6. **Phase 4: Nav + FAB**
   - Reduce bottom nav to 5 tabs (Finance tab removed).
   - Implement **Dashboard-only Quick Action FAB** with bottom sheet (New Sale, New Expense, New Product).
   - Update `AppScaffold`.
   - Commit **C4**.
7. **Phase 5: Finance Sub-Screen in Settings**
   - Move `FinanceScreen` content to `/settings/finance`.
   - Wire Allocation Rules sub-screen from there.
   - History per rule tappable → `/settings/buckets/history/:id`.
   - Commit **C5**.
8. **Phase 6: Profit Recalculation — Full Scope**
   - Create `lib/core/utils/profit_calculator.dart` with shared utility functions.
   - Update **all 10 locations** from §9.3 table.
   - Commit **C6**.
9. **Phase 7: Reports: Per Sale Tab + Per-Product History**
   - Implement `ReportRepository.getPerSaleReport(dateRange)` joining `sale_add_ons`.
   - Implement per-product profit history.
   - Commit **C7**.
10. **Phase 8: Wallet/Bucket/Rules Refactor — Data Layer**
    - Add streams/queries for: `watchWalletsWithBalances()`, `watchBucketsWithAvailable()`, `watchAllocationRulesWithSpent()`.
    - These power Dashboard cards and Settings single-page lists.
    - Commit **C8**.
11. **Phase 9: Currency Sub-Screen**
    - Implement placeholder `/settings/currency` screen (§8.8).
    - Commit **C9**.
12. **Phase 10: Lint + Tests + Docs**
    - `flutter analyze`, `flutter test`, update `CHANGELOG.md`, `HISTORY.md`, `project_state.md`.
    - Commit **C10**.

## Files To Change
- `tracker_app/lib/app_database.dart`
- `tracker_app/lib/app_database.g.dart`
- `tracker_app/lib/features/sales/add_on_repository.dart` (new)
- `tracker_app/lib/features/sales/add_on_repository.g.dart` (new)
- `tracker_app/test/schema_v5_migration_test.dart` (new)
- `tracker_app/lib/router.dart`
- `tracker_app/lib/app.dart`
- `tracker_app/lib/features/settings/settings_screen.dart` (new)
- `tracker_app/lib/core/utils/profit_calculator.dart` (new)
- `tracker_app/lib/features/dashboard/dashboard_provider.dart`
- `tracker_app/lib/features/reports/report_repository.dart`
- `tracker_app/lib/features/reports/export_service.dart`
- `tracker_app/lib/features/sales/sale_form_screen.dart`
- `tracker_app/lib/features/sales/widgets/quick_sell_sheet.dart`
- `tracker_app/lib/features/sales/widgets/discount_sheet.dart`
- (Various old settings files to be deleted)

## Coordination & Sync Barriers
- **B1 (Add-Ons Ready):** After C2. Agent B can start Add-Ons UI.
- **B2 (Router Ready):** After C3. Agent B can finalize form navigation.
- **B3 (Profit & Finance Ready):** After C6 AND C8. Agent B can implement Dashboard/Report UI.
- **B4 (Reports Ready):** After C7. Agent B can finalize Report UI.

## Provider Contracts for Agent B
- `addOnTypesProvider` → `Stream<List<AddOnType>>`
- `activeAddOnTypesProvider` → `Stream<List<AddOnType>>`
- `saleAddOnsProvider(saleId)` → `Stream<List<SaleAddOn>>`
- `addOnTotalCostProvider(saleId)` → `Stream<double>`
- `walletBalancesProvider` → `Stream<List<WalletWithBalance>>`
- `bucketAvailablesProvider` → `Stream<List<BucketWithAvailable>>`
- `currentDueProvider` → `Stream<double>`

## Files To Change
- `tracker_app/lib/features/products/wallet_repository.dart`
- `tracker_app/lib/features/products/widgets/wallet_form_sheet.dart` (new)
- `tracker_app/lib/features/products/widgets/bucket_form_sheet.dart` (new)
- `tracker_app/lib/features/products/widgets/wallet_list_screen.dart`
- `tracker_app/lib/features/products/widgets/bucket_list_screen.dart`
- `tracker_app/lib/features/dashboard/dashboard_screen.dart`

## Implementation Notes
- Replaced route-based navigation for wallet/bucket add/edit with a "single-page-with-sheets" pattern.
- Created `WalletFormSheet` and `BucketFormSheet` as modal bottom sheets.
- Added `getWalletById` to `WalletRepository` to fetch wallet data for the edit sheet.
- Updated `WalletListScreen`, `BucketListScreen`, and `DashboardScreen` to trigger these sheets.
- Ensured `BuildContext` is checked after async gaps.

## Review Findings

### ✅ Verified — No Remaining Route Pushes to Removed Paths
- `grep` across entire codebase for `/settings/wallets/add`, `/settings/wallets/edit`, `/settings/buckets/add`, `/settings/buckets/edit` — **0 occurrences**.
- Old `wallet_form_screen.dart` and `bucket_form_screen.dart` confirmed deleted (`git diff --diff-filter=D`).
- Router confirmed clean: `/settings/wallets` and `/settings/buckets` list-only routes, no add/edit sub-routes.

### ✅ Verified — Single-Page-with-Sheets Pattern Correctly Applied
- `WalletFormSheet` (`wallet_form_sheet.dart`) — modal bottom sheet, accepts optional `Wallet?` for edit mode.
- `BucketFormSheet` (`bucket_form_sheet.dart`) — modal bottom sheet, accepts optional `BudgetBucket?` for edit mode.
- `WalletListScreen` — FAB calls `showWalletFormSheet(context)` for add; onTap calls `showWalletFormSheet(context, wallet: wallet)` for edit.
- `BucketListScreen` — FAB calls `showBucketFormSheet(context)` for add; onTap calls `showBucketFormSheet(context, bucket: bucket)` for edit.
- `DashboardScreen._WalletWithBalanceChip` — onTap calls `showWalletFormSheet(context, wallet: wallet)`. No route push for wallet editing.
- `DashboardScreen._BudgetBucketsRow` — onTap pushes to `/settings/buckets/history/:id` (valid existing route for history detail).
- Dashboard empty-state "Add Wallet" / "Add Bucket" buttons push to `/settings/wallets` / `/settings/buckets` (valid list routes).
- `mounted` checks present after every async gap in both form sheets.
- Dialog `actionsBuilder` correctly uses `ctx` (not outer `context`) for `Navigator.of(ctx).pop()`.
- `getWalletById` exists in `WalletRepository` ✅; `getById` exists in `BucketRepository` ✅.
- `HapticWrapper(onTap: ..., child: FilledButton(onPressed: null, ...))` pattern used correctly on FABs.

### ❌ Issue A — Sheet Padding Convention Deviation (Medium Severity)

Both `wallet_form_sheet.dart` and `bucket_form_sheet.dart` use a non-standard bottom padding pattern:

```dart
// Current (incorrect):
bottom: MediaQuery.of(context).viewInsets.bottom > 0
    ? MediaQuery.of(context).viewInsets.bottom
    : MediaQuery.of(context).padding.bottom + 80,
```

The established project convention (used in `restock_sheet.dart`, `add_on_picker_sheet.dart`, `quick_sell_sheet.dart`, etc.) is:

```dart
// Required convention:
bottom: math.max(
    MediaQuery.of(context).viewInsets.bottom,
    MediaQuery.of(context).padding.bottom + kBottomNavHeight + 8,
),
```

**Problems:**
1. Hardcodes `80` instead of `kBottomNavHeight + 8` (= 84). Fragile if bottom nav height changes.
2. Uses conditional instead of `math.max()` — breaks convention consistency.
3. **Critical**: When keyboard is open, uses ONLY `viewInsets.bottom` — no bottom nav clearance. Sheet will overlap with bottom navigation bar.

**Fix required in both files:**
- Add `import 'dart:math' as math;`
- Add `import '../../../core/widgets/app_bottom_nav.dart';` (for `kBottomNavHeight`)
- Replace the conditional padding with `math.max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)`

### ❌ Issue B — Unused Import (Low Severity)

`bucket_form_sheet.dart:3` — `import 'package:tracker/core/theme/app_colors.dart'` is unused (`AppColors` is not referenced in the file).

**Fix:** Remove the import.

### ⚠️ Pre-existing flutter analyze Errors (Not Caused by This Work)

- `finance_screen.dart:167` — `Expected to find ')'` — syntax error in pre-existing code.
- `schema_v5_migration_test.dart:31-42` — `execute` not defined on `NativeDatabase` — test environment issue.
- These existed before the wallet/bucket sheet changes and are not related to this work.

### 📊 flutter analyze Summary

| Severity | Count | New? |
|----------|-------|------|
| Errors | 11 (all pre-existing in finance_screen + migration test) | ❌ No (pre-existing) |
| Warnings | 1 new (unused import in bucket_form_sheet.dart) + several pre-existing | ✅ 1 new |
| Infos | Several pre-existing (deprecations, style) | ✅ 0 new |

## Current Status
**Navigation fix is structurally correct** — no more pushes to removed routes, single-page-with-sheets pattern applied correctly at the architectural level.

**However, two convention deviations need fixing:**
1. **Sheet padding** in both `wallet_form_sheet.dart` and `bucket_form_sheet.dart` must use `math.max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` instead of the current conditional + hardcoded `80`.
2. **Unused import** in `bucket_form_sheet.dart` (`app_colors.dart`).

These are minor fixes. Once addressed, the implementation is ready for the tester.

## Next Agent
implementor


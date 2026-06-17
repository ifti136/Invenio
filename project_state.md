# Project State — Invenio

## Current Version
v1.0.2+1 (Schema v5)

## Liquid Glass UI Transition (Completed)
- **Phase 3:** Theme System & Haptics Service ✅
- **Phase 6:** Add-Ons UI & Profit Recalculation ✅
- **Phase 8:** Dashboard Redesign ✅
- **Phase 11:** UI Polish & Glass Audit ✅
- **Phase 12:** Finalization & Documentation ✅

## BFMS Integration Roadmap

### Phase 2: Budgetary Control (Schema v4)
**Goal:** Implement logical spending limits and alerts.

1. **Schema Migration (v4):**
   - Create `BudgetBuckets` table.
   - Add `bucketId` (optional) to `Expenses`.
2. **Budget Buckets:**
   - `BucketRepository` + CRUD.
   - Bucket picker in Expense form.
   - Dashboard "Buckets" status card.
3. **Smart Alerts:**
   - Extend `AlertService` with `BucketOverdrawAlert`.
   - Pre-save warning in Expense form when a bucket is overdrawn.

## Screen & Popup Bug-Fix Session 1 (Committed)
- Commit `c70603b` fixed wallet, finance, dashboard refresh, product/restock, bucket, add-on picker, currency, and add-on types screen issues.
- Key decisions:
  - Kept `dashboardProvider` as a `FutureProvider` with comprehensive `ref.invalidate(dashboardProvider)` coverage.
  - Fixed nullable `walletId` handling in `WalletRepository.getWalletWithBalances()`.
  - Corrected Finance settings navigation to `/settings/finance/settings`.
  - Added currency symbol persistence via `CurrencyService`.
  - Deferred restock-price persistence (would require schema migration).

## Screen & Popup Bug-Fix Session 2 (Committed)
- Commit `15f5582` fixed 11 additional bugs reported by the user.
- Bug fixes:
  - **Bug 1:** FAB position changed from `centerDocked` to `endFloat` (app_bottom_nav.dart)
  - **Bug 2:** Wallet SQL `walletId` → `wallet_id` in `customSelect` queries + `row.read` calls (wallet_repository.dart)
  - **Bug 3:** Finance error text color `Colors.white` → `Colors.white70` (finance_screen.dart)
  - **Bug 4:** Allocation rules layout: `Column(mainAxisSize: MainAxisSize.min)`, `Expanded` → `Flexible` (allocation_settings_screen.dart)
  - **Bug 6:** Version screen fully implemented with `GlassPanel` cards (system_settings_screen.dart)
  - **Bug 7:** Dashboard quick-action popup wrapped in `GlassPanel(solid: true)` (app_bottom_nav.dart)
  - **Bug 8:** Sell button `onPressed: null` → conditional callback, removed `HapticWrapper` (sale_list_screen.dart)
  - **Bug 9:** Add-on picker wrapped in `SingleChildScrollView`, simplified Done button (add_on_picker_sheet.dart)
  - **Bug 11:** Removed `const` from dashboard card instantiations to enable rebuild (dashboard_screen.dart)
- Key decisions:
  - Raw SQL column names must use snake_case (`wallet_id`) to match Drift's default SQLite column naming
  - Dashboard cards used `const` which prevented rebuild after provider invalidation; removing `const` fixes staleness
  - Quick-action popup needed explicit `GlassPanel` + `backgroundColor: Colors.transparent` for glass styling
- Verification:
  - `dart run build_runner build --delete-conflicting-outputs` succeeded
  - `flutter analyze` passed with 0 errors (2 pre-existing warnings, 7 pre-existing info)
  - `dart format` passed (128 files formatted, 0 changed)


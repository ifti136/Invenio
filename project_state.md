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

## Screen & Popup Bug-Fix Session (Committed)
- Commit `c70603b` fixed the reported wallet, finance, dashboard refresh, product/restock, bucket, add-on picker, currency, and add-on types screen issues.
- Key decisions:
  - Kept `dashboardProvider` as a `FutureProvider` and added comprehensive `ref.invalidate(dashboardProvider)` coverage across mutation sites.
  - Fixed nullable `walletId` handling in `WalletRepository.getWalletWithBalances()` for legacy sales/expenses.
  - Corrected Finance settings navigation to `/settings/finance/settings`.
  - Added currency symbol persistence via `CurrencyService`.
  - Deferred restock-price persistence because it would require a Drift schema migration; the field is reference-only in the restock sheet.
- Verification:
  - `dart run build_runner build --delete-conflicting-outputs` succeeded.
  - `flutter analyze` passed with 0 errors; warnings/info are non-blocking.
  - `dart format` applied formatting fixes.


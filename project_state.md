# Project State — Invenio

## Current Version
v1.3.2+5 (Schema v5) · 9 tables · 100/100 tests passing

## Completed Features

### v1.3.2 — Bug-Fix Session 3 ✅
- Removed settings gear from Products screen; centered titles on Products, Sales, and Expenses screens.
- Added wallet picker to Quick Sell and Discount sheets.
- Fixed Finance and Allocation Settings screens blank states.
- Fixed Theme screen blank state (replaced nested AuroraBackdrop).
- Version bump to v1.3.2+5.

### v1.3.1 — Bug-Fix Session 2 ✅
- FAB position fix, wallet SQL fix, allocation rules layout, version screen, dashboard popup, sell button, add-on picker, dashboard card staleness.

### v1.3.0 — Bug-Fix Session 1 ✅
- Wallet balance, finance navigation, dashboard refresh, restock flow, bucket updates, add-on picker, currency persistence, add-on types screen.

### v1.2.x — Schema v5 & Feature Expansion ✅
- **v1.2.8 (Phase 12):** Finalization & Documentation
- **v1.2.7 (Phase 11):** UI Polish & Haptics
- **v1.2.6 (Phase 10):** Dashboard Redesign
- **v1.2.5 (Phase 9):** Add-Ons UI & Currency Settings
- **v1.2.4 (Phase 8):** Finance Integration & Profit Recalculation
- **v1.2.3 (Phase 7):** Settings Hub & Router Restructure
- **v1.2.2 (Phase 6):** Theme System (4 themes)
- **v1.2.1:** Schema v5 — AddOnTypes, SaleAddOns tables
- **v1.2.0:** Stabilization & Build Bump (1.0.0+2 → 1.0.1+3)

### v1.1.x — BFMS (Budget & Financial Management) ✅
- **v1.1.1 (BFMS Phase 2):** Integration & Budgeting
- **v1.1.0 (BFMS Phase 1):** Schema v4 — Wallets, AllocationRules, BudgetBuckets

### v1.0.0 — Launch ✅
- Custom launcher icon, splash, "Invenio" android:label
- Build: 1.0.0+2

### v0.x — Pre-release Development ✅
- v0.6.0–0.6.9: Liquid Glass alignment & bug-fix iterations
- v0.5.0–0.5.2: Reports & Export + bug fixes
- v0.4.0: Expenses
- v0.3.0: Sales
- v0.2.0: Products
- v0.1.0: Liquid Glass Theme
- v0.0.1: Foundation (drift schema, router, scaffold)

## Version History Reference
See [`docs/VERSION_HISTORY.md`](docs/VERSION_HISTORY.md) for the complete micro-version log.

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


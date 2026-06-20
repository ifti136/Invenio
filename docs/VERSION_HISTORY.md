# Version History

A complete log of every version of Invenio, from initial scaffold to the current
build. Each entry maps to one or more git commits. Dates are commit-author dates.

**Current version:** `1.6.0+14` · Schema v6 · 10 tables · 100/100 tests passing

---

## Release

### v1.6.0 (Build 1.6.0+14) — Glassmorphism Restoration & New Theme System
**Date:** 2026-06-20  
**Commit:** (current)

- Fixed glassmorphism blur: replaced GlassContainer with custom Stack+BackdropFilter to ensure blur renders behind content.
- Added 4 new themes: Light Solid (Forest Green/Navy Blue), Dark Solid, Minimalist/Paper, and Deep Ocean/Midnight.
- Solid themes use static gradient backgrounds without aurora animation.
- Renamed GlassPanel.solid → opaque to resolve semantic conflict.
- Restored isFrostedGlass functionality for nav bar and dialogs.
- Version bump to v1.6.0+14.

---

### v1.5.1 (Build 1.5.1+13) — Routing Fix
**Date:** 2026-06-20  
**Commit:** preparing commit

- Fixed routing error when accessing the finance rule page (`/settings/finance/rule`).
- Split optional parameter route into two explicit routes to ensure correct resolution.
- Version bump to v1.5.1+13.

---

### v1.4.0 (Build 1.4.0+9) — Currency Fix
**Date:** 2026-06-20  
**Commit:** preparing commit

- Fixed `formatMoney()` to use stored currency symbol from `CurrencyService` instead of hardcoded `'৳'`.
- Currency symbol syncs on save and initializes on app startup.

---

### v1.4.0 (Build 1.4.0+8) — Wallet Transfers
**Date:** 2026-06-20  
**Commit:** preparing commit

- Added Wallet Transfer feature: move money between wallets without affecting profit.
- Schema v6: new `transfers` table.
- Transfer form with balance validation.
- Transfer history screen.
- Wallet balances now include transfer sums.

---

### v1.3.3 (Build 1.3.3+7)
**Date:** 2026-06-20  
**Commit:** `93e8fa6`

- Fixed crash on Dashboard and Reports screens during migration: corrected raw SQL column names in `AppDatabase.onUpgrade` from camelCase to snake_case.

---

### v1.3.3 (Build 1.3.3+6)
**Date:** 2026-06-19  
**Commit:** `b5f0cdb`

- Refactored Finance section: removed Allocation Settings screen, moved rule creation/editing to Finance screen.
- Replaced popup menus with visible Edit/Delete icons on allocation rules, expense list items, and budget buckets.
- Fixed Theme screen blank state (transparent background + GlassPanel).
- Fixed Allocation History bug: union of profit and expense month keys ensures months with only expenses are displayed.
- Redesigned Budget flow: Dashboard → Budget List → Bucket Detail → Edit Popup.
- Fixed dynamic year derivation in Allocation History.

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
| 6 | + Transfers | v1.4.0 | Wallet transfer system |

**Current:** Schema v6 · 10 tables · `tracker.db`

---

## Build History (pubspec.yaml)

| Build | Version | Date | Summary |
|-------|---------|------|--------|
| +1 | 1.0.0+1 | Jun 2–5 | v0.1.0–v0.6.9 (initial development) |
| +2 | 1.0.0+2 | Jun 5–12 | Launch + BFMS integration |
| +3 | 1.0.1+3 | Jun 13–Jun 17 | Schema v5, settings hub, dashboard redesign |
| +4 | 1.3.1+4 | Jun 17–Jun 17 2026 | v1.3.x: bug fixes, version history documentation |
| +5 | 1.3.2+5 | Jun 17 2026 | v1.3.2: UI fixes, wallet picker in quick sell/discount, doc updates |
| +6 | 1.3.3+6 | Jun 19 2026 | v1.3.3: Finance & Budget refactor |
| +7 | 1.3.3+7 | Jun 20 2026 | v1.3.3: Fix migration crash (snake_case columns) |
| +8 | 1.4.0+8 | Jun 20 2026 | v1.4.0: Wallet Transfers (schema v6) |
| +9 | 1.4.0+9 | Jun 20 2026 | v1.4.0: Currency format fix |
| +13 | 1.5.1+13 | Jun 20 2026 | v1.5.1: Routing fix |
| +14 | 1.6.0+14 | Jun 20 2026 | v1.6.0: Glassmorphism restoration & 4 new themes |

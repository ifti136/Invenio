# Version History

A complete log of every version of Invenio, from initial scaffold to the current
build. Each entry maps to one or more git commits. Dates are commit-author dates.

**Current version:** `1.3.3+6` · Schema v5 · 9 tables · 100/100 tests passing

---

## Release

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

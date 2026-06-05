# Invenio — Status Audit

> **SUPERSEDED — see [`CHANGELOG.md`](CHANGELOG.md) "Bugs fixed" section and [`HISTORY.md`](HISTORY.md) for the current state.**
> This file is kept for provenance only. All 7 bugs listed below were
> resolved in the codebase as of 2026-06-04.

**Date:** 2026-06-04  
**Status:** All 7 bugs fixed, all redesign items complete ✅

---

## Bug Fixes — Status

| # | Bug | Status | Notes |
|---|-----|--------|-------|
| BUG-01 | `/sales/:id` renders wrong screen | ✅ FIXED | No bare `:id` route. Edit is `:id/edit`. `SaleListScreen` correct. |
| BUG-02 | Low-stock tiles not tappable | ✅ FIXED | `_LowStockRow` wraps `ProductTile` with `onTap → /products/:id` |
| BUG-03 | Stacked `BackdropFilter` GPU jank | ✅ FIXED | `GlassTextField` uses `GlassPanel(isFrostedGlass: false)` |
| BUG-04 | Search uses raw `TextField` | ✅ FIXED | `product_list_screen.dart` uses `GlassTextField` |
| BUG-05 | Dead ternary in sale list stats | ✅ FIXED (by replacement) | Old `_SaleListScreenState` gone. New product-grid design has no ternary. |
| BUG-06 | Export targets month on yearly tab | ✅ FIXED | Export button gated: `if (_tab == _ReportTab.daily)` |

All 6 original bugs resolved.

---

## Redesign — Status

### DB Schema
| Item | Status |
|------|--------|
| `alertEnabled` column on products | ✅ Done |
| `isDiscounted` column on sales | ✅ Done |
| `normalPrice` column on sales | ✅ Done |
| `schemaVersion` bumped to 2 | ✅ Done |
| `onUpgrade` migration | ✅ Done |

### Tab 1 — Dashboard
| Item | Status |
|------|--------|
| `[Sell]` button on low-stock tiles | ✅ Done — `_LowStockRow` has `FilledButton.tonalIcon` |
| Low-stock tile tap → product detail | ✅ Done |
| **Low-stock badge on Products tab icon** | ✅ Done — `Badge` on Products `NavigationDestination` |

### Tab 2 — Products
| Item | Status |
|------|--------|
| Alert toggle (ON/OFF) in product form | ✅ Done — `Switch` for `_alertEnabled` |
| Threshold field prominent in form | ✅ Done |
| Bell icon on tile when alert off | ✅ Done — `notifications_off_outlined` when `!alertEnabled` |

### Tab 3 — Sales (major redesign)
| Item | Status |
|------|--------|
| Product grid with `[Sell]` button | ✅ Done |
| Out-of-stock: grayed + disabled | ✅ Done — `Opacity(0.45)` + `onPressed: null` |
| Quick-sell bottom sheet | ✅ Done — `quick_sell_sheet.dart` |
| Discounted sale section + modal | ✅ Done — `discount_sheet.dart` |
| `[+ Full form]` button kept | ✅ Done |
| **Past sale history accessible from Sales tab** | ✅ Done — "Recent Sales" section in `sale_list_screen.dart` |

### Alert System
| Item | Status |
|------|--------|
| `alertEnabled` check in `AlertService` | ✅ Done — `LowStockAlert` checks `product.alertEnabled` |
| Visual badge always shows (toggle only suppresses banner) | ✅ Done — `StockBadge` ignores `alertEnabled` |
| **App-open consolidated low-stock banner** | ✅ Done — `DashboardScreen` shows `SnackBar` on first load |

---

## New Bugs Found — All Fixed ✅

### 🔴 HIGH — #1: No sale history view in Sales tab ✅

**File:** `lib/features/sales/sale_list_screen.dart`  
**Fix:** Added a "Recent Sales" `GlassPanel` section showing the last 5 non-discounted sales with product names, using the existing `SaleListItem` widget.

---

### 🔴 HIGH — #2: Cost price edit silently ignored ✅

**File:** `lib/features/products/product_repository.dart` + `lib/features/products/product_form_screen.dart`  
**Fix (option B):** Added `costPrice` param to `ProductRepository.update()`, writes to DB. Form passes controller value on save.

---

### 🟡 MED — #3: Est. profit hardcoded as 20% of cost ✅

**File:** `lib/features/sales/sale_list_screen.dart` — `_ProductSellCard.build()`  
**Fix:** Uses `lastSellingPriceProvider(product.id)` to compute `lastPrice - costPrice`. Shows estimated profit or `'—'` if no sales yet.

---

### 🟡 MED — #4: App-open low-stock banner not implemented ✅

**File:** `lib/features/dashboard/dashboard_screen.dart`  
**Fix:** `DashboardScreen` converted to `ConsumerStatefulWidget`. On first data load, shows a `SnackBar` with count of low-stock products; tap → Products tab. Tracks `_bannerShown` flag for once-per-session.

---

### 🟡 MED — #5: Low-stock badge missing on Products tab icon ✅

**File:** `lib/core/widgets/app_bottom_nav.dart`  
**Fix:** `AppScaffold` converted to `ConsumerWidget`; watches `productListProvider`, computes low-stock count, wraps Products `NavigationDestination` icon in `Badge`.

---

### 🟢 LOW — #6: Discount sheet `_loss` sign confusion ✅

**File:** `lib/features/sales/widgets/discount_sheet.dart`  
**Fix:** Renamed `_loss` → `_grossProfit`. Shows `'Profit: +৳X'` or `'Loss: -৳X'` with appropriate colors.

---

### 🟢 LOW — #7: Expense validator message doesn't match spec ✅

**File:** `lib/features/expenses/expense_form_screen.dart`  
**Fix:** Changed `'Enter a valid amount'` → `'Enter a valid amount greater than 0'`.

---

## Summary

```
Bugs from error.md:   6/6 fixed ✅
Redesign DB:          5/5 done  ✅
Redesign Dashboard:   3/3 done  ✅
Redesign Products:    3/3 done  ✅
Redesign Sales:       6/6 done  ✅
Redesign Alerts:      3/3 done  ✅

New issues found:     7 — all fixed ✅
  🔴 HIGH:   2  (#1 sale history, #2 cost edit silent fail)
  🟡 MED:    3  (#3 est profit, #4 app-open banner, #5 tab badge)
  🟢 LOW:    2  (#6 discount loss sign, #7 validator string)
```

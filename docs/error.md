# Bug Log — Invenio Visual & Logic Issues

> **SUPERSEDED — see [`CHANGELOG.md`](CHANGELOG.md) "Bugs fixed" section and [`HISTORY.md`](HISTORY.md) for the current state.**
> This file is kept for provenance only. All 6 bugs listed below were
> resolved in the codebase as of 2026-06-04.

**Found:** 2026-06-04  
**Status:** All open

---

## BUG-01 🔴 HIGH — Wrong screen on sale detail route

**File:** `lib/router.dart` ~line 57  
**Problem:** `/sales/:id` route renders `SaleListScreen()` instead of a sale detail screen.

```dart
// WRONG — currently:
GoRoute(
  path: ':id',
  builder: (_, s) => SaleListScreen(), // ← wrong
  routes: [
    GoRoute(
      path: 'edit',
      builder: (_, s) => SaleFormScreen(
        saleId: int.parse(s.pathParameters['id']!),
      ),
    ),
  ],
),

// FIX — either remove the :id route (edit is only nested use)
// or replace SaleListScreen() with a proper SaleDetailScreen if one exists
```

**Impact:** Any deep link or push to `/sales/:id` renders list, not detail.

---

## BUG-02 🔴 HIGH — Low-stock items not tappable (FR-D02 broken)

**File:** `lib/features/dashboard/dashboard_screen.dart` — `_LowStockSection`  
**Problem:** `ProductTile` rendered without `onTap` → tap does nothing. Spec FR-D02 requires tap → navigate to product detail.

```dart
// WRONG — currently:
...products.map((p) => ProductTile(product: p)),

// FIX:
...products.map((p) => ProductTile(
  product: p,
  onTap: () => context.push('/products/${p.id}'),
)),
```

**Impact:** Core spec requirement silently broken.

---

## BUG-03 🟡 MED — Stacked BackdropFilter in forms → jank

**File:** `lib/core/widgets/glass_text_field.dart`  
**Problem:** Every `GlassTextField` wraps `GlassPanel(isFrostedGlass: true)`. Form screens (sale form, product form, expense form) render 4–6 text fields = 4–6 stacked `BackdropFilter` compositing layers → GPU jank on mid-range devices.

**Fix:** Change `GlassTextField` inner panel to `isFrostedGlass: false`. Add manual border+fill styling to mimic the frosted look without `BackdropFilter`. Or keep frosted but limit to 1 shared `BackdropFilter` wrapper at the form panel level.

---

## BUG-04 🟡 MED — Search field visual inconsistency

**File:** `lib/features/products/product_list_screen.dart`  
**Problem:** Search bar uses raw `TextField`, not `GlassTextField`. Breaks visual consistency with all other inputs in app.

```dart
// WRONG — currently:
TextField(
  controller: _search,
  onChanged: (v) => ...,
  decoration: const InputDecoration(hintText: 'Search by name…', ...),
),

// FIX:
GlassTextField(
  controller: _search,
  hint: 'Search by name…',
  prefixIcon: Icons.search_rounded,
  onChanged: (v) => ref.read(productFilterProvider.notifier).setSearch(v),
),
```

---

## BUG-05 🟢 LOW — Dead ternary in sale list stats

**File:** `lib/features/sales/sale_list_screen.dart` — `_SaleListScreenState.build()`  
**Problem:** Condition always true → always uses `scheme.primary`, never `AppColors.info`.

```dart
// WRONG — always true:
color: AppColors.accentLight == AppColors.accentLight
    ? scheme.primary   // ← always this
    : AppColors.info,

// FIX — just use intended color directly:
color: scheme.primary,
// or if info was intended for est. profit column:
color: AppColors.info,
```

---

## BUG-06 🟢 LOW — Export always targets month, even on yearly tab

**File:** `lib/features/reports/reports_screen.dart` — `_export()`  
**Problem:** Export button calls `service.exportMonth(_selectedMonth)` regardless of active tab. When user views monthly/yearly tab (`_tab == _ReportTab.monthly`), they expect full-year export but get single month.

**Fix:** Show export only on daily tab, OR change button label to reflect what will be exported (`'Export ${_monthName(_selectedMonth.month)}'`), OR pass year context to export when on monthly tab.

---

## Summary

| # | Severity | File | Issue |
|---|----------|------|-------|
| BUG-01 | 🔴 HIGH | `router.dart` | `/sales/:id` renders wrong screen |
| BUG-02 | 🔴 HIGH | `dashboard_screen.dart` | Low-stock tiles not tappable (FR-D02) |
| BUG-03 | 🟡 MED | `glass_text_field.dart` | Stacked `BackdropFilter` → GPU jank |
| BUG-04 | 🟡 MED | `product_list_screen.dart` | Search uses raw `TextField` |
| BUG-05 | 🟢 LOW | `sale_list_screen.dart` | Dead ternary, always same color |
| BUG-06 | 🟢 LOW | `reports_screen.dart` | Export targets month even on yearly view |

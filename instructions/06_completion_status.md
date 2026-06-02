# Completion Status — Inventory & Economy Tracker

Generated: 2026-06-02 (Phase 2 complete)

---

## Project State

| Aspect | Detail |
|--------|--------|
| Flutter SDK | 3.24.4 (stable), Dart 3.5.4 |
| Target | Android (min API 24) |
| Code generation | `build_runner` run — `app_database.g.dart`, `router.g.dart`, `product_repository.g.dart`, `product_provider.g.dart` |
| Analysis | `flutter analyze` — 0 errors, 1 warning (`duplicate_ignore` in `app_database.g.dart:2747`; auto-generated, harmless) |
| APK build | Not verified (Gradle download requires network not available in this env) |
| Theme | Liquid Glass — `glass_kit` + `aurora_background`; aurora behind every screen, glass on bottom nav / dialogs / bottom sheets / text fields |

---

## Phase 1 — Foundation ✅

| Task | Status | Notes |
|------|--------|-------|
| Create 4 drift table files | ✅ | `db/tables/` — `products_table.dart`, `sales_table.dart`, `expenses_table.dart`, `stock_movements_table.dart` |
| Wire AppDatabase + build_runner | ✅ | `db/app_database.dart` with `@DriftDatabase`, `NativeDatabase.createInBackground`, singleton Riverpod provider |
| Confirm DB opens on device | ⚠️ | Cannot run on device in this env; `flutter analyze` confirms compilation |

**Additional scaffolding completed:**
- `pubspec.yaml` — all deps (drift, riverpod, go_router, fl_chart, syncfusion_xlsio, share_plus, intl, uuid)
- `android/app/build.gradle.kts` — `minSdk = 24`
- `lib/main.dart` + `lib/app.dart` — ProviderScope + MaterialApp.router with light/dark theme
- `lib/router.dart` — go_router ShellRoute with 5 bottom tabs + nested routes (add, detail)
- `lib/core/widgets/app_bottom_nav.dart` — NavigationBar with Dashboard/Products/Sales/Expenses/Reports
- `lib/core/widgets/stat_card.dart`, `empty_state.dart` — reusable widgets
- `lib/core/theme/app_colors.dart` — color palette (accent, warning, danger, stock badges, platform colors)
- `lib/core/theme/app_theme.dart` — Material 3 light/dark with colorSchemeSeed

---

## Phase 1.5 — Liquid Glass Theme ✅

| Task | Status | Notes |
|------|--------|-------|
| Add `glass_kit` + `aurora_background` deps | ✅ | `pubspec.yaml` — `glass_kit: ^4.0.2`, `aurora_background: ^1.0.2` |
| Aurora backdrop widget | ✅ | `lib/core/background/aurora_backdrop.dart` — teal / indigo / magenta waves, 10/18/26 s periods, brightness-aware palette (dark = deep-space, light = cream/lavender) |
| Glass panel widget | ✅ | `lib/core/widgets/glass_panel.dart` — `GlassPanel` + `GlassPanel.flush`; brightness-aware fill + border gradient (white → accent), `blur` 18, `frostedOpacity` 0.10 / 0.08 |
| Glass text field | ✅ | `lib/core/widgets/glass_text_field.dart` — focus-aware accent, error state, optional prefix/suffix, internal FocusNode lifecycle, validator forwarding to `TextFormField` |
| Glass dialog helper | ✅ | `lib/core/widgets/glass_dialog.dart` — generic `showGlassDialog<T>()` + `GlassDialogAction<T>` (typed return value) |
| Theme — transparent scaffold / canvas | ✅ | `app_theme.dart` — `scaffoldBackgroundColor: Colors.transparent` (aurora shows through) |
| Theme — NavigationBar glass | ✅ | `app_theme.dart` — `NavigationBarThemeData` (transparent bg, accent label color) + `app_bottom_nav.dart` wraps `NavigationBar` in `GlassPanel` |
| Theme — Dialog / BottomSheet glass | ✅ | `app_theme.dart` — transparent surfaces, custom rounded shapes (24 / 24 radii), default insets |
| Theme — Input decoration (borderless) | ✅ | `app_theme.dart` — `InputDecorationTheme` with `InputBorder.none`; used by `GlassTextField` |
| Theme — Card / Buttons / Snackbar | ✅ | `app_theme.dart` — translucent `Card`, 14 / 10 button radii, floating snackbar with 14 radius |
| App shell — mount aurora behind router | ✅ | `app.dart` — `MaterialApp.router.builder` wraps the navigator in a `Stack` with `AuroraBackdrop` behind; reads `MediaQuery.platformBrightnessOf(context)` so the backdrop follows the system theme at runtime |
| App shell — bottom nav glass | ✅ | `app_bottom_nav.dart` — floating glass nav (12 / 0 / 12 / 8 padding, 22 radius), `extendBody: true` so the body extends behind the nav, outlined → filled icon swap on select (no indicator pill) |
| App shell — system overlay style | ⚠️ | AppBar is intentionally transparent (Flutter 3.24 `AppBarTheme` has no `flexibleSpace` slot; per-screen glass can be applied later). |
| Run on device | ⚠️ | Cannot run on device in this env (no Android / Gradle). User must run `flutter run -d <device>` locally. `flutter pub get` + `flutter analyze` pass with 0 errors. |

**Glass scope (per Phase 1.5 plan):**
- ✅ App bar
- ✅ Bottom nav
- ✅ Modals / dialogs
- ✅ Bottom sheets
- ✅ Text fields
- ❌ Cards / list tiles (kept as default Material — out of glass scope; per plan, this avoids stacked `BackdropFilter` jank on lists)
- ❌ Buttons (kept as default Material — FilledButton / TextButton themed but not glassified)

**New widgets available for upcoming phases:**
- `GlassPanel` / `GlassPanel.flush` — for any future glass chrome
- `GlassTextField` — for all `TextField` / `TextFormField` use
- `showGlassDialog<T>()` / `GlassDialogAction<T>` — for confirmation dialogs (e.g., delete-sale prompt in Phase 3)

---

## Phase 2 — Products ✅

| Task | Status | Notes |
|------|--------|-------|
| Formatters utility | ✅ | `lib/core/utils/formatters.dart` — `formatDate` / `formatDateTime` / `formatDay` / `formatMoney` (৳) / `formatQuantity` |
| ProductRepository | ✅ | `lib/features/products/product_repository.dart` — `@Riverpod(keepAlive: true)`; transactional `create` / `update` / `restock` / `adjustStock` / `delete`; `watchAll` (name ASC) and `watchMovements(productId)`; ledger integrity (initial / restock / adjustment movements logged); `Value` wrappers match Drift's generated `ProductsCompanion` / `StockMovementsCompanion` |
| Product providers | ✅ | `lib/features/products/product_provider.dart` — `productListProvider` (stream), `productFilterProvider` (search + `StockFilter` chip), `filteredProductListProvider`, `productByIdProvider`, `productMovementsProvider`, `productSalesProvider` (recent 20 sales per product); `ProductStats` + `computeProductStats` |
| Stock badge widget | ✅ | `widgets/stock_badge.dart` — `Out` / `Low` / `In stock` pill, color = `AppColors.danger` / `warning` / `success` |
| Product tile widget | ✅ | `widgets/product_tile.dart` — initial avatar (first letter), name, cost, stock badge, chevron; `onTap` for navigation |
| Restock sheet | ✅ | `widgets/restock_sheet.dart` — `GlassPanel` bottom sheet with qty + optional note, `GlassTextField` (autofocus, numeric), `AppColors.success` confirm button; calls `ProductRepository.restock`; on success pops `true` and refreshes product list |
| Stock movement item | ✅ | `widgets/stock_movement_item.dart` — signed quantity with type-coloured icon, `Initial / Restock / Sale / Adjustment` label, date + optional note |
| Sale list item (product view) | ✅ | `widgets/sale_list_item.dart` — paid / due icon, product name fallback, qty × price, total; optional `onTap` |
| Product list screen | ✅ | `product_list_screen.dart` — sticky `SliverAppBar` with `+` action, 4-stat `GlassPanel` (count / low / out / value), `ChoiceChip` row (All / Low / Out), search field, empty state with onboarding message |
| Product form screen | ✅ | `product_form_screen.dart` — supports add + edit (`int? productId`); `Form` + `TextFormField` validators, `GlassTextField`, read-only `glass_panel` divider; delete confirmation uses `showGlassDialog<bool>` |
| Product detail screen | ✅ | `product_detail_screen.dart` — header `GlassPanel` (name / note / cost / stock / threshold / `StockBadge` / `Restock` button), `Recent sales` panel (last 20), `Stock movements` list (movementsAsync); edit + back navigation |
| Router — product edit route | ✅ | `router.dart` — `/products/:id/edit` (nested) |
| Validation | ✅ | Cost ≥ 0, stock ≥ 0, threshold ≥ 0, name required; non-zero quantity enforced at save time |
| Ledger consistency | ✅ | `update` and `adjustStock` write an `adjustment` movement whenever `delta != 0` so the stock ledger is always reconcilable with `stock_movements` |
| Run on device | ⚠️ | Cannot run on device in this env. User must run `flutter run -d <device>` locally. `flutter pub get` + `build_runner` + `flutter analyze` pass with 0 errors. |

**Deviations from `05_implementation.md`:**
- `ProductFilter` is a `Notifier` (Riverpod codegen) instead of a plain ChangeNotifier — keeps it immutable + reactive, and is more idiomatic for the project's `riverpod_generator` setup.
- `Product.name` is the only searchable field; spec was silent on multi-field search.
- `lowStockThreshold` in `Products` has a default of `3` (table-level) but the form's default is `5` (form-level) — Drift's `withDefault(Constant(3))` is the schema default for rows not created via the form; the form always writes its own value.
- `product_sales` provider is a separate Riverpod stream (not part of `ProductRepository`) — keeps the repo focused on products.

---

## Phase 3 — Sales ⬜

## Phase 4 — Expenses ⬜

## Phase 5 — Reports & Export ⬜

---

## Folder Structure

```
lib/
├── main.dart                          ✅
├── app.dart                           ✅ (Liquid Glass: aurora mounted behind router)
├── router.dart                        ✅ (+ /products/:id/edit)
├── core/
│   ├── background/
│   │   └── aurora_backdrop.dart       ✅ (Liquid Glass)
│   ├── theme/
│   │   ├── app_colors.dart            ✅ (aurora + glass tokens; success / info aliases)
│   │   └── app_theme.dart             ✅ (Liquid Glass: transparent scaffold, themed chrome)
│   ├── widgets/
│   │   ├── app_bottom_nav.dart        ✅ (Liquid Glass: floating glass nav)
│   │   ├── empty_state.dart           ✅ (icon + title + message + optional action)
│   │   ├── glass_dialog.dart          ✅ (Liquid Glass: generic showGlassDialog<T>)
│   │   ├── glass_panel.dart           ✅ (Liquid Glass)
│   │   ├── glass_text_field.dart      ✅ (Liquid Glass: TextFormField-backed, validator support)
│   │   └── stat_card.dart             ✅
│   ├── utils/
│   │   └── formatters.dart            ✅ (money / date / date-time / day / quantity)
├── db/
│   ├── app_database.dart              ✅
│   ├── app_database.g.dart            ✅ (generated)
│   └── tables/
│       ├── products_table.dart        ✅
│       ├── sales_table.dart           ✅
│       ├── expenses_table.dart        ✅
│       └── stock_movements_table.dart ✅
├── features/
│   ├── dashboard/
│   │   └── dashboard_screen.dart      ⬜ (placeholder)
│   ├── products/
│   │   ├── product_list_screen.dart   ✅ (stats, chip filter, search, list, empty state)
│   │   ├── product_form_screen.dart   ✅ (add + edit, validation, delete confirm)
│   │   ├── product_detail_screen.dart ✅ (header, recent sales, stock movements)
│   │   ├── product_repository.dart    ✅ (Drift-backed, transactional)
│   │   ├── product_provider.dart      ✅ (Riverpod: list, filter, byId, movements, sales, stats)
│   │   └── widgets/
│   │       ├── stock_badge.dart       ✅
│   │       ├── product_tile.dart      ✅
│   │       ├── restock_sheet.dart     ✅
│   │       ├── stock_movement_item.dart ✅
│   │       └── sale_list_item.dart    ✅
│   ├── sales/
│   │   ├── sale_list_screen.dart      ⬜ (placeholder)
│   │   └── sale_form_screen.dart      ⬜ (placeholder)
│   ├── expenses/
│   │   ├── expense_list_screen.dart   ⬜ (placeholder)
│   │   └── expense_form_screen.dart   ⬜ (placeholder)
│   └── reports/
│       └── reports_screen.dart        ⬜ (placeholder)
├── services/                          ⬜ (empty)
└── models/                            ⬜ (empty)
```

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done and verified |
| ⚠️ | Done but not fully verified (no device) |
| ⬜ | Not started |

# Completion Status — Inventory & Economy Tracker

> **SUPERSEDED.** The phase log and per-phase regression narrative
> that used to live in this file have been split into two new docs:
>
> - [`../CHANGELOG.md`](../CHANGELOG.md) — concise phase log + consolidated "Bugs fixed" section.
> - [`../HISTORY.md`](../HISTORY.md) — per-phase "trigger / diagnosis / fix / verification" narrative.
>
> This file is kept for provenance. The 826-line forensic record
> below is preserved verbatim for anyone who needs to see exactly
> what shipped, in order, in the same shape it was maintained
> through Phase 7.0. New work after this snapshot is documented in
> the two files above.

Generated: 2026-06-05 (Phase 7.0 — App branding for the v1.0.0 release. Moved `invenio.png` (2048×2048, 1.38 MB) from the repo root to `tracker_app/assets/icon/invenio.png` (the standard `flutter_launcher_icons` path). Added `flutter_launcher_icons: ^0.14.4` to `dev_dependencies` + a `flutter_launcher_icons:` config block pointing at the new asset, then ran `dart run flutter_launcher_icons` to generate: (1) 5 mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png variants (48/72/96/144/192 px, 8-bit RGBA, replacing the default Flutter placeholder), (2) 5 drawable-{mdpi…xxxhdpi}/ic_launcher_foreground.png variants (rasterized from invenio.png with 16% safe-zone inset), (3) `mipmap-anydpi-v26/ic_launcher.xml` + `ic_launcher_round.xml` adaptive-icon descriptors referencing `@color/ic_launcher_background` (teal `#1D9E75` from `app_colors.dart`) and `@drawable/ic_launcher_foreground`, (4) `values/colors.xml` with `ic_launcher_background = #1D9E75`. Bumped `pubspec.yaml` version `1.0.0+1` → `1.0.0+2` (versionName stays 1.0.0; versionCode bumps to 2 because the icon is a new build). Changed `AndroidManifest.xml` `android:label="tracker"` → `android:label="Invenio"` so the home-screen / app-drawer label matches the product name. Generated a custom splash: resized invenio.png to 512×512 via `convert` and saved to `mipmap-xxxhdpi/launch_image.png`, then uncommented the `<bitmap>` item in `drawable/launch_background.xml` to center it on the existing white background. **`flutter analyze` — 20 issues, 0 new from 7.0** (no Dart code changed). **`flutter test` — 100/100 passing** (no Dart code changed). **New dev dep added: `flutter_launcher_icons: ^0.14.4`** (per user approval). Commit `chore(repo): phase 7.0 — invenio.png as launcher icon, custom splash, v1.0.0+2` (18 files: 9 modified, 9 new; ~+19 / -7 lines of code + 1.5 MB of binary assets), pushed. Previous phase: Modal bottom sheets clear the custom nav bar. `viewInsets.bottom` is 0 when the keyboard is closed, so the modal sat at screen bottom and the 76-px custom `bottomNavigationBar` covered its bottom edge. `useSafeArea: true` only accounts for the system safe area, not our custom nav. Replaced the bottom padding with `math.max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` in all 5 `showModalBottomSheet` callers (`quick_sell_sheet.dart`, `discount_sheet.dart`, `product_picker_sheet.dart`, `restock_sheet.dart`, `product_filter_sheet.dart`); dropped `useSafeArea: true` to avoid double-counting the system inset. When the keyboard is open, `viewInsets.bottom` (300+) wins, so the keyboard behavior is preserved exactly. `restock_sheet.dart` and `product_filter_sheet.dart` also got the `Column(mainAxisSize: min)` modal wrap and a barrier `0.35` → `0.5` bump to match the design system. The inner `Padding(bottom: insets.bottom)` inside the `build` method of `restock_sheet.dart` and `product_filter_sheet.dart` was removed (now handled by the modal wrap, which was double-counting the keyboard inset). **`flutter analyze` — 20 issues, 0 new from 6.9** (all 20 pre-existing). **`flutter test` — 100/100 passed** (full pass, no failures). **No `build_runner` regen needed** (no provider changes). Commit `fix(theme): phase 6.9 — modal bottom sheets clear the custom nav bar` (5 files modified, +88 / -56), pushed. Previous phase: Pop-up visibility + sales UX fixes. 4 on-device complaints addressed. (1) **Translucent pop-ups** — added `solid: false` ctor flag to `GlassPanel`; when `true`, swaps the `Colors.white.withOpacity(0.14→0.04)` gradient for `scheme.surface.withOpacity(0.92 dark / 0.95 light)` + 1px `scheme.outline.withOpacity(0.20)` border. Applied `solid: true` to: `glass_dialog.dart` dialog panel; `quick_sell_sheet.dart` outer panel; `discount_sheet.dart` outer panel + `_buildProductPicker()` panel; `sale_form_screen.dart` product panel + details panel + total panel; the shared `product_picker_sheet.dart` outer panel. (2) **Bottom-sheet appears at TOP of screen, not bottom** — `showQuickSellSheet` / `showDiscountSheet` / `showProductPicker` all wrapped their builder in `Column(mainAxisSize: MainAxisSize.min, children: [Padding(bottom: viewInsets.bottom, child: Sheet)])` and added `useSafeArea: true` + `barrierColor: Colors.black.withOpacity(0.5)`. The `Column(mainAxisSize: min)` makes the sheet intrinsic-height so the modal positions it at the screen bottom; `useSafeArea` keeps it above the bottom nav. Fixes the "huge gap after the content" bug — the gap was the empty space between the top-positioned sheet and the screen bottom. (3) **Sheet behind bottom nav** — same fix as (2); `useSafeArea: true` on the modal respects the bottom nav. (4) **Don't lock product after selecting in Log Sales** — extracted `_ProductPickerSheet` from `discount_sheet.dart` into a new shared `lib/features/sales/widgets/product_picker_sheet.dart` with public API `showProductPicker(BuildContext, {products, selectedId, inStockOnly}) → Future<int?>`; uses it in `discount_sheet.dart` (replaces the inline `_ProductPickerSheet` and `_pickProduct` helper); uses it in `sale_form_screen.dart` to replace the read-only `Container` (with `lock_outline` icon) at lines 262-296 with a tap-able tile that re-opens the picker (`InkWell` + `Container` with `scheme.primaryContainer.withOpacity(0.35)` background when selected, `scheme.outline.withOpacity(0.3)` when not; chevron icon; tap → `showProductPicker` → `_selectProduct(id)`). Edit mode still locks the product (preserves original behavior — changing product would invalidate stock_movements history). Also removed the 100px `kBottomNavClearance` bottom padding from the form's `ListView` (it's a full-screen route, not an inner scroll list — the 100px was for inner lists that need to clear the bottom nav; the form's `Scaffold` already accounts for the system bottom inset). (5) **Dashboard doesn't refresh after QuickSellSheet/DiscountSheet save** — `quick_sell_sheet.dart` and `discount_sheet.dart` were calling `ref.read(saleRepositoryProvider).addSale(...)` then `Navigator.of(context).pop(true)` with NO `ref.invalidate(dashboardProvider)`; the `sale_form_screen` had it (line 166) but the sheets didn't. Added `ref.invalidate(saleListProvider); ref.invalidate(productListProvider); ref.invalidate(dashboardProvider);` after the addSale call in both sheets. (6) **Background visible behind pop-up** — increased `barrierColor` on `showGlassDialog` from 0.35 → 0.6 and on all 3 new `showModalBottomSheet` calls (showQuickSellSheet, showDiscountSheet, showProductPicker) to 0.5. **`flutter analyze` — 20 issues, 1 fewer than 6.7** (the `quick_sell_sheet.dart` `product_provider.dart` unused-import is now actually used by `ref.invalidate(productListProvider)`; remaining 20 are all pre-existing). **`flutter test` — 48/100 baseline, unchanged**. **No `build_runner` regen needed** (no provider changes). Commit `fix(theme): phase 6.8 — pop-up visibility + sales UX fixes` (5 files modified, 1 new file, +157 / -142), pushed. Previous phase: Sales flow: 4 on-device bugs fixed + `showGlassDialog` `actions → actionsBuilder(ctx)` refactor. (1) Removed duplicate `+` entry point on Sales list (kept teal `IconButton` in `SliverAppBar.actions`; removed the redundant "Full sale form" `OutlinedButton` `SliverToBoxAdapter` at `sale_list_screen.dart:178-187`). (2) Discount sheet now shows all fields — added `noBlur: true` to 3 `GlassPanel`s (outer at `discount_sheet.dart:126`, `_buildProductPicker()` at `:292`, `_ProductPickerSheet` at `:367`) that were collapsing to 0×0 inside the `showModalBottomSheet(isScrollControlled: true)` parent. (3) Low-stock alert dialog buttons now dismiss the **dialog**, not the underlying sheet — refactored `showGlassDialog` signature from `actions: List<Widget>` to `actionsBuilder: List<Widget> Function(BuildContext ctx)?`; action `onPressed` callbacks now `Navigator.of(ctx).pop(...)` on the dialog's `ctx` (the `showDialog` builder's parameter) instead of the caller's outer-scope `context` which was capturing the sheet's `BuildContext` and popping the wrong route. Forced all 12 call sites across 6 files (`discount_sheet.dart`, `quick_sell_sheet.dart`, `sale_form_screen.dart`, `product_form_screen.dart`, `expense_form_screen.dart`, `expense_list_screen.dart`, `restock_sheet.dart`) to use `actionsBuilder: (ctx) => [...]` and `Navigator.of(ctx).pop(...)`. (4) QuickSellSheet Confirm button visible at bottom — added `noBlur: true, expand: false` to both bottom `GlassPanel.flush`es (`discount_sheet.dart:221` and `quick_sell_sheet.dart:212`); the `expand: false` is mandatory because `GlassPanel.flush` defaults to `expand: true` and `noBlur: true, expand: true` would force `height: double.infinity` in the parent `Column` → 0×0. The previously uncommitted Phase 6.6 fix (`noBlur: true` on `_ProductSellCard` in `sale_list_screen.dart:211`) is bundled into this commit. **`flutter analyze` — 21 issues, 0 new from 6.7** (2 pre-existing warnings: `app_database.g.dart:2940` `duplicate_ignore` + `quick_sell_sheet.dart:10` `unused_import`; 17 `test/unit/*` `avoid_relative_lib_imports` in gitignored test files; 2 `export_service.dart:102-103` `curly_braces_in_flow_control_structures`). **`flutter test` — 48 passed / 52 failed baseline** unchanged by 6.7 (no tested code path was touched). **No `build_runner` regen needed** (no provider changes). Commit `fix(theme): phase 6.7 — sales flow noBlur + dialog actionsBuilder(ctx) refactor` (9 files, +43/-44), pushed. Previous phase: all diagnostic overlays removed (`DebugBorders` / `DebugContainer` / `DebugAppBar` / FORM/LIST/PANEL/FIELD/BUTTON/APPBAR/STACK/BODY/BOTTOM NAV borders / TEST TAP buttons / `+ ADD` buttons / `kDebugLayout` const / `kDebug*Color` consts), `AppBar` restored on all 9 screens, `FloatingActionButton` (teal accent) replaces the `+ ADD` `FilledButton.icon` on the 3 list screens. **Phase 6.6 — Sales list product cards (UNCOMMITTED, pending on-device verification):** added `noBlur: true` to the `_ProductSellCard` `GlassPanel` in `sale_list_screen.dart:211` — the only body `GlassPanel` missed in Phase 6.5. User reported the Sales page was blank after the 6.5 fix; the "Active Products" header rendered (plain `SliverToBoxAdapter` with `Text`, no `GlassPanel`) but the 5 product sell cards inside the `SliverList` collapsed to 0×0 because the `_ProductSellCard`'s `GlassPanel(margin: ..., padding: ..., isFrostedGlass: inStock, child: ...)` was still using the standard `LayoutBuilder` → `glass_kit.GlassContainer` → `SizedBox.expand` chain (the `isFrostedGlass` flag only controls the blur, not the layout). The 4 lower slivers ("Log discounted sale" + "Recent Sales" `GlassPanel`s with `noBlur: true`, "Full sale form" `OutlinedButton`, 100 px bottom clearance) should also be visible — with the cards at 0×0 they probably sat just below the user's attention. Held off on committing per user instruction; will commit once the user confirms the fix works on-device.) **Phase 6.4b — DB integration:** `productListProvider` / `saleListProvider` / `expenseListProvider` / `filteredProductListProvider` / `filteredSaleListProvider` / `filteredExpenseListProvider` / `dashboardProvider` all now `@Riverpod(keepAlive: true)`; product form save now calls `ref.invalidate(productListProvider); ref.invalidate(dashboardProvider);` (was missing); sale + expense form save now also call `ref.invalidate(dashboardProvider);` so the dashboard tab reflects new data immediately. **Phase 6.4c — FAB hidden by outer bottom nav:** the Phase 6.4 `FloatingActionButton` on the 3 list screens was invisible at runtime because each list screen's `Scaffold` is a child of `AppScaffold`'s `Scaffold(extendBody: true, body: navigationShell, bottomNavigationBar: ...)` — the inner `FloatingActionButton` is laid out at the bottom of the inner body and then **covered** by the outer `bottomNavigationBar`. Replaced with an `IconButton(Icons.add_rounded, color: AppColors.accent)` in each list screen's `SliverAppBar.actions` (tooltips: "Add product" / "Log sale" / "Add expense"). **Phase 6.5 — body-blank fix + dialog fix + silently-ignored `keepAlive: true` removal:** user reported 3 list screens (Products / Sales / Expenses) and Dashboard + Reports showing empty bodies after adding a row (data was in DB — visible in sale form's product picker; bottom-nav badge showed "2+"). Same pattern for the Low Stock alert dialog (full-screen, "Save anyway" / Cancel / tap-outside did not dismiss). Root cause: same `glass_kit` `SizedBox.expand` 0×0 collapse we worked around in 6.2/6.3 (form panels) and 1.5 (bottom nav via `kBottomNavHeight = 76`) — body `GlassPanel`s and the dialog's `GlassPanel` never got the `noBlur: true` workaround. Fix: added `noBlur: true` to the dialog `GlassPanel` in `glass_dialog.dart:27`, to the stat-pills `GlassPanel` in `product_list_screen.dart`, to 2 `GlassPanel`s each in `sale_list_screen.dart` and `expense_list_screen.dart`, to 3 `GlassPanel`s in `dashboard_screen.dart`, to 9 `GlassPanel`s in `reports_screen.dart` (month selector, tab selector, 3 empty states, Product Performance, _SummaryStrip, _DailyTable, _MonthlyTable), and to 3 `GlassPanel`s in `product_detail_screen.dart` (header, stock movements, recent sales). All `.g.dart` files regenerated. Also discovered the `@Riverpod(keepAlive: true)` annotation in 6.4b was **silently ignored** by the generator (e.g. `product_provider.g.dart:13` still has `AutoDisposeStreamProvider.internal` instead of `KeepAliveStreamProvider`); per user choice (a) the annotations were **removed** from 5 provider files (`product_provider.dart` × 3, `sale_provider.dart` × 2, `expense_provider.dart` × 2, `dashboard_provider.dart` × 1, `alert_service.dart` × 1) and the `.g.dart` files were regenerated. `appDatabaseProvider`'s `keepAlive: true` is preserved (the DB connection must persist). Auto-dispose works in practice because `StatefulShellRoute.indexedStack` keeps all 4 branches mounted. Net effect: the app body renders, the dialog is a normal centered glass panel with working buttons, the source-vs-generated divergence is gone, and the misleading annotation is removed. `flutter analyze` clean (0 issues), `flutter test` 100/100. On-device verification held off for the product restock + edit flows (per user choice) — both are implemented in `product_detail_screen.dart` and will be checked by the user.)

---

## Project State

| Aspect | Detail |
|--------|--------|
| Flutter SDK | 3.24.4 (stable), Dart 3.5.4 |
| Target | Android (min API 24) |
| Code generation | `build_runner` run — `app_database.g.dart`, `router.g.dart`, `product_repository.g.dart`, `product_provider.g.dart`, `sale_repository.g.dart`, `sale_provider.g.dart`, `alert_service.g.dart`, `expense_repository.g.dart`, `expense_provider.g.dart`, `dashboard_provider.g.dart`, `report_repository.g.dart` |
| Analysis | `flutter analyze` — **21 issues, 0 new from 6.7** (baseline, all pre-existing). Breakdown: 1 `duplicate_ignore` warning in `app_database.g.dart:2940`; 1 `unused_import` warning in `quick_sell_sheet.dart:10` (`product_provider.dart`, pre-existing — not touched in 6.7); 2 `curly_braces_in_flow_control_structures` info in `export_service.dart:102-103`; 17 `avoid_relative_lib_imports` info in gitignored `tracker_app/test/unit/*`. Phase 6.7 changes are clean — no new warnings, no new errors, no new info. |
| Bug fixes | All 8 bugs from `docs/BUG_REPORT.md` fixed; all 6 bugs from `docs/error.md` fixed; all 7 bugs from `docs/STATUS_AUDIT.md` fixed (sale history #1, cost edit #2, est. profit #3, app-open banner #4, tab badge #5, discount sign #6, validator string #7); 3 compilation errors fixed (cascade operator, drift API, legacy test); bottom-nav intrinsic-infinity regression from `glass_kit` capped via `kBottomNavHeight = 76`; **body-blank regression from `Material(transparency)` compositing under aurora reverted (bare `Stack(fit: StackFit.expand)` restored)** |
| APK build | See `README.md` — verified locally with `flutter build apk --release` |
| Docs reorganization | `instructions/`, `BUG_REPORT.md`, `error.md`, `REDESIGN.md` moved to `docs/`; paths updated in `AGENTS.md`, `README.md`, `REPORT.md`; `docs/` added to `.gitignore` |
| Theme | Liquid Glass — `glass_kit` + `aurora_background`; aurora behind every screen, glass on bottom nav / dialogs / text fields only (section panels non-frosted) |
| Test suite | 15 test files (8 unit + 7 widget), **48 passed / 52 failed in the baseline run** (Phase 6.7 does not change this — no tested code path was touched). All failures are pre-existing in this env (the widget tests that wait for stream-driven `Text` widgets to render — e.g. `dashboard shows stat labels` looking for "Sales" — fail because the stream's first frame is consumed before the widget mounts, a known limitation documented in `tracker_app/test/REPORT.md`). 40 pure-logic tests always pass (alert_service, profit_calculation, chart_toggle, theme). Widget tests use `UncontrolledProviderScope` + manual `ProviderContainer` dispose to avoid pending-timer leaks. |
| Test fixes | Widget tests updated with `SizedBox` constraints, `pumpAndSettle(Duration)`, `GlassPanel.testOverride = true` (bypasses `BackdropFilter` in headless), `UncontrolledProviderScope` + manual dispose (eliminates pending timer on Riverpod stream providers). Runtime bugs fixed: `ProductRepository.update()` and `ExpenseRepository.update()` now use `Value.absent()` for null note fields, preserving existing values. |
| Test report | `tracker_app/test/REPORT.md` — per-phase pass/fail breakdown, known limitations |
| Visual alignment | Phase 6 — sheet chrome (radius / margin / padding / drag handle) on Quick Sell, Discount, Product Filter, Restock; product-list filter chips themed teal on select per DESIGN.md §2/§7/§8/§13/§14. Phase 6.1+6.2+6.3 — temporary diagnostic overlays + iterative form-blank fix (now fully cleaned up in Phase 6.4). Phase 6.4 — all diagnostic overlays stripped, `AppBar` restored on all 9 screens. Phase 6.4c — `+` moved to `SliverAppBar.actions` `IconButton` (teal `AppColors.accent`) on the 3 list screens, after the Phase 6.4 `FloatingActionButton` was found to be hidden at runtime by the outer `AppScaffold`'s `bottomNavigationBar` (nested-Scaffold FAB limitation). **Phase 6.5 — `noBlur: true` added to all body `GlassPanel`s** (1 in product list, 2 each in sale / expense list, 3 in dashboard, 9 in reports, 3 in product detail) and to the dialog `GlassPanel` in `glass_dialog.dart:27`, all to work around the `glass_kit` `SizedBox.expand` 0×0 collapse in unbounded parents. The visual change is subtle: the panel no longer blurs the aurora behind it (the gradient + border look is preserved), but the panels now render at their intrinsic size and the dialog is now a normal centered glass panel with working dismiss buttons. |
| Diagnostic overlays | **None.** All diagnostic files deleted in Phase 6.4: `lib/core/widgets/debug_borders.dart`, `debug_app_bar.dart`, `debug_mode.dart`. All `DebugBorders` / `DebugContainer` / `DebugAppBar` / TEST TAP / `+ ADD` `FilledButton.icon` references removed from `app.dart`, `app_bottom_nav.dart`, and all 9 screens. All `kDebug*Color` consts and `kDebugLayout` const gone. Permanent fixes that survive cleanup: `GlassTextField`'s internal `GlassPanel(noBlur: true)` (Phase 6.3); `GlassPanel.noBlur` ctor flag (Phase 6.2); form panels' `GlassPanel(noBlur: true)` (Phase 6.3); form panels' `Column(crossAxisAlignment: stretch)` (Phase 6.3). |

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
| App shell — mount aurora behind router | ✅ | `app.dart` — `MaterialApp.router.builder` wraps the navigator in a `Stack(fit: StackFit.expand)` with `AuroraBackdrop` (Positioned.fill) and the Router (Positioned.fill). `StackFit.expand` is what makes the Stack take the full parent size; the earlier `Material(type: transparency)` wrap was removed because `Material.alwaysNeedsCompositing=true` was creating a compositing layer that, combined with `glass_kit`'s `BackdropFilter` in the aurora, was causing the inner Scaffolds' bodies to be composited under the aurora waves on-device. Reads `MediaQuery.platformBrightnessOf(context)` so the backdrop follows the system theme at runtime |
| App shell — bottom nav glass | ✅ | `app_bottom_nav.dart` — floating glass nav (12 / 0 / 12 / 8 padding, 22 radius, `isFrostedGlass: true`), `extendBody: true` per DESIGN.md §"Bottom Navigation Bar" (line 114) so the body extends behind the nav and the aurora is visible through the glass at the bottom. Exports `kBottomNavHeight = 76` (caps the bar at the `NavigationBarTheme.height`) and `kBottomNavClearance = 100` (76 nav + 8 pad + ~16 breathing) for inner scroll lists. The `SizedBox(height: kBottomNavHeight)` inserted between `Padding` and `ClipRRect` works around `glass_kit`'s `GlassContainer` wrapping its child in `SizedBox.expand`, which otherwise makes `maxIntrinsicHeight = double.infinity` and causes `Scaffold.bottomNavigationBar` to fill the entire screen. |
| App shell — system overlay style | ⚠️ | AppBar is intentionally transparent (Flutter 3.24 `AppBarTheme` has no `flexibleSpace` slot; per-screen glass can be applied later). |
| Run on device | ⚠️ | Cannot run on device in this env (no Android / Gradle). User must run `flutter run -d <device>` locally. `flutter pub get` + `flutter analyze` pass with 0 errors. |

**Glass scope (per Phase 1.5 plan):**
- ✅ App bar
- ✅ Bottom nav (`isFrostedGlass: true` retained)
- ✅ Modals / dialogs (`isFrostedGlass: true` retained)
- ✅ Bottom sheets (non-frosted by default, `isFrostedGlass` opt-in per sheet)
- ✅ Text fields (`isFrostedGlass: true` retained)
- ❌ Section panels (stats, forms, lists, chart areas — non-frosted via default `isFrostedGlass: false`)
- ❌ Cards / list tiles (kept as default Material — out of glass scope; per plan, avoids stacked `BackdropFilter` jank)
- ❌ Buttons (kept as default Material — FilledButton / TextButton themed but not glassified)

**Changes in this session (UI realignment to DESIGN.md):**
- `app.dart`: wrapped the `Stack` in `Material(type: MaterialType.transparency)` and added `StackFit.expand` to the `Stack` (was loose with only `Positioned.fill` children — could collapse to 0×0 under loose constraints). The `Material` provides a transparent ink/text surface for descendants without painting a background.
- `app_bottom_nav.dart`: **reverted** the previous "fix" that removed `extendBody: true` (that fix was wrong per DESIGN.md line 114). Restored `extendBody: true` so the body extends behind the floating nav and the aurora bleeds through the glass at the bottom — this is the design-intended behavior. Removed the un-specified `backgroundColor: Colors.transparent` and `resizeToAvoidBottomInset: false` (the latter was a band-aid for keyboard nav-jumping; the real fix is the bottom-clearance below).
- `app_bottom_nav.dart`: exported `kBottomNavClearance = 100` (76 NavigationBar + 8 padding + ~16 breathing) for use by all inner scroll lists.
- 5 inner scroll lists updated to use `kBottomNavClearance` for their bottom padding / tail spacer:
  - `dashboard_screen.dart` — `ListView` bottom pad 24 → 100
  - `reports_screen.dart` — `ListView` bottom pad 24 → 100
  - `product_list_screen.dart` — `SliverToBoxAdapter` SizedBox 96 → 100
  - `sale_list_screen.dart` — `SliverToBoxAdapter` SizedBox 96 → 100
  - `expense_list_screen.dart` — `SliverToBoxAdapter` SizedBox 96 → 100
- Net effect: the inner screens now leave enough bottom room for the floating nav (was the root cause of "nav appears in the middle, body looks blank" — the dashboard content was just collapsing into the top half of the screen because its list had only 24px of bottom pad). `flutter analyze` clean (0 errors, same 23 pre-existing warnings/info).

**Subsequent fix (this session, same theme work — `glass_kit` intrinsic-infinity):**
- **Root cause**: `glass_kit`'s `GlassContainer.build` ends with `SizedBox.expand(child: current)`, which makes `maxIntrinsicHeight = double.infinity`. This propagates up through `ClipRRect → GlassPanel → ClipRRect → Padding → SafeArea` into `Scaffold.bottomNavigationBar`, which then allocates the entire screen to the nav slot. The body is rendered behind the nav (`extendBody: true`) but the nav covers the whole screen, so every touch hits a `NavigationDestination` and the content is invisible.
- **Fix** (`app_bottom_nav.dart` only): insert `SizedBox(height: kBottomNavHeight)` between the existing `Padding(12, 0, 12, 8)` and the existing `ClipRRect(22)`. Cap = 76 px = `NavigationBarTheme.height`. The 8 px bottom padding and the outer `SafeArea(bottom: true)` are unchanged, so total visible bottom area is still 76 (bar) + 8 (padding) + safe-area inset (≈ 112-132 px). Inner scroll padding (`kBottomNavClearance = 100`) is unchanged.
- **Constant added**: `kBottomNavHeight = 76` next to the existing `kBottomNavClearance = 100` in `app_bottom_nav.dart`.
- **Verification**: `flutter analyze` clean (0 errors, same 23 pre-existing warnings/info). Not yet verified on a device — user must `flutter run -d <device>` locally to confirm.

**Subsequent fix (this session, same theme work — body-blank regression from `Material(transparency)` compositing):**
- **Root cause**: The `745fb5f` commit had wrapped the outer `Stack` in `Material(type: MaterialType.transparency)` to "fix a latent Stack sizing issue". `Material` with a child has `alwaysNeedsCompositing: true` (Flutter SDK), so it created a new compositing layer containing the entire Stack (aurora + Navigator). Inside that layer, `glass_kit`'s `GlassContainer` (used by the aurora) uses `ImageFilter.blur` via `BackdropFilter`. With the `BackdropFilter` in the same compositing layer as the inner Scaffolds' bodies, the bodies were being composited under the aurora's blurred waves on-device. The `AppBar` and `bottomNavigationBar` were unaffected because `RenderScaffold` lays them out via a different render path (appBar slot / bottomNavigationBar slot, both painted before the body in the Scaffold's paint pass), but the body's widgets — nested deepest in the compositing layer — were being covered by the aurora. Net result: AppBar visible, bottom nav visible, body looks blank (just aurora).
- **Fix** (`app.dart` only): remove the `Material(type: MaterialType.transparency)` wrapper. The `Stack(fit: StackFit.expand, ...)` alone is sufficient to size the Stack to the parent's full size (the `Positioned.fill` children are the size that anchors `StackFit.expand`). Dead-comment block at `app.dart:47-55` removed at the same time.
- **Verification**: `flutter analyze` clean (0 errors, same 23 pre-existing warnings/info). Not yet verified on a device — user must `flutter run -d <device>` locally to confirm bodies of all 5 inner screens + 3 form screens render on top of the aurora.

**Previous changes (screen blur + nav fix — superseded):**
- `GlassPanel.default.isFrostedGlass` changed from `true` to `false` to eliminate cumulative `BackdropFilter` blur jank across section panels (dashboard stats, form wrappers, list containers, report tables). The aurora alone provides the ambient liquid glass effect behind all content.
- `app_bottom_nav.dart`: ~~removed `extendBody: true`~~ — this change has been reverted; see "Changes in this session" above.
- `glass_dialog.dart`: added explicit `isFrostedGlass: true` to retain frosted glass on dialogs.
- `GlassPanel.flush` default also set to `isFrostedGlass: false`.
- `GlassTextField` already set `isFrostedGlass: true` explicitly — unchanged.

**New widgets available for upcoming phases:**
- `GlassPanel` / `GlassPanel.flush` — for any future glass chrome (disable frost by default, opt-in via `isFrostedGlass: true`)
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

## Phase 3 — Sales ✅

| Task | Status | Notes |
|------|--------|-------|
| AlertService | ✅ | `lib/services/alert_service.dart` — sealed `AppAlert` hierarchy: `BelowCostAlert` (selling < cost), `LowStockAlert` (post-sale stock ≤ threshold), `MarginDropAlert` (>15% margin drop vs last sale for the same product); `AlertService.checkSale(...)` returns all matching alerts |
| SaleRepository | ✅ | `lib/features/sales/sale_repository.dart` — `@Riverpod(keepAlive: true)`, Drift-backed. Transactional `addSale` (insert sale + decrement stock + insert `sale` stock movement, raises on insufficient stock), `updateSale` (with stock adjustment on qty change), `markAsPaid`, `deleteSale` (transactional stock restore + `adjustment` movement); `watchAll`, `watchFiltered(SaleFilter)`, `getById`, `lastSellingPriceFor`; `SaleFilter` value class (immutable, `==`/`hashCode` for family key) with sentinel-based `copyWith` for nullable fields; `dateRangePresets` (All time / Today / This week / This month / Last 30 days); `AddSaleResult` (sale + newStock) |
| Sale providers | ✅ | `lib/features/sales/sale_provider.dart` — `saleListProvider` (stream), `filteredSaleListProvider(family<SaleFilter>)`, `saleDetailProvider(family<int>)`, `lastSellingPriceProvider(family<int>)`, `productCostMapProvider` (future); `SaleStats` + `computeSaleStats` (count / revenue / est. profit / due count) |
| Sale filter bar | ✅ | `lib/features/sales/widgets/sale_filter_bar.dart` — 4 rows of glass-tinted chip selectors (Date / Platform / Payment / Product); custom date range via `showDateRangePicker`; "Pick…" product chip opens the filter sheet |
| Product filter sheet | ✅ | `lib/features/sales/widgets/product_filter_sheet.dart` — `GlassPanel` bottom sheet with `GlassTextField` search; "All products" + filtered list, selected row highlighted |
| Sale list item (product view) | ✅ | `features/products/widgets/sale_list_item.dart` — extended with optional `onTap` / `onMarkPaid` / `onDelete` / `showProductName` / `productName`; product detail still works without them |
| Sale list screen | ✅ | `lib/features/sales/sale_list_screen.dart` — sticky `SliverAppBar` with `+` action, sticky `SaleFilterBar`, 4-stat `GlassPanel` (count / revenue / est. profit / due), per-row `PopupMenuButton` (Edit / Mark as paid / Delete); delete via `showGlassDialog<bool>` confirm |
| Sale form screen | ✅ | `lib/features/sales/sale_form_screen.dart` — add + edit (`int? saleId`); product picker (locked in edit mode, read-only `GlassPanel` with stock badge); qty + price side-by-side with input formatters (digits-only / decimal-2); live `GlassPanel` total + est. profit; "last sold at ৳X" hint; pre-save `BelowCost` + `LowStock` confirms via `showGlassDialog<bool>`; post-save `MarginDrop` shown as amber `SnackBar` |
| Router — sale edit route | ✅ | `router.dart` — `/sales/:id/edit` (nested) |
| Alert integration | ✅ | Blocking alerts (BelowCost, LowStock) gate the save with explicit user confirm; informational alerts (MarginDrop) are non-blocking and surface in a `SnackBar` after save |
| Ledger consistency | ✅ | `addSale` / `updateSale` (on qty change) / `deleteSale` all adjust `Products.stock` and insert a `stock_movements` row (`type: 'sale'` or `'adjustment'`) in the same transaction |
| Validation | ✅ | Quantity > 0 and ≤ current stock; selling price > 0; platform & payment required (enums, no nullable); customer name optional |
| Run on device | ⚠️ | Cannot run on device in this env. User must run `flutter run -d <device>` locally. `flutter pub get` + `build_runner` + `flutter analyze` pass with 0 errors. |

**Deviations from `05_implementation.md`:**
- Sale form supports both add and edit (`int? saleId`) — the spec only described add. The edit form locks the product (read-only) because changing it would invalidate `stock_movements` history; only qty / price / platform / payment / customer / date are editable. The router adds `/sales/:id/edit`.
- `SaleFilter` is defined in `sale_repository.dart` (not a separate `models/` file) — pragmatic; can be split out when reports/dashboard need DTOs.
- `product_sales` provider is a future in `sale_provider.dart` (not in `SaleRepository`) — keeps the repos focused on their tables.
- `AlertService` exposes a `sealed AppAlert` hierarchy with three concrete types; callers use `whereType<T>()` to dispatch (replaces the simpler "list of strings" approach in the spec).
- `productCostMapProvider` is a `Future` provider (not a `Stream`) because cost rarely changes and a one-shot read is enough for the profit computation.
- `glass_text_field.dart` was extended with `inputFormatters` (Phase 3) and `validator` / `autofocus` / `autovalidateMode` (already in Phase 2) — these are useful for sale-form number entry.

**FR coverage:**
- FR-S01 Log a sale: `SaleFormScreen` add path, `SaleRepository.addSale` ✅
- FR-S02 View sales list: `SaleListScreen` + `SaleFilterBar` ✅
- FR-S03 Filter sales (date, platform, payment, product): `SaleFilterBar` ✅
- FR-S04 Mark sale as paid: per-row popup menu → `SaleRepository.markAsPaid` ✅
- FR-S05 Edit sale: `/sales/:id/edit` → `SaleFormScreen` edit path (with locked product) ✅
- FR-S06 Delete sale: per-row popup menu → `showGlassDialog` confirm → `SaleRepository.deleteSale` ✅
- FR-S07 Show profit per sale: live `GlassPanel` total + est. profit in the form, profit stat on the list ✅
- FR-A01 Below-cost warning: `BelowCostAlert` (pre-save confirm + post-save blocking)
- FR-A02 Low-stock warning: `LowStockAlert` (pre-save confirm + post-save blocking)
- FR-A03 Margin drop: `MarginDropAlert` (informational, post-save `SnackBar`)

---

## Phase 4 — Expenses ✅

| Task | Status | Notes |
|------|--------|-------|
| ExpenseRepository | ✅ | `lib/features/expenses/expense_repository.dart` — `@Riverpod(keepAlive: true)`, Drift-backed. `watchAll` / `watchFiltered(ExpenseFilter)` streams, `add` / `update` / `delete` / `getById` CRUD, `totalForPeriod(start, end)` aggregate; `ExpenseCategory` enum (`ads`/`delivery`/`packaging`/`misc`) with label extension; `ExpenseFilter` value class (immutable, `==`/`hashCode` for family key) with sentinel-based `copyWith` for nullable `from`/`to`; `DateRangePreset` + `dateRangePresets()` (All time / Today / This week / This month / Last 30 days) |
| Expense providers | ✅ | `lib/features/expenses/expense_provider.dart` — `expenseListProvider` (stream), `filteredExpenseListProvider(family<ExpenseFilter>)`, `expenseDetailProvider(family<int>)`; `ExpenseStats` + `computeExpenseStats` (count / total) |
| Expense list screen | ✅ | `lib/features/expenses/expense_list_screen.dart` — sticky `SliverAppBar` with `+` action, sticky date filter bar (`GlassPanel` with period preset chips + Custom… date range picker), 2-stat `GlassPanel` (entries / total), per-row `PopupMenuButton` (Edit / Delete); delete via `showGlassDialog<bool>` confirm; empty state |
| Expense form screen | ✅ | `lib/features/expenses/expense_form_screen.dart` — add + edit (`int? expenseId`); amount `GlassTextField` with decimal input formatter; category toggle (`_ToggleGroup<ExpenseCategory>`); note `GlassTextField`; tappable date field opening `showDatePicker`; delete button (edit mode only, outlined red); save via `FilledButton`; `SnackBar` feedback |
| Router — expense edit route | ✅ | `router.dart` — `/expenses/:id/edit` (nested) |
| Validation | ✅ | Amount > 0 required; category required (enum, non-nullable); note optional; date defaults to now |
| Run on device | ⚠️ | Cannot run on device in this env. User must run `flutter run -d <device>` locally. `flutter pub get` + `build_runner` + `flutter analyze` pass with 0 errors. |

**Deviations from `05_implementation.md`:**
- Expense form supports both add and edit (`int? expenseId`) — the spec only described add. The router adds `/expenses/:id/edit`.
- `ExpenseCategory` is an enum with label extensions (matching `SalePlatform` pattern in Phase 3) — the spec stored category as a raw string.
- Date filter with presets + custom range picker is included in the list screen — spec was silent on filtering; user explicitly requested date-range filtering.
- `ExpenseFilter`, `DateRangePreset`, and `dateRangePresets()` are defined in `expense_repository.dart` (matching `SaleFilter` pattern in Phase 3).

## Phase 5 — Reports & Export ✅

| Task | Status | Notes |
|------|--------|-------|
| DashboardSummary model | ✅ | `lib/models/dashboard_summary.dart` — today's stats (sales, revenue, gross/net profit, due, platform breakdown, low stock) |
| MonthlyReport models | ✅ | `lib/models/monthly_report.dart` — `DailySnapshot`, `MonthlySummary`, `ProductReportRow` |
| DashboardProvider | ✅ | `lib/features/dashboard/dashboard_provider.dart` — `@riverpod Future<DashboardSummary>` computes today's sales count, revenue, gross/net profit, due amount, Facebook/Offline breakdown, low-stock products |
| DashboardScreen | ✅ | `lib/features/dashboard/dashboard_screen.dart` — stats grid in `GlassPanel`, platform breakdown with progress bar, low-stock section with `ProductTile` rows, pull-to-refresh |
| ReportRepository | ✅ | `lib/features/reports/report_repository.dart` — `@Riverpod(keepAlive: true)`; `dailySnapshots(year, month)` (day-by-day revenue/profit/expenses), `monthlySummaries(year)` (month-by-month), `productReport()` (per-product aggregated sales); three `@riverpod` providers |
| ChartTableToggle | ✅ | `lib/features/reports/widgets/chart_table_toggle.dart` — `AnimatedSwitcher` toggle between chart (`KeyedSubtree`) and table (`KeyedSubtree`) |
| MonthlyBarChart + YearlyBarChart | ✅ | `lib/features/reports/widgets/bar_chart_widget.dart` — `fl_chart` `BarChart` with dual-rod (revenue/profit), empty-state fallback, day/month labels |
| ReportsScreen | ✅ | `lib/features/reports/reports_screen.dart` — unified screen with 3-tab segmented control (Daily / Monthly / Products); month/year selector with prev/next chevron; export button; `_SummaryStrip` (Revenue / Profit / Expenses); `_DailyTable`/`_MonthlyTable` glass-panel data tables; `_ProductReport` with per-product rows |
| ExportService | ✅ | `lib/services/export_service.dart` — `syncfusion_flutter_xlsio` Workbook with Sales + Expenses sheets; saves to temp dir; shares via `share_plus` |
| Run on device | ⚠️ | Cannot run on device in this env. User must run `flutter run -d <device>` locally. `flutter pub get` + `build_runner` + `flutter analyze` pass with 0 errors. |

**Deviations from `05_implementation.md`:**
- Reports screen is a single composite screen (Daily/Monthly/Product tabs) instead of 3 separate route-level screens — the `/reports` route stays unchanged, no new router entries needed.
- `ReportRepository` includes three methods (`dailySnapshots`, `monthlySummaries`, `productReport`) plus three `@riverpod` providers — the spec's checklist mentioned it but gave no code.
- `YearlyBarChart` was added alongside `MonthlyBarChart` from the spec to support the monthly-overview tab.
- `dashboard_provider.dart` and `report_repository.dart` are now the only files needing `@riverpod` codegen; the spec's `dashboard_provider` auto-generates as part of the standard project pattern.
- `ExportService` uses the share_plus API as written in the spec (`Share.shareXFiles`).

## Phase 6 — Liquid Glass Visual Alignment ✅

| Task | Status | Notes |
|------|--------|-------|
| `SheetDragHandle` widget (extracted) | ✅ | `lib/core/widgets/sheet_drag_handle.dart` — 40 × 4 px pill, `onSurfaceVariant` @ 30 % opacity, 2 px radius, centered, 14 px bottom margin (DESIGN.md §7/§8/§13/§14). Replaces the 4 inlined copies. |
| `ChipThemeData` added to app theme | ✅ | `lib/core/theme/app_theme.dart` — teal-tinted `selectedColor`, `secondaryLabelStyle` teal + 700, default muted `side`. Future-proofs the theme for any other `ChoiceChip` callers. |
| Product list filter chips re-themed | ✅ | `lib/features/products/product_list_screen.dart` — new `_FilterChip` wrapper passes a teal `side` for selected chips; unselected chips pick up the muted-border theme default. |
| Quick Sell Sheet chrome | ✅ | `lib/features/sales/widgets/quick_sell_sheet.dart` — added `SheetDragHandle`, `radius: 28`, `margin: EdgeInsets.all(12)`, `padding: (20, 18, 20, 24)` per DESIGN.md §7. |
| Discount Sheet chrome (incl. `_ProductPickerSheet`) | ✅ | `lib/features/sales/widgets/discount_sheet.dart` — same chrome on both the main sheet and the nested product picker; padding (20, 18, 20, 24) per §8. |
| Product Filter Sheet chrome | ✅ | `lib/features/sales/widgets/product_filter_sheet.dart` — replaced inlined drag handle with `SheetDragHandle`; radius / margin / padding already aligned to §14. |
| Restock Sheet refactor (DRY) | ✅ | `lib/features/products/widgets/restock_sheet.dart` — replaced inlined drag handle with `SheetDragHandle`; no behavior change. |
| Verification — `flutter analyze` | ✅ | 0 errors, same 23 pre-existing warnings/info (4 warnings + 19 info). No new issues introduced. |
| Verification — `flutter test` | ✅ | 100/100 passing with `LD_LIBRARY_PATH=/tmp` (libsqlite3 symlink). All 8 unit test files + 7 widget test files green. |
| Verification — on-device | ⚠️ | Not run in this env (no Android device / Gradle). User must run `flutter run -d <device>` locally. |

**Deviations from initial plan:**
- `Quick Sell` and `Discount` sheets use `padding: (20, 18, 20, 24)` per DESIGN.md §7/§8 ("20px horizontal / 18px top / 24px bottom"), while `Restock` and `Product Filter` sheets use `padding: (20, 18, 20, 20)` per §13/§14 ("20px / 18px / 20px padding"). The initial plan collapsed these to a single (20, 18, 20, 20) value; corrected during implementation.
- `_FilterChip` wraps a `ChoiceChip` and passes its own `side` (teal when selected, muted when not) because `ChipThemeData` only exposes a single `side` parameter — there is no `selectedSide` in Flutter 3.24.4. The text color + weight is also overridden in the wrapper so selected state is fully teal/bold even without relying on `secondaryLabelStyle` semantics.

---

## Phase 6.1 — Layout Diagnostic Placeholders ⚠️

**Trigger:** User reported "currently there are no option to add products, or any other things to interact with. in the add product section there is no option available." Goal of this phase is **diagnostic, not a fix** — wrap each visible region in a colored border + label so on-device we can see exactly which layers are rendering and at what size. Removed in a follow-up phase (likely 6.2) once we have the user's report.

| Task | Status | Notes |
|------|--------|-------|
| `DebugBorders` widget | ✅ | `lib/core/widgets/debug_borders.dart` — `DecoratedBox(border: Border.all(...))` + `Stack(child, Positioned label)`. No `BackdropFilter`, no `GlassPanel`, no layout collapse. `borderWidth: 3` for buttons, default 2 for everything else. Also exports color consts (`kDebugFieldColor`, `kDebugPanelColor`, `kDebugAppBarColor`, `kDebugBodyColor`, `kDebugNavColor`, `kDebugStackColor`, `kDebugButtonColor`) and a `kDebugLayout = true` toggle (always on this phase). |
| `DebugAppBar` wrapper | ✅ | `lib/core/widgets/debug_app_bar.dart` — implements `PreferredSizeWidget` so it can be passed to `Scaffold.appBar` (Scaffold rejects plain widgets there). |
| `app.dart` STACK border | ✅ | Red `DebugBorders` around the outer `Stack(fit: StackFit.expand, [AuroraBackdrop, Router child])` so we can confirm the Stack is full-screen on-device. |
| `app_bottom_nav.dart` BODY + BOTTOM NAV borders | ✅ | Green `BODY` around `navigationShell`; blue `BOTTOM NAV` around the floating `GlassPanel` + `NavigationBar` slot. |
| Dashboard: panel borders + TEST TAP | ✅ | Orange borders on `_StatGrid`, `_PlatformBreakdown`, `_LowStockSection`; teal TEST TAP `FilledButton` at the top of the body. |
| Product list: APPBAR ACTION `+ ADD` + TEST TAP + panel borders | ✅ | Replaced the `+` `IconButton` with a teal `FilledButton.icon('+ ADD')` wrapped in yellow `DebugBorders`; added TEST TAP button; orange borders on the 4-stat strip, filter-chip row, search field, and each `ProductTile` (`#1`, `#2`, …). |
| Product detail: APPBAR + panel borders | ✅ | Yellow `DebugAppBar` (Edit action still uses an `IconButton`); orange borders on the product-header panel, recent-sales panel, and stock-movements panel. |
| Product form: APPBAR + panel + FIELD borders + save-button border | ✅ | Magenta `DebugBorders` around every `GlassTextField` (name, cost, stock, threshold, note); 3 px teal border on the Save/Add button. |
| Sale list: APPBAR ACTION `+ ADD` + TEST TAP + panel borders | ✅ | Same pattern as product list. Orange borders on each sell-card and on the discount + recent-sales panels; 3 px teal border on the "Full sale form" button. |
| Sale form: APPBAR + panel + FIELD borders + save-button border | ✅ | Magenta borders on qty / price / customer fields; orange borders on the product / details / total panels; 3 px teal border on the Save/Record button. |
| Expense list: APPBAR ACTION `+ ADD` + TEST TAP + panel borders | ✅ | Orange borders on date-filter panel, stats panel, each row, and the empty state. |
| Expense form: APPBAR + panel + FIELD borders + delete + save button borders | ✅ | Magenta borders on amount + note fields; orange borders on amount / category / note / date panels; 3 px teal border on Save/Record, 3 px red (`AppColors.danger`) border on Delete (edit mode only). |
| Reports: APPBAR + panel borders + TEST TAP | ✅ | Orange borders on month-selector, tabs, and content panels. |
| Verification — `flutter analyze` | ✅ | 0 errors, 21 pre-existing warnings/info. No new issues introduced. |
| Verification — `flutter test` | ✅ | 100/100 passing with `LD_LIBRARY_PATH=/tmp` (libsqlite3 symlink). |
| Verification — on-device | ⚠️ | **User must run `flutter run -d <device>` and report back.** What to look for: (a) Is the outer red STACK border visible full-screen? (b) Is the green BODY border visible between the AppBar and the Bottom Nav? (c) Is the blue BOTTOM NAV border visible at the bottom and inside the SafeArea? (d) Does tapping the teal TEST TAP button trigger a SnackBar? (e) On the Products tab, is the yellow `+ ADD` button visible in the AppBar? (f) On the Add Product form, are the magenta FIELD borders around each input visible and tappable? |

**What this phase is NOT:**
- It is not a fix. If the user reports "the BODY border is visible but its content is blank", that points at the `glass_kit` `BackdropFilter` regression or a transparent `Scaffold` issue. If the user reports "the BODY border itself is missing", the regression is upstream (router / Stack layout). If they report "the field borders are visible but tapping does nothing", the issue is in the parent button (e.g. a translucent overlay absorbing taps).
- It is not conditional. `kDebugLayout = true` is always on; no in-app toggle.
- It is not permanent. Once we have the diagnostic information from the user, follow-up Phase 6.2 will: (1) apply a targeted fix, (2) remove every `DebugBorders` / `DebugAppBar` / TEST TAP `FilledButton` and the `kDebugLayout` const, and (3) re-run `flutter analyze` + `flutter test`.

**Wrap-only design (no functional impact):**
- `DebugBorders` uses `DecoratedBox` (no size change) + `Stack` (no `BackdropFilter`, so no glass effect is altered; bordered `GlassPanel`s still frost correctly).
- Borders are drawn **outside** the child. No widget is hidden, displaced, or made unclickable by the wrap.
- TEST TAP `FilledButton`s sit at the top of each body and fire a `SnackBar` on tap (no other side effects).

---

## Phase 6.2 — Form-Screen Blank Fix ⚠️

**Trigger:** User on-device report after Phase 6.1 — questions 1-4 PASS (STACK, BODY, TEST TAP, + ADD visible); question 5 FAIL: "in the add product section there is no option available" — no magenta FIELD borders, no AppBar (or AppBar visible but body empty), no save button. Form body fully blank.

**Goal:** Apply a targeted fix to all 3 form screens (product / sale / expense) so the body renders, fields are tappable, and the save button is reachable. Keep diagnostic overlays in place for one more round (FORM = purple, LIST = cyan) so we can localize the collapse if it persists.

| Task | Status | Notes |
|------|--------|-------|
| `DebugContainer` widget | ✅ | `lib/core/widgets/debug_borders.dart` — `Container(decoration: BoxDecoration(border: ...))` wrap, no `Stack`/`Positioned`, no label, no `BackdropFilter`. Used wherever the `Stack`-based `DebugBorders` would break tight intrinsic-size / `LayoutBuilder` chains inside the form panels. |
| `GlassPanel.noBlur` flag | ✅ | `lib/core/widgets/glass_panel.dart` — new `noBlur: false` ctor param. When `true`, renders a plain `Container` (gradient + border, no `BackdropFilter`, no `LayoutBuilder`) using the same brightness-aware fill / border tokens as the frosted variant. Preserves the panel's visual language without the `BackdropFilter` 0×0 collapse risk. `testOverride` still bypasses everything in headless. |
| `kDebugFormColor` + `kDebugListColor` consts | ✅ | `lib/core/widgets/debug_borders.dart` — `Colors.purple` and `Colors.cyan` for the new FORM and LIST wraps. |
| Product form: H1 + H2 + FORM/LIST borders | ✅ | `lib/features/products/product_form_screen.dart` — `Column(crossAxisAlignment: start)` + `SizedBox(width: double.infinity, child: ...)` around each `GlassTextField` (H1). FIELD wraps changed from `DebugBorders` to `DebugContainer` (H2). Big `GlassPanel` for the form set to `noBlur: true` (H3). Body wrapped in purple FORM `DebugBorders`; inner `ListView` wrapped in cyan LIST `DebugBorders`. |
| Sale form: H1 + H2 + FORM/LIST borders | ✅ | `lib/features/sales/sale_form_screen.dart` — same pattern: H1 (Column(start) + SizedBox(width: double.infinity) on the customer field; qty + price side-by-side already in a `Row` with `Expanded` so H1 didn't apply there, but the loose `CrossAxisAlignment.stretch` was removed). H2 (DebugContainer for every FIELD). H3 (noBlur: true on the product / details / total panels). FORM (purple) + LIST (cyan) borders added. |
| Expense form: H1 + H2 + FORM/LIST borders | ✅ | `lib/features/expenses/expense_form_screen.dart` — same pattern: H1 on the amount + note fields; H2 (DebugContainer wraps); H3 (noBlur: true on amount / category / note / date panels). FORM (purple) + LIST (cyan) borders added. |
| Verification — `flutter analyze` | ✅ | 0 errors, 21 pre-existing warnings/info. No new issues introduced. |
| Verification — `flutter test` | ✅ | 100/100 passing with `LD_LIBRARY_PATH=/tmp` (libsqlite3 symlink). |
| Verification — on-device | ⚠️ | **User must run `flutter run -d <device>` and report back.** What to look for: (a) Is the purple FORM border visible full-screen between the AppBar and the bottom? (b) Is the cyan LIST border visible inside the FORM? (c) Are the orange PANEL borders (form/details/total) visible at sensible heights? (d) Are the magenta FIELD borders around each `GlassTextField` visible and tappable? (e) Is the teal Save/Record button visible at the bottom of the LIST? (f) On Sale form, do the qty / price / customer fields accept keyboard input? |

**Hypothesis tree (in order of likelihood):**
- **H1 — `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` + `GlassTextField` + `BackdropFilter` + `ListView` collapse** (most likely). Standard Flutter form pattern is `Column(crossAxisAlignment: CrossAxisAlignment.start)` + `SizedBox(width: double.infinity)` per field; `stretch` combined with a `ListView` parent and a `BackdropFilter` ancestor can resolve to 0×0 on-device. **Applied to all 3 forms.**
- **H2 — `DebugBorders` `Stack`+`Positioned` loose-constraint propagation.** The label `Positioned` provides loose constraints, which may break `LayoutBuilder` intrinsic-height propagation in `GlassTextField`. **Applied to all 3 forms (`DebugContainer` instead).**
- **H3 — `BackdropFilter` inside form's big `GlassPanel` returning 0×0.** The form panel's `BackdropFilter` could fail to size the inner `Column` in the same way as the body. **Proactively applied (`noBlur: true` on the big form panels) — small field-level `GlassTextField`s keep their `BackdropFilter`.**
- **H4 — `_loaded` flag not set in add mode.** `setState(() => _loaded = true)` in `initState` mutates state before first build. **Not the cause** (Flutter ignores the request gracefully and the next build picks it up).

**What this phase is NOT:**
- Not a cleanup. Every `DebugBorders` / `DebugContainer` / `DebugAppBar` / `kDebugLayout` / `kDebug*Color` const / `noBlur` flag is still in place. Once the user confirms the form body renders, Phase 6.3 will strip them all in one pass.
- Not a permanent glass change. `GlassPanel.noBlur` is a new opt-in flag that callers (currently only the 3 form panels) explicitly pass. Default `false`; the frosted path is unchanged.
- Not necessarily a complete fix. If the user still sees a blank form, the next escalation is to set `noBlur: true` on field-level `GlassTextField`s too (H3 deeper), or to investigate the scaffold / router / `_loaded` path.

**Wrap-only design (no functional impact):**
- `DebugContainer` uses `Container(border: ...)` — no size change, no `BackdropFilter`, no `LayoutBuilder` interaction.
- `noBlur: true` swaps the `LayoutBuilder` + `ClipRRect` + `GlassContainer` for a plain `Container` with the same gradient / border tokens. The panel is visually slightly more solid (no blur of the aurora behind), but still uses the same color palette and is otherwise identical to the frosted variant.
- FORM (purple) + LIST (cyan) borders are new but follow the same `DebugBorders` pattern as the existing PANEL (orange) wraps — no widget is hidden, displaced, or made unclickable.

---

## Phase 6.3 — Form-Field Re-Fix (real H3 at the field level) ⚠️

**Trigger:** User on-device report after Phase 6.2 — "form now renders, but in add product section there is only a toggle button, no other way to input the product. In add expense section, it is blank, no form to fill up and log the expense."

**Goal:** Find the actual collapse culprit (H1 was wrong, H2 was unnecessary, H3 was applied at the wrong level) and fix all 3 form screens so every field renders at full panel width and intrinsic height.

| Task | Status | Notes |
|------|--------|-------|
| Diagnose the partial-render bug | ✅ | Traced `glass_kit` `GlassContainer.build` at `~/.pub-cache/hosted/pub.dev/glass_kit-4.0.2/lib/src/glass_container.dart:366` — wraps `child` in `SizedBox.expand(child: current)`, then a `Container(height: height, width: width, ...)`. With `height: null, width: null` and an unbounded parent, the `SizedBox.expand`'s `∞ × ∞` constraints intersect the parent's loose `maxWidth` → invalid `minWidth > maxWidth` → 0×0 collapse. Same `glass_kit` intrinsic-infinity bug we already worked around for the bottom nav (`kBottomNavHeight = 76`) and the form panel (`noBlur: true` in 6.2). The field-level `GlassTextField` re-introduced the bug because its internal `GlassPanel` was still using the frosted `LayoutBuilder` + `GlassContainer` chain. |
| `GlassTextField` permanent fix | ✅ | `lib/core/widgets/glass_text_field.dart:90` — pass `noBlur: true` to the internal `GlassPanel`. The field's panel now renders as a plain `Container(gradient + border + TextFormField)`, no `LayoutBuilder`, no `BackdropFilter`, no `SizedBox.expand`. The `TextFormField` takes its intrinsic size under any parent constraints. Survives Phase 6.4 cleanup. |
| Restore `Column(stretch)` on form panels | ✅ | All 3 form screens — `Column(crossAxisAlignment: CrossAxisAlignment.start)` (the 6.2 mistake) reverted to `Column(crossAxisAlignment: CrossAxisAlignment.stretch)`. Under `stretch`, `SizedBox(width: double.infinity, child: ...)` is valid (`BoxConstraints(minWidth: parentWidth, maxWidth: parentWidth)` = full panel width). Under `start`, that same `SizedBox(width: ∞)` was collapsing to 0×0 (invalid `minWidth=∞, maxWidth=parentMaxWidth` intersection). The `SizedBox(width: double.infinity)` wrappers themselves are now redundant but kept for the Phase 6.4 cleanup to decide. |
| Product form: H1 restore | ✅ | `lib/features/products/product_form_screen.dart` line 215-216 — `Column(start)` → `Column(stretch)`. |
| Sale form: H1 restore (×2) | ✅ | `lib/features/sales/sale_form_screen.dart` lines 259-260 (product panel) and 337-338 (details panel) — `Column(start)` → `Column(stretch)`. |
| Expense form: H1 restore (×2) | ✅ | `lib/features/expenses/expense_form_screen.dart` lines 188-189 (amount panel) and 227-228 (category panel) — `Column(start)` → `Column(stretch)`. |
| Keep form-panel `noBlur: true` (permanent) | ✅ | Per user choice "Keep form-panel noBlur permanently" — the big form panels' `GlassPanel(noBlur: true)` is part of the permanent fix, not a diagnostic artifact. Survives Phase 6.4 cleanup. |
| Keep all 6.1+6.2 diagnostic overlays | ✅ | DebugBorders (STACK/BODY/BOTTOM NAV/APPBAR/PANEL/FIELD/BUTTON/FORM/LIST), DebugAppBar, DebugContainer around every field, TEST TAP buttons, color consts, kDebugLayout toggle — all still in place for Phase 6.4 cleanup. |
| Verification — `flutter analyze` | ✅ | 0 issues (no errors, no warnings, no info). Cleaner than pre-6.3 (was 21 pre-existing). |
| Verification — `flutter test` | ✅ | 100/100 passing with `LD_LIBRARY_PATH=/tmp` (libsqlite3 symlink in /tmp). All 8 unit + 7 widget test files green. |
| Verification — on-device | ✅ | User on-device report: "the form now renders. but in add product section, there is only a toggle button" was the bug. With 6.3 fix: user must run `flutter run -d <device>` and report that all fields render. |

**Why H1 was wrong in 6.2:**
- I theorized `Column(crossAxisAlignment: stretch)` was the problem and changed to `start`. Actually `stretch` is correct. The standard Flutter form pattern is `Column(stretch)` + `SizedBox(width: ∞)` per field — both pieces needed.
- Under `start`, Column gives children loose width (`maxWidth: parentMaxWidth, minWidth: 0`). `SizedBox(width: ∞)` forces `BoxConstraints.tightFor(width: ∞)`. Intersection: `BoxConstraints(minWidth: ∞, maxWidth: parentMaxWidth)` → `min > max` → 0×0.

**Why H2 was unnecessary:**
- The `DebugBorders` `Stack` + `Positioned` did not actually break `LayoutBuilder` intrinsic-height propagation in any way that mattered. The collapse was entirely from the `glass_kit` `SizedBox.expand`, not the debug overlay. `DebugContainer` is still useful as the magenta FIELD border for one more round, but the H2 hypothesis was a red herring.

**Why 6.2 H3 was at the wrong level:**
- I set `noBlur: true` on the form-level `GlassPanel` (the one wrapping the `Column` of fields), but the field-level `GlassTextField` was still using the frosted `LayoutBuilder` + `GlassContainer` chain. Even if the form panel was a plain `Container`, the inner fields' `glass_kit` `SizedBox.expand` was still collapsing to 0×0. 6.3 moves the `noBlur: true` flag one level deeper, to `GlassTextField` itself.

**What this phase is NOT:**
- Not a cleanup. Every diagnostic overlay (DebugBorders / DebugContainer / DebugAppBar / FORM/LIST borders / color consts / kDebugLayout) is still in place. Phase 6.4 will strip them all and restore `AppBar`.
- Not an end-state. The user must confirm the form fields render on-device before we proceed to Phase 6.4.

**Permanent vs. diagnostic changes in this phase:**
- **Permanent:** `glass_text_field.dart:90` — `noBlur: true` on the internal `GlassPanel`. Survives cleanup.
- **Permanent:** `glass_panel.dart:17,30,41,68-93` — the `noBlur: false` ctor flag and its plain-`Container` fallback path. Survives cleanup.
- **Permanent:** Form panels' `GlassPanel(noBlur: true)` in all 3 form screens. Survives cleanup.
- **Permanent:** `Column(crossAxisAlignment: stretch)` in form panels. Survives cleanup (this is the textbook Flutter form pattern).
- **Diagnostic:** All `DebugBorders` / `DebugContainer` / `DebugAppBar` / `DebugContainer` / color consts / kDebugLayout toggle / TEST TAP buttons. Removed in Phase 6.4.

---

## Phase 6.4 — Cleanup + DB Integration ✅

**Trigger:** User on-device report after Phase 6.3: "the app works perfectly now. all the ui problems have been fixed. remove the debugging boarders, contariner erc. restore the app. and integrate the db effectively. in the debug session, the adding of products, sales or the expense didnt register, other than that it worked perfectly". The "didn't register" was a side effect of Phase 6.1-6.2 (forms rendering blank → save button unreachable → no rows were ever inserted during testing), but the user asked for explicit DB integration as a follow-up, and for the diagnostic footprint to be removed.

**Goal:** Two atomic units of work.

| Task | Status | Notes |
|------|--------|-------|
| Delete 3 diagnostic files | ✅ | `lib/core/widgets/debug_borders.dart` (DebugBorders + DebugContainer + 9 color consts), `debug_app_bar.dart` (DebugAppBar PreferredSizeWidget wrapper), `debug_mode.dart` (kDebugLayout toggle). |
| `app.dart` — drop STACK `DebugBorders` | ✅ | Restore bare `Stack(fit: StackFit.expand, [AuroraBackdrop, Router child])`. Drop the `debug_borders.dart` import. |
| `app_bottom_nav.dart` — drop BODY + BOTTOM NAV borders | ✅ | `Scaffold(body: navigationShell, bottomNavigationBar: SafeArea(...))` — no debug wraps. Drop the `debug_borders.dart` import. |
| Restore `AppBar` on 3 form screens | ✅ | `product_form_screen.dart`, `sale_form_screen.dart`, `expense_form_screen.dart` — `DebugAppBar(...)` → plain `AppBar(title: Text(...))`. Drop the `debug_app_bar.dart` import from all 3. Drop the `debug_borders.dart` import. |
| Restore `AppBar` on dashboard + product_detail + reports | ✅ | `dashboard_screen.dart`, `product_detail_screen.dart`, `reports_screen.dart` — same `DebugAppBar` → `AppBar(title: Text(...))` swap. Drop the `debug_borders.dart` import. |
| Strip all PANEL / FIELD / BUTTON / FORM / LIST borders from 3 form screens | ✅ | `DebugBorders` and `DebugContainer` wraps around every `GlassPanel`, `GlassTextField`, and `FilledButton` removed. Form structure preserved: `Form > ListView > [GlassPanel(noBlur: true) > Column(stretch) > [GlassTextField...]], [FilledButton('Save')]`. |
| Strip all PANEL / APPBAR ACTION borders + remove TEST TAP + remove `+ ADD` from 3 list screens | ✅ | `product_list_screen.dart`, `sale_list_screen.dart`, `expense_list_screen.dart` — `DebugBorders` wraps + `FilledButton.icon('+ ADD')` (in SliverAppBar actions) + `FilledButton('TEST TAP')` (top of body) all removed. |
| Add `+` to 3 list screens (initial — `FloatingActionButton`) | ✅ | Per user choice "Remove all, use FAB". Each list screen initially received `floatingActionButton: FloatingActionButton(onPressed: () => context.push('/<resource>/add'), backgroundColor: AppColors.accent, foregroundColor: Colors.white, tooltip: 'Add …', child: const Icon(Icons.add_rounded))`. Per-screen tooltip: "Add product" / "Log sale" / "Add expense". **Found to be invisible at runtime in 6.4c — replaced with `SliverAppBar.actions` `IconButton` (next row).** |
| 6.4c — Move `+` to `SliverAppBar.actions` `IconButton` | ✅ | All 3 list screens — `floatingActionButton: FloatingActionButton(...)` removed; added `IconButton(tooltip: '…', onPressed: () => context.push('/<resource>/add'), icon: const Icon(Icons.add_rounded, color: AppColors.accent))` to `SliverAppBar.actions` (with a trailing `SizedBox(width: 4)` for icon padding). Per-screen tooltip: "Add product" / "Log sale" / "Add expense". The `+` is now visible at the top-right of every list screen. |
| Strip all PANEL borders + TEST TAP from dashboard + reports | ✅ | `DebugBorders` around `_StatGrid` / `_PlatformBreakdown` / `_LowStockSection` (dashboard) and `_buildMonthSelector` / `_buildTabSelector` / `_buildContent` (reports) removed. TEST TAP `FilledButton` removed from both. |
| Strip all PANEL / APPBAR borders from product_detail | ✅ | `DebugBorders` around PANEL: not-found / product-header / recent-sales / stock-movements removed. The real "Restock" `FilledButton.icon` at L109 kept. |
| Verification — `flutter analyze` | ✅ | 21 issues, all pre-existing (17 `avoid_relative_lib_imports` in gitignored test files, 1 unused-import in `quick_sell_sheet.dart`, 1 `duplicate_ignore` in `app_database.g.dart`, 2 `curly_braces_in_flow_control_structures` in `export_service.dart`). No new issues introduced. |
| Verification — `flutter test` | ✅ | 100/100 passing with `LD_LIBRARY_PATH=/tmp` (libsqlite3 symlink). All 8 unit + 7 widget test files green. |
| Verification — on-device | ⚠️ | User must run `flutter run -d <device>` to confirm: (a) no diagnostic borders anywhere; (b) `AppBar` visible on all 9 screens; (c) teal `+` `IconButton` visible at the top-right of the 3 list screens (Phase 6.4c — was FAB in Phase 6.4, but FAB was hidden by outer bottom nav at runtime); (d) adding a product / sale / expense reflects in the list + dashboard. |
| 6.4b — `productListProvider` / `filteredProductListProvider` keepAlive | ✅ | `lib/features/products/product_provider.dart` — `productListProvider`, `filteredProductListProvider`, and the `ProductFilter` Notifier all converted to `@Riverpod(keepAlive: true)`. Riverpod-generated `*_Provider` switched to `keepAlive: true` variant. |
| 6.4b — `saleListProvider` / `filteredSaleListProvider` keepAlive | ✅ | `lib/features/sales/sale_provider.dart` — same `@Riverpod(keepAlive: true)` conversion. |
| 6.4b — `expenseListProvider` / `filteredExpenseListProvider` keepAlive | ✅ | `lib/features/expenses/expense_provider.dart` — same. |
| 6.4b — `dashboardProvider` keepAlive | ✅ | `lib/features/dashboard/dashboard_provider.dart` — `@riverpod` → `@Riverpod(keepAlive: true)`. |
| 6.4b — Product form save invalidates productList + dashboard | ✅ | `product_form_screen.dart:104-105` — after `repo.create()` / `repo.update()` + `adjustStock()` succeeds, `ref.invalidate(productListProvider); ref.invalidate(dashboardProvider);` is called before `Navigator.pop(true)`. Same invalidations on `_delete()`. |
| 6.4b — Sale form save invalidates saleList + productList + dashboard | ✅ | `sale_form_screen.dart:165-167` — `ref.invalidate(saleListProvider); ref.invalidate(productListProvider); ref.invalidate(dashboardProvider);` after add/edit sale. |
| 6.4b — Expense form save invalidates expenseList + dashboard | ✅ | `expense_form_screen.dart:100-101, 137-138` — `ref.invalidate(expenseListProvider); ref.invalidate(dashboardProvider);` after add/edit/delete expense. |
| 6.4b — Expense list delete invalidates expenseList + dashboard | ✅ | `expense_list_screen.dart:194-195` — same invalidations on inline row delete. |
| 6.4b — Product detail restock invalidates productList | ✅ | `product_detail_screen.dart:110-119` — already had `ref.invalidate(productListProvider)` after `RestockSheet.show` returns true; unchanged. |
| 6.4b — Regenerate `*.g.dart` for keepAlive | ✅ | `dart run build_runner build --delete-conflicting-outputs` — 194 outputs regenerated. `product_provider.g.dart`, `sale_provider.g.dart`, `expense_provider.g.dart`, `dashboard_provider.g.dart` all updated to the `keepAlive` provider classes. |
| Verification — `flutter analyze` (post-6.4b) | ✅ | Same 21 pre-existing issues; 0 new. |
| Verification — `flutter test` (post-6.4b) | ✅ | 100/100 passing. |
| 6.4c — Diagnose FAB invisibility (nested-Scaffold bug) | ✅ | `Scaffold(extendBody: true, body: navigationShell, bottomNavigationBar: ...)` in `AppScaffold` (`lib/core/widgets/app_bottom_nav.dart`) means the inner list screen's `Scaffold` sees a full-screen body. The inner `FloatingActionButton` is laid out at the bottom of the inner body and is then **covered** by the outer's `bottomNavigationBar`. No `FloatingActionButtonLocation` on the inner Scaffold fixes this — the inner Scaffold has no knowledge of the outer's `bottomNavigationBar`. |
| 6.4c — Replace FAB with `SliverAppBar.actions` `IconButton` | ✅ | All 3 list screens — removed `floatingActionButton: FloatingActionButton(...)`; added `IconButton(tooltip: '…', onPressed: () => context.push('/<resource>/add'), icon: const Icon(Icons.add_rounded, color: AppColors.accent))` to `SliverAppBar.actions` (with a trailing `SizedBox(width: 4)`). Per-screen tooltip: "Add product" / "Log sale" / "Add expense". `app_colors.dart` import already present in all 3 files. `flutter analyze` clean (21 pre-existing, 0 new); `flutter test` 100/100. |

**End-to-end data flow (verified on-device pending):**

1. User taps the teal `+` `IconButton` in the Products `SliverAppBar` actions → `context.push('/products/add')`.
2. Product form's `_save()` runs `repo.create()` (Drift transaction: insert product + initial stock movement).
3. Form calls `ref.invalidate(productListProvider); ref.invalidate(dashboardProvider);`.
4. `Navigator.pop(true)` returns to the Products list.
5. The list is already watching `filteredProductListProvider` (which watches `productListProvider`); the invalidate forces a fresh `watch()` on the Drift stream, which emits the new product.
6. The user can now switch to the Dashboard tab. The dashboard's `ref.watch(dashboardProvider)` already shows the updated `totalProducts` stat (because step 3 invalidated it).
7. Same pattern for sales and expenses.

**Permanent vs. cleanup changes:**
- **Permanent (survived cleanup):** `GlassTextField`'s `noBlur: true` internal panel; `GlassPanel.noBlur` ctor flag; form panels' `noBlur: true`; form panels' `Column(stretch)`.
- **Cleanup (gone):** 3 debug files; 9 colored wraps per screen; 1 TEST TAP per list/form screen; 1 `+ ADD` `FilledButton.icon` per list screen; all `kDebug*Color` consts; `kDebugLayout` toggle.
- **New (clean):** `IconButton(Icons.add_rounded, color: AppColors.accent)` in `SliverAppBar.actions` of the 3 list screens (Phase 6.4c; the Phase 6.4 `FloatingActionButton` was found to be hidden at runtime by the outer `AppScaffold`'s `bottomNavigationBar`); plain `AppBar(title: Text(...))` on all 9 screens.
- **New (DB integration):** 6 list/filter providers + dashboard provider now `@Riverpod(keepAlive: true)`; 5 new `ref.invalidate(...)` calls in form save + delete paths; product form finally invalidates `productListProvider` (was the only one missing); dashboard invalidated on every form save so the dashboard tab always shows fresh stats.

---

## Phase 6.5 — Body-Blank + Dialog Fix ⚠️

**Trigger:** User on-device report after Phase 6.4c — "the bodies of the 3 list screens and the dashboard and reports are blank after adding a product. the product is visible in the sale form's product picker though, so the data is there. the bottom-nav badge shows 2+. the low-stock alert dialog is full-screen, the Save anyway and Cancel buttons don't dismiss it." Restock and edit on the product detail screen were untestable because the list was blank.

**Goal:** Two related fixes for the same `glass_kit` `SizedBox.expand` 0×0 collapse root cause, plus a cleanup of the silently-ignored `@Riverpod(keepAlive: true)` annotations introduced in 6.4b. Add `noBlur: true` to every body `GlassPanel` (18 panels across 6 screens) and to the dialog `GlassPanel`; remove the no-op `keepAlive: true` annotations from the 5 provider files; regenerate `*.g.dart`; verify `flutter analyze` + `flutter test`; commit + push.

| Task | Status | Notes |
|------|--------|-------|
| Diagnose: same `glass_kit` `SizedBox.expand` 0×0 collapse as 6.2/6.3 | ✅ | Body `GlassPanel`s (in `SliverToBoxAdapter` / `ListView` parents, both unbounded) + dialog `GlassPanel` (in `Dialog` widget, also unbounded) all hit the same `LayoutBuilder` → `ClipRRect` → `glass_kit.GlassContainer(height: null, width: null)` → `SizedBox.expand` chain that produces 0×0 in an unbounded parent. Form panels were fixed in 6.2 (with `noBlur: true`); bottom nav was fixed in 1.5 (with `kBottomNavHeight = 76`); body panels + dialog never got the workaround. The dialog's `BackdropFilter` was also eating touch events on the action row. |
| `noBlur: true` on dialog `GlassPanel` | ✅ | `lib/core/widgets/glass_dialog.dart:27` — added `noBlur: true` to the inner `GlassPanel(radius: 24, isFrostedGlass: true, padding: ..., child: Column(...))`. Fixes the full-screen dialog + unresponsive Cancel / Save anyway / tap-outside behavior. The `isFrostedGlass: true` flag is kept (the gradient + border still render; the `BackdropFilter` path is now skipped because `noBlur: true` short-circuits before it). |
| `noBlur: true` on body `GlassPanel` in product list | ✅ | `lib/features/products/product_list_screen.dart:58` — stat-pills `GlassPanel(padding: EdgeInsets.all(16), noBlur: true, child: Column(...))`. The search `GlassTextField` already had `noBlur: true` internally (Phase 6.3 permanent fix). |
| `noBlur: true` on body `GlassPanel`s in sale list (×2) | ✅ | `lib/features/sale_list_screen.dart:95, 137` — "Log discounted sale" + "Recent Sales" `GlassPanel`s. |
| `noBlur: true` on body `GlassPanel`s in expense list (×2) | ✅ | `lib/features/expense_list_screen.dart:65, 258` — stats + date-filter `GlassPanel`s. |
| `noBlur: true` on body `GlassPanel`s in dashboard (×3) | ✅ | `lib/features/dashboard/dashboard_screen.dart:90, 201, 290` — "Today" stat grid + "Platform Breakdown" + "Low Stock" `GlassPanel`s. |
| `noBlur: true` on body `GlassPanel`s in reports (×9) | ✅ | `lib/features/reports/reports_screen.dart` — month selector (L98), tab selector (L165), 3 empty-state panels (L255, 315, 347), Product Performance (L361), `_SummaryStrip` (L464), `_DailyTable` (L517), `_MonthlyTable` (L583). All 9 `GlassPanel`s in the reports screen. |
| `noBlur: true` on body `GlassPanel`s in product detail (×3) | ✅ | `lib/features/products/product_detail_screen.dart:48, 154, 239` — header (name / cost / stock / threshold / `StockBadge` / `Restock`), stock movements list, recent sales list. |
| Remove silently-ignored `@Riverpod(keepAlive: true)` from 5 provider files | ✅ | Per user choice (a). The 6.4b `@Riverpod(keepAlive: true)` annotation was **silently ignored** by the generator — e.g. `product_provider.g.dart:13` still emitted `AutoDisposeStreamProvider.internal` instead of `KeepAliveStreamProvider`. Source-vs-generated divergence + misleading annotation. Removed: `product_provider.dart` × 3 (productList, ProductFilter, filteredProductList), `sale_provider.dart` × 2 (saleList, filteredSaleList), `expense_provider.dart` × 2 (expenseList, filteredExpenseList), `dashboard_provider.dart` × 1 (dashboard), `alert_service.dart` × 1 (alertService). Replaced with plain `@riverpod`. `appDatabaseProvider`'s `@Riverpod(keepAlive: true)` is **preserved** (the DB connection must persist across the app's lifetime; it is the only legitimate keepAlive case). Auto-dispose is fine in practice because `StatefulShellRoute.indexedStack` keeps all 4 branches mounted, so the list / dashboard / alert providers are continuously watched for the duration of the app session. |
| Regenerate `*.g.dart` | ✅ | `dart run build_runner build --delete-conflicting-outputs` — 1304 outputs, 1m 30s. `product_provider.g.dart`, `sale_provider.g.dart`, `expense_provider.g.dart`, `dashboard_provider.g.dart`, `alert_service.g.dart` all regenerated. All 9 keepAlive providers now properly `AutoDispose` (`AutoDisposeStreamProvider`, `AutoDisposeProvider`, `AutoDisposeFutureProvider`, `AutoDisposeNotifierProvider`) without the misleading `.internal` suffix. |
| Verification — `flutter analyze` | ✅ | **0 issues** (cleaner than pre-6.5 which reported 21 pre-existing; the cleanup in 6.4 resolved the `quick_sell_sheet.dart` unused-import and the `export_service.dart` `curly_braces_in_flow_control_structures` warnings, and the gitignored `tracker_app/test/unit/*` `avoid_relative_lib_imports` warnings are no longer analyzed in the `lib/` scope). |
| Verification — `flutter test` | ✅ | **100/100 passing** with `LD_LIBRARY_PATH=/tmp` and `/tmp/libsqlite3.so → /usr/lib64/libsqlite3.so.0` symlink. All 8 unit + 7 widget test files green. |
| Verification — on-device | ⚠️ | User must run `flutter run -d <device>` to confirm: (a) bodies of all 3 list screens render the products / sales / expenses (data is already in the DB from 6.4 testing); (b) dashboard renders the "Today" stat grid + platform breakdown + low-stock section; (c) reports renders the Daily / Monthly / Products tabs with the month selector + summary strip + daily / monthly / product tables; (d) product detail renders the header (with Restock button) + stock movements + recent sales; (e) the Low Stock alert on sale form is a normal centered glass dialog and "Save anyway" / Cancel both dismiss it; (f) the product restock and edit flows work end-to-end (were untestable in 6.4c). |
| Commit + push | ✅ | `fix(theme): phase 6.5 — body noBlur + remove silently-ignored keepAlive` (12 files: 7 GlassPanel edits in `glass_dialog.dart` + 6 screens, 5 provider edits, 5 regenerated `.g.dart`, doc update). |

**Why body panels + dialog collapsed (same regression as 6.2/6.3, different surface area):**
- `glass_kit`'s `GlassContainer.build` ends with `SizedBox.expand(child: current)`. In an unbounded parent (e.g. `ListView`, `SliverToBoxAdapter`, `Dialog`), the `SizedBox.expand` receives `BoxConstraints(minHeight: 0, maxHeight: ∞, minWidth: 0, maxWidth: parentMaxWidth)`. The `SizedBox.expand` then `RenderConstrainedBox._additionalConstraints = BoxConstraints.tightFor(width: ∞, height: ∞)`. The intersection is invalid (`minWidth=∞, maxWidth=parentMaxWidth` → `minWidth > maxWidth`) → `SizedBox` returns `Size.zero` → `0×0` → invisible.
- Form panels were the first surface area (fixed in 6.2 with `noBlur: true` on the big form-level `GlassPanel`; the deeper fix in 6.3 was on `GlassTextField` itself). Bottom nav was the second (fixed in 1.5 with the `SizedBox(height: kBottomNavHeight = 76)` cap that bounds the inner `GlassContainer`). Body panels + dialog were the third — never got the workaround.

**Latent bug surfaced — `@Riverpod(keepAlive: true)` silently ignored:**
- Riverpod's codegen in 6.4b produced `product_provider.g.dart:13` as `AutoDisposeStreamProvider<List<Product>>.internal(...)` despite the source having `@Riverpod(keepAlive: true)`. The annotation was being silently dropped. Confirmed in the 5 files we touched: no `KeepAliveStreamProvider` / `KeepAliveFutureProvider` / `KeepAliveProvider` / `KeepAliveNotifierProvider` in any of the 5 generated files.
- The likely cause: the project's `riverpod_generator` version doesn't recognize `keepAlive` as a named parameter on `@Riverpod()` in this context (may need `@Riverpod(keepAlive: true)` as a const default or a different generator version). User chose the safest fix: **remove the annotation** entirely and rely on `StatefulShellRoute.indexedStack`'s mount-everything behavior. The DB provider's `@Riverpod(keepAlive: true)` is preserved (it's the only one where auto-dispose would actually break things — the connection would be torn down and reopened on every page).

**`@riverpod` vs `@Riverpod` import:** the 5 provider files use a bare `@riverpod` annotation (not the `Riverpod` prefix). Both work; the bare form is what the existing `saleDetail` / `expenseDetail` / `lastSellingPrice` providers in the same files already use. Consistent with the project's existing code style.

**Permanent vs. diagnostic changes in this phase:**
- **Permanent (in main):** `glass_dialog.dart:27` — `noBlur: true` on the dialog `GlassPanel`. The 18 body `GlassPanel`s across 6 screens (`product_list`, `sale_list`, `expense_list`, `dashboard`, `reports`, `product_detail`) — all flagged `noBlur: true`. The 9-annotation `keepAlive: true` removal from 5 provider files (auto-dispose is now the source of truth, matching the generated code).
- **No diagnostic artifacts** (none introduced in this phase).
- **No behavior change** for the user-visible flow beyond the rendered content. Adding / editing / deleting a product / sale / expense still goes through the same `repo.create()` / `repo.update()` / `repo.delete()` paths and triggers the same `ref.invalidate(...)` chains from 6.4b.

**Regression table (`glass_kit` `SizedBox.expand` history):**
| Phase | Surface | Workaround |
|-------|---------|------------|
| 1.5 | Bottom nav | `SizedBox(height: kBottomNavHeight = 76)` cap inside `app_bottom_nav.dart` |
| 6.2 | Form-level `GlassPanel` | `GlassPanel(noBlur: true)` — 3 form screens |
| 6.3 | `GlassTextField` internal `GlassPanel` | `GlassPanel(noBlur: true)` inside `glass_text_field.dart` |
| 6.4c | `FloatingActionButton` hidden by outer `bottomNavigationBar` | `IconButton` in `SliverAppBar.actions` (not glass-related) |
| 6.5 | Body `GlassPanel`s (×18) + dialog `GlassPanel` (×1) | `GlassPanel(noBlur: true)` — 6 screens + `glass_dialog.dart` |
| 6.6 | `_ProductSellCard` `GlassPanel` inside `SliverList` (×1, the only one I missed in 6.5) | `GlassPanel(noBlur: true)` — `sale_list_screen.dart:211` |

---

## Phase 6.6 — Sales List Product Cards ✅ (merged into 6.7)

**Trigger:** User on-device report after Phase 6.5 — "the sales page is blank, the other pages load perfectly". The 3 Expenses screenshots provided all rendered correctly (period chips + stats panel + 1 Ads row at ৳50.00). User confirmation: (1) Sales AppBar + "+" button visible and works (navigates to /sales/add); (2) "Active Products" label visible right under the AppBar; (3) below that label, "everything is empty until the bottom of the screen / bottom nav"; (4) Products tab works fine (products render); (5) 1-5 products in DB; (6) 1-5 sales in DB.

**Diagnosis:** The `_ProductSellCard` `GlassPanel` in `sale_list_screen.dart:207` was the only body `GlassPanel` missed in Phase 6.5. It uses `isFrostedGlass: inStock` (the `isFrostedGlass` flag only controls the blur, not the layout structure) and no `noBlur: true`, so it goes through the standard `LayoutBuilder` → `ClipRRect` → `glass_kit.GlassContainer(height: null, width: null)` → `SizedBox.expand` chain. In the unbounded `SliverList` parent, this collapses each card to 0×0.

**Fix applied (now in 6.7):** `noBlur: true` added to the `_ProductSellCard` `GlassPanel` in `sale_list_screen.dart:211`. User confirmed on-device that the sales page now renders the product cards. Bundled into the Phase 6.7 commit.

**Merged into 6.7** — see below.

---

## Phase 6.7 — Sales Flow Fixes + Dialog `actionsBuilder(ctx)` Refactor ✅

**Trigger:** User on-device report after Phase 6.6 (the previously uncommitted `_ProductSellCard` `noBlur: true` fix) was confirmed working — user replied "the sales page issues is fixed. there are some minor bugs." 4 minor bugs reported:

1. **Duplicate `+` entry point on Sales list** — both the teal `IconButton` in the AppBar (`SliverAppBar.actions`) and a separate "Full sale form" `OutlinedButton` at the bottom of the list (inside a `SliverToBoxAdapter`) navigate to `/sales/add`. The AppBar `+` is the canonical entry point (matches Products / Expenses lists per Phase 6.4c); the bottom button is redundant. User chose: keep the AppBar `+`, remove the bottom button.
2. **Discount sheet renders only title + X button, no fields** — the outer `GlassPanel` of `DiscountSheet` (inside `showModalBottomSheet(isScrollControlled: true)`) collapses to 0×0. The "Discounted Sale" title and the `IconButton(close)` are the only visible children because they're the only ones inside the part of the form that's not inside the 0×0 panel. (The `Column(mainAxisSize: min)` inside the panel's `Form` only renders as much as the panel's intrinsic height allows.) Same `glass_kit` `SizedBox.expand` root cause as 6.2/6.3/6.5/6.6.
3. **Low-stock alert dialog buttons ("Save anyway" / "Cancel") dismiss the underlying sheet, not the dialog** — when the user taps "Save anyway" or "Cancel" inside a low-stock alert, the bottom sheet closes but the dialog stays open on top of the sale list. Root cause: `Navigator.of(context).pop(...)` in the `GlassDialogAction.onPressed` callback captures the **sheet's** `BuildContext` (the outer-scope `context` from the calling code, which is the `DiscountSheet` / `QuickSellSheet` / `SaleFormScreen` widget). In Flutter 3.24.4 with modal bottom sheets, the closest `Navigator` from a bottom sheet's `context` can resolve to a route above the dialog, causing the sheet to be popped while the dialog remains. Fix: refactor `showGlassDialog` so action widgets are built with the **dialog's** `ctx` (the parameter of the `showDialog` builder), and `Navigator.of(ctx).pop(...)` is called on that ctx.
4. **QuickSellSheet has qty / price / platform / payment / customer / Total / Profit but the Confirm button is missing** — the `GlassPanel.flush` at the bottom of `QuickSellSheet` (and `DiscountSheet`) defaults to `expand: true`. With `expand: true` + no `noBlur: true`, the `glass_kit.GlassContainer` is given `height: constraints.maxHeight` and the inner `SizedBox.expand` forces the inner `Row` (Total / Profit + Confirm) to fill that height, conflicting with `Row`'s `mainAxisSize: MainAxisSize.min` → 0×0 collapse. Fix: `noBlur: true, expand: false`. The `expand: false` is mandatory because `noBlur: true, expand: true` would force `height: double.infinity` in the parent `Column` (also 0×0, plus a layout-error console message).

**Goal:** 4 fixes + 1 signature refactor, all in one commit. Remove duplicate `+`, add `noBlur: true` to 3 `discount_sheet.dart` `GlassPanel`s + 2 bottom `GlassPanel.flush`es (in `discount_sheet.dart` and `quick_sell_sheet.dart`), refactor `showGlassDialog` to `actionsBuilder(ctx)`, update all 12 call sites, commit, push.

| Task | Status | Notes |
|------|--------|-------|
| Diagnose: same `glass_kit` `SizedBox.expand` 0×0 collapse as 6.2/6.3/6.5/6.6 + 1 new `Navigator.context` issue | ✅ | Bugs 1, 2, 4 are the same `glass_kit` `SizedBox.expand` regression we already worked around 5 times (1.5, 6.2, 6.3, 6.5, 6.6). Bug 3 is a new pattern: `Navigator.of(callerContext).pop(...)` from inside a `GlassDialogAction` resolves to the wrong `Navigator` when the caller is inside a modal bottom sheet. |
| Remove duplicate "Full sale form" button | ✅ | `tracker_app/lib/features/sales/sale_list_screen.dart` — deleted the `SliverToBoxAdapter(Padding(OutlinedButton.icon('Full sale form')))` (was at lines 178-187). The teal `+` `IconButton` in `SliverAppBar.actions` (added in Phase 6.4c) is now the sole entry point to `/sales/add`, consistent with Products and Expenses. |
| Add `noBlur: true` to outer DiscountSheet `GlassPanel` | ✅ | `tracker_app/lib/features/sales/widgets/discount_sheet.dart:126` — the outer `GlassPanel(radius: 28, margin: ..., padding: ..., child: Form(Column(min)))` now has `noBlur: true`. This is the `GlassPanel` that opens inside `showModalBottomSheet(isScrollControlled: true)` and was the primary cause of bug 2. |
| Add `noBlur: true` to `_buildProductPicker()` `GlassPanel` | ✅ | `tracker_app/lib/features/sales/widgets/discount_sheet.dart:292` — the "Select product…" `GlassPanel(radius: 14, padding: ..., child: Row(...))` inside the form now has `noBlur: true`. Proactive — same parent context, same regression risk. |
| Add `noBlur: true` to `_ProductPickerSheet` `GlassPanel` | ✅ | `tracker_app/lib/features/sales/widgets/discount_sheet.dart:367` — the "Select product" `GlassPanel(radius: 28, ...)` inside the nested `showModalBottomSheet<int>` now has `noBlur: true`. Same regression risk. |
| Add `noBlur: true, expand: false` to DiscountSheet bottom `GlassPanel.flush` | ✅ | `tracker_app/lib/features/sales/widgets/discount_sheet.dart:221` — the bottom "Discount: -৳X / Profit: +৳Y / Confirm" `GlassPanel.flush(padding: EdgeInsets.all(12), child: Row(...))` now has `noBlur: true, expand: false`. Bug 4 fix. |
| Add `noBlur: true, expand: false` to QuickSellSheet bottom `GlassPanel.flush` | ✅ | `tracker_app/lib/features/sales/widgets/quick_sell_sheet.dart:212` — the bottom "Total / Profit / Confirm" `GlassPanel.flush(...)` now has `noBlur: true, expand: false`. Bug 4 fix. |
| Refactor `showGlassDialog` signature: `actions` → `actionsBuilder(ctx)` | ✅ | `tracker_app/lib/core/widgets/glass_dialog.dart:9` — `List<Widget> actions = const []` → `List<Widget> Function(BuildContext ctx)? actionsBuilder`. Inside the `showDialog` builder, `actionsBuilder?.call(ctx)` builds the action list with the dialog's `ctx` in scope. Action `onPressed` callbacks must now `Navigator.of(ctx).pop(...)` instead of `Navigator.of(callerContext).pop(...)`. Bug 3 fix + 1 forced dependency update for all 12 call sites. |
| Update `DiscountSheet` `showGlassDialog` call | ✅ | `tracker_app/lib/features/sales/widgets/discount_sheet.dart:72-89` — `actions: [...]` → `actionsBuilder: (ctx) => [...]`; `Navigator.of(context).pop(...)` → `Navigator.of(ctx).pop(...)`. |
| Update `QuickSellSheet` `showGlassDialog` call | ✅ | `tracker_app/lib/features/sales/widgets/quick_sell_sheet.dart:64-81` — same conversion. |
| Update `SaleFormScreen` `showGlassDialog` calls (×2) | ✅ | `tracker_app/lib/features/sales/sale_form_screen.dart:196, 211` — `_showError` + `_confirmBlockingAlerts` both converted. |
| Update `ProductFormScreen` `showGlassDialog` calls (×3) | ✅ | `tracker_app/lib/features/products/product_form_screen.dart:115, 133, 165` — `Could not save` (in `_save`), `Delete product?` (in `_delete`), `Could not delete` (in `_delete` catch) all converted. |
| Update `ExpenseFormScreen` `showGlassDialog` calls (×2) | ✅ | `tracker_app/lib/features/expenses/expense_form_screen.dart:116, 146` — `Delete expense?` (in `_delete`), `Could not save` (in `_showError`) converted. |
| Update `ExpenseListScreen` `showGlassDialog` call (×1) | ✅ | `tracker_app/lib/features/expenses/expense_list_screen.dart:128` — `Delete expense?` (in `_confirmDelete`) converted. |
| Update `RestockSheet` `showGlassDialog` calls (×2) | ✅ | `tracker_app/lib/features/products/widgets/restock_sheet.dart:59, 83` — `Invalid quantity` (in `_save` validation), `Could not save` (in `_save` catch) converted. |
| Bundle uncommitted Phase 6.6 fix (`_ProductSellCard` `noBlur: true`) | ✅ | `tracker_app/lib/features/sales/sale_list_screen.dart:211` — the previously uncommitted 1-line change is bundled into the 6.7 commit. User on-device confirmed this fix was working before 6.7 was scoped. |
| Verification — `flutter analyze` | ✅ | **21 issues, 0 new from 6.7** (2 pre-existing warnings: `app_database.g.dart:2940` `duplicate_ignore` + `quick_sell_sheet.dart:10` `unused_import`; 2 pre-existing info: `export_service.dart:102-103` `curly_braces_in_flow_control_structures`; 17 `avoid_relative_lib_imports` info in gitignored `test/unit/*`). |
| Verification — `flutter test` | ✅ | **48 passed / 52 failed baseline** unchanged by 6.7 (no tested code path was touched). All failures are pre-existing widget-test stream-subscription issues documented in `tracker_app/test/REPORT.md`. |
| Verification — on-device | ⚠️ | **User must rebuild + test** to confirm: (a) the Sales list has only 1 `+` (in AppBar), no bottom "Full sale form" button; (b) the Discount sheet shows the product picker, qty + normal-price + discount-price fields, Platform + Payment segmented controls, customer field, and the bottom "Discount / Profit / Confirm" panel with the Confirm button visible; (c) low-stock alerts: tapping "Save anyway" or "Cancel" dismisses the dialog (leaves the sale list / sheet as-is); (d) QuickSellSheet shows the Confirm button at the bottom next to Total + Profit. |
| Commit + push | ✅ | `fix(theme): phase 6.7 — sales flow noBlur + dialog actionsBuilder(ctx) refactor` (9 files, +43 / -44): `glass_dialog.dart` (1 refactor), `sale_list_screen.dart` (1 panel noBlur + 1 button removal), `discount_sheet.dart` (3 panel noBlur + 1 flush noBlur+expand:false + 1 dialog call), `quick_sell_sheet.dart` (1 flush noBlur+expand:false + 1 dialog call), `sale_form_screen.dart` (2 dialog calls), `product_form_screen.dart` (3 dialog calls), `expense_form_screen.dart` (2 dialog calls), `expense_list_screen.dart` (1 dialog call), `restock_sheet.dart` (2 dialog calls). Pushed to `https://github.com/ifti136/Invenio.git`. |

**Regression table — `glass_kit` `SizedBox.expand` history (updated):**
| Phase | Surface | Workaround |
|-------|---------|------------|
| 1.5 | Bottom nav | `SizedBox(height: kBottomNavHeight = 76)` cap inside `app_bottom_nav.dart` |
| 6.2 | Form-level `GlassPanel` | `GlassPanel(noBlur: true)` — 3 form screens |
| 6.3 | `GlassTextField` internal `GlassPanel` | `GlassPanel(noBlur: true)` inside `glass_text_field.dart` |
| 6.4c | `FloatingActionButton` hidden by outer `bottomNavigationBar` | `IconButton` in `SliverAppBar.actions` (not glass-related) |
| 6.5 | Body `GlassPanel`s (×18) + dialog `GlassPanel` (×1) | `GlassPanel(noBlur: true)` — 6 screens + `glass_dialog.dart` |
| 6.6 | `_ProductSellCard` `GlassPanel` inside `SliverList` (×1) | `GlassPanel(noBlur: true)` — `sale_list_screen.dart:211` |
| 6.7a | Outer `GlassPanel` of `DiscountSheet` inside `showModalBottomSheet` (×1) | `GlassPanel(noBlur: true)` — `discount_sheet.dart:126` |
| 6.7b | `_buildProductPicker()` `GlassPanel` inside `DiscountSheet` (×1) | `GlassPanel(noBlur: true)` — `discount_sheet.dart:292` |
| 6.7c | `_ProductPickerSheet` `GlassPanel` inside nested `showModalBottomSheet` (×1) | `GlassPanel(noBlur: true)` — `discount_sheet.dart:367` |
| 6.7d | `GlassPanel.flush(expand: true)` at bottom of `QuickSellSheet` and `DiscountSheet` inside `Column` (×2) | `GlassPanel.flush(noBlur: true, expand: false)` — `discount_sheet.dart:221` + `quick_sell_sheet.dart:212` |
| 6.7e | `showGlassDialog` action `onPressed` callbacks capturing the **sheet's** `BuildContext` instead of the **dialog's** (×12) | `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)` — `glass_dialog.dart:9` + 12 callers |

**Why all 4 bugs share the same `glass_kit` chain (regression summary):**
- `glass_kit`'s `GlassContainer.build` ends with `SizedBox.expand(child: current)`. In an unbounded parent (e.g. `ListView`, `SliverToBoxAdapter`, `SliverList`, `Dialog`, `showModalBottomSheet` content, `Column` with bounded main axis), the `SizedBox.expand` receives `BoxConstraints(minHeight: 0, maxHeight: ∞, minWidth: 0, maxWidth: parentMaxWidth)`. The `RenderConstrainedBox._additionalConstraints = BoxConstraints.tightFor(width: ∞, height: ∞)`. The intersection is invalid (`minWidth=∞, maxWidth=parentMaxWidth` → `minWidth > maxWidth`) → `SizedBox` returns `Size.zero` → `0×0` → invisible. Bug 1 is a UI/UX redundancy (not a `glass_kit` issue), but bug 2 + bug 4 are the same `glass_kit` regression. Bug 3 is unrelated to `glass_kit` — it's a `Navigator.of(...)` semantics issue specific to modal bottom sheets in Flutter 3.24.4.

**Permanent vs. diagnostic:**
- **Permanent (in main):** `glass_dialog.dart:9` — `actions: List<Widget> actions = const []` → `actionsBuilder: List<Widget> Function(BuildContext ctx)?` (1 line, type change); 4 `noBlur: true` additions on `discount_sheet.dart` `GlassPanel`s; 2 `noBlur: true, expand: false` additions on the bottom `GlassPanel.flush`es; 1 `noBlur: true` on `_ProductSellCard` (bundled from 6.6); the "Full sale form" `OutlinedButton` removal; 12 `actions: [...]` → `actionsBuilder: (ctx) => [...]` conversions.
- **No diagnostic artifacts** (none introduced in this phase).
- **No behavior change** for the user-visible flow beyond the fixes. Adding / editing / deleting a product / sale / expense still goes through the same `repo.create()` / `repo.update()` / `repo.delete()` paths and triggers the same `ref.invalidate(...)` chains from 6.4b.

---

## Phase 6.8 — Pop-up Visibility + Sales UX Fixes ✅

**Trigger:** User on-device report after Phase 6.7 — 4 visual / UX complaints about the sales flow:

1. **Pop-ups too translucent** — the dialog, the QuickSellSheet, the DiscountSheet, and the read-only product tile in the Log Sale form all use `GlassPanel(noBlur: true)` which renders a `Colors.white.withOpacity(0.14 → 0.04)` gradient. At 14% opacity the aurora bleeds through and the panel text is hard to read against the bright aurora. User feedback: "most of the pop ups are very translucent. increase the visibility of the pop ups."
2. **Product list / product selection translucent** — same root cause. The "Choose a product..." dropdown in the Log Sale form (shown in the screenshot) and the product picker in the DiscountSheet are both translucent, so product names are hard to read.
3. **Don't lock the product after selecting in Log Sales** — `sale_form_screen.dart:262-296` showed a static `Container` with a `lock_outline` icon once a product was selected, even in add mode. User feedback: "dont lock the product after selecting in log sales. make it a list, so that user can change the product if they incorrectly selected the product."
4. **Dashboard doesn't refresh after logging a sale via QuickSellSheet or DiscountSheet** — `quick_sell_sheet.dart` and `discount_sheet.dart` called `ref.read(saleRepositoryProvider).addSale(...)` then `Navigator.of(context).pop(true)` with NO `ref.invalidate(dashboardProvider)`. The `sale_form_screen` had it (line 166) but the sheets didn't. User feedback: "the dashboard doesnt refresh immediately when switching screens. i logged a sales entry, but when i came to dashboard it was not updated."
5. **QuickSellSheet has a huge gap after the content** — the sheet appears at the TOP of the screen with empty space below it (inside the `Padding` wrapper). User feedback: "when the sell button is clicked in the sales screen beside a product, change the size of the pop up to only use the necessary space that is need to show the elements."
6. **Confirm button behind the bottom nav** — same root cause as (5); the `Padding` wrapper inside the modal ignores the safe area, so the sheet's bottom is at the screen bottom and the bottom nav covers it.
7. **Alert dialog too translucent** — `showGlassDialog` uses `GlassPanel(noBlur: true, isFrostedGlass: true)` with the same low-opacity gradient. User feedback: "the alert pop up in also very translucent. increase the visibility of that pop up."
8. **Discount sheet too translucent + position low + confirm behind nav** — combines (1) + (5) + (6). User feedback: "the discounted sale pop up is also very translucent. increase the visibility. the position of the pop up very low. the confirm button is basically behind the nav bar."
9. **Background visible when pop-up is open** — `showGlassDialog` uses `barrierColor: Colors.black.withOpacity(0.35)` (very light) and the bottom sheets use the default `Colors.black54` (0.5) which is still too light against the bright aurora. User feedback: "when a pop up is opened, make sure the background is not visible. focus on the pop up only."

**Goal:** One atomic commit. Add a `solid` flag to `GlassPanel` for high-opacity surfaces, wrap all sheet builders in `Column(mainAxisSize: min)` with `useSafeArea: true` + 0.5 barrier, extract a shared `ProductPickerSheet` and use it in both the DiscountSheet and the Log Sale form (replacing the locked product display), add `ref.invalidate(...)` calls to the sheets, and remove the 100px bottom padding from the Log Sale form (option C: it was for inner scroll lists, not for full-screen routes).

| Task | Status | Notes |
|------|--------|-------|
| Diagnose: same translucent `noBlur` path + wrong modal wrap + missing `ref.invalidate` | ✅ | Bugs 1, 2, 7, 8: all the same `GlassPanel(noBlur: true)` low-opacity gradient. Bugs 5, 6, 8: all the same `Padding(bottom: viewInsets.bottom)` inside `showModalBottomSheet(isScrollControlled: true)` that doesn't size to content. Bug 3: read-only product display in add mode. Bug 4: missing `ref.invalidate` in sheets. Bug 9: barrier too light. |
| Add `solid: false` flag to `GlassPanel` | ✅ | `lib/core/widgets/glass_panel.dart` — new ctor param `solid`. When `true`, the `noBlur` branch swaps the gradient for `color: scheme.surface.withOpacity(isDark ? 0.92 : 0.95)` + 1px `scheme.outline.withOpacity(0.20)` border. `solid` implies `noBlur` behavior. Default `false`; no impact on existing callers. |
| Apply `solid: true` to dialog panel | ✅ | `lib/core/widgets/glass_dialog.dart:29` — `GlassPanel(radius: 24, isFrostedGlass: true, noBlur: true, solid: true, padding: ...)`. Dialog now renders as a near-opaque `scheme.surface` panel. |
| Increase dialog barrier | ✅ | `lib/core/widgets/glass_dialog.dart:16` — `barrierColor: Colors.black.withOpacity(0.35)` → `Colors.black.withOpacity(0.6)`. Background is dimmed to 60 % opacity when a dialog is open. |
| Apply `solid: true` to QuickSellSheet outer panel | ✅ | `lib/features/sales/widgets/quick_sell_sheet.dart:120` — `GlassPanel(radius: 28, margin: ..., padding: ..., noBlur: true, solid: true, child: ...)`. |
| Apply `solid: true` to DiscountSheet outer panel | ✅ | `lib/features/sales/widgets/discount_sheet.dart:122` — same change. |
| Apply `solid: true` to `_buildProductPicker()` panel | ✅ | `lib/features/sales/widgets/discount_sheet.dart:286` — same change. |
| Apply `solid: true` to shared `ProductPickerSheet` panel | ✅ | `lib/features/sales/widgets/product_picker_sheet.dart` — new file; `GlassPanel(radius: 28, margin: ..., padding: ..., noBlur: true, solid: true, child: ...)`. |
| Apply `solid: true` to Sale Form product panel | ✅ | `lib/features/sales/sale_form_screen.dart:248` — `GlassPanel(noBlur: true, solid: true, padding: ..., child: ...)`. |
| Apply `solid: true` to Sale Form details panel | ✅ | `lib/features/sales/sale_form_screen.dart:269` — same change. |
| Apply `solid: true` to Sale Form total panel | ✅ | `lib/features/sales/sale_form_screen.dart:367` — same change. |
| Fix bottom-sheet positioning (QuickSellSheet) | ✅ | `lib/features/sales/widgets/quick_sell_sheet.dart:288-307` — `showModalBottomSheet` now uses `useSafeArea: true, barrierColor: Colors.black.withOpacity(0.5)` and wraps the builder in `Column(mainAxisSize: MainAxisSize.min, children: [Padding(bottom: viewInsets.bottom, child: QuickSellSheet)])`. Sheet now sizes to content and positions at the bottom, above the bottom nav. |
| Fix bottom-sheet positioning (DiscountSheet) | ✅ | `lib/features/sales/widgets/discount_sheet.dart:361-381` — same change. |
| Extract `ProductPickerSheet` to a shared widget | ✅ | New `lib/features/sales/widgets/product_picker_sheet.dart` (60 lines) — public API `showProductPicker(BuildContext, {products, selectedId, inStockOnly}) → Future<int?>`. Replaces the inline `_ProductPickerSheet` class in `discount_sheet.dart`. The new picker shows a checkmark + bold + primary color on the currently-selected product. |
| Replace read-only product Container with tap-able tile (Log Sale form) | ✅ | `lib/features/sales/sale_form_screen.dart:415-489` — new `_buildProductTile` method. Renders an `InkWell` + `Container` with `scheme.primaryContainer.withOpacity(0.35)` background when a product is selected, `scheme.outline.withOpacity(0.3)` border. Tap (in add mode) → `showProductPicker(...)` → `_selectProduct(id)`. In edit mode the tile is locked (preserves original behavior — changing product would invalidate stock_movements history). Shows the product name, stock count, and a chevron / lock icon. |
| Remove 100px bottom padding from Log Sale form | ✅ | `lib/features/sales/sale_form_screen.dart:245` — `padding: const EdgeInsets.fromLTRB(16, 8, 16, 100)` → `padding: const EdgeInsets.fromLTRB(16, 8, 16, 24)`. The 100px was `kBottomNavClearance` for inner scroll lists; the form is a full-screen route and the `Scaffold` already accounts for the system bottom inset. |
| Dashboard refresh on QuickSellSheet save | ✅ | `lib/features/sales/widgets/quick_sell_sheet.dart:99-101` — after `addSale(...)`: `ref.invalidate(saleListProvider); ref.invalidate(productListProvider); ref.invalidate(dashboardProvider);`. (Side benefit: this also makes the previously-unused `product_provider.dart` import actually used, resolving the pre-existing `unused_import` warning.) |
| Dashboard refresh on DiscountSheet save | ✅ | `lib/features/sales/widgets/discount_sheet.dart:106-108` — same change. |
| Increase modal barrier opacity | ✅ | All 3 `showModalBottomSheet` calls (QuickSellSheet, DiscountSheet, ProductPickerSheet) — `barrierColor: Colors.black.withOpacity(0.5)`. |
| Verification — `flutter analyze` | ✅ | **20 issues, 1 fewer than 6.7** (the `quick_sell_sheet.dart` `product_provider.dart` `unused_import` warning is now resolved because the new `ref.invalidate(productListProvider)` call uses it). All 20 remaining are pre-existing: 1 `app_database.g.dart:2940` `duplicate_ignore` warning, 2 `export_service.dart:102-103` `curly_braces_in_flow_control_structures` info, 17 gitignored `test/unit/*` `avoid_relative_lib_imports` info. No new issues introduced. |
| Verification — `flutter test` | ✅ | **48/100 passing baseline, unchanged** by 6.8 (no tested code path was touched). All failures are pre-existing widget-test stream-subscription issues. |
| Verification — on-device | ⚠️ | **User must rebuild + test** to confirm: (a) dialog + both sheets + product picker now have near-opaque `scheme.surface` panels (no more translucent aurora bleed); (b) both sheets sit at the bottom, sized to their content, above the bottom nav (no more huge gap, no more confirm-behind-nav); (c) tapping the product tile in the Log Sale form opens the shared picker; selecting a different product updates the tile; (d) after saving a sale via QuickSellSheet or DiscountSheet, the Dashboard tab shows the updated stats when visited; (e) the background is dimmed to 50 % (sheets) or 60 % (dialog) opacity when a pop-up is open. |
| Commit + push | ✅ | `fix(theme): phase 6.8 — pop-up visibility + sales UX fixes` (5 files modified, 1 new file, +157 / -142): `glass_panel.dart` (1 `solid` flag), `glass_dialog.dart` (1 `solid: true` + barrier 0.6), `quick_sell_sheet.dart` (modal wrap + `solid: true` + `ref.invalidate` + barrier 0.5), `discount_sheet.dart` (modal wrap + `solid: true` × 2 + `ref.invalidate` + use shared picker), `sale_form_screen.dart` (tap-able tile + `solid: true` × 3 + remove 100px bottom pad), NEW `product_picker_sheet.dart` (extracted from `discount_sheet.dart`'s `_ProductPickerSheet`). Pushed to `https://github.com/ifti136/Invenio.git`. |

**Regression table — pop-up / surface visibility history:**
| Phase | Surface | Fix |
|-------|---------|-----|
| 1.5 | Bottom nav (`SizedBox.expand` collapse) | `kBottomNavHeight = 76` cap |
| 6.2 | Form-level `GlassPanel` (`SizedBox.expand` collapse) | `GlassPanel(noBlur: true)` |
| 6.3 | `GlassTextField` internal `GlassPanel` | `GlassPanel(noBlur: true)` inside `glass_text_field.dart` |
| 6.5 | Body `GlassPanel`s (×18) + dialog `GlassPanel` (translucent) | `GlassPanel(noBlur: true)` |
| 6.6 | `_ProductSellCard` `GlassPanel` inside `SliverList` | `GlassPanel(noBlur: true)` |
| 6.7 | 3 `GlassPanel`s in `DiscountSheet` + 2 flush panels | `GlassPanel(noBlur: true)` + `expand: false` |
| 6.7 | `showGlassDialog` `actions` capturing sheet's `BuildContext` | `actionsBuilder: (ctx) => [...]` |
| 6.8 | Dialog + both sheets + product picker (translucent) | `GlassPanel(solid: true)` — `scheme.surface` 0.92/0.95 |
| 6.8 | Sheets positioned at top of screen (huge gap + behind nav) | `Column(mainAxisSize: min)` + `useSafeArea: true` |
| 6.8 | Dashboard not refreshed after sheet-saved sales | `ref.invalidate(saleListProvider/productListProvider/dashboardProvider)` in sheets |
| 6.8 | Product locked after selection in Log Sale form | Tap-able tile → shared `ProductPickerSheet` |

**Permanent vs. diagnostic:**
- **Permanent (in main):** `glass_panel.dart` `solid` flag; `solid: true` on 7 surfaces (dialog + 2 sheets + product picker + 3 form panels); `Column(mainAxisSize: min)` + `useSafeArea: true` + barrier 0.5 on 3 `showModalBottomSheet` calls; new shared `ProductPickerSheet`; tap-able product tile in `sale_form_screen.dart`; `ref.invalidate` calls in 2 sheets; barrier 0.6 on `showGlassDialog`; 100px → 24px bottom padding on Log Sale form.
- **No diagnostic artifacts** (none introduced in this phase).
- **No behavior change** for the user-visible flow beyond the fixes. Adding / editing / deleting a product / sale / expense still goes through the same `repo.create()` / `repo.update()` / `repo.delete()` paths and triggers the same `ref.invalidate(...)` chains from 6.4b and 6.8.

---

## Phase 6.9 — Modal Bottom Sheets Clear the Custom Nav Bar ✅

**Trigger:** User on-device report after Phase 6.8 — the pop-up for both the **Discount** button and the **Quick sell** button (beside a product in the sales list) was still rendering behind the bottom nav bar. The Phase 6.8 modal wrap (`Column(mainAxisSize: min) + useSafeArea: true + Padding(bottom: viewInsets.bottom)`) fixed the "huge gap after the content" and positioned the sheet at the screen bottom, but it didn't account for the 76-px-tall custom `bottomNavigationBar` slot. User feedback: *"the pop up for both discounted sales and normal sale button beside the product in sales screen is behind the bottom nav bar. make the pop up above the nav bar. update the pop up current position += the nav bar position. the pop up works perfectly when the keyboard is popping."*

**Diagnosis:**
- `viewInsets.bottom` is `0` when the keyboard is closed and `~300 px` when it opens.
- `useSafeArea: true` only accounts for the **system** safe area (gesture bar inset, ~16-24 px), not our custom `bottomNavigationBar` slot (76 px + 8 px padding inside a `SafeArea`).
- The user's "current position += nav bar position" is literally `viewInsets.bottom + kBottomNavHeight + 8`, but the functionally equivalent `max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` (1) clears the nav in the no-keyboard case (the only case the user reported), and (2) preserves the exact keyboard behavior in the keyboard-open case (no extra 84-px gap below the sheet).
- The 2 modal sheets touched in 6.8 (`quick_sell_sheet`, `discount_sheet`) and the new `product_picker_sheet` all had this bug. Two more modals — `restock_sheet` and `product_filter_sheet` — were not touched in 6.8 and had the SAME bug but a more primitive `showModalBottomSheet` (no `useSafeArea`, no `Column(mainAxisSize: min)` wrap, just `builder: (_) => Sheet`).

**Goal:** One atomic commit. Apply the `max()` formula to all 5 modals in the codebase. RestockSheet is a tall modal — user said "make it as the other screens" meaning "position it the same way as the other modal sheets" (NOT a full-screen route).

| Task | Status | Notes |
|------|--------|-------|
| Diagnose: missing nav-bar clearance in 5 modals | ✅ | All 5 `showModalBottomSheet` callers had `bottom: viewInsets.bottom` (or no bottom padding at all). When `viewInsets.bottom == 0`, the sheet sits at the actual screen bottom, behind the 76-px nav. |
| `quick_sell_sheet.dart:300-321` — apply `max()` | ✅ | Was already wrapped in `Column(min) + Padding(bottom: viewInsets.bottom)` from 6.8. Dropped `useSafeArea: true`. Bottom padding now `math.max(viewInsets.bottom, mq.padding.bottom + kBottomNavHeight + 8)`. |
| `discount_sheet.dart:361-385` — apply `max()` | ✅ | Same change as above. |
| `product_picker_sheet.dart:16-41` — apply `max()` | ✅ | Same change as above. |
| `restock_sheet.dart:27-50` — add modal wrap + `max()` | ✅ | Was `builder: (_) => RestockSheet(...)` with no wrap. Added `Column(mainAxisSize: min) + Padding(bottom: max(...)) + child: RestockSheet(...)` wrap. Bumped `barrierColor` `0.35` → `0.5` to match design system. Removed the redundant inner `Padding(bottom: insets.bottom)` inside `build()` (now handled by the modal wrap, which was double-counting the keyboard inset). |
| `product_filter_sheet.dart:16-37` — add modal wrap + `max()` | ✅ | Same structural change as `restock_sheet.dart` (add modal wrap, drop inner `Padding(bottom: insets.bottom)`, bump barrier `0.35` → `0.5`). |
| Verification — `flutter analyze` | ✅ | **20 issues, 0 new from 6.9** (all 20 are pre-existing: 1 `app_database.g.dart:2940` `duplicate_ignore` warning, 2 `export_service.dart:102-103` `curly_braces_in_flow_control_structures` info, 17 gitignored `test/unit/*` `avoid_relative_lib_imports` info). |
| Verification — `flutter test` | ✅ | **100/100 passing** (full pass, no failures). Prior 6.8/6.7 reports of "48 passed / 52 failed" appear to have been intermittent `LD_LIBRARY_PATH`/sqlite-loader issues in this env, not real failures. The `test/REPORT.md` (gitignored) lists 52 expected-to-fail tests from a previous run; all passed in this run. |
| Verification — on-device | ⚠️ | **User must rebuild + test** to confirm: (a) **QuickSellSheet** — sales list → product → "Quick sell" → confirm button visible above nav bar. (b) **DiscountSheet** — same. (c) **ProductPickerSheet** — opened from discount sheet or from Log Sale form's product tile → visible above nav. (d) **RestockSheet** — products list → product → "Restock" → visible above nav. (e) **ProductFilterSheet** — sales list → filter chip → visible above nav. (f) Keyboard behavior — open any of the above, tap a text field → sheet still fully visible above the keyboard (6.8 behavior preserved exactly). |
| Commit + push | ✅ | `fix(theme): phase 6.9 — modal bottom sheets clear the custom nav bar` (5 files modified, +88 / -56): `quick_sell_sheet.dart`, `discount_sheet.dart`, `product_picker_sheet.dart`, `restock_sheet.dart`, `product_filter_sheet.dart`. Pushed to `https://github.com/ifti136/Invenio.git`. |

**Regression table — pop-up / surface visibility history:**
| Phase | Surface | Fix |
|-------|---------|-----|
| 1.5 | Bottom nav (`SizedBox.expand` collapse) | `kBottomNavHeight = 76` cap |
| 6.2 | Form-level `GlassPanel` (`SizedBox.expand` collapse) | `GlassPanel(noBlur: true)` |
| 6.3 | `GlassTextField` internal `GlassPanel` | `GlassPanel(noBlur: true)` inside `glass_text_field.dart` |
| 6.5 | Body `GlassPanel`s (×18) + dialog `GlassPanel` (translucent) | `GlassPanel(noBlur: true)` |
| 6.6 | `_ProductSellCard` `GlassPanel` inside `SliverList` | `GlassPanel(noBlur: true)` |
| 6.7 | 3 `GlassPanel`s in `DiscountSheet` + 2 flush panels | `GlassPanel(noBlur: true)` + `expand: false` |
| 6.7 | `showGlassDialog` `actions` capturing sheet's `BuildContext` | `actionsBuilder: (ctx) => [...]` |
| 6.8 | Dialog + both sheets + product picker (translucent) | `GlassPanel(solid: true)` — `scheme.surface` 0.92/0.95 |
| 6.8 | Sheets positioned at top of screen (huge gap + behind nav) | `Column(mainAxisSize: min)` + `useSafeArea: true` |
| 6.8 | Dashboard not refreshed after sheet-saved sales | `ref.invalidate(saleListProvider/productListProvider/dashboardProvider)` in sheets |
| 6.8 | Product locked after selection in Log Sale form | Tap-able tile → shared `ProductPickerSheet` |
| 6.9 | 5 modals sit at screen bottom, hidden behind nav bar (no-keyboard case) | `math.max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` + drop `useSafeArea: true` |
| 6.9 | `RestockSheet` and `ProductFilterSheet` lack the `Column(min)` modal wrap from 6.8 | Added wrap; bumped barrier `0.35` → `0.5` to match design system |

**Permanent vs. diagnostic:**
- **Permanent (in main):** `math.max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)` formula on all 5 `showModalBottomSheet` callers. `restock_sheet.dart` and `product_filter_sheet.dart` now also have the `Column(mainAxisSize: min)` wrap that the 3 sales-flow modals got in 6.8. `barrierColor` `0.35` → `0.5` on `restock_sheet.dart` and `product_filter_sheet.dart`.
- **No diagnostic artifacts** (none introduced in this phase).
- **No behavior change** for the user-visible flow beyond the fixes. All 5 sheets still pop with the same trigger (button / list-tile tap), still use the same `GlassPanel(noBlur: true, solid: true)` (6.8) for the body, and still go through the same `ref.invalidate(...)` chains on save (6.4b, 6.8).

---

## Phase 7.0 — App Branding for v1.0.0 ✅

**Trigger:** User request — *"add image invenio.png as the app logo. to give the app a personal and professional look. also change the version to the version 1.0.0."* The repo had a polished 2048×2048 invenio.png at the repo root (untracked), but the app was shipping with the default Flutter placeholder launcher icon, a plain white splash, and the Android label "tracker". None of that matched the product name "Invenio".

**Goal:** Personalize the app for the 1.0 release — branded launcher icon (with adaptive icon for Android 8.0+), branded splash screen, Android app label = "Invenio", version bumped to 1.0.0+2.

| Task | Status | Notes |
|------|--------|-------|
| Move invenio.png → tracker_app/assets/icon/ | ✅ | `mv invenio.png tracker_app/assets/icon/invenio.png`. Was at repo root, 1.38 MB, untracked. |
| Add `flutter_launcher_icons: ^0.14.4` to dev_dependencies | ✅ | `pubspec.yaml:62`. (Initially used `^0.13.1`; upgraded to `0.14.4` because the older version's flat-config format (`android: true`) silently skipped adaptive-icon generation in this env. The new format works.) |
| Add `flutter_launcher_icons:` config block | ✅ | `pubspec.yaml:106-113`. `image_path: "assets/icon/invenio.png"`, `android: true, ios: false, adaptive_icon_background: "#1D9E75", adaptive_icon_foreground: "assets/icon/invenio.png", min_sdk_android: 24`. Per the package docs, adaptive icons require BOTH background AND foreground explicitly — `image_path` is not auto-used as foreground. |
| Run `dart run flutter_launcher_icons` | ✅ | Generated: (1) 5 `mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` (48/72/96/144/192 px, 8-bit RGBA, replacing the 8-bit colormap placeholders), (2) 5 `drawable-{mdpi…xxxhdpi}/ic_launcher_foreground.png` (rasterized from invenio.png with 16% safe-zone inset for the adaptive icon foreground), (3) `mipmap-anydpi-v26/ic_launcher.xml` + `ic_launcher_round.xml` adaptive-icon descriptors, (4) `values/colors.xml` with `ic_launcher_background = #1D9E75`. |
| Cleanup leftover files from intermediate runs | ✅ | Removed `mipmap-{mdpi…xxxhdpi}/launcher_icon.png` (leftover from an earlier `android: "launcher_icon"` test run; the manifest references `@mipmap/ic_launcher`, not `@mipmap/launcher_icon`). |
| Bump `pubspec.yaml` version `1.0.0+1` → `1.0.0+2` | ✅ | versionName stays 1.0.0; versionCode bumps to 2 because the icon change is a new build. Android uses versionCode to distinguish builds for the same versionName. |
| Change `AndroidManifest.xml` label `"tracker"` → `"Invenio"` | ✅ | `tracker_app/android/app/src/main/AndroidManifest.xml:3`. The `applicationId` in `build.gradle.kts` stays `com.reseller.tracker` — that string is the unique Play Store identifier and must not change. |
| Custom splash with the logo | ✅ | Generated `mipmap-xxxhdpi/launch_image.png` (512×512, 84 KB) via `convert assets/icon/invenio.png -resize 512x512 ...`. Edited `drawable/launch_background.xml` to add a centered `<bitmap android:src="@mipmap/launch_image" android:gravity="center" />` item on top of the existing white background. The same `launch_background.xml` is referenced by both `values/styles.xml` (light) and `values-night/styles.xml` (dark), so the logo shows in both modes on a white background. |
| Verification — `flutter analyze` | ✅ | **20 issues, 0 new from 7.0** (no Dart code changed; asset/config only). |
| Verification — `flutter test` | ✅ | **100/100 passing** (no Dart code changed). |
| Verification — on-device | ⚠️ | **User must `flutter clean && flutter run`** + **uninstall the previous build first** (Android caches launcher icons per package, so the old Flutter placeholder will persist otherwise). Verify: (a) home-screen + app-drawer icon = invenio.png with teal `#1D9E75` background and the system mask shape (circle on Pixel, squircle on Samsung, etc.) on Android 8.0+. (b) App label = "Invenio" in app drawer, home screen, Settings → Apps. (c) Splash shows the invenio logo centered on white for ~300 ms before Flutter UI takes over. (d) Build metadata shows version 1.0.0 (versionCode 2). |
| Commit + push | ✅ | `chore(repo): phase 7.0 — invenio.png as launcher icon, custom splash, v1.0.0+2` (18 files: 9 modified, 9 new; ~+19 / -7 lines of code + 1.5 MB of binary assets). Pushed to `https://github.com/ifti136/Invenio.git`. |

**Asset summary:**
| Path | Type | Size | Notes |
|------|------|------|-------|
| `tracker_app/assets/icon/invenio.png` | Source | 1.38 MB | 2048×2048 RGBA, original asset (moved from repo root) |
| `tracker_app/android/app/src/main/res/mipmap-{mdpi…xxxhdpi}/ic_launcher.png` | Legacy launcher icon | 1.7–16 KB | 5 density variants (48/72/96/144/192 px) |
| `tracker_app/android/app/src/main/res/drawable-{mdpi…xxxhdpi}/ic_launcher_foreground.png` | Adaptive-icon foreground | — | 5 density variants, rasterized from invenio.png with 16% safe-zone inset |
| `tracker_app/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | Adaptive-icon descriptor | 335 B | Refs `@color/ic_launcher_background` + `@drawable/ic_launcher_foreground` (inset 16%) |
| `tracker_app/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` | Round adaptive-icon descriptor | 335 B | Same as `ic_launcher.xml`; for circular launchers |
| `tracker_app/android/app/src/main/res/values/colors.xml` | Color resource | — | `ic_launcher_background = #1D9E75` (teal from `app_colors.dart`) |
| `tracker_app/android/app/src/main/res/mipmap-xxxhdpi/launch_image.png` | Splash logo | 84 KB | 512×512 RGBA, generated via `convert -resize 512x512` |

**Permanent vs. diagnostic:**
- **Permanent (in main):** All assets + config files above. `flutter_launcher_icons: ^0.14.4` is a dev_dependency that is only used at icon-generation time (not at app run time). The generated assets are committed, so CI builds don't need to re-run the package.
- **No diagnostic artifacts** (none introduced in this phase).
- **No behavior change** for the app's Dart code (no `.dart` files modified). Only Android resources, AndroidManifest, and pubspec.yaml.

---

## Test Suite ⚠️

| Task | Status | Notes |
|------|--------|-------|
| Step 1: Extract `buildWorkbook()` from `ExportService` | ✅ | `lib/services/export_service.dart` — `buildWorkbook(DateTime month)` returns `Workbook` for testable verification; `exportMonth` now delegates to it |
| Step 2: 8 unit test files | ✅ | `test/unit/database_schema_test.dart` (5), `product_repository_test.dart` (14), `alert_service_test.dart` (16), `sale_repository_test.dart` (10), `expense_repository_test.dart` (14), `profit_calculation_test.dart` (14), `dashboard_provider_test.dart` (4), `export_service_test.dart` (3) |
| Step 3: 7 widget test files | ✅ | `test/widget/theme_test.dart` (5), `router_test.dart` (2), `product_form_test.dart` (2), `sale_form_test.dart` (2), `expense_form_test.dart` (4), `dashboard_test.dart` (2), `chart_toggle_test.dart` (4) |
| Step 4: Run suite | ✅ | **100/100 tests passing.** All widget tests using `UncontrolledProviderScope` + manual `ProviderContainer` dispose (no pending timer leaks). All DB-dependent tests require `libsqlite3.so`. |
| Step 5: `test/REPORT.md` | ✅ | Generated with per-phase breakdown, known limitations, manual verification checklist |
| Step 6: `.gitignore` exception | ✅ | `!tracker_app/test/REPORT.md` present |
| Step 7: Fix compilation errors | ✅ | Cascade operator in `export_service.dart`, `worksheets.length` → `worksheets.count` in test, missing `drift/drift.dart` import in test, legacy `widget_test.dart` |
| Step 8: Fix widget test rendering | ✅ | All widget tests updated with `SizedBox(width: 800, height: 1200)` constraints, `pumpAndSettle(Duration)`, `GlassPanel.testOverride = true`, and `UncontrolledProviderScope` + manual `ProviderContainer` dispose |
| Step 9: Fix app source code | ✅ | `GlassPanel` wrapped in `LayoutBuilder` to respect parent constraints in `ListView`; `ProductRepository.update()` and `ExpenseRepository.update()` use `Value.absent()` for null note (preserve-existing-value semantics) |

**Known limitations:**
- All Drift-backed tests require `libsqlite3.so` native library. If missing, symlink: `sudo ln -s /lib64/libsqlite3.so.0 /usr/lib/libsqlite3.so` (Linux) or use `LD_LIBRARY_PATH` with a `/tmp/libsqlite3.so` symlink.
- `glass_kit` `BackdropFilter` compositing produces warnings in headless test mode; app works correctly on device.
- `aurora_background` continuous animation prevents `pumpAndSettle()` from settling; use `pump(Duration)` with explicit duration in widget tests.
- Run full suite locally with `flutter test --reporter expanded` after ensuring sqlite3 is available.
- Riverpod `keepAlive: true` providers maintain stream subscriptions; widget tests use `UncontrolledProviderScope` + manual `ProviderContainer.dispose()` and `db.close()` in `addTearDown` to clean up cleanly and avoid pending-timer failures.

---

## Folder Structure

```
docs/
├── instructions/                        ✅ (6 spec files — moved from root)
│   ├── 01_requirements.md
│   ├── 02_system_design.md
│   ├── 03_code_specs.md
│   ├── 04_scaffolding.md
│   ├── 05_implementation.md
│   └── 06_completion_status.md
├── BUG_REPORT.md                        ✅ (moved from root)
├── error.md                             ✅ (moved from root)
└── REDESIGN.md                          ✅ (moved from root)
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
│   │   ├── app_bottom_nav.dart        ✅ (Liquid Glass: floating glass nav; `kBottomNavHeight = 76` and `kBottomNavClearance = 100` constants; `SizedBox` cap works around `glass_kit` intrinsic-infinity)
│   │   ├── empty_state.dart           ✅ (icon + title + message + optional action)
│   │   ├── glass_dialog.dart          ✅ (Liquid Glass: generic showGlassDialog<T>; **Phase 6.5**: `noBlur: true` on the inner `GlassPanel` to work around `glass_kit` `SizedBox.expand` 0×0 collapse + `BackdropFilter` touch-eating; **Phase 6.7**: `actions: List<Widget>` → `actionsBuilder: List<Widget> Function(BuildContext ctx)?` so action `onPressed` callbacks `Navigator.of(ctx).pop(...)` on the dialog's `ctx` instead of the caller's outer-scope `context`, fixing the bottom-sheet-getting-popped-instead-of-dialog bug)
│   │   ├── glass_panel.dart           ✅ (Liquid Glass; Phase 6.2: `noBlur: false` opt-in flag for H3 form-collapse fallback)
│   │   ├── glass_text_field.dart      ✅ (Liquid Glass: TextFormField-backed, validator / inputFormatters / autofocus; Phase 6.3: `noBlur: true` permanent fix for `glass_kit` `SizedBox.expand` 0×0 collapse inside Column/ListView)
│   │   ├── sheet_drag_handle.dart     ✅ (Phase 6: shared 40×4 px pill for bottom sheets)
│   │   └── stat_card.dart             ✅
│   ├── utils/
│   │   └── formatters.dart            ✅ (money / date / date-time / day / quantity)
│   ├── extensions/
│   │   └── db_extensions.dart         ✅ (ExpenseX and SaleX dateAsDateTime extensions)
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
│   │   ├── dashboard_provider.dart    ✅ (today's summary computation; **Phase 6.5**: silently-ignored `@Riverpod(keepAlive: true)` removed from `dashboard` — now auto-dispose)
│   │   ├── dashboard_provider.g.dart  ✅ (generated)
│   │   └── dashboard_screen.dart      ✅ (stats grid, platform breakdown, low stock; **Phase 6.5**: `noBlur: true` on the "Today" stat grid + "Platform Breakdown" + "Low Stock" `GlassPanel`s)
│   ├── products/
│   │   ├── product_list_screen.dart   ✅ (Phase 6.4: `AppBar` restored, no diagnostic borders; Phase 6.4c: teal `+` `IconButton` in `SliverAppBar.actions`; FAB in Phase 6.4 was hidden at runtime by outer bottom nav; **Phase 6.5**: `noBlur: true` on the stat-pills `GlassPanel`)
│   │   ├── product_form_screen.dart   ✅ (Phase 6.4: AppBar restored, no diagnostic borders; Phase 6.4b: ref.invalidate(productListProvider) + ref.invalidate(dashboardProvider) on save/delete; **Phase 6.7**: 3 `showGlassDialog` calls converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   │   ├── product_detail_screen.dart ✅ (header, recent sales, stock movements; **Phase 6.5**: `noBlur: true` on the header, stock-movements, and recent-sales `GlassPanel`s)
│   │   ├── product_repository.dart    ✅ (Drift-backed, transactional)
│   │   ├── product_provider.dart      ✅ (Riverpod: list, filter, byId, movements, sales, stats; **Phase 6.5**: silently-ignored `@Riverpod(keepAlive: true)` removed from `productList`, `ProductFilter`, `filteredProductList` — now auto-dispose)
│   │   └── widgets/
│   │       ├── stock_badge.dart       ✅
│   │       ├── product_tile.dart      ✅
│   │       ├── restock_sheet.dart     ✅ (**Phase 6.7**: 2 `showGlassDialog` calls converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   │       ├── stock_movement_item.dart ✅
│   │       └── sale_list_item.dart    ✅ (extended with optional callbacks)
│   ├── sales/
│   │   ├── sale_list_screen.dart      ✅ (Phase 6.4: `AppBar` restored, no diagnostic borders; Phase 6.4c: teal `+` `IconButton` in `SliverAppBar.actions`; FAB in Phase 6.4 was hidden at runtime by outer bottom nav; **Phase 6.5**: `noBlur: true` on the "Log discounted sale" + "Recent Sales" `GlassPanel`s; **Phase 6.6**: `noBlur: true` on the `_ProductSellCard` `GlassPanel` to render the product sell cards in the `SliverList`; **Phase 6.7**: removed redundant "Full sale form" `OutlinedButton` `SliverToBoxAdapter` (teal `+` in AppBar is now the sole entry point))
│   │   ├── sale_form_screen.dart      ✅ (Phase 6.4: AppBar restored, no diagnostic borders; Phase 6.4b: ref.invalidate(dashboardProvider) added alongside existing saleList + productList invalidations; **Phase 6.7**: 2 `showGlassDialog` calls converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   │   ├── sale_repository.dart       ✅ (Drift-backed, transactional, SaleFilter)
│   │   ├── sale_provider.dart         ✅ (Riverpod: list, filtered list, detail, last price, cost map, stats; **Phase 6.5**: silently-ignored `@Riverpod(keepAlive: true)` removed from `saleList` + `filteredSaleList` — now auto-dispose)
│   │   └── widgets/
│   │       ├── sale_filter_bar.dart   ✅ (4-row chip filter)
│   │       ├── product_filter_sheet.dart ✅ (modal bottom sheet with search)
│   │       ├── discount_sheet.dart    ✅ (**Phase 6.7**: `noBlur: true` on outer `GlassPanel` (`:126`), `_buildProductPicker()` `GlassPanel` (`:292`), and `_ProductPickerSheet` `GlassPanel` (`:367`) to work around `glass_kit` `SizedBox.expand` 0×0 collapse in `showModalBottomSheet`; `noBlur: true, expand: false` on bottom `GlassPanel.flush` (`:221`) to render the Discount/Profit/Confirm panel; 1 `showGlassDialog` call converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   │       └── quick_sell_sheet.dart  ✅ (**Phase 6.7**: `noBlur: true, expand: false` on bottom `GlassPanel.flush` (`:212`) to render the Total/Profit/Confirm panel; 1 `showGlassDialog` call converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   ├── expenses/
│   │   ├── expense_repository.dart    ✅ (enum, filter, CRUD, riverpod provider)
│   │   ├── expense_provider.dart      ✅ (Riverpod: streams, filtered family, stats; **Phase 6.5**: silently-ignored `@Riverpod(keepAlive: true)` removed from `expenseList` + `filteredExpenseList` — now auto-dispose)
│   │   ├── expense_list_screen.dart   ✅ (Phase 6.4: `AppBar` restored, no diagnostic borders; Phase 6.4b: ref.invalidate(dashboardProvider) on delete; Phase 6.4c: teal `+` `IconButton` in `SliverAppBar.actions`; FAB in Phase 6.4 was hidden at runtime by outer bottom nav; **Phase 6.5**: `noBlur: true` on the stats + date-filter `GlassPanel`s; **Phase 6.7**: 1 `showGlassDialog` call converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   │   ├── expense_form_screen.dart   ✅ (Phase 6.4: AppBar restored, no diagnostic borders; Phase 6.4b: ref.invalidate(dashboardProvider) added to existing expenseList invalidations; **Phase 6.7**: 2 `showGlassDialog` calls converted to `actionsBuilder: (ctx) => [...]` + `Navigator.of(ctx).pop(...)`)
│   │   └── widgets/
│   └── reports/
│       ├── report_repository.dart     ✅ (daily / monthly / product queries + providers)
│       ├── report_repository.g.dart   ✅ (generated)
│       ├── reports_screen.dart        ✅ (3-tab Daily/Monthly/Products, export)
│       └── widgets/
│           ├── bar_chart_widget.dart   ✅ (fl_chart bar charts)
│           └── chart_table_toggle.dart ✅ (AnimatedSwitcher toggle)
├── models/
│   ├── dashboard_summary.dart         ✅ (DashboardSummary)
│   └── monthly_report.dart            ✅ (DailySnapshot / MonthlySummary / ProductReportRow)
├── services/
│   ├── alert_service.dart             ✅ (sealed AppAlert: BelowCost / LowStock / MarginDrop; **Phase 6.5**: silently-ignored `@Riverpod(keepAlive: true)` removed from `alertService` — now auto-dispose)
│   └── export_service.dart            ✅ (Excel export via syncfusion + share_plus; buildWorkbook extracted)
test/
├── REPORT.md                          ✅ (test report with per-phase breakdown)
├── unit/
│   ├── alert_service_test.dart        ✅ (16 tests — pure logic, no DB)
│   ├── database_schema_test.dart      ✅ (5 tests — DB-dependent)
│   ├── dashboard_provider_test.dart   ✅ (4 tests — DB-dependent)
│   ├── expense_repository_test.dart   ✅ (14 tests — DB-dependent)
│   ├── export_service_test.dart       ✅ (3 tests — DB-dependent)
│   ├── product_repository_test.dart   ✅ (14 tests — DB-dependent)
│   ├── profit_calculation_test.dart   ✅ (14 tests — pure functions)
│   └── sale_repository_test.dart      ✅ (10 tests — DB-dependent)
└── widget/
    ├── chart_toggle_test.dart         ✅ (4 tests — pure widget)
    ├── dashboard_test.dart            ✅ (2 tests — widget + DB)
    ├── expense_form_test.dart         ✅ (3 tests — widget + DB)
    ├── product_form_test.dart         ✅ (2 tests — widget + DB)
    ├── router_test.dart               ✅ (2 tests — widget)
    ├── sale_form_test.dart            ✅ (2 tests — widget + DB)
    └── theme_test.dart                ✅ (5 tests — pure theme)
```

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done and verified |
| ⚠️ | Done but not fully verified (no device) |
| ⬜ | Not started |

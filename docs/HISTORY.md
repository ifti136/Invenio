# History
 
## Liquid Glass Design Transition (Phases 3, 6, 8, 11)
**Trigger:** The need to transition the app from a basic Material 3 look to a high-fidelity "Liquid Glass" aesthetic as specified in `full_DESIGN.md`.
 
**Diagnosis:** The previous UI was functional but lacked the visual identity and polish required for a premium feel. Key gaps included the absence of a dynamic background, inconsistent surface transparency, lack of haptic feedback, and a dashboard that didn't provide a high-level "at-a-glance" financial overview.
 
**Fix:** Implemented a multi-phase UI overhaul:
- **Theme System (Phase 3):** Introduced a provider-driven theme system with 4 distinct themes. Implemented the "Solid Slate" theme to provide a high-contrast, opaque alternative to the glass aesthetic. Added theme persistence via `shared_preferences`.
- **Add-Ons UI (Phase 6):** Integrated a flexible add-on system into the sales flow, allowing users to add multiple custom costs to a sale. This included a new `AddOnPickerSheet` and live profit recalculation.
- **Dashboard Redesign (Phase 8):** Completely refactored the dashboard into a modular grid of "Glass Cards". Added a `TodayCard` for immediate stats, a `PlatformPerformanceCard` with a donut chart for revenue split, and a `StockAlertsCard` for proactive inventory management.
- **UI Polish & Haptics (Phase 11):** Standardized haptic feedback across the app using a new `HapticService` and `HapticWrapper`. Conducted a "Glass Audit" to ensure all surfaces correctly used `GlassPanel` and `GlassTextField` to avoid rendering regressions.
 
**Verification:** `flutter analyze` clean. Verified on-device: theme switching is instantaneous, haptics provide tactile confirmation for all primary actions, and the dashboard correctly reflects real-time data from the database.
 
---
 
## BFMS Integration & Stabilization

**Trigger:** The need to move beyond simple profit tracking to actual financial management, including multi-wallet support and budget buckets.

**Diagnosis:** The existing schema (v2) only tracked total revenue and expenses without attributing them to specific financial accounts or budgets.

**Fix:** Implemented BFMS in two phases. Phase 1 introduced the schema v4 with `Wallets`, `AllocationRules`, and `BudgetBuckets`. Phase 2 integrated these into the sales and expense flows, ensuring that every sale triggers an allocation event and every expense is tracked against a budget. Stabilization involved fixing race conditions in wallet balance updates and ensuring allocation rules are applied atomically.

**Verification:** `flutter analyze` clean. `flutter test` 100/100. Verified on-device: sales correctly split across wallets, and budget buckets reflect current spending.

## Phase 7.0 — Branding assets

**Trigger:** Default Flutter launcher icon (8-bit colormap PNG, ~1 KB)
and `android:label = "tracker"` did not match the product name "Invenio"
or the `invenio.png` (2048×2048 RGBA, 1.4 MB) sitting untracked at the
repo root.

**Diagnosis:** No automated icon generation; splash was a plain white
drawable; Android label was the default `flutter create` value.

**Fix:** Moved `invenio.png` into `tracker_app/assets/icon/`; added
`flutter_launcher_icons: ^0.14.4` with a config block (background
`#1D9E75`, foreground from the asset, `min_sdk_android: 24`); ran
`dart run flutter_launcher_icons` to generate 5 mipmap variants + 5
drawable foregrounds + adaptive-icon XML descriptors + a `colors.xml`
with the teal accent; added a custom splash (`launch_background.xml`
referenced from `values/styles.xml` and `values-night/styles.xml`);
changed `AndroidManifest.xml android:label` to `"Invenio"` (kept
`applicationId = com.reseller.tracker` because that string is the
unique Play Store identifier); bumped `version: 1.0.0+1` → `1.0.0+2`.

**Verification:** `flutter analyze` 20 → 20 (0 new; no Dart code
touched). `flutter test` 100/100. Not yet verified on a device —
user must `flutter clean && flutter run` and uninstall the previous
build first (Android caches launcher icons per package).

## Phase 6.9 — Modal bottom sheets clear the custom nav

**Trigger:** User reported: "when the sell button is clicked in the
sales screen beside a product, change the size of the pop up to only
use the necessary space that is need to show the elements." The
modal sat at the screen bottom and the 76-px custom
`bottomNavigationBar` covered its bottom edge.

**Diagnosis:** `viewInsets.bottom` is 0 when the keyboard is closed,
so the `Padding(bottom: viewInsets.bottom, child: ...)` in the modal
build sat at the screen bottom. `useSafeArea: true` only accounts
for the system safe area, not our custom nav. This was the same
root cause for all 5 modals — the 3 from 6.8 (QuickSellSheet,
DiscountSheet, ProductPickerSheet) plus the 2 unmentioned
(RestockSheet, ProductFilterSheet).

**Fix:** Replaced the bottom padding with
`max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)`.
Dropped `useSafeArea: true` to avoid double-counting the system
inset. When the keyboard is open, `viewInsets.bottom` (300+) wins,
so keyboard behavior is preserved exactly. Applied to all 5
`showModalBottomSheet` callers. `restock_sheet` and
`product_filter_sheet` also gained the `Column(mainAxisSize: min)`
modal wrap and a barrier bump from 0.35 → 0.5.

**Verification:** `flutter analyze` 20 → 20 (0 new). `flutter test`
100/100. Not yet verified on a device.

## Phase 6.8 — Pop-up visibility + sales UX

**Trigger:** 4 on-device complaints about the sales flow:
translucent pop-ups (dialog / sheets / product tile / Log Sale
dropdown), sheets positioned at the top of the screen with a huge
gap below, Confirm button hidden by the bottom nav, and the
dashboard not refreshing after a sheet-saved sale.

**Diagnosis:** `GlassPanel(noBlur: true)` uses a
`Colors.white.withOpacity(0.14 → 0.04)` gradient — at 14% the
aurora bleeds through and panel text is hard to read against the
bright aurora. The modal wrap was `Padding(bottom: viewInsets.bottom)`
inside `showModalBottomSheet(isScrollControlled: true)`, which
doesn't size to content and ignores the safe area. The sheets called
`addSale` and popped without `ref.invalidate(dashboardProvider)`.

**Fix:** Added a `solid` flag to `GlassPanel`; when `true`, the
`noBlur` branch swaps the gradient for
`scheme.surface.withOpacity(isDark ? 0.92 : 0.95)` + a 1px
`scheme.outline.withOpacity(0.20)` border. Applied `solid: true` to
the dialog, both sheets, the product picker, and 3 panels in the
Sale Form. Wrapped all sheet builders in
`Column(mainAxisSize: MainAxisSize.min, children: [Padding(bottom: viewInsets.bottom, child: Sheet)])`
+ `useSafeArea: true` + 0.5 barrier. Extracted a shared
`ProductPickerSheet` and used it in both `discount_sheet` and the
Log Sale form (replacing the read-only product tile with a tap-able
tile). Added `ref.invalidate(saleListProvider/productListProvider/dashboardProvider)`
in both sheets. Bumped dialog barrier to 0.6. Removed 100px bottom
padding from the Log Sale form (it was for inner scroll lists, not
for full-screen routes).

**Verification:** `flutter analyze` 20 issues (1 fewer than 6.7 —
the previously-unused `product_provider.dart` import is now used by
the new `ref.invalidate` call). `flutter test` 100/100. Not yet
verified on a device.

## Phase 6.7 — Sales flow noBlur + dialog actionsBuilder(ctx) refactor

**Trigger:** 4 on-device complaints: duplicate `+` entry point on
the Sales list, Discount sheet renders only the title and ×
button, low-stock alert dialog buttons dismiss the underlying sheet
instead of the dialog, and QuickSellSheet's Confirm button is
missing.

**Diagnosis:** Three of the four are the same `glass_kit`
`SizedBox.expand` 0×0 collapse that has surfaced in 5 places
already (1.5, 6.2, 6.3, 6.5, 6.6). The fourth is a new pattern:
`Navigator.of(callerContext).pop(...)` from inside a
`GlassDialogAction` resolves to the wrong `Navigator` when the
caller is inside a modal bottom sheet (the closest `Navigator`
from a bottom sheet's `context` can resolve to a route above the
dialog).

**Fix:** Added `noBlur: true` to 3 `discount_sheet` `GlassPanel`s
(outer, product picker, nested sheet) and 2 bottom
`GlassPanel.flush`es (QuickSellSheet, DiscountSheet) with
`expand: false` so the Confirm button renders. Refactored
`showGlassDialog` signature from `actions: List<Widget>` to
`actionsBuilder: List<Widget> Function(BuildContext ctx)?`, so
action `onPressed` callbacks `Navigator.of(ctx).pop(...)` on the
dialog's own `BuildContext`. Updated 12 call sites. Removed the
redundant "Full sale form" `OutlinedButton` from the Sales list.

**Verification:** `flutter analyze` 20 issues (0 new). `flutter test`
100/100. Not yet verified on a device.

## Phase 6.5 — Body + dialog noBlur + remove silently-ignored keepAlive

**Trigger:** After Phase 6.4, user on-device report: "the bodies of
the 3 list screens and the dashboard and reports are blank after
adding a product. the product is visible in the sale form's
product picker though, so the data is there. the bottom-nav badge
shows 2+. the low-stock alert dialog is full-screen, the Save
anyway and Cancel buttons don't dismiss it."

**Diagnosis:** Same `glass_kit` `SizedBox.expand` 0×0 collapse as
6.2/6.3, on two new surface areas: body `GlassPanel`s (in
`SliverToBoxAdapter` / `ListView` parents, both unbounded) and
the dialog `GlassPanel` (in `Dialog` widget, also unbounded).
The dialog's `BackdropFilter` was also eating touch events on the
action row. Separately: the `@Riverpod(keepAlive: true)`
annotations introduced in 6.4b were being silently ignored by the
generator (e.g. `product_provider.g.dart:13` still emitted
`AutoDisposeStreamProvider.internal`).

**Fix:** Added `noBlur: true` to 18 body `GlassPanel`s across 6
screens (product list, sale list, expense list, dashboard, reports,
product detail) and 1 dialog `GlassPanel`. Removed the silently-
ignored `@Riverpod(keepAlive: true)` annotations from 5 provider
files; `appDatabaseProvider`'s keepAlive is preserved (the
connection must outlive any single screen). Auto-dispose is fine
in practice because `StatefulShellRoute.indexedStack` keeps all
branches mounted.

**Verification:** `flutter analyze` 0 issues (cleaner than pre-6.5
which had 21; the cleanup in 6.4 resolved the `quick_sell_sheet`
unused-import and the `export_service` `curly_braces_in_flow_control_structures`
warnings, and the gitignored `test/unit/*` warnings are no longer
analyzed in the `lib/` scope). `flutter test` 100/100. Not yet
verified on a device.

## Phase 6.4 — Cleanup + DB integration

**Trigger:** After Phase 6.3, user on-device report: "the app works
perfectly now. all the ui problems have been fixed. remove the
debugging boarders, container erc. restore the app. and integrate
the db effectively. in the debug session, the adding of products,
sales or the expense didnt register, other than that it worked
perfectly". The "didn't register" was a side effect of 6.1/6.2
(forms rendering blank → save button unreachable → no rows
inserted during testing), but the user asked for explicit DB
integration as a follow-up.

**Fix (cleanup):** Deleted 3 diagnostic files
(`debug_borders.dart`, `debug_app_bar.dart`, `debug_mode.dart`);
removed all `DebugBorders` / `DebugContainer` / `DebugAppBar` /
TEST TAP / `+ ADD` `FilledButton.icon` references from `app.dart`,
`app_bottom_nav.dart`, and all 9 screens; restored plain `AppBar`
on all 9 screens; removed `kDebug*Color` consts and the
`kDebugLayout` toggle.

**Fix (DB integration):** Converted `productListProvider`,
`filteredProductListProvider`, `ProductFilter`, `saleListProvider`,
`filteredSaleListProvider`, `expenseListProvider`,
`filteredExpenseListProvider`, `dashboardProvider` to
`@Riverpod(keepAlive: true)` (later reverted in 6.5 when the
annotation was found to be silently ignored). Added
`ref.invalidate(productListProvider / saleListProvider / expenseListProvider / dashboardProvider)`
calls in form save and delete paths.

**Fix (FAB → AppBar action):** The initial `FloatingActionButton`
on the 3 list screens was being hidden at runtime by the outer
`AppScaffold`'s `bottomNavigationBar` (nested-Scaffold FAB
limitation). Replaced with an `IconButton` in
`SliverAppBar.actions` for all 3 list screens.

**Verification:** `flutter analyze` 21 issues (all pre-existing;
0 new). `flutter test` 100/100. Not yet verified on a device.

## Phase 6.3 — GlassTextField permanent noBlur fix

**Trigger:** After Phase 6.2, user on-device report: "form now
renders, but in add product section there is only a toggle button,
no other way to input the product. In add expense section, it is
blank, no form to fill up and log the expense."

**Diagnosis:** Traced `glass_kit`'s `GlassContainer.build` —
it wraps `child` in `SizedBox.expand(child: current)`, then a
`Container(height: height, width: width, ...)`. With
`height: null, width: null` and an unbounded parent, the
`SizedBox.expand`'s `∞ × ∞` constraints intersect the parent's
loose `maxWidth` → invalid `minWidth > maxWidth` → 0×0 collapse.
Same `glass_kit` intrinsic-infinity bug worked around for the
bottom nav (`kBottomNavHeight = 76`) and the form panel
(`noBlur: true` in 6.2). The field-level `GlassTextField` re-
introduced the bug because its internal `GlassPanel` was still
using the frosted `LayoutBuilder` + `GlassContainer` chain.

**Fix:** Pass `noBlur: true` to the internal `GlassPanel` in
`glass_text_field.dart`. The field's panel now renders as a
plain `Container(gradient + border + TextFormField)`, no
`LayoutBuilder`, no `BackdropFilter`, no `SizedBox.expand`.
Restored `Column(crossAxisAlignment: stretch)` on all 3 form
panels (the 6.2 change to `start` was wrong — `stretch` is the
textbook Flutter form pattern).

**Verification:** `flutter analyze` 0 issues (cleaner than pre-6.3
which had 21 pre-existing). `flutter test` 100/100. Not yet
verified on a device.

## Phase 6.2 — Form-screen blank fix

**Trigger:** After Phase 6.1, user on-device report — diagnostic
borders PASS (STACK / BODY / TEST TAP / `+ ADD` visible); FAIL on
form: "in the add product section there is no option available" —
no magenta FIELD borders, no AppBar (or AppBar visible but body
empty), no save button.

**Hypotheses considered (in order of likelihood):**
- H1 — `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` +
  `GlassTextField` + `BackdropFilter` + `ListView` collapse
  (applied; later shown to be wrong in 6.3).
- H2 — `DebugBorders` `Stack` + `Positioned` loose-constraint
  propagation (applied; later shown to be unnecessary in 6.3).
- H3 — `BackdropFilter` inside form's big `GlassPanel` returning
  0×0 (proactively applied at the form-panel level; the deeper
  fix landed in 6.3 at the GlassTextField level).

**Fix:** Added `GlassPanel.noBlur` ctor flag (defaults to `false`;
when `true`, renders a plain `Container` with the same gradient +
border tokens, no `BackdropFilter` or `LayoutBuilder`). Applied
`noBlur: true` to the 3 form-level `GlassPanel`s. Added a
`DebugContainer` widget (no `Stack`/`Positioned`) for tight
intrinsic-size contexts. Added FORM (purple) and LIST (cyan)
borders.

**Verification:** `flutter analyze` 21 issues (0 new). `flutter test`
100/100. Not yet verified on a device.

## Phase 6.1 — Layout diagnostic placeholders

**Trigger:** User on-device report — "currently there are no
option to add products, or any other things to interact with. in
the add product section there is no option available." Goal was
diagnostic, not a fix: wrap each visible region in a colored
border + label so we could see exactly which layers were
rendering and at what size.

**Fix:** Added `DebugBorders` (orange/yellow/teal/magenta wraps),
`DebugAppBar` (PreferredSizeWidget wrapper for `Scaffold.appBar`),
`kDebugLayout = true` toggle, and `TEST TAP` `FilledButton`s on
every screen. Wrapped the outer `Stack` in `app.dart`, the
`Scaffold.body` and `bottomNavigationBar` in
`app_bottom_nav.dart`, every `GlassPanel` and `GlassTextField` in
the 9 screens, and the `+` `IconButton` on the 3 list screens
(rewritten as `+ ADD` `FilledButton.icon` for visibility).

**Removed in 6.4.** All 3 diagnostic files deleted; all
references removed; all 21 issues resolved.

## Phase 6 — Liquid Glass visual alignment

Sheet chrome (radius / margin / padding / drag handle) aligned to
[`DESIGN.md`](../DESIGN.md) on Quick Sell, Discount, Product
Filter, and Restock sheets. `SheetDragHandle` widget extracted
(40×4 px pill, `onSurfaceVariant` @ 30% opacity, 2 px radius,
centered, 14 px bottom margin) — replaces the 4 inlined copies.
`ChipThemeData` added to `app_theme.dart`; product-list filter
chips re-themed teal on select via a `_FilterChip` wrapper that
passes its own `side` (because `ChipThemeData` only exposes a
single `side` parameter; no `selectedSide` in Flutter 3.24.4).

## Phase 1.5 — bottom nav intrinsic-infinity

**Trigger:** Bottom nav was rendering full-screen, covering all
content; `flutter analyze` clean but the body was invisible on
device.

**Diagnosis:** `glass_kit`'s `GlassContainer.build` ends with
`SizedBox.expand(child: current)`, which makes
`maxIntrinsicHeight = double.infinity`. This propagated up through
`ClipRRect → GlassPanel → ClipRRect → Padding → SafeArea` into
`Scaffold.bottomNavigationBar`, which then allocated the entire
screen to the nav slot.

**Fix:** Inserted `SizedBox(height: kBottomNavHeight = 76)` between
the existing `Padding(12, 0, 12, 8)` and the existing
`ClipRRect(22)`. Cap = 76 px = `NavigationBarTheme.height`. The
8 px bottom padding and the outer `SafeArea(bottom: true)` are
unchanged, so total visible bottom area is still 76 (bar) + 8
(padding) + safe-area inset.

**Verification:** `flutter analyze` 0 errors. Not yet verified on
a device.

## Phase 1.5 — body-blank regression from Material(transparency)

**Trigger:** After applying the 1.5 bottom-nav fix, the AppBar and
bottom nav were visible, but the body of every screen looked
blank (just aurora).

**Diagnosis:** The `745fb5f` commit had wrapped the outer `Stack`
in `Material(type: MaterialType.transparency)` to "fix a latent
Stack sizing issue". `Material` with a child has
`alwaysNeedsCompositing: true`, so it created a new compositing
layer containing the entire Stack. Inside that layer,
`glass_kit`'s `GlassContainer` (used by the aurora) uses
`ImageFilter.blur` via `BackdropFilter`. With the `BackdropFilter`
in the same compositing layer as the inner Scaffolds' bodies, the
bodies were being composited under the aurora's blurred waves
on-device. The `AppBar` and `bottomNavigationBar` were unaffected
because `RenderScaffold` lays them out via a different render path
(appBar slot / bottomNavigationBar slot, both painted before the
body in the Scaffold's paint pass).

**Fix:** Removed the `Material(type: MaterialType.transparency)`
wrapper from `app.dart`. The `Stack(fit: StackFit.expand, ...)`
alone is sufficient to size the Stack to the parent's full size.

**Verification:** `flutter analyze` 0 errors. Not yet verified on
a device.

---

## Regression table — glass_kit SizedBox.expand history

| Phase | Surface | Workaround |
|---|---|---|
| 1.5 | Bottom nav | `SizedBox(height: kBottomNavHeight = 76)` cap inside `app_bottom_nav.dart` |
| 6.2 | Form-level `GlassPanel` | `GlassPanel(noBlur: true)` — 3 form screens |
| 6.3 | `GlassTextField` internal `GlassPanel` | `GlassPanel(noBlur: true)` inside `glass_text_field.dart` |
| 6.4c | `FloatingActionButton` hidden by outer `bottomNavigationBar` | `IconButton` in `SliverAppBar.actions` (not glass-related) |
| 6.5 | Body `GlassPanel`s (×18) + dialog `GlassPanel` (×1) | `GlassPanel(noBlur: true)` — 6 screens + `glass_dialog.dart` |
| 6.6 | `_ProductSellCard` `GlassPanel` inside `SliverList` (×1) | `GlassPanel(noBlur: true)` — `sale_list_screen.dart:211` |
| 6.7 | 3 `GlassPanel`s in `DiscountSheet` + 2 flush panels | `GlassPanel(noBlur: true)` + `expand: false` |
| 6.8 | Dialog + both sheets + product picker (translucent) | `GlassPanel(solid: true)` — `scheme.surface` 0.92/0.95 |
| 6.8 | Sheets positioned at top of screen (huge gap + behind nav) | `Column(mainAxisSize: min)` + `useSafeArea: true` |
| 6.9 | All 5 `showModalBottomSheet` callers | `max(viewInsets.bottom, kBottomNavHeight + 8)` + barrier 0.5 |

## Regression table — silent `keepAlive` history

| Phase | Surface | Fix |
|---|---|---|
| 6.4b | 5 list / filter / dashboard providers | `@Riverpod(keepAlive: true)` (silently ignored by generator) |
| 6.5 | Same 5 providers | Removed annotation; auto-dispose is fine because `StatefulShellRoute.indexedStack` keeps all branches mounted |

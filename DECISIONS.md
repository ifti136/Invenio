# Architectural & Design Decisions

This file logs important decisions made during development. Each entry has a date, context, decision, and rationale.

> **Note (2026-11-06):** Entries before this date describe the retired Liquid
> Glass app (v1.x–v2.1.2). The Clean Ledger overhaul below supersedes them,
> including the blur, aurora, multi-theme, and `glass_kit` decisions.

---

## 2026-06-16 — Screen/Popup Bug Fixes

**Context:** User reported widespread functional and UI bugs across wallet, finance, dashboard, product, restock, bucket, add-on picker, and settings screens.

**Decisions:**

1. **Dashboard reactivity kept as `FutureProvider` with invalidation**  
   Rather than converting `dashboardProvider` to a `StreamProvider` (which would be architecturally cleaner but require more invasive restructuring), we added `ref.invalidate(dashboardProvider)` to all 13 mutation sites (sales, expenses, products, wallets, buckets). This fixed the dashboard refresh issue with minimal risk.

2. **Wallet Nullable walletId fixed in `getWalletWithBalances()`**  
   The custom SQL query used `row.read<int>('walletId')` which crashes on NULL values from legacy sales/expenses. Fixed by matching the null-safe logic already present in the stream-based `watchWalletsWithBalances()`.

3. **Finance settings route corrected (not added)**  
   The route `/settings/finance/settings` already existed; the navigation bug was in `FinanceScreen` pushing `/settings/finance/rules` (wrong path). Fixed by correcting the push target.

4. **Restock price input collected but not persisted**  
   Adding a Drift schema migration to store restock price per movement was deemed too invasive for a bug-fix session. The price field is presented to the user with a "Price is for reference only" note. Schema migration deferred to a future feature session if needed.

5. **Currency service with SharedPreferences**  
   Implemented a minimal `CurrencyService` using the existing `shared_preferences` dependency. No new top-level dependencies. The service stores a currency symbol that `formatMoney` reads via a cached static.

6. **Add-on Picker redesigned as tickable list**  
   The original picker had a split layout (selected + available sections) with disabled visual buttons. Redesigned to a single list where each add-on type appears once with a check-circle toggle indicator and an inline amount field.

7. **Button visual state pattern**  
   The systemic `onPressed: null` pattern (where `HapticWrapper` handled taps but buttons appeared disabled) was fixed by moving `onPressed` callbacks directly onto the buttons and placing `HapticService.trigger()` inside the button's `onPressed`. Dead `HapticWrapper(onTap: null)` wrappers were left in place rather than removed to minimize diff churn.

---

## 2026-06-17 — v1.3.2 (UI Fixes & Wallet Picker)

**Context:** User reported Products screen had a settings button inconsistent with other screens; Quick Sell and Discount sheets lacked wallet picker; Finance, Allocation Settings, and Theme screens were blank; screen titles inconsistently aligned.

**Decisions:**

1. **Settings button removed from Products only**  
   Dashboard keeps its settings gear as the sole entry point to the settings hub. Products, Sales, and Expenses screens all now lack the gear icon (were already absent from Sales/Expenses).

2. **Wallet picker pattern reused for Quick Sell and Discount sheets**  
   The existing wallet picker pattern from `sale_form_screen.dart` (tappable row → `showWalletPicker()` bottom sheet → auto-select last-used wallet) was copied to both sheets. The sheets pass `walletId` and `ownership: 'business'` to `saleRepository.addSale()`.

3. **`noBlur: true` confirmed as the fix for GlassPanel blankness**  
   The Finance screen's `GlassPanel` (wrapping rule cards in `ListView.builder`) was missing `noBlur: true`, triggering `glass_kit`'s `SizedBox.expand` 0×0 bug. Adding `noBlur: true` resolves it.

4. **Allocation Settings layout fix revisited**  
   The previous session (v1.3.1) changed `Expanded` → `Flexible` but left `Column(mainAxisSize: MainAxisSize.min)` in place. This made the ListView invisible because the Column took zero remaining height. The correct fix: remove `mainAxisSize: MainAxisSize.min` and use `Expanded`.

5. **Nested AuroraBackdrop causes BackdropFilter to fail**  
   The app shell (`app.dart`) wraps everything in an `AuroraBackdrop` (uses `BackdropFilter`). Theme cards had a second `AuroraBackdrop` inside them. Flutter's `BackdropFilter` does not support nesting — the inner one silently produces no visible output. Fixed by replacing the `AuroraBackdrop` in `ThemeCard` with a simple colored `Container`/gradient preview.

6. **Screen titles centralized**  
   All main list screen titles now use `centerTitle: true` for consistent appearance. The theme default (`centerTitle: false`) is overridden per screen.

---

## 2026-06-20 — Glassmorphism Restoration & 4-Theme System

**Context:** The app's glassmorphism (blur) effect was disabled because content became invisible. The theme system also needed to be overhauled to support 4 distinct themes with different design vibes.

**Decisions:**

1. **Custom `Stack`+`BackdropFilter` replaces `glass_kit`'s `GlassContainer`**  
   The `GlassContainer` from `glass_kit` wrapped the blur layer around the child in a way that could visually "erase" content on some GPU compositions. By manually building the glass panel as a `Stack` with layers (BackdropFilter → gradient fill → frosted overlay → border → child), the content is always guaranteed to render on top of the blur. The `glass_kit` dependency remains in `pubspec.yaml` but is no longer used for blur.

2. **`GlassPanel.solid` renamed to `opaque`**  
   The old `solid` parameter caused confusion — it controlled whether the panel was opaque (no blur), but it sounded like it controlled the "solid" (no-aurora) theme type. Renamed to `opaque` to match its actual behavior. The "no aurora" concept is now exclusively controlled by `AuroraConfig.enabled`.

3. **4 new themes replace the original 4-theme set**  
   The original `darkAurora`, `lightAurora`, `midnightBlue`, and `solidSlate` are replaced by:
   - `lightSolid` (Forest Green / Navy Blue)
   - `darkSolid` (Dark inversion)
   - `minimalistPaper` (Monochrome, clean)
   - `deepOcean` (Navy + cyan accents)
   
   `darkAurora`, `lightAurora`, and `midnightBlue` are preserved as active themes. `solidSlate` is `@Deprecated` and maps to `darkSolid` in the migration path in `ThemeProvider`.

4. **Static gradient backgrounds for solid themes**  
   `AuroraBackdrop` was enhanced to render a `LinearGradient` (instead of a flat color) when `enabled == false` and `backgrounds.length > 1`. This gives solid themes visual depth without animation.

5. **`isFrostedGlass` functionality restored**  
   The frosted opacity layer (extra 8–10% white overlay for nav bar and dialogs) was missing in the initial custom Stack implementation. It was restored as a conditional layer between the gradient fill and the border.

---

## 2026-11-03 — Always-MaterialApp Root (v2.1.2 blank-screen fix)

**Context:** v2.1.1+18 shipped a blank gray screen on launch. Root cause: `app.dart`
returned a bare `WalkthroughScreen` `Scaffold` (no `MaterialApp`/`WidgetsApp`
ancestor) whenever `walkthrough.completed == false`, which is always true on the
first frame because prefs load asynchronously. The first build threw (missing
MediaQuery / Directionality / Navigator / Theme), and release builds rendered
Flutter's textless light-gray `ErrorWidget`.

**Decisions:**

1. **`TrackerApp` always returns a MaterialApp-family root.**
   Three branches: `!initialized` → `_BootstrapLoading` scaffold;
   `initialized && !completed` → `WalkthroughScreen`; `completed` →
   `MaterialApp.router`. Theme, `debugShowCheckedModeBanner`, SystemChrome and
   `AuroraBackdrop` are shared via a `_buildApp`/`_appShell` helper so no branch
   can ever render outside a widget-app root.

2. **`WalkthroughState.initialized` gate, failing open.**
   The provider sets `initialized: true` on prefs load success *and* failure
   (failure also sets `completed: true`). Returning users therefore never see
   the walkthrough, and an unreadable prefs file can no longer trap the user on
   an un-dismissable screen.

3. **Distinct `ValueKey`s per branch** (`bootstrap-loading` / `walkthrough` /
   `router`) so Flutter tears down the whole subtree on branch change instead of
   reusing an incompatible navigator.

**Consequence:** any future pre-router screen (splash, onboarding, migration)
must live *inside* a MaterialApp-family root, never above one.



---

## 2026-11-06 — Phase-based sub-sub-versioning (v3.6.3+23)

**Context:** The Clean Ledger overhaul was built as Phases 0–6, but the
package version stayed at `2.3.0+20`, so the release history did not map to the
phase structure.

**Decision:** Adopt **`v3.<phase>.<change>`** for all releases.

- `v3.0.0` is the Clean Ledger baseline.
- Phase 0 changes are `v3.0.1`, `v3.0.2`, …; Phase 1 starts at `v3.1.1`,
  Phase 2 at `v3.2.1`, and so on through Phase 6 at `v3.6.1`.
- Apply the scheme retroactively in `docs/CHANGELOG.md`; do not rewrite git
  history or force-push.
- The current package version is `3.6.3+23`.

**Rationale:** The version number now tells the reader which overhaul phase a
change belongs to, and the changelog and pubspec stay in lockstep.

---

## 2026-11-06 — Clean Ledger overhaul (v3.0.0 baseline)

**Context:** The Liquid Glass / aurora UI, multi-theme system, and Excel export
were replaced by the Clean Ledger spec (`docs/invenio overhaul.pdf` v2.3). The
app was treated as a greenfield rebuild on top of the existing Flutter project.

**Decisions:**

1. **Fresh schema, no legacy migration.**
   The overhaul creates a fresh schema v7 database (now `invenio.sqlite`) with
   no import path from the old app. Rationale: the old data model and
   UI were being replaced wholesale, and a one-user offline tool can start
   clean. The version later advanced to v8 for the adjustments table.

2. **One Material 3 theme, no theme picker.**
   `AppTheme` is built from `ColorScheme.fromSeed(0xFF1D9E75)` with light,
   dark, and system modes. The four Liquid Glass themes and migration logic
   were removed. Rationale: fewer states, predictable contrast, and one visual
   language.

3. **Flat surfaces only.**
   Cards and sheets use tonal surface colours with a 1 px outline. No blur,
   gradients, shadows, or animated backgrounds. Rationale: performance,
   readability, and the Clean Ledger spec.

4. **Money is integer minor units.**
   `Money` owns parsing, arithmetic, and formatting; every money column is an
   `int`. `MoneyText` renders with tabular figures and the reactive currency
   symbol. Rationale: avoid floating-point drift in financial data.

5. **Derived balances, no stored balance column.**
   Balances are computed from opening balance, payments, expenses, paid
   restocks, transfers, and adjustments. Rationale: one source of truth and
   no reconciliation drift.

6. **Sale line costs are snapshotted.**
   `unit_cost_minor` is stored on each sale line. Editing a product's cost
   later never changes historical profit. Rationale: accurate P&L and a
   simpler edit flow.

7. **`adjustments` table added in schema v8.**
   Spec §5 had no adjustments table. A signed adjustment row with a note
   records manual balance corrections and remains visible in the ledger.
   Rationale: users need a way to reconcile cash without fake sales/expenses.

8. **Five-tab information architecture.**
   Home, Sales, Inventory, Money, Reports; Settings is reached from the Home
   app bar. Rationale: one loop (sale → stock → money → profit) and fewer
   navigation dead ends than the old six-slot POS shell.

9. **CSV replaces Excel; SQLite file export uses `share_plus`.**
   `syncfusion_flutter_xlsio` was removed. CSV is dependency-free and
   inspectable; database export plus daily local backups cover safety.
   Rationale: fewer heavy dependencies and no licensing surface.

10. **Restore is deferred.**
    Export and daily backups ship now, but restoring a database needs a
    file-picker dependency that was not approved. Rationale: do not add an
    unapproved top-level dependency; document the gap honestly.

11. **Accessibility is verified with widget tests.**
    Key screens are pumped at 200% text scale on a 360 dp viewport; contrast
    tokens are checked at 4.5:1 text and 3:1 outline. Overflow fixes use
    `Wrap`, `FittedBox`, and horizontally scrollable segmented controls rather
    than shrinking fonts globally. Rationale: keep type readable while
    preventing clipped content.

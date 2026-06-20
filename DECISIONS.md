# Architectural & Design Decisions

This file logs important decisions made during development. Each entry has a date, context, decision, and rationale.

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

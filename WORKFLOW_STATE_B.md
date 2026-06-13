# Workflow State — Agent B (Features & UI)

## Request
Implement the plan in `.planning/IMPLEMENTATION_PLAN.md` as Agent B (Features & UI).

## Vision Notes
- Transition the app to the `full_DESIGN.md` specification.
- Focus on the "Liquid Glass" aesthetic: frosted panels over an animated aurora.
- **Solid Slate Theme:** Aurora backdrop is completely hidden and replaced with a static solid color; surfaces become opaque.
- **Motion:** Stick to the specified 250ms fades and standard sheet transitions; no additional complex motion.
- **Coordination:** Agent A is working separately on the foundation/data layer.

## Constraints
- Parallel execution with Agent A.
- Strict ownership of `app_theme.dart` and `aurora_backdrop.dart`.
- Must pass `flutter analyze` and `flutter test` for every commit.
- "Glass first" policy: use `GlassPanel` and `GlassTextField` for all new surfaces.

## Open Questions
- None.

## Clarified Scope
- **Theme Persistence:** Use `shared_preferences` directly for storing the selected theme ID.
- **Theme Previews:** Theme cards in the picker will feature mini animated aurora strips.
- **Haptics:** Implement a new standardized haptic utility/service to handle Light, Medium, and Heavy impacts.
- **UI Components:** Implement the Dashboard redesign, Add-Ons UI, and "Per Sale" reports.

## Acceptance Criteria
- **Theme System:** 4 themes implemented; live switching works; "Solid Slate" disables aurora/transparency; persistence via `shared_preferences`.
- **Add-Ons UI:** Functional picker sheet; integration into Sale Form, Quick Sell, and Discount sheets; live total/profit updates.
- **Dashboard:** Matches §3 of `full_DESIGN.md` (Today 2x2 grid, Platform donut chart, Stock alerts).
- **Reports:** "Per Sale" tab implemented showing chronological net profit.
- **Aesthetics:** All new UI follows the Liquid Glass spec; haptics integrated across all primary interactions.
- **Quality:** `flutter analyze` passes; no regressions in existing features.

## Plan
1. **Phase 3: Theme System**
   - ✅ Create `HapticService` for standardized feedback (Light/Medium/Heavy).
   - ✅ Create `HapticWrapper` widgets to easily wrap interactive elements.
   - ✅ Implement `AuroraConfig` and update `AuroraBackdrop` to be provider-driven.
   - ✅ Implement `AppTheme.fromId` factory to return `ThemeData` and `AuroraConfig`.
   - ✅ Implement theme persistence using `shared_preferences` in a `ThemeProvider`.
   - ✅ Build `ThemeCard` with mini animated aurora strips.
   - ✅ Build `ThemeScreen` at `/settings/theme` with a 2-column `Wrap` of `ThemeCard`s.
   - ✅ Implement "Solid Slate" logic: hide `AuroraBackdrop` and set `GlassPanel` to opaque.
   - ✅ Commit **C3**.

2. **Phase 6: Add-Ons UI**
   - ✅ **Dependency:** Requires Agent A's `AddOnRepository` (C2). Verified.
   - ✅ Implement `AddOnPickerSheet` (top: added items with editable amounts, bottom: available types).
   - ✅ Implement/Update `DiscountSheet` to include the Add-Ons system.
   - ✅ Add `+ Add-Ons` button to `SaleFormScreen`, `QuickSellSheet`, and `DiscountSheet`.
   - ✅ Implement local state management for add-ons in forms (`_AddOnEntry`).
   - ✅ Update live preview panels to subtract add-on costs from profit (using Agent A's logic).
   - ✅ Commit **C6**.

3. **Phase 8: Dashboard Redesign**
   - ✅ **Dependency:** Requires Agent A's Profit Recalculation (C7).
   - ✅ Refactor `DashboardScreen` to a single `ListView` with `kBottomNavClearance`.
   - ✅ Implement `TodayCard`: 2x2 grid, `MetricCell`s, and `fl_chart` sparkline.
   - ✅ Implement `PlatformPerformanceCard`: `fl_chart` donut chart and `PlatformRow`s with progress bars.
   - ✅ Implement `WalletBalancesCard` and `BudgetBucketsCard` with specified empty states.
   - ✅ Implement `StockAlertsCard` with avatar squares and `SELL` buttons.
   - ✅ Commit **C8**.

4. **Phase 11: UI Polish & Haptics**
   - ✅ Integrate `HapticWrapper` and `HapticService` into all buttons, toggles, and list items.
   - ✅ Perform a "Glass Audit" to ensure all surfaces use `GlassPanel` correctly.
   - ✅ Implement empty states for all major lists.
   - ✅ Commit **C11**.

5. **Phase 12: Finalization**
   - ✅ Implement `flutter analyze` and fix any issues.
   - ✅ Update `CHANGELOG.md`, `HISTORY.md`, and `project_state.md`.
   - ✅ Commit **C12**.

## Current Status
All phases for Agent B are completed and committed. The app has been transitioned to the `full_DESIGN.md` specification.

## Next Agent
None (Agent B's assignment complete)

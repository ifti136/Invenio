# Workflow State

## Request
Integrate BFMS concepts into Invenio as specified in `docs/instructions/BFMS_INTEGRATION (1).md`.

## Vision Notes
- Integrate high-value BFMS concepts (Wallets, Ownership, Profit Allocation, Budget Buckets) without bloating the app.
- Maintain solo-owner, offline-first nature.
- Adhere to "Liquid Glass" design system.
- **Wallets are mandatory** for all transactions.
- **Dashboard:** Strictly Business-only.
- **Finance System:** Implemented as a new 6th navigation tab with cumulative fund tracking.
- **Rollout:** Plan all phases in `project_state.md`, then implement phase-by-phase.

## Constraints
- Wallets nest inside the Products tab settings.
- No new top-level dependencies.
- Must follow `AGENTS.md` conventions (GlassTextField, showGlassDialog, etc.).
- **Exception:** A new 6th tab (Finance) is approved per the updated spec.

## Open Questions
None.

## Clarified Scope
- **Phase 1 (Implemented):** Schema v3, Wallets, Ownership, Finance Tab.
- **Phase 2 (Implemented):** 
    - **Database:** Migrate to Schema v4. Create `BudgetBuckets` table (Global). Add `bucketId` (nullable) to `Expenses`.
    - **Logic:** Hybrid Budgeting. Buckets are global (limit is shared), but each expense linked to a bucket tracks the wallet used. Balance = `allocatedAmount` - linked expenses.
    - **UI:** Bucket CRUD in Products $\rightarrow$ Product Settings. Optional bucket picker in Expense form.
    - **Alerts:** Bucket overdraws trigger a blocking `showGlassDialog` (Cancel/Proceed).
    - **Dashboard:** "Buckets" card showing a simple list of balances with color chips.
    - **History:** Bucket history view showing amount and wallet used for each expense.

## Acceptance Criteria
- **Phase 1:** All criteria met. ✅
- **Phase 2:** 
    1. Schema v4 applied and `build_runner` successful. ✅
    2. Budget Bucket CRUD functional (Global). ✅
    3. Expense form allows optional bucket selection. ✅
    4. Bucket overdraws trigger a mandatory confirmation dialog. ✅
    5. Dashboard correctly displays the list of bucket balances with color chips. ✅
    6. Bucket history correctly shows the wallet used for each expense. ✅
    7. All UI follows "Liquid Glass" design system. ✅
    8. **Code compiles without errors.** ✅

## Plan
- **Phase 1:** Completed.
- **Phase 2:** Implemented, but currently broken.
- **Stabilization Phase (Current):**
    1. **Fix Core Infrastructure:** Resolve all broken imports and `AppColors` undefined getters.
    2. **Fix Repositories:** Correct Drift query syntax in `WalletRepository`, `AllocationRulesRepository`, and `ExpenseRepository`.
    3. **Fix UI Screens:** 
       - Rewrite `DashboardScreen` to fix severe syntax errors.
       - Fix `ExpenseFormScreen` (providers, type mismatches, alert calls).
       - Fix `AllocationSettingsScreen` (type definitions, nullability).
       - Fix `WalletPickerSheet` (type casting).
    4. **Verification:** Run `flutter analyze` and `build_runner` until 0 errors.

## Files To Change
- `lib/core/theme/app_colors.dart`
- `lib/db/app_database.dart`
- `lib/features/dashboard/dashboard_screen.dart`
- `lib/features/expenses/expense_form_screen.dart`
- `lib/features/expenses/expense_repository.dart`
- `lib/features/finance/allocation_rules_repository.dart`
- `lib/features/finance/allocation_settings_screen.dart`
- `lib/features/products/wallet_repository.dart`
- `lib/features/products/widgets/wallet_picker_sheet.dart`
- All new BFMS widgets (fixing imports).

## Current Status
Phase 2: Implemented and verified. Codebase is stable and compiles without errors.

## Next Agent
planner

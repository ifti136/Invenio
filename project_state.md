# Project State — Invenio

## Current Version
v1.0.0+2 (Schema v2)

## BFMS Integration Roadmap

### Phase 1: Financial Foundation (Schema v3)
**Goal:** Implement mandatory money tracking, ownership separation, and the cumulative Profit Allocation system.

1. **Schema Migration (v3):**
   - Create `Wallets` table.
   - Add `walletId` (mandatory) to `Sales` and `Expenses`.
   - Add `ownership` ('business'/'personal') to `Sales` and `Expenses`.
   - Create `AllocationRules` table.
   - Add `allocationRuleId` (nullable) to `Expenses`.
2. **Wallet Management:**
   - `WalletRepository` + Provider.
   - Wallet List & Form screens (nested in Products $\rightarrow$ Settings).
   - Mandatory Wallet Picker in Sale and Expense forms.
   - Dashboard "Wallet Balances" card.
3. **Ownership Tagging:**
   - Ownership toggle in Sale and Expense forms.
   - Dashboard filtering logic (Strictly Business-only).
4. **Profit Allocation System:**
   - `AllocationRulesRepository` + Provider.
   - **New 6th Tab: Finance** (`/finance`) showing available balances per rule.
   - `AllocationHistoryScreen` showing monthly credit/debit breakdown.
   - `AllocationSettingsScreen` for CRUD of rules (sum $\le$ 100%).
   - Expense form: "Allocate to fund" picker for business expenses.
   - `AlertService`: `AllocationOverdrawAlert` (amber warning).

### Phase 2: Budgetary Control (Schema v4)
**Goal:** Implement logical spending limits and alerts.

1. **Schema Migration (v4):**
   - Create `BudgetBuckets` table.
   - Add `bucketId` (optional) to `Expenses`.
2. **Budget Buckets:**
   - `BucketRepository` + CRUD.
   - Bucket picker in Expense form.
   - Dashboard "Buckets" status card.
3. **Smart Alerts:**
   - Extend `AlertService` with `BucketOverdrawAlert`.
   - Pre-save warning in Expense form when a bucket is overdrawn.

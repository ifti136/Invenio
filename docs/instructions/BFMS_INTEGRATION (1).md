# BFMS Integration Plan — Invenio

> **Purpose:** Integrate relevant BFMS concepts into Invenio without breaking existing UX, violating `AGENTS.md` conventions, or bloating a single-owner offline app.
>
> **Guiding principle:** Invenio user is a solo reseller on a phone. BFMS is a SaaS spec. Take the concepts that fit a one-person operation; drop everything that assumes multi-user, cloud, or accounting-grade complexity.

---

## What Already Exists (No Work Needed)

| BFMS Module | Invenio Equivalent |
|---|---|
| Module 4: Profit Calculation Engine | `ReportRepository.dailySnapshots/monthlySummaries` — revenue minus expenses, daily/monthly/yearly |
| Module 6 (partial): Expense categories | `ExpenseCategory` enum (Ads, Delivery, Packaging, Misc) |
| Dashboard profitability metrics | `DashboardSummary` — gross/net profit, platform breakdown |
| Reporting module | `ReportsScreen` — Daily/Monthly/Product tabs, Excel export |
| Transaction audit trail | `StockMovements` table — full ledger per product |

---

## Phase 1 Integration — High Value, Low Disruption

These map directly to existing architecture with schema additions only.

### 1.1 Wallet Management (Module 1)

**What:** Track where money lives — Cash, bKash, Nagad, Bank, Custom.

**Why it fits:** Invenio user sells on Facebook and offline, collects via bKash/cash. Currently no way to track which wallet received payment.

**Schema change — schema v3:**
```dart
// New table
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();              // 'bKash', 'Cash', etc.
  TextColumn get type => text()();              // 'cash'|'bank'|'bkash'|'nagad'|'rocket'|'custom'
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
}

// Add to Sales table (schema v3)
IntColumn get walletId => integer().nullable().references(Wallets, #id)();

// Add to Expenses table (schema v3)
IntColumn get walletId => integer().nullable().references(Wallets, #id)();
```

**UI changes:**
- New **Wallets** section under Settings (accessible from Products tab, since `AGENTS.md` says "Settings lives inside Products tab")
- `WalletFormScreen` — add/edit wallet, set opening balance
- `WalletListScreen` — list wallets with current balance (computed from opening balance + transactions)
- Sale form + Expense form: optional wallet picker (defaults to last used)
- Dashboard: "Wallet Balances" card showing each wallet's current balance

**No new tab.** Wallets live in Products tab → Settings section.

---

### 1.2 Ownership Tagging (Module 2)

**What:** Mark every transaction Business or Personal.

**Why it fits:** Solo resellers frequently mix personal spending with business. Knowing true business profit requires separating these.

**Schema change (schema v3):**
```dart
// Add to Sales table
TextColumn get ownership => text().withDefault(const Constant('business'))();

// Add to Expenses table
TextColumn get ownership => text().withDefault(const Constant('business'))();
```

**UI changes:**
- Expense form: ownership toggle (Business / Personal) — same `_ToggleGroup` pattern as platform/payment
- Sale form: ownership toggle, default Business
- Reports: filter by ownership; Dashboard stats count only `ownership == 'business'` by default
- Dashboard: new "Personal vs Business" split card (hidden when zero personal transactions)

**Migration:** `onUpgrade` adds columns with `'business'` default — zero data loss, zero UX disruption.

---

### 1.3 Profit Allocation System (Module 5)

**What:** A cumulative fund-tracking system. The user defines allocation rules (e.g., Marketing = 20% of profit). Every month, the system computes that month's business profit and credits 20% to a running Marketing balance. Unspent allocation carries forward indefinitely. When the user spends against that category, the expense is linked to the allocation and the available balance decreases.

**Example:**
- January profit = ৳1,000 → Marketing gets ৳200 credited
- February profit = ৳1,000 → Marketing gets another ৳200 credited
- Running Marketing balance = ৳400
- User logs a ৳400 Ads expense tagged to Marketing allocation
- Marketing available balance = ৳0

This is not a real bank account — it is a virtual running tally computed from profit history and spending history. No money moves.

**Schema change (schema v3):**
```dart
// Allocation rules — configured once in settings
class AllocationRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();        // 'Marketing', 'Inventory', 'Savings', etc.
  RealColumn get percentage => real()();   // 0.0–100.0; all active rules must sum to ≤ 100
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
}

// Link an expense to an allocation category
// Add to Expenses table (schema v3)
IntColumn get allocationRuleId => integer().nullable().references(AllocationRules, #id)();
```

**How the balance is computed (no stored balance — always derived):**

```
AllocationBalance(ruleId) =
    SUM over all months of (monthlyBusinessProfit × rule.percentage / 100)
  − SUM of all expenses WHERE allocationRuleId = ruleId AND ownership = 'business'
```

`monthlyBusinessProfit` = `ReportRepository.monthlySummaries` filtered to `ownership == 'business'`, already implemented. Allocation balance is a pure query — no new writes when profit changes, always fresh.

**Two new screens:**

#### Finance Screen (dedicated top-level route `/finance`)

> **Note:** This is a 6th navigation tab. Add to `AppScaffold._tabs` (after Reports) and to `StatefulShellRoute` branches. Tab icon: `Icons.account_balance_wallet_outlined`.

Displays one card per active allocation rule:
- Rule label + percentage badge (e.g., "Marketing · 20%")
- Total accumulated (all-time allocated profit for this rule)
- Total spent (sum of expenses linked to this rule)
- **Available balance** (accumulated − spent) — teal if positive, red if overdrawn
- "History" chevron → `AllocationHistoryScreen` (monthly breakdown table)

`AllocationHistoryScreen` (pushed from Finance screen):
- Month selector (same chevron pattern as Reports)
- Per-month row: profit that month, amount allocated that month, expenses charged that month, running balance after that month
- Read-only, no editing

#### Allocation Settings Screen (`/finance/settings`)

Accessible via settings icon in Finance screen `AppBar`.

- List of allocation rules (label, percentage, active toggle)
- "+" to add a rule → `AllocationRuleFormScreen`
- Validation: sum of active rule percentages must be ≤ 100%; warn if < 100% (remainder is unallocated)
- Delete with `showGlassDialog` confirm — soft-delete (`isActive = false`), preserving history

**Expense form change:**

When expense `ownership == 'business'`, show optional "Allocate to fund" picker. Tapping opens a bottom sheet listing active allocation rules with their current available balance. User picks one (or none). Selected rule id saved as `allocationRuleId`.

If selected rule's available balance < expense amount: show amber warning ("This will overdraw your Marketing fund by ৳X") — non-blocking, user can still save (same pattern as below-cost alert).

---

## Phase 2 Integration — Medium Complexity

### 2.1 Virtual Budget Buckets (Module 6)

**What:** Global budget limits for spending categories. A bucket tracks a total allocated amount across all wallets.

**Schema:**
```dart
class BudgetBuckets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get allocatedAmount => real().withDefault(const Constant(0))();
  TextColumn get color => text().nullable()();    // hex color for UI chip
  IntColumn get createdAt => integer()();
}

// Add to Expenses table (schema v4)
IntColumn get bucketId => integer().nullable().references(BudgetBuckets, #id)();
```

**UI:** New "Buckets" card on Dashboard showing a simple list of balances. Expense form: optional bucket picker. Bucket balance = allocatedAmount − spent. Bucket history view shows amount and wallet used for each expense.

---

### 2.2 Smart Spending Alerts (Module 10)

**What:** Notify when an expense would overdraw its bucket.

**How:** Extend `AlertService` with `BucketOverdrawAlert`. Alert shown as a blocking `showGlassDialog` with "Cancel" and "Proceed" options before expense is saved.

---

## What to Skip

| BFMS Feature | Reason |
|---|---|
| Audit log (user/time/prev/new value) | Single user, offline — no accountability requirement. `StockMovements` already covers stock audit. |
| Double-entry bookkeeping, GL, Trial Balance | Phase 2 roadmap item in BFMS itself; overkill for a reseller app. |
| Multi-user roles | Invenio is explicitly single-user, no auth. |
| bKash/Nagad/Bank API integrations | Network-dependent; Invenio is offline-first by design. |
| AI forecasting | Requires cloud, out of v1 scope. |
| Annual income statement / balance sheet | Beyond Invenio scope (product-level P&L, not accounting). |
| Supplier management | Partially covered by restock + stock movements. |

---

## Schema Migration Summary

| Version | Phase | Changes |
|---|---|---|
| 1 | Phase 1 | Initial 4 tables |
| 2 | Phase 1.5/2 | `alertEnabled`, `isDiscounted`, `normalPrice` |
| **3** | **BFMS Phase 1** | `Wallets` table; `walletId` on Sales + Expenses; `ownership` on Sales + Expenses; `AllocationRules` table; `allocationRuleId` on Expenses |
| **4** | **BFMS Phase 2** | `BudgetBuckets` table (Global); `bucketId` on Expenses |

`onUpgrade` branch in `AppDatabase`:
```dart
if (from < 3) {
  await m.createTable(wallets);
  await m.addColumn(sales, sales.walletId);
  await m.addColumn(sales, sales.ownership);
  await m.addColumn(expenses, expenses.walletId);
  await m.addColumn(expenses, expenses.ownership);
  await m.addColumn(expenses, expenses.allocationRuleId);
  await m.createTable(allocationRules);
}
if (from < 4) {
  await m.createTable(budgetBuckets);
  await m.addColumn(expenses, expenses.bucketId);
}
```

---

## Implementation Order

```
Step 1 — Schema v3 migration
  ☐ Add Wallets table
  ☐ Add walletId (nullable) to Sales + Expenses
  ☐ Add ownership (default 'business') to Sales + Expenses
  ☐ Add AllocationRules table
  ☐ Bump schemaVersion → 3, add onUpgrade branch
  ☐ dart run build_runner build

Step 2 — Wallet CRUD
  ☐ WalletRepository + @Riverpod(keepAlive: true) provider
  ☐ WalletListScreen (inside Products tab settings)
  ☐ WalletFormScreen (GlassTextField, GlassPanel(noBlur), showGlassDialog for delete)
  ☐ walletListProvider stream

Step 3 — Ownership tagging
  ☐ Expense form: ownership _ToggleGroup (Business / Personal, default Business)
  ☐ Sale form: ownership _ToggleGroup (default Business)
  ☐ DashboardProvider: filter business-only by default; add ownershipFilter param

Step 4 — Wallet picker on forms
  ☐ Sale form + Expense form: optional wallet GlassTextField-style picker (same showProductPicker pattern)
  ☐ Dashboard: "Wallet Balances" GlassPanel card (noBlur: true)

Step 5 — Allocation System
  ☐ AllocationRulesRepository + @Riverpod(keepAlive: true) provider
  ☐ AllocationBalanceRepository — derived query (accumulated − spent per rule)
  ☐ Add Finance tab to AppScaffold._tabs (index 5, icon: account_balance_wallet_outlined)
  ☐ Add StatefulShellBranch for /finance route
  ☐ FinanceScreen — one card per active rule, available balance, history chevron
  ☐ AllocationHistoryScreen — monthly breakdown table (pushed route /finance/history/:ruleId)
  ☐ AllocationSettingsScreen (/finance/settings) — CRUD for rules, sum validation
  ☐ AllocationRuleFormScreen — GlassTextField label + percentage, active toggle
  ☐ Expense form: "Allocate to fund" optional picker bottom sheet (business expenses only)
  ☐ AlertService: AllocationOverdrawAlert (sealed class, amber non-blocking warning)

Step 6 (Phase 2) — Budget Buckets
  ☐ Schema v4 (Global BudgetBuckets table)
  ☐ BudgetBuckets CRUD + BucketRepository
  ☐ Expense form: optional bucket picker
  ☐ Dashboard: "Buckets" GlassPanel card (list of balances with color chips)
  ☐ Bucket History Screen: join Expenses + Wallets to show wallet used per expense
  ☐ AlertService: BucketOverdrawAlert (sealed class, blocking showGlassDialog confirmation)

```

---

## Design Conventions (Must Follow per `AGENTS.md`)

- All new `TextField` → `GlassTextField`
- All new dialogs → `showGlassDialog()` with `actionsBuilder: (ctx) => [...]`
- All new body panels → `GlassPanel(noBlur: true)`
- All new pop-up surfaces (sheets, dialogs) → `GlassPanel(solid: true)`
- All new bottom sheets → `Column(mainAxisSize: min)` + `math.max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8)`
- No new top-level navigation tabs except Finance (6th tab) — Wallets nest inside Products tab; Allocation Settings is `/finance/settings` pushed from Finance tab
- Finance tab added to `AppScaffold._tabs` at index 5; `StatefulShellRoute` gains a 6th branch
- Ownership/wallet toggles use same `_ToggleGroup` pattern as platform/payment
- Wallet type uses `ChoiceChip` row (same `_FilterChip` pattern as product list)
- `Scaffold` transparent on all new screens
- No comments unless explicitly requested
- No new deps without asking (`@Riverpod(keepAlive: true)` for repositories, `@riverpod` for stream/future providers)

---

## Resolved Questions
1. **Wallets required?** Mandatory for all transactions.
2. **Dashboard ownership toggle?** Strictly business-only.
3. **Allocation overdraw behavior?** Non-blocking amber SnackBar.
4. **Phase rollout?** Phase-by-phase (v3 then v4).
5. **Finance tab icon?** `account_balance_wallet_outlined`.
6. **Budget Buckets scope?** Global limits, but track wallet used in history.
7. **Budget overdraw behavior?** Blocking `showGlassDialog` confirmation.

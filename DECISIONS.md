# Architectural & Design Decisions

This file logs important decisions made during development. Each entry has a date, context, decision, and rationale.

---

## 2026-06-16 — Screen/Popup Bug-Fix Session

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

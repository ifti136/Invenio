# Phase 4 — Validation, Debugging & Testing
## Expenses: Repository, Screens, Cross-Agent Contract

**Status at time of writing:** ⬜ Not started
**Agent:** Agent A owns this phase entirely
**Critical cross-agent dependency:** `expenseRepositoryProvider` and `totalForPeriod()` are called by Agent B's `ReportRepository`. The method signature is a shared contract — do NOT change it after publishing.

---

## 1. Pre-Implementation Checklist

Before writing any Phase 4 code, verify the following are already in place from Phase 1–3:

```bash
# All must pass before starting Phase 4
flutter analyze            # 0 errors
flutter test               # all Phase 1-3 tests green

# Confirm shared files exist and are correct
ls lib/db/tables/expenses_table.dart        # must exist
ls lib/core/widgets/glass_text_field.dart   # must exist
ls lib/core/widgets/glass_dialog.dart       # must exist
ls lib/core/utils/formatters.dart           # must exist — Formatters.money() used by expense tile
```

---

## 2. Static Validation

```bash
# After creating expense_repository.dart:
dart run build_runner build --delete-conflicting-outputs
# Generates: expense_repository.g.dart

flutter analyze
# Must show 0 errors before proceeding to screens
```

Files to validate:

```
lib/models/expense_filter.dart
lib/features/expenses/expense_repository.dart
lib/features/expenses/expense_repository.g.dart  ← generated
lib/features/expenses/expense_provider.dart
lib/features/expenses/expense_list_screen.dart
lib/features/expenses/expense_form_screen.dart
lib/features/expenses/widgets/expense_tile.dart
lib/features/expenses/widgets/expense_filter_bar.dart
```

---

## 3. Cross-Agent Contract Validation

**This must be verified before Agent B starts ReportRepository work.**

The cross-agent interface is a single method. Validate its signature exactly:

```dart
// ✅ CORRECT signature — do not deviate
Future<double> totalForPeriod(DateTime start, DateTime end);
```

Write this contract test and share the result with Agent B:

```dart
// test/unit/expense_contract_test.dart
// PURPOSE: Confirms that the cross-agent API is stable.
// Run this first and show Agent B it passes before they write ReportRepository.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/expenses/expense_repository.dart';
import 'package:tracker/models/expense_filter.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExpenseRepository(db);
  });

  tearDown(() => db.close());

  // ── CONTRACT: totalForPeriod ───────────────────────────────────────────────
  // Agent B calls this. Do NOT change signature after this test passes.

  group('CONTRACT — totalForPeriod (Agent B depends on this)', () {
    test('returns 0.0 when no expenses in period', () async {
      final total = await repo.totalForPeriod(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30, 23, 59, 59),
      );
      expect(total, 0.0);
    });

    test('returns sum of all expenses within the period', () async {
      await repo.add(AddExpenseParams(
        amount: 500, category: ExpenseCategory.ads,
        date: DateTime(2024, 6, 10),
      ));
      await repo.add(AddExpenseParams(
        amount: 200, category: ExpenseCategory.delivery,
        date: DateTime(2024, 6, 20),
      ));
      final total = await repo.totalForPeriod(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30, 23, 59, 59),
      );
      expect(total, closeTo(700.0, 0.01));
    });

    test('EXCLUDES expenses outside the date range', () async {
      await repo.add(AddExpenseParams(
        amount: 999, category: ExpenseCategory.misc,
        date: DateTime(2024, 5, 31), // May — outside June range
      ));
      await repo.add(AddExpenseParams(
        amount: 100, category: ExpenseCategory.ads,
        date: DateTime(2024, 6, 1), // inside
      ));
      final total = await repo.totalForPeriod(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30, 23, 59, 59),
      );
      expect(total, closeTo(100.0, 0.01));
    });

    test('handles period with a single expense exactly on boundary', () async {
      final boundaryDate = DateTime(2024, 6, 1);
      await repo.add(AddExpenseParams(
        amount: 300, category: ExpenseCategory.packaging,
        date: boundaryDate,
      ));
      final total = await repo.totalForPeriod(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30, 23, 59, 59),
      );
      expect(total, closeTo(300.0, 0.01));
    });

    test('return type is double (not int)', () async {
      await repo.add(AddExpenseParams(
        amount: 150.50, category: ExpenseCategory.delivery,
        date: DateTime(2024, 6, 5),
      ));
      final total = await repo.totalForPeriod(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30),
      );
      expect(total, isA<double>());
      expect(total, closeTo(150.50, 0.01));
    });
  });
}
```

**Run and share with Agent B:**
```bash
flutter test test/unit/expense_contract_test.dart --reporter expanded
# All 5 tests must pass before Agent B starts ReportRepository
```

---

## 4. Full Unit Tests — ExpenseRepository

```dart
// test/unit/expense_repository_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/expenses/expense_repository.dart';
import 'package:tracker/models/expense_filter.dart';

void main() {
  late AppDatabase db;
  late ExpenseRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExpenseRepository(db);
  });

  tearDown(() => db.close());

  // ── add() ─────────────────────────────────────────────────────────────────

  group('add()', () {
    test('returns a positive id', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 500,
        category: ExpenseCategory.ads,
        date: DateTime.now(),
      ));
      expect(id, greaterThan(0));
    });

    test('stores amount correctly', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 123.45,
        category: ExpenseCategory.delivery,
        date: DateTime.now(),
      ));
      final expense = await repo.getById(id);
      expect(expense.amount, closeTo(123.45, 0.001));
    });

    test('stores category as string matching enum name', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 100,
        category: ExpenseCategory.packaging,
        date: DateTime.now(),
      ));
      final expense = await repo.getById(id);
      expect(expense.category, 'packaging');
    });

    test('stores optional note', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 200,
        category: ExpenseCategory.ads,
        note: 'Facebook boost — 3 days',
        date: DateTime.now(),
      ));
      final expense = await repo.getById(id);
      expect(expense.note, 'Facebook boost — 3 days');
    });

    test('note is null when not provided', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 200,
        category: ExpenseCategory.misc,
        date: DateTime.now(),
      ));
      final expense = await repo.getById(id);
      expect(expense.note, isNull);
    });

    test('stores date as Unix timestamp ms', () async {
      final date = DateTime(2024, 6, 15);
      final id = await repo.add(AddExpenseParams(
        amount: 100,
        category: ExpenseCategory.ads,
        date: date,
      ));
      final expense = await repo.getById(id);
      expect(expense.date, date.millisecondsSinceEpoch);
    });
  });

  // ── update() ──────────────────────────────────────────────────────────────

  group('update()', () {
    test('changes amount only when only amount specified', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 100,
        category: ExpenseCategory.ads,
        date: DateTime.now(),
      ));
      await repo.update(id, const UpdateExpenseParams(amount: 250));
      final updated = await repo.getById(id);
      expect(updated.amount, 250);
      expect(updated.category, 'ads'); // unchanged
    });

    test('changes category only', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 100,
        category: ExpenseCategory.ads,
        date: DateTime.now(),
      ));
      await repo.update(id,
          const UpdateExpenseParams(category: ExpenseCategory.delivery));
      final updated = await repo.getById(id);
      expect(updated.category, 'delivery');
      expect(updated.amount, 100); // unchanged
    });

    test('null fields leave all values unchanged', () async {
      final date = DateTime(2024, 6, 1);
      final id = await repo.add(AddExpenseParams(
        amount: 75,
        category: ExpenseCategory.packaging,
        note: 'Bubble wrap',
        date: date,
      ));
      await repo.update(id, const UpdateExpenseParams()); // all nulls
      final updated = await repo.getById(id);
      expect(updated.amount, 75);
      expect(updated.category, 'packaging');
      expect(updated.note, 'Bubble wrap');
    });
  });

  // ── delete() ─────────────────────────────────────────────────────────────

  group('delete()', () {
    test('removes the expense row', () async {
      final id = await repo.add(AddExpenseParams(
        amount: 100,
        category: ExpenseCategory.misc,
        date: DateTime.now(),
      ));
      await repo.delete(id);
      final all = await repo.watchFiltered(const ExpenseFilter()).first;
      expect(all.where((e) => e.id == id), isEmpty);
    });

    test('does not affect other expense rows', () async {
      final id1 = await repo.add(AddExpenseParams(
        amount: 100,
        category: ExpenseCategory.ads,
        date: DateTime.now(),
      ));
      final id2 = await repo.add(AddExpenseParams(
        amount: 200,
        category: ExpenseCategory.delivery,
        date: DateTime.now(),
      ));
      await repo.delete(id1);
      final remaining = await repo.watchFiltered(const ExpenseFilter()).first;
      expect(remaining.length, 1);
      expect(remaining.first.id, id2);
    });
  });

  // ── watchFiltered() ───────────────────────────────────────────────────────

  group('watchFiltered()', () {
    test('emits empty list when no expenses', () async {
      final list = await repo.watchFiltered(const ExpenseFilter()).first;
      expect(list, isEmpty);
    });

    test('category filter returns only matching expenses', () async {
      await repo.add(AddExpenseParams(
        amount: 100, category: ExpenseCategory.ads, date: DateTime.now()));
      await repo.add(AddExpenseParams(
        amount: 200, category: ExpenseCategory.delivery, date: DateTime.now()));
      final filtered = await repo
          .watchFiltered(
              const ExpenseFilter(category: ExpenseCategory.ads))
          .first;
      expect(filtered.length, 1);
      expect(filtered.first.category, 'ads');
    });

    test('date range filter excludes out-of-range expenses', () async {
      await repo.add(AddExpenseParams(
        amount: 100, category: ExpenseCategory.ads,
        date: DateTime(2024, 6, 1)));
      await repo.add(AddExpenseParams(
        amount: 999, category: ExpenseCategory.misc,
        date: DateTime(2024, 5, 15)));
      final filtered = await repo
          .watchFiltered(ExpenseFilter(
            start: DateTime(2024, 6, 1),
            end: DateTime(2024, 6, 30, 23, 59, 59),
          ))
          .first;
      expect(filtered.length, 1);
      expect(filtered.first.amount, 100);
    });

    test('all-category filter returns all expenses', () async {
      for (final cat in ExpenseCategory.values
          .where((c) => c != ExpenseCategory.all)) {
        await repo.add(AddExpenseParams(
          amount: 50, category: cat, date: DateTime.now()));
      }
      final all = await repo
          .watchFiltered(const ExpenseFilter(category: ExpenseCategory.all))
          .first;
      expect(all.length, 4);
    });
  });

  // ── totalByCategory() ────────────────────────────────────────────────────

  group('totalByCategory()', () {
    test('returns zero for categories with no expenses in period', () async {
      final breakdown = await repo.totalByCategory(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30),
      );
      for (final value in breakdown.values) {
        expect(value, 0.0);
      }
    });

    test('correctly sums per category', () async {
      await repo.add(AddExpenseParams(
        amount: 300, category: ExpenseCategory.ads,
        date: DateTime(2024, 6, 10)));
      await repo.add(AddExpenseParams(
        amount: 100, category: ExpenseCategory.ads,
        date: DateTime(2024, 6, 15)));
      await repo.add(AddExpenseParams(
        amount: 200, category: ExpenseCategory.delivery,
        date: DateTime(2024, 6, 20)));
      final breakdown = await repo.totalByCategory(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30),
      );
      expect(breakdown[ExpenseCategory.ads], closeTo(400.0, 0.01));
      expect(breakdown[ExpenseCategory.delivery], closeTo(200.0, 0.01));
      expect(breakdown[ExpenseCategory.packaging], 0.0);
      expect(breakdown[ExpenseCategory.misc], 0.0);
    });
  });
}
```

**Run with:**
```bash
flutter test test/unit/expense_repository_test.dart --reporter expanded
flutter test test/unit/expense_contract_test.dart --reporter expanded
```

---

## 5. Widget Tests — Expense Form

```dart
// test/widget/expense_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/expense_form_screen.dart';

void main() {
  Widget buildForm({int? expenseId}) => ProviderScope(
        child: MaterialApp(home: ExpenseFormScreen(expenseId: expenseId)),
      );

  group('ExpenseFormScreen (add mode)', () {
    testWidgets('shows all 4 category chips', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();
      expect(find.text('📢 Ads'), findsOneWidget);
      expect(find.text('🚚 Delivery'), findsOneWidget);
      expect(find.text('📦 Packaging'), findsOneWidget);
      expect(find.text('🗂 Misc'), findsOneWidget);
    });

    testWidgets('shows validation error when amount is empty on save',
        (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log Expense'));
      await tester.pumpAndSettle();
      expect(
          find.text('Enter a valid amount greater than 0'), findsOneWidget);
    });

    testWidgets('shows validation error when amount is zero', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '0');
      await tester.tap(find.text('Log Expense'));
      await tester.pumpAndSettle();
      expect(
          find.text('Enter a valid amount greater than 0'), findsOneWidget);
    });

    testWidgets('shows correct title in add mode', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();
      expect(find.text('Log Expense'), findsWidgets);
    });

    testWidgets('selecting a category chip marks it as selected',
        (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();
      await tester.tap(find.text('🚚 Delivery'));
      await tester.pumpAndSettle();
      final chip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('🚚 Delivery'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(chip.selected, isTrue);
    });
  });

  group('ExpenseFormScreen (edit mode)', () {
    testWidgets('shows delete button in edit mode', (tester) async {
      // expenseId=99 — will fail to load but shows the AppBar delete button
      await tester.pumpWidget(buildForm(expenseId: 99));
      await tester.pump(); // don't pumpAndSettle — async load
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('title shows "Edit Expense" in edit mode', (tester) async {
      await tester.pumpWidget(buildForm(expenseId: 99));
      await tester.pump();
      expect(find.text('Edit Expense'), findsOneWidget);
    });
  });
}
```

---

## 6. Manual Validation Checklist

### 6.1 Add Expense — Happy Path

| Step | Action | Expected |
|------|--------|----------|
| 1 | Open Expenses tab | Expense list (empty) shown |
| 2 | Tap + | Form opens |
| 3 | Amount = 500, Category = Ads | Chip selected highlighted |
| 4 | Date picker | Current date pre-selected |
| 5 | Note = "FB boost" | Text field accepts input |
| 6 | Tap Log Expense | Returns to list |
| 7 | List header | Shows "Period Total: ৳500" |
| 8 | Ads chip shown in breakdown | "Ads: ৳500" visible in header chips |

### 6.2 Filter Validation

| Filter | Expected |
|--------|---------|
| Category: Ads | Only ad expenses shown; total is only ads |
| Category: All | All expenses shown |
| This month preset | Expenses from current month only |
| Last 30 days preset | Rolling 30-day window |
| All time | No date filter applied |

### 6.3 Edit & Delete

| Scenario | Expected |
|----------|---------|
| Tap expense → edit form opens | Fields pre-filled with existing data |
| Change amount → Save Changes | Amount updates in list and header total |
| Delete → Cancel | Expense remains |
| Delete → Confirm | Expense removed; period total decreases |

### 6.4 Net Profit Dependency (cross-agent)

This check requires Agent B's ReportRepository to be wired. Perform this after Phase 5 is integrated:

| Setup | Expected net profit |
|-------|-------------------|
| Gross profit: ৳1000, Expenses: ৳300 | Net profit: ৳700 |
| Gross profit: ৳500, Expenses: ৳600 | Net profit: −৳100 (loss) |
| Gross profit: ৳0, Expenses: ৳0 | Net profit: ৳0 |

---

## 7. Debugging Guide

### 7.1 Category Filter Not Working

**Symptom:** Selecting "Ads" filter shows all expenses.

**Root cause:** The `ExpenseFilter.category` field is `ExpenseCategory.all` (default) instead of the selected value, OR the `expenseFilterProvider` state mutation isn't triggering a rebuild.

**Check:**
```dart
// In expense_filter_bar.dart — mutation must update the notifier:
ref.read(expenseFilterProvider.notifier).state = filter.copyWith(category: cat);
// NOT:
ref.read(expenseFilterProvider).copyWith(...)  // wrong — reads only, doesn't update
```

### 7.2 Period Total Not Matching Sum of Rows

**Symptom:** Header shows ৳X but the visible rows sum to ৳Y.

**Root cause:** `expensePeriodTotalProvider` derives from `expenseListProvider.valueOrNull`. If the stream hasn't emitted yet (loading state), it returns `[]` and the total is 0.

**Check:** In `ExpenseListScreen`, make sure the header is rebuilt when `expenseListProvider` changes:

```dart
// Correct — re-reads total from derived provider
final total = ref.watch(expensePeriodTotalProvider);

// Wrong — reads total once and doesn't update
final total = ref.read(expensePeriodTotalProvider);
```

### 7.3 `expenseRepositoryProvider` Not Found by Agent B

**Symptom:** Agent B's `ReportRepository` gets a compile error on `expenseRepositoryProvider`.

**Cause:** `expense_repository.dart` missing the `part` directive, or `build_runner` not regenerated after creating the file.

**Fix:**
1. Confirm `part 'expense_repository.g.dart';` is present in `expense_repository.dart`
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Confirm `expense_repository.g.dart` now exists
4. In Agent B's file: `import 'package:tracker/features/expenses/expense_repository.dart';`

### 7.4 Decimal Amounts Displaying Incorrectly

**Symptom:** ৳500 shown as ৳500.0000000001 due to floating point.

**Fix:** Always use `Formatters.money(amount)` from `lib/core/utils/formatters.dart` — never `.toString()` directly on a double.

```dart
// Correct
Text(Formatters.money(expense.amount)) // → "৳500.00"

// Wrong
Text('৳${expense.amount}')             // → "৳500.0" or ৳"500.0000000001"
```

---

## 8. Phase 4 Completion Gate

```
✅ flutter analyze — 0 errors
✅ test/unit/expense_contract_test.dart — all 5 tests pass
✅  → Share this result with Agent B before they start ReportRepository
✅ test/unit/expense_repository_test.dart — all 18+ tests pass
✅ test/widget/expense_form_test.dart — all 7 tests pass
✅ dart run build_runner build — expense_repository.g.dart generated
✅ Manual: add expense → appears in list with correct category icon
✅ Manual: period total header updates correctly
✅ Manual: category breakdown chips show correct per-category totals
✅ Manual: date filters work (this month, last 30 days, all time)
✅ Manual: edit expense → correct pre-fill
✅ Manual: delete expense → removed + total updates
✅ Manual: Formatters.money() used for all currency display (no raw doubles)
✅ Update 06_completion_status.md Phase 4 rows to ✅
```

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/money/expense_repository.dart';
import 'package:tracker/features/settings/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late ExpenseRepository expenses;
  late int cash;
  late int bank;
  late int categoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accounts = AccountRepository(db);
    expenses = ExpenseRepository(db);
    cash = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    bank = await accounts.addAccount(
      name: 'Bank',
      openingBalanceMinor: 5000,
    );
    categoryId = (await db.select(db.expenseCategories).get()).first.id;
  });

  tearDown(() async {
    await db.close();
  });

  test('an expense reduces its account balance and appears in the ledger',
      () async {
    final id = await expenses.addExpense(
      categoryId: categoryId,
      accountId: cash,
      amountMinor: 1200,
      date: DateTime.now(),
      note: 'Flyers',
    );

    final balances = await accounts.watchBalances().first;
    expect(balances.firstWhere((item) => item.account.id == cash).balanceMinor,
        8800);
    expect(balances.firstWhere((item) => item.account.id == bank).balanceMinor,
        5000);

    final list = await expenses.watchExpenses().first;
    expect(list, hasLength(1));
    expect(list.single.expense.id, id);
    expect(list.single.expense.amountMinor, 1200);
    expect(list.single.expense.note, 'Flyers');
    expect(list.single.accountName, 'Cash');

    final ledger = (await accounts.getLedger(cash))!;
    expect(ledger.entries.single.kind, 'expense');
    expect(ledger.entries.single.amountMinor, -1200);
    expect(ledger.entries.single.runningMinor, 8800);
  });

  test('editing moves the deduction to the new account and amount', () async {
    final id = await expenses.addExpense(
      categoryId: categoryId,
      accountId: cash,
      amountMinor: 1200,
      date: DateTime.now(),
    );

    await expenses.updateExpense(
      id: id,
      categoryId: categoryId,
      accountId: bank,
      amountMinor: 700,
      date: DateTime.now(),
    );

    final balances = await accounts.watchBalances().first;
    expect(balances.firstWhere((item) => item.account.id == cash).balanceMinor,
        10000);
    expect(balances.firstWhere((item) => item.account.id == bank).balanceMinor,
        4300);
  });

  test('deleting reverses the deduction and restore reapplies it', () async {
    final id = await expenses.addExpense(
      categoryId: categoryId,
      accountId: cash,
      amountMinor: 800,
      date: DateTime.now(),
    );

    final deleted = await expenses.deleteExpense(id);
    expect(deleted, isNotNull);
    var balances = await accounts.watchBalances().first;
    expect(balances.firstWhere((item) => item.account.id == cash).balanceMinor,
        10000);
    expect(await db.select(db.expenses).get(), isEmpty);

    await expenses.restoreExpense(deleted!);
    balances = await accounts.watchBalances().first;
    expect(balances.firstWhere((item) => item.account.id == cash).balanceMinor,
        9200);
    expect(await db.select(db.expenses).get(), hasLength(1));
  });

  test('an expense blocks a negative account unless confirmed', () async {
    expect(
      () => expenses.addExpense(
        categoryId: categoryId,
        accountId: cash,
        amountMinor: 12000,
        date: DateTime.now(),
      ),
      throwsA(isA<NegativeBalanceException>()),
    );

    await expenses.addExpense(
      categoryId: categoryId,
      accountId: cash,
      amountMinor: 12000,
      date: DateTime.now(),
      allowNegative: true,
    );
    final balances = await accounts.watchBalances().first;
    expect(balances.firstWhere((item) => item.account.id == cash).balanceMinor,
        -2000);
  });

  test('dates are stored at local day precision', () async {
    final date = DateTime(2026, 3, 4, 15, 30);
    final id = await expenses.addExpense(
      categoryId: categoryId,
      accountId: cash,
      amountMinor: 100,
      date: date,
    );
    final expense = await (db.select(db.expenses)
          ..where((row) => row.id.equals(id)))
        .getSingle();
    final stored = DateTime.fromMillisecondsSinceEpoch(expense.date);
    expect(
        DateTime(stored.year, stored.month, stored.day), DateTime(2026, 3, 4));
  });
}

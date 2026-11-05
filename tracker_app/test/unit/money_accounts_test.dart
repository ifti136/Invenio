import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/utils/date_period.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/money/expense_repository.dart';
import 'package:tracker/features/sales/customer_repository.dart';
import 'package:tracker/features/sales/sale_models.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/settings/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late ExpenseRepository expenses;
  late ProductRepository products;
  late SaleRepository sales;
  late CustomerRepository customers;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accounts = AccountRepository(db);
    expenses = ExpenseRepository(db);
    products = ProductRepository(db);
    sales = SaleRepository(db);
    customers = CustomerRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('balance includes payments, expenses, restocks, transfers, adjustments',
      () async {
    final cash = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final bank = await accounts.addAccount(
      name: 'Bank',
      openingBalanceMinor: 500,
    );
    final category = (await db.select(db.expenseCategories).get()).first;

    await expenses.addExpense(
      categoryId: category.id,
      accountId: cash,
      amountMinor: 2000,
      date: DateTime.now(),
    );
    await accounts.createTransfer(
      fromAccountId: cash,
      toAccountId: bank,
      amountMinor: 3000,
    );
    await accounts.addAdjustment(
      accountId: cash,
      amountMinor: -500,
      note: 'Counted the till',
    );

    final balances = await accounts.watchBalances().first;
    final cashBalance = balances.firstWhere((item) => item.account.id == cash);
    final bankBalance = balances.firstWhere((item) => item.account.id == bank);
    expect(cashBalance.balanceMinor, 10000 - 2000 - 3000 - 500);
    expect(bankBalance.balanceMinor, 3500);

    final ledger = await accounts.getLedger(cash);
    expect(ledger!.balanceMinor, 4500);
    expect(ledger.entries, hasLength(3));
    expect(ledger.entries[0].kind, 'expense');
    expect(ledger.entries[0].amountMinor, -2000);
    expect(ledger.entries[1].kind, 'transferOut');
    expect(ledger.entries[1].amountMinor, -3000);
    expect(ledger.entries[2].kind, 'adjustment');
    expect(ledger.entries[2].amountMinor, -500);
    expect(ledger.entries[0].runningMinor, 8000);
    expect(ledger.entries[1].runningMinor, 5000);
    expect(ledger.entries[2].runningMinor, 4500);
    expect(ledger.outMinor(DatePeriod.allTime), 5500);
    expect(ledger.inMinor(DatePeriod.allTime), 0);

    final total = balances.fold<int>(0, (sum, item) => sum + item.balanceMinor);
    expect(total, 10000 + 500 - 2000 - 500);
  });

  test('transfers need two accounts and block a negative source unless allowed',
      () async {
    final cash = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 1000,
    );
    final bank = await accounts.addAccount(
      name: 'Bank',
      openingBalanceMinor: 0,
    );

    expect(
      () => accounts.createTransfer(
        fromAccountId: cash,
        toAccountId: cash,
        amountMinor: 100,
      ),
      throwsArgumentError,
    );
    expect(
      () => accounts.createTransfer(
        fromAccountId: cash,
        toAccountId: bank,
        amountMinor: 1500,
      ),
      throwsA(isA<NegativeBalanceException>()),
    );

    await accounts.createTransfer(
      fromAccountId: cash,
      toAccountId: bank,
      amountMinor: 1500,
      allowNegative: true,
    );
    final balances = await accounts.watchBalances().first;
    expect(balances.firstWhere((item) => item.account.id == cash).balanceMinor,
        -500);
    expect(balances.firstWhere((item) => item.account.id == bank).balanceMinor,
        1500);
  });

  test('transfers never change profit', () async {
    final cash = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 5000,
    );
    final bank = await accounts.addAccount(
      name: 'Bank',
      openingBalanceMinor: 0,
    );
    final customer = await customers.addCustomer(name: 'Rina');
    final product = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1200,
      costMinor: 800,
      initialStock: 5,
      lowStockAt: 3,
      archived: false,
    );
    final channel = (await db.select(db.channels).get()).first;

    await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: product,
          qty: 1,
          unitPriceMinor: 1200,
          unitCostMinor: 800,
        ),
      ],
      channelId: channel.id,
      payment: PaymentMode.due,
      customerId: customer,
    );

    final before = await sales.watchSales().first;
    final profitBefore = before.single.profitMinor;
    await accounts.createTransfer(
      fromAccountId: cash,
      toAccountId: bank,
      amountMinor: 2500,
    );
    final after = await sales.watchSales().first;
    expect(after.single.profitMinor, profitBefore);
    expect(profitBefore, 400);
  });

  test('ledger period summary separates this month from last month', () async {
    final cash = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
    final category = (await db.select(db.expenseCategories).get()).first;
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 15);

    await expenses.addExpense(
      categoryId: category.id,
      accountId: cash,
      amountMinor: 700,
      date: now,
    );
    await expenses.addExpense(
      categoryId: category.id,
      accountId: cash,
      amountMinor: 300,
      date: lastMonth,
    );

    final ledger = (await accounts.getLedger(cash))!;
    expect(ledger.outMinor(DatePeriod.thisMonth), 700);
    expect(ledger.outMinor(DatePeriod.lastMonth), 300);
  });
}

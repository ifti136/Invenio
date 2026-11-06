import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/home/dashboard_repository.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/money/expense_repository.dart';
import 'package:tracker/features/reports/csv_export.dart';
import 'package:tracker/features/reports/report_repository.dart';
import 'package:tracker/features/sales/customer_repository.dart';
import 'package:tracker/features/sales/sale_models.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/settings/account_repository.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late ProductRepository products;
  late SaleRepository sales;
  late CustomerRepository customers;
  late ExpenseRepository expenses;
  late DashboardRepository dashboard;
  late ReportRepository reports;
  late int channelId;
  late int categoryId;
  late int accountId;
  late int productId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accounts = AccountRepository(db);
    products = ProductRepository(db);
    sales = SaleRepository(db);
    customers = CustomerRepository(db);
    expenses = ExpenseRepository(db);
    dashboard = DashboardRepository(db);
    reports = ReportRepository(db);
    channelId = (await db.select(db.channels).get()).first.id;
    categoryId = (await db.select(db.expenseCategories).get()).first.id;
    accountId = await accounts.addAccount(
      name: 'Cash',
      openingBalanceMinor: 100000,
    );
    productId = await products.createProduct(
      name: 'Wired Mouse',
      priceMinor: 1000,
      costMinor: 600,
      initialStock: 20,
      lowStockAt: 3,
      archived: false,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> sell({int qty = 2, int? customerId}) async {
    final receipt = await sales.saveSale(
      lines: [
        SaleLineInput(
          productId: productId,
          qty: qty,
          unitPriceMinor: 1000,
          unitCostMinor: 600,
        ),
      ],
      channelId: channelId,
      payment: PaymentMode.paid,
      customerId: customerId,
      accountId: accountId,
    );
    return receipt.saleId;
  }

  test('dashboard today aggregates sales count, revenue, and gross profit',
      () async {
    final empty = await dashboard.watchTodayStats().first;
    expect(empty.salesCount, 0);
    expect(empty.revenueMinor, 0);
    expect(empty.profitMinor, 0);

    await sell(qty: 2);

    final stats = await dashboard.watchTodayStats().first;
    expect(stats.salesCount, 1);
    expect(stats.revenueMinor, 2000);
    expect(stats.profitMinor, 800);
  });

  test('P&L uses sale item revenue and cost, adds period expenses, and margin',
      () async {
    await sell(qty: 2);
    await expenses.addExpense(
      categoryId: categoryId,
      accountId: accountId,
      amountMinor: 300,
      date: DateTime.now(),
    );

    final report = await reports.getReport(ReportRange.week(DateTime.now()));

    expect(report.pnl.revenueMinor, 2000);
    expect(report.pnl.cogsMinor, 1200);
    expect(report.pnl.grossProfitMinor, 800);
    expect(report.pnl.expensesMinor, 300);
    expect(report.pnl.netProfitMinor, 500);
    expect(report.pnl.margin, closeTo(0.25, 0.000001));
  });

  test('reports group products and channels and fill chart buckets', () async {
    await sell(qty: 2);
    await sell(qty: 1);

    final report = await reports.getReport(ReportRange.week(DateTime.now()));

    expect(report.buckets, hasLength(7));
    expect(
      report.buckets.fold<int>(0, (sum, bucket) => sum + bucket.revenueMinor),
      3000,
    );
    expect(report.products, hasLength(1));
    expect(report.products.single.name, 'Wired Mouse');
    expect(report.products.single.qty, 3);
    expect(report.products.single.revenueMinor, 3000);
    expect(report.products.single.profitMinor, 1200);
    expect(report.channels, hasLength(1));
    expect(report.channels.single.name, 'In person');
    expect(report.channels.single.qty, 3);
    expect(report.channels.single.revenueMinor, 3000);
  });

  test('empty reports keep the selected range buckets and no data flag',
      () async {
    final report = await reports.getReport(ReportRange.week(DateTime.now()));

    expect(report.isEmpty, true);
    expect(report.buckets, hasLength(7));
    expect(report.products, isEmpty);
    expect(report.channels, isEmpty);
  });

  test('custom ranges fill one bucket per selected day and guard margin',
      () async {
    final report = await reports.getReport(
      ReportRange.custom(DateTime(2026, 1, 10), DateTime(2026, 1, 12)),
    );

    expect(report.buckets, hasLength(3));
    expect(report.pnl.margin, 0);
  });

  test('CSV escapes commas, quotes, and newlines', () {
    expect(csvField('plain'), 'plain');
    expect(csvField('a,b'), '"a,b"');
    expect(csvField('say "hi"'), '"say ""hi"""');
    expect(csvField('line1\nline2'), '"line1\nline2"');
    expect(
      encodeCsv([
        ['a', 'b'],
        ['c,d', 'e'],
      ]),
      'a,b\n"c,d",e',
    );
  });

  test('CSV export builds all data files with escaped values', () async {
    final customerId = await customers.addCustomer(name: 'Rina, "Best"');
    await sell(qty: 2, customerId: customerId);
    await expenses.addExpense(
      categoryId: categoryId,
      accountId: accountId,
      amountMinor: 300,
      date: DateTime.now(),
      note: 'line1\nline2',
    );

    final files = await CsvExportService(db).buildFiles();
    final byName = {for (final file in files) file.name: file.content};

    expect(
      byName.keys,
      containsAll([
        'sales.csv',
        'sale_items.csv',
        'payments.csv',
        'expenses.csv',
        'accounts.csv',
      ]),
    );
    expect(
      byName['sales.csv'],
      contains('"Rina, ""Best"""'),
    );
    expect(byName['expenses.csv'], contains('"line1\nline2"'));
    expect(
      byName['sale_items.csv'],
      contains('2000'),
    );
  });
  test('CSV export returns no files when there is nothing to export', () async {
    await db.clearAllData();

    expect(await CsvExportService(db).buildFiles(), isEmpty);
  });
}

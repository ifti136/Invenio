import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/theme/app_theme.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/home/dashboard_repository.dart';
import 'package:tracker/features/home/home_providers.dart';
import 'package:tracker/features/home/home_screen.dart';
import 'package:tracker/features/inventory/inventory_providers.dart';
import 'package:tracker/features/inventory/inventory_screen.dart';
import 'package:tracker/features/inventory/product_repository.dart';
import 'package:tracker/features/money/dues_repository.dart';
import 'package:tracker/features/money/money_providers.dart';
import 'package:tracker/features/money/money_screen.dart';
import 'package:tracker/features/reports/report_providers.dart';
import 'package:tracker/features/reports/report_repository.dart';
import 'package:tracker/features/reports/reports_screen.dart';
import 'package:tracker/features/sales/sale_models.dart';
import 'package:tracker/features/sales/sale_providers.dart';
import 'package:tracker/features/sales/sales_screen.dart';
import 'package:tracker/features/settings/account_repository.dart';
import 'package:tracker/features/settings/settings_providers.dart';

void main() {
  const account = Account(
    id: 1,
    name: 'Cash',
    openingBalanceMinor: 100000,
    archived: false,
  );
  final balances = [
    const AccountBalance(account: account, balanceMinor: 123456),
  ];
  const settings = Setting(id: 1, currencySymbol: '৳', shopName: 'Shop');
  final products = [
    const Product(
      id: 1,
      name: 'Wired Mouse With A Fairly Long Product Name',
      priceMinor: 1200,
      costMinor: 800,
      stock: 2,
      lowStockAt: 3,
      archived: false,
    ),
    const Product(
      id: 2,
      name: 'Mechanical Keyboard',
      priceMinor: 5500,
      costMinor: 4000,
      stock: 0,
      lowStockAt: 2,
      archived: false,
    ),
  ];
  const productStats = ProductStats(
    products: 2,
    lowStock: 1,
    outOfStock: 1,
    stockValueMinor: 4000,
  );
  final now = DateTime.now().millisecondsSinceEpoch;
  final sales = [
    SaleSummary(
      id: 1,
      createdAt: now,
      totalMinor: 1200,
      status: 'paid',
      channelId: 1,
      customerName: null,
      channelName: 'Walk-in',
      paidMinor: 1200,
      dueMinor: 0,
      itemCount: 1,
      itemsLabel: 'Wired Mouse',
      profitMinor: 400,
    ),
  ];
  const channel = Channel(id: 1, name: 'Walk-in', sort: 0);
  final dues = [
    CustomerDue(
      customerId: 1,
      name: 'A Customer With A Long Name',
      phone: null,
      dueMinor: 1200,
      oldestCreatedAt: now,
      saleCount: 1,
    ),
  ];
  const today = TodayStats(salesCount: 3, revenueMinor: 4200, profitMinor: 900);
  const report = ReportData(
    pnl: ProfitLoss(revenueMinor: 4200, cogsMinor: 3000, expensesMinor: 200),
    buckets: [
      ReportBucket(label: 'Mon', revenueMinor: 1200, profitMinor: 400),
      ReportBucket(label: 'Tue', revenueMinor: 3000, profitMinor: 500),
    ],
    products: [
      ProductBreakdown(
        productId: 1,
        name: 'Wired Mouse With A Fairly Long Product Name',
        qty: 3,
        revenueMinor: 3600,
        profitMinor: 800,
      ),
    ],
    channels: [
      ChannelBreakdown(
        channelId: 1,
        name: 'Walk-in',
        qty: 3,
        revenueMinor: 3600,
        profitMinor: 800,
      ),
    ],
  );

  Future<void> pumpAt200Percent(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
          accountBalancesProvider.overrideWith((ref) => Stream.value(balances)),
          duesListProvider.overrideWith((ref) => Stream.value(dues)),
          productStatsProvider
              .overrideWith((ref) => Stream.value(productStats)),
          todayStatsProvider.overrideWith((ref) => Stream.value(today)),
          allProductsProvider.overrideWith((ref) => Stream.value(products)),
          productsProvider.overrideWith((ref) => Stream.value(products)),
          salesListProvider.overrideWith((ref) => Stream.value(sales)),
          channelsProvider.overrideWith((ref) => Stream.value(const [channel])),
          reportProvider(ReportRange.week(DateTime.now()))
              .overrideWith((ref) => Stream.value(report)),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: screen),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('Home renders at 200% text scale without overflow',
      (tester) async {
    await pumpAt200Percent(tester, const HomeScreen());
    expect(find.text('Total money'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sales renders at 200% text scale without overflow',
      (tester) async {
    await pumpAt200Percent(tester, const SalesScreen());
    expect(find.byType(SearchBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Inventory renders at 200% text scale without overflow',
      (tester) async {
    await pumpAt200Percent(tester, const InventoryScreen());
    expect(find.text('Inventory'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Money renders at 200% text scale without overflow',
      (tester) async {
    await pumpAt200Percent(tester, const MoneyScreen());
    expect(find.text('Total money'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reports renders at 200% text scale without overflow',
      (tester) async {
    await pumpAt200Percent(tester, const ReportsScreen());
    expect(find.text('Profit & loss'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

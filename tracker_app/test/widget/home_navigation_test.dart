import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/app.dart';
import 'package:tracker/core/widgets/stat_card.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/home/home_screen.dart';
import 'package:tracker/features/inventory/inventory_screen.dart';
import 'package:tracker/features/money/account_ledger_screen.dart';
import 'package:tracker/features/money/money_screen.dart';
import 'package:tracker/features/reports/reports_screen.dart';
import 'package:tracker/features/sales/sales_screen.dart';
import 'package:tracker/features/settings/account_repository.dart';
import 'package:tracker/features/settings/settings_providers.dart';
import 'package:tracker/features/settings/settings_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'first_run_done': true});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await AccountRepository(db).addAccount(
      name: 'Cash',
      openingBalanceMinor: 10000,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget app() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appSettingsProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const TrackerApp(),
    );
  }

  testWidgets('account shortcut keeps the nav bar and back returns Home',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountLedgerScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('every Home tab shortcut returns to Home on back',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    const shortcuts = <(String, Type)>[
      ('Sales', SalesScreen),
      ('Revenue', ReportsScreen),
      ('Owed to you', MoneyScreen),
      ('Low stock', InventoryScreen),
    ];

    for (final (label, screen) in shortcuts) {
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is StatCard && widget.label == label,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(screen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    }

    await disposeTree(tester);
  });

  testWidgets('back from a pushed sub-screen still returns Home',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await disposeTree(tester);
  });
}

Future<void> disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

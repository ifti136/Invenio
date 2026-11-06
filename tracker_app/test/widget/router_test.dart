import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/app.dart';
import 'package:tracker/features/inventory/inventory_providers.dart';
import 'package:tracker/features/settings/account_repository.dart';
import 'package:tracker/features/settings/settings_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'first_run_done': true});
  });

  testWidgets('renders the 5-tab Clean Ledger shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith((ref) => Stream.value(null)),
          accountBalancesProvider.overrideWith(
            (ref) => Stream.value(const <AccountBalance>[]),
          ),
          lowStockCountProvider.overrideWith((ref) => Stream.value(0)),
        ],
        child: const TrackerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Set up your shop'), findsOneWidget);
  });
}

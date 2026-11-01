import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/app.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/pos_nav_bar.dart';
import 'package:tracker/features/walkthrough/walkthrough_provider.dart';
import 'package:tracker/features/walkthrough/walkthrough_screen.dart';

Widget _buildApp() {
  return const ProviderScope(
    child: TrackerApp(),
  );
}

Future<void> _openShopNameDialog(WidgetTester tester) async {
  await tester.pumpWidget(_buildApp());
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.byType(WalkthroughScreen), findsOneWidget);

  for (var i = 0; i < 4; i++) {
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
  expect(find.text('Enter Shop Name'), findsOneWidget);

  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.byType(GlassTextField), findsOneWidget);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GlassPanel.testOverride = true;
  });

  tearDown(() {
    GlassPanel.testOverride = false;
  });

  testWidgets('first frame is a safe MaterialApp with no exception',
      (tester) async {
    await tester.pumpWidget(_buildApp());

    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('loaded empty prefs shows the walkthrough', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(WalkthroughScreen), findsOneWidget);
  });

  testWidgets('completed prefs shows the app nav', (tester) async {
    SharedPreferences.setMockInitialValues({
      'walkthrough_completed': true,
      'shop_name': 'Test Shop',
    });

    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(WalkthroughScreen), findsNothing);
    expect(find.byType(PosNavBar), findsOneWidget);
  });

  testWidgets('completing the walkthrough swaps the root without exception',
      (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(WalkthroughScreen), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WalkthroughScreen)),
      listen: false,
    );
    await container
        .read(walkthroughProvider.notifier)
        .completeWalkthrough('Test Shop');

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(WalkthroughScreen), findsNothing);
    expect(find.byType(PosNavBar), findsOneWidget);
  });

  testWidgets('keyboard done submits the trimmed shop name', (tester) async {
    await _openShopNameDialog(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WalkthroughScreen)),
      listen: false,
    );

    await tester.enterText(find.byType(GlassTextField), '  My Shop  ');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(container.read(walkthroughProvider).shopName, 'My Shop');
    expect(find.byType(WalkthroughScreen), findsNothing);
    expect(find.byType(PosNavBar), findsOneWidget);
  });

  testWidgets('skip falls back to the app name', (tester) async {
    await _openShopNameDialog(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(WalkthroughScreen)),
      listen: false,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(container.read(walkthroughProvider).shopName, 'Invenio');
    expect(find.byType(PosNavBar), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/app.dart';
import 'package:tracker/core/widgets/pos_nav_bar.dart';

Widget _buildApp() {
  return const ProviderScope(
    child: TrackerApp(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app renders MaterialApp without crashing', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('app navigates to dashboard on launch', (tester) async {
    SharedPreferences.setMockInitialValues({
      'walkthrough_completed': true,
      'shop_name': 'Test Shop',
    });
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(PosNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}

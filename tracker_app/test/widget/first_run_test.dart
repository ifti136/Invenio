import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/theme/app_theme.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/onboarding/first_run_screen.dart';

void main() {
  testWidgets('first run saves a payment source and finishes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    var completed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: FirstRunScreen(onCompleted: () => completed = true),
        ),
      ),
    );

    expect(find.text('Welcome to Invenio'), findsOneWidget);
    expect(find.text('Cash'), findsWidgets);

    await tester.ensureVisible(find.text('Start'));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(completed, true);
    final accounts = await db.select(db.accounts).get();
    expect(accounts.length, 1);
    expect(accounts.single.name, 'Cash');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('first_run_done'), true);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/theme/app_theme.dart';
import 'package:tracker/core/widgets/empty_state.dart';

void main() {
  testWidgets('renders icon, title, message, and primary action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products yet',
            message: 'Add a product with its price and stock.',
            actionLabel: 'Add product',
            actionIcon: Icons.add,
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    expect(find.text('No products yet'), findsOneWidget);
    expect(find.text('Add a product with its price and stock.'), findsOneWidget);

    await tester.tap(find.text('Add product'));
    expect(tapped, true);
  });

  testWidgets('hides the action when no callback is supplied', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: EmptyState(
            title: 'Nothing here',
            message: 'This list is empty.',
            actionLabel: 'Do something',
          ),
        ),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Do something'), findsNothing);
  });
}

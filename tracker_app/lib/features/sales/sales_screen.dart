import 'package:flutter/material.dart';

import '../../core/utils/feedback.dart';
import '../../core/widgets/empty_state.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No sales yet',
        message:
            'Log your first sale to see revenue, profit, and stock changes here.',
        actionLabel: 'New sale',
        actionIcon: Icons.add,
        onAction: () => showComingSoon(context, 'New sale'),
      ),
    );
  }
}

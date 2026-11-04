import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/empty_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'No data yet',
        message:
            'Reports fill in automatically after your first sale.',
        actionLabel: 'Make your first sale',
        actionIcon: Icons.receipt_long_outlined,
        onAction: () => context.go('/sales'),
      ),
    );
  }
}

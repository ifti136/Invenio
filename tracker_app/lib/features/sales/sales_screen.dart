import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import 'sale_flow.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No sales yet',
        message:
            'Log your first sale to see revenue, profit, and stock changes here.',
        actionLabel: 'New sale',
        actionIcon: Icons.add,
        onAction: () => openNewSale(context, ref),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/utils/feedback.dart';
import '../../core/widgets/empty_state.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No products yet',
        message:
            'Add a product with its price and stock to start selling.',
        actionLabel: 'Add product',
        actionIcon: Icons.add,
        onAction: () => showComingSoon(context, 'The product form'),
      ),
    );
  }
}

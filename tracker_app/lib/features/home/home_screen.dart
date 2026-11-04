import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invenio'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: EmptyState(
        icon: Icons.storefront_outlined,
        title: 'Set up your shop',
        message:
            'Add a payment source and your first product to start tracking money.',
        actionLabel: 'Get started',
        actionIcon: Icons.arrow_forward,
        onAction: () => context.go('/settings'),
      ),
    );
  }
}

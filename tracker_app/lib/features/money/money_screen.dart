import 'package:flutter/material.dart';

import '../../core/utils/feedback.dart';
import '../../core/widgets/empty_state.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
      body: EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No accounts yet',
        message:
            'Create Cash, Bank, or a mobile wallet to track where your money lives.',
        actionLabel: 'Add account',
        actionIcon: Icons.add,
        onAction: () => showComingSoon(context, 'The account form'),
      ),
    );
  }
}

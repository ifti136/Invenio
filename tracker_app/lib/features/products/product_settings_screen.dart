import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'widgets/wallet_list_screen.dart';


class ProductSettingsScreen extends ConsumerWidget {
  const ProductSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Product Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassPanel(
              noBlur: true,
              child: Column(
                children: [
                    _SettingsTile(
                      title: 'Wallets',
                      icon: Icons.account_balance_wallet_outlined,
                      onTap: () => context.push('/products/settings/wallets'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _SettingsTile(
                      title: 'Budget Buckets',
                      icon: Icons.layers_outlined,
                      onTap: () => context.push('/products/settings/buckets'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    _SettingsTile(
                      title: 'Currency Settings',
                      icon: Icons.currency_exchange,
                      onTap: () {
                        // TODO: Implement currency settings
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}

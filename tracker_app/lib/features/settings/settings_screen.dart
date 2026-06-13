import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('FINANCE'),
          _buildTile(context, 'Wallet Management', Icons.account_balance_wallet_outlined, '/settings/wallets'),
          _buildTile(context, 'Budget Buckets', Icons.savings_outlined, '/settings/buckets'),
          _buildTile(context, 'Finance Overview & Rules', Icons.analytics_outlined, '/settings/finance'),
          
          const SizedBox(height: 24),
          _buildSection('CONFIGURATION'),
          _buildTile(context, 'Add-On Types', Icons.extension_outlined, '/settings/add-ons'),
          _buildTile(context, 'Currency Settings', Icons.currency_exchange, '/settings/currency'),
          _buildTile(context, 'App Theme', Icons.palette_outlined, '/settings/theme'),
          
          const SizedBox(height: 24),
          _buildSection('SYSTEM'),
          _buildTile(context, 'App Version & Data', Icons.system_update_alt_outlined, '/settings/system'),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        noBlur: true,
        child: ListTile(
          leading: Icon(icon, color: AppColors.accent),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          onTap: () => context.push(route),
        ),
      ),
    );
  }
}

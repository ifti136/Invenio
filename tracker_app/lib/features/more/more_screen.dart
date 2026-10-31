import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/haptic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/section_header.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More', style: AppTextStyles.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, kBottomNavClearance),
        children: [
          const SectionHeader('Selling'),
          const SizedBox(height: AppSpacing.sm),
          _Section(
            children: [
              _MoreRow(
                icon: Icons.receipt_long_outlined,
                title: 'Sales history',
                subtitle: 'View and log sales',
                route: '/sales',
              ),
              _MoreRow(
                icon: Icons.payments_outlined,
                title: 'Expenses',
                subtitle: 'Record and review expenses',
                route: '/expenses',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader('Finance'),
          const SizedBox(height: AppSpacing.sm),
          _Section(
            children: [
              _MoreRow(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallets',
                subtitle: 'Cash and bank balances',
                route: '/settings/wallets',
              ),
              _MoreRow(
                icon: Icons.savings_outlined,
                title: 'Budget buckets',
                subtitle: 'Set aside money for planned spending',
                route: '/settings/buckets',
              ),
              _MoreRow(
                icon: Icons.account_tree_outlined,
                title: 'Finance overview & rules',
                subtitle: 'Allocation rules and history',
                route: '/settings/finance',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader('App'),
          const SizedBox(height: AppSpacing.sm),
          _Section(
            children: [
              _MoreRow(
                icon: Icons.category_outlined,
                title: 'Add-on types',
                subtitle: 'Manage optional sale add-ons',
                route: '/settings/add-ons',
              ),
              _MoreRow(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Theme, currency and system',
                route: '/settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;

  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassPanel(
      noBlur: true,
      radius: AppRadii.card,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: 60,
                color: scheme.onSurfaceVariant.withOpacity(0.12),
              ),
          ],
        ],
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  const _MoreRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentInk = AppColors.accentInkFor(Theme.of(context).brightness);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: () {
        HapticService.trigger(HapticProfile.light);
        context.push(route);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppRadii.input),
                ),
                child: Icon(icon, size: 19, color: accentInk),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

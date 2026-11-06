import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/account_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/stat_card.dart';
import '../inventory/inventory_providers.dart';
import '../money/money_providers.dart';
import '../sales/sale_flow.dart';
import '../settings/account_repository.dart';
import '../settings/settings_providers.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final balances = ref.watch(accountBalancesProvider);
    final shopName = (settings?.shopName ?? '').trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(shopName.isEmpty ? 'Invenio' : shopName),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load your shop',
          message: 'Something went wrong while reading your money and sales.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () {
            ref.invalidate(accountBalancesProvider);
            ref.invalidate(todayStatsProvider);
          },
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'Set up your shop',
              message:
                  'Add a payment source to start tracking money, sales, and stock.',
              actionLabel: 'Add payment source',
              actionIcon: Icons.add,
              onAction: () => context.push('/settings/accounts'),
            );
          }

          final totalMinor = accounts.fold<int>(
            0,
            (sum, item) => sum + item.balanceMinor,
          );
          final dues = ref.watch(duesListProvider).valueOrNull ?? const [];
          final duesMinor = dues.fold<int>(
            0,
            (sum, item) => sum + item.dueMinor,
          );
          final productStats = ref.watch(productStatsProvider).valueOrNull;
          final lowStock = productStats?.lowStock ?? 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl * 2,
            ),
            children: [
              _TotalMoneyCard(
                totalMinor: totalMinor,
                accounts: accounts,
                onAccountTap: (id) => context.go('/money/accounts/$id'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Owed to you',
                      value: Money(duesMinor).format(
                        currencySymbol: ref.watch(currencySymbolProvider),
                      ),
                      icon: Icons.handshake_outlined,
                      tone: StatTone.warning,
                      caption:
                          '${dues.length} customer${dues.length == 1 ? '' : 's'}',
                      onTap: () => context.go('/money?tab=dues'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: 'Low stock',
                      value: '$lowStock item${lowStock == 1 ? '' : 's'}',
                      icon: Icons.warning_amber_outlined,
                      tone: lowStock > 0 ? StatTone.danger : StatTone.neutral,
                      caption: 'See all',
                      onTap: () => context.go('/inventory?filter=low'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Today',
                style: AppTextStyles.title.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TodaySection(
                onNewSale: () => openNewSale(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalMoneyCard extends StatelessWidget {
  final int totalMinor;
  final List<AccountBalance> accounts;
  final ValueChanged<int> onAccountTap;

  const _TotalMoneyCard({
    required this.totalMinor,
    required this.accounts,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total money',
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: MoneyText(
              Money(totalMinor),
              style: AppTextStyles.display.copyWith(color: scheme.onSurface),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in accounts)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: AccountChip(
                      name: item.account.name,
                      balance: Money(item.balanceMinor),
                      onTap: () => onAccountTap(item.account.id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySection extends ConsumerWidget {
  final VoidCallback onNewSale;

  const _TodaySection({required this.onNewSale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayStatsProvider);

    return today.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text("Could not load today's numbers."),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => ref.invalidate(todayStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (stats) {
        final symbol = ref.watch(currencySymbolProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Sales',
                    value: '${stats.salesCount}',
                    icon: Icons.receipt_long_outlined,
                    onTap: () => context.go('/sales'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    label: 'Revenue',
                    value: Money(stats.revenueMinor).format(
                      currencySymbol: symbol,
                    ),
                    icon: Icons.trending_up,
                    tone: StatTone.accent,
                    onTap: () => context.go('/reports'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    label: 'Profit',
                    value: Money(stats.profitMinor).format(
                      currencySymbol: symbol,
                    ),
                    icon: Icons.savings_outlined,
                    tone: stats.profitMinor < 0
                        ? StatTone.danger
                        : StatTone.accent,
                    onTap: () => context.go('/reports'),
                  ),
                ),
              ],
            ),
            if (stats.isEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Text(
                          'No sales yet today. Record one to watch revenue and profit show up here.',
                        ),
                      ),
                      TextButton(
                        onPressed: onNewSale,
                        child: const Text('New sale'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

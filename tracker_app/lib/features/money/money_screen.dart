import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../settings/account_editor.dart';
import '../settings/settings_providers.dart';
import 'dues_view.dart';
import 'expenses_view.dart';
import 'money_providers.dart';

enum MoneyTab { accounts, dues, expenses }

class MoneyScreen extends ConsumerStatefulWidget {
  const MoneyScreen({super.key});

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> {
  MoneyTab _tab = MoneyTab.accounts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
      floatingActionButton: _tab == MoneyTab.expenses
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/money/expenses/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<MoneyTab>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: MoneyTab.accounts,
                    label: Text('Accounts'),
                  ),
                  ButtonSegment(
                    value: MoneyTab.dues,
                    label: Text('Dues'),
                  ),
                  ButtonSegment(
                    value: MoneyTab.expenses,
                    label: Text('Expenses'),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (selection) {
                  setState(() => _tab = selection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              MoneyTab.accounts => const _AccountsView(),
              MoneyTab.dues => const DuesView(),
              MoneyTab.expenses => const ExpensesView(),
            },
          ),
        ],
      ),
    );
  }
}

class _AccountsView extends ConsumerWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(accountBalancesProvider);

    return balances.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load accounts',
        message: 'Something went wrong while reading your money.',
        actionLabel: 'Retry',
        actionIcon: Icons.refresh,
        onAction: () => ref.invalidate(accountBalancesProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No accounts yet',
            message:
                'Add Cash, a bank account, or a mobile wallet to track where your money lives.',
            actionLabel: 'Add account',
            actionIcon: Icons.add,
            onAction: () => showAccountEditorDialog(context),
          );
        }

        final total = ref.watch(totalMoneyMinorProvider);
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xxl * 2,
          ),
          children: [
            _TotalMoneyCard(totalMinor: total),
            const SizedBox(height: AppSpacing.lg),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () =>
                        context.push('/money/accounts/${item.account.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              item.account.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          MoneyText(
                            Money(item.balanceMinor),
                            style: AppTextStyles.title.copyWith(
                              color: item.balanceMinor < 0
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/money/transfer'),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Transfer'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/money/expenses/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add expense'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TotalMoneyCard extends StatelessWidget {
  final int totalMinor;

  const _TotalMoneyCard({required this.totalMinor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total money',
            style: AppTextStyles.label.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MoneyText(
            Money(totalMinor),
            style: AppTextStyles.display.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

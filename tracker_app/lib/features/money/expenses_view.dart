import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_period.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/stat_card.dart';
import '../settings/settings_providers.dart';
import 'expense_repository.dart';
import 'money_providers.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  DatePeriod _period = DatePeriod.thisMonth;
  int _categoryId = 0;

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseListProvider);
    final categories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];

    return expenses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load expenses',
        message: 'Something went wrong while reading your expenses.',
        actionLabel: 'Retry',
        actionIcon: Icons.refresh,
        onAction: () => ref.invalidate(expenseListProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_outlined,
            title: 'No expenses yet',
            message:
                'Log ads, delivery, packaging, or any other shop cost to see your true profit.',
            actionLabel: 'Add expense',
            actionIcon: Icons.add,
            onAction: () => context.push('/money/expenses/new'),
          );
        }

        final filtered = _apply(items);
        final monthly = items
            .where(
              (item) => DatePeriod.thisMonth.contains(
                DateTime.fromMillisecondsSinceEpoch(item.expense.date),
              ),
            )
            .fold<int>(0, (sum, item) => sum + item.expense.amountMinor);

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              sliver: SliverList.list(
                children: [
                  StatCard(
                    label: 'This month',
                    value: Money(monthly).format(
                      currencySymbol: ref.watch(currencySymbolProvider),
                    ),
                    icon: Icons.calendar_month_outlined,
                    tone: StatTone.accent,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _periodChip(),
                        const SizedBox(width: AppSpacing.sm),
                        FilterChip(
                          label: const Text('All categories'),
                          selected: _categoryId == 0,
                          onSelected: (_) => setState(() => _categoryId = 0),
                        ),
                        for (final category in categories) ...[
                          const SizedBox(width: AppSpacing.sm),
                          FilterChip(
                            label: Text(category.name),
                            selected: _categoryId == category.id,
                            onSelected: (_) =>
                                setState(() => _categoryId = category.id),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'No expenses match',
                  message:
                      'Try another period or category, or clear the filters.',
                  actionLabel: 'Clear filters',
                  actionIcon: Icons.filter_alt_off_outlined,
                  onAction: () => setState(() {
                    _period = DatePeriod.allTime;
                    _categoryId = 0;
                  }),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxl * 2,
                ),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ExpenseTile(item: item),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _periodChip() {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<DatePeriod>(
      tooltip: _period.label,
      initialValue: _period,
      onSelected: (value) => setState(() => _period = value),
      itemBuilder: (context) => [
        for (final period in DatePeriod.values)
          PopupMenuItem(value: period, child: Text(period.label)),
      ],
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_period.label),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
        backgroundColor: scheme.surfaceContainerLow,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }

  List<ExpenseItem> _apply(List<ExpenseItem> items) {
    return items.where((item) {
      if (_categoryId != 0 && item.expense.categoryId != _categoryId) {
        return false;
      }
      final date = DateTime.fromMillisecondsSinceEpoch(item.expense.date);
      return _period.contains(date);
    }).toList();
  }
}

class _ExpenseTile extends ConsumerWidget {
  final ExpenseItem item;

  const _ExpenseTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat('MMM d, yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(item.expense.date),
    );
    final note = item.expense.note;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () => context.push('/money/expenses/${item.expense.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.errorContainer,
                foregroundColor: scheme.onErrorContainer,
                child: const Icon(Icons.receipt_outlined, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.categoryName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$date · ${item.accountName}',
                      style: AppTextStyles.body.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (note != null && note.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MoneyText(
                Money(item.expense.amountMinor),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

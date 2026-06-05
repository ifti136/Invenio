import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/empty_state.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/core/extensions/db_extensions.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/expenses/expense_provider.dart';
import 'package:tracker/features/expenses/expense_repository.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  ExpenseFilter _filter = const ExpenseFilter();

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(expenseListProvider);
    final filteredAsync = ref.watch(filteredExpenseListProvider(_filter));
    final scheme = Theme.of(context).colorScheme;

    final stats = computeExpenseStats(
      filteredAsync.value ?? const [],
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text(
              'Expenses',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            actions: [
              IconButton(
                tooltip: 'Add expense',
                onPressed: () => context.push('/expenses/add'),
                icon: const Icon(Icons.add_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: _DateFilterBar(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                noBlur: true,
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'Entries',
                        value: stats.count.toString(),
                        color: scheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Total',
                        value: formatMoney(stats.total),
                        color: AppColors.warning,
                        small: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (filteredAsync.isLoading || allAsync.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if ((filteredAsync.value ?? []).isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.wallet_outlined,
                title: 'No expenses yet',
                message: 'Tap the + button to add your first expense.',
              ),
            )
          else
            SliverList.separated(
              itemCount: (filteredAsync.value ?? []).length,
              separatorBuilder: (_, __) => Divider(
                height: 0,
                thickness: 0.5,
                color: scheme.onSurfaceVariant.withOpacity(0.12),
                indent: 70,
              ),
              itemBuilder: (_, i) {
                final e = (filteredAsync.value ?? [])[i];
                return _ExpenseRow(
                  expense: e,
                  onEdit: () => context.push('/expenses/${e.id}/edit'),
                  onDelete: () => _confirmDelete(e),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: kBottomNavClearance)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Expense expense) async {
    final result = await showGlassDialog<bool>(
      context: context,
      title: 'Delete expense?',
      message:
          'This removes the ${ExpenseCategoryX.fromKey(expense.category).label.toLowerCase()} expense of ${formatMoney(expense.amount)} from ${formatDate(expense.dateAsDateTime)}.',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );
    if (result != true) return;
    await ref.read(expenseRepositoryProvider).delete(expense.id);
    if (!mounted) return;
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ExpenseRow({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategoryX.fromKey(expense.category);
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: AppColors.danger)),
        ),
      ],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withOpacity(0.12),
          child: Icon(
            _categoryIcon(category),
            color: scheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          category.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          expense.note != null && expense.note!.isNotEmpty
              ? expense.note!
              : formatDate(expense.dateAsDateTime),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatMoney(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.warning,
              ),
            ),
            if (expense.note != null && expense.note!.isNotEmpty)
              Text(
                formatDate(expense.dateAsDateTime),
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(ExpenseCategory c) => switch (c) {
        ExpenseCategory.ads => Icons.campaign_outlined,
        ExpenseCategory.delivery => Icons.local_shipping_outlined,
        ExpenseCategory.packaging => Icons.inventory_outlined,
        ExpenseCategory.misc => Icons.more_horiz_outlined,
      };
}

class _DateFilterBar extends StatelessWidget {
  final ExpenseFilter filter;
  final ValueChanged<ExpenseFilter> onChanged;
  const _DateFilterBar({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        noBlur: true,
        child: _ChipRow(
          label: 'Period',
          children: [
            for (final preset in dateRangePresets()) ...[
              _Chip(
                label: preset.label,
                selected: _matchesPreset(preset),
                onTap: () => onChanged(
                    filter.copyWith(from: preset.from, to: preset.to)),
              ),
              const SizedBox(width: 6),
            ],
            _Chip(
              label: 'Custom…',
              selected: _isCustomRange(),
              onTap: () => _pickCustomRange(context),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesPreset(DateRangePreset p) {
    if (filter.from == null) return p.label == 'All time';
    return filter.from!.year == p.from.year &&
        filter.from!.month == p.from.month &&
        filter.from!.day == p.from.day &&
        filter.to == null &&
        p.to == null;
  }

  bool _isCustomRange() {
    if (filter.from == null || filter.to == null) return false;
    return !dateRangePresets().any((p) => _matchesPreset(p));
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filter.from != null && filter.to != null
          ? DateTimeRange(start: filter.from!, end: filter.to!)
          : null,
    );
    if (picked != null) {
      onChanged(filter.copyWith(from: picked.start, to: picked.end));
    }
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _ChipRow({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: children),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withOpacity(0.18)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? scheme.primary.withOpacity(0.5)
                : scheme.onSurfaceVariant.withOpacity(0.18),
            width: 0.6,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: small ? 13 : 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

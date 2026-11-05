import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../sales/sale_flow.dart';
import 'dues_repository.dart';
import 'money_providers.dart';

class DuesView extends ConsumerWidget {
  const DuesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dues = ref.watch(duesListProvider);

    return dues.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load dues',
        message: 'Something went wrong while reading what customers owe.',
        actionLabel: 'Retry',
        actionIcon: Icons.refresh,
        onAction: () => ref.invalidate(duesListProvider),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.handshake_outlined,
            title: 'No dues yet',
            message:
                'When you sell on credit, what customers owe will appear here.',
            actionLabel: 'Record a sale',
            actionIcon: Icons.add,
            onAction: () => openNewSale(context, ref),
          );
        }

        final total = ref.watch(duesTotalMinorProvider);
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xxl * 2,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.hero),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owed to you',
                    style: AppTextStyles.label.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  MoneyText(
                    Money(total),
                    style: AppTextStyles.display.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final due in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _DueTile(due: due),
              ),
          ],
        );
      },
    );
  }
}

class _DueTile extends StatelessWidget {
  final CustomerDue due;

  const _DueTile({required this.due});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = _daysSince(due.oldestCreatedAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () => context.push('/money/dues/${due.customerId}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
                child: Text(
                  due.name.trim().isEmpty
                      ? '?'
                      : due.name.trim().substring(0, 1).toUpperCase(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      due.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (due.phone != null && due.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        due.phone!,
                        style: AppTextStyles.body.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'oldest due: $days ${days == 1 ? 'day' : 'days'}',
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    Money(due.dueMinor),
                    style: AppTextStyles.title.copyWith(color: scheme.error),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(Icons.chevron_right, color: scheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _daysSince(int milliseconds) {
  final then = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(then.year, then.month, then.day);
  final days = today.difference(day).inDays;
  return days < 0 ? 0 : days;
}

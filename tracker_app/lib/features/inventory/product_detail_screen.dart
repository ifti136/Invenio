import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../sales/quick_sell_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/stock_badge.dart';
import '../../db/app_database.dart';
import 'inventory_providers.dart';
import 'restock_sheet.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(productId));

    return product.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load product',
          message: 'Something went wrong while reading this product.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(productProvider(productId)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product')),
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Product not found',
              message: 'It may have been removed from this shop.',
              actionLabel: 'Back to inventory',
              actionIcon: Icons.arrow_back,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }
        return _ProductDetailBody(product: item);
      },
    );
  }
}

class _ProductDetailBody extends ConsumerWidget {
  final Product product;

  const _ProductDetailBody({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(productMovementsProvider(product.id));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            tooltip: 'Edit product',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/inventory/${product.id}/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          label: 'Stock',
                          child: Row(
                            children: [
                              Text(
                                '${product.stock}',
                                style: AppTextStyles.headline,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              StockBadge(
                                stock: product.stock,
                                lowStockAt: product.lowStockAt,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _Metric(
                          label: 'Price',
                          child: MoneyText(
                            Money(product.priceMinor),
                            style: AppTextStyles.headline,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _Metric(
                          label: 'Cost',
                          child: MoneyText(
                            Money(product.costMinor),
                            style: AppTextStyles.headline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Alerts at ${product.lowStockAt} or fewer',
                    style: AppTextStyles.label.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (product.note != null && product.note!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(product.note!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _restock(context, ref),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Restock'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => startQuickSell(context, ref, product),
                  icon: const Icon(Icons.sell_outlined),
                  label: const Text('Sell'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Activity', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          movements.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      'Could not load activity.',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(
                        productMovementsProvider(product.id),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SizedBox(
                  height: 280,
                  child: EmptyState(
                    icon: Icons.history,
                    title: 'No activity yet',
                    message: 'Restocks, sales, and stock changes appear here.',
                    actionLabel: 'Restock',
                    actionIcon: Icons.add_box_outlined,
                    onAction: () => _restock(context, ref),
                  ),
                );
              }
              return Column(
                children: [
                  for (final movement in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _MovementTile(movement: movement),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _restock(BuildContext context, WidgetRef ref) async {
    final saved = await showRestockSheet(context, product);
    if (!context.mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock added.')),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final Widget child;

  const _Metric({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _MovementTile extends ConsumerWidget {
  final StockMovement movement;

  const _MovementTile({required this.movement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isIn = movement.qty > 0;
    final color = isIn ? scheme.primary : scheme.error;
    final date = DateFormat('MMM d, h:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(movement.createdAt),
    );
    final details = [
      date,
      if (movement.note != null && movement.note!.isNotEmpty) movement.note!,
    ].join(' · ');

    return Card(
      child: ListTile(
        leading: Icon(
          isIn ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: color,
        ),
        title: Text(_title()),
        subtitle: Text(details),
        trailing: movement.unitCostMinor == null
            ? null
            : MoneyText(
                Money(movement.unitCostMinor!),
                style: AppTextStyles.body.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  String _title() {
    final qty = movement.qty.abs();
    switch (movement.type) {
      case 'sale':
        return 'Sale ×$qty';
      case 'restock':
        return 'Restock +$qty';
      case 'initial':
        return 'Initial stock +$qty';
      case 'adjustment':
        return 'Adjustment ${movement.qty >= 0 ? '+' : '−'}$qty';
      default:
        return '${movement.type} ${movement.qty >= 0 ? '+' : '−'}$qty';
    }
  }
}

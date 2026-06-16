import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/empty_state.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/products/widgets/restock_sheet.dart';
import 'package:tracker/features/products/widgets/sale_list_item.dart';
import 'package:tracker/features/products/widgets/stock_badge.dart';
import 'package:tracker/features/products/widgets/stock_movement_item.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(id));
    final movementsAsync = ref.watch(productMovementsProvider(id));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          HapticWrapper(
            profile: HapticProfile.light,
            child: IconButton(
              tooltip: 'Edit',
              onPressed: () => context.push('/products/$id/edit'),
              icon: const Icon(Icons.edit_rounded),
            ),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) {
          if (p == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Product not found',
              message: 'It may have been deleted.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              GlassPanel(
                padding: const EdgeInsets.all(18),
                noBlur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    if (p.note != null && p.note!.isNotEmpty)
                      Text(
                        p.note!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            label: 'Cost',
                            value: formatMoney(p.costPrice),
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Stock',
                            value: formatQuantity(p.stock.toDouble()),
                          ),
                        ),
                        Expanded(
                          child: _Metric(
                            label: 'Alert at',
                            value: p.lowStockThreshold.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        StockBadge(
                          stock: p.stock,
                          threshold: p.lowStockThreshold,
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () async {
                            final ok = await RestockSheet.show(
                              context,
                              productId: p.id,
                              productName: p.name,
                              currentStock: p.stock,
                            );
                            if (ok == true && context.mounted) {
                              ref.invalidate(productListProvider);
                              ref.invalidate(productByIdProvider(id));
                              ref.invalidate(dashboardProvider);
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Restock'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent sales',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              _RecentSalesPanel(productId: id, productName: p.name),
              const SizedBox(height: 16),
              Text(
                'Stock movements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              movementsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('Error: $e')),
                ),
                data: (movements) {
                  if (movements.isEmpty) {
                    return const EmptyState(
                      icon: Icons.timeline_outlined,
                      title: 'No movements yet',
                      message: 'Stock changes will appear here.',
                    );
                  }
                  return GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    noBlur: true,
                    child: Column(
                      children: [
                        for (var i = 0; i < movements.length; i++) ...[
                          StockMovementItem(movement: movements[i]),
                          if (i < movements.length - 1)
                            Divider(
                              height: 0,
                              thickness: 0.5,
                              color: scheme.onSurfaceVariant.withOpacity(0.12),
                              indent: 64,
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _RecentSalesPanel extends ConsumerWidget {
  final int productId;
  final String productName;
  const _RecentSalesPanel({
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(productSalesProvider(productId));
    final scheme = Theme.of(context).colorScheme;
    return salesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Error: $e')),
      ),
      data: (sales) {
        if (sales.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No sales yet',
            message: 'Log a sale from the Sales tab.',
          );
        }
        return GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 6),
          noBlur: true,
          child: Column(
            children: [
              for (var i = 0; i < sales.length; i++) ...[
                SaleListItem(sale: sales[i], productName: productName),
                if (i < sales.length - 1)
                  Divider(
                    height: 0,
                    thickness: 0.5,
                    color: scheme.onSurfaceVariant.withOpacity(0.12),
                    indent: 70,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

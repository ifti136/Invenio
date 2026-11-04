import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/stock_badge.dart';
import '../../db/app_database.dart';
import '../inventory/inventory_providers.dart';
import 'quick_sell_sheet.dart';

Future<void> openNewSale(BuildContext context, WidgetRef ref) async {
  final product = await showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ProductPickerSheet(
      onAddProduct: () {
        if (context.mounted) context.push('/inventory/new');
      },
    ),
  );
  if (product == null || !context.mounted) return;
  await startQuickSell(context, ref, product);
}

class ProductPickerSheet extends ConsumerStatefulWidget {
  final VoidCallback onAddProduct;

  const ProductPickerSheet({super.key, required this.onAddProduct});

  @override
  ConsumerState<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<ProductPickerSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text('Choose a product', style: AppTextStyles.title),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SearchBar(
              controller: _search,
              hintText: 'Search products',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load products',
                message: 'Something went wrong while reading your inventory.',
                actionLabel: 'Retry',
                actionIcon: Icons.refresh,
                onAction: () => ref.invalidate(productsProvider),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No products yet',
                    message: 'Add a product before starting a sale.',
                    actionLabel: 'Add product',
                    actionIcon: Icons.add,
                    onAction: () {
                      Navigator.of(context).pop();
                      widget.onAddProduct();
                    },
                  );
                }
                final query = _query.trim().toLowerCase();
                final filtered = items
                    .where(
                      (product) =>
                          query.isEmpty ||
                          product.name.toLowerCase().contains(query),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No products match',
                    message: 'Try a different search.',
                    actionLabel: 'Clear search',
                    actionIcon: Icons.close,
                    onAction: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Row(
                          children: [
                            MoneyText(
                              Money(product.priceMinor),
                              style: AppTextStyles.body.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            StockBadge(
                              stock: product.stock,
                              lowStockAt: product.lowStockAt,
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pop(product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

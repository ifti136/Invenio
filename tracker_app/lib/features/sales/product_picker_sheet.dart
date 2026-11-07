import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/stock_badge.dart';
import '../../db/app_database.dart';
import '../inventory/inventory_providers.dart';
import 'sale_providers.dart';

enum _PickerFilter { all, recent, top }

Future<List<Product>> showProductPicker(
  BuildContext context, {
  required VoidCallback onAddProduct,
}) async {
  final result = await showModalBottomSheet<List<Product>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ProductPickerSheet(onAddProduct: onAddProduct),
  );
  return result ?? const [];
}

class ProductPickerSheet extends ConsumerStatefulWidget {
  final VoidCallback onAddProduct;

  const ProductPickerSheet({super.key, required this.onAddProduct});

  @override
  ConsumerState<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<ProductPickerSheet> {
  final _search = TextEditingController();
  final _selected = <int, Product>{};
  String _query = '';
  _PickerFilter _filter = _PickerFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final recent =
        ref.watch(recentProductsProvider).valueOrNull ?? const <Product>[];
    final top =
        ref.watch(topSoldProductsProvider).valueOrNull ?? const <Product>[];
    final recentIds = recent.map((product) => product.id).toSet();
    final topIds = top.map((product) => product.id).toSet();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
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
            child: Text('Add items', style: AppTextStyles.title),
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
          const SizedBox(height: AppSpacing.sm),
          _chips(recent, top),
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
                final filtered = _apply(items, recentIds, topIds);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No products match',
                    message: 'Try a different search or filter.',
                    actionLabel: 'Clear filters',
                    actionIcon: Icons.close,
                    onAction: () {
                      _search.clear();
                      setState(() {
                        _query = '';
                        _filter = _PickerFilter.all;
                      });
                    },
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final selected = _selected.containsKey(product.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Card(
                        child: CheckboxListTile(
                          value: selected,
                          onChanged: (_) => _toggle(product),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(product.name),
                          subtitle: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              MoneyText(
                                Money(product.priceMinor),
                                style: AppTextStyles.body.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              StockBadge(
                                stock: product.stock,
                                lowStockAt: product.lowStockAt,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FilledButton(
                onPressed: _selected.isEmpty ? null : _addSelected,
                child: Text(
                  _selected.isEmpty
                      ? 'Add'
                      : 'Add ${_selected.length} item${_selected.length == 1 ? '' : 's'}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chips(List<Product> recent, List<Product> top) {
    if (recent.isEmpty && top.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: const Text('All'),
              selected: _filter == _PickerFilter.all,
              onSelected: (_) => setState(() => _filter = _PickerFilter.all),
            ),
          ),
          if (recent.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                label: const Text('Recent'),
                selected: _filter == _PickerFilter.recent,
                onSelected: (_) =>
                    setState(() => _filter = _PickerFilter.recent),
              ),
            ),
          if (top.isNotEmpty)
            FilterChip(
              label: const Text('Top sold'),
              selected: _filter == _PickerFilter.top,
              onSelected: (_) => setState(() => _filter = _PickerFilter.top),
            ),
        ],
      ),
    );
  }

  List<Product> _apply(
    List<Product> items,
    Set<int> recentIds,
    Set<int> topIds,
  ) {
    final query = _query.trim().toLowerCase();
    var source = items;
    if (_filter == _PickerFilter.recent) {
      source =
          items.where((product) => recentIds.contains(product.id)).toList();
    } else if (_filter == _PickerFilter.top) {
      source = items.where((product) => topIds.contains(product.id)).toList();
    }
    if (query.isEmpty) return source;
    return source
        .where((product) => product.name.toLowerCase().contains(query))
        .toList();
  }

  void _toggle(Product product) {
    setState(() {
      if (_selected.containsKey(product.id)) {
        _selected.remove(product.id);
      } else {
        _selected[product.id] = product;
      }
    });
  }

  void _addSelected() {
    Navigator.of(context).pop(_selected.values.toList());
  }
}

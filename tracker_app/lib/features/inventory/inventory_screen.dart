import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../sales/quick_sell_sheet.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/product_tile.dart';
import '../../core/widgets/stat_card.dart';
import '../../db/app_database.dart';
import '../settings/settings_providers.dart';
import 'inventory_providers.dart';
import 'product_repository.dart';

enum _InventoryFilter { all, low, out, archived }

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _search = TextEditingController();
  _InventoryFilter _filter = _InventoryFilter.all;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load products',
          message: 'Something went wrong while reading your inventory.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () {
            ref.invalidate(allProductsProvider);
            ref.invalidate(productStatsProvider);
          },
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message:
                  'Add a product with its price and stock to start selling.',
              actionLabel: 'Add product',
              actionIcon: Icons.add,
              onAction: () => context.push('/inventory/new'),
            );
          }

          final filtered = _applyFilter(items);
          final stats =
              ref.watch(productStatsProvider).valueOrNull ?? ProductStats.empty;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                sliver: SliverList.list(
                  children: [
                    SearchBar(
                      controller: _search,
                      hintText: 'Search products',
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_query.isNotEmpty)
                          IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                      ],
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final filter in _InventoryFilter.values)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: FilterChip(
                                label: Text(_filterLabel(filter)),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _stats(stats),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No products match',
                    message: _query.isNotEmpty
                        ? 'Try a different search or clear the filters.'
                        : 'No products in this filter right now.',
                    actionLabel: 'Clear filters',
                    actionIcon: Icons.filter_alt_off_outlined,
                    onAction: () {
                      _search.clear();
                      setState(() {
                        _query = '';
                        _filter = _InventoryFilter.all;
                      });
                    },
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
                      final product = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: ProductTile(
                          name: product.name,
                          price: Money(product.priceMinor),
                          stock: product.stock,
                          lowStockAt: product.lowStockAt,
                          subtitle: _subtitle(product),
                          onTap: () => context.push('/inventory/${product.id}'),
                          onSell: () => startQuickSell(context, ref, product),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _stats(ProductStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: width,
              child: StatCard(
                label: 'Products',
                value: '${stats.products}',
                icon: Icons.inventory_2_outlined,
              ),
            ),
            SizedBox(
              width: width,
              child: StatCard(
                label: 'Low stock',
                value: '${stats.lowStock}',
                icon: Icons.warning_amber_outlined,
                tone: StatTone.warning,
              ),
            ),
            SizedBox(
              width: width,
              child: StatCard(
                label: 'Out of stock',
                value: '${stats.outOfStock}',
                icon: Icons.error_outline,
                tone: StatTone.danger,
              ),
            ),
            SizedBox(
              width: width,
              child: StatCard(
                label: 'Stock value',
                value: Money(stats.stockValueMinor).format(
                  currencySymbol: ref.watch(currencySymbolProvider),
                ),
                icon: Icons.savings_outlined,
                tone: StatTone.accent,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Product> _applyFilter(List<Product> items) {
    final query = _query.trim().toLowerCase();
    return items.where((product) {
      final matchesQuery =
          query.isEmpty || product.name.toLowerCase().contains(query);
      if (!matchesQuery) return false;
      switch (_filter) {
        case _InventoryFilter.all:
          return !product.archived;
        case _InventoryFilter.low:
          return !product.archived &&
              product.stock > 0 &&
              product.stock <= product.lowStockAt;
        case _InventoryFilter.out:
          return !product.archived && product.stock <= 0;
        case _InventoryFilter.archived:
          return product.archived;
      }
    }).toList();
  }

  String _filterLabel(_InventoryFilter filter) {
    switch (filter) {
      case _InventoryFilter.all:
        return 'All';
      case _InventoryFilter.low:
        return 'Low stock';
      case _InventoryFilter.out:
        return 'Out';
      case _InventoryFilter.archived:
        return 'Archived';
    }
  }

  String _subtitle(Product product) {
    final symbol = ref.read(currencySymbolProvider);
    final cost = Money(product.costMinor).format(currencySymbol: symbol);
    return 'Cost $cost · ${product.stock} left';
  }
}

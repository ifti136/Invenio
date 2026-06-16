import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/empty_state.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/products/widgets/product_tile.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(filteredProductListProvider);
    final all = ref.watch(productListProvider).value ?? const [];
    final stats = computeProductStats(all);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text(
              'Products',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () {
                  HapticService.trigger(HapticProfile.light);
                  context.push('/settings');
                },
                icon:
                    const Icon(Icons.settings_outlined, color: Colors.white70),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Add product',
                onPressed: () {
                  HapticService.trigger(HapticProfile.medium);
                  context.push('/products/add');
                },
                icon: const Icon(Icons.add_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: GlassPanel(
                radius: 20,
                noBlur: true,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        label: 'Products',
                        value: stats.totalProducts.toString(),
                        color: scheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _StatPill(
                        label: 'Low',
                        value: stats.lowStock.toString(),
                        color: AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _StatPill(
                        label: 'Out',
                        value: stats.outOfStock.toString(),
                        color: AppColors.danger,
                      ),
                    ),
                    Expanded(
                      child: _StatPill(
                        label: 'Stock value',
                        value: formatMoney(stats.totalStockValue),
                        color: AppColors.success,
                        small: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  for (final f in StockFilter.values) ...[
                    _FilterChip(
                      label: _chipLabel(f),
                      selected: ref.watch(productFilterProvider).stock == f,
                      onSelected: () => ref
                          .read(productFilterProvider.notifier)
                          .setStockFilter(f),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: GlassTextField(
                controller: _search,
                hint: 'Search by name…',
                prefixIcon: Icons.search_rounded,
                onChanged: (v) {
                  HapticService.trigger(HapticProfile.light);
                  ref.read(productFilterProvider.notifier).setSearch(v);
                },
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No products yet',
                message: 'Tap the + button to add your first product.',
              ),
            )
          else
            SliverList.separated(
              itemBuilder: (_, i) => ProductTile(
                product: products[i],
                onTap: () {
                  HapticService.trigger(HapticProfile.light);
                  context.push('/products/${products[i].id}');
                },
              ),
              separatorBuilder: (_, __) => Divider(
                height: 0,
                thickness: 0.5,
                color: scheme.onSurfaceVariant.withOpacity(0.12),
                indent: 70,
              ),
              itemCount: products.length,
            ),
          const SliverToBoxAdapter(
              child: SizedBox(height: kBottomNavClearance)),
        ],
      ),
    );
  }

  String _chipLabel(StockFilter f) {
    switch (f) {
      case StockFilter.all:
        return 'All';
      case StockFilter.low:
        return 'Low stock';
      case StockFilter.out:
        return 'Out of stock';
    }
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;
  const _StatPill({
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? scheme.primary : scheme.onSurface,
        ),
      ),
      selected: selected,
      onSelected: (_) {
        HapticService.trigger(HapticProfile.light);
        onSelected();
      },
      side: BorderSide(
        color: selected
            ? scheme.primary.withOpacity(0.5)
            : scheme.onSurfaceVariant.withOpacity(0.18),
        width: 0.6,
      ),
    );
  }
}

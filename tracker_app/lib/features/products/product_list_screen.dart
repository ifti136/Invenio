import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/theme/app_tokens.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/category_chip_row.dart';
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
    final filter = ref.watch(productFilterProvider);
    final stats = computeProductStats(all);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true,
            title: const Text(
              'Products',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            actions: [
              IconButton(
                tooltip: 'Add product',
                onPressed: () {
                  HapticService.trigger(HapticProfile.medium);
                  context.push('/products/add');
                },
                icon: Icon(
                  Icons.add_rounded,
                  color: AppColors.accentInkFor(Theme.of(context).brightness),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: GlassPanel(
                radius: AppRadii.card,
                noBlur: true,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCell(
                        label: 'Products',
                        value: stats.totalProducts.toString(),
                        tone: _StatTone.accent,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        label: 'Low',
                        value: stats.lowStock.toString(),
                        tone: _StatTone.warning,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        label: 'Out',
                        value: stats.outOfStock.toString(),
                        tone: _StatTone.danger,
                      ),
                    ),
                    Expanded(
                      child: _StatCell(
                        label: 'Stock value',
                        value: formatMoney(stats.totalStockValue),
                        tone: _StatTone.accent,
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
              child: CategoryChipRow(
                children: [
                  for (final f in StockFilter.values)
                    AppFilterChip(
                      label: _chipLabel(f),
                      selected: filter.stock == f,
                      onTap: () => ref
                          .read(productFilterProvider.notifier)
                          .setStockFilter(f),
                    ),
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
            SliverFillRemaining(
              hasScrollBody: false,
              child: all.isEmpty
                  ? EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products yet',
                      message: 'Add your first product to start selling.',
                      actionLabel: 'Add product',
                      onAction: () {
                        HapticService.trigger(HapticProfile.medium);
                        context.push('/products/add');
                      },
                    )
                  : EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No products match this filter',
                      message: 'Try All or clear the search.',
                      actionLabel: 'Clear filters',
                      onAction: () {
                        HapticService.trigger(HapticProfile.light);
                        _search.clear();
                        ref.read(productFilterProvider.notifier).clear();
                      },
                    ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList.builder(
                itemBuilder: (_, i) => ProductTile(
                  product: products[i],
                  onTap: () {
                    HapticService.trigger(HapticProfile.light);
                    context.push('/products/${products[i].id}');
                  },
                ),
                itemCount: products.length,
              ),
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

enum _StatTone { accent, warning, danger }

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final _StatTone tone;
  final bool small;

  const _StatCell({
    required this.label,
    required this.value,
    required this.tone,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (tone) {
      _StatTone.accent =>
        isDark ? AppColors.accentInkDark : AppColors.accentInkLight,
      _StatTone.warning =>
        isDark ? AppColors.warning : AppColors.warningInkLight,
      _StatTone.danger => isDark ? AppColors.danger : AppColors.dangerInkLight,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyles.title.copyWith(
              fontSize: small ? 13 : 18,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

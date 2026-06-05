import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/products/widgets/stock_badge.dart';
import 'package:tracker/features/sales/sale_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/widgets/discount_sheet.dart';
import 'package:tracker/features/sales/widgets/quick_sell_sheet.dart';
import 'package:tracker/features/products/widgets/sale_list_item.dart';

class SaleListScreen extends ConsumerWidget {
  const SaleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productListProvider).value ?? [];
    final active = products.where((p) => p.stock > 0).toList();
    final outOfStock = products.where((p) => p.stock <= 0).toList();

    final allSales = ref.watch(saleListProvider).value ?? [];
    final discountedSales = allSales.where((s) => s.isDiscounted).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text(
              'Sales',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            actions: [
              IconButton(
                tooltip: 'Log sale',
                onPressed: () => context.push('/sales/add'),
                icon: const Icon(Icons.add_rounded, color: AppColors.accent),
              ),
              const SizedBox(width: 4),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Active Products',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverToBoxAdapter(child: SizedBox())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ProductSellCard(product: active[i]),
                childCount: active.length,
              ),
            ),
          if (outOfStock.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ProductSellCard(product: outOfStock[i]),
                childCount: outOfStock.length,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GlassPanel(
                padding: const EdgeInsets.all(12),
                noBlur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => showDiscountSheet(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.local_offer_outlined,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Log discounted sale',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                    if (discountedSales.isNotEmpty) ...[
                      const Divider(height: 16),
                      ...discountedSales.take(5).map((s) => _DiscountedSaleRow(sale: s)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GlassPanel(
                padding: const EdgeInsets.all(12),
                noBlur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Recent Sales',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (allSales.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No sales yet',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      ...allSales.take(5).map((s) => SaleListItem(
                        sale: s,
                        productName: products.where((p) => p.id == s.productId).firstOrNull?.name,
                      )),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: OutlinedButton.icon(
                onPressed: () => context.push('/sales/add'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Full sale form'),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: kBottomNavClearance)),
        ],
      ),
    );
  }
}

class _ProductSellCard extends ConsumerWidget {
  final Product product;
  const _ProductSellCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final inStock = product.stock > 0;
    final lastPriceAsync = ref.watch(lastSellingPriceProvider(product.id));
    final lastPrice = lastPriceAsync.valueOrNull;
    final estProfit = lastPrice != null ? lastPrice - product.costPrice : null;

    return GlassPanel(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(14),
      isFrostedGlass: inStock,
      child: Opacity(
        opacity: inStock ? 1 : 0.45,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      StockBadge(
                        stock: product.stock,
                        threshold: product.lowStockThreshold,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cost ${formatMoney(product.costPrice)}  |  ${estProfit != null ? 'Est. profit ${estProfit >= 0 ? '+' : ''}${formatMoney(estProfit)}' : 'Last: ${lastPrice != null ? formatMoney(lastPrice) : '—'}'}/unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: inStock
                  ? () => _sell(context, ref)
                  : null,
              icon: const Icon(Icons.point_of_sale_rounded, size: 18),
              label: const Text('Sell'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sell(BuildContext context, WidgetRef ref) async {
    final lastSale = await ref
        .read(saleRepositoryProvider)
        .lastSellingPriceFor(product.id);
    if (!context.mounted) return;
    showQuickSellSheet(
      context,
      product: product,
      lastSellingPrice: lastSale?.sellingPrice,
    );
  }
}

class _DiscountedSaleRow extends StatelessWidget {
  final Sale sale;
  const _DiscountedSaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sale.quantity} × ${formatMoney(sale.sellingPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (sale.normalPrice != null)
                  Text(
                    'Normal ${formatMoney(sale.normalPrice!)} → Discount ${formatMoney(sale.sellingPrice)}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Icon(
            sale.paymentStatus == 'paid'
                ? Icons.check_circle_rounded
                : Icons.access_time_rounded,
            size: 18,
            color: sale.paymentStatus == 'paid'
                ? AppColors.success
                : AppColors.warning,
          ),
        ],
      ),
    );
  }
}

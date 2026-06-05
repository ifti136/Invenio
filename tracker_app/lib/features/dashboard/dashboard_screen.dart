import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/models/dashboard_summary.dart';
import 'package:tracker/features/products/widgets/product_tile.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/widgets/quick_sell_sheet.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _bannerShown = false;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardProvider);

    summaryAsync.whenData((s) {
      if (!_bannerShown && mounted) {
        _bannerShown = true;
        final lowStockCount = s.lowStockProducts.length;
        if (lowStockCount > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$lowStockCount product${lowStockCount == 1 ? '' : 's'} low on stock'),
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () => context.go('/products'),
                ),
              ),
            );
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, kBottomNavClearance),
            children: [
              _StatGrid(summary: s),
              const SizedBox(height: 16),
              _PlatformBreakdown(
                fbProfit: s.facebookProfit,
                offlineProfit: s.offlineProfit,
              ),
              if (s.lowStockProducts.isNotEmpty) ...[
                const SizedBox(height: 16),
                _LowStockSection(products: s.lowStockProducts),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _StatGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      noBlur: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _StatItem(
                      label: 'Sales',
                      value: '${summary.salesToday}',
                      icon: Icons.shopping_bag,
                      color: AppColors.accent)),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatItem(
                      label: 'Revenue',
                      value: formatMoney(summary.revenueToday),
                      icon: Icons.trending_up,
                      color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _StatItem(
                      label: 'Gross Profit',
                      value: formatMoney(summary.grossProfitToday),
                      icon: Icons.account_balance,
                      color: AppColors.warning)),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatItem(
                      label: 'Net Profit',
                      value: formatMoney(summary.netProfitToday),
                      icon: Icons.savings,
                      color: summary.netProfitToday >= 0
                          ? AppColors.success
                          : AppColors.danger)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _StatItem(
                      label: 'Due',
                      value: formatMoney(summary.totalDue),
                      icon: Icons.pending_actions,
                      color: AppColors.danger)),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color.withOpacity(0.8))),
        const SizedBox(height: 2),
        Text(value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _PlatformBreakdown extends StatelessWidget {
  final double fbProfit;
  final double offlineProfit;
  const _PlatformBreakdown(
      {required this.fbProfit, required this.offlineProfit});

  @override
  Widget build(BuildContext context) {
    final total = fbProfit + offlineProfit;
    final fbPct = total > 0 ? (fbProfit / total) * 100 : 0.0;
    final offlinePct = total > 0 ? (offlineProfit / total) * 100 : 0.0;

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      noBlur: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _PlatformRow(
            label: 'Facebook',
            profit: fbProfit,
            pct: fbPct,
            color: const Color(0xFF1877F2),
          ),
          const SizedBox(height: 8),
          _PlatformRow(
            label: 'Offline',
            profit: offlineProfit,
            pct: offlinePct,
            color: AppColors.accent,
          ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fbPct / 100,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                color: const Color(0xFF1877F2),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlatformRow extends StatelessWidget {
  final String label;
  final double profit;
  final double pct;
  final Color color;
  const _PlatformRow({
    required this.label,
    required this.profit,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(formatMoney(profit),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text('(${pct.toStringAsFixed(0)}%)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color)),
      ],
    );
  }
}

class _LowStockSection extends ConsumerWidget {
  final List<Product> products;
  const _LowStockSection({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      noBlur: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 18, color: AppColors.warning),
              const SizedBox(width: 6),
              Text('Low Stock (${products.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ...products.map((p) => _LowStockRow(product: p)),
        ],
      ),
    );
  }
}

class _LowStockRow extends ConsumerWidget {
  final Product product;
  const _LowStockRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ProductTile(
              product: product,
              onTap: () => context.push('/products/${product.id}'),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () => _sell(context, ref),
            icon: const Icon(Icons.point_of_sale_rounded, size: 16),
            label: const Text('Sell', style: TextStyle(fontSize: 12)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sell(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(saleRepositoryProvider);
    final lastSale = await repo.lastSellingPriceFor(product.id);
    if (!context.mounted) return;
    showQuickSellSheet(
      context,
      product: product,
      lastSellingPrice: lastSale?.sellingPrice,
    );
  }
}

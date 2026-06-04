import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_panel.dart';
import '../../db/app_database.dart';
import '../../models/dashboard_summary.dart';
import '../products/widgets/product_tile.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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

class _LowStockSection extends StatelessWidget {
  final List<Product> products;
  const _LowStockSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
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
          ...products.map((p) => ProductTile(
                product: p,
                onTap: () => context.push('/products/${p.id}'),
              )),
        ],
      ),
    );
  }
}

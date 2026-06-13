import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/section_header.dart';
import 'package:tracker/core/widgets/metric_cell.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/models/dashboard_summary.dart';
import 'package:tracker/features/products/wallet_repository.dart';
import 'package:tracker/features/products/bucket_repository.dart';
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
                content: Text(
                    '$lowStockCount product${lowStockCount == 1 ? '' : 's'} low on stock'),
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
          'DASHBOARD',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavClearance),
            children: [
              _TodayCard(summary: s),
              const SizedBox(height: 16),
              _PlatformPerformanceCard(
                fbRevenue: s.facebookRevenue,
                offlineRevenue: s.offlineRevenue,
              ),
              const SizedBox(height: 16),
              const _WalletBalancesCard(),
              const SizedBox(height: 16),
              const _BudgetBucketsCard(),
              if (s.lowStockProducts.isNotEmpty) ...[
                const SizedBox(height: 16),
                _StockAlertsCard(products: s.lowStockProducts),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final DashboardSummary summary;
  const _TodayCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      noBlur: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('TODAY'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCell(
                  icon: Icons.shopping_bag_outlined,
                  iconColor: AppColors.accent,
                  value: '${summary.salesToday}',
                  label: 'Sales',
                  sparklineData: summary.salesLast7Days,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCell(
                  icon: Icons.trending_up,
                  iconColor: AppColors.accent,
                  value: formatMoney(summary.revenueToday),
                  label: 'Revenue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MetricCell(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.accent,
                  value: formatMoney(summary.grossProfitToday),
                  label: 'Gross Profit',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MetricCell(
                  icon: Icons.savings_outlined,
                  iconColor: summary.netProfitToday >= 0
                      ? AppColors.accent
                      : AppColors.danger,
                  value: formatMoney(summary.netProfitToday),
                  label: 'Net Profit',
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 6),
                  Text(
                    'CURRENT DUE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              Text(
                formatMoney(summary.totalDue),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatformPerformanceCard extends StatelessWidget {
  final double fbRevenue;
  final double offlineRevenue;
  const _PlatformPerformanceCard({
    required this.fbRevenue,
    required this.offlineRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final total = fbRevenue + offlineRevenue;
    final fbPct = total > 0 ? (fbRevenue / total) : 0.0;
    final offlinePct = total > 0 ? (offlineRevenue / total) : 0.0;

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      noBlur: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('PLATFORM PERFORMANCE'),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4 - 32,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF1877F2),
                        value: total > 0 ? fbRevenue : 1,
                        title: '',
                        radius: 20,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF534AB7),
                        value: total > 0 ? offlineRevenue : 0,
                        title: '',
                        radius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _PlatformPerformanceRow(
                      label: 'Facebook',
                      amount: fbRevenue,
                      pct: fbPct,
                      color: const Color(0xFF1877F2),
                    ),
                    const SizedBox(height: 12),
                    _PlatformPerformanceRow(
                      label: 'Offline',
                      amount: offlineRevenue,
                      pct: offlinePct,
                      color: const Color(0xFF534AB7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatformPerformanceRow extends StatelessWidget {
  final String label;
  final double amount;
  final double pct;
  final Color color;
  const _PlatformPerformanceRow({
    required this.label,
    required this.amount,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
            ),
            const Spacer(),
            Text(
              formatMoney(amount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${(pct * 100).toStringAsFixed(0)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white.withOpacity(0.1),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _WalletBalancesCard extends ConsumerWidget {
  const _WalletBalancesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletRepositoryProvider).getWallets().then(
      (allWallets) async {
        final activeWallets = allWallets.where((w) => w.isActive).toList();
        final repo = ref.read(walletRepositoryProvider);
        final balances = await repo.getWalletBalances();
        final balanceMap = {for (var b in balances) b.walletId: b.balance};
        return activeWallets
            .map((w) =>
                (name: w.name, balance: balanceMap[w.id] ?? 0.0, id: w.id))
            .toList();
      },
    );

    return FutureBuilder<List<({String name, double balance, int id})>>(
      future: walletsAsync,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final walletData = snapshot.data!;
        if (walletData.isEmpty) {
          return GlassPanel(
            padding: const EdgeInsets.all(16),
            noBlur: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('WALLET BALANCES'),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Track your cash and bank balances here',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/settings/wallets'),
                        child: const Text('+ Add Wallet',
                            style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return GlassPanel(
          padding: const EdgeInsets.all(16),
          noBlur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('WALLET BALANCES'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: walletData
                    .map((w) => _WalletBalanceChip(
                          name: w.name,
                          balance: w.balance,
                          id: w.id,
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalletBalanceChip extends StatelessWidget {
  final String name;
  final double balance;
  final int id;
  const _WalletBalanceChip(
      {required this.name, required this.balance, required this.id});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/settings/wallets/edit/$id'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 6),
            Text(
              formatMoney(balance),
              style: TextStyle(
                color: balance >= 0 ? AppColors.success : AppColors.danger,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetBucketsCard extends ConsumerWidget {
  const _BudgetBucketsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketsAsync =
        ref.watch(bucketRepositoryProvider).getBucketBalances();

    return FutureBuilder<List<BucketBalance>>(
      future: bucketsAsync,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final buckets = snapshot.data!;
        if (buckets.isEmpty) {
          return GlassPanel(
            padding: const EdgeInsets.all(16),
            noBlur: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('BUDGET BUCKETS'),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Organize your funds into custom buckets',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/settings/buckets'),
                        child: const Text('+ Add Bucket',
                            style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return GlassPanel(
          padding: const EdgeInsets.all(16),
          noBlur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('BUDGET BUCKETS'),
              const SizedBox(height: 12),
              ...buckets.map((b) => _BudgetBucketRow(bucket: b)),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetBucketRow extends StatelessWidget {
  final BucketBalance bucket;
  const _BudgetBucketRow({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final color = bucket.color != null
        ? Color(int.parse(bucket.color!.replaceFirst('#', '0xff')))
        : AppColors.accent;

    return InkWell(
      onTap: () => context.push('/settings/buckets/history/${bucket.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bucket.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              formatMoney(bucket.available),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: bucket.available >= 0
                        ? AppColors.success
                        : AppColors.danger,
                  ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _StockAlertsCard extends ConsumerWidget {
  final List<Product> products;
  const _StockAlertsCard({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      noBlur: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('STOCK ALERTS (${products.length})'),
          const SizedBox(height: 12),
          ...products.map((p) => _StockAlertRow(product: p)),
        ],
      ),
    );
  }
}

class _StockAlertRow extends ConsumerWidget {
  final Product product;
  const _StockAlertRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOut = product.stock <= 0;
    final badgeColor = isOut ? AppColors.danger : AppColors.warning;
    final badgeText = isOut ? 'Out' : 'Low';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.push('/products/${product.id}'),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/products/${product.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    formatMoney(product.costPrice),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withOpacity(0.5)),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: Colors.white38),
          const SizedBox(width: 8),
          HapticWrapper(
            profile: HapticProfile.medium,
            onTap: () => _sell(context, ref),
            child: FilledButton.tonal(
              onPressed: null, // HapticWrapper handles the tap
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('SELL',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

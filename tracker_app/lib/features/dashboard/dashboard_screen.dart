import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/theme/app_tokens.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/empty_state.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/quick_action_tile.dart';
import 'package:tracker/core/widgets/section_header.dart';
import 'package:tracker/core/widgets/stat_card.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/features/walkthrough/walkthrough_provider.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/models/dashboard_summary.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/products/widgets/stock_badge.dart';
import 'package:tracker/features/products/wallet_repository.dart';
import 'package:tracker/features/products/bucket_repository.dart';
import 'package:tracker/features/sales/pos_flow.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/widgets/quick_sell_sheet.dart';
import 'package:tracker/features/sales/widgets/receipt_sheet.dart';
import 'package:tracker/features/products/widgets/wallet_form_sheet.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardProvider);
    final lowStockCount =
        summaryAsync.valueOrNull?.lowStockProducts.length ?? 0;

    final shopName = ref.watch(shopNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shopName ?? 'Invenio',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          IconButton(
            tooltip: 'Low stock',
            onPressed: () {
              HapticService.trigger(HapticProfile.light);
              ref
                  .read(productFilterProvider.notifier)
                  .setStockFilter(StockFilter.low);
              context.go('/products');
            },
            icon: Badge(
              isLabelVisible: lowStockCount > 0,
              label: Text('$lowStockCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              EmptyState(
                icon: Icons.cloud_off_outlined,
                title: "Couldn't load today's numbers.",
                message: 'Pull to refresh.',
              ),
            ],
          ),
        ),
        data: (s) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavClearance),
            children: [
              _HeroTurnoverCard(summary: s),
              const SizedBox(height: AppSpacing.lg),
              _StatGrid(summary: s),
              const SizedBox(height: AppSpacing.lg),
              const _QuickActions(),
              const SizedBox(height: AppSpacing.lg),
              _RevenueTrendCard(values: s.revenueLast7Days),
              const SizedBox(height: AppSpacing.lg),
              _PlatformPerformanceCard(
                fbRevenue: s.facebookRevenue,
                offlineRevenue: s.offlineRevenue,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _WalletWithBalancesCard(),
              const SizedBox(height: AppSpacing.lg),
              const _BudgetBucketsCard(),
              if (s.lowStockProducts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _StockAlertsCard(products: s.lowStockProducts),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTurnoverCard extends StatelessWidget {
  final DashboardSummary summary;

  const _HeroTurnoverCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentInk = AppColors.accentInkFor(Theme.of(context).brightness);

    return GlassPanel(
      radius: AppRadii.hero,
      noBlur: true,
      tint: AppColors.accent,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "TODAY'S TURNOVER",
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (summary.totalDue > 0) _DuePill(amount: summary.totalDue),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(summary.revenueToday),
              maxLines: 1,
              style: AppTextStyles.display.copyWith(color: accentInk),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${summary.salesToday} sale${summary.salesToday == 1 ? '' : 's'} today',
            style: AppTextStyles.body.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DuePill extends StatelessWidget {
  final double amount;

  const _DuePill({required this.amount});

  @override
  Widget build(BuildContext context) {
    final dangerInk = AppColors.dangerInkFor(Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.32),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: dangerInk),
          const SizedBox(width: 4),
          Text(
            'Due ${formatMoney(amount)}',
            style: AppTextStyles.label.copyWith(color: dangerInk),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final DashboardSummary summary;

  const _StatGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final netTone =
        summary.netProfitToday >= 0 ? StatTone.accent : StatTone.danger;
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: 'Gross profit',
                  value: formatMoney(summary.grossProfitToday),
                  icon: Icons.trending_up_rounded,
                  tone: StatTone.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: 'Net profit',
                  value: formatMoney(summary.netProfitToday),
                  icon: Icons.savings_outlined,
                  tone: netTone,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StatCard(
                  label: 'Sales today',
                  value: '${summary.salesToday}',
                  icon: Icons.point_of_sale_outlined,
                  tone: StatTone.neutral,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: 'Expenses today',
                  value: formatMoney(summary.expensesToday),
                  icon: Icons.payments_outlined,
                  tone: StatTone.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        QuickActionTile(
          primary: true,
          label: 'New sale',
          icon: Icons.point_of_sale_rounded,
          onTap: () => startPosFlow(context, ref),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: QuickActionTile(
                label: 'Add product',
                icon: Icons.add_box_outlined,
                onTap: () {
                  HapticService.trigger(HapticProfile.light);
                  context.push('/products/add');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: QuickActionTile(
                label: 'Add expense',
                icon: Icons.receipt_long_outlined,
                onTap: () {
                  HapticService.trigger(HapticProfile.light);
                  context.push('/expenses/add');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RevenueTrendCard extends StatelessWidget {
  final List<double> values;

  const _RevenueTrendCard({required this.values});

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentInk = AppColors.accentInkFor(Theme.of(context).brightness);
    final hasData = values.any((v) => v > 0);
    final maxValue = values.fold(0.0, (m, v) => v > m ? v : m);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;
    final now = DateTime.now();

    return GlassPanel(
      radius: AppRadii.card,
      noBlur: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('7-Day Trend'),
          const SizedBox(height: AppSpacing.md),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    'No sales yet today',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap Sell to record your first sale.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barGroups: [
                    for (var i = 0; i < values.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: values[i],
                            color: AppColors.accent,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: scheme.onSurfaceVariant.withOpacity(0.12),
                      strokeWidth: 0.6,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (v, meta) {
                          final i = v.toInt();
                          if (i < 0 || i >= values.length) {
                            return const SizedBox.shrink();
                          }
                          final date = now
                              .subtract(Duration(days: values.length - 1 - i));
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _weekdayLabels[date.weekday - 1],
                              style: AppTextStyles.label.copyWith(
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: maxY / 2,
                        getTitlesWidget: (v, meta) {
                          if (v == 0 || v >= maxY) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _compactMoney(v),
                            textAlign: TextAlign.right,
                            style: AppTextStyles.label.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: 0,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          if (hasData) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Revenue · last 7 days',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  formatMoney(values.fold(0.0, (s, v) => s + v)),
                  style: AppTextStyles.label.copyWith(color: accentInk),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _compactMoney(double value) {
    if (value >= 1000) {
      final k = value / 1000;
      return '৳${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
    }
    return '৳${value.toStringAsFixed(0)}';
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
    final scheme = Theme.of(context).colorScheme;
    final total = fbRevenue + offlineRevenue;
    final fbPct = total > 0 ? (fbRevenue / total) : 0.0;
    final offlinePct = total > 0 ? (offlineRevenue / total) : 0.0;

    return GlassPanel(
      radius: AppRadii.card,
      noBlur: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Platform Performance'),
          const SizedBox(height: AppSpacing.md),
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
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    _PlatformPerformanceRow(
                      label: 'Facebook',
                      amount: fbRevenue,
                      pct: fbPct,
                      color: const Color(0xFF1877F2),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
          if (total == 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No sales on either platform today.',
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              formatMoney(amount),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '(${(pct * 100).toStringAsFixed(0)}%)',
              style: AppTextStyles.label.copyWith(
                color: color,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: scheme.onSurfaceVariant.withOpacity(0.12),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _WalletWithBalancesCard extends ConsumerWidget {
  const _WalletWithBalancesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final walletsAsync = ref.watch(walletRepositoryProvider).getWallets().then(
      (allWallets) async {
        final activeWallets = allWallets.where((w) => w.isActive).toList();
        final repo = ref.read(walletRepositoryProvider);
        final balances = await repo.getWalletWithBalances();
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
            radius: AppRadii.card,
            noBlur: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Wallet Balances'),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Track your cash and bank balances here',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticService.trigger(HapticProfile.light);
                          context.push('/settings/wallets');
                        },
                        child: Text(
                          '+ Add Wallet',
                          style: TextStyle(
                            color: AppColors.accentInkFor(
                              Theme.of(context).brightness,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return GlassPanel(
          radius: AppRadii.card,
          noBlur: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('Wallet Balances'),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: walletData
                    .map((w) => _WalletWithBalanceChip(
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

class _WalletWithBalanceChip extends ConsumerWidget {
  final String name;
  final double balance;
  final int id;
  const _WalletWithBalanceChip(
      {required this.name, required this.balance, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final tone = AppColors.accentInkFor(Theme.of(context).brightness);
    return InkWell(
      onTap: () async {
        HapticService.trigger(HapticProfile.light);
        final wallet =
            await ref.read(walletRepositoryProvider).getWalletById(id);
        if (context.mounted) {
          showWalletFormSheet(context, wallet: wallet);
        }
      },
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: scheme.onSurfaceVariant.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              formatMoney(balance),
              style: AppTextStyles.label.copyWith(
                color: balance >= 0
                    ? tone
                    : AppColors.dangerInkFor(
                        Theme.of(context).brightness,
                      ),
                letterSpacing: 0,
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
    final scheme = Theme.of(context).colorScheme;
    final bucketsAsync =
        ref.watch(bucketRepositoryProvider).getBucketWithAvailables();

    return FutureBuilder<List<BucketWithAvailable>>(
      future: bucketsAsync,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final buckets = snapshot.data!;
        if (buckets.isEmpty) {
          return GlassPanel(
            radius: AppRadii.card,
            noBlur: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Budget Buckets'),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Organize your funds into custom buckets',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticService.trigger(HapticProfile.light);
                          context.push('/settings/buckets');
                        },
                        child: Text(
                          '+ Add Bucket',
                          style: TextStyle(
                            color: AppColors.accentInkFor(
                              Theme.of(context).brightness,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return GlassPanel(
          radius: AppRadii.card,
          noBlur: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('Budget Buckets'),
              const SizedBox(height: AppSpacing.md),
              ...buckets.map((b) => _BudgetBucketRow(bucket: b)),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetBucketRow extends StatelessWidget {
  final BucketWithAvailable bucket;
  const _BudgetBucketRow({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = bucket.color != null
        ? Color(int.parse(bucket.color!.replaceFirst('#', '0xff')))
        : AppColors.accent;
    final tone = AppColors.accentInkFor(Theme.of(context).brightness);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.input),
      onTap: () {
        HapticService.trigger(HapticProfile.light);
        context.push('/settings/buckets');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                bucket.name,
                style: AppTextStyles.body,
              ),
            ),
            Text(
              formatMoney(bucket.available),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: bucket.available >= 0
                    ? tone
                    : AppColors.dangerInkFor(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
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
      radius: AppRadii.card,
      noBlur: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('Stock Alerts (${products.length})'),
          const SizedBox(height: AppSpacing.md),
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticService.trigger(HapticProfile.light);
              context.push('/products/${product.id}');
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppColors.accentInkFor(Theme.of(context).brightness),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.input),
              onTap: () {
                HapticService.trigger(HapticProfile.light);
                context.push('/products/${product.id}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatMoney(product.costPrice),
                    style: AppTextStyles.label.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StockBadge(
            stock: product.stock,
            threshold: product.lowStockThreshold,
            compact: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton.tonal(
            onPressed: () {
              HapticService.trigger(HapticProfile.medium);
              _sell(context, ref);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              'SELL',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
    final sale = await showQuickSellSheet(
      context,
      product: product,
      lastSellingPrice: lastSale?.sellingPrice,
    );
    if (sale != null && context.mounted) {
      await showReceiptSheet(
        context,
        sale: sale,
        productName: product.name,
      );
    }
  }
}

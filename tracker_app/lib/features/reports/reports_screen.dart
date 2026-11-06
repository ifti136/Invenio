import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../sales/sale_flow.dart';
import '../settings/settings_providers.dart';
import 'csv_export.dart';
import 'report_providers.dart';
import 'report_repository.dart';

enum _BreakdownView { products, channels }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPreset _preset = ReportPreset.week;
  DateTimeRange? _custom;
  _BreakdownView _breakdown = _BreakdownView.products;

  ReportRange get _range {
    final now = DateTime.now();
    switch (_preset) {
      case ReportPreset.week:
        return ReportRange.week(now);
      case ReportPreset.month:
        return ReportRange.month(now);
      case ReportPreset.year:
        return ReportRange.year(now);
      case ReportPreset.custom:
        final custom = _custom;
        if (custom == null) return ReportRange.week(now);
        return ReportRange.custom(custom.start, custom.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final report = ref.watch(reportProvider(range));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () => shareCsvExport(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<ReportPreset>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ReportPreset.week, label: Text('Week')),
                  ButtonSegment(
                    value: ReportPreset.month,
                    label: Text('Month'),
                  ),
                  ButtonSegment(value: ReportPreset.year, label: Text('Year')),
                  ButtonSegment(
                    value: ReportPreset.custom,
                    label: Text('Custom'),
                  ),
                ],
                selected: {_preset},
                onSelectionChanged: _selectPreset,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: KeyedSubtree(
                key: ValueKey(range),
                child: report.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => EmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not load reports',
                    message:
                        'Something went wrong while reading your sales and expenses.',
                    actionLabel: 'Retry',
                    actionIcon: Icons.refresh,
                    onAction: () => ref.invalidate(reportProvider(range)),
                  ),
                  data: (data) => _body(data, range),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPreset(Set<ReportPreset> selection) async {
    final next = selection.first;
    if (next != ReportPreset.custom) {
      setState(() => _preset = next);
      return;
    }
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day + 1),
      initialDateRange: _custom ??
          DateTimeRange(
            start: DateTime(now.year, now.month, now.day - 6),
            end: now,
          ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _custom = picked;
      _preset = ReportPreset.custom;
    });
  }

  Widget _body(ReportData data, ReportRange range) {
    if (data.isEmpty) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'No data for this period',
        message: _preset == ReportPreset.custom
            ? 'No sales or expenses in the selected dates.'
            : 'Make a sale or add an expense to see your profit and loss.',
        actionLabel: 'New sale',
        actionIcon: Icons.add,
        onAction: () => openNewSale(context, ref),
      );
    }

    final rows = _breakdown == _BreakdownView.products
        ? [
            for (final item in data.products)
              (item.name, item.qty, item.revenueMinor, item.profitMinor),
          ]
        : [
            for (final item in data.channels)
              (item.name, item.qty, item.revenueMinor, item.profitMinor),
          ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl * 2,
      ),
      children: [
        _ProfitLossCard(pnl: data.pnl),
        const SizedBox(height: AppSpacing.lg),
        if (data.buckets.any(
          (bucket) => bucket.revenueMinor != 0 || bucket.profitMinor != 0,
        ))
          _ChartCard(buckets: data.buckets)
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No sales in this period to chart.'),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<_BreakdownView>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _BreakdownView.products,
                        label: Text('Products'),
                      ),
                      ButtonSegment(
                        value: _BreakdownView.channels,
                        label: Text('Channels'),
                      ),
                    ],
                    selected: {_breakdown},
                    onSelectionChanged: (selection) {
                      setState(() => _breakdown = selection.first);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Text(
                      _breakdown == _BreakdownView.products
                          ? 'No product sales in this period.'
                          : 'No channel sales in this period.',
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  _BreakdownTable(rows: rows),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.tonalIcon(
          onPressed: () => shareCsvExport(context, ref),
          icon: const Icon(Icons.ios_share_outlined),
          label: const Text('Export CSV'),
        ),
      ],
    );
  }
}

class _ProfitLossCard extends StatelessWidget {
  final ProfitLoss pnl;

  const _ProfitLossCard({required this.pnl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Profit & loss',
              style: AppTextStyles.title.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            _row(context, 'Revenue', Money(pnl.revenueMinor)),
            _row(context, '− Cost of goods', Money(pnl.cogsMinor)),
            const Divider(),
            _row(
              context,
              '= Gross profit',
              Money(pnl.grossProfitMinor),
              emphasis: true,
            ),
            _row(context, '− Expenses', Money(pnl.expensesMinor)),
            const Divider(),
            _row(
              context,
              '= Net profit',
              Money(pnl.netProfitMinor),
              emphasis: true,
              color: pnl.netProfitMinor < 0 ? scheme.error : scheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Margin',
                    style: AppTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${(pnl.margin * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.body.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontFeatures: AppTextStyles.tabular,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    Money money, {
    bool emphasis = false,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final style =
        (emphasis ? AppTextStyles.bodyLarge : AppTextStyles.body).copyWith(
      color: color ?? scheme.onSurface,
      fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: MoneyText(money, style: style),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends ConsumerWidget {
  final List<ReportBucket> buckets;

  const _ChartCard({required this.buckets});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencySymbolProvider);
    final maxValue = buckets.fold<int>(
      0,
      (current, bucket) => math.max(
        current,
        math.max(bucket.revenueMinor, bucket.profitMinor),
      ),
    );
    final minValue = buckets.fold<int>(
      0,
      (current, bucket) => math.min(
        current,
        math.min(bucket.profitMinor, 0),
      ),
    );
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.2;
    final minY = minValue >= 0 ? 0.0 : minValue * 1.2;
    final rodWidth = buckets.length > 16 ? 4.0 : 7.0;
    final labelInterval = buckets.length > 12 ? 5.0 : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue vs profit',
              style: AppTextStyles.title.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _LegendDot(color: scheme.primary, label: 'Revenue'),
                const SizedBox(width: AppSpacing.lg),
                _LegendDot(color: scheme.tertiary, label: 'Profit'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: minY,
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: buckets.length > 20 ? 4 : 8,
                  barGroups: [
                    for (var i = 0; i < buckets.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 3,
                        barRods: [
                          BarChartRodData(
                            toY: buckets[i].revenueMinor.toDouble(),
                            color: scheme.primary,
                            width: rodWidth,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          BarChartRodData(
                            toY: buckets[i].profitMinor.toDouble(),
                            color: scheme.tertiary,
                            width: rodWidth,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : null,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: scheme.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: labelInterval,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 ||
                              index >= buckets.length ||
                              (value - index).abs() > 0.01) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              buckets[index].label,
                              style: AppTextStyles.label.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => scheme.inverseSurface,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = rodIndex == 0 ? 'Revenue' : 'Profit';
                        final value = Money(rod.toY.round()).format(
                          currencySymbol: symbol,
                        );
                        return BarTooltipItem(
                          '$label\n$value',
                          TextStyle(
                            color: scheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent) return;
                      final spot = response?.spot;
                      if (spot == null ||
                          spot.touchedBarGroupIndex < 0 ||
                          spot.touchedBarGroupIndex >= buckets.length) {
                        return;
                      }
                      _showDetail(
                        context,
                        buckets[spot.touchedBarGroupIndex],
                        symbol,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(
    BuildContext context,
    ReportBucket bucket,
    String symbol,
  ) {
    final margin = bucket.revenueMinor == 0
        ? 0.0
        : bucket.profitMinor / bucket.revenueMinor;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(bucket.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogRow(
                dialogContext, 'Revenue', Money(bucket.revenueMinor), symbol),
            _dialogRow(
                dialogContext, 'Profit', Money(bucket.profitMinor), symbol),
            _dialogRow(
              dialogContext,
              'Margin',
              null,
              symbol,
              text: '${(margin * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(
    BuildContext context,
    String label,
    Money? money,
    String symbol, {
    String? text,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          if (money != null)
            Text(
              money.format(currencySymbol: symbol),
              style: AppTextStyles.body.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              text ?? '',
              style: AppTextStyles.body.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BreakdownTable extends ConsumerWidget {
  final List<(String, int, int, int)> rows;

  const _BreakdownTable({required this.rows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(0.7),
        2: FlexColumnWidth(1.4),
        3: FlexColumnWidth(1.4),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: scheme.outlineVariant.withOpacity(0.6),
        ),
      ),
      children: [
        TableRow(
          children: [
            _header(context, 'Name'),
            _header(context, 'Qty', align: TextAlign.center),
            _header(context, 'Revenue', align: TextAlign.right),
            _header(context, 'Profit', align: TextAlign.right),
          ],
        ),
        for (final row in rows)
          TableRow(
            children: [
              _cell(context, row.$1),
              _cell(context, '${row.$2}', align: TextAlign.center),
              _moneyCell(context, row.$3),
              _moneyCell(context, row.$4),
            ],
          ),
      ],
    );
  }

  Widget _header(
    BuildContext context,
    String text, {
    TextAlign align = TextAlign.start,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Text(
        text,
        textAlign: align,
        style: AppTextStyles.label.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String text, {
    TextAlign align = TextAlign.start,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _moneyCell(BuildContext context, int minor) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: MoneyText(
            Money(minor),
            style: AppTextStyles.body.copyWith(
              color: minor < 0 ? scheme.error : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

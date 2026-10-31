import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/category_chip_row.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/haptic_wrapper.dart';
import '../../core/widgets/empty_state.dart';
import '../../db/app_database.dart';
import '../../models/monthly_report.dart';
import '../../services/export_service.dart';
import 'report_repository.dart';
import 'widgets/bar_chart_widget.dart';
import 'widgets/chart_table_toggle.dart';

enum _ReportTab { daily, monthly, products }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _selectedMonth;
  late int _selectedYear;
  _ReportTab _tab = _ReportTab.daily;
  bool _showChart = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedYear = now.year;
  }

  void _prevMonth() => setState(() => _selectedMonth =
      DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));

  void _nextMonth() => setState(() => _selectedMonth =
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));

  void _prevYear() => setState(() => _selectedYear = _selectedYear - 1);

  void _nextYear() => setState(() => _selectedYear = _selectedYear + 1);

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final service = ExportService(db);
      await service.exportMonth(_selectedMonth);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, kBottomNavClearance),
        children: [
          _buildMonthSelector(context),
          const SizedBox(height: 12),
          _buildTabSelector(context),
          const SizedBox(height: 12),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final monthLabel =
        '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}';
    final yearLabel = '$_selectedYear';

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      noBlur: true,
      child: Row(
        children: [
          if (_tab == _ReportTab.monthly) ...[
            HapticWrapper(
              profile: HapticProfile.light,
              onTap: _prevYear,
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(yearLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            HapticWrapper(
              profile: HapticProfile.light,
              onTap: _nextYear,
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ] else ...[
            HapticWrapper(
              profile: HapticProfile.light,
              onTap: _prevMonth,
              child: IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(monthLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            HapticWrapper(
              profile: HapticProfile.light,
              onTap: _nextMonth,
              child: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
          if (_tab == _ReportTab.daily) ...[
            const SizedBox(width: 8),
            HapticWrapper(
              profile: HapticProfile.medium,
              onTap: _exporting ? null : _export,
              child: IconButton(
                icon: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.file_download_outlined),
                onPressed: null,
                tooltip: 'Export month',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: cs.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return CategoryChipRow(
      children: [
        for (final tab in _ReportTab.values)
          AppFilterChip(
            label: switch (tab) {
              _ReportTab.daily => 'Daily',
              _ReportTab.monthly => 'Monthly',
              _ReportTab.products => 'Products',
            },
            selected: _tab == tab,
            onTap: () {
              HapticService.trigger(HapticProfile.light);
              setState(() => _tab = tab);
            },
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_tab) {
      case _ReportTab.daily:
        return _DailyReport(
          year: _selectedMonth.year,
          month: _selectedMonth.month,
          showChart: _showChart,
          onToggle: () => setState(() => _showChart = !_showChart),
        );
      case _ReportTab.monthly:
        return _MonthlyReport(
          year: _selectedYear,
          showChart: _showChart,
          onToggle: () => setState(() => _showChart = !_showChart),
        );
      case _ReportTab.products:
        return const _ProductReport();
    }
  }

  static String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[m - 1];
  }
}

class _DailyReport extends ConsumerWidget {
  final int year;
  final int month;
  final bool showChart;
  final VoidCallback onToggle;

  const _DailyReport({
    required this.year,
    required this.month,
    required this.showChart,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotsAsync = ref.watch(dailySnapshotsProvider(year, month));

    return snapshotsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (snapshots) {
        final totalRev = snapshots.fold(0.0, (s, d) => s + d.revenue);
        final totalProfit = snapshots.fold(0.0, (s, d) => s + d.profit);
        final totalExp = snapshots.fold(0.0, (s, d) => s + d.expenses);
        final hasData = totalRev > 0 || totalProfit > 0 || totalExp > 0;

        return Column(
          children: [
            _PlReportCard(
              revenue: totalRev,
              profit: totalProfit,
              expenses: totalExp,
            ),
            const SizedBox(height: 12),
            if (hasData)
              ChartTableToggle(
                showChart: showChart,
                onToggle: onToggle,
                chart: _ChartCard(
                  child: MonthlyBarChart(snapshots: snapshots),
                ),
                table: _DailyTable(snapshots: snapshots),
              )
            else
              const Padding(
                padding: EdgeInsets.all(32),
                child: EmptyState(
                  icon: Icons.analytics_outlined,
                  title: 'No sales or expenses this month',
                  message: 'Try another month or record a sale.',
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MonthlyReport extends ConsumerWidget {
  final int year;
  final bool showChart;
  final VoidCallback onToggle;

  const _MonthlyReport({
    required this.year,
    required this.showChart,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(monthlySummariesProvider(year));

    return summariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summaries) {
        final totalRev = summaries.fold(0.0, (s, m) => s + m.revenue);
        final totalProfit = summaries.fold(0.0, (s, m) => s + m.profit);
        final totalExp = summaries.fold(0.0, (s, m) => s + m.expenses);
        final hasData = totalRev > 0 || totalProfit > 0 || totalExp > 0;

        return Column(
          children: [
            _PlReportCard(
              revenue: totalRev,
              profit: totalProfit,
              expenses: totalExp,
            ),
            const SizedBox(height: 12),
            if (hasData)
              ChartTableToggle(
                showChart: showChart,
                onToggle: onToggle,
                chart: _ChartCard(
                  child: YearlyBarChart(summaries: summaries),
                ),
                table: _MonthlyTable(summaries: summaries),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'No sales or expenses for $year',
                  message: 'Try another year or record a sale.',
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProductReport extends ConsumerWidget {
  const _ProductReport();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(productReportProvider);

    return rowsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (rows) {
        if (rows.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No product data',
              message: 'No product sales data available yet.',
            ),
          );
        }

        return GlassPanel(
          padding: const EdgeInsets.all(12),
          noBlur: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Performance',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _hdr(context, 'Product', flex: 3),
                  _hdr(context, 'Qty'),
                  _hdr(context, 'Revenue', flex: 2, align: TextAlign.end),
                  _hdr(context, 'Profit', flex: 2, align: TextAlign.end),
                ],
              ),
              const Divider(height: 12),
              ...rows.map((r) => _ProductReportRowTile(row: r)),
            ],
          ),
        );
      },
    );
  }

  Widget _hdr(BuildContext context, String label,
      {int flex = 1, TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          textAlign: align,
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
    );
  }
}

class _ProductReportRowTile extends StatelessWidget {
  final ProductReportRow row;
  const _ProductReportRowTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(row.productName, style: AppTextStyles.body),
          ),
          Expanded(
            flex: 1,
            child: Text('${row.quantitySold}',
                textAlign: TextAlign.center,
                style: AppTextStyles.number.copyWith(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(formatMoney(row.revenue),
                textAlign: TextAlign.end,
                style: AppTextStyles.number.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatMoney(row.profit),
              textAlign: TextAlign.end,
              style: AppTextStyles.number.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: row.profit >= 0
                    ? AppColors.accentInkFor(Theme.of(context).brightness)
                    : AppColors.dangerInkFor(Theme.of(context).brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlReportCard extends StatelessWidget {
  final double revenue;
  final double profit;
  final double expenses;

  const _PlReportCard({
    required this.revenue,
    required this.profit,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final net = profit - expenses;
    final netColor = net >= 0
        ? (isDark ? AppColors.accentInkDark : AppColors.accentInkLight)
        : AppColors.dangerInkFor(Theme.of(context).brightness);
    final margin = revenue > 0 ? (net / revenue) * 100 : null;

    return GlassPanel(
      radius: AppRadii.card,
      noBlur: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'NET PROFIT',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (margin != null)
                Text(
                  '${margin.toStringAsFixed(1)}% margin',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(net),
              maxLines: 1,
              style: AppTextStyles.display.copyWith(color: netColor),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PlMetric(
                  label: 'Revenue',
                  value: formatMoney(revenue),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PlMetric(
                  label: 'Expenses',
                  value: formatMoney(expenses),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PlMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: AppTextStyles.tabular,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final Widget child;

  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppRadii.card,
      noBlur: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const _ChartLegend(),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget item(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        item(scheme.primary.withOpacity(0.4), 'Revenue'),
        const SizedBox(width: AppSpacing.md),
        item(scheme.primary, 'Profit'),
      ],
    );
  }
}

class _DailyTable extends StatelessWidget {
  final List<DailySnapshot> snapshots;
  const _DailyTable({required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = snapshots
        .where((d) => d.revenue > 0 || d.profit > 0 || d.expenses > 0)
        .toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return GlassPanel(
      padding: const EdgeInsets.all(12),
      noBlur: true,
      child: Column(
        children: [
          Row(
            children: [
              _hdr('Date', cs, flex: 2),
              _hdr('Revenue', cs),
              _hdr('Profit', cs),
              _hdr('Expenses', cs),
            ],
          ),
          const Divider(height: 16),
          ...filtered.map((d) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(formatDay(d.date),
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                  Expanded(
                      child: Text(formatMoney(d.revenue),
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                  Expanded(
                      child: Text(formatMoney(d.profit),
                          style: AppTextStyles.number.copyWith(
                            fontSize: 12,
                            color: d.profit >= 0
                                ? AppColors.accentInkFor(
                                    Theme.of(context).brightness)
                                : AppColors.dangerInkFor(
                                    Theme.of(context).brightness),
                          ))),
                  Expanded(
                      child: Text(formatMoney(d.expenses),
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _hdr(String label, ColorScheme cs, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: AppTextStyles.label.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0,
          )),
    );
  }
}

class _MonthlyTable extends StatelessWidget {
  final List<MonthlySummary> summaries;
  const _MonthlyTable({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered =
        summaries.where((m) => m.revenue > 0 || m.profit > 0).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return GlassPanel(
      padding: const EdgeInsets.all(12),
      noBlur: true,
      child: Column(
        children: [
          Row(
            children: [
              _hdr('Month', cs),
              _hdr('Sales', cs),
              _hdr('Revenue', cs, flex: 2),
              _hdr('Profit', cs, flex: 2),
              _hdr('Expenses', cs, flex: 2),
            ],
          ),
          const Divider(height: 16),
          ...filtered.map((m) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                      child: Text(m.label,
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                  Expanded(
                      child: Text('${m.salesCount}',
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                  Expanded(
                      flex: 2,
                      child: Text(formatMoney(m.revenue),
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                  Expanded(
                      flex: 2,
                      child: Text(formatMoney(m.profit),
                          style: AppTextStyles.number.copyWith(
                            fontSize: 12,
                            color: m.profit >= 0
                                ? AppColors.accentInkFor(
                                    Theme.of(context).brightness)
                                : AppColors.dangerInkFor(
                                    Theme.of(context).brightness),
                          ))),
                  Expanded(
                      flex: 2,
                      child: Text(formatMoney(m.expenses),
                          style: AppTextStyles.number.copyWith(fontSize: 12))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _hdr(String label, ColorScheme cs, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: AppTextStyles.label.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0,
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_panel.dart';
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

  void _prevMonth() =>
      setState(() => _selectedMonth = DateTime(
          _selectedMonth.year, _selectedMonth.month - 1, 1));

  void _nextMonth() =>
      setState(() => _selectedMonth = DateTime(
          _selectedMonth.year, _selectedMonth.month + 1, 1));

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
      appBar: AppBar(title: const Text('Reports')),
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
      child: Row(
        children: [
          if (_tab == _ReportTab.monthly) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _prevYear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(yearLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextYear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _prevMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(monthLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextMonth,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
          if (_tab == _ReportTab.daily) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.file_download_outlined),
              onPressed: _exporting ? null : _export,
              tooltip: 'Export month',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: cs.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(4),
      child: SegmentedButton<_ReportTab>(
        segments: const [
          ButtonSegment(value: _ReportTab.daily, label: Text('Daily')),
          ButtonSegment(value: _ReportTab.monthly, label: Text('Monthly')),
          ButtonSegment(value: _ReportTab.products, label: Text('Products')),
        ],
        selected: {_tab},
        onSelectionChanged: (v) {
          setState(() => _tab = v.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
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
        final hasData = totalRev > 0 || totalProfit > 0;

        return Column(
          children: [
            _SummaryStrip(
              revenue: totalRev,
              profit: totalProfit,
              expenses: totalExp,
            ),
            const SizedBox(height: 12),
            if (hasData)
              ChartTableToggle(
                showChart: showChart,
                onToggle: onToggle,
                chart: MonthlyBarChart(snapshots: snapshots),
                table: _DailyTable(snapshots: snapshots),
              )
            else
              GlassPanel(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No sales or expenses recorded this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5)),
                  ),
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
        final hasData = totalRev > 0 || totalProfit > 0;

        return Column(
          children: [
            _SummaryStrip(
              revenue: totalRev,
              profit: totalProfit,
              expenses: totalExp,
            ),
            const SizedBox(height: 12),
            if (hasData)
              ChartTableToggle(
                showChart: showChart,
                onToggle: onToggle,
                chart: YearlyBarChart(summaries: summaries),
                table: _MonthlyTable(summaries: summaries),
              )
            else
              GlassPanel(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No data for $year',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5)),
                  ),
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
          return GlassPanel(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No product sales data yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5)),
              ),
            ),
          );
        }
        return GlassPanel(
          padding: const EdgeInsets.all(12),
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
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
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
            child: Text(row.productName,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Text('${row.quantitySold}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            flex: 2,
            child: Text(formatMoney(row.revenue),
                textAlign: TextAlign.end,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatMoney(row.profit),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: row.profit >= 0
                      ? AppColors.success
                      : AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final double revenue;
  final double profit;
  final double expenses;

  const _SummaryStrip({
    required this.revenue,
    required this.profit,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _SumItem(label: 'Revenue', value: formatMoney(revenue)),
          _SumItem(
              label: 'Profit',
              value: formatMoney(profit),
              color: profit >= 0 ? null : AppColors.danger),
          _SumItem(label: 'Expenses', value: formatMoney(expenses)),
        ],
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SumItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _DailyTable extends StatelessWidget {
  final List<DailySnapshot> snapshots;
  const _DailyTable({required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered =
        snapshots.where((d) => d.revenue > 0 || d.profit > 0 || d.expenses > 0).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return GlassPanel(
      padding: const EdgeInsets.all(12),
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
                  Expanded(flex: 2,
                      child: Text(formatDay(d.date),
                          style: const TextStyle(fontSize: 12))),
                  Expanded(
                      child: Text(formatMoney(d.revenue),
                          style: const TextStyle(fontSize: 12))),
                  Expanded(
                      child: Text(formatMoney(d.profit),
                          style: TextStyle(
                              fontSize: 12,
                              color: d.profit >= 0
                                  ? AppColors.success
                                  : AppColors.danger))),
                  Expanded(
                      child: Text(formatMoney(d.expenses),
                          style: const TextStyle(fontSize: 12))),
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
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(0.7))),
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
                          style: const TextStyle(fontSize: 12))),
                  Expanded(
                      child: Text('${m.salesCount}',
                          style: const TextStyle(fontSize: 12))),
                  Expanded(
                      flex: 2,
                      child: Text(formatMoney(m.revenue),
                          style: const TextStyle(fontSize: 12))),
                  Expanded(
                      flex: 2,
                      child: Text(formatMoney(m.profit),
                          style: TextStyle(
                              fontSize: 12,
                              color: m.profit >= 0
                                  ? AppColors.success
                                  : AppColors.danger))),
                  Expanded(
                      flex: 2,
                      child: Text(formatMoney(m.expenses),
                          style: const TextStyle(fontSize: 12))),
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
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(0.7))),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/monthly_report.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<DailySnapshot> snapshots;

  const MonthlyBarChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (snapshots.every((s) => s.revenue == 0 && s.profit == 0)) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data for this month',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: snapshots
                  .map((s) => s.revenue > s.profit ? s.revenue : s.profit)
                  .reduce((a, b) => a > b ? a : b) *
              1.15,
          barGroups: snapshots.asMap().entries.map((e) {
            final snap = e.value;
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: snap.revenue,
                color: cs.primary.withOpacity(0.4),
                width: 8,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: snap.profit,
                color: cs.primary,
                width: 8,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]);
          }).toList(),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= snapshots.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${snapshots[i].date.day}',
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

class YearlyBarChart extends StatelessWidget {
  final List<MonthlySummary> summaries;

  const YearlyBarChart({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (summaries.every((s) => s.revenue == 0 && s.profit == 0)) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data for this year',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: summaries
                  .map((s) => s.revenue > s.profit ? s.revenue : s.profit)
                  .reduce((a, b) => a > b ? a : b) *
              1.15,
          barGroups: summaries.asMap().entries.map((e) {
            final snap = e.value;
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: snap.revenue,
                color: cs.primary.withOpacity(0.4),
                width: 12,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: snap.profit,
                color: cs.primary,
                width: 12,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]);
          }).toList(),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= summaries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      summaries[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

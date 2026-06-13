import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MetricCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final List<double>? sparklineData;

  const MetricCell({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (sparklineData != null && sparklineData!.isNotEmpty)
          Positioned.fill(
            child: _Sparkline(data: sparklineData!),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> data;

  const _Sparkline({required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            barWidth: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChartTableToggle extends StatelessWidget {
  final bool showChart;
  final VoidCallback onToggle;
  final Widget chart;
  final Widget table;

  const ChartTableToggle({
    super.key,
    required this.showChart,
    required this.onToggle,
    required this.chart,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onToggle,
            icon: Icon(showChart ? Icons.table_chart : Icons.bar_chart),
            label: Text(showChart ? 'Show Table' : 'Show Chart'),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: showChart
              ? KeyedSubtree(key: const ValueKey('chart'), child: chart)
              : KeyedSubtree(key: const ValueKey('table'), child: table),
        ),
      ],
    );
  }
}

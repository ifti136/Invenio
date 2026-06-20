import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/formatters.dart';
import 'finance_repository.dart';

part 'allocation_history_screen.g.dart';

@riverpod
Future<List<RuleMonthlyDetail>> ruleHistory(Ref ref, int ruleId) async {
  return await ref
      .watch(financeRepositoryProvider)
      .getRuleMonthlyHistory(ruleId);
}

class AllocationHistoryScreen extends ConsumerWidget {
  final int ruleId;
  const AllocationHistoryScreen({super.key, required this.ruleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ruleHistoryProvider(ruleId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Allocation History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text('No history available',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                      label: Text('Month',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Profit',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Allocated',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Charged',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Balance',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                ],
                rows: history.map((detail) {
                  return DataRow(
                    cells: [
                      DataCell(Text(detail.month,
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Text(formatMoney(detail.monthlyProfit),
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Text(formatMoney(detail.amountAllocated),
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Text(formatMoney(detail.expensesCharged),
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Text(
                        formatMoney(detail.runningBalance),
                        style: TextStyle(
                          color: detail.runningBalance >= 0
                              ? Colors.teal
                              : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

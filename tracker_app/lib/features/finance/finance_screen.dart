import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/haptic_wrapper.dart';
import '../../core/services/haptic_service.dart';
import 'finance_repository.dart';
import 'allocation_rules_repository.dart';
import '../../db/app_database.dart';

part 'finance_screen.g.dart';

@riverpod
Future<List<RuleFinanceData>> financeData(Ref ref) async {
  final rulesRepo = ref.watch(allocationRulesRepositoryProvider);
  final financeRepo = ref.watch(financeRepositoryProvider);

  final rules = await rulesRepo.getRules();
  final financials = await financeRepo.getRuleFinancials();

  return rules.map((rule) {
    final fin = financials[rule.id] ??
        RuleFinancials(
          accumulatedProfit: 0,
          totalSpent: 0,
          availableBalance: 0,
        );
    return RuleFinanceData(
      rule: rule,
      financials: fin,
    );
  }).toList();
}

class RuleFinanceData {
  final AllocationRule rule;
  final RuleFinancials financials;

  RuleFinanceData({required this.rule, required this.financials});
}

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(financeDataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Finance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          HapticWrapper(
            profile: HapticProfile.light,
            onTap: null,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings/finance/settings'),
            ),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No allocation rules found. Add some in settings.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final rule = item.rule;
              final fin = item.financials;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassPanel(
                  child: HapticWrapper(
                    profile: HapticProfile.light,
                    onTap: null,
                    child: InkWell(
                      onTap: () =>
                          context.push('/settings/finance/history/${rule.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    rule.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${rule.percentage}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                    color: Colors.white54),
                              ],
                            ),
                            const Divider(color: Colors.white12, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildFinanceStat(context, 'Accumulated',
                                    fin.accumulatedProfit),
                                _buildFinanceStat(
                                    context, 'Spent', fin.totalSpent),
                                _buildFinanceStat(
                                  context,
                                  'Available',
                                  fin.availableBalance,
                                  color: fin.availableBalance >= 0
                                      ? AppColors.teal
                                      : Colors.redAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFinanceStat(BuildContext context, String label, double value,
      {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white,
              ),
        ),
      ],
    );
  }
}

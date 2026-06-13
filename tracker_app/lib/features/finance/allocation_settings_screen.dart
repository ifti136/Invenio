import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/glass_dialog.dart';
import '../../db/app_database.dart';
import 'allocation_rules_repository.dart';
import 'allocation_rule_form_screen.dart';

part 'allocation_settings_screen.g.dart';

@riverpod
Future<List<AllocationRule>> allocationRulesList(Ref ref) async {
  return await ref.watch(allocationRulesRepositoryProvider).getRules();
}

class AllocationSettingsScreen extends ConsumerWidget {
  const AllocationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(allocationRulesListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Allocation Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToForm(context, ref),
          ),
        ],
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: Colors.white))),
        data: (rules) {
          final activeRules = rules.where((r) => r.isActive).toList();
          final totalPercentage =
              activeRules.fold(0.0, (sum, r) => sum + r.percentage);

          return Column(
            children: [
              _buildPercentageWarning(context, totalPercentage),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassPanel(
                        child: ListTile(
                          title: Text(
                            rule.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${rule.percentage}%',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: rule.isActive,
                                onChanged: (val) async {
                                  await ref
                                      .read(allocationRulesRepositoryProvider)
                                      .updateRule(
                                        rule.id,
                                        rule.label,
                                        rule.percentage,
                                        val,
                                      );
                                  ref.invalidate(allocationRulesListProvider);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white70),
                                onPressed: () =>
                                    _navigateToForm(context, ref, rule: rule),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    _confirmDelete(context, ref, rule),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPercentageWarning(BuildContext context, double total) {
    if (total > 100) {
      return Container(
        width: double.infinity,
        color: Colors.redAccent.withOpacity(0.8),
        padding: const EdgeInsets.all(12),
        child: Text(
          'Total allocation exceeds 100% (\$${total.toStringAsFixed(1)}%)',
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    } else if (total < 100) {
      return Container(
        width: double.infinity,
        color: Colors.orangeAccent.withOpacity(0.8),
        padding: const EdgeInsets.all(12),
        child: Text(
          'Unallocated profit: ${(100 - total).toStringAsFixed(1)}%',
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _navigateToForm(BuildContext context, WidgetRef ref,
      {AllocationRule? rule}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AllocationRuleFormScreen(
              ruleId: rule?.id,
              initialLabel: rule?.label,
              initialPercentage: rule?.percentage,
              initialIsActive: rule?.isActive,
            ),
          ),
        )
        .then((_) => ref.invalidate(allocationRulesListProvider));
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AllocationRule rule) {
    showGlassDialog(
      context: context,
      title: 'Delete Rule',
      message: 'Are you sure you want to deactivate "${rule.label}"?',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          onPressed: () async {
            final navigator = Navigator.of(ctx);
            await ref
                .read(allocationRulesRepositoryProvider)
                .softDeleteRule(rule.id);
            ref.invalidate(allocationRulesListProvider);
            navigator.pop();
          },
        ),
      ],
    );
  }
}

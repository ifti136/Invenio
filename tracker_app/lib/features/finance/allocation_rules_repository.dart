import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../core/utils/stream_utils.dart';

part 'allocation_rules_repository.g.dart';

class RuleWithSpent {
  final AllocationRule rule;
  final double spent;

  RuleWithSpent({required this.rule, required this.spent});
}

@Riverpod(keepAlive: true)
AllocationRulesRepository allocationRulesRepository(Ref ref) {
  return AllocationRulesRepository(ref.watch(appDatabaseProvider));
}

class AllocationRulesRepository {
  final AppDatabase _db;

  AllocationRulesRepository(this._db);

  Stream<List<RuleWithSpent>> watchAllocationRulesWithSpent() {
    return combineLatest2(
      _db.select(_db.allocationRules).watch(),
      _db.select(_db.expenses).watch(),
      (rules, expenses) {
        final spentMap = <int, double>{};
        for (final e in expenses) {
          if (e.allocationRuleId != null) {
            spentMap[e.allocationRuleId!] =
                (spentMap[e.allocationRuleId!] ?? 0.0) + e.amount;
          }
        }
        return rules
            .map((r) => RuleWithSpent(
                  rule: r,
                  spent: spentMap[r.id] ?? 0.0,
                ))
            .toList();
      },
    );
  }

  Future<List<AllocationRule>> getRules() async {
    return await _db.select(_db.allocationRules).get();
  }

  Future<AllocationRule> getRuleById(int id) async {
    return await (_db.select(_db.allocationRules)
          ..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<int> createRule(String label, double percentage, bool isActive) async {
    return await _db.into(_db.allocationRules).insert(
          AllocationRulesCompanion.insert(
            label: label,
            percentage: percentage,
            isActive: drift.Value(isActive),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<bool> updateRule(
      int id, String label, double percentage, bool isActive) async {
    final count = await (_db.update(_db.allocationRules)
          ..where((t) => t.id.equals(id)))
        .write(
      AllocationRulesCompanion(
        label: drift.Value(label),
        percentage: drift.Value(percentage),
        isActive: drift.Value(isActive),
      ),
    );
    return count > 0;
  }

  Future<bool> softDeleteRule(int id) async {
    final count = await (_db.update(_db.allocationRules)
          ..where((t) => t.id.equals(id)))
        .write(
      AllocationRulesCompanion(
        isActive: drift.Value(false),
      ),
    );
    return count > 0;
  }

  Future<int> deleteRule(int id) async {
    return await (_db.delete(_db.allocationRules)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

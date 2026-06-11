import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';

part 'allocation_rules_repository.g.dart';

@Riverpod(keepAlive: true)
AllocationRulesRepository allocationRulesRepository(Ref ref) {
  return AllocationRulesRepository(ref.watch(appDatabaseProvider));
}

class AllocationRulesRepository {
  final AppDatabase _db;

  AllocationRulesRepository(this._db);

  Future<List<AllocationRule>> getRules() async {
    return await _db.select(_db.allocationRules).get();
  }

  Future<int> createRule(String label, double percentage, bool isActive) async {
    return await _db.into(_db.allocationRules).insert(
      AllocationRulesCompanion.insert(
        label: label,
        percentage: percentage,
        isActive: Value(isActive),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<bool> updateRule(int id, String label, double percentage, bool isActive) async {
    return await (_db.update(_db.allocationRules)..where((t) => t.id.equals(id))).replace(
      AllocationRulesCompanion(
        label: Value(label),
        percentage: Value(percentage),
        isActive: Value(isActive),
      ),
    );
  }

  Future<bool> softDeleteRule(int id) async {
    return await (_db.update(_db.allocationRules)..where((t) => t.id.equals(id))).replace(
      AllocationRulesCompanion(
        isActive: Value(false),
      ),
    );
  }

  Future<int> deleteRule(int id) async {
    return await (_db.delete(_db.allocationRules)..where((t) => t.id.equals(id))).go();
  }
}

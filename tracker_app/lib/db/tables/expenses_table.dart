import 'package:drift/drift.dart';
import 'wallets_table.dart';
import 'allocation_rules_table.dart';
import 'budget_buckets_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get walletId => integer().nullable().references(Wallets, #id)();
  TextColumn get ownership => text().withDefault(const Constant('business'))();
  IntColumn get allocationRuleId => integer().nullable().references(AllocationRules, #id)();
  IntColumn get bucketId => integer().nullable().references(BudgetBuckets, #id)();
}

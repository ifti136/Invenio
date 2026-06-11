import 'package:drift/drift.dart';

class BudgetBuckets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  RealColumn get allocatedAmount => real().withDefault(const Constant(0.0))();
  TextColumn get color => text().nullable()();
  IntColumn get createdAt => integer()();
}

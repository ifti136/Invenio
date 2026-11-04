import 'package:drift/drift.dart';

class ExpenseCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get sort => integer().withDefault(const Constant(0))();
}

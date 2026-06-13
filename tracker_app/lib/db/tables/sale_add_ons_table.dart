import 'package:drift/drift.dart';
import 'add_on_types_table.dart';
import 'sales_table.dart';

class SaleAddOns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get addOnTypeId => integer().references(AddOnTypes, #id)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
}

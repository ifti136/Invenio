import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get priceMinor => integer()();
  IntColumn get costMinor => integer()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get lowStockAt => integer().withDefault(const Constant(3))();
  TextColumn get note => text().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

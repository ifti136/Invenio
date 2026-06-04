import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  RealColumn get costPrice => real()();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(3))();
  BoolColumn get alertEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}

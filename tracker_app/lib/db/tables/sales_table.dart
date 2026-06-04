import 'package:drift/drift.dart';
import 'products_table.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get sellingPrice => real()();
  RealColumn get total => real()();
  TextColumn get platform => text()();
  TextColumn get paymentStatus => text()();
  TextColumn get customerName => text().nullable()();
  BoolColumn get isDiscounted => boolean().withDefault(const Constant(false))();
  RealColumn get normalPrice => real().nullable()();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer()();
}

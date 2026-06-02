import 'package:drift/drift.dart';
import 'products_table.dart';

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  TextColumn get type => text()();
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
}

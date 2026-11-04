import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'products_table.dart';

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get type => text().withLength(min: 1, max: 20)();
  IntColumn get qty => integer()();
  IntColumn get unitCostMinor => integer().nullable()();
  IntColumn get accountId =>
      integer().nullable().references(Accounts, #id)();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}

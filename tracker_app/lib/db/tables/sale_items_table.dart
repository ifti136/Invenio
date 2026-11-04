import 'package:drift/drift.dart';
import 'products_table.dart';
import 'sales_table.dart';

class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get qty => integer()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get unitCostMinor => integer()();
}

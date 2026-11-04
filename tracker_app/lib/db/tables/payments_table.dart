import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'sales_table.dart';

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get amountMinor => integer()();
  IntColumn get paidAt => integer()();
  TextColumn get note => text().nullable()();
}

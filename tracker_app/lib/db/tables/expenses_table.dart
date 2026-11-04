import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'expense_categories_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(ExpenseCategories, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
}

import 'package:drift/drift.dart';
import 'accounts_table.dart';

class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();
  @ReferenceName('transfersFrom')
  IntColumn get fromAccountId => integer().references(Accounts, #id)();
  @ReferenceName('transfersTo')
  IntColumn get toAccountId => integer().references(Accounts, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}

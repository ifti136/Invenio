import 'package:drift/drift.dart';

import 'accounts_table.dart';

class Adjustments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}

import 'package:drift/drift.dart';

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currencySymbol =>
      text().withDefault(const Constant('\u09F3'))();
  TextColumn get shopName => text().nullable()();
}

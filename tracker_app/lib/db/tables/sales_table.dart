import 'package:drift/drift.dart';
import 'channels_table.dart';
import 'customers_table.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId =>
      integer().nullable().references(Customers, #id)();
  IntColumn get channelId => integer().references(Channels, #id)();
  IntColumn get totalMinor => integer()();
  TextColumn get status => text().withDefault(const Constant('paid'))();
  IntColumn get createdAt => integer()();
  IntColumn get legacyExtraCostMinor => integer().nullable()();
}

import 'package:drift/drift.dart';
import 'wallets_table.dart';

class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fromWalletId => integer().references(Wallets, #id)();
  IntColumn get toWalletId => integer().references(Wallets, #id)();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}

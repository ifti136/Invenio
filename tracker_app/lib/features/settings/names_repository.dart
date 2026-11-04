import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class NamesRepository {
  final AppDatabase _db;

  NamesRepository(this._db);

  Stream<List<Channel>> watchChannels() {
    final query = _db.select(_db.channels)
      ..orderBy([
        (c) => OrderingTerm(expression: c.sort),
        (c) => OrderingTerm(expression: c.id),
      ]);
    return query.watch();
  }

  Stream<List<ExpenseCategory>> watchExpenseCategories() {
    final query = _db.select(_db.expenseCategories)
      ..orderBy([
        (c) => OrderingTerm(expression: c.sort),
        (c) => OrderingTerm(expression: c.id),
      ]);
    return query.watch();
  }

  Future<void> renameChannel(int id, String name) async {
    final statement = _db.update(_db.channels)..where((c) => c.id.equals(id));
    await statement.write(ChannelsCompanion(name: Value(name)));
  }

  Future<void> renameExpenseCategory(int id, String name) async {
    final statement = _db.update(_db.expenseCategories)
      ..where((c) => c.id.equals(id));
    await statement.write(ExpenseCategoriesCompanion(name: Value(name)));
  }

  Future<int> addChannel(String name) async {
    final channels = await _db.select(_db.channels).get();
    final sort = channels.isEmpty ? 0 : channels.last.sort + 1;
    return _db.into(_db.channels).insert(
          ChannelsCompanion.insert(name: name, sort: Value(sort)),
        );
  }

  Future<int> addExpenseCategory(String name) async {
    final categories = await _db.select(_db.expenseCategories).get();
    final sort = categories.isEmpty ? 0 : categories.last.sort + 1;
    return _db.into(_db.expenseCategories).insert(
          ExpenseCategoriesCompanion.insert(name: name, sort: Value(sort)),
        );
  }
}

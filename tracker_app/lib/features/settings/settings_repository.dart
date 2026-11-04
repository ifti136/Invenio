import 'package:drift/drift.dart';

import '../../db/app_database.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Stream<Setting?> watchSettings() {
    return (_db.select(_db.settings)..limit(1)).watchSingleOrNull();
  }

  Future<Setting?> getSettings() {
    return (_db.select(_db.settings)..limit(1)).getSingleOrNull();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    await _ensureRow();
    await _db.update(_db.settings).write(
          SettingsCompanion(currencySymbol: Value(symbol)),
        );
  }

  Future<void> setShopName(String? name) async {
    await _ensureRow();
    await _db.update(_db.settings).write(
          SettingsCompanion(shopName: Value(name)),
        );
  }

  Future<void> _ensureRow() async {
    final existing = await getSettings();
    if (existing == null) {
      await _db.into(_db.settings).insert(const SettingsCompanion());
    }
  }
}

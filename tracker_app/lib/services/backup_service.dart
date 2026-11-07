import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import '../db/database_path.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  static const String dailyBackupKey = 'daily_backup_enabled';

  Future<bool> isDailyBackupEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(dailyBackupKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setDailyBackupEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(dailyBackupKey, enabled);
    } catch (_) {}
  }

  Future<File?> createDailyBackup({DateTime? now}) async {
    final dir = await appBackupDirectory();
    final stamp = _dateStamp(now ?? DateTime.now());
    final target = File(p.join(dir.path, 'invenio_$stamp.sqlite'));
    if (await target.exists()) return target;
    return _copyDatabase(target);
  }

  Future<File> exportDatabase() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final target = File(p.join(dir.path, 'invenio_$stamp.sqlite'));
    return _copyDatabase(target);
  }

  Future<void> shareDatabase() async {
    final file = await exportDatabase();
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invenio database backup',
    );
  }

  Future<void> runDailyBackupIfNeeded() async {
    try {
      if (!await isDailyBackupEnabled()) return;
      await createDailyBackup();
    } catch (_) {}
  }

  Future<File> _copyDatabase(File target) async {
    await _db.customStatement('PRAGMA wal_checkpoint(FULL)');
    final source = await appDatabaseFile();
    if (!await source.exists()) return target;
    return source.copy(target.path);
  }

  String _dateStamp(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(appDatabaseProvider));
});

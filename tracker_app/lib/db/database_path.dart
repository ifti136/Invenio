import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String databaseFileName = 'invenio.sqlite';
const String backupDirectoryName = 'backups';

Future<File> appDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, databaseFileName));
}

Future<Directory> appBackupDirectory() async {
  final dir = await getApplicationDocumentsDirectory();
  final backups = Directory(p.join(dir.path, backupDirectoryName));
  if (!await backups.exists()) {
    await backups.create(recursive: true);
  }
  return backups;
}

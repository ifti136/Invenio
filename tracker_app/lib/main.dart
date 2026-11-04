import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/backup_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  unawaited(
    container.read(backupServiceProvider).runDailyBackupIfNeeded(),
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TrackerApp(),
    ),
  );
}

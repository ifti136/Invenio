import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final appSettingsProvider = StreamProvider<Setting?>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

final currencySymbolProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull;
  return settings?.currencySymbol ?? '\u09F3';
});

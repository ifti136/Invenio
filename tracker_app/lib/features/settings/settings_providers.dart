import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'account_repository.dart';
import 'names_repository.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(appDatabaseProvider));
});

final namesRepositoryProvider = Provider<NamesRepository>((ref) {
  return NamesRepository(ref.watch(appDatabaseProvider));
});

final appSettingsProvider = StreamProvider<Setting?>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

final currencySymbolProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull;
  return settings?.currencySymbol ?? '\u09F3';
});

final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAccounts();
});

final archivedAccountsProvider = StreamProvider<List<Account>>((ref) {
  return ref
      .watch(accountRepositoryProvider)
      .watchAccounts(includeArchived: true);
});

final accountBalancesProvider = StreamProvider<List<AccountBalance>>((ref) {
  return ref.watch(accountRepositoryProvider).watchBalances();
});

final channelsProvider = StreamProvider<List<Channel>>((ref) {
  return ref.watch(namesRepositoryProvider).watchChannels();
});

final expenseCategoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(namesRepositoryProvider).watchExpenseCategories();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../settings/account_repository.dart';
import '../settings/settings_providers.dart';
import 'dues_repository.dart';
import 'expense_repository.dart';

final duesRepositoryProvider = Provider<DuesRepository>((ref) {
  return DuesRepository(ref.watch(appDatabaseProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(appDatabaseProvider));
});

final accountLedgerProvider =
    StreamProvider.family<AccountLedger?, int>((ref, accountId) {
  return ref.watch(accountRepositoryProvider).watchLedger(accountId);
});

final totalMoneyMinorProvider = Provider<int>((ref) {
  final balances = ref.watch(accountBalancesProvider).valueOrNull ?? const [];
  return balances.fold<int>(0, (sum, item) => sum + item.balanceMinor);
});

final duesListProvider = StreamProvider<List<CustomerDue>>((ref) {
  return ref.watch(duesRepositoryProvider).watchDues();
});

final duesTotalMinorProvider = Provider<int>((ref) {
  final dues = ref.watch(duesListProvider).valueOrNull ?? const [];
  return dues.fold<int>(0, (sum, item) => sum + item.dueMinor);
});

final customerDueDetailProvider =
    StreamProvider.family<CustomerDueDetail?, int>((ref, customerId) {
  return ref.watch(duesRepositoryProvider).watchDueDetail(customerId);
});

final expenseListProvider = StreamProvider<List<ExpenseItem>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchExpenses();
});

final expenseProvider =
    FutureProvider.family<ExpenseItem?, int>((ref, expenseId) {
  return ref.watch(expenseRepositoryProvider).getExpense(expenseId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import 'expense_repository.dart';

part 'expense_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<Expense>> expenseList(Ref ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
}

@Riverpod(keepAlive: true)
Stream<List<Expense>> filteredExpenseList(Ref ref, ExpenseFilter filter) {
  return ref.watch(expenseRepositoryProvider).watchFiltered(filter);
}

@riverpod
Future<Expense?> expenseDetail(Ref ref, int id) {
  return ref.watch(expenseRepositoryProvider).getById(id);
}

class ExpenseStats {
  final int count;
  final double total;

  const ExpenseStats({required this.count, required this.total});
}

ExpenseStats computeExpenseStats(List<Expense> expenses) {
  var total = 0.0;
  for (final e in expenses) {
    total += e.amount;
  }
  return ExpenseStats(count: expenses.length, total: total);
}

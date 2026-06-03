import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';

part 'expense_repository.g.dart';

enum ExpenseCategory { ads, delivery, packaging, misc }

extension ExpenseCategoryX on ExpenseCategory {
  String get key => name;
  String get label => switch (this) {
        ExpenseCategory.ads => 'Ads',
        ExpenseCategory.delivery => 'Delivery',
        ExpenseCategory.packaging => 'Packaging',
        ExpenseCategory.misc => 'Misc',
      };
  static ExpenseCategory fromKey(String k) =>
      ExpenseCategory.values.firstWhere((e) => e.key == k,
          orElse: () => ExpenseCategory.misc);
}

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepository(ref.watch(appDatabaseProvider));
}

class ExpenseRepository {
  ExpenseRepository(this._db);
  final AppDatabase _db;

  Stream<List<Expense>> watchAll() {
    final q = _db.select(_db.expenses)
      ..orderBy([(e) => drift.OrderingTerm.desc(e.date)]);
    return q.watch();
  }

  Stream<List<Expense>> watchFiltered(ExpenseFilter f) {
    final q = _db.select(_db.expenses);
    if (f.from != null) {
      q.where((e) =>
          e.date.isBiggerOrEqualValue(f.from!.millisecondsSinceEpoch));
    }
    if (f.to != null) {
      q.where((e) =>
          e.date.isSmallerOrEqualValue(f.to!.millisecondsSinceEpoch));
    }
    q.orderBy([(e) => drift.OrderingTerm.desc(e.date)]);
    return q.watch();
  }

  Future<Expense?> getById(int id) {
    return (_db.select(_db.expenses)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> add({
    required double amount,
    required String category,
    String? note,
    DateTime? date,
  }) {
    final effectiveDate = date ?? DateTime.now();
    return _db.into(_db.expenses).insert(ExpensesCompanion.insert(
      amount: amount,
      category: category,
      note: drift.Value(note),
      date: effectiveDate.millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> update({
    required int id,
    required double amount,
    required String category,
    String? note,
    DateTime? date,
  }) {
    final effectiveDate = date ?? DateTime.now();
    return (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
      ExpensesCompanion(
        amount: drift.Value(amount),
        category: drift.Value(category),
        note: drift.Value(note),
        date: drift.Value(effectiveDate.millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> delete(int id) {
    return (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
  }

  Future<double> totalForPeriod(DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.expenses)
          ..where((e) =>
              e.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              e.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();
    var total = 0.0;
    for (final e in rows) {
      total += e.amount;
    }
    return total;
  }
}

class ExpenseFilter {
  final DateTime? from;
  final DateTime? to;

  const ExpenseFilter({this.from, this.to});

  ExpenseFilter copyWith({
    Object? from = _sentinel,
    Object? to = _sentinel,
  }) {
    return ExpenseFilter(
      from: from == _sentinel ? this.from : from as DateTime?,
      to: to == _sentinel ? this.to : to as DateTime?,
    );
  }

  ExpenseFilter clear() => const ExpenseFilter();

  static const _sentinel = Object();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseFilter &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(from, to);
}

class DateRangePreset {
  final String label;
  final DateTime from;
  final DateTime? to;
  const DateRangePreset(this.label, this.from, this.to);
}

List<DateRangePreset> dateRangePresets() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    DateRangePreset('All time', DateTime(2000), null),
    DateRangePreset('Today', today, null),
    DateRangePreset('This week',
        today.subtract(Duration(days: today.weekday - 1)), null),
    DateRangePreset('This month', DateTime(now.year, now.month, 1), null),
    DateRangePreset('Last 30 days', today.subtract(const Duration(days: 30)),
        null),
  ];
}


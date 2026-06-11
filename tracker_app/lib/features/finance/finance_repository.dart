import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../db/tables/expenses_table.dart';
import '../../db/tables/sales_table.dart';
import '../../db/tables/allocation_rules_table.dart';

part 'finance_repository.g.dart';

@Riverpod(keepAlive: true)
FinanceRepository financeRepository(Ref ref) {
  return FinanceRepository(ref.watch(appDatabaseProvider));
}

class FinanceRepository {
  final AppDatabase _db;

  FinanceRepository(this._db);

  Future<Map<int, RuleFinancials>> getRuleFinancials() async {
    final rules = await _db.select(_db.allocationRules).get();
    final financials = <int, RuleFinancials>{};

    // Total Business Profit = ΣSales(business) - ΣExpenses(business)
    final businessSales = await (_db.select(_db.sales)..where((s) => s.ownership.equals('business'))).get();
    final businessRevenue = businessSales.fold(0.0, (sum, s) => sum + s.total);
    
    final businessExpenses = await (_db.select(_db.expenses)..where((e) => e.ownership.equals('business'))).get();
    final totalBusinessExpenses = businessExpenses.fold(0.0, (sum, e) => sum + e.amount);
    
    final totalBusinessProfit = businessRevenue - totalBusinessExpenses;

    for (final rule in rules) {
      // Accumulated Profit = Total Business Profit * (rule.percentage / 100)
      final accumulatedProfit = totalBusinessProfit * (rule.percentage / 100);
      
      // Total Spent = ΣExpenses(where allocationRuleId == rule.id)
      final ruleExpenses = await (_db.select(_db.expenses)..where((e) => e.allocationRuleId.equals(rule.id))).get();
      final totalSpent = ruleExpenses.fold(0.0, (sum, e) => sum + e.amount);
      
      financials[rule.id] = RuleFinancials(
        accumulatedProfit: accumulatedProfit,
        totalSpent: totalSpent,
        availableBalance: accumulatedProfit - totalSpent,
      );
    }

    return financials;
  }

  Future<double> getAvailableBalance(int ruleId) async {
    final financials = await getRuleFinancials();
    return financials[ruleId]?.availableBalance ?? 0.0;
  }

  Future<List<RuleMonthlyDetail>> getRuleMonthlyHistory(int ruleId) async {
    final rules = await _db.select(_db.allocationRules).get();
    final rule = rules.firstWhere((r) => r.id == ruleId);
    final percentage = rule.percentage / 100;

    // Fetch all business transactions from the beginning
    final sales = await (_db.select(_db.sales)..where((s) => s.ownership.equals('business'))).get();
    final expenses = await (_db.select(_db.expenses)..where((e) => e.ownership.equals('business'))).get();

    // Group by month
    final monthlyProfit = <String, double>{};
    final monthlyExpenses = <String, double>{};

    for (final s in sales) {
      final date = DateTime.fromMillisecondsSinceEpoch(s.date);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyProfit[key] = (monthlyProfit[key] ?? 0.0) + s.total;
    }

    for (final e in expenses) {
      final date = DateTime.fromMillisecondsSinceEpoch(e.date);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      // Only count expenses allocated to this rule
      if (e.allocationRuleId == ruleId) {
        monthlyExpenses[key] = (monthlyExpenses[key] ?? 0.0) + e.amount;
      }
    }

    final allMonths = (monthlyProfit.keys.toList()..sort());
    
    double runningBalance = 0.0;
    final history = <RuleMonthlyDetail>[];

    for (final month in allMonths) {
      final profit = monthlyProfit[month] ?? 0.0;
      final allocated = profit * percentage;
      final charged = monthlyExpenses[month] ?? 0.0;
      
      runningBalance += (allocated - charged);
      
      history.add(RuleMonthlyDetail(
        month: month,
        monthlyProfit: profit,
        amountAllocated: allocated,
        expensesCharged: charged,
        runningBalance: runningBalance,
      ));
    }

    return history;
  }
}

class RuleMonthlyDetail {
  final String month;
  final double monthlyProfit;
  final double amountAllocated;
  final double expensesCharged;
  final double runningBalance;

  RuleMonthlyDetail({
    required this.month,
    required this.monthlyProfit,
    required this.amountAllocated,
    required this.expensesCharged,
    required this.runningBalance,
  });
}

class MonthlyAllocation {

  final String month;
  final double totalProfit;
  final Map<int, double> ruleAllocations;

  MonthlyAllocation({
    required this.month,
    required this.totalProfit,
    required this.ruleAllocations,
  });
}

class RuleFinancials {
  final double accumulatedProfit;
  final double totalSpent;
  final double availableBalance;

  RuleFinancials({
    required this.accumulatedProfit,
    required this.totalSpent,
    required this.availableBalance,
  });
}

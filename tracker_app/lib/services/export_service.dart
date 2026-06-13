import 'dart:io';
import 'package:drift/drift.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import '../db/app_database.dart';
import '../core/utils/profit_calculator.dart';

class ExportService {
  final AppDatabase _db;
  ExportService(this._db);

  Future<Workbook> buildWorkbook(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final sales = await (_db.select(_db.sales)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              t.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final allAddOns = await (_db.select(_db.saleAddOns)
          ..where((s) => s.saleId.isIn(sales.map((s) => s.id))))
        .get();

    final addOnsMap = {
      for (final s in sales)
        s.id: allAddOns.where((a) => a.saleId == s.id).toList()
    };

    final expenses = await (_db.select(_db.expenses)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              t.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final products = await _db.select(_db.products).get();
    final productMap = {for (final p in products) p.id: p};

    final workbook = Workbook();

    final salesSheet = workbook.worksheets[0];
    salesSheet.name = 'Sales';
    final salesHeaders = [
      'Date',
      'Product',
      'Qty',
      'Cost Price',
      'Sell Price',
      'Add-Ons',
      'Profit',
      'Platform',
      'Status',
    ];
    for (var i = 0; i < salesHeaders.length; i++) {
      salesSheet.getRangeByIndex(1, i + 1).setText(salesHeaders[i]);
    }
    for (var r = 0; r < sales.length; r++) {
      final s = sales[r];
      final p = productMap[s.productId];
      final addOns = addOnsMap[s.id] ?? [];
      final profit =
          ProfitCalculator.calculateNetProfit(s, p?.costPrice ?? 0, addOns);
      final addOnTotal = ProfitCalculator.calculateAddOnCost(addOns);
      final row = [
        DateTime.fromMillisecondsSinceEpoch(s.date).toString().substring(0, 10),
        p?.name ?? 'Unknown',
        s.quantity.toString(),
        p?.costPrice.toStringAsFixed(2) ?? '-',
        s.sellingPrice.toStringAsFixed(2),
        addOnTotal.toStringAsFixed(2),
        profit.toStringAsFixed(2),
        s.platform,
        s.paymentStatus,
      ];
      for (var c = 0; c < row.length; c++) {
        salesSheet.getRangeByIndex(r + 2, c + 1).setText(row[c]);
      }
    }

    workbook.worksheets.addWithName('Expenses');
    final expSheet = workbook.worksheets[1];
    final expHeaders = ['Date', 'Category', 'Amount', 'Note'];
    for (var i = 0; i < expHeaders.length; i++) {
      expSheet.getRangeByIndex(1, i + 1).setText(expHeaders[i]);
    }
    for (var r = 0; r < expenses.length; r++) {
      final e = expenses[r];
      final row = [
        DateTime.fromMillisecondsSinceEpoch(e.date).toString().substring(0, 10),
        e.category,
        e.amount.toStringAsFixed(2),
        e.note ?? '',
      ];
      for (var c = 0; c < row.length; c++) {
        expSheet.getRangeByIndex(r + 2, c + 1).setText(row[c]);
      }
    }

    // Add Summary sheet
    workbook.worksheets.addWithName('Summary');
    final sumSheet = workbook.worksheets[2];

    // Compute totals from the already-fetched sales/expenses data
    double grossProfit = 0;
    double fbProfit = 0;
    double offlineProfit = 0;
    for (final s in sales) {
      final p = productMap[s.productId];
      final addOns = addOnsMap[s.id] ?? [];
      final profit =
          ProfitCalculator.calculateNetProfit(s, p?.costPrice ?? 0, addOns);
      grossProfit += profit;
      if (s.platform == 'facebook') {
        fbProfit += profit;
      } else {
        offlineProfit += profit;
      }
    }
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final netProfit = grossProfit - totalExpenses;

    // Write summary rows
    final summaryRows = [
      ['Gross Profit', grossProfit.toStringAsFixed(2)],
      ['Total Expenses', totalExpenses.toStringAsFixed(2)],
      ['Net Profit', netProfit.toStringAsFixed(2)],
      ['Facebook Profit', fbProfit.toStringAsFixed(2)],
      ['Offline Profit', offlineProfit.toStringAsFixed(2)],
    ];
    for (var r = 0; r < summaryRows.length; r++) {
      sumSheet.getRangeByIndex(r + 1, 1).setText(summaryRows[r][0]);
      sumSheet.getRangeByIndex(r + 1, 2).setText(summaryRows[r][1]);
    }

    // Top 5 products by profit (optional but spec-required)
    final productProfits = <int, double>{};
    for (final s in sales) {
      final p = productMap[s.productId];
      final addOns = addOnsMap[s.id] ?? [];
      final profit =
          ProfitCalculator.calculateNetProfit(s, p?.costPrice ?? 0, addOns);
      productProfits.update(s.productId, (value) => value + profit,
          ifAbsent: () => profit);
    }
    final sorted = productProfits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sorted.take(5).toList();
    for (var i = 0; i < topProducts.length; i++) {
      final entry = topProducts[i];
      final product = productMap[entry.key];
      sumSheet.getRangeByIndex(i + 7, 1).setText(product?.name ?? 'Unknown');
      sumSheet
          .getRangeByIndex(i + 7, 2)
          .setText(entry.value.toStringAsFixed(2));
    }

    return workbook;
  }

  Future<void> exportMonth(DateTime month) async {
    final workbook = await buildWorkbook(month);
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final fileName =
        'tracker_${month.year}_${month.month.toString().padLeft(2, '0')}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Tracker export — ${month.year}/${month.month}');
  }
}

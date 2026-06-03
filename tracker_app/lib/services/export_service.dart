import 'dart:io';
import 'package:drift/drift.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import '../db/app_database.dart';

class ExportService {
  final AppDatabase _db;
  ExportService(this._db);

  Future<void> exportMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final sales = await (_db.select(_db.sales)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              t.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

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
      final profit = (s.sellingPrice - (p?.costPrice ?? 0)) * s.quantity;
      final row = [
        DateTime.fromMillisecondsSinceEpoch(s.date)
            .toString()
            .substring(0, 10),
        p?.name ?? 'Unknown',
        s.quantity.toString(),
        p?.costPrice.toStringAsFixed(2) ?? '-',
        s.sellingPrice.toStringAsFixed(2),
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
        DateTime.fromMillisecondsSinceEpoch(e.date)
            .toString()
            .substring(0, 10),
        e.category,
        e.amount.toStringAsFixed(2),
        e.note ?? '',
      ];
      for (var c = 0; c < row.length; c++) {
        expSheet.getRangeByIndex(r + 2, c + 1).setText(row[c]);
      }
    }

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

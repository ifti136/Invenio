import '../../db/app_database.dart';

extension ExpenseX on Expense {
  DateTime get dateAsDateTime => DateTime.fromMillisecondsSinceEpoch(date);
}

extension SaleX on Sale {
  DateTime get dateAsDateTime => DateTime.fromMillisecondsSinceEpoch(date);
}
import 'package:intl/intl.dart';

final _moneyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '৳',
  decimalDigits: 2,
);

final _dateFormat = DateFormat('d MMM yyyy');
final _dateTimeFormat = DateFormat('d MMM yyyy, h:mm a');
final _dayFormat = DateFormat('d MMM');

String formatDate(DateTime d) => _dateFormat.format(d);
String formatDateTime(DateTime d) => _dateTimeFormat.format(d);
String formatDay(DateTime d) => _dayFormat.format(d);
String formatMoney(double v) => _moneyFormat.format(v);
String formatQuantity(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

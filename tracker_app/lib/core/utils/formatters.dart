import 'package:intl/intl.dart';

String _currencySymbol = '৳';

final _dateFormat = DateFormat('d MMM yyyy');
final _dateTimeFormat = DateFormat('d MMM yyyy, h:mm a');
final _dayFormat = DateFormat('d MMM');

String formatDate(DateTime d) => _dateFormat.format(d);
String formatDateTime(DateTime d) => _dateTimeFormat.format(d);
String formatDay(DateTime d) => _dayFormat.format(d);

String formatMoney(double v) {
  return NumberFormat.currency(
    locale: 'en_IN',
    symbol: _currencySymbol,
    decimalDigits: 2,
  ).format(v);
}

String formatQuantity(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

/// Synchronizes the currency symbol used by [formatMoney].
/// Call this whenever the user changes the currency symbol.
void setCurrencySymbol(String symbol) {
  _currencySymbol = symbol;
}

import 'package:intl/intl.dart';

class Money implements Comparable<Money> {
  final int minor;

  const Money(this.minor);

  static const Money zero = Money(0);

  factory Money.fromMajor(num major) {
    if (major is int) return Money(major * 100);
    return Money(_parseDecimalToMinor(major.toString()));
  }

  factory Money.parse(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[^0-9.,\-]'), '')
        .replaceAll(',', '')
        .trim();
    if (cleaned.isEmpty || cleaned == '-') return zero;
    return Money(_parseDecimalToMinor(cleaned));
  }

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;
  bool get isPositive => minor > 0;

  Money get abs => Money(minor.abs());

  Money operator +(Money other) => Money(minor + other.minor);
  Money operator -(Money other) => Money(minor - other.minor);
  Money operator *(int quantity) => Money(minor * quantity);
  Money operator -() => Money(-minor);

  bool operator <(Money other) => minor < other.minor;
  bool operator <=(Money other) => minor <= other.minor;
  bool operator >(Money other) => minor > other.minor;
  bool operator >=(Money other) => minor >= other.minor;

  String format({required String currencySymbol, String? locale}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol,
      decimalDigits: 0,
    );
    final absolute = minor.abs();
    final whole = formatter.format(absolute ~/ 100);
    final cents = (absolute % 100).toString().padLeft(2, '0');
    final sign = minor < 0 ? '-' : '';
    return '$sign$whole${formatter.symbols.DECIMAL_SEP}$cents';
  }

  @override
  int compareTo(Money other) => minor.compareTo(other.minor);

  @override
  bool operator ==(Object other) => other is Money && other.minor == minor;

  @override
  int get hashCode => minor.hashCode;

  @override
  String toString() => 'Money($minor)';
}

int _parseDecimalToMinor(String input) {
  final match =
      RegExp(r'^([+-]?)(\d*)(?:\.(\d*))?$').firstMatch(input.trim());
  if (match == null) return 0;
  final wholeText = match.group(2) ?? '';
  final fractionText = match.group(3) ?? '';
  if (wholeText.isEmpty && fractionText.isEmpty) return 0;
  final sign = match.group(1) == '-' ? -1 : 1;
  try {
    final whole = wholeText.isEmpty ? 0 : int.parse(wholeText);
    final fraction = fractionText.padRight(3, '0');
    final hundredths = int.parse(fraction.substring(0, 2));
    final roundUp = fraction.codeUnitAt(2) >= 0x35;
    return sign * (whole * 100 + hundredths + (roundUp ? 1 : 0));
  } on FormatException {
    return 0;
  }
}

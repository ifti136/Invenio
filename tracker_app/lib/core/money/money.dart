import 'package:intl/intl.dart';

class Money implements Comparable<Money> {
  final int minor;

  const Money(this.minor);

  static const Money zero = Money(0);

  factory Money.fromMajor(num major) => Money((major * 100).round());

  factory Money.parse(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[^0-9.,\-]'), '')
        .replaceAll(',', '')
        .trim();
    if (cleaned.isEmpty || cleaned == '-') return zero;
    return Money.fromMajor(double.tryParse(cleaned) ?? 0);
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
      decimalDigits: 2,
    );
    return formatter.format(minor / 100);
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

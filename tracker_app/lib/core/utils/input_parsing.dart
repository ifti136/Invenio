import '../money/money.dart';

Money? parseMoneyInput(String raw, {bool allowNegative = false}) {
  final cleaned = raw
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9.\-]'), '')
      .trim();
  if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') return null;
  final value = double.tryParse(cleaned);
  if (value == null) return null;
  if (!allowNegative && value < 0) return null;
  return Money.fromMajor(value);
}

int? parseWholeNumber(String raw, {int min = 0}) {
  final value = int.tryParse(raw.trim());
  if (value == null || value < min) return null;
  return value;
}

String moneyToInput(Money money) => (money.minor / 100).toStringAsFixed(2);

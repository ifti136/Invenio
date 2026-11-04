import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/money/money.dart';

void main() {
  group('Money', () {
    test('stores integer minor units', () {
      expect(const Money(1250).minor, 1250);
    });

    test('fromMajor rounds to minor units', () {
      expect(Money.fromMajor(12.345).minor, 1235);
      expect(Money.fromMajor(12).minor, 1200);
    });

    test('parse ignores currency symbols and grouping', () {
      expect(Money.parse('\$1,234.50').minor, 123450);
      expect(Money.parse('-12.30').minor, -1230);
      expect(Money.parse('').minor, 0);
    });

    test('supports arithmetic and comparison', () {
      const a = Money(1000);
      const b = Money(250);
      expect((a + b).minor, 1250);
      expect((a - b).minor, 750);
      expect((a * 3).minor, 3000);
      expect(-a.minor, -1000);
      expect(a > b, true);
      expect(b <= a, true);
      expect(a.abs.minor, 1000);
    });

    test('formats with the supplied symbol and locale', () {
      const money = Money(123450);
      expect(
        money.format(currencySymbol: '\$', locale: 'en_US'),
        '\$1,234.50',
      );
    });

    test('formats negative amounts', () {
      const money = Money(-500);
      expect(
        money.format(currencySymbol: '\$', locale: 'en_US'),
        '-\$5.00',
      );
    });
  });
}

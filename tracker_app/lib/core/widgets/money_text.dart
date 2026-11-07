import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/settings_providers.dart';
import '../money/money.dart';
import '../theme/app_tokens.dart';

class MoneyText extends ConsumerWidget {
  final Money money;
  final TextStyle? style;
  final String? currencySymbol;
  final String? locale;
  final bool showSign;
  final TextAlign textAlign;

  const MoneyText(
    this.money, {
    super.key,
    this.style,
    this.currencySymbol,
    this.locale,
    this.showSign = false,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String symbol = currencySymbol ?? ref.watch(currencySymbolProvider);
    final formatted = _format(symbol);
    final baseStyle = style ?? Theme.of(context).textTheme.bodyLarge;

    return Text(
      formatted,
      textAlign: textAlign,
      style: baseStyle?.copyWith(fontFeatures: AppTextStyles.tabular),
    );
  }

  String _format(String symbol) {
    if (!showSign) return money.format(currencySymbol: symbol, locale: locale);
    final sign = money.isNegative ? '\u2212' : '+';
    return '$sign${money.abs.format(currencySymbol: symbol, locale: locale)}';
  }
}

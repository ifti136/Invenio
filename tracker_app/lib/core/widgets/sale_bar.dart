import 'package:flutter/material.dart';

import '../money/money.dart';
import '../theme/app_tokens.dart';
import 'money_text.dart';

class SaleBar extends StatelessWidget {
  final Money total;
  final Money profit;
  final String actionLabel;
  final VoidCallback? onAction;

  const SaleBar({
    super.key,
    required this.total,
    required this.profit,
    this.actionLabel = 'Save sale',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profitColor = profit.isNegative ? scheme.error : scheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MoneyText(
                        total,
                        style: AppTextStyles.headline.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: MoneyText(
                        profit,
                        showSign: true,
                        style: AppTextStyles.body.copyWith(color: profitColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

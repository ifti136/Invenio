import 'package:flutter/material.dart';

import '../money/money.dart';
import '../theme/app_tokens.dart';
import 'money_text.dart';
import 'stock_badge.dart';

class ProductTile extends StatelessWidget {
  final String name;
  final Money price;
  final int stock;
  final int lowStockAt;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onSell;

  const ProductTile({
    super.key,
    required this.name,
    required this.price,
    required this.stock,
    required this.lowStockAt,
    this.subtitle,
    this.onTap,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.input),
                ),
                child: Text(
                  initial,
                  style: AppTextStyles.title.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        MoneyText(
                          price,
                          style: AppTextStyles.body.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StockBadge(stock: stock, lowStockAt: lowStockAt),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onSell != null) ...[
                const SizedBox(width: AppSpacing.sm),
                FilledButton.tonal(
                  onPressed: onSell,
                  child: const Text('Sell'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

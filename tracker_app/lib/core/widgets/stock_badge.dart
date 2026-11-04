import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class StockBadge extends StatelessWidget {
  final int stock;
  final int lowStockAt;

  const StockBadge({
    super.key,
    required this.stock,
    required this.lowStockAt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, icon, color) = _appearance(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  (String, IconData, Color) _appearance(ColorScheme scheme) {
    if (stock <= 0) {
      return ('Out', Icons.error_outline, scheme.error);
    }
    if (stock <= lowStockAt) {
      return ('Low', Icons.warning_amber_outlined, scheme.tertiary);
    }
    return ('In stock', Icons.check_circle_outline, scheme.primary);
  }
}

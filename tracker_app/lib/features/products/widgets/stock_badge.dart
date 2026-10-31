import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StockBadge extends StatelessWidget {
  final int stock;
  final int? threshold;
  final bool compact;

  const StockBadge({
    super.key,
    required this.stock,
    this.threshold,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = threshold ?? 5;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color;
    final String label;
    if (stock <= 0) {
      color = AppColors.danger;
      label = 'Out';
    } else if (stock <= t) {
      color = AppColors.warning;
      label = 'Low';
    } else {
      color = AppColors.success;
      label = 'In stock';
    }

    final ink = isDark
        ? color
        : (stock <= 0
            ? AppColors.dangerInkLight
            : stock <= t
                ? AppColors.warningInkLight
                : AppColors.accentInkLight);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ink.withOpacity(0.35), width: 0.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ink,
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

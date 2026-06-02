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
    final Color bg;
    final Color fg;
    final String label;
    if (stock <= 0) {
      bg = AppColors.danger.withOpacity(0.18);
      fg = AppColors.danger;
      label = 'Out';
    } else if (stock <= t) {
      bg = AppColors.warning.withOpacity(0.18);
      fg = AppColors.warning;
      label = 'Low';
    } else {
      bg = AppColors.success.withOpacity(0.18);
      fg = AppColors.success;
      label = 'In stock';
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.35), width: 0.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 12,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

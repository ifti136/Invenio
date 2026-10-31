import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'glass_panel.dart';

enum StatTone { neutral, accent, warning, danger }

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final StatTone tone;
  final String? caption;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone = StatTone.neutral,
    this.caption,
    this.trailing,
  });

  Color _toneColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (tone) {
      case StatTone.accent:
        return isDark ? AppColors.accentInkDark : AppColors.accentInkLight;
      case StatTone.warning:
        return isDark ? AppColors.warning : AppColors.warningInkLight;
      case StatTone.danger:
        return isDark ? AppColors.danger : AppColors.dangerInkLight;
      case StatTone.neutral:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _toneColor(context);

    return GlassPanel(
      radius: AppRadii.tile,
      noBlur: true,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs + 2),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.title.copyWith(color: color),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

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

  Color _toneColor(ColorScheme scheme) {
    switch (tone) {
      case StatTone.accent:
        return scheme.primary;
      case StatTone.warning:
        return scheme.tertiary;
      case StatTone.danger:
        return scheme.error;
      case StatTone.neutral:
        return scheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _toneColor(scheme);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
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
                  label,
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
              style: AppTextStyles.headline.copyWith(color: color),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

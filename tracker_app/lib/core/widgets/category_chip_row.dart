import 'package:flutter/material.dart';

import '../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedInk =
        isDark ? AppColors.accentInkDark : AppColors.accentInkLight;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: () {
          HapticService.trigger(HapticProfile.light);
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withOpacity(isDark ? 0.22 : 0.18)
                : (isDark
                    ? Colors.white.withOpacity(0.04)
                    : scheme.surface.withOpacity(0.42)),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected
                  ? scheme.primary.withOpacity(0.5)
                  : scheme.onSurfaceVariant.withOpacity(0.18),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? selectedInk : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? selectedInk : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChipRow extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const CategoryChipRow({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }
}

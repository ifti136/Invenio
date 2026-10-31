import 'package:flutter/material.dart';

import '../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'glass_panel.dart';

class QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = AppColors.accentInkFor(Theme.of(context).brightness);

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: primary ? AppSpacing.lg : AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: primary ? 22 : 20,
              color: primary ? AppColors.onAccent : ink,
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: primary ? 15 : 14,
                  fontWeight: primary ? FontWeight.w700 : FontWeight.w600,
                  color: primary ? AppColors.onAccent : scheme.onSurface,
                ),
              ),
            ),
            if (primary)
              const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: AppColors.onAccent,
              ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: primary ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        clipBehavior: Clip.antiAlias,
        child: primary
            ? InkWell(
                onTap: () {
                  HapticService.trigger(HapticProfile.light);
                  onTap();
                },
                child: content,
              )
            : GlassPanel(
                radius: AppRadii.tile,
                noBlur: true,
                padding: EdgeInsets.zero,
                child: InkWell(
                  onTap: () {
                    HapticService.trigger(HapticProfile.light);
                    onTap();
                  },
                  child: content,
                ),
              ),
      ),
    );
  }
}

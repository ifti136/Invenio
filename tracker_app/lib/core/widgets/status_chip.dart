import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

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
    switch (status) {
      case 'partial':
        return ('Part paid', Icons.schedule, scheme.tertiary);
      case 'due':
        return ('Due', Icons.error_outline, scheme.error);
      case 'paid':
      default:
        return ('Paid', Icons.check_circle_outline, scheme.primary);
    }
  }
}

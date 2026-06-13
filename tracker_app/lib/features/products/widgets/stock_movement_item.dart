import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../db/app_database.dart';

class StockMovementItem extends StatelessWidget {
  final StockMovement movement;
  final String? productName;

  const StockMovementItem({
    super.key,
    required this.movement,
    this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPositive = movement.quantity > 0;
    final color = isPositive ? AppColors.success : AppColors.danger;
    final typeLabel = _typeLabel(movement.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (productName != null) productName!,
                    formatDateTime(
                        DateTime.fromMillisecondsSinceEpoch(movement.date)),
                  ].join(' • '),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (movement.note != null && movement.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    movement.note!,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isPositive ? '+' : ''}${movement.quantity}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'initial':
        return 'Initial stock';
      case 'restock':
        return 'Restock';
      case 'sale':
        return 'Sale';
      case 'adjustment':
        return 'Adjustment';
      default:
        return type;
    }
  }
}

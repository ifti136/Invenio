import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../db/app_database.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/glass_panel.dart';
import 'stock_badge.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductTile({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentInk = AppColors.accentInkFor(Theme.of(context).brightness);

    return GlassPanel(
      radius: AppRadii.tile,
      noBlur: true,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticService.trigger(HapticProfile.light);
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    product.name.isNotEmpty
                        ? product.name.characters.first.toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: accentInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            formatMoney(product.costPrice),
                            style: AppTextStyles.label.copyWith(
                              color: scheme.onSurfaceVariant,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StockBadge(
                            stock: product.stock,
                            threshold: product.lowStockThreshold,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!product.alertEnabled)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 18,
                      color: scheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

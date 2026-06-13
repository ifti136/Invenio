import 'package:flutter/material.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/db/app_database.dart';

class SaleListItem extends StatelessWidget {
  final Sale sale;
  final String? productName;
  final bool showProductName;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onDelete;

  const SaleListItem({
    super.key,
    required this.sale,
    this.productName,
    this.showProductName = true,
    this.onTap,
    this.onMarkPaid,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPaid = sale.paymentStatus == 'paid';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: isPaid ? AppColors.success : AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showProductName)
                      Text(
                        productName ?? 'Product #${sale.productId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                    Text(
                      '${formatQuantity(sale.quantity.toDouble())} × ${formatMoney(sale.sellingPrice)} • ${formatDate(DateTime.fromMillisecondsSinceEpoch(sale.date))}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatMoney(sale.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

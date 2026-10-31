import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/theme/app_tokens.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/sales/sale_repository.dart';

String buildReceiptText(Sale sale, String productName) {
  final platform = SalePlatformX.fromKey(sale.platform).label;
  final payment = PaymentStatusX.fromKey(sale.paymentStatus).label;
  final customer = sale.customerName?.trim();
  return [
    'Invenio receipt',
    productName,
    '${sale.quantity} × ${formatMoney(sale.sellingPrice)}',
    'Total: ${formatMoney(sale.total)}',
    if (customer != null && customer.isNotEmpty) 'Customer: $customer',
    'Platform: $platform',
    'Payment: $payment',
  ].join('\n');
}

class ReceiptSheet extends StatelessWidget {
  final Sale sale;
  final String productName;

  const ReceiptSheet({
    super.key,
    required this.sale,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final payment = PaymentStatusX.fromKey(sale.paymentStatus);
    final customer = sale.customerName?.trim();

    return GlassPanel(
      radius: AppRadii.sheet,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      noBlur: true,
      opaque: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.accentInkFor(theme.brightness),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt',
                      style: AppTextStyles.title.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      'Sale #${sale.id} · ${formatDateTime(DateTime.fromMillisecondsSinceEpoch(sale.date))}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'TOTAL',
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(sale.total),
              maxLines: 1,
              style: AppTextStyles.display.copyWith(
                color: AppColors.accentInkFor(theme.brightness),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPanel.flush(
            noBlur: true,
            opaque: true,
            padding: const EdgeInsets.all(AppSpacing.md),
            expand: false,
            child: Column(
              children: [
                _ReceiptRow(
                  label: '${sale.quantity} ×',
                  value: formatMoney(sale.sellingPrice),
                ),
                if (customer != null && customer.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ReceiptRow(label: 'Customer', value: customer),
                ],
                const SizedBox(height: AppSpacing.sm),
                _ReceiptRow(
                  label: 'Platform',
                  value: SalePlatformX.fromKey(sale.platform).label,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payment',
                        style: AppTextStyles.label.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _PaymentPill(payment: payment),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      Share.share(buildReceiptText(sale, productName)),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Share receipt'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: AppTextStyles.tabular,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentPill extends StatelessWidget {
  final PaymentStatus payment;

  const _PaymentPill({required this.payment});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final paid = payment == PaymentStatus.paid;
    final color = paid
        ? AppColors.accentInkFor(brightness)
        : AppColors.warningInkFor(brightness);
    final iconData = paid ? Icons.check_rounded : Icons.schedule_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            payment.label,
            style: AppTextStyles.label.copyWith(
              color: color,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showReceiptSheet(
  BuildContext context, {
  required Sale sale,
  required String productName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: math.max(
              MediaQuery.of(context).viewInsets.bottom,
              kBottomNavHeight + 8,
            ),
          ),
          child: ReceiptSheet(sale: sale, productName: productName),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/money_text.dart';
import '../settings/settings_providers.dart';
import 'sale_models.dart';

Future<void> showReceiptSheet(
  BuildContext context,
  SaleReceipt receipt,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ReceiptSheet(receipt: receipt),
  );
}

String buildReceiptText(
  SaleReceipt receipt, {
  required String currencySymbol,
  String? shopName,
}) {
  final buffer = StringBuffer();
  final title =
      shopName == null || shopName.trim().isEmpty ? 'Receipt' : shopName.trim();
  buffer.writeln(title);
  buffer.writeln('Sale #${receipt.saleId}');
  if (receipt.customerName != null) {
    buffer.writeln('Customer: ${receipt.customerName}');
  }
  buffer.writeln();
  for (final line in receipt.lines) {
    final total = Money(line.totalMinor).format(
      currencySymbol: currencySymbol,
    );
    buffer.writeln('${line.name} ×${line.qty}  $total');
  }
  buffer.writeln();
  buffer.writeln(
    'Total: ${Money(receipt.totalMinor).format(currencySymbol: currencySymbol)}',
  );
  buffer.writeln(
    'Paid: ${Money(receipt.paidMinor).format(currencySymbol: currencySymbol)}',
  );
  buffer.writeln(
    'Due: ${Money(receipt.dueMinor).format(currencySymbol: currencySymbol)}',
  );
  return buffer.toString().trim();
}

SaleReceipt receiptFromDetail(SaleDetail detail) {
  final paid = detail.payments.fold<int>(0, (sum, p) => sum + p.amountMinor);
  return SaleReceipt(
    saleId: detail.sale.id,
    customerName: detail.customerName,
    status: detail.sale.status,
    lines: [
      for (final line in detail.lines)
        SaleReceiptLine(
          name: line.productName,
          qty: line.qty,
          unitPriceMinor: line.unitPriceMinor,
        ),
    ],
    totalMinor: detail.sale.totalMinor,
    paidMinor: paid,
    dueMinor: detail.sale.totalMinor - paid,
  );
}

void shareReceipt(
  BuildContext context,
  WidgetRef ref,
  SaleReceipt receipt,
) {
  final symbol = ref.read(currencySymbolProvider);
  final shopName = ref.read(appSettingsProvider).valueOrNull?.shopName;
  Share.share(
    buildReceiptText(
      receipt,
      currencySymbol: symbol,
      shopName: shopName,
    ),
  );
}

class ReceiptSheet extends ConsumerWidget {
  final SaleReceipt receipt;

  const ReceiptSheet({super.key, required this.receipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text('Sale complete', style: AppTextStyles.title),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                itemCount: receipt.lines.length,
                itemBuilder: (context, index) {
                  final line = receipt.lines[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(line.name),
                      subtitle: Text(
                        '${line.qty} × ${Money(line.unitPriceMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
                      ),
                      trailing: MoneyText(
                        Money(line.totalMinor),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _row(context, 'Total', receipt.totalMinor, scheme.onSurface),
                  const SizedBox(height: AppSpacing.sm),
                  _row(context, 'Paid', receipt.paidMinor, scheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  _row(context, 'Due', receipt.dueMinor, scheme.onSurface),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => shareReceipt(context, ref, receipt),
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, int minor, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        MoneyText(
          Money(minor),
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

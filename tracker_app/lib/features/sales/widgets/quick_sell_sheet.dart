import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/sales/sale_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/services/alert_service.dart';

class QuickSellSheet extends ConsumerStatefulWidget {
  final Product product;
  final double? lastSellingPrice;
  const QuickSellSheet({
    super.key,
    required this.product,
    this.lastSellingPrice,
  });

  @override
  ConsumerState<QuickSellSheet> createState() => _QuickSellSheetState();
}

class _QuickSellSheetState extends ConsumerState<QuickSellSheet> {
  final _form = GlobalKey<FormState>();
  late final _quantity = TextEditingController(text: '1');
  late final _price = TextEditingController(
    text: widget.lastSellingPrice?.toStringAsFixed(2) ?? '',
  );
  final _customer = TextEditingController();
  SalePlatform _platform = SalePlatform.facebook;
  PaymentStatus _payment = PaymentStatus.paid;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _customer.dispose();
    super.dispose();
  }

  double get _unitPrice => double.tryParse(_price.text.trim()) ?? 0;
  int get _qty => int.tryParse(_quantity.text.trim()) ?? 1;
  double get _total => _qty * _unitPrice;
  double get _profit => (_unitPrice - widget.product.costPrice) * _qty;

  Future<void> _confirm() async {
    if (!_form.currentState!.validate()) return;
    final price = _unitPrice;
    final qty = _qty;

    final alerts = ref.read(alertServiceProvider).checkSale(
      product: widget.product,
      quantity: qty,
      sellingPrice: price,
    );

    final hasBlocking = alerts.any((a) => a is BelowCostAlert || a is LowStockAlert);
    if (hasBlocking) {
      final proceed = await showGlassDialog<bool>(
        context: context,
        title: 'Sale alerts',
        message: alerts.map((a) => a.message).join('\n\n'),
        actionsBuilder: (ctx) => [
          GlassDialogAction(
            label: 'Cancel',
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          GlassDialogAction(
            label: 'Sell anyway',
            isDestructive: true,
            isPrimary: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      );
      if (proceed != true) return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(saleRepositoryProvider).addSale(
        productId: widget.product.id,
        quantity: qty,
        sellingPrice: price,
        platform: _platform.key,
        paymentStatus: _payment.key,
        customerName: _customer.text.trim().isEmpty
            ? null
            : _customer.text.trim(),
      );

      ref.invalidate(saleListProvider);
      ref.invalidate(productListProvider);
      ref.invalidate(dashboardProvider);

      final infoAlerts = alerts.whereType<MarginDropAlert>().toList();
      if (mounted) {
        Navigator.of(context).pop(true);
        if (infoAlerts.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(infoAlerts.first.message)),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassPanel(
      radius: 28,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      noBlur: true,
      solid: true,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sell — ${widget.product.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Stock available: ${widget.product.stock}',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassTextField(
                    controller: _quantity,
                    label: 'Quantity',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n < 1) return 'Min 1';
                      if (n > widget.product.stock) return 'Only ${widget.product.stock} available';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassTextField(
                    controller: _price,
                    label: 'Selling price (৳)',
                    hint: widget.lastSellingPrice?.toStringAsFixed(2),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final d = double.tryParse(v?.trim() ?? '');
                      if (d == null || d <= 0) return 'Enter a valid price';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _segmentedRow<SalePlatform>(
              label: 'Platform',
              value: _platform,
              items: SalePlatform.values,
              labelFn: (p) => p.label,
              onChanged: (v) => setState(() => _platform = v),
            ),
            const SizedBox(height: 12),
            _segmentedRow<PaymentStatus>(
              label: 'Payment',
              value: _payment,
              items: PaymentStatus.values,
              labelFn: (p) => p.label,
              onChanged: (v) => setState(() => _payment = v),
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _customer,
              label: 'Customer (optional)',
              hint: 'Name or phone',
            ),
            const SizedBox(height: 16),
            GlassPanel.flush(
              padding: const EdgeInsets.all(12),
              noBlur: true,
              expand: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: ${formatMoney(_total)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: cs.primary,
                          ),
                        ),
                        Text(
                          'Profit: ${_profit >= 0 ? '+' : ''}${formatMoney(_profit)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _profit >= 0 ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _confirm,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedRow<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelFn,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: SegmentedButton<T>(
            segments: items
                .map((e) => ButtonSegment(value: e, label: Text(labelFn(e))))
                .toList(),
            selected: {value},
            onSelectionChanged: (v) => onChanged(v.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}

void showQuickSellSheet(BuildContext context, {
  required Product product,
  double? lastSellingPrice,
}) {
  showModalBottomSheet(
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
              MediaQuery.of(context).padding.bottom + kBottomNavHeight + 8,
            ),
          ),
          child: QuickSellSheet(
            product: product,
            lastSellingPrice: lastSellingPrice,
          ),
        ),
      ],
    ),
  );
}

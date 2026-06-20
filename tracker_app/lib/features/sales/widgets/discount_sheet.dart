import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:tracker/core/theme/app_colors.dart';

import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/utils/profit_calculator.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/sales/sale_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/add_on_repository.dart';
import 'package:tracker/features/sales/widgets/product_picker_sheet.dart';
import 'package:tracker/features/sales/widgets/add_on_picker_sheet.dart';
import 'package:tracker/features/products/wallet_repository.dart';
import 'package:tracker/features/products/widgets/wallet_picker_sheet.dart';
import 'package:tracker/services/alert_service.dart';

class DiscountSheet extends ConsumerStatefulWidget {
  const DiscountSheet({super.key});

  @override
  ConsumerState<DiscountSheet> createState() => _DiscountSheetState();
}

class _DiscountSheetState extends ConsumerState<DiscountSheet> {
  final _form = GlobalKey<FormState>();
  final _qty = TextEditingController(text: '1');
  final _normalPrice = TextEditingController();
  final _discountPrice = TextEditingController();
  final _customer = TextEditingController();
  List<AddOnEntry> _addOns = [];
  int? _selectedProductId;
  SalePlatform _platform = SalePlatform.facebook;
  PaymentStatus _payment = PaymentStatus.paid;
  int? _walletId;
  String? _walletName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lastWalletId =
          await ref.read(walletRepositoryProvider).getLastUsedWalletId();
      if (lastWalletId != null) {
        final wallets = await ref.read(walletRepositoryProvider).getWallets();
        final wallet = wallets.firstWhere((w) => w.id == lastWalletId);
        if (mounted) {
          setState(() {
            _walletId = wallet.id;
            _walletName = wallet.name;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _qty.dispose();
    _normalPrice.dispose();
    _discountPrice.dispose();
    _customer.dispose();
    super.dispose();
  }

  Product? get _product {
    if (_selectedProductId == null) return null;
    final products = ref.read(productListProvider).value ?? [];
    return products.cast<Product?>().firstWhere(
          (p) => p!.id == _selectedProductId,
          orElse: () => null,
        );
  }

  int get _quantity => int.tryParse(_qty.text.trim()) ?? 1;
  double get _normal => double.tryParse(_normalPrice.text.trim()) ?? 0;
  double get _discount => double.tryParse(_discountPrice.text.trim()) ?? 0;
  double get _discountAmt => (_normal - _discount) * _quantity;
  double get _grossProfit {
    if (_product == null) return 0;
    return ProfitCalculator.calculateNetProfit(
      Sale(
        id: 0,
        productId: _product!.id,
        quantity: _quantity,
        sellingPrice: _discount,
        total: _discount * _quantity,
        platform: _platform.key,
        paymentStatus: _payment.key,
        date: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        walletId: _walletId,
        ownership: 'business',
        customerName: _customer.text.trim(),
        isDiscounted: true,
      ),
      _product!.costPrice,
      _addOns
          .map((e) => SaleAddOn(
                id: 0,
                saleId: 0,
                addOnTypeId: e.typeId,
                quantity: 1,
                cost: e.amount,
              ))
          .toList(),
    );
  }

  Future<void> _confirm() async {
    if (!_form.currentState!.validate()) return;
    if (_selectedProductId == null) return;
    final product = _product;
    if (product == null) return;

    final alerts = ref.read(alertServiceProvider).checkSale(
          product: product,
          quantity: _quantity,
          sellingPrice: _discount,
        );

    final hasBlocking =
        alerts.any((a) => a is BelowCostAlert || a is LowStockAlert);
    if (hasBlocking) {
      final proceed = await showGlassDialog<bool>(
        context: context,
        title: 'Sale alerts',
        message: alerts.map((a) => a.message).join('\n\n'),
        actionsBuilder: (ctx) => [
          GlassDialogAction(
            label: 'Cancel',
            onPressed: () {
              HapticService.trigger(HapticProfile.light);
              Navigator.of(ctx).pop(false);
            },
          ),
          GlassDialogAction(
            label: 'Sell anyway',
            isDestructive: true,
            isPrimary: true,
            onPressed: () {
              HapticService.trigger(HapticProfile.medium);
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      );
      if (proceed != true) return;
    }

    setState(() => _saving = true);
    try {
      final result = await ref.read(saleRepositoryProvider).addSale(
            productId: _selectedProductId!,
            quantity: _quantity,
            sellingPrice: _discount,
            platform: _platform.key,
            paymentStatus: _payment.key,
            customerName:
                _customer.text.trim().isEmpty ? null : _customer.text.trim(),
            isDiscounted: true,
            normalPrice: _normal,
            walletId: _walletId,
            ownership: 'business',
          );

      // Save add-ons
      final addOnRepo = ref.read(addOnRepositoryProvider);
      await addOnRepo.setForSale(
        result.sale.id,
        _addOns
            .map((e) => SaleAddOnsCompanion.insert(
                  saleId: result.sale.id,
                  addOnTypeId: e.typeId,
                  cost: drift.Value(e.amount),
                  quantity: drift.Value(1),
                ))
            .toList(),
      );

      ref.invalidate(saleListProvider);
      ref.invalidate(productListProvider);
      ref.invalidate(dashboardProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
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
    final product = _product;
    return GlassPanel(
      radius: 28,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      noBlur: true,
      opaque: true,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Discounted Sale',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
                HapticWrapper(
                  profile: HapticProfile.light,
                  onTap: () => Navigator.of(context).pop(),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProductPicker(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassTextField(
                    controller: _qty,
                    label: 'Quantity',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n < 1) return 'Min 1';
                      if (product != null && n > product.stock) {
                        return 'Only ${product.stock} available';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      HapticService.trigger(HapticProfile.light);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassTextField(
                    controller: _normalPrice,
                    label: 'Normal price (৳)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final d = double.tryParse(v?.trim() ?? '');
                      if (d == null || d <= 0) return 'Enter a valid price';
                      return null;
                    },
                    onChanged: (_) {
                      HapticService.trigger(HapticProfile.light);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _discountPrice,
              label: 'Discount price (৳)',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final d = double.tryParse(v?.trim() ?? '');
                if (d == null || d <= 0) return 'Enter a valid price';
                final n = double.tryParse(_normalPrice.text.trim()) ?? 0;
                if (d >= n) return 'Must be less than normal price';
                return null;
              },
              onChanged: (_) {
                HapticService.trigger(HapticProfile.light);
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            _segmentedRow<SalePlatform>(
              label: 'Platform',
              value: _platform,
              items: SalePlatform.values,
              labelFn: (p) => p.label,
              onChanged: (v) {
                HapticService.trigger(HapticProfile.light);
                setState(() => _platform = v);
              },
            ),
            const SizedBox(height: 12),
            _segmentedRow<PaymentStatus>(
              label: 'Payment',
              value: _payment,
              items: PaymentStatus.values,
              labelFn: (p) => p.label,
              onChanged: (v) {
                HapticService.trigger(HapticProfile.light);
                setState(() => _payment = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      HapticService.trigger(HapticProfile.light);
                      final id = await showWalletPicker(
                        context,
                        ref: ref,
                        selectedId: _walletId,
                      );
                      if (id != null) {
                        final wallets = await ref
                            .read(walletRepositoryProvider)
                            .getWallets();
                        final name = wallets.firstWhere((w) => w.id == id).name;
                        setState(() {
                          _walletId = id;
                          _walletName = name;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined,
                              size: 16, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _walletName ?? 'Select Wallet',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.expand_more,
                              size: 16, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _customer,
              label: 'Customer (optional)',
              hint: 'Name or phone',
            ),
            const SizedBox(height: 12),
            HapticWrapper(
              onTap: () async {
                final result = await showAddOnPicker(
                  context,
                  initialEntries: _addOns,
                );
                if (result != null) {
                  setState(() => _addOns = result);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      '${_addOns.isNotEmpty ? _addOns.length : ''} Add-Ons',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
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
                          'Discount: -${formatMoney(_discountAmt)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.warning,
                          ),
                        ),
                        if (product != null && _discount > 0)
                          Text(
                            _grossProfit >= 0
                                ? 'Profit: +${formatMoney(_grossProfit)}'
                                : 'Loss: -${formatMoney(_grossProfit.abs())}',
                            style: TextStyle(
                              fontSize: 13,
                              color: _grossProfit >= 0
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                      ],
                    ),
                  ),
                  HapticWrapper(
                    profile: HapticProfile.medium,
                    onTap: _saving ? null : _confirm,
                    child: FilledButton(
                      onPressed: null,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPicker() {
    final products = ref.watch(productListProvider).value ?? [];
    final inStock = products.where((p) => p.stock > 0).toList();

    final selectedName = _selectedProductId == null
        ? null
        : inStock
            .firstWhere(
              (p) => p.id == _selectedProductId,
              orElse: () => inStock.first,
            )
            .name;

    return InkWell(
      onTap: () {
        HapticService.trigger(HapticProfile.light);
        _pickProduct(context, inStock);
      },
      borderRadius: BorderRadius.circular(14),
      child: GlassPanel(
        radius: 14,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        noBlur: true,
        opaque: true,
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedName ?? 'Select product…',
                style: TextStyle(
                  color: selectedName != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProduct(BuildContext context, List<Product> inStock) async {
    final result = await showProductPicker(
      context,
      products: inStock,
      selectedId: _selectedProductId,
    );
    if (result != null) setState(() => _selectedProductId = result);
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

void showDiscountSheet(BuildContext context) {
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
          child: const DiscountSheet(),
        ),
      ],
    ),
  );
}

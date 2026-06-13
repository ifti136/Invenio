import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/utils/profit_calculator.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/products/product_repository.dart';
import 'package:tracker/features/products/wallet_repository.dart';
import 'package:tracker/features/sales/sale_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/add_on_repository.dart';
import 'package:tracker/features/sales/widgets/product_picker_sheet.dart';
import 'package:tracker/features/sales/widgets/add_on_picker_sheet.dart';
import 'package:tracker/features/products/widgets/wallet_picker_sheet.dart';
import 'package:tracker/services/alert_service.dart';

class SaleFormScreen extends ConsumerStatefulWidget {
  final int? saleId;
  final int? preselectProductId;

  const SaleFormScreen({
    super.key,
    this.saleId,
    this.preselectProductId,
  });

  @override
  ConsumerState<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends ConsumerState<SaleFormScreen> {
  final _form = GlobalKey<FormState>();
  final _qty = TextEditingController(text: '1');
  final _price = TextEditingController();
  final _customer = TextEditingController();
  List<AddOnEntry> _addOns = [];
  Product? _product;
  SalePlatform _platform = SalePlatform.facebook;
  PaymentStatus _payment = PaymentStatus.paid;
  DateTime _date = DateTime.now();
  int? _walletId;
  String? _walletName;
  String _ownership = 'business';
  bool _saving = false;
  bool _loaded = false;
  double? _lastPrice;
  Sale? _lastSale;

  bool get _isEdit => widget.saleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (widget.preselectProductId != null) {
          _selectProduct(widget.preselectProductId!);
        }
        final lastWalletId =
            await ref.read(walletRepositoryProvider).getLastUsedWalletId();
        if (lastWalletId != null) {
          final wallets = await ref.read(walletRepositoryProvider).getWallets();
          final wallet = wallets.firstWhere((w) => w.id == lastWalletId);
          setState(() {
            _walletId = wallet.id;
            _walletName = wallet.name;
          });
        }
        setState(() => _loaded = true);
      });
    }
  }

  Future<void> _load() async {
    final s = await ref.read(saleRepositoryProvider).getById(widget.saleId!);
    if (s == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    await _selectProduct(s.productId);
    _qty.text = s.quantity.toString();
    _price.text = s.sellingPrice.toStringAsFixed(2);
    _customer.text = s.customerName ?? '';
    _platform = SalePlatformX.fromKey(s.platform);
    _payment = PaymentStatusX.fromKey(s.paymentStatus);
    _date = DateTime.fromMillisecondsSinceEpoch(s.date);
    _walletId = s.walletId;
    _ownership = s.ownership;
    if (_walletId != null) {
      final wallets = await ref.read(walletRepositoryProvider).getWallets();
      _walletName = wallets.firstWhere((w) => w.id == _walletId).name;
    }
    final addOns =
        await ref.read(addOnRepositoryProvider).getForSale(widget.saleId!);
    final types = await ref.read(addOnRepositoryProvider).getActiveTypes();
    setState(() {
      _addOns = addOns.map((a) {
        final type = types.firstWhere(
          (t) => t.id == a.addOnTypeId,
          orElse: () => AddOnType(
              id: a.addOnTypeId, name: 'Unknown', isActive: true, createdAt: 0),
        );
        return AddOnEntry(
          typeId: a.addOnTypeId,
          name: type.name,
          amount: a.cost,
        );
      }).toList();
      _loaded = true;
    });
  }

  Future<void> _selectProduct(int id) async {
    final p = await ref.read(productRepositoryProvider).getById(id);
    if (p == null) return;
    final last = await ref.read(saleRepositoryProvider).lastSellingPriceFor(id);
    setState(() {
      _product = p;
      _lastSale = last;
      _lastPrice = last?.sellingPrice;
      if (_lastPrice != null && _price.text.isEmpty) {
        _price.text = _lastPrice!.toStringAsFixed(2);
      }
    });
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    _customer.dispose();
    super.dispose();
  }

  double? get _total {
    final q = int.tryParse(_qty.text.trim());
    final p = double.tryParse(_price.text.trim());
    if (q == null || p == null) return null;
    return q * p;
  }

  double? get _profit {
    final t = _total;
    if (t == null || _product == null) return null;
    return ProfitCalculator.calculateNetProfit(
      Sale(
        id: 0,
        productId: _product!.id,
        quantity: int.tryParse(_qty.text.trim()) ?? 0,
        sellingPrice: double.tryParse(_price.text.trim()) ?? 0,
        total: t,
        platform: _platform.key,
        paymentStatus: _payment.key,
        date: _date.millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        walletId: _walletId,
        ownership: _ownership,
        customerName: _customer.text.trim(),
        isDiscounted: false,
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

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_product == null) {
      await _showError('Please pick a product first.');
      return;
    }
    if (_walletId == null) {
      await _showError('Please select a wallet.');
      return;
    }
    final qty = int.parse(_qty.text.trim());
    final price = double.parse(_price.text.trim());
    final repo = ref.read(saleRepositoryProvider);
    final alerts = ref.read(alertServiceProvider).checkSale(
          product: _product!,
          quantity: qty,
          sellingPrice: price,
          lastSale: _lastSale,
        );
    final blocking = <AppAlert>[
      ...alerts.whereType<BelowCostAlert>(),
      ...alerts.whereType<LowStockAlert>(),
    ];
    if (blocking.isNotEmpty) {
      final ok = await _confirmBlockingAlerts(blocking);
      if (ok != true) return;
    }
    setState(() => _saving = true);
    try {
      int saleId;
      if (_isEdit) {
        saleId = widget.saleId!;
        await repo.updateSale(
          id: saleId,
          productId: _product!.id,
          quantity: qty,
          sellingPrice: price,
          platform: _platform.key,
          paymentStatus: _payment.key,
          customerName:
              _customer.text.trim().isEmpty ? null : _customer.text.trim(),
          date: _date,
          walletId: _walletId,
          ownership: _ownership,
        );
      } else {
        final result = await repo.addSale(
          productId: _product!.id,
          quantity: qty,
          sellingPrice: price,
          platform: _platform.key,
          paymentStatus: _payment.key,
          customerName:
              _customer.text.trim().isEmpty ? null : _customer.text.trim(),
          date: _date,
          walletId: _walletId,
          ownership: _ownership,
          isDiscounted: false,
        );
        saleId = result.sale.id;
      }

      // Save add-ons
      final addOnRepo = ref.read(addOnRepositoryProvider);
      await addOnRepo.setForSale(
        saleId,
        _addOns
            .map((e) => SaleAddOnsCompanion.insert(
                  saleId: saleId,
                  addOnTypeId: e.typeId,
                  cost: drift.Value(e.amount),
                  quantity: drift.Value(1),
                ))
            .toList(),
      );

      if (!mounted) return;
      ref.invalidate(saleListProvider);
      ref.invalidate(productListProvider);
      ref.invalidate(dashboardProvider);
      Navigator.of(context).pop(true);
      final info = alerts.whereType<MarginDropAlert>().toList();
      if (info.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.warning.withOpacity(0.95),
            content: Text(
              info.map((a) => a.message).join('\n'),
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Sale updated' : 'Sale recorded'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showError(String msg) {
    return showGlassDialog(
      context: context,
      title: 'Could not save',
      message: msg,
         actionsBuilder: (ctx) => [
           GlassDialogAction(
             label: 'OK',
             isPrimary: true,
             onPressed: () {
               HapticService.trigger(HapticProfile.light);
               Navigator.of(ctx).pop();
             },
           ),
         ],
    );
  }

  Future<bool?> _confirmBlockingAlerts(List<AppAlert> alerts) {
    return showGlassDialog<bool>(
      context: context,
      title: 'Heads up',
      message: alerts.map((a) => '• ${a.message}').join('\n\n'),
       actionsBuilder: (ctx) => [
         GlassDialogAction(
           label: 'Cancel',
           onPressed: () {
             HapticService.trigger(HapticProfile.light);
             Navigator.of(ctx).pop(false);
           },
         ),
         GlassDialogAction(
           label: 'Save anyway',
           isPrimary: true,
           onPressed: () {
             HapticService.trigger(HapticProfile.medium);
             Navigator.of(ctx).pop(true);
           },
         ),
       ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final products = ref.watch(productListProvider).value ?? const [];
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Sale' : 'Log Sale'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            GlassPanel(
              noBlur: true,
              solid: true,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Product',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProductTile(products),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              noBlur: true,
              solid: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GlassTextField(
                          controller: _qty,
                          label: 'Quantity',
                          hint: '1',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null || n <= 0) {
                              return 'Enter a whole number';
                            }
                            if (_product != null && n > _product!.stock) {
                              return 'Only ${_product!.stock} in stock';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GlassTextField(
                          controller: _price,
                          label: 'Selling price (৳)',
                          hint: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final d = double.tryParse(v?.trim() ?? '');
                            if (d == null || d <= 0) {
                              return 'Enter a price';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_lastPrice != null && !_isEdit) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Last sold at ${formatMoney(_lastPrice!)}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ToggleGroup<SalePlatform>(
                        label: 'Platform',
                        value: _platform,
                        values: SalePlatform.values,
                        labelOf: (v) => v.label,
                         onChanged: (v) {
                           HapticService.trigger(HapticProfile.light);
                           setState(() => _platform = v);
                         },
                      ),
                      const SizedBox(width: 12),
                      _ToggleGroup<PaymentStatus>(
                        label: 'Payment',
                        value: _payment,
                        values: PaymentStatus.values,
                        labelOf: (v) => v.label,
                         onChanged: (v) {
                           HapticService.trigger(HapticProfile.light);
                           setState(() => _payment = v);
                         },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ToggleGroup<String>(
                        label: 'Ownership',
                        value: _ownership,
                        values: const ['business', 'personal'],
                        labelOf: (v) =>
                            v == 'business' ? 'Business' : 'Personal',
                         onChanged: (v) {
                           HapticService.trigger(HapticProfile.light);
                           setState(() => _ownership = v);
                         },
                      ),
                      const SizedBox(width: 12),
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
                             final name =
                                 wallets.firstWhere((w) => w.id == id).name;
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
                                const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 16,
                                    color: AppColors.accent),
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
                    hint: 'Name or note',
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
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
                            '${_addOns.length > 0 ? _addOns.length : ''} Add-Ons',
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
                  const SizedBox(height: 12),
                  if (_total != null)
                    GlassPanel(
                      noBlur: true,
                      solid: true,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              label: 'Total',
                              value: formatMoney(_total!),
                              color: AppColors.success,
                            ),
                          ),
                          if (_profit != null)
                            Expanded(
                              child: _Metric(
                                label: 'Est. profit',
                                value: formatMoney(_profit!),
                                color: (_profit! < 0)
                                    ? AppColors.danger
                                    : AppColors.info,
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                   HapticWrapper(
                     profile: HapticProfile.medium,
                     onTap: _saving ? null : _save,
                     child: FilledButton(
                       onPressed: null,
                       style: FilledButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                       child: _saving
                           ? const SizedBox(
                               width: 20,
                               height: 20,
                               child: CircularProgressIndicator(
                                 strokeWidth: 2,
                                 color: Colors.white,
                               ),
                             )
                           : Text(_isEdit ? 'Save changes' : 'Record sale'),
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

  Widget _buildProductTile(List<Product> products) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _product;
    final isLocked = _isEdit;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isLocked
          ? null
          : () async {
              final id = await showProductPicker(
                context,
                products: products,
                selectedId: selected?.id,
                inStockOnly: false,
              );
              if (id != null) {
                await _selectProduct(id);
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected != null
              ? scheme.primaryContainer.withOpacity(0.35)
              : scheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected != null
                ? scheme.primary.withOpacity(0.5)
                : scheme.outline.withOpacity(0.3),
            width: selected != null ? 1.0 : 0.6,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isLocked
                  ? Icons.lock_outline_rounded
                  : (selected != null
                      ? Icons.inventory_2_outlined
                      : Icons.add_box_outlined),
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected?.name ?? 'Choose a product…',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: selected != null
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  'Stock: ${selected.stock}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            Icon(
              isLocked ? Icons.lock : Icons.expand_more_rounded,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleGroup<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  const _ToggleGroup({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final v in values) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: v == value
                            ? scheme.primary.withOpacity(0.18)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: v == value
                              ? scheme.primary.withOpacity(0.55)
                              : scheme.onSurfaceVariant.withOpacity(0.18),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        labelOf(v),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              v == value ? FontWeight.w700 : FontWeight.w500,
                          color: v == value ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                if (v != values.last) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/debug_app_bar.dart';
import 'package:tracker/core/widgets/debug_borders.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/products/product_repository.dart';
import 'package:tracker/features/sales/sale_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
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
  Product? _product;
  SalePlatform _platform = SalePlatform.facebook;
  PaymentStatus _payment = PaymentStatus.paid;
  DateTime _date = DateTime.now();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.preselectProductId != null) {
          _selectProduct(widget.preselectProductId!);
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
    if (mounted) setState(() => _loaded = true);
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
    final q = int.tryParse(_qty.text.trim()) ?? 0;
    return t - (q * _product!.costPrice);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_product == null) {
      await _showError('Please pick a product first.');
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
      if (_isEdit) {
        await repo.updateSale(
          id: widget.saleId!,
          productId: _product!.id,
          quantity: qty,
          sellingPrice: price,
          platform: _platform.key,
          paymentStatus: _payment.key,
          customerName:
              _customer.text.trim().isEmpty ? null : _customer.text.trim(),
          date: _date,
        );
      } else {
        await repo.addSale(
          productId: _product!.id,
          quantity: qty,
          sellingPrice: price,
          platform: _platform.key,
          paymentStatus: _payment.key,
          customerName:
              _customer.text.trim().isEmpty ? null : _customer.text.trim(),
          date: _date,
        );
      }
      if (!mounted) return;
      ref.invalidate(saleListProvider);
      ref.invalidate(productListProvider);
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
      actions: [
        GlassDialogAction(
          label: 'OK',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<bool?> _confirmBlockingAlerts(List<AppAlert> alerts) {
    return showGlassDialog<bool>(
      context: context,
      title: 'Heads up',
      message: alerts.map((a) => '• ${a.message}').join('\n\n'),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: 'Save anyway',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
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
      appBar: DebugAppBar(
        title: _isEdit ? 'Edit Sale' : 'Log Sale',
      ),
      body: DebugBorders(
        label: 'FORM',
        color: kDebugFormColor,
        child: Form(
          key: _form,
          child: DebugBorders(
            label: 'LIST',
            color: kDebugListColor,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                DebugBorders(
                  label: 'PANEL: product',
                  color: Colors.orange,
                  child: GlassPanel(
                    noBlur: true,
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
                        if (_isEdit || _product != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: scheme.onSurfaceVariant.withOpacity(0.18),
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_outline_rounded, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _product?.name ?? '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Stock: ${_product?.stock ?? 0}',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              hintText: 'Choose a product…',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            items: products
                                .map((p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(
                                        '${p.name} (${p.stock})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (id) {
                              if (id != null) _selectProduct(id);
                            },
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DebugBorders(
                  label: 'PANEL: details',
                  color: Colors.orange,
                  child: GlassPanel(
                    noBlur: true,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DebugContainer(
                                color: kDebugFieldColor,
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
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DebugContainer(
                                color: kDebugFieldColor,
                                child: GlassTextField(
                                  controller: _price,
                                  label: 'Selling price (৳)',
                                  hint: '0.00',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
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
                              onChanged: (v) => setState(() => _platform = v),
                            ),
                            const SizedBox(width: 12),
                            _ToggleGroup<PaymentStatus>(
                              label: 'Payment',
                              value: _payment,
                              values: PaymentStatus.values,
                              labelOf: (v) => v.label,
                              onChanged: (v) => setState(() => _payment = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: DebugContainer(
                            color: kDebugFieldColor,
                            child: GlassTextField(
                              controller: _customer,
                              label: 'Customer (optional)',
                              hint: 'Name or note',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_total != null)
                  DebugBorders(
                    label: 'PANEL: total',
                    color: Colors.orange,
                    child: GlassPanel(
                      noBlur: true,
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
                  ),
                const SizedBox(height: 16),
                DebugBorders(
                  label: 'BUTTON: ${_isEdit ? 'save' : 'record'}',
                  color: Colors.teal,
                  borderWidth: 3,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
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
                          fontWeight: v == value
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: v == value
                              ? scheme.primary
                              : scheme.onSurface,
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

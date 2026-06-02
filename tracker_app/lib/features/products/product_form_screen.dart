import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/features/products/product_repository.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final int? productId;
  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController();
  final _threshold = TextEditingController(text: '5');
  final _note = TextEditingController();
  bool _saving = false;
  bool _loaded = false;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final p = await ref
        .read(productRepositoryProvider)
        .getById(widget.productId!);
    if (p == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _name.text = p.name;
    _cost.text = p.costPrice.toStringAsFixed(2);
    _stock.text = p.stock.toString();
    _threshold.text = p.lowStockThreshold.toString();
    _note.text = p.note ?? '';
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    _stock.dispose();
    _threshold.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final cost = double.parse(_cost.text.trim());
    final stock = int.parse(_stock.text.trim());
    final threshold = int.tryParse(_threshold.text.trim()) ?? 5;
    final name = _name.text.trim();
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();

    setState(() => _saving = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      if (_isEdit) {
        await repo.update(
          id: widget.productId!,
          name: name,
          lowStockThreshold: threshold,
          note: note,
        );
        await repo.adjustStock(
          productId: widget.productId!,
          newStock: stock,
          note: 'Manual edit',
        );
      } else {
        await repo.create(
          name: name,
          stock: stock,
          costPrice: cost,
          lowStockThreshold: threshold,
          note: note,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Product updated' : 'Product added'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showGlassDialog(
        context: context,
        title: 'Could not save',
        message: e.toString(),
        actions: [
          GlassDialogAction(
            label: 'OK',
            isPrimary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final result = await showGlassDialog<bool>(
      context: context,
      title: 'Delete product?',
      message:
          'This removes the product and all its stock history. Sales already recorded stay.',
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (result != true) return;
    try {
      await ref
          .read(productRepositoryProvider)
          .delete(widget.productId!);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showGlassDialog(
        context: context,
        title: 'Could not delete',
        message: e.toString(),
        actions: [
          GlassDialogAction(
            label: 'OK',
            isPrimary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isEdit = _isEdit;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        actions: [
          if (isEdit)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassTextField(
                    controller: _name,
                    label: 'Name',
                    hint: 'e.g. Wireless mouse',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _cost,
                    label: 'Cost price (৳)',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      final d = double.tryParse(v?.trim() ?? '');
                      if (d == null || d < 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _stock,
                    label: isEdit ? 'Current stock' : 'Initial stock',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n < 0) return 'Enter a whole number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _threshold,
                    label: 'Low-stock alert at',
                    hint: '5',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n < 0) return 'Enter a whole number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _note,
                    label: 'Note (optional)',
                    hint: 'SKU, supplier, location…',
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
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
                  : Text(isEdit ? 'Save changes' : 'Add product'),
            ),
            if (isEdit) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : _delete,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete product'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

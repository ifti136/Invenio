import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../db/app_database.dart';
import 'inventory_providers.dart';

class ProductFormScreen extends ConsumerWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (productId == null) {
      return const ProductFormBody(product: null);
    }
    final product = ref.watch(productProvider(productId!));

    return product.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit product')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Edit product')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load product',
          message: 'Something went wrong while reading this product.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(productProvider(productId!)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit product')),
            body: EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Product not found',
              message: 'It may have been removed from this shop.',
              actionLabel: 'Back to inventory',
              actionIcon: Icons.arrow_back,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }
        return ProductFormBody(
          key: ValueKey(item.id),
          product: item,
        );
      },
    );
  }
}

class ProductFormBody extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormBody({super.key, this.product});

  @override
  ConsumerState<ProductFormBody> createState() => _ProductFormBodyState();
}

class _ProductFormBodyState extends ConsumerState<ProductFormBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _cost;
  late final TextEditingController _stock;
  late final TextEditingController _threshold;
  late final TextEditingController _note;
  late bool _archived;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _price = TextEditingController(
      text: product == null ? '' : moneyToInput(Money(product.priceMinor)),
    );
    _cost = TextEditingController(
      text: product == null ? '' : moneyToInput(Money(product.costMinor)),
    );
    _stock = TextEditingController(
      text: product == null ? '0' : '${product.stock}',
    );
    _threshold = TextEditingController(
      text: product == null ? '3' : '${product.lowStockAt}',
    );
    _note = TextEditingController(text: product?.note ?? '');
    _archived = product?.archived ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _cost.dispose();
    _stock.dispose();
    _threshold.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit product' : 'Add product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter a product name'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Selling price'),
              validator: (value) => parseMoneyInput(value ?? '') == null
                  ? 'Enter a valid selling price'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cost,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Cost'),
              validator: (value) => parseMoneyInput(value ?? '') == null
                  ? 'Enter a valid cost'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Stock' : 'Initial stock',
              ),
              validator: (value) => parseWholeNumber(value ?? '') == null
                  ? 'Enter a whole number'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _threshold,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Low-stock threshold',
                helperText: 'Warn when stock reaches this number.',
              ),
              validator: (value) => parseWholeNumber(value ?? '') == null
                  ? 'Enter a whole number'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Archived'),
              subtitle: const Text('Hide this product from the catalogue'),
              value: _archived,
              onChanged: (value) => setState(() => _archived = value),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save product'),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = parseMoneyInput(_price.text)!;
    final cost = parseMoneyInput(_cost.text)!;
    final stock = parseWholeNumber(_stock.text)!;
    final threshold = parseWholeNumber(_threshold.text)!;
    final note = _note.text.trim();

    setState(() => _saving = true);
    try {
      final repository = ref.read(productRepositoryProvider);
      if (widget.product == null) {
        await repository.createProduct(
          name: _name.text.trim(),
          priceMinor: price.minor,
          costMinor: cost.minor,
          initialStock: stock,
          lowStockAt: threshold,
          note: note.isEmpty ? null : note,
          archived: _archived,
        );
      } else {
        await repository.updateProduct(
          id: widget.product!.id,
          name: _name.text.trim(),
          priceMinor: price.minor,
          costMinor: cost.minor,
          stock: stock,
          lowStockAt: threshold,
          note: note.isEmpty ? null : note,
          archived: _archived,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the product.')),
        );
      }
    }
  }
}

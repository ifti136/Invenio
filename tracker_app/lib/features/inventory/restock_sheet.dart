import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../db/app_database.dart';
import '../settings/settings_providers.dart';
import 'inventory_providers.dart';

Future<bool> showRestockSheet(BuildContext context, Product product) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RestockSheet(product: product),
  );
  return result ?? false;
}

class RestockSheet extends ConsumerStatefulWidget {
  final Product product;

  const RestockSheet({super.key, required this.product});

  @override
  ConsumerState<RestockSheet> createState() => _RestockSheetState();
}

class _RestockSheetState extends ConsumerState<RestockSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qty;
  late final TextEditingController _unitCost;
  late final TextEditingController _note;
  int? _accountId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(text: '1');
    _unitCost = TextEditingController(
      text: moneyToInput(Money(widget.product.costMinor)),
    );
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _qty.dispose();
    _unitCost.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Restock ${widget.product.name}',
                  style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  final qty = parseWholeNumber(value ?? '', min: 1);
                  return qty == null ? 'Enter a quantity of 1 or more' : null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _unitCost,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Unit cost'),
                validator: (value) => parseMoneyInput(value ?? '') == null
                    ? 'Enter a valid cost'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int?>(
                value: _accountId,
                decoration: const InputDecoration(labelText: 'Paid from'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None'),
                  ),
                  for (final account in accounts)
                    DropdownMenuItem<int?>(
                      value: account.id,
                      child: Text(account.name),
                    ),
                ],
                onChanged: (value) => setState(() => _accountId = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                accounts.isEmpty
                    ? 'Add a payment source in Settings to deduct cash automatically.'
                    : 'Choosing a source deducts the cost from its balance without adding an expense.',
                style: AppTextStyles.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _note,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Add stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final qty = parseWholeNumber(_qty.text, min: 1)!;
    final unitCost = parseMoneyInput(_unitCost.text)!;
    final note = _note.text.trim();

    setState(() => _saving = true);
    try {
      await ref.read(productRepositoryProvider).restock(
            productId: widget.product.id,
            qty: qty,
            unitCostMinor: unitCost.minor,
            accountId: _accountId,
            note: note.isEmpty ? null : note,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add stock.')),
        );
      }
    }
  }
}

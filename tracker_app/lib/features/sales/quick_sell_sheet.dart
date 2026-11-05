import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../db/app_database.dart';
import '../settings/account_editor.dart';
import '../settings/settings_providers.dart';
import 'cart_controller.dart';
import 'receipt_sheet.dart';
import 'sale_models.dart';
import 'sale_providers.dart';

class QuickSellOutcome {
  final SaleReceipt? receipt;
  final int? addMoreQty;
  final int? addMorePriceMinor;

  const QuickSellOutcome.completed(this.receipt)
      : addMoreQty = null,
        addMorePriceMinor = null;

  const QuickSellOutcome.addMore({
    required this.addMoreQty,
    required this.addMorePriceMinor,
  }) : receipt = null;

  bool get isAddMore => receipt == null;
}

Future<void> startQuickSell(
  BuildContext context,
  WidgetRef ref,
  Product product,
) async {
  final outcome = await showModalBottomSheet<QuickSellOutcome>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => QuickSellSheet(product: product),
  );
  if (outcome == null || !context.mounted) return;

  if (outcome.isAddMore) {
    ref.read(cartProvider.notifier)
      ..reset()
      ..addProduct(
        product,
        qty: outcome.addMoreQty!,
        unitPriceMinor: outcome.addMorePriceMinor,
      );
    context.push('/sales/new');
    return;
  }

  final receipt = outcome.receipt!;
  await showReceiptSheet(context, receipt);
  if (!context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    SnackBar(
      content: const Text('Sale saved.'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          try {
            await ref.read(saleRepositoryProvider).undoSale(receipt.saleId);
            messenger.showSnackBar(
              const SnackBar(content: Text('Sale undone.')),
            );
          } catch (_) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Could not undo the sale.')),
            );
          }
        },
      ),
    ),
  );
}

class QuickSellSheet extends ConsumerStatefulWidget {
  final Product product;

  const QuickSellSheet({super.key, required this.product});

  @override
  ConsumerState<QuickSellSheet> createState() => _QuickSellSheetState();
}

class _QuickSellSheetState extends ConsumerState<QuickSellSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qty;
  late final TextEditingController _price;
  int? _accountId;
  bool _overrideStock = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(text: '1');
    _price = TextEditingController(
      text: moneyToInput(Money(widget.product.priceMinor)),
    );
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final defaults = ref.watch(salesDefaultsProvider).valueOrNull;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: accounts.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load payment sources.'),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () => ref.invalidate(accountsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return SizedBox(
              height: 340,
              child: EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Add a payment source',
                message:
                    'Quick Sell needs to know where the money will be received.',
                actionLabel: 'Add source',
                actionIcon: Icons.add,
                onAction: () async {
                  await showAccountEditorDialog(context);
                },
              ),
            );
          }
          return _form(context, items, defaults);
        },
      ),
    );
  }

  Widget _form(
    BuildContext context,
    List<Account> accounts,
    SalesDefaults? defaults,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final qty = int.tryParse(_qty.text) ?? 0;
    final aboveStock = qty > widget.product.stock;
    final price = parseMoneyInput(_price.text);
    final belowCost = price != null && price.minor < widget.product.costMinor;
    final selectedAccountId = accounts.any((a) => a.id == _accountId)
        ? _accountId!
        : (accounts.any((a) => a.id == defaults?.accountId)
            ? defaults!.accountId!
            : accounts.first.id);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sell ${widget.product.name}', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${widget.product.stock} in stock',
              style: AppTextStyles.body.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qty,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    onChanged: (_) => setState(() {}),
                    validator: (value) =>
                        parseWholeNumber(value ?? '', min: 1) == null
                            ? 'Enter 1 or more'
                            : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unit price',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) => parseMoneyInput(value ?? '') == null
                        ? 'Enter a valid price'
                        : null,
                  ),
                ),
              ],
            ),
            if (belowCost) ...[
              const SizedBox(height: AppSpacing.sm),
              _warning(
                context,
                Icons.error_outline,
                'This price is below cost. You can still sell.',
                scheme.error,
              ),
            ],
            if (aboveStock) ...[
              const SizedBox(height: AppSpacing.sm),
              _warning(
                context,
                Icons.warning_amber_outlined,
                'Only ${widget.product.stock} in stock. Turn on the override to sell anyway.',
                scheme.tertiary,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sell above stock'),
                value: _overrideStock,
                onChanged: (value) => setState(() => _overrideStock = value),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              value: selectedAccountId,
              decoration: const InputDecoration(labelText: 'Payment source'),
              items: [
                for (final account in accounts)
                  DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(account.name),
                  ),
              ],
              onChanged: (value) => setState(() => _accountId = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving || (aboveStock && !_overrideStock)
                  ? null
                  : () => _save(selectedAccountId, defaults?.channelId),
              child: Text(_saving ? 'Saving…' : 'Confirm'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _saving ? null : _addMore,
              icon: const Icon(Icons.add),
              label: const Text('Add more items'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _warning(
    BuildContext context,
    IconData icon,
    String message,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Future<void> _save(int accountId, int? channelId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (channelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a sales channel in Settings.')),
      );
      return;
    }
    final qty = parseWholeNumber(_qty.text, min: 1)!;
    final price = parseMoneyInput(_price.text)!;

    setState(() => _saving = true);
    try {
      final receipt = await ref.read(saleRepositoryProvider).saveSale(
        lines: [
          SaleLineInput(
            productId: widget.product.id,
            qty: qty,
            unitPriceMinor: price.minor,
            unitCostMinor: widget.product.costMinor,
            allowAboveStock: _overrideStock,
          ),
        ],
        channelId: channelId,
        payment: PaymentMode.paid,
        accountId: accountId,
      );
      ref.invalidate(salesDefaultsProvider);
      if (mounted) {
        Navigator.of(context).pop(QuickSellOutcome.completed(receipt));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the sale.')),
        );
      }
    }
  }

  void _addMore() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final qty = parseWholeNumber(_qty.text, min: 1)!;
    final price = parseMoneyInput(_price.text)!;
    Navigator.of(context).pop(
      QuickSellOutcome.addMore(
        addMoreQty: qty,
        addMorePriceMinor: price.minor,
      ),
    );
  }
}

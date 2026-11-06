import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/sale_bar.dart';
import '../../db/app_database.dart';
import '../settings/account_editor.dart';
import '../settings/settings_providers.dart';
import 'cart_controller.dart';
import 'product_picker_sheet.dart';
import 'receipt_sheet.dart';
import 'sale_models.dart';
import 'sale_providers.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partial = TextEditingController();
  int? _customerId;
  int? _channelId;
  int? _accountId;
  PaymentMode _payment = PaymentMode.paid;
  bool _customerError = false;
  bool _accountError = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final seed = ref.read(cartProvider).editSeed;
    if (seed == null) return;
    _customerId = seed.customerId;
    _channelId = seed.channelId;
    _accountId = seed.accountId;
    _payment = seed.payment;
    if (seed.payment == PaymentMode.partial) {
      _partial.text = moneyToInput(Money(seed.paidMinor));
    }
  }

  @override
  void dispose() {
    _partial.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final channelsAsync = ref.watch(channelsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final defaults = ref.watch(salesDefaultsProvider).valueOrNull;
    final channels = channelsAsync.valueOrNull ?? const <Channel>[];
    final accounts = accountsAsync.valueOrNull ?? const <Account>[];
    final selectedChannelId = _resolveChannel(channels, defaults);
    final selectedAccountId = _resolveAccount(accounts, defaults);
    final editing = cart.editingSaleId != null;

    final accountMissing = _payment != PaymentMode.due && accounts.isEmpty;
    final canSave = !_saving &&
        !cart.hasUnapprovedOverStock &&
        !accountMissing &&
        selectedChannelId != null;

    return PopScope(
      canPop: cart.isEmpty && !_saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await _confirmDiscard();
        if (!discard || !mounted) return;
        ref.read(cartProvider.notifier).reset();
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? 'Edit sale' : 'New sale'),
        ),
        body: cart.isEmpty
            ? EmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'No items yet',
                message: 'Add a product to start this sale.',
                actionLabel: 'Add item',
                actionIcon: Icons.add,
                onAction: _addItems,
              )
            : Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Items (${cart.itemCount})',
                                style: AppTextStyles.title,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addItems,
                              icon: const Icon(Icons.add),
                              label: const Text('Add item'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      sliver: SliverList.builder(
                        itemCount: cart.lines.length,
                        itemBuilder: (context, index) {
                          final line = cart.lines[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _CartLineTile(
                              key: ValueKey(line.productId),
                              line: line,
                            ),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _customerSection(),
                            const SizedBox(height: AppSpacing.xl),
                            _channelSection(
                              channelsAsync,
                              channels,
                              selectedChannelId,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _paymentSection(
                              cart,
                              accountsAsync,
                              accounts,
                              selectedAccountId,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: cart.isEmpty
            ? null
            : SaleBar(
                total: Money(cart.totalMinor),
                profit: Money(cart.profitMinor),
                actionLabel: _saving
                    ? 'Saving…'
                    : (editing ? 'Save changes' : 'Save sale'),
                onAction: canSave ? _save : null,
              ),
      ),
    );
  }

  Future<void> _addItems() async {
    final picked = await showProductPicker(
      context,
      onAddProduct: () => context.push('/inventory/new'),
    );
    for (final product in picked) {
      ref.read(cartProvider.notifier).addProduct(product);
    }
  }

  Widget _customerSection() {
    final customers = ref.watch(customersProvider);
    final items = customers.valueOrNull ?? const <Customer>[];
    final requiresCustomer = _payment != PaymentMode.paid;
    final hasSelected = items.any((customer) => customer.id == _customerId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Customer', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: hasSelected ? _customerId : null,
                hint: const Text('Walk-in'),
                decoration: InputDecoration(
                  labelText: 'Customer',
                  errorText: requiresCustomer && _customerError
                      ? 'Choose or add a customer'
                      : null,
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Walk-in'),
                  ),
                  for (final customer in items)
                    DropdownMenuItem<int?>(
                      value: customer.id,
                      child: Text(customer.name),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _customerId = value;
                  _customerError = false;
                }),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filledTonal(
              tooltip: 'Add customer',
              onPressed: _addCustomer,
              icon: const Icon(Icons.person_add_alt_1_outlined),
            ),
          ],
        ),
        if (requiresCustomer)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'A customer is required when the sale is not paid in full.',
              style: AppTextStyles.label.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _channelSection(
    AsyncValue<List<Channel>> async,
    List<Channel> channels,
    int? selectedChannelId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Channel', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        if (async.isLoading)
          const LinearProgressIndicator()
        else if (async.hasError)
          _retryRow('Could not load channels.', () {
            ref.invalidate(channelsProvider);
          })
        else if (channels.isEmpty)
          const Text('Add a sales channel in Settings.')
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final channel in channels)
                ChoiceChip(
                  label: Text(channel.name),
                  selected: channel.id == selectedChannelId,
                  onSelected: (_) => setState(() => _channelId = channel.id),
                ),
            ],
          ),
      ],
    );
  }

  Widget _paymentSection(
    CartState cart,
    AsyncValue<List<Account>> async,
    List<Account> accounts,
    int? selectedAccountId,
  ) {
    final requiresAccount = _payment != PaymentMode.due;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Payment', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<PaymentMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: PaymentMode.paid,
                label: Text('Paid in full'),
              ),
              ButtonSegment(value: PaymentMode.partial, label: Text('Part')),
              ButtonSegment(value: PaymentMode.due, label: Text('Later')),
            ],
            selected: {_payment},
            onSelectionChanged: (selection) {
              setState(() {
                _payment = selection.first;
                _customerError = false;
                _accountError = false;
              });
            },
          ),
        ),
        if (_payment == PaymentMode.partial) ...[
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _partial,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount received',
            ),
            validator: (value) {
              if (_payment != PaymentMode.partial) return null;
              final amount = parseMoneyInput(value ?? '');
              if (amount == null || amount.minor <= 0) {
                return 'Enter the amount received';
              }
              if (amount.minor >= cart.totalMinor) {
                return 'Use Paid in full for the whole amount';
              }
              return null;
            },
          ),
        ],
        if (_payment == PaymentMode.due)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              'The full amount stays due. Record the payment later from the sale.',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (requiresAccount) ...[
          const SizedBox(height: AppSpacing.md),
          if (async.isLoading)
            const LinearProgressIndicator()
          else if (async.hasError)
            _retryRow('Could not load payment sources.', () {
              ref.invalidate(accountsProvider);
            })
          else if (accounts.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add a payment source to receive this payment.',
                  style: AppTextStyles.body.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showAccountEditorDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add payment source'),
                ),
              ],
            )
          else
            DropdownButtonFormField<int>(
              value: selectedAccountId,
              decoration: InputDecoration(
                labelText: 'Received in',
                errorText: _accountError
                    ? 'Choose where the money was received'
                    : null,
              ),
              items: [
                for (final account in accounts)
                  DropdownMenuItem<int>(
                    value: account.id,
                    child: Text(account.name),
                  ),
              ],
              onChanged: (value) => setState(() {
                _accountId = value;
                _accountError = false;
              }),
            ),
        ],
      ],
    );
  }

  Widget _retryRow(String message, VoidCallback onRetry) {
    return Row(
      children: [
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }

  int? _resolveChannel(List<Channel> channels, SalesDefaults? defaults) {
    if (_channelId != null &&
        channels.any((channel) => channel.id == _channelId)) {
      return _channelId;
    }
    if (defaults?.channelId != null &&
        channels.any((channel) => channel.id == defaults!.channelId)) {
      return defaults!.channelId;
    }
    return channels.isEmpty ? null : channels.first.id;
  }

  int? _resolveAccount(List<Account> accounts, SalesDefaults? defaults) {
    if (_accountId != null &&
        accounts.any((account) => account.id == _accountId)) {
      return _accountId;
    }
    if (defaults?.accountId != null &&
        accounts.any((account) => account.id == defaults!.accountId)) {
      return defaults!.accountId;
    }
    return accounts.isEmpty ? null : accounts.first.id;
  }

  Future<void> _addCustomer() async {
    final id = await showDialog<int>(
      context: context,
      builder: (_) => const _AddCustomerDialog(),
    );
    if (id != null && mounted) {
      setState(() {
        _customerId = id;
        _customerError = false;
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard sale?'),
        content: const Text('Items in this sale will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _save() async {
    final cart = ref.read(cartProvider);
    final channels =
        ref.read(channelsProvider).valueOrNull ?? const <Channel>[];
    final accounts =
        ref.read(accountsProvider).valueOrNull ?? const <Account>[];
    final defaults = ref.read(salesDefaultsProvider).valueOrNull;
    final channelId = _resolveChannel(channels, defaults);
    final accountId = _resolveAccount(accounts, defaults);
    final valid = _formKey.currentState?.validate() ?? false;
    final requiresCustomer = _payment != PaymentMode.paid;

    setState(() {
      _customerError = requiresCustomer && _customerId == null;
      _accountError = _payment != PaymentMode.due && accountId == null;
    });
    if (!valid ||
        _customerError ||
        _accountError ||
        cart.hasUnapprovedOverStock ||
        channelId == null) {
      return;
    }

    final editing = cart.editingSaleId;
    final partial = _payment == PaymentMode.partial
        ? parseMoneyInput(_partial.text)?.minor ?? 0
        : 0;
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      final receipt = await ref.read(saleRepositoryProvider).saveSale(
        lines: [
          for (final line in cart.lines)
            SaleLineInput(
              productId: line.productId,
              qty: line.qty,
              unitPriceMinor: line.unitPriceMinor,
              unitCostMinor: line.unitCostMinor,
              allowAboveStock: line.allowAboveStock,
            ),
        ],
        channelId: channelId,
        customerId: _customerId,
        payment: _payment,
        paidMinor: partial,
        accountId: _payment == PaymentMode.due ? null : accountId,
        editingSaleId: editing,
      );
      ref.read(cartProvider.notifier).reset();
      ref.invalidate(salesDefaultsProvider);
      if (!mounted) return;
      await showReceiptSheet(context, receipt);
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        editing == null
            ? SnackBar(
                content: const Text('Sale saved.'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    try {
                      await ref
                          .read(saleRepositoryProvider)
                          .undoSale(receipt.saleId);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Sale undone.')),
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Could not undo the sale.'),
                        ),
                      );
                    }
                  },
                ),
              )
            : const SnackBar(content: Text('Sale updated.')),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          SnackBar(content: Text(_message(error))),
        );
      }
    }
  }

  String _message(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Could not save the sale.';
    }
    if (error is StateError) {
      return error.message;
    }
    return 'Could not save the sale.';
  }
}

class _CartLineTile extends ConsumerStatefulWidget {
  final CartLine line;

  const _CartLineTile({super.key, required this.line});

  @override
  ConsumerState<_CartLineTile> createState() => _CartLineTileState();
}

class _CartLineTileState extends ConsumerState<_CartLineTile> {
  late final TextEditingController _price;
  final _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _price = TextEditingController(
      text: moneyToInput(Money(widget.line.unitPriceMinor)),
    );
  }

  @override
  void didUpdateWidget(covariant _CartLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_priceFocus.hasFocus) return;
    final text = moneyToInput(Money(widget.line.unitPriceMinor));
    if (_price.text != text) {
      _price.text = text;
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = widget.line;
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(cartProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    line.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove item',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.removeProduct(line.productId),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  tooltip: 'Decrease quantity',
                  onPressed: line.qty > 1
                      ? () => controller.setQty(line.productId, line.qty - 1)
                      : null,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text('${line.qty}', style: AppTextStyles.title),
                ),
                _StepperButton(
                  icon: Icons.add,
                  tooltip: 'Increase quantity',
                  onPressed: () =>
                      controller.setQty(line.productId, line.qty + 1),
                ),
                const Spacer(),
                MoneyText(
                  Money(line.lineTotalMinor),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    focusNode: _priceFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unit price',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final price = parseMoneyInput(value);
                      if (price != null) {
                        controller.setUnitPrice(line.productId, price.minor);
                      }
                    },
                    validator: (value) => parseMoneyInput(value ?? '') == null
                        ? 'Enter a price'
                        : null,
                  ),
                ),
                if (line.isDiscount) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _Tag(
                    label: 'Discount',
                    color: scheme.tertiary,
                  ),
                ],
              ],
            ),
            if (line.isBelowCost) ...[
              const SizedBox(height: AppSpacing.sm),
              _InlineWarning(
                icon: Icons.error_outline,
                color: scheme.error,
                message: 'This price is below cost. You can still sell.',
              ),
            ],
            if (line.isAboveStock) ...[
              const SizedBox(height: AppSpacing.sm),
              _InlineWarning(
                icon: Icons.warning_amber_outlined,
                color: scheme.tertiary,
                message:
                    'Only ${line.stock} in stock. Turn on the override to sell anyway.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Sell above stock'),
                value: line.allowAboveStock,
                onChanged: (value) =>
                    controller.setAllowAboveStock(line.productId, value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}

class _InlineWarning extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _InlineWarning({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _AddCustomerDialog extends ConsumerStatefulWidget {
  const _AddCustomerDialog();

  @override
  ConsumerState<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<_AddCustomerDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _nameError;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add customer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone (optional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a name');
      return;
    }
    final phone = _phone.text.trim();
    setState(() => _saving = true);
    try {
      final id = await ref.read(customerRepositoryProvider).addCustomer(
            name: name,
            phone: phone.isEmpty ? null : phone,
          );
      if (mounted) Navigator.of(context).pop(id);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add the customer.')),
        );
      }
    }
  }
}

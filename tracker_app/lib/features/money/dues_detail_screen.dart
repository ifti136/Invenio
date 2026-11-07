import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../db/app_database.dart';
import '../settings/account_editor.dart';
import '../settings/settings_providers.dart';
import 'dues_repository.dart';
import 'money_providers.dart';

class CustomerDueScreen extends ConsumerWidget {
  final int customerId;

  const CustomerDueScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(customerDueDetailProvider(customerId));

    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Customer dues')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Customer dues')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this customer',
          message: 'Something went wrong while reading their dues.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(customerDueDetailProvider(customerId)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer dues')),
            body: EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Customer not found',
              message: 'They may have been removed from this shop.',
              actionLabel: 'Back to dues',
              actionIcon: Icons.arrow_back,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }
        return _DueDetailBody(detail: item);
      },
    );
  }
}

class _DueDetailBody extends ConsumerWidget {
  final CustomerDueDetail detail;

  const _DueDetailBody({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final oldest = detail.oldestCreatedAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.name),
        actions: [
          IconButton(
            tooltip: 'Share reminder',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _share(context, ref),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share reminder'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: detail.dueMinor > 0
                      ? () => _recordPayment(context, ref)
                      : null,
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Record payment'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.hero),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.phone ?? 'No phone saved',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Owed to you',
                  style: AppTextStyles.label.copyWith(
                    color: scheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: MoneyText(
                    Money(detail.dueMinor),
                    style: AppTextStyles.display.copyWith(
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
                if (oldest != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Oldest due ${_daysSince(oldest)} ${_daysSince(oldest) == 1 ? 'day' : 'days'} ago',
                    style: AppTextStyles.body.copyWith(
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Unpaid sales', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          if (detail.sales.isEmpty)
            SizedBox(
              height: 240,
              child: EmptyState(
                icon: Icons.check_circle_outline,
                title: 'All settled',
                message: 'This customer has no unpaid sales.',
                actionLabel: 'Back to dues',
                actionIcon: Icons.arrow_back,
                onAction: () => Navigator.of(context).pop(),
              ),
            )
          else
            for (final sale in detail.sales)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    onTap: () => context.push('/sales/${sale.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sale #${sale.id}',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  DateFormat('MMM d, yyyy').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      sale.createdAt,
                                    ),
                                  ),
                                  style: AppTextStyles.body.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              MoneyText(
                                Money(sale.dueMinor),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.error,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'of ${Money(sale.totalMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
                                style: AppTextStyles.label.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.xl),
          Text('Payment timeline', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          if (detail.payments.isEmpty)
            Text(
              'No payments recorded yet.',
              style: AppTextStyles.body.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            for (final payment in detail.payments)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(payment.accountName),
                    subtitle: Text(
                      'Sale #${payment.saleId} · ${DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(payment.paidAt))}',
                    ),
                    trailing: MoneyText(
                      Money(payment.amountMinor),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RecordDuePaymentSheet(detail: detail),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded.')),
      );
    }
  }

  void _share(BuildContext context, WidgetRef ref) {
    final symbol = ref.read(currencySymbolProvider);
    final shopName = ref.read(appSettingsProvider).valueOrNull?.shopName;
    final buffer = StringBuffer();
    final shop = shopName?.trim();
    if (shop != null && shop.isNotEmpty) {
      buffer.writeln(shop);
      buffer.writeln();
    }
    buffer.writeln('Payment reminder');
    final amount = Money(detail.dueMinor).format(currencySymbol: symbol);
    if (detail.sales.isEmpty) {
      buffer.writeln('Hi ${detail.name}, $amount is outstanding.');
    } else {
      final count = detail.sales.length;
      buffer.writeln(
        'Hi ${detail.name}, $amount is due across $count ${count == 1 ? 'sale' : 'sales'}.',
      );
    }
    final oldest = detail.oldestCreatedAt;
    if (oldest != null) {
      buffer.writeln(
        'Oldest due: ${DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(oldest))} (${_daysSince(oldest)} days ago).',
      );
    }
    buffer.writeln();
    for (final sale in detail.sales) {
      buffer.writeln(
        'Sale #${sale.id} · ${DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(sale.createdAt))} · ${Money(sale.dueMinor).format(currencySymbol: symbol)} due',
      );
    }
    buffer.writeln();
    buffer.writeln('Thank you!');
    Share.share(buffer.toString().trim());
  }
}

class _RecordDuePaymentSheet extends ConsumerStatefulWidget {
  final CustomerDueDetail detail;

  const _RecordDuePaymentSheet({required this.detail});

  @override
  ConsumerState<_RecordDuePaymentSheet> createState() =>
      _RecordDuePaymentSheetState();
}

class _RecordDuePaymentSheetState
    extends ConsumerState<_RecordDuePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  int _saleId = 0;
  int? _accountId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: moneyToInput(Money(widget.detail.dueMinor)),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: accounts.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => SizedBox(
          height: 220,
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load accounts',
            message: 'Something went wrong while reading your money.',
            actionLabel: 'Retry',
            actionIcon: Icons.refresh,
            onAction: () => ref.invalidate(accountsProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return SizedBox(
              height: 320,
              child: EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Add a payment source',
                message: 'Choose where the money will be received.',
                actionLabel: 'Add account',
                actionIcon: Icons.add,
                onAction: () async {
                  await showAccountEditorDialog(context);
                },
              ),
            );
          }
          return _form(items);
        },
      ),
    );
  }

  Widget _form(List<Account> accounts) {
    final selectedAccount = accounts.any((a) => a.id == _accountId)
        ? _accountId!
        : accounts.first.id;
    final targetDue = _saleId == 0
        ? widget.detail.dueMinor
        : widget.detail.sales.firstWhere((sale) => sale.id == _saleId).dueMinor;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Record payment', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Due ${Money(widget.detail.dueMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _amount,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final amount = parseMoneyInput(value ?? '');
                if (amount == null || amount.minor <= 0) {
                  return 'Enter an amount';
                }
                if (amount.minor > targetDue) {
                  return 'Amount is more than the due';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              value: _saleId,
              decoration: const InputDecoration(labelText: 'Apply to'),
              items: [
                const DropdownMenuItem<int>(
                  value: 0,
                  child: Text('Oldest due first'),
                ),
                for (final sale in widget.detail.sales)
                  DropdownMenuItem<int>(
                    value: sale.id,
                    child: Text(
                      'Sale #${sale.id} · ${Money(sale.dueMinor).format(currencySymbol: ref.watch(currencySymbolProvider))} due',
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _saleId = value ?? 0),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              value: selectedAccount,
              decoration: const InputDecoration(labelText: 'Received in'),
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
              onPressed: _saving ? null : () => _save(selectedAccount),
              child: Text(_saving ? 'Saving…' : 'Record payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(int accountId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = parseMoneyInput(_amount.text)!;
    setState(() => _saving = true);
    try {
      await ref.read(duesRepositoryProvider).recordCustomerPayment(
            customerId: widget.detail.customerId,
            amountMinor: amount.minor,
            accountId: accountId,
            saleId: _saleId == 0 ? null : _saleId,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not record the payment.')),
      );
    }
  }
}

int _daysSince(int milliseconds) {
  final then = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(then.year, then.month, then.day);
  final days = today.difference(day).inDays;
  return days < 0 ? 0 : days;
}

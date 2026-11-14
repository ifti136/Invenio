import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/status_chip.dart';
import '../../db/app_database.dart';
import '../settings/account_editor.dart';
import '../settings/settings_providers.dart';
import 'receipt_sheet.dart';
import 'sale_flow.dart';
import 'sale_models.dart';
import 'sale_providers.dart';

class SaleDetailScreen extends ConsumerWidget {
  final int saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(saleDetailProvider(saleId));

    return detail.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Sale')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Sale')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this sale',
          message: 'Something went wrong while reading the sale.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(saleDetailProvider(saleId)),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sale')),
            body: EmptyState(
              icon: Icons.receipt_long_outlined,
              imageAsset: 'assets/illustrations/empty_sales.png',
              title: 'Sale not found',
              message: 'It may have been deleted from this shop.',
              actionLabel: 'Back to sales',
              actionIcon: Icons.arrow_back,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }
        return _SaleDetailBody(detail: item);
      },
    );
  }
}

class _SaleDetailBody extends ConsumerWidget {
  final SaleDetail detail;

  const _SaleDetailBody({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final sale = detail.sale;
    final date = DateFormat('MMM d, yyyy · h:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(sale.createdAt),
    );
    final profitColor = detail.profitMinor < 0 ? scheme.error : scheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sale #${sale.id}'),
        actions: [
          IconButton(
            tooltip: 'Share receipt',
            icon: const Icon(Icons.share_outlined),
            onPressed: () =>
                shareReceipt(context, ref, receiptFromDetail(detail)),
          ),
          IconButton(
            tooltip: 'Edit sale',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => startEditSale(context, ref, sale.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          detail.customerName ?? 'Walk-in',
                          style: AppTextStyles.title,
                        ),
                      ),
                      StatusChip(status: sale.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$date · ${detail.channelName}',
                    style: AppTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (detail.customerPhone != null &&
                      detail.customerPhone!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      detail.customerPhone!,
                      style: AppTextStyles.body.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.xl,
                    runSpacing: AppSpacing.md,
                    children: [
                      _Metric(
                        label: 'Total',
                        child: MoneyText(
                          Money(sale.totalMinor),
                          style: AppTextStyles.headline,
                        ),
                      ),
                      _Metric(
                        label: 'Paid',
                        child: MoneyText(
                          Money(detail.paidMinor),
                          style: AppTextStyles.headline.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      _Metric(
                        label: 'Due',
                        child: MoneyText(
                          Money(detail.dueMinor),
                          style: AppTextStyles.headline.copyWith(
                            color: detail.dueMinor > 0
                                ? scheme.error
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                      _Metric(
                        label: 'Profit',
                        child: MoneyText(
                          Money(detail.profitMinor),
                          showSign: true,
                          style: AppTextStyles.headline.copyWith(
                            color: profitColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(label: 'Items (${detail.lines.length})'),
          const SizedBox(height: AppSpacing.sm),
          for (final line in detail.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(line.productName),
                  subtitle: Text(
                    '${line.qty} × ${Money(line.unitPriceMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
                  ),
                  trailing: MoneyText(
                    Money(line.lineTotalMinor),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(label: 'Payments (${detail.payments.length})'),
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
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(payment.accountName),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy · h:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(payment.paidAt),
                      ),
                    ),
                    trailing: MoneyText(
                      Money(payment.amountMinor),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: AppSpacing.xl),
          if (detail.dueMinor > 0) ...[
            FilledButton.icon(
              onPressed: () => _recordPayment(context, ref),
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                'Record payment · ${Money(detail.dueMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      shareReceipt(context, ref, receiptFromDetail(detail)),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share receipt'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => startEditSale(context, ref, sale.id),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => _delete(context, ref),
            icon: Icon(Icons.delete_outline, color: scheme.error),
            label: Text(
              'Delete sale',
              style: TextStyle(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final saved = await showRecordPaymentSheet(context, detail);
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded.')),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(saleRepositoryProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete sale #${detail.sale.id}?'),
        content: const Text(
          'Stock will be restored and its payments removed. You can undo this right after.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final deleted = await repository.deleteSale(detail.sale.id);
      if (deleted == null) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Sale deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await repository.restoreSale(deleted);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Sale restored.')),
                );
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Could not restore the sale.')),
                );
              }
            },
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the sale.')),
      );
    }
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final Widget child;

  const _Metric({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.title);
  }
}

Future<bool?> showRecordPaymentSheet(
  BuildContext context,
  SaleDetail detail,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RecordPaymentSheet(detail: detail),
  );
}

class RecordPaymentSheet extends ConsumerStatefulWidget {
  final SaleDetail detail;

  const RecordPaymentSheet({super.key, required this.detail});

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
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
            title: 'Could not load payment sources',
            message: 'Something went wrong while reading your accounts.',
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
                actionLabel: 'Add source',
                actionIcon: Icons.add,
                onAction: () async {
                  await showAccountEditorDialog(context);
                },
              ),
            );
          }
          return _form(context, items);
        },
      ),
    );
  }

  Widget _form(BuildContext context, List<Account> accounts) {
    final selected = accounts.any((account) => account.id == _accountId)
        ? _accountId!
        : accounts.first.id;
    final due = widget.detail.dueMinor;

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
              'Due ${Money(due).format(currencySymbol: ref.watch(currencySymbolProvider))}',
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
                if (amount.minor > due) {
                  return 'Amount is more than the due';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              value: selected,
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
              onPressed: _saving ? null : () => _save(selected),
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
      await ref.read(saleRepositoryProvider).recordPayment(
            saleId: widget.detail.sale.id,
            amountMinor: amount.minor,
            accountId: accountId,
          );
      ref.invalidate(salesDefaultsProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not record the payment.')),
        );
      }
    }
  }
}

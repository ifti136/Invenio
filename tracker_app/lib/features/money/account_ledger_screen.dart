import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_period.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/money_text.dart';
import '../settings/account_repository.dart';
import '../settings/settings_providers.dart';
import 'money_providers.dart';

class AccountLedgerScreen extends ConsumerStatefulWidget {
  final int accountId;

  const AccountLedgerScreen({super.key, required this.accountId});

  @override
  ConsumerState<AccountLedgerScreen> createState() =>
      _AccountLedgerScreenState();
}

class _AccountLedgerScreenState extends ConsumerState<AccountLedgerScreen> {
  DatePeriod _period = DatePeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final ledger = ref.watch(accountLedgerProvider(widget.accountId));

    return ledger.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load this account',
          message: 'Something went wrong while reading the ledger.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () =>
              ref.invalidate(accountLedgerProvider(widget.accountId)),
        ),
      ),
      data: (data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Account')),
            body: EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Account not found',
              message: 'It may have been removed from this shop.',
              actionLabel: 'Back to money',
              actionIcon: Icons.arrow_back,
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }
        return _body(data);
      },
    );
  }

  Widget _body(AccountLedger ledger) {
    final entries = ledger.entriesFor(_period).reversed.toList();
    final hasAny = ledger.entries.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(ledger.account.name)),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/money/transfer?from=${ledger.account.id}',
                  ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transfer'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _adjustBalance(ledger),
                  icon: const Icon(Icons.tune),
                  label: const Text('Adjust balance'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: entries.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _Header(
                  ledger: ledger,
                  period: _period,
                  onPeriodChanged: (value) => setState(() => _period = value),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 280,
                  child: EmptyState(
                    icon: Icons.history,
                    title: hasAny
                        ? 'No activity in this period'
                        : 'No activity yet',
                    message: hasAny
                        ? 'Choose another period to see older activity.'
                        : 'Payments, expenses, transfers, and adjustments will appear here.',
                    actionLabel: hasAny ? 'Show all time' : 'Adjust balance',
                    actionIcon: hasAny ? Icons.history : Icons.tune,
                    onAction: hasAny
                        ? () => setState(() => _period = DatePeriod.allTime)
                        : () => _adjustBalance(ledger),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _Header(
                      ledger: ledger,
                      period: _period,
                      onPeriodChanged: (value) =>
                          setState(() => _period = value),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LedgerRow(entry: entries[index - 1]),
                );
              },
            ),
    );
  }

  Future<void> _adjustBalance(AccountLedger ledger) async {
    final result = await showDialog<({int amountMinor, String? note})>(
      context: context,
      builder: (_) => _AdjustBalanceDialog(ledger: ledger),
    );
    if (result == null) return;
    try {
      await ref.read(accountRepositoryProvider).addAdjustment(
            accountId: ledger.account.id,
            amountMinor: result.amountMinor,
            note: result.note,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balance adjusted.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not adjust the balance.')),
      );
    }
  }
}

class _Header extends ConsumerWidget {
  final AccountLedger ledger;
  final DatePeriod period;
  final ValueChanged<DatePeriod> onPeriodChanged;

  const _Header({
    required this.ledger,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencySymbolProvider);
    final inMinor = ledger.inMinor(period);
    final outMinor = ledger.outMinor(period);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.hero),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance',
            style: AppTextStyles.label.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          MoneyText(
            Money(ledger.balanceMinor),
            style: AppTextStyles.display.copyWith(
              color: ledger.balanceMinor < 0 ? scheme.error : scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PopupMenuButton<DatePeriod>(
            tooltip: period.label,
            initialValue: period,
            onSelected: onPeriodChanged,
            itemBuilder: (context) => [
              for (final value in DatePeriod.values)
                PopupMenuItem(value: value, child: Text(value.label)),
            ],
            child: Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(period.label),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
              backgroundColor: scheme.surface,
              side: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'In +${Money(inMinor).format(currencySymbol: symbol)} · Out −${Money(outMinor).format(currencySymbol: symbol)}',
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends ConsumerWidget {
  final LedgerEntry entry;

  const _LedgerRow({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat('MMM d, yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(entry.createdAt),
    );
    final subtitle = entry.subtitle;
    final positive = entry.amountMinor > 0;
    final hasSubtitle = subtitle != null && subtitle.trim().isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: entry.saleId == null
            ? null
            : () => context.push('/sales/${entry.saleId}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    positive ? scheme.primaryContainer : scheme.errorContainer,
                foregroundColor: positive
                    ? scheme.onPrimaryContainer
                    : scheme.onErrorContainer,
                child: Icon(_icon(entry.kind), size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      hasSubtitle ? '$date · $subtitle' : date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    Money(entry.amountMinor),
                    showSign: true,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: positive ? scheme.primary : scheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  MoneyText(
                    Money(entry.runningMinor),
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
    );
  }

  IconData _icon(String kind) {
    switch (kind) {
      case 'payment':
        return Icons.payments_outlined;
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'restock':
        return Icons.inventory_2_outlined;
      case 'transferIn':
      case 'transferOut':
        return Icons.swap_horiz;
      case 'adjustment':
        return Icons.tune;
      default:
        return Icons.circle_outlined;
    }
  }
}

class _AdjustBalanceDialog extends ConsumerStatefulWidget {
  final AccountLedger ledger;

  const _AdjustBalanceDialog({required this.ledger});

  @override
  ConsumerState<_AdjustBalanceDialog> createState() =>
      _AdjustBalanceDialogState();
}

class _AdjustBalanceDialogState extends ConsumerState<_AdjustBalanceDialog> {
  late final TextEditingController _amount;
  final _note = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: moneyToInput(Money(widget.ledger.balanceMinor)),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust balance'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current balance ${Money(widget.ledger.balanceMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'New balance',
                errorText: _error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _note,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Adjust'),
        ),
      ],
    );
  }

  void _save() {
    final target = parseMoneyInput(_amount.text, allowNegative: true);
    if (target == null) {
      setState(() => _error = 'Enter a valid balance');
      return;
    }
    final difference = target.minor - widget.ledger.balanceMinor;
    if (difference == 0) {
      setState(() => _error = 'Enter a balance that differs');
      return;
    }
    final note = _note.text.trim();
    Navigator.of(context).pop((
      amountMinor: difference,
      note: note.isEmpty ? null : note,
    ));
  }
}

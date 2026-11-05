import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../settings/account_editor.dart';
import '../settings/account_repository.dart';
import '../settings/settings_providers.dart';

class TransferScreen extends ConsumerStatefulWidget {
  final int? fromAccountId;

  const TransferScreen({super.key, this.fromAccountId});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  int? _fromId;
  int? _toId;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balances = ref.watch(accountBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load accounts',
          message: 'Something went wrong while reading your money.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(accountBalancesProvider),
        ),
        data: (items) {
          if (items.length < 2) {
            return EmptyState(
              icon: Icons.swap_horiz,
              title: 'Two accounts needed',
              message:
                  'Add another payment source to move money between accounts.',
              actionLabel: 'Add account',
              actionIcon: Icons.add,
              onAction: () => showAccountEditorDialog(context),
            );
          }
          return _form(items);
        },
      ),
    );
  }

  Widget _form(List<AccountBalance> items) {
    final from = items.any((item) => item.account.id == _fromId)
        ? _fromId!
        : (items.any((item) => item.account.id == widget.fromAccountId)
            ? widget.fromAccountId!
            : items.first.account.id);
    final others =
        items.where((item) => item.account.id != from).toList(growable: false);
    final to = others.any((item) => item.account.id == _toId)
        ? _toId!
        : others.first.account.id;
    final fromBalance =
        items.firstWhere((item) => item.account.id == from).balanceMinor;
    final amount = parseMoneyInput(_amount.text);
    final wouldGoNegative = amount != null && amount.minor > fromBalance;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          DropdownButtonFormField<int>(
            value: from,
            decoration: const InputDecoration(labelText: 'From account'),
            items: [
              for (final item in items)
                DropdownMenuItem<int>(
                  value: item.account.id,
                  child: Text(
                    '${item.account.name} · ${Money(item.balanceMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
                  ),
                ),
            ],
            onChanged: (value) => setState(() {
              _fromId = value;
              if (value == _toId) _toId = null;
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            value: to,
            decoration: const InputDecoration(labelText: 'To account'),
            items: [
              for (final item in others)
                DropdownMenuItem<int>(
                  value: item.account.id,
                  child: Text(item.account.name),
                ),
            ],
            onChanged: (value) => setState(() => _toId = value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final parsed = parseMoneyInput(value ?? '');
              if (parsed == null || parsed.minor <= 0) {
                return 'Enter an amount';
              }
              return null;
            },
          ),
          if (wouldGoNegative) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This would take the account below zero.',
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _note,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Transfers change account balances but never affect profit.',
            style: AppTextStyles.label.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _saving ? null : () => _save(from, to, fromBalance),
            child: Text(_saving ? 'Saving…' : 'Transfer'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(int from, int to, int fromBalance) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (from == to) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose two different accounts.')),
      );
      return;
    }
    final amount = parseMoneyInput(_amount.text)!;
    var allowNegative = false;
    if (amount.minor > fromBalance) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Go below zero?'),
          content: Text(
            'This transfer leaves the source account at ${Money(fromBalance - amount.minor).format(currencySymbol: ref.read(currencySymbolProvider))}. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      allowNegative = true;
    }

    setState(() => _saving = true);
    try {
      final note = _note.text.trim();
      await ref.read(accountRepositoryProvider).createTransfer(
            fromAccountId: from,
            toAccountId: to,
            amountMinor: amount.minor,
            note: note.isEmpty ? null : note,
            allowNegative: allowNegative,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer recorded.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not record the transfer.')),
      );
    }
  }
}

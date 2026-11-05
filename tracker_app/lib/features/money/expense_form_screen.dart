import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../core/widgets/empty_state.dart';
import '../../db/app_database.dart';
import '../settings/account_editor.dart';
import '../settings/account_repository.dart';
import '../settings/settings_providers.dart';
import 'expense_repository.dart';
import 'money_providers.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int? expenseId;

  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  int? _categoryId;
  int? _accountId;
  DateTime _date = DateTime.now();
  int? _originalAccountId;
  int _originalAmountMinor = 0;
  bool _seeded = false;
  bool _saving = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final expense = ref.watch(expenseProvider(widget.expenseId!));
      return expense.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit expense')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Edit expense')),
          body: EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load this expense',
            message: 'Something went wrong while reading the expense.',
            actionLabel: 'Retry',
            actionIcon: Icons.refresh,
            onAction: () => ref.invalidate(expenseProvider(widget.expenseId!)),
          ),
        ),
        data: (item) {
          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit expense')),
              body: EmptyState(
                icon: Icons.receipt_outlined,
                title: 'Expense not found',
                message: 'It may have been deleted from this shop.',
                actionLabel: 'Back',
                actionIcon: Icons.arrow_back,
                onAction: () => Navigator.of(context).pop(),
              ),
            );
          }
          _seed(item);
          return _scaffold(context);
        },
      );
    }
    return _scaffold(context);
  }

  void _seed(ExpenseItem item) {
    if (_seeded) return;
    _seeded = true;
    _amount.text = moneyToInput(Money(item.expense.amountMinor));
    _note.text = item.expense.note ?? '';
    _categoryId = item.expense.categoryId;
    _accountId = item.expense.accountId;
    _originalAccountId = item.expense.accountId;
    _originalAmountMinor = item.expense.amountMinor;
    _date = DateTime.fromMillisecondsSinceEpoch(item.expense.date);
  }

  Widget _scaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit expense' : 'New expense'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete expense',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final balances = ref.watch(accountBalancesProvider);
    final categories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];

    return balances.when(
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
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Add a payment source',
            message: 'An expense needs an account to pay from.',
            actionLabel: 'Add account',
            actionIcon: Icons.add,
            onAction: () => showAccountEditorDialog(context),
          );
        }
        if (categories.isEmpty) {
          return EmptyState(
            icon: Icons.category_outlined,
            title: 'Add a category',
            message: 'Create an expense category before logging a cost.',
            actionLabel: 'Open settings',
            actionIcon: Icons.settings_outlined,
            onAction: () => context.push('/settings/names'),
          );
        }
        return _form(context, items, categories);
      },
    );
  }

  Widget _form(
    BuildContext context,
    List<AccountBalance> accounts,
    List<ExpenseCategory> categories,
  ) {
    final category = categories.any((item) => item.id == _categoryId)
        ? _categoryId!
        : categories.first.id;
    final account = accounts.any((item) => item.account.id == _accountId)
        ? _accountId!
        : accounts.first.account.id;
    final amount = parseMoneyInput(_amount.text);
    final balance =
        accounts.firstWhere((item) => item.account.id == account).balanceMinor;
    final available = _isEditing && _originalAccountId == account
        ? balance + _originalAmountMinor
        : balance;
    final wouldGoNegative = amount != null && amount.minor > available;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextFormField(
            controller: _amount,
            autofocus: !_isEditing,
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
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            value: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final item in categories)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(item.name),
                ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            value: account,
            decoration: const InputDecoration(labelText: 'Paid from'),
            items: [
              for (final item in accounts)
                DropdownMenuItem<int>(
                  value: item.account.id,
                  child: Text(
                    '${item.account.name} · ${Money(item.balanceMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
                  ),
                ),
            ],
            onChanged: (value) => setState(() => _accountId = value),
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
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('Date · ${DateFormat('MMM d, yyyy').format(_date)}'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _note,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _saving
                ? null
                : () => _save(
                      category: category,
                      account: account,
                      wouldGoNegative: wouldGoNegative,
                    ),
            child: Text(_saving ? 'Saving…' : 'Save expense'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save({
    required int category,
    required int account,
    required bool wouldGoNegative,
  }) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = parseMoneyInput(_amount.text)!;
    var allowNegative = false;
    if (wouldGoNegative) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Go below zero?'),
          content: const Text(
            'This expense leaves the account with a negative balance. Continue?',
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
    final note = _note.text.trim();
    try {
      final repository = ref.read(expenseRepositoryProvider);
      if (_isEditing) {
        await repository.updateExpense(
          id: widget.expenseId!,
          categoryId: category,
          accountId: account,
          amountMinor: amount.minor,
          date: _date,
          note: note.isEmpty ? null : note,
          allowNegative: allowNegative,
        );
      } else {
        await repository.addExpense(
          categoryId: category,
          accountId: account,
          amountMinor: amount.minor,
          date: _date,
          note: note.isEmpty ? null : note,
          allowNegative: allowNegative,
        );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Expense updated.' : 'Expense added.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the expense.')),
      );
    }
  }

  Future<void> _delete() async {
    final repository = ref.read(expenseRepositoryProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: const Text(
          'The amount will be added back to the account. You can undo this right after.',
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
      final deleted = await repository.deleteExpense(widget.expenseId!);
      if (deleted == null) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Expense deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await repository.restoreExpense(deleted);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Expense restored.')),
                );
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Could not restore the expense.'),
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the expense.')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/services/alert_service.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/expenses/expense_provider.dart';
import 'package:tracker/features/expenses/expense_repository.dart';
import 'package:tracker/features/finance/allocation_rules_repository.dart';
import 'package:tracker/features/finance/finance_repository.dart';
import 'package:tracker/features/products/wallet_repository.dart';
import 'package:tracker/features/products/bucket_repository.dart';
import 'package:tracker/features/products/widgets/wallet_picker_sheet.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int? expenseId;

  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _form = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.misc;
  DateTime _date = DateTime.now();
  int? _walletId;
  String? _walletName;
  int? _allocationRuleId;
  String? _allocationRuleLabel;
  int? _selectedBucketId;
  String? _selectedBucketLabel;
  String _ownership = 'business';
  bool _saving = false;
  bool _loaded = false;

  bool get _isEdit => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final lastWalletId =
            await ref.read(walletRepositoryProvider).getLastUsedWalletId();
        if (lastWalletId != null) {
          final wallets = await ref.read(walletRepositoryProvider).getWallets();
          final wallet = wallets.firstWhere((w) => w.id == lastWalletId);
          setState(() {
            _walletId = wallet.id;
            _walletName = wallet.name;
          });
        }
        setState(() => _loaded = true);
      });
    }
  }

  Future<void> _load() async {
    final e =
        await ref.read(expenseRepositoryProvider).getById(widget.expenseId!);
    if (e == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _amountCtrl.text = e.amount.toStringAsFixed(2);
    _category = ExpenseCategoryX.fromKey(e.category);
    _noteCtrl.text = e.note ?? '';
    _date = DateTime.fromMillisecondsSinceEpoch(e.date);
    _walletId = e.walletId;
    _ownership = e.ownership;
    _allocationRuleId = e.allocationRuleId;
    if (_walletId != null) {
      final wallets = await ref.read(walletRepositoryProvider).getWallets();
      _walletName = wallets.firstWhere((w) => w.id == _walletId).name;
    }
    if (_allocationRuleId != null) {
      final rules =
          await ref.read(allocationRulesRepositoryProvider).getRules();
      _allocationRuleLabel =
          rules.firstWhere((r) => r.id == _allocationRuleId).label;
    }
    if (e.bucketId != null) {
      final buckets =
          await ref.read(bucketRepositoryProvider).getById(e.bucketId!);
      if (buckets != null) {
        _selectedBucketId = e.bucketId;
        _selectedBucketLabel = buckets.name;
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickAllocationRule() async {
    final rules = await ref.read(allocationRulesRepositoryProvider).getRules();
    final activeRules = rules.where((r) => r.isActive).toList();
    final financials =
        await ref.read(financeRepositoryProvider).getRuleFinancials();

    if (!mounted) return;

    final selectedRuleId = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassPanel(
        opaque: true,
        radius: 24.0,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Allocate to fund',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.close, size: 20),
              title: const Text('None'),
              onTap: () => Navigator.of(ctx).pop(null),
            ),
            const Divider(color: Colors.white10),
            if (activeRules.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No active allocation rules found.')),
              )
            else
              ...activeRules.map((rule) {
                final balance = financials[rule.id]?.availableBalance ?? 0.0;
                return ListTile(
                  title: Text(rule.label),
                  trailing: Text(
                    formatMoney(balance),
                    style: TextStyle(
                      color: balance < 0 ? AppColors.danger : AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop(rule.id),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (selectedRuleId != null) {
      final rule = activeRules.firstWhere((r) => r.id == selectedRuleId);
      setState(() {
        _allocationRuleId = selectedRuleId;
        _allocationRuleLabel = rule.label;
      });
      _checkOverdraw(selectedRuleId);
    } else {
      setState(() {
        _allocationRuleId = null;
        _allocationRuleLabel = null;
      });
    }
  }

  Future<void> _pickBucket() async {
    final balances =
        await ref.read(bucketRepositoryProvider).getBucketWithAvailables();

    if (!mounted) return;

    final selectedBucketId = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GlassPanel(
        opaque: true,
        radius: 24.0,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Budget Bucket',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.close, size: 20),
              title: const Text('None'),
              onTap: () => Navigator.of(ctx).pop(null),
            ),
            const Divider(color: Colors.white10),
            if (balances.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No budget buckets found.')),
              )
            else
              ...balances.map((bucket) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: bucket.color != null
                        ? Color(
                            int.parse(bucket.color!.replaceFirst('#', '0xff')))
                        : AppColors.accent,
                  ),
                  title: Text(bucket.name),
                  trailing: Text(
                    formatMoney(bucket.available),
                    style: TextStyle(
                      color: bucket.available < 0
                          ? AppColors.danger
                          : AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(ctx).pop(bucket.id),
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (selectedBucketId != null) {
      final bucket = balances.firstWhere((b) => b.id == selectedBucketId);
      setState(() {
        _selectedBucketId = selectedBucketId;
        _selectedBucketLabel = bucket.name;
      });
    } else {
      setState(() {
        _selectedBucketId = null;
        _selectedBucketLabel = null;
      });
    }
  }

  Future<void> _checkOverdraw(int ruleId) async {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    final balance =
        await ref.read(financeRepositoryProvider).getAvailableBalance(ruleId);
    if (amount > balance) {
      final overdraw = amount - balance;
      final rules =
          await ref.read(allocationRulesRepositoryProvider).getRules();
      final rule = rules.firstWhere((r) => r.id == ruleId);

      final alert = AllocationOverdrawAlert(
        ruleLabel: rule.label,
        overdrawAmount: overdraw,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber.shade800,
          content: Text(alert.message),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_walletId == null) {
      await _showError('Please select a wallet.');
      return;
    }

    final amount = double.parse(_amountCtrl.text.trim());

    if (_selectedBucketId != null) {
      final balances =
          await ref.read(bucketRepositoryProvider).getBucketWithAvailables();
      final bucket = balances.firstWhere((b) => b.id == _selectedBucketId);
      if (amount > bucket.available) {
        final overdraw = amount - bucket.available;
        final ok = await _confirmBucketOverdraw(bucket.name, overdraw);
        if (ok != true) return;
      }
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      if (_isEdit) {
        await repo.update(
          id: widget.expenseId!,
          amount: amount,
          category: _category.key,
          note: note,
          date: _date,
          walletId: _walletId,
          ownership: _ownership,
          allocationRuleId: _allocationRuleId,
          bucketId: _selectedBucketId,
        );
      } else {
        await repo.add(
          amount: amount,
          category: _category.key,
          note: note,
          date: _date,
          walletId: _walletId,
          ownership: _ownership,
          allocationRuleId: _allocationRuleId,
          bucketId: _selectedBucketId,
        );
      }
      if (!mounted) return;
      ref.invalidate(expenseListProvider);
      ref.invalidate(dashboardProvider);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Expense updated' : 'Expense recorded'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final result = await showGlassDialog<bool>(
      context: context,
      title: 'Delete expense?',
      message:
          'This removes the ${_category.label.toLowerCase()} expense of ${_amountCtrl.text.isEmpty ? '—' : formatMoney(double.tryParse(_amountCtrl.text) ?? 0)}.',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () {
            HapticService.trigger(HapticProfile.light);
            Navigator.of(ctx).pop(false);
          },
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () {
            HapticService.trigger(HapticProfile.medium);
            Navigator.of(ctx).pop(true);
          },
        ),
      ],
    );
    if (result != true) return;
    await ref.read(expenseRepositoryProvider).delete(widget.expenseId!);
    if (!mounted) return;
    ref.invalidate(expenseListProvider);
    ref.invalidate(dashboardProvider);
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
    );
  }

  Future<void> _showError(String msg) {
    return showGlassDialog(
      context: context,
      title: 'Could not save',
      message: msg,
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'OK',
          isPrimary: true,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
  }

  Future<bool?> _confirmBucketOverdraw(
      String bucketName, double overdrawAmount) {
    return showGlassDialog<bool>(
      context: context,
      title: 'Budget Overdraw',
      message:
          'This expense will overdraw your $bucketName budget by ৳${overdrawAmount.toStringAsFixed(2)}. Do you wish to proceed?',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () {
            HapticService.trigger(HapticProfile.light);
            Navigator.of(ctx).pop(false);
          },
        ),
        GlassDialogAction(
          label: 'Proceed',
          isPrimary: true,
          onPressed: () {
            HapticService.trigger(HapticProfile.medium);
            Navigator.of(ctx).pop(true);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            GlassPanel(
              noBlur: true,
              padding: const EdgeInsets.all(16),
              child: GlassTextField(
                controller: _amountCtrl,
                label: 'Amount (৳)',
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.monetization_on_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final d = double.tryParse(v?.trim() ?? '');
                  if (d == null || d <= 0) {
                    return 'Enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              noBlur: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ToggleGroup<ExpenseCategory>(
                    value: _category,
                    values: ExpenseCategory.values,
                    labelOf: (v) => v.label,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              noBlur: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ownership',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ToggleGroup<String>(
                        value: _ownership,
                        values: const ['business', 'personal'],
                        labelOf: (v) =>
                            v == 'business' ? 'Business' : 'Personal',
                        onChanged: (v) => setState(() => _ownership = v),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final id = await showWalletPicker(
                              context,
                              ref: ref,
                              selectedId: _walletId,
                            );
                            if (id != null) {
                              final wallets = await ref
                                  .read(walletRepositoryProvider)
                                  .getWallets();
                              final name =
                                  wallets.firstWhere((w) => w.id == id).name;
                              setState(() {
                                _walletId = id;
                                _walletName = name;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 0.6,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 16,
                                    color: AppColors.accent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _walletName ?? 'Select Wallet',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.expand_more,
                                    size: 16, color: Colors.white54),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_ownership == 'business') ...[
              const SizedBox(height: 12),
              GlassPanel(
                noBlur: true,
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickAllocationRule,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_outlined,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _allocationRuleLabel ?? 'No fund allocated',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.expand_more,
                            size: 16, color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GlassPanel(
                noBlur: true,
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickBucket,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.savings_outlined,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedBucketLabel ?? 'No budget bucket',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.expand_more,
                            size: 16, color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            GlassPanel(
              noBlur: true,
              padding: const EdgeInsets.all(16),
              child: GlassTextField(
                controller: _noteCtrl,
                label: 'Note (optional)',
                hint: 'What was this for?',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              noBlur: true,
              padding: const EdgeInsets.all(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(
                      Icons.calendar_month_outlined,
                      color: scheme.primary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  child: Text(
                    formatDate(_date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_isEdit) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(
                            color: AppColors.danger.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: _isEdit ? 2 : 1,
                  child: FilledButton(
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
                        : Text(_isEdit ? 'Save changes' : 'Record expense'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleGroup<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  const _ToggleGroup({
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final v in values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticService.trigger(HapticProfile.light);
                onChanged(v);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v == value
                      ? scheme.primary.withOpacity(0.18)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: v == value
                        ? scheme.primary.withOpacity(0.55)
                        : scheme.onSurfaceVariant.withOpacity(0.18),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  labelOf(v),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: v == value ? FontWeight.w700 : FontWeight.w500,
                    color: v == value ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          if (v != values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

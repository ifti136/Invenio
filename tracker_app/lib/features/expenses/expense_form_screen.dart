import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/features/dashboard/dashboard_provider.dart';
import 'package:tracker/features/expenses/expense_provider.dart';
import 'package:tracker/features/expenses/expense_repository.dart';

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
  bool _saving = false;
  bool _loaded = false;

  bool get _isEdit => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      setState(() => _loaded = true);
    }
  }

  Future<void> _load() async {
    final e = await ref.read(expenseRepositoryProvider).getById(widget.expenseId!);
    if (e == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    _amountCtrl.text = e.amount.toStringAsFixed(2);
    _category = ExpenseCategoryX.fromKey(e.category);
    _noteCtrl.text = e.note ?? '';
    _date = DateTime.fromMillisecondsSinceEpoch(e.date);
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

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final amount = double.parse(_amountCtrl.text.trim());
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      if (_isEdit) {
        await repo.update(
          id: widget.expenseId!,
          amount: amount,
          category: _category.key,
          note: note,
          date: _date,
        );
      } else {
        await repo.add(
          amount: amount,
          category: _category.key,
          note: note,
          date: _date,
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
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
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
      actions: [
        GlassDialogAction(
          label: 'OK',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(),
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
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final d = double.tryParse(v?.trim() ?? '');
                  if (d == null || d <= 0) return 'Enter a valid amount greater than 0';
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
                        side: BorderSide(color: AppColors.danger.withOpacity(0.4)),
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
              onTap: () => onChanged(v),
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
                    fontWeight:
                        v == value ? FontWeight.w700 : FontWeight.w500,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/utils/input_parsing.dart';
import '../../db/app_database.dart';
import 'settings_providers.dart';

Future<bool> showAccountEditorDialog(
  BuildContext context, {
  Account? account,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AccountEditorDialog(account: account),
  );
  return result ?? false;
}

class AccountEditorDialog extends ConsumerStatefulWidget {
  final Account? account;

  const AccountEditorDialog({super.key, this.account});

  @override
  ConsumerState<AccountEditorDialog> createState() =>
      _AccountEditorDialogState();
}

class _AccountEditorDialogState extends ConsumerState<AccountEditorDialog> {
  late final TextEditingController _name;
  late final TextEditingController _opening;
  String? _nameError;
  String? _openingError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.account?.name ?? '');
    _opening = TextEditingController(
      text: widget.account == null
          ? '0.00'
          : moneyToInput(Money(widget.account!.openingBalanceMinor)),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit payment source' : 'Add payment source'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Cash, Bank, Mobile wallet',
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _opening,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Opening balance',
                errorText: _openingError,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final opening = parseMoneyInput(_opening.text);
    setState(() {
      _nameError = name.isEmpty ? 'Enter a name' : null;
      _openingError = opening == null ? 'Enter a valid amount' : null;
    });
    if (name.isEmpty || opening == null) return;

    setState(() => _saving = true);
    try {
      final repository = ref.read(accountRepositoryProvider);
      if (widget.account == null) {
        await repository.addAccount(
          name: name,
          openingBalanceMinor: opening.minor,
        );
      } else {
        await repository.updateAccount(
          id: widget.account!.id,
          name: name,
          openingBalanceMinor: opening.minor,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the payment source.')),
        );
      }
    }
  }
}


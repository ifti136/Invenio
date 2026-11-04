import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/input_parsing.dart';
import '../../features/settings/settings_providers.dart';
import 'first_run_providers.dart';

class FirstRunScreen extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const FirstRunScreen({super.key, required this.onCompleted});

  @override
  ConsumerState<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _DraftAccount {
  final TextEditingController name;
  final TextEditingController opening;

  _DraftAccount({required String name, String opening = '0.00'})
      : name = TextEditingController(text: name),
        opening = TextEditingController(text: opening);

  void dispose() {
    name.dispose();
    opening.dispose();
  }
}

class _FirstRunScreenState extends ConsumerState<FirstRunScreen> {
  final _symbol = TextEditingController(text: '\u09F3');
  final List<_DraftAccount> _accounts = [
    _DraftAccount(name: 'Cash'),
  ];
  String? _symbolError;
  bool _saving = false;

  @override
  void dispose() {
    _symbol.dispose();
    for (final account in _accounts) {
      account.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(
                    Icons.storefront_outlined,
                    size: 64,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Welcome to Invenio',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Set up your shop in one quick step. You can change everything later in Settings.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Currency symbol', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _symbol,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'Symbol',
                      helperText: 'Used for every money amount.',
                      errorText: _symbolError,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Where do you keep money?', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _quickAddChip('Cash'),
                      _quickAddChip('Bank'),
                      _quickAddChip('Mobile wallet'),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Custom'),
                        onPressed: _addCustom,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_accounts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Text(
                        'Add at least one payment source to continue.',
                        style: AppTextStyles.body.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  for (var i = 0; i < _accounts.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _draftCard(i),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _start,
                  child: Text(_saving ? 'Setting up…' : 'Start'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAddChip(String name) {
    final exists = _accounts.any(
      (account) => account.name.text.trim().toLowerCase() == name.toLowerCase(),
    );
    return ActionChip(
      avatar: Icon(exists ? Icons.check : Icons.add, size: 18),
      label: Text(name),
      onPressed: exists ? null : () => _addAccount(name),
    );
  }

  Widget _draftCard(int index) {
    final account = _accounts[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: account.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove source',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _accounts.removeAt(index).dispose();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: account.opening,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Opening balance',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addAccount(String name) {
    setState(() => _accounts.add(_DraftAccount(name: name)));
  }

  Future<void> _addCustom() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom payment source'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    _addAccount(name);
  }

  Future<void> _start() async {
    final symbol = _symbol.text.trim();
    final entries = <(String, int)>[];
    var valid = symbol.isNotEmpty;
    setState(() => _symbolError = valid ? null : 'Enter a currency symbol');

    for (final account in _accounts) {
      final name = account.name.text.trim();
      final opening = parseMoneyInput(account.opening.text);
      if (name.isEmpty || opening == null) {
        valid = false;
        continue;
      }
      entries.add((name, opening.minor));
    }
    if (entries.isEmpty) valid = false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add at least one payment source with a valid opening balance.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final accountRepository = ref.read(accountRepositoryProvider);
      for (final entry in entries) {
        await accountRepository.addAccount(
          name: entry.$1,
          openingBalanceMinor: entry.$2,
        );
      }
      await ref.read(settingsRepositoryProvider).setCurrencySymbol(symbol);
      await markFirstRunDone();
      widget.onCompleted();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not finish setup. Try again.')),
        );
      }
    }
  }
}

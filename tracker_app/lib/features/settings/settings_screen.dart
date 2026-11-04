import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../db/app_database.dart';
import '../../services/backup_service.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _dailyBackup;

  @override
  void initState() {
    super.initState();
    ref.read(backupServiceProvider).isDailyBackupEnabled().then((value) {
      if (mounted) setState(() => _dailyBackup = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _section('Shop'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('Shop name'),
                  subtitle: Text(settings?.shopName ?? 'Not set'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editShopName(settings?.shopName),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Payment sources'),
                  subtitle: Text(
                    accounts.isEmpty
                        ? 'Add where you keep money'
                        : '${accounts.length} source${accounts.length == 1 ? '' : 's'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/accounts'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.sell_outlined),
                  title: const Text('Channels and categories'),
                  subtitle: const Text('Rename sale channels and expense categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/names'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency symbol'),
                  subtitle: Text(settings?.currencySymbol ?? '\u09F3'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editCurrency(settings?.currencySymbol),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _section('Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: AppTextStyles.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _section('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Back up database'),
                  subtitle: const Text('Share a copy of your data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _shareBackup,
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.schedule_outlined),
                  title: const Text('Daily auto-backup'),
                  subtitle: const Text('Save a local copy once a day'),
                  value: _dailyBackup ?? true,
                  onChanged: (value) async {
                    setState(() => _dailyBackup = value);
                    await ref
                        .read(backupServiceProvider)
                        .setDailyBackupEnabled(value);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.table_view_outlined),
                  title: const Text('Export CSV'),
                  subtitle: const Text('Available in Phase 5'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('CSV export arrives in Phase 5.'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Clear all data',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: const Text('Remove everything from this device'),
                  onTap: _clearAllData,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _section('About'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Invenio'),
              subtitle: Text('Version 2.3.0+20'),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _editShopName(String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Shop name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Used on receipts',
          ),
          onSubmitted: (text) => Navigator.of(dialogContext).pop(text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await ref
        .read(settingsRepositoryProvider)
        .setShopName(value.isEmpty ? null : value);
  }

  Future<void> _editCurrency(String? current) async {
    final controller = TextEditingController(text: current ?? '\u09F3');
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Currency symbol'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 4,
          decoration: const InputDecoration(labelText: 'Symbol'),
          onSubmitted: (text) => Navigator.of(dialogContext).pop(text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    await ref.read(settingsRepositoryProvider).setCurrencySymbol(value);
  }

  Future<void> _shareBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backupServiceProvider).shareDatabase();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not back up your data.')),
      );
    }
  }

  Future<void> _clearAllData() async {
    final first = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This removes products, sales, accounts, and settings from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    final second = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
    if (second != true || !mounted) return;

    try {
      await ref.read(appDatabaseProvider).clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not clear the data.')),
        );
      }
    }
  }
}

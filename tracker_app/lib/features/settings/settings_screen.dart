import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_mode_provider.dart';
import '../../services/backup_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
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
              ref.read(themeModeProvider.notifier).setMode(selection.first);
            },
          ),
          const SizedBox(height: 24),
          Text('Data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Back up database'),
              subtitle: const Text('Share a copy of your data'),
              onTap: () => _shareBackup(context, ref),
            ),
          ),
          const SizedBox(height: 24),
          Text('About', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Invenio'),
              subtitle: Text('Version 2.3.0+20'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backupServiceProvider).shareDatabase();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not back up: $error')),
      );
    }
  }
}

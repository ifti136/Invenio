import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_tokens.dart';
import 'settings_providers.dart';

class SettingsNamesScreen extends ConsumerWidget {
  const SettingsNamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = ref.watch(channelsProvider);
    final categories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Channels and categories')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _sectionHeader(
            context,
            'Sale channels',
            onAdd: () => _editName(context, ref, isChannel: true),
          ),
          channels.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _errorCard(
              context,
              'Could not load channels',
              () => ref.invalidate(channelsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _emptyCard(
                  context,
                  icon: Icons.sell_outlined,
                  title: 'No channels yet',
                  message: 'Add a channel such as In person or Online.',
                  actionLabel: 'Add channel',
                  onAction: () => _editName(context, ref, isChannel: true),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const Divider(),
                      ListTile(
                        leading: const Icon(Icons.sell_outlined),
                        title: Text(items[i].name),
                        trailing: IconButton(
                          tooltip: 'Rename channel',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editName(
                            context,
                            ref,
                            isChannel: true,
                            id: items[i].id,
                            current: items[i].name,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _sectionHeader(
            context,
            'Expense categories',
            onAdd: () => _editName(context, ref, isChannel: false),
          ),
          categories.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _errorCard(
              context,
              'Could not load categories',
              () => ref.invalidate(expenseCategoriesProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _emptyCard(
                  context,
                  icon: Icons.category_outlined,
                  title: 'No categories yet',
                  message: 'Add a category such as Ads, Delivery, or Rent.',
                  actionLabel: 'Add category',
                  onAction: () => _editName(context, ref, isChannel: false),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const Divider(),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: Text(items[i].name),
                        trailing: IconButton(
                          tooltip: 'Rename category',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editName(
                            context,
                            ref,
                            isChannel: false,
                            id: items[i].id,
                            current: items[i].name,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String label, {
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.label.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: scheme.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: scheme.error),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref, {
    required bool isChannel,
    int? id,
    String? current,
  }) async {
    final controller = TextEditingController(text: current ?? '');
    final isEditing = id != null;
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isEditing
              ? 'Rename ${isChannel ? 'channel' : 'category'}'
              : 'Add ${isChannel ? 'channel' : 'category'}',
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name'),
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
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;

    final repository = ref.read(namesRepositoryProvider);
    if (isChannel) {
      if (id == null) {
        await repository.addChannel(value);
      } else {
        await repository.renameChannel(id, value);
      }
    } else {
      if (id == null) {
        await repository.addExpenseCategory(value);
      } else {
        await repository.renameExpenseCategory(id, value);
      }
    }
  }
}

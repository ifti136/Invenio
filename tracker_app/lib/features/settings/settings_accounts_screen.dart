import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money/money.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/empty_state.dart';
import '../../db/app_database.dart';
import 'account_editor.dart';
import 'settings_providers.dart';

class SettingsAccountsScreen extends ConsumerWidget {
  const SettingsAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(archivedAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment sources')),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load payment sources',
          message: 'Something went wrong while reading your accounts.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh,
          onAction: () => ref.invalidate(archivedAccountsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No payment sources yet',
              message:
                  'Add Cash, a bank account, or a mobile wallet to track where money lives.',
              actionLabel: 'Add source',
              actionIcon: Icons.add,
              onAction: () => _add(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final account = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    account.archived
                        ? Icons.archive_outlined
                        : Icons.account_balance_wallet_outlined,
                  ),
                  title: Text(account.name),
                  subtitle: Text(
                    account.archived
                        ? 'Archived'
                        : 'Opening ${Money(account.openingBalanceMinor).format(currencySymbol: ref.watch(currencySymbolProvider))}',
                  ),
                  trailing: Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _edit(context, account),
                      ),
                      IconButton(
                        tooltip:
                            account.archived ? 'Restore' : 'Archive source',
                        icon: Icon(
                          account.archived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                        ),
                        onPressed: () => ref
                            .read(accountRepositoryProvider)
                            .setArchived(account.id, !account.archived),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add),
        label: const Text('Add source'),
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    await showAccountEditorDialog(context);
  }

  Future<void> _edit(BuildContext context, Account account) async {
    await showAccountEditorDialog(context, account: account);
  }
}

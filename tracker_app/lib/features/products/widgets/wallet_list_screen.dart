import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/utils/formatters.dart';
import '../wallet_repository.dart';
import 'wallet_form_sheet.dart';
import '../../transfers/transfer_form_sheet.dart';
import '../../dashboard/dashboard_provider.dart';

class WalletListScreen extends ConsumerWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Wallets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white70),
            tooltip: 'Transfer History',
            onPressed: () => context.push('/settings/wallets/transfers'),
          ),
        ],
      ),
      body: FutureBuilder<List<WalletWithBalance>>(
        future: ref.read(walletRepositoryProvider).getWalletWithBalances(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading wallets: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final balances = snapshot.data!;

          if (balances.isEmpty) {
            return const Center(
              child: Text(
                'No wallet available',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: balances.length,
            itemBuilder: (context, index) {
              final walletBalance = balances[index];
              final balance = walletBalance.balance;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  noBlur: true,
                  child: ListTile(
                    title: Text(
                      walletBalance.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      formatMoney(balance),
                      style: TextStyle(
                        color:
                            balance >= 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () async {
                      HapticService.trigger(HapticProfile.light);
                      final wallet = await ref
                          .read(walletRepositoryProvider)
                          .getWalletById(walletBalance.walletId);
                      if (context.mounted) {
                        showWalletFormSheet(context, wallet: wallet);
                      }
                    },
                    onLongPress: () {
                      HapticService.trigger(HapticProfile.heavy);
                      _confirmDeleteWallet(
                          context, ref, walletBalance.walletId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'transfer',
            backgroundColor: AppColors.accent.withOpacity(0.8),
            onPressed: () {
              HapticService.trigger(HapticProfile.medium);
              showTransferFormSheet(context);
            },
            child: const Icon(Icons.swap_horiz, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: AppColors.accent,
            onPressed: () {
              HapticService.trigger(HapticProfile.medium);
              showWalletFormSheet(context);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWallet(BuildContext context, WidgetRef ref, int id) {
    showGlassDialog(
      context: context,
      title: 'Delete Wallet',
      message:
          'Are you sure you want to delete this wallet? This action cannot be undone.',
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () {
            HapticService.trigger(HapticProfile.light);
            Navigator.of(ctx).pop();
          },
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () async {
            final navigator = Navigator.of(ctx);
            HapticService.trigger(HapticProfile.heavy);
            await ref.read(walletRepositoryProvider).deleteWallet(id);
            ref.invalidate(dashboardProvider);
            navigator.pop();
          },
        ),
      ],
    );
  }
}

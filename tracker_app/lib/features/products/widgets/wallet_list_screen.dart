import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import '../wallet_repository.dart';
import 'wallet_form_sheet.dart';

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
      ),
      body: FutureBuilder<List<WalletWithBalance>>(
        future: ref.read(walletRepositoryProvider).getWalletWithBalances(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final balances = snapshot.data!;

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
                      '\$${balance.toStringAsFixed(2)}',
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
      floatingActionButton: HapticWrapper(
        profile: HapticProfile.medium,
        onTap: () => showWalletFormSheet(context),
        child: FloatingActionButton(
          backgroundColor: AppColors.accent,
          onPressed: null,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
            navigator.pop();
          },
        ),
      ],
    );
  }
}

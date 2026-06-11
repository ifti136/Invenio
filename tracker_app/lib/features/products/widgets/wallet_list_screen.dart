import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import '../wallet_repository.dart';
import 'wallet_form_screen.dart';


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
      body: FutureBuilder<List<WalletBalance>>(
        future: ref.read(walletRepositoryProvider).getWalletBalances(),
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: balance >= 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () => context.push('/products/settings/wallets/edit/${walletBalance.walletId}'),
                    onLongPress: () => _confirmDeleteWallet(context, ref, walletBalance.walletId),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => context.push('/products/settings/wallets/add'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDeleteWallet(BuildContext context, WidgetRef ref, int id) {
    showGlassDialog(
      context: context,
      title: 'Delete Wallet',
      message: 'Are you sure you want to delete this wallet? This action cannot be undone.',
      actionsBuilder: (ctx) => [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () async {
            await ref.read(walletRepositoryProvider).deleteWallet(id);
            Navigator.of(ctx).pop();
            // The FutureBuilder will rebuild, but we might need to trigger a refresh if using a provider
          },
          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}

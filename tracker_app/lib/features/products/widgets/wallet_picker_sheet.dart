import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../wallet_repository.dart';

Future<int?> showWalletPicker(
  BuildContext context, {
  required WidgetRef ref,
  int? selectedId,
}) async {
  final wallets = await ref.read(walletRepositoryProvider).getWallets();
  final balances = await ref.read(walletRepositoryProvider).getWalletBalances();

  return await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: wallets.length,
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  final balance = balances.firstWhere(
                    (b) => b.walletId == wallet.id,
                    orElse: () => WalletBalance(walletId: -1, name: '', balance: 0.0),
                  ).balance;
                  final isSelected = wallet.id == selectedId;

                  return ListTile(
                    title: Text(wallet.name),
                    trailing: Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () => Navigator.of(context).pop(wallet.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

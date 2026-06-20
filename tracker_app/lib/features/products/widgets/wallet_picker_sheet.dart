import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/products/wallet_repository.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';

Future<int?> showWalletPicker(
  BuildContext context, {
  required WidgetRef ref,
  int? selectedId,
}) async {
  final wallets = await ref.read(walletRepositoryProvider).getWallets();
  final balances =
      await ref.read(walletRepositoryProvider).getWalletWithBalances();

  if (!context.mounted) return null;
  return await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return GlassPanel(
        radius: 28,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        noBlur: true,
        opaque: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Select Wallet',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: wallets.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No wallet available',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = wallets[index];
                        final balance = balances
                            .firstWhere(
                              (b) => b.walletId == wallet.id,
                              orElse: () => WalletWithBalance(
                                  walletId: -1, name: '', balance: 0.0),
                            )
                            .balance;
                        final isSelected = wallet.id == selectedId;

                        return ListTile(
                          title: Text(wallet.name),
                          trailing: Text(
                            formatMoney(balance),
                            style: TextStyle(
                              color: balance >= 0
                                  ? AppColors.success
                                  : AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () {
                            HapticService.trigger(HapticProfile.light);
                            Navigator.of(context).pop(wallet.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    },
  );
}

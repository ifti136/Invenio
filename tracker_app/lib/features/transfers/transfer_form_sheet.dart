import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/haptic_service.dart';
import '../finance/transfer_repository.dart';
import '../products/wallet_repository.dart';
import '../../db/app_database.dart';

Future<void> showTransferFormSheet(
  BuildContext context, {
  int? fromWalletId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransferFormSheet(fromWalletId: fromWalletId),
  );
}

class _TransferFormSheet extends ConsumerStatefulWidget {
  final int? fromWalletId;
  const _TransferFormSheet({this.fromWalletId});

  @override
  ConsumerState<_TransferFormSheet> createState() => _TransferFormSheetState();
}

class _TransferFormSheetState extends ConsumerState<_TransferFormSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _fromWalletId;
  int? _toWalletId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fromWalletId = widget.fromWalletId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_fromWalletId == null || _toWalletId == null) {
      setState(() => _error = 'Select both wallets');
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }

    HapticService.trigger(HapticProfile.medium);
    try {
      await ref.read(transferRepositoryProvider).createTransfer(
        _fromWalletId!,
        _toWalletId!,
        amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletRepositoryProvider).getWallets();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 80,
      ),
      child: GlassPanel(
        solid: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<List<Wallet>>(
            future: walletsAsync,
            builder: (context, snapshot) {
              final wallets = snapshot.data ?? [];
              final walletOptions = wallets.where((w) => w.isActive).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transfer Money',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: _fromWalletId,
                    decoration: const InputDecoration(
                      labelText: 'From Wallet',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white),
                    items: walletOptions.map((w) {
                      return DropdownMenuItem(
                        value: w.id,
                        child: Text(
                          '${w.name} (${w.type})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _fromWalletId = v;
                        if (_toWalletId == v) _toWalletId = null;
                        _error = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _toWalletId,
                    decoration: const InputDecoration(
                      labelText: 'To Wallet',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Colors.white),
                    items: walletOptions
                        .where((w) => w.id != _fromWalletId)
                        .map((w) {
                      return DropdownMenuItem(
                        value: w.id,
                        child: Text(
                          '${w.name} (${w.type})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _toWalletId = v;
                        _error = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                    controller: _amountController,
                    label: 'Amount',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _noteController,
                    label: 'Note (optional)',
                    hint: 'e.g. Monthly transfer',
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Transfer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/db/app_database.dart';
import '../wallet_repository.dart';

class WalletFormSheet extends ConsumerStatefulWidget {
  final Wallet? wallet;

  const WalletFormSheet({super.key, this.wallet});

  @override
  ConsumerState<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends ConsumerState<WalletFormSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController();
  late final _type = TextEditingController();
  late final _balance = TextEditingController();
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.wallet != null) {
      _name.text = widget.wallet!.name;
      _type.text = widget.wallet!.type;
      _balance.text = widget.wallet!.openingBalance.toStringAsFixed(2);
      _isActive = widget.wallet!.isActive;
    } else {
      _name.text = '';
      _type.text = 'Cash';
      _balance.text = '0.00';
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final name = _name.text.trim();
      final type = _type.text.trim();
      final balance = double.tryParse(_balance.text.trim()) ?? 0.0;

      if (widget.wallet == null) {
        await repo.createWallet(name, type, balance, _isActive);
      } else {
        await repo.updateWallet(
            widget.wallet!.id, name, type, balance, _isActive);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving wallet: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 28,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      noBlur: true,
      solid: true,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.wallet == null ? 'Add Wallet' : 'Edit Wallet',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                HapticWrapper(
                  profile: HapticProfile.light,
                  onTap: () => Navigator.of(context).pop(),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _name,
              label: 'Wallet Name',
              hint: 'e.g. Main Cash, Bank Account',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _type,
              label: 'Type',
              hint: 'e.g. Cash, Bank, Mobile Money',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _balance,
              label: 'Opening Balance',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title:
                  const Text('Active', style: TextStyle(color: Colors.white)),
              value: _isActive,
              onChanged: (v) {
                HapticService.trigger(HapticProfile.light);
                setState(() => _isActive = v);
              },
              activeColor: AppColors.accent,
            ),
            const SizedBox(height: 24),
            HapticWrapper(
              profile: HapticProfile.medium,
              onTap: _saving ? null : _save,
              child: FilledButton(
                onPressed: null,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showWalletFormSheet(
  BuildContext context, {
  Wallet? wallet,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: math.max(
              MediaQuery.of(context).viewInsets.bottom,
              MediaQuery.of(context).padding.bottom + kBottomNavHeight + 8,
            ),
          ),
          child: WalletFormSheet(wallet: wallet),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import '../wallet_repository.dart';


class WalletFormScreen extends ConsumerStatefulWidget {
  final int? walletId;

  const WalletFormScreen({super.key, this.walletId});

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  String _selectedType = 'cash';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController(text: '0.0');
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    if (widget.walletId != null) {
      final repo = ref.read(walletRepositoryProvider);
      final wallets = await repo.getWallets();
      final wallet = wallets.firstWhere((w) => w.id == widget.walletId);
      _nameController.text = wallet.name;
      _balanceController.text = wallet.openingBalance.toString();
      _selectedType = wallet.type;
      _isActive = wallet.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    final repo = ref.read(walletRepositoryProvider);

    if (widget.walletId == null) {
      await repo.createWallet(name, _selectedType, balance, _isActive);
    } else {
      await repo.updateWallet(widget.walletId!, name, _selectedType, balance, _isActive);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletTypes = ['cash', 'bank', 'bkash', 'nagad', 'rocket', 'custom'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.walletId == null ? 'Add Wallet' : 'Edit Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: GlassPanel(
            noBlur: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassTextField(
                  controller: _nameController,
                  label: 'Wallet Name',
                  validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Wallet Type',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: walletTypes.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _selectedType == type,
                      selectedColor: AppColors.accent,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: _balanceController,
                  label: 'Opening Balance',
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || double.tryParse(value) == null) ? 'Invalid balance' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Active', style: TextStyle(color: Colors.white)),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeColor: AppColors.accent,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (widget.walletId != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _confirmDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Delete Wallet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: widget.walletId != null ? 2 : 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _save,
                        child: const Text('Save Wallet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final result = await showGlassDialog<bool>(
      context: context,
      title: 'Delete Wallet',
      message: 'Are you sure you want to delete this wallet? This action cannot be undone.',
      actionsBuilder: (ctx) => [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );

    if (result == true) {
      await ref.read(walletRepositoryProvider).deleteWallet(widget.walletId!);
      if (mounted) {
        context.pop();
      }
    }
  }
}


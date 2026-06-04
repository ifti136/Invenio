import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_dialog.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/sheet_drag_handle.dart';
import '../product_repository.dart';

class RestockSheet extends ConsumerStatefulWidget {
  final int productId;
  final String productName;
  final int currentStock;

  const RestockSheet({
    super.key,
    required this.productId,
    required this.productName,
    required this.currentStock,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int productId,
    required String productName,
    required int currentStock,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => RestockSheet(
        productId: productId,
        productName: productName,
        currentStock: currentStock,
      ),
    );
  }

  @override
  ConsumerState<RestockSheet> createState() => _RestockSheetState();
}

class _RestockSheetState extends ConsumerState<RestockSheet> {
  final _qty = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final qty = int.tryParse(_qty.text.trim());
    if (qty == null || qty <= 0) {
      await showGlassDialog(
        context: context,
        title: 'Invalid quantity',
        message: 'Please enter a whole number greater than zero.',
        actions: [
          GlassDialogAction(
            label: 'OK',
            isPrimary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(productRepositoryProvider).restock(
            productId: widget.productId,
            quantity: qty,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      await showGlassDialog(
        context: context,
        title: 'Could not save',
        message: e.toString(),
        actions: [
          GlassDialogAction(
            label: 'OK',
            isPrimary: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: GlassPanel(
        radius: 28,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        margin: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Text(
              'Restock — ${widget.productName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Current stock: ${widget.currentStock}',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _qty,
              label: 'Quantity to add',
              hint: 'e.g. 10',
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            GlassTextField(
              controller: _note,
              label: 'Note (optional)',
              hint: 'Supplier, batch, etc.',
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _saving ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Add stock'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

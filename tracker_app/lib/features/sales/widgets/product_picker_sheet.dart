import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/db/app_database.dart';

Future<int?> showProductPicker(
  BuildContext context, {
  required List<Product> products,
  int? selectedId,
  bool inStockOnly = true,
}) {
  final filtered = inStockOnly
      ? products.where((p) => p.stock > 0).toList()
      : products;
  return showModalBottomSheet<int>(
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
          child: _ProductPickerSheet(
            products: filtered,
            selectedId: selectedId,
          ),
        ),
      ],
    ),
  );
}

class _ProductPickerSheet extends StatelessWidget {
  final List<Product> products;
  final int? selectedId;
  const _ProductPickerSheet({required this.products, this.selectedId});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: GlassPanel(
        radius: 28,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        noBlur: true,
        solid: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetDragHandle(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select product',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final p = products[i];
                  final selected = p.id == selectedId;
                  return ListTile(
                    title: Text(
                      p.name,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      'Stock: ${p.stock} — ${formatMoney(p.costPrice)}',
                    ),
                    dense: true,
                    trailing: selected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(p.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

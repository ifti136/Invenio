import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/app_bottom_nav.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/widgets/glass_text_field.dart';
import 'package:tracker/core/widgets/sheet_drag_handle.dart';
import 'package:tracker/features/products/product_provider.dart';

class ProductFilterSheet extends ConsumerStatefulWidget {
  final int? currentProductId;
  const ProductFilterSheet({super.key, this.currentProductId});

  static Future<int?> show(
    BuildContext context, {
    int? currentProductId,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
            child: ProductFilterSheet(currentProductId: currentProductId),
          ),
        ],
      ),
    );
  }

  @override
  ConsumerState<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends ConsumerState<ProductFilterSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(productListProvider).value ?? const [];
    final q = _query.trim().toLowerCase();
    final filtered =
        q.isEmpty ? all : all.where((p) => p.name.toLowerCase().contains(q)).toList();
    return GlassPanel(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          Text(
            'Filter by product',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          GlassTextField(
            controller: _search,
            hint: 'Search products…',
            prefixIcon: Icons.search_rounded,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return ListTile(
                    leading: const Icon(Icons.clear_rounded),
                    title: const Text('All products'),
                    selected: widget.currentProductId == null,
                    onTap: () => Navigator.of(context).pop(0),
                  );
                }
                final p = filtered[i - 1];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(p.name),
                  subtitle: Text('Stock: ${p.stock}'),
                  selected: widget.currentProductId == p.id,
                  onTap: () => Navigator.of(context).pop(p.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

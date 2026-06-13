import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/widgets/product_filter_sheet.dart';

class SaleFilterBar extends ConsumerWidget {
  final SaleFilter filter;
  final ValueChanged<SaleFilter> onFilterChanged;

  const SaleFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChipRow(
              label: 'Date',
              children: [
                for (final preset in dateRangePresets()) ...[
                  _Chip(
                    label: preset.label,
                    selected: _matchesPreset(preset),
                    onTap: () => onFilterChanged(
                        filter.copyWith(from: preset.from, to: preset.to)),
                  ),
                  const SizedBox(width: 6),
                ],
                _Chip(
                  label: 'Custom…',
                  selected: _isCustomRange(),
                  onTap: () => _pickCustomRange(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _ChipRow(
              label: 'Platform',
              children: [
                _Chip(
                  label: 'All',
                  selected: filter.platform == null,
                  onTap: () => onFilterChanged(filter.copyWith(platform: null)),
                ),
                const SizedBox(width: 6),
                for (final p in SalePlatform.values) ...[
                  _Chip(
                    label: p.label,
                    selected: filter.platform == p.key,
                    onTap: () =>
                        onFilterChanged(filter.copyWith(platform: p.key)),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 6),
            _ChipRow(
              label: 'Payment',
              children: [
                _Chip(
                  label: 'All',
                  selected: filter.paymentStatus == null,
                  onTap: () =>
                      onFilterChanged(filter.copyWith(paymentStatus: null)),
                ),
                const SizedBox(width: 6),
                for (final s in PaymentStatus.values) ...[
                  _Chip(
                    label: s.label,
                    selected: filter.paymentStatus == s.key,
                    onTap: () =>
                        onFilterChanged(filter.copyWith(paymentStatus: s.key)),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 6),
            _ChipRow(
              label: 'Product',
              children: [
                _Chip(
                  label: 'All products',
                  selected: filter.productId == null,
                  onTap: () =>
                      onFilterChanged(filter.copyWith(productId: null)),
                ),
                const SizedBox(width: 6),
                _Chip(
                  label: _productLabel(ref, filter.productId),
                  icon: Icons.tune_rounded,
                  selected: filter.productId != null,
                  onTap: () async {
                    final id = await ProductFilterSheet.show(
                      context,
                      currentProductId: filter.productId,
                    );
                    if (id == null) {
                      onFilterChanged(filter.copyWith(productId: null));
                    } else if (id == 0) {
                      onFilterChanged(filter.copyWith(productId: null));
                    } else {
                      onFilterChanged(filter.copyWith(productId: id));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _productLabel(WidgetRef ref, int? id) {
    if (id == null) return 'Pick…';
    final products = ref.read(productListProvider).value;
    final p = products?.firstWhere(
      (e) => e.id == id,
      orElse: () => Product(
        id: 0,
        name: 'Unknown',
        stock: 0,
        costPrice: 0,
        lowStockThreshold: 0,
        alertEnabled: true,
        note: null,
        createdAt: 0,
      ),
    );
    return p?.name ?? 'Product #$id';
  }

  bool _matchesPreset(DateRangePreset p) {
    if (filter.from == null) return p.label == 'All time';
    return filter.from!.year == p.from.year &&
        filter.from!.month == p.from.month &&
        filter.from!.day == p.from.day &&
        filter.to == null &&
        p.to == null;
  }

  bool _isCustomRange() {
    if (filter.from == null || filter.to == null) return false;
    return !dateRangePresets().any((p) => _matchesPreset(p));
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: filter.from != null && filter.to != null
          ? DateTimeRange(start: filter.from!, end: filter.to!)
          : null,
    );
    if (picked != null) {
      onFilterChanged(filter.copyWith(from: picked.start, to: picked.end));
    }
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _ChipRow({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: children),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        HapticService.trigger(HapticProfile.light);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withOpacity(0.18)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? scheme.primary.withOpacity(0.5)
                : scheme.onSurfaceVariant.withOpacity(0.18),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.primary : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

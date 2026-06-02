import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/core/utils/formatters.dart';
import 'package:tracker/core/widgets/empty_state.dart';
import 'package:tracker/core/widgets/glass_dialog.dart';
import 'package:tracker/core/widgets/glass_panel.dart';
import 'package:tracker/core/theme/app_colors.dart';
import 'package:tracker/db/app_database.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/products/widgets/sale_list_item.dart';
import 'package:tracker/features/sales/sale_provider.dart';
import 'package:tracker/features/sales/sale_repository.dart';
import 'package:tracker/features/sales/widgets/sale_filter_bar.dart';

class SaleListScreen extends ConsumerStatefulWidget {
  const SaleListScreen({super.key});

  @override
  ConsumerState<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends ConsumerState<SaleListScreen> {
  SaleFilter _filter = const SaleFilter();

  @override
  Widget build(BuildContext context) {
    final allSales = ref.watch(saleListProvider);
    final filteredSales = ref.watch(filteredSaleListProvider(_filter));
    final costMapAsync = ref.watch(productCostMapProvider);
    final costMap = costMapAsync.value ?? const <int, double>{};
    final scheme = Theme.of(context).colorScheme;

    final products = ref.watch(productListProvider).value ?? const [];
    final productName = {for (final p in products) p.id: p.name};

    final stats = computeSaleStats(
      filteredSales.value ?? const [],
      costMap,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            title: const Text(
              'Sales',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            actions: [
              IconButton(
                tooltip: 'Add sale',
                onPressed: () => context.push('/sales/add'),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SaleFilterBar(
              filter: _filter,
              onFilterChanged: (f) => setState(() => _filter = f),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: GlassPanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'Sales',
                        value: stats.count.toString(),
                        color: scheme.primary,
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Revenue',
                        value: formatMoney(stats.revenue),
                        color: AppColors.success,
                        small: true,
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Est. profit',
                        value: formatMoney(stats.estimatedProfit),
                        color: AppColors.accentLight == AppColors.accentLight
                            ? scheme.primary
                            : AppColors.info,
                        small: true,
                      ),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Due',
                        value: stats.dueCount.toString(),
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (filteredSales.isLoading || allSales.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if ((filteredSales.value ?? []).isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: (allSales.value ?? []).isEmpty
                    ? 'No sales yet'
                    : 'No sales match the filter',
                message: (allSales.value ?? []).isEmpty
                    ? 'Tap the + button to log your first sale.'
                    : 'Try widening the date range or removing a filter.',
              ),
            )
          else
            SliverList.separated(
              itemCount: (filteredSales.value ?? []).length,
              separatorBuilder: (_, __) => Divider(
                height: 0,
                thickness: 0.5,
                color: scheme.onSurfaceVariant.withOpacity(0.12),
                indent: 70,
              ),
              itemBuilder: (_, i) {
                final s = (filteredSales.value ?? [])[i];
                return _SaleRow(
                  sale: s,
                  productName: productName[s.productId],
                  onEdit: () => context.push('/sales/${s.id}/edit'),
                  onMarkPaid: () => _markPaid(s.id),
                  onDelete: () => _confirmDelete(s),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  Future<void> _markPaid(int id) async {
    await ref.read(saleRepositoryProvider).markAsPaid(id);
    if (!mounted) return;
    ref.invalidate(saleListProvider);
    ref.invalidate(productSalesProvider(id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as paid')),
    );
  }

  Future<void> _confirmDelete(Sale sale) async {
    final result = await showGlassDialog<bool>(
      context: context,
      title: 'Delete sale?',
      message:
          'This removes the sale and restores ${sale.quantity} unit(s) to stock. Stock movement history is kept.',
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (result != true) return;
    await ref.read(saleRepositoryProvider).deleteSale(sale.id);
    if (!mounted) return;
    ref.invalidate(saleListProvider);
    ref.invalidate(productListProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale deleted')),
    );
  }
}

class _SaleRow extends StatelessWidget {
  final Sale sale;
  final String? productName;
  final VoidCallback onEdit;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;
  const _SaleRow({
    required this.sale,
    required this.productName,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            onEdit();
            break;
          case 'paid':
            onMarkPaid();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (sale.paymentStatus != 'paid')
          const PopupMenuItem(value: 'paid', child: Text('Mark as paid')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: AppColors.danger)),
        ),
      ],
      child: SaleListItem(
        sale: sale,
        productName: productName,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool small;
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: small ? 13 : 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

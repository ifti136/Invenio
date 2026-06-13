import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/core/services/haptic_service.dart';
import 'package:tracker/core/widgets/haptic_wrapper.dart';
import 'glass_panel.dart';
import '../theme/app_colors.dart';

const double kBottomNavHeight = 76;
const double kBottomNavClearance = 100;

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  static const _tabs = [
    (
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    (
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Products',
    ),
    (
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Sales',
    ),
    (
      icon: Icons.wallet_outlined,
      selectedIcon: Icons.wallet,
      label: 'Expenses',
    ),
    (
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Reports',
    ),
  ];

  void _showQuickActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      useSafeArea: false,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            (MediaQuery.of(ctx).viewInsets.bottom > 0
                ? MediaQuery.of(ctx).viewInsets.bottom
                : kBottomNavHeight + 8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'QUICK ACTIONS',
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
                ctx, 'New Sale', Icons.add_shopping_cart, '/sales/add'),
            _buildActionTile(
                ctx, 'New Expense', Icons.money_off, '/expenses/add'),
            _buildActionTile(
                ctx, 'New Product', Icons.add_box, '/products/add'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
      BuildContext context, String label, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        noBlur: true,
        child: ListTile(
          leading: Icon(icon, color: AppColors.accent),
          title: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          trailing: Icon(Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: () {
            HapticService.trigger(HapticProfile.light);
            Navigator.of(context).pop();
            context.push(route);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = navigationShell.currentIndex;
    final products = ref.watch(productListProvider).valueOrNull ?? [];
    final lowStockCount = products
        .where(
          (p) => p.stock > 0 && p.stock <= p.lowStockThreshold,
        )
        .length;

    final destinations = [
      NavigationDestination(
        icon: Icon(_tabs[0].icon),
        selectedIcon: Icon(_tabs[0].selectedIcon),
        label: _tabs[0].label,
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: lowStockCount > 0,
          label: Text('$lowStockCount'),
          child: Icon(_tabs[1].icon),
        ),
        selectedIcon: Badge(
          isLabelVisible: lowStockCount > 0,
          label: Text('$lowStockCount'),
          child: Icon(_tabs[1].selectedIcon),
        ),
        label: _tabs[1].label,
      ),
      NavigationDestination(
        icon: Icon(_tabs[2].icon),
        selectedIcon: Icon(_tabs[2].selectedIcon),
        label: _tabs[2].label,
      ),
      NavigationDestination(
        icon: Icon(_tabs[3].icon),
        selectedIcon: Icon(_tabs[3].selectedIcon),
        label: _tabs[3].label,
      ),
      NavigationDestination(
        icon: Icon(_tabs[4].icon),
        selectedIcon: Icon(_tabs[4].selectedIcon),
        label: _tabs[4].label,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: idx == 0
          ? HapticWrapper(
              profile: HapticProfile.medium,
              child: FloatingActionButton(
                onPressed: () => _showQuickActionSheet(context),
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: SizedBox(
            height: kBottomNavHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: GlassPanel(
                radius: 22,
                isFrostedGlass: true,
                padding: EdgeInsets.zero,
                child: NavigationBar(
                  selectedIndex: idx,
                   onDestinationSelected: (i) {
                     HapticService.trigger(HapticProfile.light);
                     navigationShell.goBranch(
                       i,
                       initialLocation: i == idx,
                     );
                   },
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  destinations: destinations,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

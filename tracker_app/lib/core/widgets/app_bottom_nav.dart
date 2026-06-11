import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'glass_panel.dart';

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
    (
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Finance',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = navigationShell.currentIndex;
    final products = ref.watch(productListProvider).valueOrNull ?? [];
    final lowStockCount = products.where(
      (p) => p.stock > 0 && p.stock <= p.lowStockThreshold,
    ).length;

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
      NavigationDestination(
        icon: Icon(_tabs[5].icon),
        selectedIcon: Icon(_tabs[5].selectedIcon),
        label: _tabs[5].label,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
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
                  onDestinationSelected: (i) => navigationShell.goBranch(
                    i,
                    initialLocation: i == idx,
                  ),
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

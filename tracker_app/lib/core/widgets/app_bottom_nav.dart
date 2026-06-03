import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_panel.dart';

class AppScaffold extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: GlassPanel(
              radius: 22,
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
                destinations: _tabs.map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.selectedIcon),
                  label: t.label,
                )).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

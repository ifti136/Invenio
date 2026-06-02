import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_panel.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  static const _tabs = [
    (
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      path: '/dashboard',
    ),
    (
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Products',
      path: '/products',
    ),
    (
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Sales',
      path: '/sales',
    ),
    (
      icon: Icons.wallet_outlined,
      selectedIcon: Icons.wallet,
      label: 'Expenses',
      path: '/expenses',
    ),
    (
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Reports',
      path: '/reports',
    ),
  ];

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabIndex(context);
    return Scaffold(
      extendBody: true,
      body: child,
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
                onDestinationSelected: (i) => context.go(_tabs[i].path),
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

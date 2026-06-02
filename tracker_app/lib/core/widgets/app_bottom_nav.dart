import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.inventory_2_outlined, label: 'Products', path: '/products'),
    (icon: Icons.receipt_long_outlined, label: 'Sales', path: '/sales'),
    (icon: Icons.wallet_outlined, label: 'Expenses', path: '/expenses'),
    (icon: Icons.bar_chart_outlined, label: 'Reports', path: '/reports'),
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
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon),
          label: t.label,
        )).toList(),
      ),
    );
  }
}

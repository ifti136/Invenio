import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/inventory/inventory_providers.dart';
import '../../features/sales/sale_flow.dart';
import '../navigation/home_return.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    final location = GoRouterState.of(context).uri.path;
    final lowStock = ref.watch(lowStockCountProvider).valueOrNull ?? 0;
    final returnToHome = ref.watch(homeReturnProvider);
    final canLeave = index == 0 || !returnToHome;

    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || canLeave) return;
        ref.read(homeReturnProvider.notifier).clear();
        navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        floatingActionButton: index == 1 || (index == 0 && location == '/home')
            ? FloatingActionButton.extended(
                onPressed: () => openNewSale(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('New sale'),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          height: 64,
          selectedIndex: index,
          onDestinationSelected: (destination) {
            ref.read(homeReturnProvider.notifier).clear();
            navigationShell.goBranch(
              destination,
              initialLocation: destination == index,
            );
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Sales',
            ),
            NavigationDestination(
              icon: Badge.count(
                count: lowStock,
                isLabelVisible: lowStock > 0,
                child: const Icon(Icons.inventory_2_outlined),
              ),
              selectedIcon: Badge.count(
                count: lowStock,
                isLabelVisible: lowStock > 0,
                child: const Icon(Icons.inventory_2),
              ),
              label: 'Inventory',
            ),
            const NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Money',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}

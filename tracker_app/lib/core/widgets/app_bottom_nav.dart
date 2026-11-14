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
              icon: ImageIcon(AssetImage('assets/nav/home.png')),
              selectedIcon: ImageIcon(AssetImage('assets/nav/home_filled.png')),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: ImageIcon(AssetImage('assets/nav/sales.png')),
              selectedIcon:
                  ImageIcon(AssetImage('assets/nav/sales_filled.png')),
              label: 'Sales',
            ),
            NavigationDestination(
              icon: Badge.count(
                count: lowStock,
                isLabelVisible: lowStock > 0,
                child: const ImageIcon(AssetImage('assets/nav/inventory.png')),
              ),
              selectedIcon: Badge.count(
                count: lowStock,
                isLabelVisible: lowStock > 0,
                child: const ImageIcon(
                  AssetImage('assets/nav/inventory_filled.png'),
                ),
              ),
              label: 'Inventory',
            ),
            const NavigationDestination(
              icon: ImageIcon(AssetImage('assets/nav/money.png')),
              selectedIcon:
                  ImageIcon(AssetImage('assets/nav/money_filled.png')),
              label: 'Money',
            ),
            const NavigationDestination(
              icon: ImageIcon(AssetImage('assets/nav/reports.png')),
              selectedIcon: ImageIcon(
                AssetImage('assets/nav/reports_filled.png'),
              ),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}

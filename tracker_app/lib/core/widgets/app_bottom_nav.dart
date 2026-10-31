import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker/features/products/product_provider.dart';
import 'package:tracker/features/sales/pos_flow.dart';
import 'pos_nav_bar.dart';

export 'nav_metrics.dart';

class AppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = navigationShell.currentIndex;
    final products = ref.watch(productListProvider).valueOrNull ?? [];
    final lowStockCount = products
        .where(
          (p) =>
              p.stock > 0 && p.stock <= p.lowStockThreshold && p.alertEnabled,
        )
        .length;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: PosNavBar(
            currentIndex: idx,
            lowStockCount: lowStockCount,
            onSelect: (i) {
              navigationShell.goBranch(
                i,
                initialLocation: i == idx,
              );
            },
            onSell: () {
              startPosFlow(context, ref);
            },
          ),
        ),
      ),
    );
  }
}

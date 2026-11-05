import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/app_bottom_nav.dart';
import 'features/home/home_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/inventory/product_detail_screen.dart';
import 'features/inventory/product_form_screen.dart';
import 'features/money/money_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/sales/new_sale_screen.dart';
import 'features/sales/sales_screen.dart';
import 'features/settings/settings_accounts_screen.dart';
import 'features/settings/settings_names_screen.dart';
import 'features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                builder: (context, state) => const SalesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/money',
                builder: (context, state) => const MoneyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/sales/new',
        builder: (context, state) => const NewSaleScreen(),
      ),
      GoRoute(
        path: '/inventory/new',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/inventory/:id/edit',
        builder: (context, state) => ProductFormScreen(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/inventory/:id',
        builder: (context, state) => ProductDetailScreen(
          productId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'accounts',
            builder: (context, state) => const SettingsAccountsScreen(),
          ),
          GoRoute(
            path: 'names',
            builder: (context, state) => const SettingsNamesScreen(),
          ),
        ],
      ),
    ],
  );
});

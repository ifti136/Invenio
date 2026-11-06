import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/widgets/app_bottom_nav.dart';
import 'features/home/home_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/inventory/product_detail_screen.dart';
import 'features/inventory/product_form_screen.dart';
import 'features/money/account_ledger_screen.dart';
import 'features/money/dues_detail_screen.dart';
import 'features/money/expense_form_screen.dart';
import 'features/money/money_screen.dart';
import 'features/money/transfer_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/sales/new_sale_screen.dart';
import 'features/sales/sale_detail_screen.dart';
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
                builder: (context, state) => InventoryScreen(
                  initialFilter: state.uri.queryParameters['filter'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/money',
                builder: (context, state) => MoneyScreen(
                  initialTab: state.uri.queryParameters['tab'],
                ),
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
        path: '/sales/:id',
        builder: (context, state) => SaleDetailScreen(
          saleId: int.parse(state.pathParameters['id']!),
        ),
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
        path: '/money/transfer',
        builder: (context, state) => TransferScreen(
          fromAccountId: int.tryParse(
            state.uri.queryParameters['from'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/money/accounts/:id',
        builder: (context, state) => AccountLedgerScreen(
          accountId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/money/dues/:customerId',
        builder: (context, state) => CustomerDueScreen(
          customerId: int.parse(state.pathParameters['customerId']!),
        ),
      ),
      GoRoute(
        path: '/money/expenses/new',
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: '/money/expenses/:id/edit',
        builder: (context, state) => ExpenseFormScreen(
          expenseId: int.parse(state.pathParameters['id']!),
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

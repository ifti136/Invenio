import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/products/product_list_screen.dart';
import 'features/products/product_detail_screen.dart';
import 'features/products/product_form_screen.dart';
import 'features/sales/sale_list_screen.dart';
import 'features/sales/sale_form_screen.dart';
import 'features/expenses/expense_list_screen.dart';
import 'features/expenses/expense_form_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/finance/finance_screen.dart';
import 'features/finance/allocation_history_screen.dart';
import 'features/finance/allocation_settings_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/add_on_types_screen.dart';
import 'features/settings/currency_screen.dart';
import 'features/settings/system_settings_screen.dart';
import 'features/settings/theme_screen.dart';
import 'features/products/widgets/bucket_history_screen.dart';
import 'features/products/widgets/wallet_list_screen.dart';
import 'features/products/widgets/bucket_list_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                builder: (_, __) => const ProductListScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (_, __) => const ProductSettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'wallets',
                        builder: (_, __) => const WalletListScreen(),
                        routes: [
                          GoRoute(
                            path: 'add',
                            builder: (_, __) => const WalletFormScreen(),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            builder: (_, s) => WalletFormScreen(
                              walletId: int.parse(s.pathParameters['id']!),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'buckets',
                        builder: (_, __) => const BucketListScreen(),
                        routes: [
                          GoRoute(
                            path: 'add',
                            builder: (_, __) => const BucketFormScreen(),
                          ),
                          GoRoute(
                            path: 'edit/:id',
                            builder: (_, s) => BucketFormScreen(
                              bucketId: int.parse(s.pathParameters['id']!),
                            ),
                          ),
                          GoRoute(
                            path: 'history/:id',
                            builder: (_, s) => BucketHistoryScreen(
                              bucketId: int.parse(s.pathParameters['id']!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'add',
                    builder: (_, __) => const ProductFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, s) => ProductDetailScreen(
                      id: int.parse(s.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (_, s) => ProductFormScreen(
                          productId: int.parse(s.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                builder: (_, __) => const SaleListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (_, __) => const SaleFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (_, s) => SaleFormScreen(
                      saleId: int.parse(s.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (_, __) => const ExpenseListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (_, __) => const ExpenseFormScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (_, s) => ExpenseFormScreen(
                      expenseId: int.parse(s.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (_, __) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                builder: (_, __) => const FinanceScreen(),
                routes: [
                  GoRoute(
                    path: 'history/:ruleId',
                    builder: (_, s) => AllocationHistoryScreen(
                      ruleId: int.parse(s.pathParameters['ruleId']!),
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, __) => const AllocationSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings/theme',
        builder: (_, __) => const ThemeScreen(),
      ),
    ],
  );
}

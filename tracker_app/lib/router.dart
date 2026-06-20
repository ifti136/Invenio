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
import 'features/finance/allocation_rule_form_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/add_on_types_screen.dart';
import 'features/settings/currency_screen.dart';
import 'features/settings/system_settings_screen.dart';
import 'features/settings/theme_screen.dart';
import 'features/products/widgets/bucket_detail_screen.dart';
import 'features/products/widgets/bucket_list_screen.dart';
import 'features/products/widgets/wallet_list_screen.dart';
import 'features/transfers/transfer_history_screen.dart';
import 'core/utils/formatters.dart';
import 'core/services/currency_service.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  // Initialize currency symbol for formatMoney()
  final symbol = ref.watch(currencySymbolProvider);
  setCurrencySymbol(symbol);
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
        ],
      ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'wallets',
            builder: (_, __) => const WalletListScreen(),
            routes: [
              GoRoute(
                path: 'transfers',
                builder: (_, __) => const TransferHistoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'buckets',
            builder: (_, __) => const BucketListScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (_, s) => BucketDetailScreen(
                  bucketId: int.parse(s.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'add-ons',
            builder: (_, __) => const AddOnTypesScreen(),
          ),
           GoRoute(
             path: 'finance',
             builder: (_, __) => const FinanceScreen(),
             routes: [
               GoRoute(
                 path: 'history/:ruleId',
                 builder: (_, s) => AllocationHistoryScreen(
                   ruleId: int.parse(s.pathParameters['ruleId']!),
                 ),
               ),
               GoRoute(
                 path: 'rule/:ruleId?',
                 builder: (_, s) {
                   final id = s.pathParameters['ruleId'];
                   return AllocationRuleFormScreen(
                     ruleId: id != null ? int.parse(id) : null,
                   );
                 },
               ),
             ],
           ),
          GoRoute(
            path: 'theme',
            builder: (_, __) => const ThemeScreen(),
          ),
          GoRoute(
            path: 'currency',
            builder: (_, __) => const CurrencyScreen(),
          ),
          GoRoute(
            path: 'system',
            builder: (_, __) => const SystemSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

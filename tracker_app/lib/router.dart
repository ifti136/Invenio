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

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
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
              ),
              GoRoute(
                path: ':id/edit',
                builder: (_, s) => ProductFormScreen(
                  productId: int.parse(s.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/sales',
            builder: (_, __) => const SaleListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const SaleFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/expenses',
            builder: (_, __) => const ExpenseListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const ExpenseFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            builder: (_, __) => const ReportsScreen(),
          ),
        ],
      ),
    ],
  );
}

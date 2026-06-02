# Implementation — Inventory & Economy Tracker

This document covers the full implementation for each phase, screen by screen, function by function. Follow phases in order — each phase builds on the previous.

---

## Phase 1 — Database Tables & Providers

### 1.1 Products Table

```dart
// lib/db/tables/products_table.dart
import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  RealColumn get costPrice => real()();
  IntColumn get lowStockThreshold =>
      integer().withDefault(const Constant(3))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
}
```

### 1.2 Sales Table

```dart
// lib/db/tables/sales_table.dart
import 'package:drift/drift.dart';
import 'products_table.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId =>
      integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get sellingPrice => real()();
  RealColumn get total => real()();
  TextColumn get platform => text()();          // 'facebook' | 'offline'
  TextColumn get paymentStatus => text()();     // 'paid' | 'due'
  TextColumn get customerName => text().nullable()();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer()();
}
```

### 1.3 Expenses Table

```dart
// lib/db/tables/expenses_table.dart
import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get category => text()();  // 'ads'|'delivery'|'packaging'|'misc'
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer()();
}
```

### 1.4 Stock Movements Table

```dart
// lib/db/tables/stock_movements_table.dart
import 'package:drift/drift.dart';
import 'products_table.dart';

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId =>
      integer().references(Products, #id)();
  IntColumn get quantity => integer()(); // +in / -out
  TextColumn get type => text()();       // 'initial'|'restock'|'sale'|'adjustment'
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
}
```

---

## Phase 2 — Product Feature

### 2.1 Product Repository

```dart
// lib/features/products/product_repository.dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) =>
    ProductRepository(ref.watch(appDatabaseProvider));

class ProductRepository {
  final AppDatabase _db;
  ProductRepository(this._db);

  Stream<List<Product>> watchAll() =>
      _db.select(_db.products).watch();

  Future<Product> getById(int id) =>
      (_db.select(_db.products)
            ..where((t) => t.id.equals(id)))
          .getSingle();

  Future<int> create({
    required String name,
    required double costPrice,
    required int initialStock,
    String? note,
    int threshold = 3,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _db.into(_db.products).insert(
      ProductsCompanion.insert(
        name: name,
        costPrice: costPrice,
        stock: Value(initialStock),
        lowStockThreshold: Value(threshold),
        note: Value(note),
        createdAt: now,
      ),
    );
    // Record initial stock movement
    await _db.into(_db.stockMovements).insert(
      StockMovementsCompanion.insert(
        productId: id,
        quantity: initialStock,
        type: 'initial',
        date: now,
      ),
    );
    return id;
  }

  Future<void> restock(int id, int quantity, {String? note}) =>
      _db.transaction(() async {
        await (_db.update(_db.products)
              ..where((t) => t.id.equals(id)))
            .write(ProductsCompanion(
              stock: Value(
                (await getById(id)).stock + quantity,
              ),
            ));
        await _db.into(_db.stockMovements).insert(
          StockMovementsCompanion.insert(
            productId: id,
            quantity: quantity,
            type: 'restock',
            note: Value(note),
            date: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      });

  Future<void> update(int id, {
    String? name,
    double? costPrice,
    String? note,
    int? threshold,
  }) =>
      (_db.update(_db.products)..where((t) => t.id.equals(id)))
          .write(ProductsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        costPrice: costPrice != null
            ? Value(costPrice)
            : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        lowStockThreshold: threshold != null
            ? Value(threshold)
            : const Value.absent(),
      ));
}
```

### 2.2 Product Provider

```dart
// lib/features/products/product_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import 'product_repository.dart';

part 'product_provider.g.dart';

@riverpod
Stream<List<Product>> productList(ProductListRef ref) =>
    ref.watch(productRepositoryProvider).watchAll();

@riverpod
Future<Product> productDetail(ProductDetailRef ref, int id) =>
    ref.watch(productRepositoryProvider).getById(id);
```

### 2.3 Product List Screen

```dart
// lib/features/products/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'product_provider.dart';
import 'widgets/product_tile.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products yet. Tap + to add one.'))
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) => ProductTile(product: products[i]),
              ),
      ),
    );
  }
}
```

### 2.4 Product Tile Widget

```dart
// lib/features/products/widgets/product_tile.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../db/app_database.dart';
import '../../../core/theme/app_colors.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  Color get _stockColor {
    if (product.stock <= 0) return AppColors.danger;
    if (product.stock <= product.lowStockThreshold) return AppColors.warning;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/products/${product.id}'),
      title: Text(product.name),
      subtitle: Text('Cost: ৳${product.costPrice.toStringAsFixed(2)}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _stockColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _stockColor.withOpacity(0.4)),
        ),
        child: Text(
          '${product.stock} units',
          style: TextStyle(
            color: _stockColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
```

---

## Phase 3 — Sales Feature

### 3.1 Alert Service

```dart
// lib/services/alert_service.dart
import '../db/app_database.dart';

sealed class AppAlert {
  const AppAlert();
}

class BelowCostAlert extends AppAlert {
  final double costPrice;
  final double sellingPrice;
  const BelowCostAlert(this.costPrice, this.sellingPrice);
}

class LowStockAlert extends AppAlert {
  final int stock;
  final int threshold;
  const LowStockAlert(this.stock, this.threshold);
}

class MarginDropAlert extends AppAlert {
  final double prevMarginPct;
  final double currMarginPct;
  const MarginDropAlert(this.prevMarginPct, this.currMarginPct);
}

class AlertService {
  List<AppAlert> checkSale({
    required Sale sale,
    required Product product,
    Sale? lastSale,
  }) {
    final alerts = <AppAlert>[];

    if (sale.sellingPrice < product.costPrice) {
      alerts.add(BelowCostAlert(product.costPrice, sale.sellingPrice));
    }

    if (product.stock < product.lowStockThreshold) {
      alerts.add(LowStockAlert(product.stock, product.lowStockThreshold));
    }

    if (lastSale != null && product.costPrice > 0) {
      final prev = (lastSale.sellingPrice - product.costPrice) /
          lastSale.sellingPrice;
      final curr =
          (sale.sellingPrice - product.costPrice) / sale.sellingPrice;
      if (prev - curr > 0.10) {
        alerts.add(MarginDropAlert(prev * 100, curr * 100));
      }
    }

    return alerts;
  }
}
```

### 3.2 Sale Repository

```dart
// lib/features/sales/sale_repository.dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../../services/alert_service.dart';
import '../products/product_repository.dart';

part 'sale_repository.g.dart';

class AddSaleResult {
  final Sale sale;
  final List<AppAlert> alerts;
  const AddSaleResult(this.sale, this.alerts);
}

@riverpod
SaleRepository saleRepository(SaleRepositoryRef ref) =>
    SaleRepository(ref.watch(appDatabaseProvider),
        ref.watch(productRepositoryProvider));

class SaleRepository {
  final AppDatabase _db;
  final ProductRepository _products;
  SaleRepository(this._db, this._products);

  Stream<List<Sale>> watchAll() =>
      _db.select(_db.sales).watch();

  Future<AddSaleResult> addSale({
    required int productId,
    required int quantity,
    required double sellingPrice,
    required String platform,
    required String paymentStatus,
    String? customerName,
    DateTime? date,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final saleDate = (date ?? DateTime.now()).millisecondsSinceEpoch;
    final total = quantity * sellingPrice;

    // Fetch last sale for margin check BEFORE the transaction
    final lastSale = await (_db.select(_db.sales)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();

    late Sale created;
    late Product updatedProduct;

    await _db.transaction(() async {
      // 1. Insert sale
      final id = await _db.into(_db.sales).insert(
        SalesCompanion.insert(
          productId: productId,
          quantity: quantity,
          sellingPrice: sellingPrice,
          total: total,
          platform: platform,
          paymentStatus: paymentStatus,
          customerName: Value(customerName),
          date: saleDate,
          createdAt: now,
        ),
      );

      // 2. Decrement stock
      final product = await _products.getById(productId);
      await (_db.update(_db.products)
            ..where((t) => t.id.equals(productId)))
          .write(ProductsCompanion(
        stock: Value(product.stock - quantity),
      ));

      // 3. Record stock movement
      await _db.into(_db.stockMovements).insert(
        StockMovementsCompanion.insert(
          productId: productId,
          quantity: -quantity,
          type: 'sale',
          date: saleDate,
        ),
      );

      created = await (_db.select(_db.sales)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      updatedProduct = await _products.getById(productId);
    });

    final alerts = AlertService().checkSale(
      sale: created,
      product: updatedProduct,
      lastSale: lastSale,
    );

    return AddSaleResult(created, alerts);
  }

  Future<void> markAsPaid(int id) =>
      (_db.update(_db.sales)..where((t) => t.id.equals(id)))
          .write(const SalesCompanion(paymentStatus: Value('paid')));

  Future<void> deleteSale(int id) async {
    final sale = await (_db.select(_db.sales)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    await _db.transaction(() async {
      // Restore stock
      final product = await _products.getById(sale.productId);
      await (_db.update(_db.products)
            ..where((t) => t.id.equals(sale.productId)))
          .write(ProductsCompanion(
        stock: Value(product.stock + sale.quantity),
      ));
      await (_db.delete(_db.sales)
            ..where((t) => t.id.equals(id)))
          .go();
    });
  }
}
```

### 3.3 Sale Form Screen

```dart
// lib/features/sales/sale_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../products/product_provider.dart';
import 'sale_repository.dart';

class SaleFormScreen extends ConsumerStatefulWidget {
  const SaleFormScreen({super.key});

  @override
  ConsumerState<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends ConsumerState<SaleFormScreen> {
  int? _selectedProductId;
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  String _platform = 'facebook';
  String _paymentStatus = 'paid';
  bool _saving = false;

  double get _total {
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    return qty * price;
  }

  Future<void> _save() async {
    if (_selectedProductId == null || _priceCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      final result = await ref.read(saleRepositoryProvider).addSale(
            productId: _selectedProductId!,
            quantity: int.parse(_qtyCtrl.text),
            sellingPrice: double.parse(_priceCtrl.text),
            platform: _platform,
            paymentStatus: _paymentStatus,
          );
      if (!mounted) return;
      context.pop();
      // Show alerts
      for (final alert in result.alerts) {
        _showAlert(alert);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showAlert(AppAlert alert) {
    final msg = switch (alert) {
      BelowCostAlert(costPrice: var c, sellingPrice: var s) =>
        '⚠ Sold below cost price (Cost: ৳${c.toStringAsFixed(0)}, Sold: ৳${s.toStringAsFixed(0)})',
      LowStockAlert(stock: var s, :var threshold) =>
        '📦 Low stock — only $s units left (threshold: $threshold)',
      MarginDropAlert(prevMarginPct: var p, currMarginPct: var c) =>
        '📉 Margin dropped from ${p.toStringAsFixed(0)}% to ${c.toStringAsFixed(0)}%',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider).valueOrNull ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Log Sale')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product picker
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Product'),
            value: _selectedProductId,
            items: products
                .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.name} (${p.stock} in stock)'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedProductId = v),
          ),
          const SizedBox(height: 12),
          // Quantity
          TextFormField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          // Selling price
          TextFormField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Selling Price (৳)',
              hintText: 'Enter price',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          // Live total
          Text(
            'Total: ৳${_total.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Platform toggle
          const Text('Platform'),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            selected: {_platform},
            onSelectionChanged: (v) =>
                setState(() => _platform = v.first),
            segments: const [
              ButtonSegment(value: 'facebook', label: Text('Facebook')),
              ButtonSegment(value: 'offline', label: Text('Offline')),
            ],
          ),
          const SizedBox(height: 12),
          // Payment toggle
          const Text('Payment'),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            selected: {_paymentStatus},
            onSelectionChanged: (v) =>
                setState(() => _paymentStatus = v.first),
            segments: const [
              ButtonSegment(value: 'paid', label: Text('Paid')),
              ButtonSegment(value: 'due', label: Text('Due')),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save Sale'),
          ),
        ],
      ),
    );
  }
}
```

---

## Phase 4 — Expense Feature

### 4.1 Expense Repository

```dart
// lib/features/expenses/expense_repository.dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';

part 'expense_repository.g.dart';

@riverpod
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) =>
    ExpenseRepository(ref.watch(appDatabaseProvider));

class ExpenseRepository {
  final AppDatabase _db;
  ExpenseRepository(this._db);

  Stream<List<Expense>> watchAll() =>
      _db.select(_db.expenses).watch();

  Future<void> add({
    required double amount,
    required String category,
    String? note,
    DateTime? date,
  }) =>
      _db.into(_db.expenses).insert(ExpensesCompanion.insert(
        amount: amount,
        category: category,
        note: Value(note),
        date: (date ?? DateTime.now()).millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));

  Future<double> totalForPeriod(DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.expenses)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              t.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();
    return rows.fold(0.0, (sum, e) => sum + e.amount);
  }
}
```

---

## Phase 5 — Reports & Dashboard

### 5.1 Dashboard Provider

```dart
// lib/features/dashboard/dashboard_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../db/app_database.dart';
import '../sales/sale_repository.dart';
import '../expenses/expense_repository.dart';
import '../products/product_repository.dart';
import '../../models/dashboard_summary.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardSummary> dashboard(DashboardRef ref) async {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day)
      .millisecondsSinceEpoch;
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59)
      .millisecondsSinceEpoch;

  final todaySales = await (db.select(db.sales)
        ..where((t) =>
            t.date.isBiggerOrEqualValue(startOfDay) &
            t.date.isSmallerOrEqualValue(endOfDay)))
      .get();

  final todayExpenses = await (db.select(db.expenses)
        ..where((t) =>
            t.date.isBiggerOrEqualValue(startOfDay) &
            t.date.isSmallerOrEqualValue(endOfDay)))
      .get();

  final allProducts = await db.select(db.products).get();
  final productMap = {for (final p in allProducts) p.id: p};

  double grossProfit = 0;
  double fbProfit = 0;
  double offlineProfit = 0;
  double revenue = 0;

  for (final s in todaySales) {
    final product = productMap[s.productId];
    if (product == null) continue;
    final profit = s.sellingPrice - product.costPrice;
    grossProfit += profit * s.quantity;
    revenue += s.total;
    if (s.platform == 'facebook') {
      fbProfit += profit * s.quantity;
    } else {
      offlineProfit += profit * s.quantity;
    }
  }

  final totalExpenses =
      todayExpenses.fold(0.0, (sum, e) => sum + e.amount);

  final dueAmount = await (db.select(db.sales)
        ..where((t) => t.paymentStatus.equals('due')))
      .get()
      .then((rows) => rows.fold(0.0, (sum, s) => sum + s.total));

  final lowStock = allProducts
      .where((p) => p.stock < p.lowStockThreshold)
      .toList();

  return DashboardSummary(
    salesToday: todaySales.length,
    revenueToday: revenue,
    grossProfitToday: grossProfit,
    netProfitToday: grossProfit - totalExpenses,
    totalDue: dueAmount,
    facebookProfit: fbProfit,
    offlineProfit: offlineProfit,
    lowStockProducts: lowStock,
  );
}
```

### 5.2 Chart + Table Toggle Widget

```dart
// lib/features/reports/widgets/chart_table_toggle.dart
import 'package:flutter/material.dart';

class ChartTableToggle extends StatelessWidget {
  final bool showChart;
  final VoidCallback onToggle;
  final Widget chart;
  final Widget table;

  const ChartTableToggle({
    super.key,
    required this.showChart,
    required this.onToggle,
    required this.chart,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onToggle,
            icon: Icon(showChart ? Icons.table_chart : Icons.bar_chart),
            label: Text(showChart ? 'Show Table' : 'Show Chart'),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: showChart
              ? KeyedSubtree(key: const ValueKey('chart'), child: chart)
              : KeyedSubtree(key: const ValueKey('table'), child: table),
        ),
      ],
    );
  }
}
```

### 5.3 Monthly Bar Chart Widget

```dart
// lib/features/reports/widgets/bar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/monthly_report.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<DailySnapshot> snapshots;
  const MonthlyBarChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: snapshots.asMap().entries.map((e) {
            final snap = e.value;
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: snap.revenue,
                color: cs.surfaceVariant,
                width: 8,
              ),
              BarChartRodData(
                toY: snap.profit,
                color: cs.primary,
                width: 8,
              ),
            ]);
          }).toList(),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) => Text(
                  '${snapshots[v.toInt()].date.day}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}
```

---

## Phase 5 — Export Service

```dart
// lib/services/export_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../db/app_database.dart';

class ExportService {
  final AppDatabase _db;
  ExportService(this._db);

  Future<void> exportMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final sales = await (_db.select(_db.sales)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              t.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final expenses = await (_db.select(_db.expenses)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start.millisecondsSinceEpoch) &
              t.date.isSmallerOrEqualValue(end.millisecondsSinceEpoch)))
        .get();

    final products = await _db.select(_db.products).get();
    final productMap = {for (final p in products) p.id: p};

    final workbook = Workbook();

    // Sheet 1: Sales
    final salesSheet = workbook.worksheets[0];
    salesSheet.name = 'Sales';
    final salesHeaders = [
      'Date', 'Product', 'Qty', 'Cost Price',
      'Sell Price', 'Profit', 'Platform', 'Status'
    ];
    for (var i = 0; i < salesHeaders.length; i++) {
      salesSheet.getRangeByIndex(1, i + 1).setText(salesHeaders[i]);
    }
    for (var r = 0; r < sales.length; r++) {
      final s = sales[r];
      final p = productMap[s.productId];
      final profit = (s.sellingPrice - (p?.costPrice ?? 0)) * s.quantity;
      final row = [
        DateTime.fromMillisecondsSinceEpoch(s.date).toString().substring(0, 10),
        p?.name ?? 'Unknown',
        s.quantity.toString(),
        p?.costPrice.toStringAsFixed(2) ?? '-',
        s.sellingPrice.toStringAsFixed(2),
        profit.toStringAsFixed(2),
        s.platform,
        s.paymentStatus,
      ];
      for (var c = 0; c < row.length; c++) {
        salesSheet.getRangeByIndex(r + 2, c + 1).setText(row[c]);
      }
    }

    // Sheet 2: Expenses
    workbook.worksheets.addWithName('Expenses');
    final expSheet = workbook.worksheets[1];
    final expHeaders = ['Date', 'Category', 'Amount', 'Note'];
    for (var i = 0; i < expHeaders.length; i++) {
      expSheet.getRangeByIndex(1, i + 1).setText(expHeaders[i]);
    }
    for (var r = 0; r < expenses.length; r++) {
      final e = expenses[r];
      final row = [
        DateTime.fromMillisecondsSinceEpoch(e.date).toString().substring(0, 10),
        e.category,
        e.amount.toStringAsFixed(2),
        e.note ?? '',
      ];
      for (var c = 0; c < row.length; c++) {
        expSheet.getRangeByIndex(r + 2, c + 1).setText(row[c]);
      }
    }

    // Save and share
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await getTemporaryDirectory();
    final fileName =
        'tracker_${month.year}_${month.month.toString().padLeft(2, '0')}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Tracker export — ${month.year}/${month.month}');
  }
}
```

---

## Implementation Order Checklist

```
Phase 1 — Foundation
  ☐ Create 4 drift table files
  ☐ Wire AppDatabase + run build_runner
  ☐ Confirm DB opens on device without crash

Phase 2 — Products
  ☐ ProductRepository (create, watchAll, getById, restock, update)
  ☐ productListProvider + productDetailProvider
  ☐ ProductListScreen + ProductTile
  ☐ ProductFormScreen (add + edit)
  ☐ ProductDetailScreen (tabs: price history, sales, stock log)

Phase 3 — Sales
  ☐ AlertService (BelowCost, LowStock, MarginDrop)
  ☐ SaleRepository (addSale transaction, markAsPaid, delete)
  ☐ saleListProvider
  ☐ SaleListScreen + SaleFormScreen
  ☐ Alert display after save

Phase 4 — Expenses
  ☐ ExpenseRepository (add, watchAll, totalForPeriod)
  ☐ ExpenseListScreen + ExpenseFormScreen

Phase 5 — Reports & Export
  ☐ DashboardProvider + DashboardScreen
  ☐ ReportRepository (daily, monthly, product)
  ☐ DailyReportScreen (chart + table toggle)
  ☐ MonthlyReportScreen (BarChart + table toggle)
  ☐ ProductReportScreen (LineChart + table toggle)
  ☐ ExportService + "Export Month" button
  ☐ ChartTableToggle widget
```

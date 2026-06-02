# Code Specifications — Inventory & Economy Tracker

## 1. Coding Standards

| Rule | Standard |
|------|----------|
| Language version | Dart 3.x (sound null safety required) |
| Formatting | `dart format` — enforced via pre-commit hook |
| Linting | `flutter_lints` + custom rules in `analysis_options.yaml` |
| Naming | `lowerCamelCase` for variables/methods, `UpperCamelCase` for classes, `snake_case` for files and DB columns |
| Max file length | 300 lines — split into smaller widgets/helpers beyond this |
| Max function length | 40 lines — extract helpers beyond this |
| Comments | Required on all public classes, providers, and repository methods |

---

## 2. Dependency Specifications

```yaml
# pubspec.yaml (key dependencies only)

dependencies:
  flutter:
    sdk: flutter

  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

  # State management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Navigation
  go_router: ^13.0.0

  # Charts
  fl_chart: ^0.66.0

  # Export
  syncfusion_flutter_xlsio: ^24.0.0
  share_plus: ^7.2.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  drift_dev: ^2.14.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
```

---

## 3. Database Layer Specifications

### 3.1 drift Table Definitions

```dart
// db/tables/products_table.dart

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  RealColumn get costPrice => real()();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(3))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();   // Unix ms
}

// db/tables/sales_table.dart

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get sellingPrice => real()();
  RealColumn get total => real()();         // Stored, not computed — never changes
  TextColumn get platform => text()();      // 'facebook' | 'offline'
  TextColumn get paymentStatus => text()(); // 'paid' | 'due'
  TextColumn get customerName => text().nullable()();
  IntColumn get date => integer()();        // Unix ms — user-selected date
  IntColumn get createdAt => integer()();   // Unix ms — actual insert time
}

// db/tables/expenses_table.dart

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get category => text()();      // 'ads' | 'delivery' | 'packaging' | 'misc'
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer()();
}

// db/tables/stock_movements_table.dart

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();    // Positive = in, negative = out
  TextColumn get type => text()();          // 'initial' | 'restock' | 'sale' | 'adjustment'
  TextColumn get note => text().nullable()();
  IntColumn get date => integer()();
}
```

### 3.2 Database Class

```dart
// db/app_database.dart

@DriftDatabase(tables: [Products, Sales, Expenses, StockMovements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => await m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      // Each version bump documents its changes here
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tracker.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

### 3.3 Database Provider

```dart
// Always provide database as a singleton via Riverpod

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
```

---

## 4. Repository Specifications

Every repository follows the same contract:

- Accepts an `AppDatabase` instance (injected via Riverpod)
- Returns `Future<T>` for mutations
- Returns `Stream<T>` for watch queries (live UI updates)
- Throws typed exceptions (`ProductNotFound`, `InsufficientStock`)
- Performs multi-table mutations inside `db.transaction()`

### 4.1 ProductRepository

```dart
abstract class IProductRepository {
  Stream<List<Product>> watchAll();
  Future<Product> getById(int id);
  Future<int> create(CreateProductParams params);
  Future<void> update(int id, UpdateProductParams params);
  Future<void> restock(int id, int quantity, {String? note});
  Future<void> adjustStock(int id, int delta, String reason);
  Future<void> delete(int id);
}
```

### 4.2 SaleRepository

```dart
abstract class ISaleRepository {
  Stream<List<SaleWithProduct>> watchFiltered(SaleFilter filter);
  Future<SaleResult> addSale(AddSaleParams params);
  // SaleResult carries the created Sale + any AppAlerts triggered
  Future<void> updateSale(int id, UpdateSaleParams params);
  Future<void> markAsPaid(int id);
  Future<void> deleteSale(int id);
  Future<double?> lastSellingPriceFor(int productId);
}
```

### 4.3 ExpenseRepository

```dart
abstract class IExpenseRepository {
  Stream<List<Expense>> watchFiltered(ExpenseFilter filter);
  Future<void> addExpense(AddExpenseParams params);
  Future<void> updateExpense(int id, UpdateExpenseParams params);
  Future<void> deleteExpense(int id);
  Future<double> totalForPeriod(DateTime start, DateTime end);
}
```

### 4.4 ReportRepository

```dart
abstract class IReportRepository {
  Future<DashboardSummary> getDashboard(DateTime today);
  Future<DailyReport> getDaily(DateTime date);
  Future<MonthlyReport> getMonthly(DateTime month);
  Future<ProductReport> getProduct(int productId);
}
```

---

## 5. Model Specifications

```dart
// models/dashboard_summary.dart
class DashboardSummary {
  final int salesToday;
  final double revenuToday;
  final double grossProfitToday;
  final double netProfitToday;
  final double totalDue;
  final double facebookProfit;
  final double offlineProfit;
  final List<LowStockProduct> lowStockProducts;
}

// models/daily_report.dart
class DailyReport {
  final DateTime date;
  final List<SaleWithProduct> sales;
  final List<Expense> expenses;
  final double grossProfit;
  final double totalExpenses;
  final double netProfit;
}

// models/monthly_report.dart
class MonthlyReport {
  final DateTime month;
  final List<DailySnapshot> dailySnapshots; // For bar chart
  final double totalRevenue;
  final double grossProfit;
  final double totalExpenses;
  final double netProfit;
  final List<ProductProfitSummary> topProducts;
  final PlatformBreakdown platformBreakdown;
}

// models/product_report.dart
class ProductReport {
  final Product product;
  final int totalUnitsSold;
  final double averageSellingPrice;
  final double highestSellingPrice;
  final double lowestSellingPrice;
  final double totalProfit;
  final List<PricePoint> priceHistory; // For line chart
  final List<SaleWithProduct> allSales;
}
```

---

## 6. Screen Specifications

### 6.1 Dashboard Screen

**Widget:** `DashboardScreen` (ConsumerWidget)

**Provider:** `dashboardProvider` — watches for changes to `sales`, `expenses`, and `products` tables. Auto-refreshes when any of these change.

**Layout:**
```
AppBar: "Dashboard"  [date chip: Today]
─────────────────────────
StatRow:
  [Sales Today]  [Revenue Today]
─────────────────────────
StatRow:
  [Gross Profit]  [Net Profit]
─────────────────────────
StatCard: Total Due (unpaid)
─────────────────────────
PlatformCards:
  [Facebook ▸ profit]  [Offline ▸ profit]
─────────────────────────
LowStockSection:
  "Low Stock Alerts" header
  ProductTile (tappable → product detail)
  ProductTile
  ...
```

### 6.2 Product List Screen

**Widget:** `ProductListScreen` (ConsumerWidget)

**Provider:** `productListProvider` — streaming query.

**Layout:**
```
AppBar: "Products"  [+] FAB
SearchBar (filters live)
─────────────────────────
ListView:
  ProductTile:
    name  [stock badge]
    cost_price  |  note
  ProductTile...
─────────────────────────
Empty state if no products
```

**Stock badge colours:**
- Green: stock > threshold
- Amber: stock == threshold
- Red: stock < threshold or 0

### 6.3 Product Detail Screen

**Widget:** `ProductDetailScreen(id)` (ConsumerWidget)

**Provider:** `productDetailProvider(id)` — joins product + all sales + all stock movements.

**Layout:**
```
AppBar: product name  [edit icon]
─────────────────────────
SummaryRow: Stock | Cost Price | All-time Profit
[Restock Button]
─────────────────────────
TabBar: Price History | Sales | Stock Log
  Tab 1: LineChart of all past selling prices
  Tab 2: Sales list (same tile as SaleListScreen)
  Tab 3: StockMovement list with type badges
```

### 6.4 Sale Form Screen

**Widget:** `SaleFormScreen({Sale? existing})` (ConsumerStatefulWidget)

**Provider:** `saleFormProvider` — AsyncNotifier managing form state.

**Layout:**
```
AppBar: "Log Sale" / "Edit Sale"
─────────────────────────
ProductDropdown (searchable)
QuantityField       (numeric)
SellingPriceField   (numeric, hint: last price)
[Total: ৳ X,XXX auto-calculated]
─────────────────────────
PlatformToggle: [Facebook]  [Offline]
PaymentToggle:  [Paid]      [Due]
─────────────────────────
CustomerNameField (optional, collapsed by default)
─────────────────────────
[Save Sale] button (full width, primary)
```

After save: pop screen, show alert banner if any alerts triggered.

### 6.5 Reports Screen

**Widget:** `ReportsScreen` (tab host — ConsumerWidget)

**Layout:**
```
AppBar: "Reports"
SegmentedButton: [Daily]  [Monthly]  [Product]
─────────────────────────
Body (switches based on segment):
  DailyReportScreen
  MonthlyReportScreen
  ProductReportScreen
```

### 6.6 Daily Report Screen

**Provider:** `dailyReportProvider(date)`

**Layout:**
```
DatePicker row (← Today →)
─────────────────────────
SummaryRow: Gross Profit | Expenses | Net Profit
─────────────────────────
[Chart ⇄ Table] toggle
  Chart: simple revenue/profit/expense stat bars
  Table: Sales rows + Expenses rows with totals
```

### 6.7 Monthly Report Screen

**Provider:** `monthlyReportProvider(month)`

**Layout:**
```
MonthPicker row (← Month →)
─────────────────────────
SummaryRow: Revenue | Gross | Net
PlatformRow: Facebook | Offline
─────────────────────────
[Chart ⇄ Table] toggle
  Chart: BarChart — revenue (grey) vs profit (accent) per day
  Table: Per-day rows with revenue + profit columns + totals row
─────────────────────────
TopProductsSection (always shown, no toggle)
[Export Month] button
```

### 6.8 Product Report Screen

**Provider:** `productReportProvider(productId)`

**Layout:**
```
ProductDropdown (select product)
─────────────────────────
StatRow: Units Sold | Avg Price | Total Profit
StatRow: Highest Sale | Lowest Sale
─────────────────────────
[Chart ⇄ Table] toggle
  Chart: LineChart — selling price over time
  Table: All sales for this product (date, qty, price, profit, platform)
```

---

## 7. Alert Specifications

`AppAlert` is a sealed class:

```dart
sealed class AppAlert {}
class BelowCostAlert extends AppAlert {
  final double costPrice;
  final double sellingPrice;
}
class LowStockAlert extends AppAlert {
  final int currentStock;
  final int threshold;
}
class MarginDropAlert extends AppAlert {
  final double previousMarginPct;
  final double currentMarginPct;
}
```

Alerts are shown as `SnackBar` with amber background for warnings. BelowCost additionally shows a `showDialog` confirmation step asking: *"Are you sure you want to save this sale?"*

---

## 8. Form Validation Rules

| Field | Rule |
|-------|------|
| Product | Must be selected |
| Quantity | Integer ≥ 1; cannot exceed current stock (warning, not block) |
| Selling price | Real > 0 |
| Amount (expense) | Real > 0 |
| Product name | Non-empty, max 200 chars |
| Cost price | Real > 0 |
| Initial stock | Integer ≥ 0 |

Quantity exceeding stock shows a warning dialog: *"Stock is X. You are selling Y. Continue?"* — does not block the save.

---

## 9. Theme Specifications

```dart
// core/theme/app_colors.dart

class AppColors {
  // Accent — used for profit, primary actions
  static const accent = Color(0xFF1D9E75);        // Teal 400
  static const accentLight = Color(0xFFE1F5EE);   // Teal 50

  // Warning
  static const warning = Color(0xFFEF9F27);       // Amber 400
  static const warningLight = Color(0xFFFAEEDA);  // Amber 50

  // Danger
  static const danger = Color(0xFFE24B4A);        // Red 400
  static const dangerLight = Color(0xFFFCEBEB);   // Red 50

  // Stock badges
  static const stockGood = Color(0xFF1D9E75);
  static const stockWarn = Color(0xFFEF9F27);
  static const stockLow  = Color(0xFFE24B4A);

  // Platforms
  static const facebook = Color(0xFF1877F2);
  static const offline  = Color(0xFF534AB7);      // Purple 600
}
```

---

## 10. Testing Strategy

| Type | Scope | Tool |
|------|-------|------|
| Unit tests | Repository logic, alert logic, profit calculations | `flutter_test` + `mockito` |
| Widget tests | Form validation, stat cards, chart/table toggle | `flutter_test` |
| Integration tests | Add sale flow end-to-end, export | `integration_test` |

Priority order: Profit calculation functions > AlertService > SaleRepository transaction > UI form validation.

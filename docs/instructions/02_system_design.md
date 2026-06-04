# System Design — Inventory & Economy Tracker

## 1. Architecture Overview

The app follows a layered, offline-first architecture. Data flows in one direction: UI → Provider → Repository → Database. There is no network layer in Phase 1.

```
┌─────────────────────────────────┐
│           UI Layer              │  Screens, Widgets, Dialogs
├─────────────────────────────────┤
│        State Layer              │  Riverpod Providers
├─────────────────────────────────┤
│      Repository Layer           │  Business logic, query composition
├─────────────────────────────────┤
│       Data Layer                │  drift (typed SQLite)
└─────────────────────────────────┘
        │
        ▼ (Phase 2 only)
┌─────────────────────────────────┐
│     Sync Layer (future)         │  Supabase client, background isolate
└─────────────────────────────────┘
```

---

## 2. Technology Choices

| Layer | Choice | Reason |
|-------|--------|--------|
| UI framework | Flutter 3.x | Cross-platform, single codebase for Android + iOS later |
| Language | Dart | Required by Flutter |
| Database | drift (SQLite) | Type-safe queries, migrations, streams |
| State management | flutter_riverpod | Reactive, testable, no boilerplate |
| Navigation | go_router | Deep links, declarative routes |
| Charts | fl_chart | Best-in-class Flutter charting, offline |
| Export | syncfusion_flutter_xlsio | Excel generation without native dependencies |
| Cloud (Phase 2) | Supabase | Postgres + realtime, easy Flutter SDK |

---

## 3. Database Schema

### 3.1 Table: `products`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | INTEGER | PK, autoincrement | |
| name | TEXT | NOT NULL | Product display name |
| stock | INTEGER | NOT NULL, DEFAULT 0 | Current stock count |
| cost_price | REAL | NOT NULL | Latest cost price |
| low_stock_threshold | INTEGER | NOT NULL, DEFAULT 3 | Alert trigger |
| note | TEXT | NULLABLE | Colour, variant, model |
| created_at | INTEGER | NOT NULL | Unix timestamp ms |

### 3.2 Table: `sales`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | INTEGER | PK, autoincrement | |
| product_id | INTEGER | FK → products.id | |
| quantity | INTEGER | NOT NULL | Units sold |
| selling_price | REAL | NOT NULL | Price per unit |
| total | REAL | NOT NULL | quantity × selling_price |
| platform | TEXT | NOT NULL | 'facebook' \| 'offline' |
| payment_status | TEXT | NOT NULL | 'paid' \| 'due' |
| customer_name | TEXT | NULLABLE | |
| date | INTEGER | NOT NULL | Unix timestamp ms |
| created_at | INTEGER | NOT NULL | Unix timestamp ms |

### 3.3 Table: `expenses`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | INTEGER | PK, autoincrement | |
| amount | REAL | NOT NULL | |
| category | TEXT | NOT NULL | 'ads' \| 'delivery' \| 'packaging' \| 'misc' |
| note | TEXT | NULLABLE | |
| date | INTEGER | NOT NULL | Unix timestamp ms |
| created_at | INTEGER | NOT NULL | Unix timestamp ms |

### 3.4 Table: `stock_movements`

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | INTEGER | PK, autoincrement | |
| product_id | INTEGER | FK → products.id | |
| quantity | INTEGER | NOT NULL | Positive = in, negative = out |
| type | TEXT | NOT NULL | 'initial' \| 'restock' \| 'sale' \| 'adjustment' |
| note | TEXT | NULLABLE | Reason for adjustment |
| date | INTEGER | NOT NULL | Unix timestamp ms |

### 3.5 Entity Relationship

```
products ──< sales           (one product, many sales)
products ──< stock_movements (one product, many movements)
```

---

## 4. State Management Design

Each feature domain owns a set of Riverpod providers. Providers are scoped to the minimum state they need.

### 4.1 Provider Taxonomy

```
productListProvider          → AsyncNotifier<List<Product>>
productDetailProvider(id)    → AsyncNotifier<ProductDetail>
saleListProvider(filter)     → AsyncNotifier<List<Sale>>
expenseListProvider(filter)  → AsyncNotifier<List<Expense>>
dashboardProvider            → AsyncNotifier<DashboardSummary>
reportDailyProvider(date)    → AsyncNotifier<DailyReport>
reportMonthlyProvider(month) → AsyncNotifier<MonthlyReport>
reportProductProvider(id)    → AsyncNotifier<ProductReport>
```

### 4.2 Data Flow: Add Sale

```
User taps Save
  │
  ▼
SaleFormNotifier.submit()
  │
  ▼
SaleRepository.addSale(params)        ← validates selling_price >= 0
  │
  ├── db.transaction():
  │     INSERT INTO sales
  │     UPDATE products SET stock = stock - quantity
  │     INSERT INTO stock_movements (type: 'sale')
  │
  ├── AlertService.checkSale(sale, product)
  │     → below cost alert?
  │     → low stock alert?
  │     → margin drop alert?
  │
  └── Invalidate: saleListProvider, productListProvider, dashboardProvider
```

---

## 5. Navigation Structure

```
/ (root)
├── /dashboard           ← BottomNav tab 0 (home)
├── /products            ← BottomNav tab 1
│   ├── /products/add
│   └── /products/:id
│       └── /products/:id/restock
├── /sales               ← BottomNav tab 2
│   ├── /sales/add
│   └── /sales/:id/edit
├── /expenses            ← BottomNav tab 3
│   ├── /expenses/add
│   └── /expenses/:id/edit
└── /reports             ← BottomNav tab 4
    ├── /reports/daily
    ├── /reports/monthly
    └── /reports/product
```

go_router's `ShellRoute` wraps tabs 0–4 so the bottom navigation bar persists across all tab screens.

---

## 6. File & Folder Structure

```
lib/
├── main.dart
├── app.dart                    ← MaterialApp + theme
├── router.dart                 ← go_router configuration
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   └── date_formatter.dart
│   └── widgets/
│       ├── app_bottom_nav.dart
│       ├── stat_card.dart
│       ├── alert_banner.dart
│       └── empty_state.dart
│
├── db/
│   ├── app_database.dart       ← drift database class
│   ├── tables/
│   │   ├── products_table.dart
│   │   ├── sales_table.dart
│   │   ├── expenses_table.dart
│   │   └── stock_movements_table.dart
│   └── app_database.g.dart     ← generated
│
├── features/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── dashboard_provider.dart
│   │   └── widgets/
│   │       ├── summary_row.dart
│   │       ├── platform_cards.dart
│   │       └── low_stock_banner.dart
│   │
│   ├── products/
│   │   ├── product_list_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── product_form_screen.dart
│   │   ├── restock_sheet.dart
│   │   ├── product_provider.dart
│   │   ├── product_repository.dart
│   │   └── widgets/
│   │       ├── product_tile.dart
│   │       ├── stock_badge.dart
│   │       └── price_history_chart.dart
│   │
│   ├── sales/
│   │   ├── sale_list_screen.dart
│   │   ├── sale_form_screen.dart
│   │   ├── sale_provider.dart
│   │   ├── sale_repository.dart
│   │   └── widgets/
│   │       ├── sale_tile.dart
│   │       ├── platform_chip.dart
│   │       └── payment_chip.dart
│   │
│   ├── expenses/
│   │   ├── expense_list_screen.dart
│   │   ├── expense_form_screen.dart
│   │   ├── expense_provider.dart
│   │   ├── expense_repository.dart
│   │   └── widgets/
│   │       └── expense_tile.dart
│   │
│   └── reports/
│       ├── reports_screen.dart         ← tab host
│       ├── daily_report_screen.dart
│       ├── monthly_report_screen.dart
│       ├── product_report_screen.dart
│       ├── report_provider.dart
│       └── widgets/
│           ├── chart_table_toggle.dart
│           ├── bar_chart_widget.dart
│           ├── line_chart_widget.dart
│           └── report_table.dart
│
├── services/
│   ├── alert_service.dart
│   └── export_service.dart
│
└── models/
    ├── dashboard_summary.dart
    ├── daily_report.dart
    ├── monthly_report.dart
    └── product_report.dart
```

---

## 7. Profit Calculation Logic

All profit calculations live in `SaleRepository` and `ReportRepository`. They are pure functions with no side effects.

```
grossProfitPerSale(sale, product):
  return sale.selling_price - product.cost_price

grossProfitPeriod(sales, products):
  return sales.map(s => grossProfitPerSale(s, productFor(s))).sum()

netProfitPeriod(sales, products, expenses):
  return grossProfitPeriod(sales, products) - expenses.map(e => e.amount).sum()

platformBreakdown(sales, products):
  facebook = sales.filter(platform == 'facebook')
  offline  = sales.filter(platform == 'offline')
  return {
    facebook: grossProfitPeriod(facebook, products),
    offline:  grossProfitPeriod(offline, products)
  }
```

---

## 8. Alert Logic

`AlertService.checkSale(Sale sale, Product product)` runs after every successful sale insert and returns a list of `AppAlert` objects. The UI layer converts these to `SnackBar` or `AlertDialog`.

```
checkSale(sale, product) → List<AppAlert>:
  alerts = []

  if sale.selling_price < product.cost_price:
    alerts.add(Alert.belowCost)

  if product.stock < product.low_stock_threshold:
    alerts.add(Alert.lowStock(product.stock))

  lastSale = lastSaleFor(product.id)
  if lastSale != null:
    prevMargin = (lastSale.selling_price - product.cost_price) / lastSale.selling_price
    currMargin = (sale.selling_price - product.cost_price) / sale.selling_price
    if prevMargin - currMargin > 0.10:
      alerts.add(Alert.marginDrop)

  return alerts
```

---

## 9. Export Design

`ExportService.exportMonth(DateTime month)` runs in a background isolate to avoid blocking the UI.

Output: `tracker_YYYY_MM.xlsx` with three sheets:

| Sheet | Columns |
|-------|---------|
| Sales | Date, Product, Qty, Cost Price, Sell Price, Profit, Platform, Status, Customer |
| Expenses | Date, Category, Amount, Note |
| Summary | Gross Profit, Total Expenses, Net Profit, Facebook Profit, Offline Profit, Top 5 Products |

File is written to the app's temporary directory, then shared via `share_plus`.

---

## 10. Phase 2 — Cloud Sync Design

Each table gains two columns: `synced_at INTEGER NULLABLE` and `server_id TEXT NULLABLE`.

A `SyncService` runs on app foreground (when internet is available):
1. Query all rows where `synced_at IS NULL`.
2. Upsert to Supabase using `server_id` as the conflict key.
3. On success, update `synced_at` locally.

Conflicts: last-write-wins based on `created_at`. No merge strategy is needed for a solo user.

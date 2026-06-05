# System Design — Inventory & Economy Tracker

> **Status:** As-shipped at v1.0.0+2 (post-Phase 7.0), schema v2.
> This is the detailed AI-agent-facing spec. For a human-readable
> overview of the same architecture (key decisions, trade-offs,
> folder map), see [`../ARCHITECTURE.md`](../ARCHITECTURE.md).
> For "what was built and when", see [`../CHANGELOG.md`](../CHANGELOG.md).

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
| UI framework | Flutter 3.24.4 | Cross-platform, single codebase for Android (iOS not targeted in v1) |
| Language | Dart 3.5.4 | Required by Flutter |
| Database | drift (SQLite) | Type-safe queries, migrations, reactive streams |
| State management | flutter_riverpod + riverpod_annotation + riverpod_generator | Compile-time DI, family providers, `AutoDispose` by default |
| Navigation | go_router 15.1.2 with `StatefulShellRoute.indexedStack` | Declarative routes, persistent tab state across bottom-nav switches |
| Charts | fl_chart 0.69 | Best-in-class Flutter charting, offline |
| Export | syncfusion_flutter_xlsio 27.1.55 | Excel generation without native dependencies |
| Theme | glass_kit 4.0.2 + aurora_background 1.0.2 | Liquid Glass UI (panels, animated aurora backdrop) |
| Icons | flutter_launcher_icons 0.14.4 | Custom launcher icon + adaptive icon (Phase 7.0) |
| Cloud | Not in v1 | Drift is the source of truth; cloud sync deferred indefinitely (see `ARCHITECTURE.md`) |

---

## 3. Database Schema

### 3.1 Table: `products` (schema v2)

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | INTEGER | PK, autoincrement | |
| name | TEXT | NOT NULL | Product display name |
| stock | INTEGER | NOT NULL, DEFAULT 0 | Current stock count |
| cost_price | REAL | NOT NULL | Latest cost price |
| low_stock_threshold | INTEGER | NOT NULL, DEFAULT 3 | Alert trigger |
| note | TEXT | NULLABLE | Colour, variant, model |
| alert_enabled | BOOLEAN | NOT NULL, DEFAULT 1 | *(added in schema v2, Phase 2)* — suppresses low-stock banners for this product when off |
| created_at | INTEGER | NOT NULL | Unix timestamp ms |

### 3.2 Table: `sales` (schema v2)

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| id | INTEGER | PK, autoincrement | |
| product_id | INTEGER | FK → products.id | |
| quantity | INTEGER | NOT NULL | Units sold |
| selling_price | REAL | NOT NULL | Price per unit (the price the user actually sold at) |
| total | REAL | NOT NULL | quantity × selling_price |
| platform | TEXT | NOT NULL | 'facebook' \| 'offline' |
| payment_status | TEXT | NOT NULL | 'paid' \| 'due' |
| customer_name | TEXT | NULLABLE | |
| is_discounted | BOOLEAN | NOT NULL, DEFAULT 0 | *(added in schema v2, Phase 2)* — true for sales logged via the discount sheet |
| normal_price | REAL | NULLABLE | *(added in schema v2, Phase 2)* — the pre-discount price, for discounted sales only |
| date | INTEGER | NOT NULL | Unix timestamp ms (user-selected date) |
| created_at | INTEGER | NOT NULL | Unix timestamp ms (insert time) |

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
│       ├── /products/:id/edit
│       └── /products/:id/restock
├── /sales               ← BottomNav tab 2
│   ├── /sales/add
│   └── /sales/:id/edit
├── /expenses            ← BottomNav tab 3
│   ├── /expenses/add
│   └── /expenses/:id/edit
└── /reports             ← BottomNav tab 4 (no nested routes — segmented control inside the screen)
```

`StatefulShellRoute.indexedStack` wraps the 5 tabs so the bottom
navigation bar persists AND each tab's branch is kept mounted when
the user switches tabs (preserves scroll position, keeps Riverpod
stream providers alive). This replaced the original `ShellRoute` in
Phase 5/6 when go_router 15 was adopted.

---

## 6. File & Folder Structure

The actual `lib/` tree as of v1.0.0+2:

```
lib/
├── main.dart                       ← entry point; wraps in ProviderScope
├── app.dart                        ← MaterialApp.router + aurora backdrop
├── router.dart                     ← go_router + StatefulShellRoute.indexedStack
│
├── core/
│   ├── background/
│   │   └── aurora_backdrop.dart    ← AuroraBackdrop widget (Liquid Glass)
│   ├── theme/
│   │   ├── app_theme.dart          ← Material 3 light/dark; transparent scaffold
│   │   └── app_colors.dart         ← design tokens (accent, stock, platform)
│   ├── widgets/
│   │   ├── app_bottom_nav.dart     ← floating glass nav; exports kBottomNavHeight / kBottomNavClearance
│   │   ├── glass_panel.dart        ← GlassPanel + GlassPanel.flush; noBlur + solid flags
│   │   ├── glass_text_field.dart   ← TextFormField-backed; validator, inputFormatters
│   │   ├── glass_dialog.dart       ← showGlassDialog<T>() + actionsBuilder(ctx)
│   │   ├── sheet_drag_handle.dart  ← shared 40×4 pill for all bottom sheets
│   │   ├── stat_card.dart
│   │   └── empty_state.dart
│   ├── utils/
│   │   └── formatters.dart         ← money / date / date-time / day / quantity
│   └── extensions/
│       └── db_extensions.dart      ← drift row → DateTime helpers
│
├── db/
│   ├── app_database.dart           ← drift database; schema v2
│   ├── app_database.g.dart         ← generated
│   └── tables/
│       ├── products_table.dart     ← includes alertEnabled (schema v2)
│       ├── sales_table.dart        ← includes isDiscounted + normalPrice (schema v2)
│       ├── expenses_table.dart
│       └── stock_movements_table.dart
│
├── features/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── dashboard_provider.dart
│   │   └── dashboard_provider.g.dart
│   │
│   ├── products/
│   │   ├── product_list_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── product_form_screen.dart
│   │   ├── product_provider.dart
│   │   ├── product_provider.g.dart
│   │   ├── product_repository.dart
│   │   ├── product_repository.g.dart
│   │   └── widgets/
│   │       ├── product_tile.dart
│   │       ├── stock_badge.dart
│   │       ├── restock_sheet.dart
│   │       ├── stock_movement_item.dart
│   │       └── sale_list_item.dart
│   │
│   ├── sales/
│   │   ├── sale_list_screen.dart
│   │   ├── sale_form_screen.dart
│   │   ├── sale_provider.dart
│   │   ├── sale_provider.g.dart
│   │   ├── sale_repository.dart
│   │   ├── sale_repository.g.dart
│   │   └── widgets/
│   │       ├── sale_filter_bar.dart
│   │       ├── product_filter_sheet.dart
│   │       ├── product_picker_sheet.dart   ← shared picker (Phase 6.8)
│   │       ├── quick_sell_sheet.dart
│   │       └── discount_sheet.dart
│   │
│   ├── expenses/
│   │   ├── expense_list_screen.dart
│   │   ├── expense_form_screen.dart
│   │   ├── expense_provider.dart
│   │   ├── expense_provider.g.dart
│   │   ├── expense_repository.dart
│   │   └── expense_repository.g.dart
│   │
│   └── reports/
│       ├── reports_screen.dart              ← single screen with 3-tab segmented control
│       ├── report_repository.dart
│       ├── report_repository.g.dart
│       └── widgets/
│           ├── bar_chart_widget.dart        ← fl_chart
│           └── chart_table_toggle.dart      ← AnimatedSwitcher
│
├── models/
│   ├── dashboard_summary.dart               ← DashboardSummary
│   └── monthly_report.dart                  ← DailySnapshot / MonthlySummary / ProductReportRow
│
└── services/
    ├── alert_service.dart                   ← sealed AppAlert: BelowCost / LowStock / MarginDrop
    ├── alert_service.g.dart
    └── export_service.dart                  ← syncfusion_xlsio + share_plus
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

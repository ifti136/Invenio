# Requirements — Inventory & Economy Tracker

> **Status:** As-shipped at v1.0.0+2 (post-Phase 7.0).
> The functional + non-functional requirements below describe the
> product as it exists in the codebase. The original baseline (FR-P01
> through FR-X03) was the Phase 0 spec; FR-P08, FR-P09, FR-S08,
> FR-D04, and FR-D05 were added in Phases 1.5–2.4 as the
> product evolved. For "what was added when", see
> [`../CHANGELOG.md`](../CHANGELOG.md).

## 1. Overview

A solo-use Android mobile application built with Flutter that enables a small reseller to manage product inventory, log every sale, track business expenses, and view profit analytics — all without internet access. Cloud sync is deferred to a future phase.

---

## 2. Users & Context

| Attribute | Detail |
|-----------|--------|
| Primary user | Single owner-operator (no login, no accounts) |
| Device | Android phone (API 24 / Android 7.0 minimum) |
| Connectivity | Fully offline; cloud sync added in Phase 2 |
| Scale | Tens of products, dozens of sales per week |
| Platforms sold on | Facebook Marketplace, Offline / in-person |

---

## 3. Functional Requirements

### 3.1 Product Master

- **FR-P01** — User can create a product with: name, cost price, initial stock quantity, optional note (variant/colour/model).
- **FR-P02** — User can edit a product's name, cost price, and note at any time.
- **FR-P03** — When cost price is updated, the app prompts: *"Apply to future sales only"* or *"Recalculate all historical profit"*.
- **FR-P04** — User can restock a product by entering a quantity; stock increases and a stock movement record is written.
- **FR-P05** — Each product has a configurable low-stock threshold (default: 3 units).
- **FR-P06** — Product detail screen shows: current stock, cost price, all-time profit, full price history, and all linked sales.
- **FR-P07** — No fixed selling price is stored on the product. Selling price is always entered at point of sale.
- **FR-P08** — *(added Phase 2)* Each product has a per-product `alertEnabled` toggle (default `true`) that suppresses low-stock banners and badges for that product when off. The visual stock badge (green / amber / red) is unaffected — only the banner / pop-up is suppressed.
- **FR-P09** — *(added Phase 2)* On app open, the dashboard shows a single consolidated banner listing every product with `stock ≤ threshold AND alertEnabled = true`. Tapping the banner navigates to the Products tab. The banner shows at most once per session.

### 3.2 Sales Log

- **FR-S01** — User logs a sale by selecting: product, quantity, selling price, platform (Facebook / Offline), payment status (Paid / Due), and optional customer name.
- **FR-S02** — Sale total (quantity × selling price) is auto-calculated and displayed live before saving.
- **FR-S03** — The selling price input field hints the last price used for that product.
- **FR-S04** — On save, three atomic writes occur: insert sale record, decrement product stock, insert stock movement record.
- **FR-S05** — User can edit or delete any past sale (with confirmation dialog on delete).
- **FR-S06** — Sales list is filterable by: date range (today / this week / custom), platform, payment status, and product.
- **FR-S07** — Marking a "Due" sale as "Paid" updates the payment_status field without creating a new sale.
- **FR-S08** — *(added Phase 2)* Discounted sales are supported with two extra fields on the `Sales` row: `isDiscounted: bool` (default `false`) and `normalPrice: real?` (the pre-discount price). The discount sheet captures both, and reports show margin loss per discounted sale. The Sales tab exposes a "Log discounted sale" entry point and a list of the most recent discounted sales.

### 3.3 Stock Management

- **FR-T01** — Stock is managed manually; there is no automated sync or external integration.
- **FR-T02** — Every stock change (initial, restock, sale, manual adjustment) writes a stock_movements record.
- **FR-T03** — User can make a manual stock adjustment (correction) from the product detail screen with an optional reason note.
- **FR-T04** — Stock movement history is viewable per product in chronological order.

### 3.4 Expense Tracker

- **FR-E01** — User logs an expense with: amount, category (Ads / Delivery / Packaging / Misc), date, optional note.
- **FR-E02** — Expense list shows monthly total at the top, filterable by category and date range.
- **FR-E03** — Expenses feed into the net profit calculation in all report views.

### 3.5 Profit & Reports

- **FR-R01** — Gross profit per sale = selling_price − cost_price (at the time of sale).
- **FR-R02** — Net profit = gross profit − total expenses (for the same period).
- **FR-R03** — Daily view: all sales and expenses for a selected date, gross profit, net profit.
- **FR-R04** — Monthly view: bar chart (revenue vs profit per day) + summary table with totals; toggle between chart and table.
- **FR-R05** — Product view: units sold, average selling price, highest/lowest sale price, price history line chart, all-time profit; toggle between chart and table.
- **FR-R06** — Platform breakdown: Facebook vs Offline profit side-by-side, filterable by date range.

### 3.6 Dashboard

- **FR-D01** — Home tab always shows: sales count today, revenue today, profit today (gross + net), total amount due (unpaid sales), low-stock alerts.
- **FR-D02** — Low-stock alert items are tappable and navigate directly to the product detail screen.
- **FR-D03** — Quick platform split cards (Facebook profit / Offline profit) visible on the dashboard.
- **FR-D04** — *(added Phase 2)* The Products tab icon shows a `Badge` with the count of low-stock products (`stock ≤ threshold AND alertEnabled = true`). The badge updates reactively as sales / restocks change the count.
- **FR-D05** — *(added Phase 2)* The Sales tab shows a "Recent Sales" section with the most recent non-discounted sales, so the user can see and edit / delete them without navigating to a separate history screen.

### 3.7 Reality Check Alerts

- **FR-A01** — Alert shown immediately after saving a sale if selling price < cost price: *"⚠ Sold below cost price."*
- **FR-A02** — Alert shown if stock for that product drops below its threshold after the sale.
- **FR-A03** — Alert shown if the profit margin dropped more than 10 percentage points compared to the last sale of the same product.

### 3.8 Export

- **FR-X01** — User can export the current month's data as an Excel (.xlsx) file with three sheets: Sales Detail, Expenses Detail, Summary.
- **FR-X02** — Export is shared via the Android system share sheet (WhatsApp, Google Drive, email, etc.).
- **FR-X03** — Summary sheet includes: gross profit, net profit, platform split, top 5 products by profit.

---

## 4. Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | All primary actions (log sale, add product, add expense) complete in under 200 ms on a mid-range Android device |
| NFR-02 | App is fully functional with zero internet connectivity |
| NFR-03 | Data is persisted locally in a SQLite database via drift |
| NFR-04 | Database supports schema migrations without data loss when the app is updated |
| NFR-05 | Minimum supported Android version: API 24 (Android 7.0) |
| NFR-06 | App supports both light and dark mode |
| NFR-07 | No user account, no login screen, no authentication required in Phase 1 |
| NFR-08 | All currency values stored and calculated as real (double) with 2 decimal display |

---

## 5. Out of Scope (Phase 1)

- Cloud backup or sync
- Multi-user access or roles
- Barcode / QR code scanning
- Push notifications
- Customer management CRM
- Invoice generation
- Integration with any external platform (Facebook, Shopify, etc.)
- Multiple currency support

---

## 6. Phase 2 — Cloud Upgrade Path

When ready, Supabase will be added as a mirror. Every table gains a `synced_at` column. A background job pushes unsynced rows. The local SQLite database remains the source of truth. No login is required in the initial cloud upgrade unless multi-device access is desired.

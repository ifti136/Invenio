# DESIGN.md — Invenio Visual & Structural Design Specification

**Version:** 2.1 (Updated with Usability & Accessibility Improvements)  
**Last updated:** 2026-06-13  
**Status:** Authoritative. Supersedes any prior `DESIGN.md` in `docs/`.  
**Scope:** All six tabs, the Settings overlay, the Add-Ons system, the Theme system, and global usability standards.

---

## 0. How to Read This Document

This file is the single source of truth for every UI decision in Invenio. Before touching any screen, an agent must read the relevant section. Sections are:

1. Global Design Language — colours, type, surfaces, motion, haptics
2. Navigation & Shell — tab bar, shell behaviour, quick actions
3. Dashboard Tab
4. Products Tab
5. Sales Tab (includes Add-Ons system)
6. Expenses Tab
7. Reports Tab
8. Settings Overlay (replaces Finance tab; absorbs Finance/Wallets/Buckets/Theme)
9. Add-Ons System — data model, UI contract
10. Theme System — light/dark/custom themes
11. Component Library — reusable widget contracts
12. Data Model Summary
13. Implementation Priority Order
14. Reference: Dashboard Screenshot

Read §1 and §2 before any feature. Read the feature section before coding. Read §11 if building a widget that appears in more than one screen.

---

## 1. Global Design Language

### 1.1 Visual Identity

Invenio is a **solo-operator business tool** for a reseller. The aesthetic is **"liquid glass over deep space"**: frosted glass panels float above an animated aurora that shifts through teal, indigo, and magenta. Every surface is translucent — the aurora bleeds through everything. The palette is purposefully dark so figures, green profits, and red alerts pop with no competition.

The **signature element** is the aurora backdrop. It is always on (unless the Solid Slate theme is selected). Every screen inherits it via the transparent `Scaffold`. 

### 1.2 Colour Tokens

All colour references in code and specs use these token names. Never hardcode hex outside `app_colors.dart`.

| Token | Hex | Usage |
|---|---|---|
| `accent` | `#1D9E75` | Primary action, active nav, positive values |
| `accentLight` | `#E1F5EE` | Tinted chip backgrounds (light mode only) |
| `warning` | `#EF9F27` | Low-stock badge, expense amounts, caution |
| `warningLight` | `#FAEEDA` | Warning chip background |
| `danger` | `#E24B4A` | Negative profit, overdue, destructive actions |
| `dangerLight` | `#FCEBEB` | Danger chip background |
| `success` | `#1D9E75` | (alias of `accent`) Positive profit, paid status |
| `info` | `#4F8AF0` | Estimated profit in sale preview |
| `facebook` | `#1877F2` | Facebook platform indicator |
| `offline` | `#534AB7` | Offline platform indicator |
| `auroraBg1` | `#0B1026` | Aurora layer 1 |
| `auroraBg2` | `#1B2735` | Aurora layer 2 |
| `auroraBg3` | `#2C1E50` | Aurora layer 3 |
| `auroraTeal` | `#1D9E75` | Aurora wave 1 |
| `auroraIndigo` | `#534AB7` | Aurora wave 2 |
| `auroraMagenta` | `#B987FF` | Aurora wave 3 |

**Theme variants:** In Light mode the aurora uses lighter background layers (`#F6F2EC` / `#EFE6DA` / `#E8D9E8`) but the same wave colours. All text and icon colours come from `ColorScheme`, not hardcoded.

### 1.3 Typography

Font: **Inter** (or system fallback). No secondary display face — Inter's weight range is the only tool.

| Role | Weight | Size | Usage |
|---|---|---|---|
| Screen title (AppBar) | 700 | 22sp | Dashboard, Products, etc. |
| Section header | 600 | 13sp | Card section labels (all-caps, letter-spacing 0.8) |
| Card value large | 700 | 24sp | Today metric numbers |
| Card value medium | 700 | 18sp | Stat pill values |
| Card value small | 700 | 15sp | Trailing amounts in list rows |
| Body | 500 | 15sp | List item titles |
| Caption | 500 | 12sp | Subtitles, metadata |
| Label tiny | 600 | 12sp | Badges, pill labels (Updated for readability) |

Section headers inside cards are always **all-caps with letter-spacing 0.8** and `onSurfaceVariant` colour. Example: `TODAY`, `PLATFORM PERFORMANCE`, `STOCK ALERTS (1)`.

### 1.4 Surfaces & Panels

All cards are `GlassPanel` instances. Rules:

- `GlassPanel(noBlur: true)` — body panels, form sections, list containers. Semi-transparent fill.
- `GlassPanel(isFrostedGlass: true)` — emphasis panels (product sell cards when in-stock).
- `GlassPanel(solid: true)` — dialogs, bottom sheets, pop-up overlays that must be readable against a bright aurora. Used globally when "Solid Slate" theme is active.
- `GlassPanel.flush(...)` — full-bleed strips inside a parent panel.
- Border radius: `20dp` default, `28dp` for sheets, `24dp` for dialogs, `14dp` for inline field containers.
- All panels have a 1dp border with a top-left-to-bottom-right gradient from `white@30%` to `accent@18%` (dark mode).

### 1.5 Bottom Navigation Bar

- 5 tabs: **Dashboard · Products · Sales · Expenses · Reports**
- Wrapped in `GlassPanel(radius: 22, isFrostedGlass: true)` inside a `SafeArea`.
- Active tab: icon + label in `accent`. Inactive: `onSurfaceVariant`.
- `Products` tab has a `BadgedBox` with a red dot when any product is low/out of stock. The badge count = `lowStock + outOfStock`.
- Height: `76dp`. Bottom clearance for content scroll: `kBottomNavClearance = 100dp`.

### 1.6 Motion & Haptics

- **Motion:**
  - Panel entrance: `AnimatedSwitcher` with 250ms fade for tab content.
  - Toggle groups (platform, payment, ownership): 160ms `AnimatedContainer` colour transition.
  - Sheet presentation: standard Flutter `showModalBottomSheet` with `barrierColor: Colors.black.withOpacity(0.5)`.
- **Haptic Feedback:**
  - *Light tick:* Toggling switches (payment, platform), tab changes, opening bottom sheets.
  - *Medium impact:* Primary actions (tapping `SELL` button, saving a form).
  - *Heavy/Double impact:* Destructive actions, warnings (overdrawn bucket, deleting items).

### 1.7 Spacing Rhythm

- Horizontal screen padding: `16dp`
- Gap between cards: `16dp`
- Gap between form fields: `12dp`
- Section header to first item: `8dp`
- List row vertical padding: `12dp` horizontal padding: `16dp`
- Bottom scroll clearance: `kBottomNavClearance = 100dp` (via `SizedBox` at end of `ListView`/`LazyColumn`)

---

## 2. Navigation & Shell

### 2.1 Tab Structure & Quick Actions

```
┌─────────────────────────────────────┐
│         aurora backdrop             │
│  ┌───────────────────────────────┐  │
│  │    Screen content (scrolls)   │  │
│  └───────────────────────────────┘  │
│                   [ + ] Quick Action│
│  ┌───────────────────────────────┐  │
│  │ [Dash] [Prod] [Sale][Exp][Rep]│  │ 
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

- Router: `StatefulShellRoute.indexedStack` with 5 branches.
- **Global Quick Action FAB:** A Floating Action Button sits right above the navigation bar on the Dashboard tab. Tapping it opens a sleek, frosted glass bottom sheet offering instant actions: **New Sale**, **New Expense**, and **New Product**.
- Settings is NOT a tab. It is a `context.push('/settings')` full-screen modal accessible from the **top-right gear icon** visible on every tab's AppBar.

### 2.2 Settings Entry Point

Every tab's `AppBar` has a `⚙` (settings) icon as an action. Tapping it pushes `/settings`. This replaces the Finance tab and the per-screen settings buttons.

### 2.3 Deep Links (all routes)

```
/dashboard
/products
  /products/add
  /products/:id
  /products/:id/edit
/sales
  /sales/add
  /sales/:id/edit
/expenses
  /expenses/add
  /expenses/:id/edit
/reports
/settings
  /settings/wallets
    /settings/wallets/add
    /settings/wallets/edit/:id
  /settings/buckets
    /settings/buckets/add
    /settings/buckets/edit/:id
    /settings/buckets/history/:id
  /settings/add-ons
    /settings/add-ons/add
    /settings/add-ons/edit/:id
  /settings/finance
    /settings/finance/rules
      /settings/finance/rules/add
      /settings/finance/rules/edit/:id
    /settings/finance/history/:ruleId
  /settings/theme
  /settings/currency
```

---

## 3. Dashboard Tab

### 3.1 Layout Overview

The dashboard is a **single scrollable `ListView`** padded `16dp` horizontally with `kBottomNavClearance` at the bottom. AppBar shows `DASHBOARD` (centred, 22sp 700) with the `⚙` settings icon.

Cards appear in this fixed vertical order:
1. TODAY overview card
2. PLATFORM PERFORMANCE card
3. WALLET BALANCES card (Shows empty state if none configured)
4. BUDGET BUCKETS card (Shows empty state if none configured)
5. STOCK ALERTS card (hidden if no low/out-of-stock products)

### 3.2 TODAY Card

```
┌─────────────────────────────────────┐
│ TODAY                               │  
│                                     │
│  🛍 0        │  📈 ৳0.00           │
│  Sales       │  Revenue             │
│  ·····sparkline·····                │
├─────────────────────────────────────┤
│  🏦 ৳0.00   │  🐷 ৳0.00           │
│  Gross Profit│  Net Profit          │
│  (accent)    │  (accent or danger)  │
├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│  📅  CURRENT DUE  ৳0.00            │  
└─────────────────────────────────────┘
```

- Layout: `Column` with a `Row` of two `Expanded` cells (top), another `Row` of two `Expanded` cells (middle), a `Divider(1dp, white@10%)`, and a footer row.
- Each metric cell: icon (18sp, colour-tinted), large value (24sp 700), small label (12sp 500 `onSurfaceVariant`).
- Sparkline: a lightweight ambient line chart behind the Sales cell only. Use `fl_chart`'s `LineChart` with no axis labels, `dotData: FlDotData(show: false)`, stroke width 1dp, colour `accent@40%`. Shows last 7 days' sale counts. If no data, omit sparkline (don't show empty axes).
- Net Profit colour: `accent` if ≥ 0, `danger` if < 0. Gross Profit always `accent`.
- Footer: `danger` text, calendar icon left, amount right. `CURRENT DUE` all-caps 12sp 600 (Updated for readability). Amount 15sp 700.
- Interaction: none. Refresh via pull-to-refresh on the whole `ListView`.

### 3.3 PLATFORM PERFORMANCE Card

```
┌─────────────────────────────────────┐
│ PLATFORM PERFORMANCE                │
│                                     │
│   ┌──────┐    🔵 Facebook           │
│   │donut │       ৳0.00 (0%)        │
│   │chart │    ════════════ ← progress bar
│   │      │    🟣 Offline            │
│   └──────┘       ৳0.00 (0%)        │
│                ════════════         │
└─────────────────────────────────────┘
```

- Left 40% width: donut chart via `fl_chart` `PieChart`, two segments (Facebook `#1877F2`, Offline `#534AB7`), hole radius 60%, no labels on chart itself, no touch interaction needed.
- Right 60% width: two platform rows. Each row: platform icon (18sp) + name (15sp 600) + amount + percentage on second line + `LinearProgressIndicator` (6dp height, rounded, platform colour, background `white@10%`).
- If both platforms zero: show chart with a single grey segment and `0%` labels. Never hide this card.
- Revenue used for platform breakdown (not profit).

### 3.4 WALLET BALANCES Card (With Empty State)

- **Populated:** Shows active wallets as pill chips, wrapped. Chip: `GlassPanel`-styled container, `radius: 20`, padding `12×6`. Left: wallet name. Right: balance. Tap on chip navigates to `/settings/wallets/edit/:id`.
- **Empty State:** If no wallets are configured, do NOT hide the card. Instead, show an elegant dashed-outline card reading "Track your cash and bank balances here" with a subtle `+ Add Wallet` text button to encourage discovery and onboarding.

### 3.5 BUDGET BUCKETS Card (With Empty State)

- **Populated:** Each row shows colour dot, name, available amount (`success` or `danger`), and chevron right. Tap row navigates to `/settings/buckets/history/:id`.
- **Empty State:** If no buckets are configured, show an empty state placeholder reading "Organize your funds into custom buckets" with a `+ Add Bucket` button.

### 3.6 STOCK ALERTS Card

```
┌─────────────────────────────────────┐
│ STOCK ALERTS (3)                    │
│                                     │
│  [.P]  phone    ৳2,500    Low  >  SELL │
│  [.W]  widget   ৳500     Out  >  SELL │
└─────────────────────────────────────┘
```

- Header count = number of low + out-of-stock alertEnabled products.
- Each row: avatar square (first letter, 46×46dp, `primary@12%` bg, `primary` text, `radius: 12`), product name + price, stock badge pill (`Low` = `warning` / `Out` = `danger`), chevron icon, `SELL` filled tonal button (triggers Medium Haptic impact).
- `SELL` launches the Quick Sell sheet (§5.4).
- Tap row body: navigate to `/products/:id`.

---

## 4. Products Tab

### 4.1 Tab Layout

AppBar: `Products` (22sp 700), `⚙` settings icon (goes to `/settings`), `+` add icon (goes to `/products/add`). No separate per-screen settings button — settings consolidation done.

Below AppBar:
1. Stat bar (glass panel): Products count · Low stock count · Out of stock count · Total stock value.
2. Filter chips row: All · Low stock · Out of stock.
3. Search field (`GlassTextField`).
4. Product list (`SliverList`).

### 4.2 Product List Item (ProductTile)

Unchanged from current implementation. First-letter avatar, name, cost price, `StockBadge`, alert-off icon if `alertEnabled = false`, chevron.

### 4.3 Product Detail Screen

Unchanged. Shows product header card, restock button, recent sales panel, stock movements panel.

### 4.4 Product Form Screen

Unchanged. Name, cost price, stock, threshold, alert toggle, note.

### 4.5 Settings Are NOT Here

Previous design had wallets/buckets nested under `/products/settings`. **New design:** all settings are at `/settings`. The `⚙` icon in the Products AppBar goes directly to `/settings`, not to a product-specific settings sub-screen. The product settings screen is deleted.

---

## 5. Sales Tab

### 5.1 Tab Layout

AppBar: `Sales` (22sp 700), `⚙` icon, `+` icon (goes to `/sales/add`).

Content sections (scrollable `CustomScrollView`):
1. Active Products section header + product sell cards.
2. Out of Stock section header + dimmed product sell cards.
3. Discounted Sale entry point card.
4. Recent Sales panel (last 5 sales).

### 5.2 Product Sell Card

Same as current. Name, stock badge, cost, estimated profit. `Sell` button launches Quick Sell sheet.

### 5.3 Sale Form Screen (`/sales/add`, `/sales/:id/edit`)

Fields in order:
1. Product picker tile.
2. Quantity + Selling price row.
3. Last sold price caption (if available).
4. Platform toggle (Facebook · Offline).
5. Payment toggle (Paid · Due).
6. Ownership toggle (Business · Personal).
7. Wallet picker.
8. Customer name field (optional).
9. **Add-Ons section** (new — see §5.5).
10. Live preview panel: Total · Est. Profit (recalculates including add-on costs).
11. Save button.

### 5.4 Quick Sell Sheet

Bottom sheet, `GlassPanel(solid: true, radius: 28)`. Fields:
1. Product name header + stock caption.
2. Quantity + Selling price row.
3. Platform segmented button.
4. Payment segmented button.
5. Customer (optional).
6. **`+ Add-Ons` button** (new — see §5.5).
7. Live total + profit footer with Confirm button.

The profit shown in the footer subtracts add-on costs: `profit = (sellingPrice - costPrice) × qty - Σ(addOnAmount)`.

### 5.5 Add-Ons System

#### What it is

Add-ons are optional per-sale costs that reduce net profit. Examples: gift wrapping, packaging, delivery contribution, promotional item. The user defines which add-on types exist in Settings. During a sale they can attach zero or more add-ons with a custom amount each.

#### Data model

**`AddOnTypes` table** (new, Schema v5 migration):
```
id          INTEGER PK AUTOINCREMENT
name        TEXT NOT NULL           -- e.g. "Gift Wrap", "Packaging"
defaultAmount REAL DEFAULT 0.0     -- pre-filled amount hint (0 = no hint)
isActive    BOOLEAN DEFAULT true
createdAt   INTEGER NOT NULL
```

**`SaleAddOns` table** (new, Schema v5 migration):
```
id          INTEGER PK AUTOINCREMENT
saleId      INTEGER NOT NULL REFERENCES sales(id)
addOnTypeId INTEGER NOT NULL REFERENCES add_on_types(id)
amount      REAL NOT NULL           -- actual amount charged this sale
note        TEXT NULLABLE
createdAt   INTEGER NOT NULL
```

Profit formula (updated everywhere):
```
grossProfit = (sellingPrice - costPrice) × quantity
addOnCost   = Σ SaleAddOns.amount WHERE saleId = sale.id
netSaleProfit = grossProfit - addOnCost
```

This change affects: `DashboardSummary`, `ReportRepository`, `ExportService`.

#### UI — "Add-Ons" button and sheet

The `+ Add-Ons` button appears in: Sale Form, Quick Sell sheet, Discount Sale sheet.

Style: `OutlinedButton` with `Icons.add_circle_outline` and label `Add-Ons (n)` where `n` = count of currently added add-ons. If none added, label is just `+ Add-Ons`. Colour: `accent` border and text.

Tapping opens the **Add-Ons picker sheet**:

```
┌─────────────────────────────────────┐
│ ████ drag handle ████               │
│ Add-Ons                             │  ← 17sp 700
│                                     │
│  ┌─ Gift Wrap ─────────── ৳50  [x] ┐│  ← added row
│  └────────────────────────────────┘│
│                                     │
│  Gift Wrap         [  +  ]         │  ← available add-on type
│  Packaging         [  +  ]         │
│  Delivery          [  +  ]         │
│                                     │
│  Total add-on cost: ৳50            │
│                         [  Done  ] │
└─────────────────────────────────────┘
```

- Top section: currently added add-ons. Each row shows name, amount field (editable `GlassTextField`), and `×` remove button.
- Bottom section: list of active `AddOnType` entries not yet added. Tap `+` to add with `defaultAmount` pre-filled (or 0 if none).
- "Total add-on cost" updates live.
- `Done` closes sheet and passes list back to parent form.
- Amount field validation: must be ≥ 0. Zero is allowed (free add-on tracking).

#### UI — Add-On Types in Settings (`/settings/add-ons`)

Single-page list of add-on types. Each row: name, default amount, active toggle, edit icon.

`FloatingActionButton` adds a new type. Edit sheet: name field, default amount field, active toggle. No separate edit screen — use a `showModalBottomSheet`.

---

## 6. Expenses Tab

### 6.1 Layout

Unchanged from current. `CustomScrollView` with:
- AppBar: `Expenses` + `⚙` + `+`.
- Date filter bar.
- Summary strip (entries count + total).
- Expense list.

### 6.2 Expense Form

Unchanged structure. Fields: amount, category toggle, ownership toggle + wallet picker, allocation rule picker, budget bucket picker, note, date.

No changes needed here beyond ensuring the wallet / bucket pickers respect the unified settings paths.

---

## 7. Reports Tab

### 7.1 Tab Layout

AppBar: `Reports` + `⚙`. Month/year selector bar. Tab selector (Daily · Monthly · Products · **Per Sale**).

### 7.2 Existing Tabs

**Daily** and **Monthly** tabs: unchanged from current (bar chart or table, toggle).

**Products** tab: shows product-level performance table (quantity sold, revenue, profit). Unchanged.

### 7.3 New: Per Sale / Profit History Tab

New fourth tab in the `SegmentedButton`. Label: `Per Sale`.

This tab shows a **chronological list** of individual sales with the net profit of each sale (after add-on costs deducted).

```
┌─────────────────────────────────────┐
│ ┌────────────────────────────────┐  │
│ │ 13 Jun · phone · 1 unit       │  │
│ │ Sold ৳3,000  Cost ৳2,500     │  │
│ │ Add-ons: Gift Wrap ৳50        │  │
│ │ Net profit: +৳450  Facebook  │  │
│ └────────────────────────────────┘  │
│ ┌────────────────────────────────┐  │
│ │ 12 Jun · widget · 2 units     │  │
│ │ ...                            │  │
│ └────────────────────────────────┘  │
└─────────────────────────────────────┘
```

Each card: date + product name + quantity, selling price row, add-on cost row (if any add-ons; omit row if none), net profit (green or red). Platform badge. Payment status icon.

Filtering: same date range picker as other report tabs. The month selector applies.

Sorting: newest first (default). No sort toggle needed.

**Also: Per-Product Profit History**

Within the `Products` report tab, each product row is tappable. Tapping expands an inline sub-panel (or pushes a new screen `/reports/product/:id`) showing:
- Monthly profit bars for that product (last 12 months).
- All-time total units sold, total revenue, total gross profit.
- Top 3 months by profit.

This is additive to the existing product performance table.

---

## 8. Settings Overlay

Settings is a full-screen modal route (`context.push('/settings')`) with its own `Scaffold`. It is NOT a tab. It contains all configuration previously spread across multiple locations.

### 8.1 Settings Screen Layout

```
┌─────────────────────────────────────┐
│  ← Settings                         │  
│                                     │
│  FINANCE                            │  
│  ┌─────────────────────────────┐    │
│  │ 💳 Wallets              >  │    │
│  │ 🪣 Budget Buckets        >  │    │
│  │ 📐 Allocation Rules      >  │    │
│  └─────────────────────────────┘    │
│                                     │
│  SALES                              │
│  ┌─────────────────────────────┐    │
│  │ 🎁 Add-On Types          >  │    │
│  └─────────────────────────────┘    │
│                                     │
│  APPEARANCE                         │
│  ┌─────────────────────────────┐    │
│  │ 🎨 Theme                 >  │    │
│  │ 💱 Currency              >  │    │
│  └─────────────────────────────┘    │
│                                     │
│  ABOUT                              │
│  ┌─────────────────────────────┐    │
│  │ ℹ️ App version  1.0.1+3     │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

Sections: grouped `GlassPanel` lists with `Divider(1dp)` separators. Section headers: all-caps 12sp 600 `onSurfaceVariant`. Row style: `ListTile` with leading icon (`accent`), title (white), trailing chevron.

### 8.2 Wallets Sub-Screen (`/settings/wallets`)

**Single-page design** — no nested sub-screens for the list itself.

```
┌─────────────────────────────────────┐
│  ← Wallets                    [  +  ]│
│                                      │
│  ┌──────────────────────────────┐   │
│  │ Cash          ৳4,200  ✏ 🗑  │   │
│  │ bKash         ৳800    ✏ 🗑  │   │
│  └──────────────────────────────┘   │
│                                      │
│  [Balances auto-calculate from       │
│   sales and expenses]                │
└──────────────────────────────────────┘
```

- List of wallets with inline balance.
- `+` icon in AppBar adds a new wallet via a **bottom sheet** (not a new screen).
- Edit (✏) icon on each row opens edit bottom sheet.
- Delete (🗑) with `showGlassDialog` confirm.
- Wallet bottom sheet fields: Name, Type (chip group: cash/bank/bKash/nagad/rocket/custom), Opening Balance, Active toggle.
- **No separate `/wallets/add` or `/wallets/edit/:id` screens.** Everything in sheets on this one page.

### 8.3 Budget Buckets Sub-Screen (`/settings/buckets`)

Same single-page-with-sheets pattern as Wallets.

List shows: name, colour dot, allocated amount, available amount (in `success` or `danger`). `+` in AppBar opens add sheet. Tap row opens edit sheet. Long-press or trailing icon for delete.

Bucket sheet fields: Name, Allocated Amount, Colour picker (9 preset swatches). No separate add/edit screens.

Bucket history remains at `/settings/buckets/history/:id` (separate screen is fine — it's detailed enough).

### 8.4 Allocation Rules Sub-Screen (`/settings/finance/rules`)

Same pattern as Wallets. List with `+` AppBar icon → sheet. Edit via sheet. No separate screens.

Rule sheet fields: Label, Percentage (0–100), Active toggle. Warning banner if total > 100%.

### 8.5 Finance Overview (`/settings/finance`)

A sub-screen within Settings that shows the Finance tab content (accumulated vs spent per rule). Navigation:

Settings → Finance → shows `FinanceScreen` content inline.

Within this screen: settings gear opens Allocation Rules sub-screen. History per rule tappable.

### 8.6 Add-On Types Sub-Screen (`/settings/add-ons`)

See §5.5. Single-page list + bottom-sheet add/edit.

### 8.7 Theme Sub-Screen (`/settings/theme`)

See §10.

### 8.8 Currency Sub-Screen (`/settings/currency`)

Placeholder for now. Shows: `Currency symbol: ৳`, `Decimal places: 2`. No interaction (future feature). Display only.

---

## 9. Add-Ons System — Full Specification

### 9.1 Database (Schema v5)

Migration: add `add_on_types` table and `sale_add_ons` table. No existing columns modified.

```sql
CREATE TABLE add_on_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  default_amount REAL DEFAULT 0.0,
  is_active BOOLEAN DEFAULT 1,
  created_at INTEGER NOT NULL
);

CREATE TABLE sale_add_ons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL REFERENCES sales(id),
  add_on_type_id INTEGER NOT NULL REFERENCES add_on_types(id),
  amount REAL NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL
);
```

### 9.2 Repository: `AddOnRepository`

Location: `lib/features/sales/add_on_repository.dart`

Methods:
- `Stream<List<AddOnType>> watchActiveTypes()` — for the picker sheet
- `Future<List<AddOnType>> getActiveTypes()`
- `Future<int> createType({required String name, double defaultAmount = 0, bool isActive = true})`
- `Future<void> updateType({required int id, required String name, double defaultAmount, bool isActive})`
- `Future<void> deleteType(int id)`
- `Future<List<SaleAddOn>> getForSale(int saleId)`
- `Future<void> setForSale(int saleId, List<SaleAddOnCompanion> addOns)` — replaces all add-ons for that sale (used on update)
- `Future<double> totalCostForSale(int saleId)`

### 9.3 Profit Calculation Update

**Every place that calculates profit must be updated:**

| Location | Change |
|---|---|
| `DashboardProvider` | Subtract add-on costs from gross profit per sale |
| `ReportRepository.dailySnapshots` | Join `sale_add_ons` to subtract per-sale |
| `ReportRepository.monthlySummaries` | Same |
| `ReportRepository.productReport` | Same |
| `ExportService.buildWorkbook` | New "Add-Ons" column in Sales sheet; add-on total in Summary |
| Sale Form live preview | Sum `_addOns.map((a) => a.amount)` and subtract |
| Quick Sell sheet live preview | Same |
| Discount Sheet live preview | Same |

Formula is always:
```
netSaleProfit = (sellingPrice - costPrice) × quantity - Σ addOnAmounts
```

### 9.4 State Management for Add-Ons in Forms

In Sale Form, Quick Sell Sheet, and Discount Sheet, add-on state is a local `List<_AddOnEntry>` where:
```dart
class _AddOnEntry {
  final int typeId;
  final String typeName;
  double amount;
  String? note;
}
```

When the sheet opens in edit mode for an existing sale, load add-ons from `AddOnRepository.getForSale(saleId)`.

On save: call `AddOnRepository.setForSale(saleId, entries)` after the sale is committed.

---

## 10. Theme System

### 10.1 Available Themes

Four built-in themes. User selects in `/settings/theme`.

| Theme | Background | Accent | Aurora |
|---|---|---|---|
| **Dark Aurora** (default)| Deep space (`#0B1026`) | Teal `#1D9E75` | Teal / Indigo / Magenta waves |
| **Light Aurora** | Warm cream (`#F6F2EC`) | Teal `#1D9E75` | Same wave colours, lighter bg layers |
| **Midnight Blue** | Navy (`#0A0F1E`) | Electric blue `#3B82F6` | Blue / Purple / Cyan waves |
| **Solid Slate** (New) | Charcoal (`#121212`) | Teal `#1D9E75` | **None.** Animations disabled, opaque surfaces. |

*Note: The "Solid Slate" theme caters to users needing high-contrast, distraction-free interfaces or those with visual accessibility needs.*

### 10.2 Theme Persistence

Store selected theme ID in `SharedPreferences` with key `invenio_theme`. Read on app start before first paint. `TrackerApp` wraps in a `StateProvider<ThemeMode>` (Riverpod) so live-switching works without restart.

### 10.3 Theme Screen UI

```
┌─────────────────────────────────────┐
│  ← Theme                            │
│                                     │
│  ┌──────────────┐ ┌──────────────┐ │
│  │ [preview]    │ │ [preview]    │ │
│  │ Dark Aurora  │ │ Light Aurora │ │
│  │   ✓ Active   │ │              │ │
│  └──────────────┘ └──────────────┘ │
│  ┌──────────────┐ ┌──────────────┐ │
│  │ [preview]    │ │ [preview]    │ │
│  │ Midnight Blue│ │ Solid Slate  │ │
│  └──────────────┘ └──────────────┘ │
└─────────────────────────────────────┘
```

- 2-column `Wrap` of theme cards.
- Each card: 100×140dp `GlassPanel`, aurora colour swatch strip at top (3 coloured bands, 20dp tall), theme name (14sp 600), active indicator (`accent` tick + "Active" caption).
- Tapping a card switches the app theme live.

### 10.4 ThemeData Construction

`AppTheme` gains a factory `fromId(String id)` that returns a configured `ThemeData` + `AuroraConfig`. `AuroraBackdrop` reads the config from a provider, not hardcoded.

```dart
class AuroraConfig {
  final List<Color> backgrounds;
  final List<List<Color>> waves;
}
```

`AuroraBackdrop` is updated to accept `AuroraConfig` via provider rather than hardcoded constants.

---

## 11. Component Library

### 11.1 GlassPanel (existing — no changes)

See §1.4 for usage rules. Do not modify the widget itself. Becomes completely opaque if "Solid Slate" theme is active.

### 11.2 GlassTextField (existing — no changes)

### 11.3 SectionHeader (new widget)

```dart
// Usage:
SectionHeader('PLATFORM PERFORMANCE')
SectionHeader('STOCK ALERTS (3)', trailing: Text('3', style: ...))
```

Style: all-caps, 13sp 600, `onSurfaceVariant` colour, `letterSpacing: 0.8`. Consistent across all cards.

### 11.4 MetricCell (new widget)

Used in Today card.

```dart
MetricCell(
  icon: Icons.shopping_bag_outlined,
  iconColor: AppColors.accent,
  value: '0',
  label: 'Sales',
  sparklineData: [...],   // optional
)
```

### 11.5 PlatformRow (existing — refactor)

Used in Platform Performance card. Accepts `label`, `amount`, `percentage`, `color`, `progress` (0.0–1.0).

### 11.6 StockBadge (existing — no changes)

### 11.7 AddOnPickerSheet (new widget)

`lib/features/sales/widgets/add_on_picker_sheet.dart`

```dart
Future<List<_AddOnEntry>?> showAddOnPicker(
  BuildContext context, {
  required List<AddOnType> availableTypes,
  required List<_AddOnEntry> current,
})
```

Returns updated list or `null` if dismissed without change.

### 11.8 WalletBalanceChip (existing)

Chip pill showing wallet name + balance. Used in Dashboard wallet balances card. Tap → settings wallet edit sheet (via navigator push to `/settings/wallets`).

### 11.9 SettingsTile (new shared widget)

```dart
SettingsTile(
  icon: Icons.savings_outlined,
  title: 'Budget Buckets',
  onTap: () => context.push('/settings/buckets'),
)
```

Style: `ListTile` with `accent` leading icon, white title, `onSurfaceVariant` chevron. Used in Settings screen.

### 11.10 ThemeCard (new widget)

For the theme picker screen. See §10.3.

### 11.11 Haptic Wrappers (new standard)

Ensure interactive widgets (buttons, toggles, list items) use the standardized haptic feedback profiles defined in §1.6.

---

## 12. Data Model Summary (Schema v5)

Schema v5 adds two tables. Migration path:

```
v1 → v2: add alertEnabled, isDiscounted, normalPrice
v2 → v3: add wallets, allocationRules, walletId/ownership on sales+expenses, allocationRuleId
v3 → v4: add budgetBuckets, bucketId on expenses
v4 → v5: add addOnTypes, saleAddOns
```

Migration `from < 5` block:
```sql
CREATE TABLE add_on_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  default_amount REAL DEFAULT 0.0,
  is_active BOOLEAN DEFAULT 1,
  created_at INTEGER NOT NULL
);

CREATE TABLE sale_add_ons (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL REFERENCES sales(id),
  add_on_type_id INTEGER NOT NULL REFERENCES add_on_types(id),
  amount REAL NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL
);
```

No seed data required. User creates their own add-on types in Settings.

---

## 13. Implementation Priority Order

For agents implementing this spec, tackle in this order to avoid dependency issues:

1. **Schema v5 migration** (`app_database.dart`, tables, `.g.dart` regeneration).
2. **AddOnRepository + providers** (no UI dependency).
3. **Theme system** (`AppTheme.fromId`, `AuroraConfig`, `ThemeCard`, settings persistence).
4. **Settings screen** (`/settings` route, all sub-screens as listed in §8).
5. **Wallet/Bucket/AllocationRules single-page-with-sheets refactor** (consolidation from multiple screens into single screens with bottom sheets).
6. **Finance sub-screen in Settings** (move `FinanceScreen` content to `/settings/finance`).
7. **Remove Finance tab from nav bar** (reduce to 5 tabs, update `AppScaffold` and router).
8. **Add-Ons UI** — Add-Ons picker sheet, `+ Add-Ons` button in Sale Form, Quick Sell, Discount Sheet.
9. **Profit recalculation** — update all profit calculations to subtract add-on costs.
10. **Dashboard redesign** — implement new card layout matching §3 and the reference image.
11. **Reports: Per Sale tab** + per-product profit history expansion.
12. **Add-On Types settings screen** (`/settings/add-ons`).
13. **Global UI/UX Polish** — Integrate Haptics wrappers, Quick Action FAB, and Empty States for Wallets/Buckets.
14. **`flutter analyze` clean-up** — fix any cascaded import changes.
15. **Test updates** — update unit tests for new profit formula.

---

## 14. Reference: Dashboard Screenshot

The uploaded dashboard screenshot (`1781288630696_image.png`) and `invenio_dashboard_specification.md` define the visual target for the Dashboard tab. Key points extracted:

- Title `DASHBOARD` centred, all-caps, white, regular weight.
- TODAY card: 2×2 grid with icons, large numbers, labels. Footer with `CURRENT DUE` in danger red.
- PLATFORM PERFORMANCE: concentric donut chart left, two platform rows right with progress bars.
- STOCK ALERTS: avatar letter-square, product name + price, `Low` pill badge (orange), `> SELL` button.
- Bottom nav: 5 icons, active = green, Products has red badge dot, Dashboard active highlighted.
- Overall: dark slate background, all cards have subtle border, rounded corners.

The current `AppColors` and `GlassPanel` implementation already matches this. The dashboard screen layout in Flutter needs to be updated to match §3 exactly, including the 2×2 grid layout, the sparkline behind Sales, the donut chart, and the correct card order.

---

*End of DESIGN.md*

# Invenio — Feature Integration Plan
**Written:** 2026-06-04  
**Status:** Planning  
**Approach:** Integrate new features into existing codebase. Keep existing tabs, DB, theme, expenses, dashboard, reports.

---

## What Stays Unchanged

| Area | Keep as-is |
|------|-----------|
| Liquid Glass theme | Aurora backdrop, glass panels, frosted nav |
| SQLite / Drift DB | Same schema, extend with new columns |
| Riverpod state | Same codegen pattern |
| go_router | Same ShellRoute, add new routes |
| Dashboard tab | Today stats, platform split, low-stock list |
| Expenses tab | Ads/Delivery/Packaging/Misc, monthly totals |
| Reports tab | Daily/monthly/product charts, Excel export |
| Alert service | Below-cost, margin drop alerts kept |

---

## What Changes

### Tab 1 — Dashboard (extend, not replace)

Keep everything. Add:
- **Quick-sell shortcut** — low-stock products in dashboard list now also show a [Sell] button inline, not just a tap-to-navigate link
- Low-stock badge count on Products tab icon

### Tab 2 — Products (becomes product master + settings)

Currently: product CRUD with stock management.  
New additions to existing product form:
- **Low-stock alert toggle** (ON by default) — per product
- Threshold already exists (`lowStockThreshold`) — expose it more prominently in the form

Product list screen additions:
- Show alert ON/OFF status per tile (small bell icon, struck-through if off)

No new tab needed — Settings lives inside Products tab as it does now.

```
Products screen (existing)
┌─────────────────────────────────┐
│  Wireless Mouse    stock: 12    │
│  ৳450 cost   threshold: 5  🔔  │
├─────────────────────────────────┤
│  USB Hub           stock: 2 ⚠️  │
│  ৳780 cost   threshold: 3  🔔  │
├─────────────────────────────────┤
│  HDMI Cable        stock: 0 ░░  │
│  ৳220 cost   threshold: 5  🔕  │  ← alert OFF
└─────────────────────────────────┘
```

### Tab 3 — Sales (significant change)

Currently: form-first flow (tap +, fill form, save).  
New: product grid with per-item [Sell] button as the primary interaction. Keep existing form as fallback for complex entries.

**Sales screen layout:**

```
Sales
── Active products ───────────────
┌─────────────────────────────────┐
│  Wireless Mouse        Stock: 12│
│  Cost ৳450  Last sold: ৳650     │
│  Est. profit: +৳200/unit        │
│                        [Sell ▶] │
├─────────────────────────────────┤
│  USB Hub               Stock: 2 │
│  Cost ৳780  Last sold: ৳1,100   │
│  Est. profit: +৳320/unit        │
│                        [Sell ▶] │
├─────────────────────────────────┤
│  HDMI Cable     ░░ OUT OF STOCK │
│  Cost ৳220  Last sold: ৳350     │
│                     [disabled]  │
└─────────────────────────────────┘

── Discounted / Special Sales ────
┌─────────────────────────────────┐
│  + Log discounted sale          │
├─────────────────────────────────┤
│  Mouse × 2   ৳500 each  [paid]  │
│  Normal ৳650 → Discount ৳500    │
│  Margin loss: -৳300 total       │
└─────────────────────────────────┘

                    [+ Full form ▶]  ← existing sale form, kept
```

**[Sell] button → bottom sheet (quick modal):**
```
┌─────────────────────────────────┐
│  Sell — Wireless Mouse          │
│  Stock available: 12            │
│─────────────────────────────────│
│  Quantity:      [  1  ]         │
│  Selling price: [ 650 ] ৳       │
│  Platform:  [Facebook] [Offline]│
│  Payment:   [Paid]     [Due]    │
│─────────────────────────────────│
│  Total: ৳650   Profit: +৳200    │
│         [Cancel]   [Confirm ✓]  │
└─────────────────────────────────┘
```

**Discounted sale modal:**
```
┌─────────────────────────────────┐
│  Discounted Sale                │
│─────────────────────────────────│
│  Product:    [dropdown]         │
│  Quantity:   [  1  ]            │
│  Normal price:  ৳ ___           │
│  Discount price: ৳ ___          │
│  Platform:  [Facebook] [Offline]│
│  Payment:   [Paid]     [Due]    │
│─────────────────────────────────│
│  Discount: -৳X   Loss: -৳Y     │
│         [Cancel]   [Confirm ✓]  │
└─────────────────────────────────┘
```

Out-of-stock: tile grayed out, [Sell] disabled, no tap action possible.

### Tab 4 — Expenses (unchanged)

No changes.

### Tab 5 — Reports (unchanged)

No changes.

---

## Alert System — Additions to Existing AlertService

Currently `AlertService.checkSale()` fires: below-cost, low-stock, margin-drop.  
New additions:

**Per-product alert toggle:**
- New column `alertEnabled` (bool, default true) on `products` table
- `AlertService` checks `product.alertEnabled` before firing low-stock alert
- If `false`: low-stock alert suppressed even if stock ≤ threshold

**App-open check:**
- On launch, scan all products. Collect those with `stock ≤ threshold AND alertEnabled = true`
- Show single consolidated banner: *"3 products low on stock"* with tap → Products tab

**Alert trigger points:**
| Trigger | Behavior |
|---------|----------|
| After sale (existing) | Low-stock banner if `alertEnabled AND stock ≤ threshold` |
| App open (new) | Consolidated banner for all low-stock, alert-enabled products |
| Manual stock adjust down (existing) | Same check as after sale |

**Visual regardless of toggle:**
| Stock state | `alertEnabled = true` | `alertEnabled = false` |
|-------------|----------------------|----------------------|
| > threshold | Normal | Normal |
| ≤ threshold | Amber badge + banner | Amber badge, no banner |
| = 0 | Gray + banner | Gray, no banner |

Toggle never hides amber/gray visual — only suppresses the popup/banner.

---

## DB Schema Changes

Minimal. One new column, one new table.

### `products` table — add column
```dart
BoolColumn get alertEnabled => boolean().withDefault(const Constant(true))();
```

### `sales` table — add column (discounted sale flag)
```dart
BoolColumn get isDiscounted => boolean().withDefault(const Constant(false))();
RealColumn get normalPrice => real().nullable()(); // original price before discount
```

Drift migration: `schemaVersion` bump to 2, `onUpgrade` adds columns.

---

## Navigation Structure

**Unchanged — keep 5 tabs:**
```
[Dashboard] [Products] [Sales] [Expenses] [Reports]
```

No new tabs. All new features integrate into existing tabs.

---

## Data Flow (updated)

```
Products tab (product master + alert toggle + threshold)
    │
    ├──→ Dashboard (low-stock list, quick-sell shortcut)
    │
    ├──→ Sales tab (product grid + [Sell] button + discounts)
    │         │
    │         └──→ stock decrements → AlertService.checkSale()
    │                                      → suppressed if alertEnabled=false
    │
    ├──→ Expenses tab (unchanged)
    │
    └──→ Reports tab (unchanged, discounted sales visible in data)
```

---

## Implementation Order

1. **DB migration** — add `alertEnabled` + `isDiscounted` + `normalPrice` columns
2. **Products** — expose alert toggle + threshold in product form; bell icon on list
3. **AlertService** — respect `alertEnabled`, add app-open check
4. **Sales screen** — product grid with [Sell] button + quick-sell bottom sheet
5. **Discounted sales** — section below grid, modal, flag in DB
6. **Dashboard** — [Sell] shortcut on low-stock tiles (optional, phase 2)

---

## Key Rules

| Rule | Detail |
|------|--------|
| 5 tabs unchanged | No new tabs, integrate into existing |
| Out of stock = disabled on Sales grid | Gray tile, no [Sell] action |
| Existing full sale form kept | Accessible via [+ Full form] button |
| Discounted sales flagged in DB | `isDiscounted=true`, `normalPrice` stored |
| Alert toggle per product | `alertEnabled` column, default true |
| Toggle suppresses banner only | Amber/gray visual always shows |
| Threshold already in DB | `lowStockThreshold` column exists, just expose better |
| Schema version bumps to 2 | Drift migration, no data loss |
| Liquid Glass theme untouched | All new UI uses existing GlassPanel/GlassTextField |

---

## Out of Scope (unchanged)

- Cloud sync
- Multiple users
- Barcode scanning
- Invoice generation

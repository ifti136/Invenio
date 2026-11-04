# Invenio — Clean Ledger Design Specification

> **Supersedes Liquid Glass.** The previous aurora / glass design language is
> retired and kept only in git history. Invenio now uses a flat Material 3
> "Clean Ledger" design: calm surfaces, one teal accent, big readable numbers,
> and no blur, gradients, shadows, or animated backgrounds.

Master source: `docs/invenio overhaul.pdf` (v2.3) §8. This document is the
implementation reference for the Clean Ledger overhaul.

---

## 1. Design language

**Name:** Clean Ledger
**Personality:** A good notebook for a working seller — calm, legible, and
fast. It should feel like a trusted paper ledger that happens to be on a
phone, not a dashboard toy.

- Flat tonal surfaces, separated by a 1 px outline. No shadows, blur,
  gradients, or animated backgrounds.
- Money is always the loudest element on a screen. Labels are quiet.
- Every state shows text **and** an icon; colour never carries meaning alone.
- One primary action per screen, placed at the bottom in the thumb zone.
- Plain words: "Money in / Money out / Owed to you", not accounting jargon.

### Principles

1. **One loop:** Sell → stock down → money into a source (or a due) → profit
   up. Restock or expense → money out of a source.
2. **Sale in under 10 seconds** for the common case.
3. **Every number is traceable.** Tap a balance, stock count, due, or profit
   to see the entries behind it.
4. **Nothing is hardcoded to one shop.** Currency, accounts, and names are
   user-editable.
5. **Calm and fast.** Flat Material 3, no motion beyond system transitions.
6. **Fewer things.** If a feature does not serve the core seller loop, it is
   not in v2.

---

## 2. Colour

`ColorScheme.fromSeed(seedColor: Color(0xFF1D9E75))`, light and dark.

| Role | Colour | Use |
|------|--------|-----|
| Primary (teal `#1D9E75`) | `scheme.primary` | Primary buttons, selected nav, money-in, positive profit |
| Tertiary (amber) | `#EF9F27` | Low stock, dues, warnings |
| Error (red) | `scheme.error` / `#E24B4A` | Out of stock, below cost, negative profit/balance, money-out, destructive actions |
| Neutral surfaces | `scheme.surface*` | Everything else |

- Money signs: `+` money in, `−` money out. Colour reinforces the sign; it
  never replaces it.
- Text must reach **4.5:1** contrast in both themes.
- Do not use colour as the only status indicator. Pair it with an icon and a
  label.

---

## 3. Typography

Platform default font. Use **tabular figures for every money value**.

| Style | Size / weight | Use |
|-------|---------------|-----|
| Display | 36 / 700 | Home total money, sale total (hero moments only) |
| Headline | 24 / 700 | Net profit, product name, account balance |
| Title | 20 / 600 | Screen titles, sheet titles |
| Body | 14–16 / 400–500 | Rows, fields |
| Label | 12 / 600 | Chips, badges, captions |

Expressive type is reserved for hero moments. Do not scale up every number.

---

## 4. Shape, spacing, and components

### Shape

| Element | Radius |
|---------|--------|
| Hero card | 24 |
| Card | 16 |
| Button / input | 12 |
| Sheet (top) | 28 |
| Chip / badge | pill (999) |

### Spacing

`4 / 8 / 12 / 16 / 24 / 32`. Screen padding is **16**. Section gap is **24**.

### Rhythm

- Navigation bar: **64 dp** high, pill indicator.
- List rows: **56** (one line), **72** (two lines), **88** (three lines) dp.
- Touch target: at least **48 dp**.
- Primary actions sit at the bottom of the screen.

### Components

Material 3: `NavigationBar`, `FilledButton`, `FilledButton.tonal`,
`OutlinedButton`, `SegmentedButton`, `FilterChip`, `SearchBar`, `Card.filled`,
`ListTile`, bottom sheets with a drag handle, `AlertDialog`, floating
`SnackBar` with Undo, `ExtendedFloatingActionButton`.

Custom (small, shared):

- `MoneyText` — formats minor units with the settings currency symbol and
  tabular figures.
- `StatCard` — quiet label, loud value, optional icon/tone.
- `AccountChip` — account name + live balance.
- `ProductTile` — initial avatar, name, price, stock badge.
- `StockBadge` — in stock / low / out, icon + label.
- `StatusChip` — Paid / Part paid / Due.
- `SaleBar` — sticky total + profit summary bar with the primary action.
- `EmptyState` — icon + title + one sentence + primary action.

No new UI dependency. The expressive feel comes from theme tokens, not a
package.

---

## 5. Motion and accessibility

- Use system transitions only.
- The one exception is a **150 ms fade** when the chart range changes.
- Respect the platform "remove animations" setting.
- Everything must work at **200 % font scale** without clipping. Do not use
  fixed-height text rows; wrap text in `Flexible`/`Expanded`.
- Icon-only buttons need semantic labels.
- Light and dark themes must both pass contrast checks.

---

## 6. Screen specifications

All screens are 360 dp-first. `$` below means the user's currency symbol.

### 6.1 Home

- App bar: shop name on the left, Settings icon on the right.
- Hero card (24 dp radius): "Total money" label + Display value.
- Scrollable row of `AccountChip`s (Cash, Bank, Mobile wallet…).
- Two stat cards: **Owed to you** (total + customer count) and **Low stock**
  (count + "See all").
- **Today** stat row: Sales count, Revenue, Profit.
- Extended FAB: **New sale**.
- Every card/chip navigates to the entries behind it.

### 6.2 Sales

- App bar: "Sales" + search.
- Filter chips: Date, Channel, Status.
- List grouped by day with a day total.
- Row: time, customer/walk-in, short item summary, total, `StatusChip`.
- Primary action: **New sale** (bottom / extended FAB).

### 6.3 Sale form (single scrolling form)

- Items section with an **Add item** button. Each line: product, qty stepper,
  editable unit price, line total, remove.
- Price below list shows a **Discount** tag. Below cost shows red text, an
  icon, and a short inline warning (never a blocking dialog).
- Customer picker, Channel segmented control.
- Payment segmented control: **Paid in full / Part / Later**. Part reveals an
  amount field; Later hides "Received in". Customer is required unless paid in
  full.
- Sticky `SaleBar` at the bottom: total, live profit, primary **Save sale**.

### 6.4 Inventory

- App bar: "Inventory" + search.
- Summary line: products, low, out, stock value.
- Filter chips: All / Low stock / Out / Archived.
- `ProductTile` rows with name, cost, price, stock, `StockBadge`, and a
  **Sell** action.
- Primary action: **Add product**.

### 6.5 Product detail

- Summary: stock, price, cost, low-stock threshold.
- Actions: **Restock**, **Sell**.
- One merged activity timeline: sale, restock, initial, adjustment.
- Restock sheet: quantity, unit cost (prefilled), **Paid from** account or
  None, note.

### 6.6 Money

- Segmented control: **Accounts / Dues / Expenses**.
- Accounts: total money + one card per account.
- Actions: **Transfer**, **Add expense**.
- Account ledger: period selector, `In +$X · Out −$Y` summary, signed rows,
  running balance, visible adjustments.
- Dues: total owed, grouped by customer with oldest-due age.
- Expenses: date presets, category chips, monthly total, list.

### 6.7 Reports

- Range segmented control: Week / Month / Year / Custom.
- P&L card: Revenue − Cost of goods = Gross profit − Expenses = Net profit,
  plus margin %.
- Revenue-vs-profit bar chart with tap-for-detail and a 150 ms range fade.
- Breakdown tables: Products and Channels (name, qty, revenue, profit).
- Primary action: **Export CSV**.

### 6.8 Settings

- Shop name.
- Payment sources.
- Names (channels, expense categories: rename only).
- Customers (name / phone).
- Currency symbol.
- Backup (export / restore file + daily auto-backup).
- Export CSV.
- Theme: System / Light / Dark.
- Clear all data (double confirm).
- About.

### 6.9 First run (one step)

- Welcome.
- Currency symbol.
- Where do you keep money? Quick-add Cash / Bank / Mobile wallet + custom.
- Initial source with opening balance.
- **Start**.
- At least one payment source is required. If preferences fail to load, fall
  back to defaults and open the app.

---

## 7. Required states

Every content screen must implement all four states:

1. **Loading** — skeleton or progress indicator.
2. **Empty** — icon + one sentence + one primary action. Never a dead end.
3. **Filtered-empty** — explain that filters hid the data + **Clear filters**.
4. **Error** — plain message + **Retry**.

No screen may be blank.

---

## 8. Sale flow rules (cart)

- One scrolling form. **Add item** opens a product picker sheet with Recent /
  Top-sold chips, search, stock, and multi-select.
- Adding a product already in the cart raises its quantity; one line per
  product.
- Each line has an editable price. Below list = **Discount** tag; below cost =
  red warning.
- Selling above stock is allowed with an inline warning.
- Live profit per line and in the sticky summary.
- Save requires at least one line. Customer is required only when not paid in
  full.
- The cart survives rotation/backgrounding. Leaving with items asks
  "Discard sale?".
- Quick Sell: one-line sheet with qty, price, payment source, and **Confirm**.
  "Add more items" carries the line into the full form.
- Edit sale reopens the cart. Removing a line restores its stock; changing qty
  applies the difference.
- The receipt lists every line, total, paid, and due. It never shows cost or
  profit.
- Use `ListView.builder` and stay smooth with 50+ lines.

---

## 9. Do and don't

**Do**

- Lead with big money numbers and quiet labels.
- Keep one primary action per screen, at the bottom.
- Use plain-language labels.
- Warn inline; confirm destructive actions and offer Undo where reversible.
- Use tabular figures for money.

**Don't**

- Use gradients, blur, shadows, emoji icons, or custom nav bars.
- Hide core features.
- Use accounting jargon.
- Use more than five tabs.
- Expose cost or profit on a customer receipt.

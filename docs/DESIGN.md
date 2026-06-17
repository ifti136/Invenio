# Invenio — Visual Design Specification

---

## Design Language

**Name:** Liquid Glass  
**Personality:** Dark, luminous, premium. A business tool that feels expensive. Like a glass instrument panel lit from behind.  
**Mood:** Deep night sky with aurora borealis visible through frosted glass surfaces.

---

## The Background — Aurora Backdrop

The background is the soul of the app. It is **always visible** through every screen, every panel, every sheet.

### Dark Mode (default)
Three animated aurora waves float continuously and slowly behind all content. The waves never stop moving — they breathe. Very slow undulation, roughly 10–26 second cycles per wave.

**Background gradient base (three layers blended):**
- Deep navy: `#0B1026`
- Dark slate blue: `#1B2735`
- Deep indigo-violet: `#2C1E50`

**Wave colors:**
- Wave 1 — Teal: `#1D9E75` (same as accent)
- Wave 2 — Indigo: `#534AB7`
- Wave 3 — Magenta-violet: `#B987FF`

The waves occupy roughly the lower 40% of the screen height at their base, with crests extending up to ~22% of screen height. The result: the upper portion of the screen is deep dark navy. The lower portion glows with shifting teal, indigo, and violet light.

### Light Mode
Same three waves, same movement. Background shifts to warm cream tones:
- Warm ivory: `#F6F2EC`
- Warm sand: `#EFE6DA`
- Pale lavender: `#E8D9E8`

The aurora waves use the same teal/indigo/magenta colors but appear softer and more pastel against the light ground.

---

## Glass Surface System

All UI panels, cards, nav bars, dialogs, and sheets are **glass** — not opaque. The aurora always bleeds through.

### Standard GlassPanel
- Frosted/blurred background (backdrop blur ~18px)
- Fill: white at 14% opacity (dark mode) / 22% opacity (light mode)
- Border: 1px gradient border  
  - Top-left corner: white at 30% opacity (dark) / 55% (light)  
  - Bottom-right corner: teal `#1D9E75` at 18% opacity (dark) / 10% (light)
- Corner radius: 20px (default)
- No shadow, no elevation

### Frosted GlassPanel (`isFrostedGlass: true`)
Same as above but with additional frosted opacity layer at 10% (dark) / 8% (light). Used for the nav bar and dialogs — slightly more opaque to ensure legibility.

### GlassTextField
- Wraps in a glass panel with radius 14px, blur 14px, **not frosted**
- No visible border by default — the glass fill defines it
- On focus: prefix icon color shifts to primary teal `#1D9E75`
- On error: prefix icon and floating label turn danger red `#E24B4A`
- Text cursor: teal `#1D9E75`
- Floating label: teal when focused, error red on validation failure
- Hint text: white at ~60% opacity (dark mode)

---

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Accent / Primary | `#1D9E75` | Buttons, active nav, focus rings, selected states |
| Warning | `#EF9F27` | Low stock badges, due payment status, amber alerts |
| Danger | `#E24B4A` | Out-of-stock, below-cost alerts, delete actions, negative profit |
| Info | `#4F8AF0` | Est. profit in sale form |
| Facebook | `#1877F2` | Facebook platform indicator |
| Offline | `#534AB7` | Offline platform indicator |
| Success | `#1D9E75` | Same as accent — paid status, positive profit, in-stock |

---

## Typography

Material 3 default type scale. All weights and sizes follow the theme:

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| headlineSmall | ~24px | 700 | Product name on detail screen |
| titleLarge | ~22px | 700 | Screen titles in custom AppBars (Products, Sales) |
| titleMedium | ~18px | 600 | Section headers, sheet titles |
| titleSmall | ~14px | 600 | Panel section labels, stat headers |
| bodyMedium | ~14px | 400 | List item body, descriptions |
| bodySmall | ~12px | 400 | Subtitles, dates, secondary info |
| labelSmall | ~11px | 400–600 | Stat card labels, badge text |

---

## App Shell

### Status Bar
Transparent. Icons adapt to brightness — white in dark mode, dark in light mode.

### Bottom Navigation Bar
The nav bar sits at the **bottom of the screen**, anchored to the bottom safe area. It has a visually "floating" glass style — rounded corners and horizontal margins give it a pill-like appearance — but it is always pinned to the bottom edge, not hovering above content.

**Appearance:**
- Horizontally: 12px margin left and right from screen edges (does not span full width)
- Vertically: 8px gap above the bottom safe area edge
- Height: 76px
- Corner radius: 22px
- Background: frosted GlassPanel — the aurora glows through it
- Subtle gradient border (glass border system)
- Screen body content extends behind the nav bar (`extendBody: true`) so the aurora is visible through the glass even at the bottom

**Tab items — 6 tabs:**
1. Dashboard (grid icon)
2. Products (box/inventory icon)
3. Sales (receipt icon)
4. Expenses (wallet icon)
5. Reports (bar chart icon)
6. BFMS (finance/wallet icon)

**Tab states:**
- Selected: icon + label in teal `#1D9E75`, indicator is teal at 22% opacity (dark) / 18% (light) — a soft pill behind the icon
- Unselected: icon + label in `onSurfaceVariant` — muted grey-white in dark mode
- Label: 12px, weight 600 selected / 500 unselected

### AppBar (per-screen)
- Fully transparent, no elevation, no background fill
- Title: 20px, weight 600, `onSurface` color
- Left padding: 20px
- No scroll-under elevation change
- Action icons: `onSurface` color

---

## Screen-by-Screen Visual Spec

---

### 1. Dashboard Screen

**AppBar:** "Dashboard" title, no actions.

**Body:** Single `ListView` with 16px horizontal padding, 8px top padding, 24px bottom padding. The aurora shows behind everything.

#### Stat Grid Panel
Glass panel, padding 16px all sides.

Header: "Today" — 14px, weight 600.

Two rows of two stats, each stat is a column:
- Row 1: **Sales** (shopping bag icon, teal) | **Revenue** (trending up icon, teal)
- Row 2: **Gross Profit** (account balance icon, warning amber) | **Net Profit** (savings icon, teal if positive / danger red if negative)
- Row 3 (half-row): **Due** (pending actions icon, danger red) | empty half

Each stat item:
- Icon: 18px, colored
- Label: 12px, slightly transparent, colored to match icon
- Value: 14px, bold, colored to match icon

#### Platform Breakdown Panel
Glass panel, padding 16px, below stat grid with 16px gap.

Header: "Platform Breakdown" — 14px, weight 600.

Two rows:
- **Facebook row:** blue dot `#1877F2` + "Facebook" label + profit value (bold) + percentage (blue, small)
- **Offline row:** teal dot + "Offline" label + profit value (bold) + percentage (teal, small)

Below both rows: horizontal progress bar showing Facebook share vs Offline share. Bar height 8px, rounded ends, indigo-purple for Facebook portion, teal background for Offline.

#### Low Stock Panel (conditional — only if any products below threshold)
Glass panel, padding 16px, 16px gap below platform section.

Header row: amber warning icon (18px) + "Low Stock (N)" — weight 600.

Each low-stock product shown as a row:
- **ProductTile** on the left (see Product Tile spec below)
- **[Sell] button** on the right — FilledButton.tonal, small, point-of-sale icon + "Sell" text

---

### 2. Product List Screen

**AppBar:** Large custom title "Products" (22px, weight 700) pinned. "+" add icon action (top right).

**Stat Strip** (16px padding panel, glass):
Four pill stats side by side:
- **Products** (count) — teal, 18px bold
- **Low** (count) — amber, 18px bold
- **Out** (count) — red, 18px bold
- **Stock value** (formatted money) — teal, 13px bold (smaller because money string is long)

Each pill has its colored value on top, muted label below (11px).

**Filter Chips Row** (16px padding, scrollable horizontal):
Three `ChoiceChip` options: "All" | "Low stock" | "Out of stock"
- Selected chip: teal-tinted background, teal border, teal text bold
- Unselected: near-transparent, muted border, muted text

**Search Field** (16px padding, GlassTextField):
- Search icon prefix
- Hint: "Search by name…"
- Full width, glass panel wrapping

**Product List** (no padding — tiles are full-width):
Separated by 0.5px dividers, `onSurfaceVariant` at 12% opacity, indented 70px from left.

#### Product Tile
Each tile: 16px horizontal, 12px vertical padding.

Left: **Avatar circle** — 46×46px, rounded 12px, teal at 12% opacity background, teal first-letter of product name (18px, bold, teal).

Middle column:
- Product name: 15px, weight 600, max 1 line, ellipsis
- Below name: cost price (12.5px, muted) + StockBadge (compact, inline)

Right: 
- If `alertEnabled = false`: muted bell-off icon (18px) before chevron
- Chevron right icon, muted

#### StockBadge (compact, inline)
Pill shape, 8px horizontal / 3px vertical padding, 999px radius:
- **In stock:** green `#1D9E75` tinted background (18% opacity), green text "In stock", green border (35% opacity)
- **Low:** amber `#EF9F27` tinted background, amber text "Low", amber border
- **Out:** red `#E24B4A` tinted background, red text "Out", red border

Font: 11px, weight 600.

**Empty state** (if no products): centered icon + title + subtitle. No action button if filter active, "Tap + to add" message if truly empty.

---

### 3. Product Detail Screen

**AppBar:** "Product" title. Edit (pencil) icon action top right.

**Hero Panel** (glass, 18px padding):
- Product name: 24px, weight 700 (headlineSmall)
- Note (if exists): 13px, muted, below name
- 14px gap
- Three metric columns: **Cost** | **Stock** | **Alert at**
  - Each: value on top (17px, bold), label below (11.5px, muted)
- 14px gap
- Bottom row: **StockBadge** (large, not compact) on left | **[+ Restock]** filled button (teal, add icon) on right

**"Recent sales" header** — 16px bold, outside glass panel.

**Recent Sales Panel** (glass, 6px vertical padding):
List of `SaleListItem` rows, dividers between them (0.5px, muted, indented 70px).

#### SaleListItem
42×42px status avatar (left):
- Paid: green background (15% tint), green check-circle icon
- Due: amber background (15% tint), amber clock icon

Middle column:
- "N × ৳price • date" — 12.5px, muted
- (If showing on product detail, product name is omitted)

Right: total money — 15px, bold.

**"Stock movements" header** — 16px bold.

**Movements Panel** (glass, 6px vertical padding):
List of `StockMovementItem` rows.

#### StockMovementItem
36×36px colored avatar (left), radius 10px:
- Positive qty (restock/initial): green tint bg, green down-arrow icon
- Negative qty (sale): red tint bg, red up-arrow icon

Middle column:
- Type label: 14px, weight 600 ("Initial stock" / "Restock" / "Sale" / "Adjustment")
- Date + time: 12px, muted
- Note (if exists): 12.5px, muted, italic

Right: qty with sign — 15px, bold, colored (green if +, red if −).

---

### 4. Product Form Screen (Add / Edit)

**AppBar:** "Add Product" or "Edit Product". In edit mode: delete (trash outline) icon action top right.

**Main Glass Panel** (16px padding, one card for all fields):
Fields stacked with 12px gaps:
1. **Name** — GlassTextField, label "Name", hint "e.g. Wireless mouse"
2. **Cost price (৳)** — GlassTextField, numeric decimal, label "Cost price (৳)"
3. **Current/Initial stock** — GlassTextField, numeric, label adapts to mode
4. **Low-stock alert at** — GlassTextField, numeric, label "Low-stock alert at", hint "5"
5. **Alert toggle row** — label "Low-stock alerts" (14px) + subtitle text (12px muted: "Banner & popup enabled" or "Visual badge only (no banner)") on left, Material Switch on right (teal when on)
6. **Note** — GlassTextField, multiline (1–3 lines), label "Note (optional)", hint "SKU, supplier, location…"

**Save button** (full width, 16px vertical padding, 16px top margin):
- Filled teal button
- Label: "Add product" or "Save changes"
- Loading state: 20×20px white circular progress indicator

**Delete button** (edit mode only, below save, text button, red):
- Label: "Delete product"

---

### 5. Sale List Screen (Grid Design)

**AppBar:** "Sales" title (22px, weight 700). "+" icon action (opens full form).

**"Active Products" section label** — 13px, weight 600, muted, 16px padding.

#### Product Sell Card
Glass panel, 4px vertical margin, 16px horizontal margin, 14px padding, `isFrostedGlass: true` when in-stock.

Left: product info column:
- Row: product name (15px, weight 600, max 1 line) + StockBadge (compact, inline, 6px left gap)
- Below: "Cost ৳X | Est. profit +৳Y/unit" — 12px, muted

Right: **[Sell ▶] button** — FilledButton.tonal, point-of-sale icon (18px) + "Sell" text, 14px horizontal padding. **Disabled + entire card at 45% opacity** when out of stock.

**"Out of Stock" section label** — same style as "Active Products", shown only if any out-of-stock products exist.

**Discounted Sales Glass Panel** (12px padding, 16px margin all sides):
Tappable row at top:
- Amber offer-tag icon (20px) + "Log discounted sale" text (amber, weight 600) + chevron right (muted)

If discounted sales exist: divider + up to 5 `_DiscountedSaleRow` items.

#### DiscountedSaleRow
Two columns:
- Left: "N × ৳price" (bold) above "Normal ৳X → Discount ৳Y" (12px, muted)
- Right: check-circle (green, 18px) if paid, clock (amber, 18px) if due

**"Full sale form" button** (outlined, add icon, full width, 16px margin, 24px bottom padding):
Label: "Full sale form"

---

### 6. Sale Form Screen (Add / Edit)

**AppBar:** "Log Sale" or "Edit Sale".

**Product Panel** (glass, 16px padding):
- "Product" label (12px, weight 600, muted) above picker
- **Add mode:** dropdown showing all products with stock count in parentheses
- **Edit mode / pre-selected:** locked display row — lock outline icon + product name (15px, bold) + "Stock: N" (12px, muted, right side)

**Details Panel** (glass, 16px padding):
- Row: **Quantity** field (1/3 width) | **Selling price (৳)** field (2/3 width)
- "Last sold at ৳X" hint below price (12px, muted) — add mode only when last price exists
- **Platform toggle** (label "Platform" + animated toggle buttons: "Facebook" | "Offline")
- **Payment toggle** (label "Payment" + animated toggle buttons: "Paid" | "Due")
- **Customer** GlassTextField (optional, person outline icon)

**Toggle button style (platform/payment):**
Each option is an animated container, equal width, 8px vertical padding, center-aligned text:
- Selected: teal at 18% opacity background, teal border (55% opacity), teal text (weight 700, 13px)
- Unselected: white at 4% opacity background, muted border, neutral text (weight 500, 13px)
- Transition: 160ms animation

**Summary Panel** (glass, 14px padding — only shown when total computable):
Two metrics side by side:
- **Total:** 18px bold, teal `#1D9E75`
- **Est. profit:** 18px bold, info blue `#4F8AF0` (positive) or danger red (negative)

**Save button:** full width filled teal, "Record sale" or "Save changes".

---

### 7. Quick Sell Sheet (Bottom Sheet)

Slides up from bottom. Glass panel with 28px top radius, 12px all-side margin, 20px horizontal / 18px top / 24px bottom padding.

**Drag handle:** 40×4px pill, `onSurfaceVariant` at 30% opacity, centered, 14px bottom margin.

**Header row:** "Sell — [Product Name]" (17px, weight 700) left | close (×) icon button right.

**Subtitle:** "Stock available: N" (13px, muted), 4px below header.

16px gap, then:

**Two-field row:** Quantity (1/3) | Selling price (2/3), GlassTextFields.

**Platform segmented row:** "Platform" label (13px) + SegmentedButton (compact): Facebook | Offline.

**Payment segmented row:** "Payment" label (13px) + SegmentedButton (compact): Paid | Due.

**Customer** GlassTextField (optional).

**Summary + Confirm row** (flush glass panel, 12px padding):
Left column:
- "Total: ৳X" — 15px, bold, teal
- "Profit: +৳X" or "-৳X" — 13px, success green or danger red

Right: **[Confirm]** filled teal button.

---

### 8. Discount Sheet (Bottom Sheet)

Same glass panel container as Quick Sell Sheet.

**Header:** "Discounted Sale" (17px, bold) + close icon.

**Product picker button** (tappable glass panel, 14px radius, 14px padding):
Shows selected product name or "Select product…" (muted placeholder style) + dropdown arrow icon.

**Two-field row:** Quantity | Normal price (৳)

**Discount price** field (full width GlassTextField).

**Platform segmented row** + **Payment segmented row** (same as Quick Sell).

**Customer** GlassTextField.

**Summary + Confirm row** (flush glass panel):
Left:
- "Discount: -৳X" — 15px, bold, amber `#EF9F27`
- "Margin loss: -৳X" — 13px, danger red (or muted if no loss)

Right: **[Confirm]** filled teal button.

---

### 9. Expense List Screen

**AppBar:** Pinned, "Expenses" (22px, 700). "+" icon action top right.

**Date Filter Bar** (glass panel, 16px margin, scrollable horizontal chip row):
- Label "Period" (12px, weight 600, 56px wide, muted)
- Chip options: "All time" | "Today" | "This week" | "This month" | "Last 30 days" | "Custom…"
- Chip style: pill shape, 12px horizontal / 6px vertical padding, 999px radius
  - Selected: teal 18% background, teal border (50%), teal text bold
  - Unselected: white 4% background, muted border, neutral text

**Stats Strip** (glass panel, 14px symmetric padding):
Two columns:
- **Entries** count — 18px, bold, teal
- **Total** money — 13px, bold, amber (smaller because money strings are longer)

**List items** — full width, separated by 0.5px dividers indented 70px.

#### Expense Row (via PopupMenuButton)
Left: 40×40px circular avatar — teal at 12% background, teal category icon (20px):
- Ads: megaphone/campaign icon
- Delivery: truck icon
- Packaging: box/inventory icon
- Misc: more-horiz icon

Middle:
- Category name: 15px, weight 600
- Note (if exists): 12px, muted, max 1 line ellipsis — otherwise shows date in same muted style

Right column:
- Amount: 15px, bold, amber `#EF9F27`
- Date (if note shown above): 11px, muted below amount

Tapping row opens popup menu: "Edit" | "Delete" (red text).

---

### 10. Expense Form Screen (Add / Edit)

**AppBar:** "Add Expense" or "Edit Expense". Edit mode: delete (trash) icon top right.

**Amount Panel** (glass, 16px padding):
GlassTextField — label "Amount (৳)", hint "0.00", money icon prefix, decimal input.

**Category Panel** (glass, 16px padding):
"Category" label (12px, weight 600, muted).
Four equal-width animated toggle buttons in a row (6px gaps):
- 📢 Ads | 🚚 Delivery | 📦 Packaging | 🗂 Misc
- Same animated container style as platform/payment toggles in sale form

**Note Panel** (glass, 16px padding):
GlassTextField — label "Note (optional)", hint "What was this for?", edit-note icon, 2-line max.

**Date Panel** (glass, 16px padding, tappable):
InputDecorator showing formatted date, calendar icon (teal). Tapping opens system date picker.

**Action buttons row:**
- Edit mode: [Delete] outlined button (red, 1/3 width) + [Save changes] filled teal (2/3 width)
- Add mode: [Record expense] filled teal (full width), 16px vertical padding

---

### 11. Reports Screen

**AppBar:** "Reports" title, no actions.

**Month/Year Selector** (glass panel, 12px horizontal / 8px vertical padding):
- Daily + Products tab: shows month/year ("January 2026")
  - Chevron left | "Month Year" centered text | Chevron right
  - Export icon (teal, download icon) appears at far right only on Daily tab
- Monthly tab: shows year only ("2026")
  - Same chevron nav pattern

**Tab Selector** (glass panel, 4px padding, wraps SegmentedButton):
Three segments: "Daily" | "Monthly" | "Products"
Compact visual density.

**Summary Strip** (glass panel, 12px padding, three equal columns):
- **Revenue** — formatted money, centered
- **Profit** — formatted money, colored danger red if negative
- **Expenses** — formatted money

Labels: 10px above values (labelSmall).  
Values: 14px bold (titleSmall).

**Chart/Table Toggle** (right-aligned TextButton.icon):
- Shows chart: "Show Table" + table-chart icon
- Shows table: "Show Chart" + bar-chart icon

**AnimatedSwitcher** (250ms crossfade):

#### Bar Chart (fl_chart)
200px height, no border, no grid.
- Daily chart: one group per day, two bars per group (revenue = teal at 40% / profit = teal solid), width 8px each, rounded top corners 4px
- Yearly chart: same but 12px wide bars
- X-axis labels: day numbers or month abbreviations, 10px, muted, 6px top padding

#### Data Table
Glass panel, 12px padding.
Header row: column names, 11px weight 600, 70% opacity.
Divider: 16px height.
Data rows: 4px vertical padding per row, 12px text.
Profit column: teal if positive, red if negative.

#### Product Report Table
Glass panel, 12px padding.
Columns: Product (flex 3) | Qty (flex 1, center) | Revenue (flex 2, right) | Profit (flex 2, right).
Header: 11px weight 600.
Rows: 6px vertical padding, 14px body text. Profit: teal/red.

**Empty state:** centered muted text inside glass panel, 32px padding.

---

### 12. Glass Dialog (Modal)

Triggered for: confirms, errors, below-cost warnings, delete confirmations.

**Backdrop:** black at 35% opacity overlay.

**Dialog container:** GlassPanel (frosted), radius 24px, 20px horizontal / 22px top / 16px bottom padding, max ~85% screen width, centered.

**Title:** 20px, weight 600, `onSurface`.

**Message:** 14px, `onSurfaceVariant`, 8px below title.

**Custom content:** 12px below message/title.

**Actions row** (right-aligned, 16px top gap):
TextButton actions, 14px weight 600, 14px horizontal / 10px vertical padding:
- Default: `onSurfaceVariant` color
- Primary: teal `#1D9E75`
- Destructive: red `#E24B4A`

---

### 13. Restock Sheet (Bottom Sheet)

Glass panel, 28px top radius, 12px margin, 20px / 18px / 20px padding.

**Drag handle** (same as Quick Sell Sheet).

**Header:** "Restock — [Product Name]" (20px, weight 700).  
**Subtitle:** "Current stock: N" (13px, muted).

16px gap, then:
- **Quantity to add** GlassTextField (autofocused), numeric, hint "e.g. 10"
- **Note** GlassTextField (optional), hint "Supplier, batch, etc."

**Button row** (18px top gap):
- [Cancel] outlined button (1/2 width, 14px vertical padding)
- [Add stock] filled teal button (1/2 width, 14px vertical padding, 10px gap between)

---

### 14. Product Filter Sheet (Bottom Sheet)

Glass panel, 28px top radius, 12px margin, 20px / 18px / 20px padding.

**Drag handle.**

**Title:** "Filter by product" (20px, weight 700).

**Search field** (GlassTextField, autofocused, search icon, hint "Search products…").

**Scrollable list** (max 360px height):
- First item always: clear/X icon + "All products" — selected if no product filter active
- Each product: inventory icon + product name + "Stock: N" subtitle
- Selected item uses theme selection color

---

## Shared Visual Patterns

### Empty States
Centered in remaining space, no glass panel:
- Large muted icon: 64px
- Title: titleMedium, weight 600
- Message: bodyMedium, muted
- Optional: filled teal action button (only on truly empty states, not filtered-empty)

### SnackBars
Floating, rounded 14px, `inverseSurface` background, `onInverseSurface` text.
Amber variant for warnings (95% opacity amber background, white text), 5 second duration.

### Loading States
- Full screen loading: `CircularProgressIndicator` centered
- Button loading: 20×20px `CircularProgressIndicator` (strokeWidth 2, white) replaces button label
- Sheet loading: same small indicator inline

### Form Validation Errors
Red error text below the GlassTextField. The text field's prefix icon and floating label turn red. No red border (border is `InputBorder.none`).

---

## Motion & Animation

| Element | Animation |
|---------|-----------|
| Aurora waves | Continuous sine-wave undulation, 10/18/26s cycles |
| Toggle buttons (platform/payment/category) | 160ms container color + border transition |
| Chart ↔ Table switch | 250ms AnimatedSwitcher crossfade |
| Bottom sheets | System default slide-up from bottom |
| Dialog | System default scale-in fade |
| Stock badge | Static (no animation) |
| SnackBar | System slide-up from bottom |
| FAB / buttons | System ripple on tap |

---

## Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Between badge and text, tight rows |
| sm | 8px | Between icon and label, row internal gaps |
| md | 12px | Between fields in form, panel internal gaps |
| lg | 16px | Screen edge padding, between major panels |
| xl | 24px | Bottom padding for scroll lists |
| 2xl | 32px | Empty state padding |

---

## Platform-Specific Colors (Indicators)

| Platform | Color | Usage |
|----------|-------|-------|
| Facebook | `#1877F2` (Facebook blue) | Platform badge, platform breakdown dot |
| Offline | `#534AB7` (indigo-violet) | Platform badge, platform breakdown dot |

These appear as small colored text labels or dots on sale tiles and dashboard breakdown — never as filled buttons (teal is reserved for actions).

---

## Pop-up & Sheet Surface Rules (v0.6.8–v0.6.9)

These rules apply **on top of** the glass surface system above. They
were added to fix on-device complaints about translucent pop-ups and
sheets that were either covered by the custom bottom nav or sized to
the whole screen instead of to their content.

### `GlassPanel.solid: true` for pop-ups

When a `GlassPanel` is used as a pop-up surface (dialog, bottom sheet,
modal product picker), pass `solid: true` instead of the default
`noBlur: true` or `isFrostedGlass: true`. The `solid` flag swaps the
gradient for a near-opaque fill:

| Mode | dark | light | border |
|---|---|---|---|
| default `isFrostedGlass: true` | `Colors.white.withOpacity(0.14)` | `Colors.white.withOpacity(0.22)` | white → teal 30%/18% |
| `noBlur: true` | `Colors.white.withOpacity(0.04)` | `Colors.white.withOpacity(0.06)` | white → teal 30%/18% |
| `solid: true` | `scheme.surface.withOpacity(0.92)` | `scheme.surface.withOpacity(0.95)` | `scheme.outline.withOpacity(0.20)` 1px |

`solid: true` implies `noBlur: true` behaviour. The visual effect is
a flat, readable panel that no longer bleeds the aurora through it.

**Where to use:**

- `glass_dialog.dart` — dialog panel
- `quick_sell_sheet.dart` — outer panel
- `discount_sheet.dart` — outer panel + product picker panel
- `product_picker_sheet.dart` — outer panel
- `sale_form_screen.dart` — product panel, details panel, total panel

**Where NOT to use:**

- Body / form / sheet content panels (use plain `GlassPanel` or
  `GlassPanel(noBlur: true)`)
- Bottom nav, top app bar, navigation chrome

### Modal barrier opacities

| Modal | Barrier color |
|---|---|
| `showGlassDialog` | `Colors.black.withOpacity(0.6)` |
| `showModalBottomSheet` (all 5 callers) | `Colors.black.withOpacity(0.5)` |

These dim the background enough to focus attention on the pop-up
without making the screen feel blacked-out.

### Bottom-sheet positioning (replaces `useSafeArea: true`)

`showModalBottomSheet` is called with `useSafeArea: false` (dropped in
v0.6.8) and the builder is wrapped in
`Column(mainAxisSize: MainAxisSize.min, children: [Padding(bottom: max(viewInsets.bottom, padding.bottom + kBottomNavHeight + 8), child: Sheet)])`.

- `Column(mainAxisSize: min)` makes the sheet intrinsic-height so the
  modal positions it at the screen bottom (not stretched).
- `max(viewInsets.bottom, ...)` clears the custom 76-px
  `bottomNavigationBar` when the keyboard is closed and the keyboard
  when it's open (whichever is larger).
- The 8-px gap above the nav keeps the sheet from kissing the nav.

Applied to all 5 `showModalBottomSheet` callers: `quick_sell_sheet`,
`discount_sheet`, `product_picker_sheet`, `restock_sheet`,
`product_filter_sheet`.

### Shared product picker

`ProductPickerSheet` (`lib/features/sales/widgets/product_picker_sheet.dart`)
is the single source of truth for "pick a product" in a modal. Used
by both `discount_sheet` and the Log Sale form (which previously had
an inline `_ProductPickerSheet` and a read-only `Container` with a
`lock_outline` icon, respectively). The tile in the Log Sale form
is now tap-able in add mode — the product can be re-selected if the
user picked the wrong one.

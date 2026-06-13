# Architecture

A short, opinionated overview of the technical decisions behind Invenio, written
for a reviewer who wants to know *why* the codebase looks the way it does.
Pair this with [`CHANGELOG.md`](CHANGELOG.md) (what shipped) and
[`HISTORY.md`](HISTORY.md) (what broke and why).

---

## What this is

A solo-owner Flutter Android app for a small reseller. Tracks inventory, logs
sales, records expenses, and computes daily profit. No login. No cloud. One
user, one device, one local database. APK installs and works offline forever.

## Why offline-first

The target user is a single person running a small operation from their phone,
often in environments with poor connectivity (markets, customer homes,
warehouses). They are also the only person who will ever see the data, so a
backend would add latency, cost, and a privacy surface for no benefit. The
local SQLite database is the source of truth. A future cloud-sync layer is
possible (the schema is normalized for it) but is not on the roadmap for v1.

## Why Drift (SQLite) over Hive / Isar / shared_preferences

- **Typed queries** — schema is enforced at compile time via `drift_dev`
  codegen, so a typo in a column name is a build error, not a runtime crash.
- **Migrations are first-class** — `schemaVersion` + `onUpgrade` makes schema
  changes auditable and reversible. This is non-negotiable for a tool that
  holds financial data.
- **Reactive streams** — `select(...).watch()` emits a new `List<T>` whenever
  the underlying rows change, which pairs cleanly with Riverpod's
  `StreamProvider` and gives the UI live updates without polling.
- **SQL is the right tool** — profit reports, monthly aggregations, and
  top-N-by-profit queries are trivial in SQL and painful in a key-value store.

## Why Riverpod with codegen

- **Compile-time DI** — `@riverpod` annotation + `riverpod_generator` produces
  a typed provider per function, so the compiler catches missing overrides
  and dependency cycles.
- **No `BuildContext` for reads** — `ref.watch(provider)` works anywhere,
  which keeps repositories and services UI-agnostic and trivially testable.
- **Family providers** — `provider(family<int>)` for parameterised queries
  (sale by id, product by id) without manual `ChangeNotifier` plumbing.
- **`AutoDispose` by default** — the generator emits `AutoDispose*Provider`
  variants, so a provider is torn down when no one is watching. The
  `appDatabaseProvider` is the only one opted into `keepAlive: true`
  (the DB connection must outlive any single screen).

## Why go_router with `StatefulShellRoute.indexedStack`

- **Declarative routes** — deep links (`/products/:id/edit`) are first-class
  in the URL, which makes navigation easy to reason about and test.
- **`StatefulShellRoute.indexedStack`** keeps each of the 6 bottom-nav tabs
  mounted, so switching tabs doesn't lose scroll position or re-run
  providers. A plain `ShellRoute` rebuilds the child on every tab switch.
- **Nested routes** — `/products/:id` and `/products/:id/edit` are naturally
  expressed as parent/child `GoRoute`s.

## Why Liquid Glass (glass_kit + aurora_background)

- **Design language** — the app should feel like a premium business
  instrument, not a generic Material 3 admin panel. The aurora backdrop
  (three slow-moving colored waves behind every screen) gives the UI a
  consistent, recognizable personality.
- **All glass surfaces inherit the background** — every `GlassPanel`,
  `GlassTextField`, dialog, and bottom sheet blurs the aurora behind it.
  The whole app feels unified.
- **Trade-off acknowledged** — `glass_kit`'s `BackdropFilter` is
  GPU-expensive when stacked, and a `SizedBox.expand` quirk in the package
  produces 0×0 layouts in unbounded parents. We work around this with
  `GlassPanel(noBlur: true)` for body / form / sheet panels, and
  `GlassPanel(solid: true)` for pop-up surfaces that need to be readable
  against a bright aurora. See [`HISTORY.md`](HISTORY.md) for the
  regression history.

## Why no cloud sync (yet)

The user explicitly does not need it. Adding it would mean picking a backend
(Supabase was the original candidate), implementing auth or a device-pairing
flow, and resolving sync conflicts (last-write-wins is the only sane policy
for a single user). None of that is worth the complexity for a v1 used by
one person. The schema is designed so a future `synced_at` column + a
background uploader can be added without a data migration.

## Known trade-offs

| Trade-off | Detail | Doc |
|---|---|---|
| `libsqlite3.so` is a Linux CI prerequisite | Drift-backed tests fail at startup without it. Symlink trick works. | [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| `glass_kit` `BackdropFilter` headless quirks | Widget tests in `flutter test` produce compositing warnings. The app works on a real device. | [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| `aurora_background` continuous animation | Prevents `pumpAndSettle()` from settling. Use `pump(Duration)` with explicit duration. | [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| No multi-currency | All money is `REAL` (double) with 2-decimal display. | [`instructions/01_requirements.md`](instructions/01_requirements.md) §5 |
| No barcode / invoice / push notifications | Explicitly out of scope. | [`instructions/01_requirements.md`](instructions/01_requirements.md) §5 |

## Folder map (one-line purpose per directory)

```
tracker_app/
├── lib/
│   ├── main.dart              — entry point; wraps app in ProviderScope
│   ├── app.dart               — MaterialApp.router + aurora backdrop + theme
│   ├── router.dart            — go_router with StatefulShellRoute.indexedStack (6 tabs)
│   ├── core/
│   │   ├── background/        — AuroraBackdrop widget (Liquid Glass)
│   │   ├── theme/             — AppColors (design tokens) + AppTheme (Material 3)
│   │   ├── widgets/           — GlassPanel, GlassTextField, GlassDialog, etc.
│   │   ├── utils/             — formatters (money, date, quantity)
│   │   └── extensions/        — drift row → DateTime helpers
│   ├── db/
│   │   │   ├── app_database.dart  — drift database + Riverpod singleton provider
│   │   │   └── tables/            — 7 drift table definitions (schema v4)
│   ├── features/

│   │   ├── dashboard/         — today's stats, platform breakdown, low stock
│   │   ├── products/          — CRUD, restock, stock movements, product grid
│   │   ├── sales/             — log, filter, quick-sell, discounted sales
│   │   ├── expenses/          — log, filter, edit, delete
│   │   └── reports/           — daily/monthly/product charts, Excel export
│   ├── models/                — DTOs (DashboardSummary, DailySnapshot, etc.)
│   └── services/              — AlertService (sealed AppAlert), ExportService
├── test/                      — 8 unit + 7 widget test files; see REPORT.md
├── assets/icon/               — launcher icon source (invenio.png)
└── android/                   — Android Gradle config; min SDK 24
```

## What this doc is NOT

- Not a code-level spec — see [`instructions/03_code_specs.md`](instructions/03_code_specs.md).
- Not a phase log — see [`CHANGELOG.md`](CHANGELOG.md).
- Not a regression narrative — see [`HISTORY.md`](HISTORY.md).
- Not a visual spec — see [`DESIGN.md`](DESIGN.md).

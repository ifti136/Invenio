# AGENTS.md — Project instructions for AI agents

This file is read by opencode (and any other AI agent) at the start of every
session. Follow these instructions without prompting.

---

## Project overview

- **Invenio** is a Flutter Android app (lives in `tracker_app/`) for a single
  owner-operator small reseller to manage inventory, log sales, track expenses,
  and view profit analytics. Fully offline; no auth.
- **v1.3.1+4**, Schema v5 (9 tables). Min SDK 24. Flutter 3.24.4 / Dart
  3.5.4. Target Android.
- Tech: drift (SQLite), Riverpod (`@riverpod` codegen), go_router 15
  (`StatefulShellRoute.indexedStack` with 6 tabs), `glass_kit` +
  `aurora_background` (Liquid Glass theme), `fl_chart`, `syncfusion_flutter_xlsio`,
  `share_plus`, `flutter_launcher_icons`.
- **Documentation lives in [`docs/`](docs/README.md).** Start with
  [`docs/README.md`](docs/README.md) — it is the index. Key docs:
  [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) (tech choices),
  [`docs/CHANGELOG.md`](docs/CHANGELOG.md) (what shipped per phase +
  consolidated bug list), [`docs/HISTORY.md`](docs/HISTORY.md) (regression
  narrative), [`docs/VERSION_HISTORY.md`](docs/VERSION_HISTORY.md) (micro-version log),
  [`docs/DESIGN.md`](docs/DESIGN.md) (visual design),
  [`docs/instructions/`](docs/instructions/) (pre-implementation specs).
- The pre-refresh `docs/instructions/06_completion_status.md` is gone; its
  content has been folded into `CHANGELOG.md` and `HISTORY.md`.
- The pre-refresh `docs/BUG_REPORT.md`, `docs/error.md`,
  `docs/STATUS_AUDIT.md`, and `docs/REDESIGN.md` are kept for provenance and
  carry `SUPERSEDED` banners; their content is in `CHANGELOG.md` /
  `HISTORY.md`.
- Tests: 100 / 100 passing (see [`tracker_app/test/REPORT.md`](tracker_app/test/REPORT.md)).

---

## Conventions

- **Spec fidelity:** follow `docs/instructions/05_implementation.md` closely
  for standard features (products, sales, expenses, reports). For design
  decisions, prefer the existing widgets in `lib/core/widgets/`. For
  "what was built and why", prefer `docs/CHANGELOG.md` + `docs/HISTORY.md`.
- **Glass first:** all new `TextField` → use `GlassTextField`. All new
  dialogs/confirms → use `showGlassDialog()`. New floating glass surfaces →
  use `GlassPanel` or `GlassPanel.flush`. Do **not** introduce alternative
  blurred surfaces.
- **Solid pop-ups:** dialogs and bottom sheets that need to be readable
  against a bright aurora must use `GlassPanel(solid: true)`. Plain
  `GlassPanel(noBlur: true)` is for body / form / sheet panels; reserve
  `solid: true` for actual pop-up surfaces.
- **Sheet positioning:** `showModalBottomSheet` must use
  `max(viewInsets.bottom, kBottomNavHeight + 8)` for the bottom padding +
  `Column(mainAxisSize: MainAxisSize.min)` in the modal wrap + a 0.5
  barrier. `useSafeArea: true` is not used (it double-counts the system
  inset; the bottom-nav clearance above is the right knob).
- **Dialog action context:** `showGlassDialog` uses
  `actionsBuilder: (ctx) => [...]`. Inside the action `onPressed`, call
  `Navigator.of(ctx).pop(...)` on the dialog's `ctx` — **not** the outer
  caller `context`, which may resolve to a different `Navigator` (the
  most common failure mode: caller is inside a modal bottom sheet, and
  the action pops the sheet instead of the dialog).
- **Aurora is the background:** every screen inherits it; new screens must
  use `Scaffold` (transparent) or rely on the theme's
  `scaffoldBackgroundColor: Colors.transparent` — do not set an opaque
  background.
- **Placeholder policy:** when implementing a feature, replace the
  placeholder file in place (`features/<x>/<x>_screen.dart`). Do **not**
  create `*_v2.dart` side files. Do **not** keep the old placeholder
  around.
- **Naming:** `snake_case` files, `PascalCase` classes, `@riverpod` for
  provider generation, `part '<name>.g.dart'` for generated parts.
- **No comments** unless the user explicitly asks.
- **No new top-level deps** without asking. The `pubspec.yaml` is the
  contract; deps for glass (`glass_kit`, `aurora_background`), reports
  (`fl_chart`, `syncfusion_flutter_xlsio`, `share_plus`), and icons
  (`flutter_launcher_icons`) are already approved.

---

## Commit policy

After **any** set of file changes that completes a logical unit of work
(a phase, a feature, a bug fix, a docs sweep), commit and push. Do not
wait for the user to ask.

1. **Conventional commit format** (enforced):
   - Subject: `<type>(<scope>): <short summary>` in present tense, ≤72 chars.
   - Body (optional): 2-4 short paragraphs explaining the *what* and the
     *why*, with a bullet list of key additions/changes if useful.
   - Footer (optional): notes on deviations, verification status
     (`flutter analyze` results), or "Not yet verified on a device".

   **Types**: `feat` (new user-visible feature), `fix` (bug fix),
   `chore` (tooling, deps, configs), `docs` (docs only), `refactor`,
   `style` (whitespace/formatting only), `test`.

   **Scopes used in this project**:
   - `foundation` — drift schema, db wiring, router scaffold
   - `theme` — Liquid Glass (aurora, glass chrome, app_colors, app_theme)
   - `products` — product master
   - `sales` — sales log
   - `expenses` — expenses
   - `reports` — reports & export
   - `agent` — AGENTS.md / opencode workflow
   - `instructions` — specs in `docs/instructions/`
   - `repo` — gitignore, gradle, ci, repo-level config
   - `branding` — launcher icon, splash, app label, version (Phase 7.0)

2. **One logical change per commit.** Don't mix Phase 1 with Phase 1.5;
   don't mix a feature with an unrelated bug fix.

3. **`*.g.dart` files are committed alongside their source change.** Drift's
   `app_database.g.dart` and Riverpod's `*.g.dart` are part of the change
   set — `git add` them in the same commit.

4. **Pre-commit checklist** (run mentally before `git commit`):
   - `git status` — only intended files are staged.
   - `git diff --staged --stat` — diff is sensible and matches the commit message.
   - No secrets / API keys / `local.properties` / `key.properties`.
   - No stray files (lock files, editor temp files, `.~lock.*`).
   - `flutter analyze` re-run if Flutter is available; capture the result
     in the commit footer.

5. **Reporting**: in your final message, include the commit hash(es),
   branch, and remote URL. If pushing, confirm the push and report the
   pushed commits.

---

## Verification rules

- After any code change, run `flutter analyze` if Flutter is available
  in the environment. If it is **not** available, say so explicitly in the
  final message and tell the user what to run locally.
- For new Drift tables or schema changes, run
  `dart run build_runner build` (or the project's existing build_runner
  command). The generated `*.g.dart` files are committed-equivalent —
  include them in the same change set.
- For UI work, do not run on a device from this environment. Tell the user
  what to run (`flutter pub get && flutter run -d <device>`).
- For test runs, see [`tracker_app/test/REPORT.md`](tracker_app/test/REPORT.md)
  for the `libsqlite3.so` symlink trick and the `glass_kit` /
  `aurora_background` headless workarounds.

---

## Status symbols (used in `docs/CHANGELOG.md` and `docs/HISTORY.md`)

| Symbol | Meaning |
|--------|---------|
| ✅ | Done and verified |
| ⚠️ | Done but not fully verified (e.g. no device, or no analyzer available) |
| ⬜ | Not started |

When marking a task ✅ in a session that did not have analyzer / device
access, prefer ⚠️ + a note, and let the user upgrade to ✅ after they
verify locally.

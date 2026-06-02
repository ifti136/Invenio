# AGENTS.md — Project instructions for AI agents

This file is read by opencode (and any other AI agent) at the start of every session. Follow these instructions without prompting.

---

## MANDATORY: Update completion status after every build

After **any** set of file changes (edits, new files, deletions) made in this session:

1. Open `instructions/06_completion_status.md`.
2. Update the relevant phase table(s) to reflect what was completed in this session.
3. If a new design-system, infrastructure, or cross-cutting piece was added that does not fit an existing phase, add a new sub-section (e.g. `## Phase 1.5 — …`) with its own task table.
4. Update the **Folder Structure** block: add new files, remove deleted ones, mark each with its symbol (✅ / ⚠️ / ⬜).
5. Update the **Project State** table at the top with any new SDK / analysis / build / theme status line.
6. Update the **Generated:** date at the top to today if the change is substantive.
7. Save and report the diff in your final message to the user.

This is the canonical progress checklist. **Do not skip this step.** If you make changes and do not update the file, the next session will start from stale information.

---

## Project overview

- **Invenio** is a Flutter Android app (lives in `tracker_app/`) for a single owner-operator small reseller to manage inventory, log sales, track expenses, and view profit analytics. Fully offline; no auth.
- Spec / docs live in `instructions/`:
  - `01_requirements.md` — functional + non-functional requirements
  - `02_system_design.md` — architecture
  - `03_code_specs.md` — per-file code contracts
  - `04_scaffolding.md` — initial scaffold
  - `05_implementation.md` — **full code per file** (the active task spec for features)
  - `06_completion_status.md` — **live checklist** (update this after every build)
- Min SDK 24, Flutter 3.24.4 / Dart 3.5.4, target Android.
- State: drift (SQLite), Riverpod (`@riverpod` codegen), go_router (ShellRoute + 5 tabs).

---

## Conventions

- **Spec fidelity:** follow `05_implementation.md` closely for standard features (products, sales, expenses, reports). For design-system work (theming, glass, aurora), prefer the existing widgets in `lib/core/widgets/`.
- **Glass first:** all new `TextField` → use `GlassTextField`. All new dialogs/confirms → use `showGlassDialog()`. New floating glass surfaces → use `GlassPanel` or `GlassPanel.flush`. Do **not** introduce alternative blurred surfaces.
- **Aurora is the background:** every screen inherits it; new screens must use `Scaffold` (transparent) or rely on the theme's `scaffoldBackgroundColor: Colors.transparent` — do not set an opaque background.
- **Placeholder policy:** when implementing a feature, replace the placeholder file in place (`features/<x>/<x>_screen.dart`). Do **not** create `*_v2.dart` side files. Do **not** keep the old placeholder around.
- **Naming:** `snake_case` files, `PascalCase` classes, `@riverpod` for provider generation, `part '<name>.g.dart'` for generated parts.
- **No comments** unless the user explicitly asks.
- **No new top-level deps** without asking. The `pubspec.yaml` is the contract; deps for glass (`glass_kit`, `aurora_background`) and reports (`fl_chart`, `syncfusion_flutter_xlsio`, `share_plus`) are already approved.

---

## MANDATORY: Commit to GitHub after every build

After **any** set of file changes that completes a logical unit of work (a phase, a feature, a bug fix, a docs sweep), you **must** commit and push. Do not wait for the user to ask.

1. **Conventional commit format** (enforced):
   - Subject: `<type>(<scope>): <short summary>` in present tense, ≤72 chars.
   - Body (optional): 2-4 short paragraphs explaining the *what* and the *why*, with a bullet list of key additions/changes if useful.
   - Footer (optional): notes on deviations, verification status (`flutter analyze` results), or "Not yet verified on a device".
   - **Types**: `feat` (new user-visible feature), `fix` (bug fix), `chore` (tooling, deps, configs), `docs` (docs only), `refactor`, `style` (whitespace/formatting only), `test`.
   - **Scopes used in this project**:
     - `foundation` — drift schema, db wiring, router scaffold
     - `theme` — Liquid Glass (aurora, glass chrome, app_colors, app_theme)
     - `products` — product master
     - `sales` — sales log
     - `expenses` — expenses (future)
     - `reports` — reports & export (future)
     - `agent` — AGENTS.md / opencode workflow
     - `instructions` — specs in `instructions/`
     - `repo` — gitignore, gradle, ci, repo-level config
2. **One logical change per commit.** Don't mix Phase 1 with Phase 1.5; don't mix a feature with an unrelated bug fix.
3. **`*.g.dart` files are committed alongside their source change.** Drift's `app_database.g.dart` and Riverpod's `*.g.dart` are part of the change set — `git add` them in the same commit.
4. **Pre-commit checklist** (run mentally before `git commit`):
   - `git status` — only intended files are staged.
   - `git diff --staged --stat` — diff is sensible and matches the commit message.
   - No secrets / API keys / `local.properties` / `key.properties`.
   - No stray files (lock files, editor temp files, `.~lock.*`).
   - `flutter analyze` re-run if Flutter is available; capture the result in the commit footer.
5. **Reporting**: in your final message, include the commit hash(es), branch, and remote URL. If pushing, confirm the push and report the pushed commits.

---

## Verification rules

- After any code change, run `flutter analyze` if Flutter is available in the environment. If it is **not** available, say so explicitly in the final message and tell the user what to run locally.
- For new Drift tables or schema changes, run `dart run build_runner build` (or the project's existing build_runner command). The generated `*.g.dart` files are committed-equivalent — include them in the same change set.
- For UI work, do not run on a device from this environment. Tell the user what to run (`flutter pub get && flutter run -d <device>`).

---

## Status symbols (used in `06_completion_status.md`)

| Symbol | Meaning |
|--------|---------|
| ✅ | Done and verified |
| ⚠️ | Done but not fully verified (e.g. no device, or no analyzer available) |
| ⬜ | Not started |

When marking a task ✅ in a session that did not have analyzer / device access, prefer ⚠️ + a note, and let the user upgrade to ✅ after they verify locally.

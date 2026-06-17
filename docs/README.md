# Invenio — Documentation

Invenio is a single-owner Flutter Android app for managing inventory, logging
sales, tracking expenses, and viewing profit analytics — fully offline, no
auth, no cloud sync. This directory is the canonical documentation for the
project.

## Project state (v1.3.1+4, Schema v5)

| Aspect | Detail |
|--------|--------|
| Flutter SDK | 3.24.4 · Dart 3.5.4 |
| Target | Android (min API 24) |
| Database | drift (SQLite) — schema v5 (9 tables) |
| State | Riverpod (codegen) |
| Routing | go_router 15 (`StatefulShellRoute.indexedStack`) |
| Theme | Liquid Glass — `glass_kit` + `aurora_background` |
| Charts | fl_chart 0.69 |
| Export | syncfusion_flutter_xlsio 27.1.55 + share_plus |
| Tests | 100/100 passing · `flutter analyze` 0 errors |
| Version | `1.3.1+4` (build 4) |

## If you want to …

| You want to … | Read |
|---|---|
| Understand the key tech choices in 5 minutes | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| See what was built, in order, with one bullet per phase | [`CHANGELOG.md`](CHANGELOG.md) |
| See the full micro-version history from initial build to current | [`VERSION_HISTORY.md`](VERSION_HISTORY.md) |
| Understand what broke, why, and how it was fixed | [`HISTORY.md`](HISTORY.md) |
| Look up a color, a spacing token, a screen layout | [`DESIGN.md`](DESIGN.md) |
| Read the original functional requirements | [`instructions/01_requirements.md`](instructions/01_requirements.md) |
| Read the detailed system design (AI-agent-facing spec) | [`instructions/02_system_design.md`](instructions/02_system_design.md) |
| See the per-file code contracts | [`instructions/03_code_specs.md`](instructions/03_code_specs.md) |
| Reproduce the initial scaffold | [`instructions/04_scaffolding.md`](instructions/04_scaffolding.md) |
| Read the original implementation spec (Phases 1–5 only) | [`instructions/05_implementation.md`](instructions/05_implementation.md) |
| See the test status, workarounds, and known limitations | [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| Get oriented as an AI agent (conventions, commit policy) | [`../AGENTS.md`](../AGENTS.md) |

## Doc conventions

- `instructions/` — pre-implementation specs (requirements, system design,
  code contracts, scaffold, original implementation). Kept as reference;
  `CHANGELOG.md` and `HISTORY.md` are the source of truth for what shipped.
- `*.md` files in this directory (other than `instructions/`) are the
  current-truth docs and should be updated as the project evolves.
- Five legacy files (`BUG_REPORT.md`, `error.md`, `STATUS_AUDIT.md`,
  `REDESIGN.md`, `instructions/06_completion_status.md`) are kept for
  provenance; each carries a `SUPERSEDED` banner pointing at
  `CHANGELOG.md` / `HISTORY.md`. Their content has been folded in.

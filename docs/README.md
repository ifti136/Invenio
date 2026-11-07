# Invenio — Documentation

Invenio is a single-owner Flutter Android app for managing inventory, logging
sales, tracking money and expenses, and viewing profit analytics — fully
offline, no auth, no cloud sync. This directory is the canonical documentation
for the project.

## Project state (v3.6.7+27, Schema v8)

| Aspect | Detail |
|--------|--------|
| Flutter SDK | 3.24.4 · Dart 3.5.4 |
| Target | Android (min API 24) |
| Database | drift (SQLite) — schema v8 (13 tables) |
| State | Riverpod |
| Routing | go_router 15 (`StatefulShellRoute.indexedStack`, 5 tabs) |
| Theme | Clean Ledger — Material 3, seed `#1D9E75`, light/dark/system |
| Charts | fl_chart 0.69 |
| Export | CSV + SQLite backup via `share_plus` |
| Tests | 58 passing — see [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| Version | `3.6.7+27` (build 27) |

## If you want to …

| You want to … | Read |
|---|---|
| Understand the key tech choices in 5 minutes | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| See what was built, in order, with one bullet per release | [`CHANGELOG.md`](CHANGELOG.md) |
| Look up a color, a spacing token, a screen layout | [`DESIGN.md`](DESIGN.md) |
| See the test status, workarounds, and known limitations | [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| Read the original Clean Ledger master spec | `invenio overhaul.pdf` |

## Doc conventions

- `CHANGELOG.md` is the single source of truth for what shipped. The former
  `HISTORY.md` and `VERSION_HISTORY.md` were folded into it in v3.6.3;
  pre-overhaul details remain in git history.
- Releases follow `v3.<phase>.<change>`: `v3.0.0` is the Clean Ledger
  baseline, Phase 0 is `v3.0.x`, and Phase 1+ start at `v3.<phase>.1`.
- `DESIGN.md` and the master spec PDF define the visual language. If a task
  conflicts with either, stop and ask.
- `instructions/` holds legacy pre-overhaul specs. It is kept for provenance
  and is not the current source of truth.
- Update these files as the project evolves.

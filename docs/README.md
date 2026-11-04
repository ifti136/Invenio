# Invenio — Documentation

Invenio is a single-owner Flutter Android app for managing inventory, logging
sales, tracking expenses, and viewing profit analytics — fully offline, no
auth, no cloud sync. This directory is the canonical documentation for the
project.

## Project state (v2.3.0+20, Schema v7)

| Aspect | Detail |
|--------|--------|
| Flutter SDK | 3.24.4 · Dart 3.5.4 |
| Target | Android (min API 24) |
| Database | drift (SQLite) — schema v7 (12 tables) |
| State | Riverpod |
| Routing | go_router 15 (`StatefulShellRoute.indexedStack`, 5 tabs) |
| Theme | Clean Ledger — Material 3, seed `#1D9E75`, light/dark/system |
| Charts | fl_chart 0.69 |
| Export | CSV + SQLite backup via `share_plus` |
| Tests | see [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |
| Version | `2.3.0+20` (build 20) |

## If you want to …

| You want to … | Read |
|---|---|
| Understand the key tech choices in 5 minutes | [`ARCHITECTURE.md`](ARCHITECTURE.md) |
| See what was built, in order, with one bullet per version | [`CHANGELOG.md`](CHANGELOG.md) |
| See the full micro-version history from initial build to current | [`VERSION_HISTORY.md`](VERSION_HISTORY.md) |
| Understand what broke, why, and how it was fixed | [`HISTORY.md`](HISTORY.md) |
| Look up a color, a spacing token, a screen layout | [`DESIGN.md`](DESIGN.md) |
| See the test status, workarounds, and known limitations | [`../tracker_app/test/REPORT.md`](../tracker_app/test/REPORT.md) |

## Doc conventions

- `CHANGELOG.md` and `HISTORY.md` are the canonical source of truth for what
  shipped. `VERSION_HISTORY.md` provides the full micro-version log.
- `instructions/` and several legacy files (`BUG_REPORT.md`, `error.md`,
  `STATUS_AUDIT.md`, `REDESIGN.md`) are kept on disk for provenance but
  are no longer git-tracked. Their content has been folded into
  `CHANGELOG.md` / `HISTORY.md`.
- Update the `*.md` files in this directory as the project evolves.

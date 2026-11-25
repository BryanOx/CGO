# Classic Games Online

Godot 4.7.2 mobile foundation for a multi-game client. Conga is registered as metadata and a placeholder only; Phase 1 delivers navigation, typed service ports, replaceable adapters, and a centralized design system. No game rules, multiplayer, ads, purchases, or backend are implemented in this phase.

## Quick path

1. Read `AGENTS.md`, `docs/Classic_Games_Online_GDD_TDD.md`, `docs/adr/README.md`, and `odd/tasks/platform-foundation.md`.
2. Verify the client with the exact commands below using the pinned Godot binary.
3. Pick the first unchecked task in the tracker and keep its evidence with its commit.

```bash
G="/home/bryan/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"

"$G" --headless --version
"$G" --headless --path client --editor --quit
"$G" --headless --path client -s res://tools/check_parse.gd
"$G" --headless --path client -s res://tests/run_tests.gd
python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null
```

Expected version: `4.7.2.stable.official.ed1daf0bf`. No `godot` command exists on `PATH`; the variable above is the supported local path. The third command runs the parse sweep, and the fourth runs the in-repo headless test runner.

## Folder map

| Path | Contents |
|------|----------|
| `client/app/` | Composition root, router, screen contracts, and backend configuration resource. |
| `client/core/` | Ports, game-agnostic domain contracts, application registries, and adapters. |
| `client/games/conga/` | Conga definition resource and non-playable placeholder screen. |
| `client/shared/` | Design tokens, generated Theme, responsive helpers, and reusable UI components. |
| `client/tools/` | Parse sweep and other in-repo validators. |
| `client/tests/` | Headless test runner; owned by the test work unit. |
| `contracts/fixtures/` | Frozen reference-only fixtures. Never derived into Phase 1 code. |
| `docs/adr/` | Accepted architecture decisions, indexed in `docs/adr/README.md`. |
| `docs/audit/` | Phase 0 evidence for repositories, rules, assets, licenses, and toolchain. |
| `odd/tasks/` | Task checklist, acceptance criteria, and verification evidence. |

## Toolchain

| Item | Value |
|------|-------|
| Engine | Godot 4.7.2 stable, pinned in `.github/workflows/client.yml` from the official GitHub release. |
| Local binary | `/home/bryan/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64` |
| Renderer | Mobile, retained per ADR-0001. |
| Layout baseline | 360 x 800 logical pixels, `canvas_items` / `expand` stretch, safe areas, 48 dp touch targets. |
| Dependencies | Godot built-ins only; no addons or external GDScript test framework. |

## Phase status

| Phase | Status | Exit gate |
|-------|--------|-----------|
| 0 — Audit | Complete | Inventory, nine ADRs, frozen reference-only Conga fixture. |
| 1 — Foundation | In progress | Navigable shell, typed ports, mock and remote adapters, design system, headless verification. |
| 2 — Vertical slice | Not started | Conga offline rules, bots, tutorial, and rule tests. |
| 3 — Backend | Not started | Auth, persistence, WebSocket, rooms, and parity. |
| 4 — Economy | Not started | Ledger, shop, inventory, and equipment. |
| 5 — Ads | Not started | Consent, server-side verification, and kill switch. |
| 6 — Beta | Not started | Validated ranked play, telemetry, and device QA. |
| 7 — Expansion | Not started | Second game to prove registry modularity. |

## Asset policy

Original files are never modified. `congauy` card art is CC BY-SA 3.0 with mandatory attribution and a pending share-alike gate; its audio license is unknown and excluded. No congauy asset is copied into `client/assets/` without a license entry. See `docs/audit/phase0.md` and ADR-0006 before adding art.

## Next step

Follow `odd/tasks/platform-foundation.md`; each task closes with one work-unit commit and recorded command output.

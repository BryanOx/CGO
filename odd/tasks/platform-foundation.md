# Platform Foundation — Phase 0 + Phase 1

Status: in progress. Scope: audit and foundation only. Conga gameplay, multiplayer and real monetization are explicitly out of scope.

## Objective

Build a modular Godot 4 mobile platform that can host multiple classic games, with Conga as the first registered module. Phase 0 establishes an evidence-based audit and architecture decisions; Phase 1 delivers the navigable shell, centralized design system, modular game registry, service ports, replaceable mocks, and automated headless verification.

## Problem

The repository is a bare Godot 4.7 skeleton with no source, no Git history, no scenes, and no asset policy. The requirements document proposes architecture but explicitly states that repositories and assets were not audited. Building screens before the audit would hardcode assumptions about rules, licenses, and transport.

## Constraints

- Godot 4.7.2 stable, GDScript with static typing, renderer per ADR-0001.
- Folder layout and responsibilities from `docs/Classic_Games_Online_GDD_TDD.md` section 03.
- Composition, decoupling, SOLID, KISS, explicit dependency injection; no monolithic classes; no gameplay manager autoload.
- Mobile-only: 360x800 logical baseline, safe areas, variable density, 48 dp touch targets.
- Existing assets are never modified destructively; license status is recorded before reuse.
- Simulated data exists only in development; production composition wires remote adapters.
- Backend endpoint is configuration, never business logic. REST and native WebSocket contracts only; no Socket.IO without a documented technical need.
- No backend implementation, real ads, real purchases, or multiplayer in this feature.
- No new third-party Godot dependencies; Godot built-ins only.

## Source of truth

`docs/Classic_Games_Online_GDD_TDD.md` — sections 01-04, 06-09, 15-17. Phase definitions in section 16.

## Delivery strategy

`single-pr`. Rationale: no Git remote is configured, and Phase 0 + Phase 1 form one coherent foundation boundary. PR creation and push remain user decisions. Work-unit commits are recorded per task below.

Forecast: ~1800 authored changed lines across docs, core contracts, UI components, screens, and tests. The forecast exceeds the 400-line review budget, so each task closes as its own work-unit commit and native review is assessed per commit when receipt-driven development is enabled.

## Checklist

### Phase 0 — Audit

- [ ] P0-1 Inventory repositories, Conga rules, assets, licenses, and toolchain in `docs/audit/phase0.md`.
- [x] P0-2 Record architecture decisions in `docs/adr/` with an index.
- [x] P0-3 Freeze reference-only Conga fixtures in `contracts/fixtures/conga/`; no rules engine port.

### Phase 1 — Foundation

- [ ] P1-1 Initialize monorepo: Git, `.gitignore`, `AGENTS.md`, CI workflow, export presets, dev config.
- [ ] P1-2 Implement core contracts, `BackendConfig`, `GameDefinition`, `GameRegistry`, `MatchSession` contract, composition root, and router.
- [ ] P1-3 Implement development mocks and the replaceable remote HTTP adapter behind service ports.
- [ ] P1-4 Implement centralized design tokens, generated Theme, safe-area container, and reusable UI components.
- [ ] P1-5 Implement screens: splash, home, game catalog, game detail placeholder, leaderboard, profile, wallet, shop, inventory, settings.
- [ ] P1-6 Implement automated headless tests and validation tools.
- [ ] P1-7 Verify: Godot headless import, GDScript parse check, all main scenes instantiate, tests pass, evidence recorded here.

## Acceptance criteria

| ID | Criterion | Check |
|----|-----------|-------|
| AC-1 | No original asset is modified or copied into `client/assets` without a license entry. | Audit doc + `git status` |
| AC-2 | `GameRegistry` can add a second game without editing wallet, shop, auth, or navigation logic. | Registry unit test |
| AC-3 | Switching `BackendConfig.base_url` changes no business-logic file. | Config test + ADR |
| AC-4 | Production composition never instantiates mock services. | Composition test + export filter |
| AC-5 | All main scenes instantiate headless without script errors. | Scene smoke test |
| AC-6 | All GDScript files parse with zero errors. | `godot --headless --check-only --script` sweep |
| AC-7 | Safe-area and responsive breakpoints are centralized. | Component test + code review |
| AC-8 | No Conga rules, bots, multiplayer, ads, or purchases are implemented. | Scope diff review |

## Verification evidence

| Task | Command | Result | Commit |
|------|---------|--------|--------|
| P0-1 | `find` + file inspection | pending | — |
| P0-2 | ADR section readback (9 records, 9 indexed) | `ADR readback: 9 records, 9 indexed, 9/9 with all five sections; missing=0` | `docs(adr): record phase 0 architecture decisions` (this commit) |
| P0-3 | `python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null` | exit 0, no output | `test(fixtures): freeze reference-only conga rules baseline` (this commit) |
| P1-1 | `git status --short` | pending | — |
| P1-2 | Godot headless parse | pending | — |
| P1-3 | Godot headless parse | pending | — |
| P1-4 | scene instantiation | pending | — |
| P1-5 | scene instantiation sweep | pending | — |
| P1-6 | `godot --headless -s res://tests/run_tests.gd` | pending | — |
| P1-7 | full verification batch | pending | — |

## Progress and rationale

- 2026-11-25: Phase 0 audit completed by a read-only explorer. `congauy` is a Next.js 16 / TypeScript game, not Godot. Godot 4.7.2 is available at the Steam install path but absent from `PATH`. Card art carries CC BY-SA 3.0 with attribution; audio licensing is unresolved and therefore excluded from this phase. No project skill registry exists; global standards apply.
- Renderer decision recorded in ADR-0001 because the skeleton uses the Mobile renderer while the requirements document proposes Compatibility. Both are evaluated against the mobile-only constraint rather than silently changed.
- P0-2 closed as `d72dc12393fb31ebfda0808d50c0493d226bddee` with nine indexed ADRs covering version and renderer, layering, transport, layout, mocks, assets, registry, headless verification, and deployment. Every record links to a tracker criterion or command; `client/project.godot` was not edited.
- P0-3 froze audit-verified rules facts and an empty behavioral example list; no card IDs, scores, or seeds were invented and no rules engine was ported.

## Next step

Proceed to Phase 1 from P1-1, keeping ADRs and the frozen baseline as inputs.

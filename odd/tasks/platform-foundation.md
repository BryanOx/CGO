# Platform Foundation — Phase 0 + Phase 1

Status: complete. Phase 0 and Phase 1 are verified. Scope: audit and foundation only. Conga gameplay, multiplayer and real monetization are explicitly out of scope.

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

- [x] P0-1 Inventory repositories, Conga rules, assets, licenses, and toolchain in `docs/audit/phase0.md`.
- [x] P0-2 Record architecture decisions in `docs/adr/` with an index.
- [x] P0-3 Freeze reference-only Conga fixtures in `contracts/fixtures/conga/`; no rules engine port.

### Phase 1 — Foundation

- [x] P1-1 Initialize monorepo: Git, `.gitignore`, `AGENTS.md`, CI workflow, export presets, dev config.
- [x] P1-2 Implement core contracts, `BackendConfig`, `GameDefinition`, `GameRegistry`, `MatchSession` contract, composition root, and router.
- [x] P1-3 Implement development mocks and the replaceable remote HTTP adapter behind service ports.
- [x] P1-4 Implement centralized design tokens, generated Theme, safe-area container, and reusable UI components.
- [x] P1-5 Implement screens: splash, home, game catalog, game detail placeholder, leaderboard, profile, wallet, shop, inventory, settings.
- [x] P1-6 Implement automated headless tests and validation tools.
- [x] P1-7 Verify: Godot headless import, GDScript parse check, all main scenes instantiate, tests pass, evidence recorded here.

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
| P0-1 | `find` + file inspection | completed: repositories, rules, assets, licenses, and toolchain recorded in `docs/audit/phase0.md` | `51f336c` (docs(audit): record phase 0 repository and asset findings) |
| P0-2 | ADR section readback (9 records, 9 indexed) | `ADR readback: 9 records, 9 indexed, 9/9 with all five sections; missing=0` | `docs(adr): record phase 0 architecture decisions` (this commit) |
| P0-3 | `python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null` | exit 0, no output | `test(fixtures): freeze reference-only conga rules baseline` (this commit) |
| P1-1 | `G --headless --path client --editor --quit`; `G --headless --path client -s res://tools/check_parse.gd`; `git status --short` | import exit 0, no `SCRIPT ERROR`; parse exit 0 (`1 GDScript files loaded, 0 failures`); status shows only task-owned untracked paths, no congauy or icon changes | `chore(foundation): initialize monorepo rules and pinned headless CI` (this commit) |
| P1-2 | `G --headless --path client --editor --quit`; `G --headless --path client -s res://tools/check_parse.gd`; `G --headless --path client --quit-after 5`; registry smoke script | import exit 0, no `SCRIPT ERROR`; parse exit 0 (`22 GDScript files checked, 0 failures`); main scene run exit 0, no errors; Conga definition registered once, duplicate rejected, enabled count 1 | `feat(core): add typed ports, game registry, and composition shell` (this commit) |
| P1-3 | `G --headless --path client --editor --quit`; `G --headless --path client -s res://tools/check_parse.gd`; composition and adapter smoke scripts | import exit 0, no `SCRIPT ERROR`; parse exit 0 (`26 GDScript files checked, 0 failures`); development flags `true,true,true` with local settings, production flags `false,false,false` with `RemoteApiClient`; mock guest/balance/shop/leaderboard `guest-dev-0001 / 200 / 3 / 3`; remote POST and GET against a local JSON server returned `ok=true` with `Idempotency-Key` preserved | `feat(services): add development mocks and remote adapters behind ports` (this commit) |
| P1-4 | `G --headless --path client --editor --quit`; `G --headless --path client -s res://tools/check_parse.gd`; component instantiation smoke script | import exit 0, no `SCRIPT ERROR`; parse exit 0 (`38 GDScript files checked, 0 failures`); all eight components instantiated and methods exercised with exit 0 and no runtime errors; responsive columns `1/2/3`, touch target 48, Theme Button style present | `feat(ui): add centralized design tokens and reusable mobile components` (this commit) |
| P1-5 | `G --headless --path client --editor --quit`; `G --headless --path client -s res://tools/check_parse.gd`; `G --headless --path client -s res://tests/_scene_smoke.gd` (temporary harness, removed after evidence); `G --headless --path client --quit-after 5` | import exit 0, no `SCRIPT ERROR`; parse exit 0 (`50 GDScript files checked, 0 failures`); scene sweep exit 0 (`Scene smoke: 11 checked, 0 failed.`; control counts `10/21/19/9/27/16/16/42/36/26/6`); main scene run exit 0 with no output | `feat(shell): add mobile screens and navigation flow` (this commit) |
| P1-6 | `G --headless --path client -s res://tests/run_tests.gd` | exit 0: `[PASS]` for all six suites, `Tests: 6 passed, 0 failed.`, scene controls `10/21/19/9/27/16/16/42/36/26/6`, no `SCRIPT ERROR` or resource leaks | `test(headless): add in-repo runner and foundation checks` (this commit) |
| P1-7 | `G --headless --path client --editor --quit`; `G --headless --path client -s res://tools/check_parse.gd`; `G --headless --path client -s res://tests/run_tests.gd`; `G --headless --path client --quit-after 5`; `python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null`; `git status --short`; `git log --oneline -4` | import exit 0, no `SCRIPT ERROR` (ADB daemon notice only); parse exit 0 (`58 GDScript files checked, 0 failures`); tests exit 0 (`Tests: 6 passed, 0 failed.`); main scene exit 0 with no output; fixture exit 0; status shows only `?? client/tests/` before the P1-6 commit; log head `785b8e0 feat(shell): add mobile screens and navigation flow` | `test(headless): add in-repo runner and foundation checks` (this commit) |

## Progress and rationale

- 2026-11-25: Phase 0 audit completed by a read-only explorer. `congauy` is a Next.js 16 / TypeScript game, not Godot. Godot 4.7.2 is available at the Steam install path but absent from `PATH`. Card art carries CC BY-SA 3.0 with attribution; audio licensing is unresolved and therefore excluded from this phase. No project skill registry exists; global standards apply.
- Renderer decision recorded in ADR-0001 because the skeleton uses the Mobile renderer while the requirements document proposes Compatibility. Both are evaluated against the mobile-only constraint rather than silently changed.
- P0-2 closed as `d72dc12393fb31ebfda0808d50c0493d226bddee` with nine indexed ADRs covering version and renderer, layering, transport, layout, mocks, assets, registry, headless verification, and deployment. Every record links to a tracker criterion or command; `client/project.godot` was not edited.
- P0-3 froze audit-verified rules facts and an empty behavioral example list; no card IDs, scores, or seeds were invented and no rules engine was ported.
- P1-1 added repository rules, a quick-path README, pinned Godot 4.7.2 headless CI from the official release URL, an Android export preset with `exclude_filter="tests/*"`, and the in-repo parse sweep. CI calls `tests/run_tests.gd`, which is owned by the P1-6 work unit. `client/project.godot` was not changed: the Mobile renderer in ADR-0001 is preserved.
- P1-2 added typed ports, game-agnostic domain contracts, registries, the composition root, and the router. `client/project.godot` now sets `run/main_scene="res://app/main.tscn"` for export; the Mobile renderer is unchanged. `ServiceFactory` temporarily returns fail-explicit ports until P1-3 supplies adapters, and the theme is an empty `Theme` until P1-4 supplies tokens.
- The parse sweep was hardened to call Godot `--check-only` per script. In-process `ResourceLoader.load` returned cached script objects even after parse errors, so it could not enforce AC-6. The sweep skips itself to avoid reloading the running script.
- P1-3 wired `ServiceFactory` to mocks plus `LocalSettingsService` in development and `RemoteServices` elsewhere. GDScript forbids redeclaring an inherited member, so adapters assign the inherited `simulated` field in `_init()` instead of redeclaring it. `RemoteApiClient` uses the built-in `HTTPClient` because a GDScript coroutine cannot satisfy the synchronous `ApiClient` port; the HTTP request path includes timeout, JSON parsing, typed error codes, and `Idempotency-Key`.
- P1-4 added one `DesignTokens` resource with a static accessor, a runtime-generated Theme, responsive breakpoints, safe-area margins, and eight reusable controls. All component colors, sizes, spacing, radii, and durations come from tokens; `main.gd` now builds and applies the generated Theme before navigation.
- P1-5 added ten typed screen pairs under `client/features/`, a reusable `BottomNav`, and the full ten-entry screen map in `main.gd`; the Conga placeholder was left untouched. `Screen` owns configuration but defines no `_ready()`, and GDScript rejects `super._ready()` against a base without that method, so `FeatureScreen` in `client/features/` supplies the hook while still extending `Screen`. Parent decision: if `super._ready()` must resolve directly on `Screen`, move the hook into `app/screen.gd` in a future app-owned work unit.
- Headless scene smoke needed an explicit `_ready()` call because SceneTree `_initialize()` adds nodes before they enter the running tree; the splash timer uses `autostart` when it is not yet inside the tree so the harness produces no timer error.
- P1-6 added `TestCase`, a six-suite SceneTree runner, and focused checks for registry extensibility, config composition, service behavior by environment, mock response shapes, design tokens, and scene instantiation. Scene smoke frees its `Router` and `AppContext` nodes so the runner exits without ObjectDB leak warnings.
- The composition test distinguishes `MockServices.build()` from `ServiceFactory.build()`: all mock adapters are simulated, but development composition replaces settings with the real `LocalSettingsService` (`simulated == false`). Mock default assertions therefore read the mock adapter, not user-persisted settings.
- P1-7 completed the full verification batch with zero parse failures, zero test failures, a clean main-scene run, and a valid frozen fixture. AC-2 through AC-8 now have recorded automated or scope evidence; remaining checks are device-level UX and later-phase features.

- Parent verification (2026-11-25): re-ran the full batch directly. Import exit 0 with 0 `SCRIPT ERROR`; parse exit 0 with `58 GDScript files checked, 0 failures`; tests exit 0 with `Tests: 6 passed, 0 failed.`; main-scene run exit 0 with 0 `SCRIPT ERROR`; fixture JSON exit 0; `git status --short` clean. Static-typing audit found zero untyped variable declarations and zero untyped parameters; `client/project.godot` has no autoload section; 12 `.tscn` scenes exist. Receipt-driven development reports `off (decided by global)`, so no native review transaction was opened.
- Added `contracts/api/v1/README.md` as the client-facing REST and WebSocket specification. It reserves future endpoint names without implementing a server, and records the no-Socket.IO decision from ADR-0003.

## Next step

Phase 0 and Phase 1 are complete and verified. Do not start Conga rules, bots, multiplayer, backend, ads, or purchases until the gates in `docs/audit/phase0.md` are resolved and a new feature document is created. Push and PR creation remain user decisions.

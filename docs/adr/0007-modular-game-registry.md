# ADR-0007 — Modular game registry

Accepted · 2026-11-25 · Supersedes nothing

**Decision: immutable `GameDefinition` resources are registered explicitly in `GameRegistry`; adding a game never edits wallet, auth, shop, or router, and Conga is registered in Phase 1 as metadata plus a placeholder scene only.**

## Context

- The requirements define `GameDefinition` with a stable ID, scene, modes, rules version, and capabilities, and require explicit registration without remote dynamic imports (`docs/Classic_Games_Online_GDD_TDD.md:153-162`).
- The extension criterion says a second game must not modify wallet, auth, shop, or Conga logic (`docs/Classic_Games_Online_GDD_TDD.md:190-192`).
- Phase 1 is foundation; Conga rules, bots, and multiplayer belong to Phases 2 and 3 (`docs/Classic_Games_Online_GDD_TDD.md:471-480`; `docs/audit/phase0.md:97`).

## Decision

| Item | Choice |
|------|--------|
| Definition | Immutable `GameDefinition` Resource with stable ID, placeholder scene, modes, rules version, and capabilities. |
| Registry | Explicit registration in `GameRegistry`; no dynamic or remote discovery. |
| Extensibility | A new game adds its definition, rules, view, bots, fixtures, and server module; wallet, auth, shop, and router stay unchanged. |
| Phase 1 Conga | Metadata plus a placeholder scene; no playable rules. |
| Deferred | Conga rules, bots, and multiplayer in Phase 2/3 only. |

## Consequences

- The game catalog and router consume registry data instead of hardcoded screen maps.
- The placeholder scene is non-playable and clearly scoped as a navigation target.
- A second-game unit test can prove modularity before any second game is built.
- No Conga rules, bot policy, or session protocol enters the foundation commits.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Hardcoded screen map | Forces edits to shared navigation for every new game. |
| Gameplay autoload registry | Conflicts with ADR-0002 and hides registration order. |
| Full Conga port in Phase 1 | Violates AC-8 and the phase plan. |

## Verification

- AC-2 (`GameRegistry` adds a second game without editing wallet, shop, auth, or navigation logic) via registry unit test.
- AC-8 (no Conga rules, bots, multiplayer, ads, or purchases) via scope diff review.
- AC-5 and AC-6: placeholder scene instantiates and scripts parse headless.
- P0-2 document readback: this record is present in `docs/adr/README.md`.

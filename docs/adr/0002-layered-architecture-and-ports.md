# ADR-0002 — Layered architecture with explicit ports

Accepted · 2026-11-25 · Supersedes nothing

**Decision: dependencies point inward from infrastructure through application to domain; domain code never imports scenes or HTTP clients, and dependencies are injected at a composition root with no gameplay autoload.**

## Context

- The requirements define UI → application → domain boundaries and forbid scene, HTTP, or SDK imports in the domain (`docs/Classic_Games_Online_GDD_TDD.md:60-86`).
- Typed GDScript bases may fail explicitly when a subclass does not implement a method (`docs/Classic_Games_Online_GDD_TDD.md:130-164`).
- A single `GameManager` autoload would concentrate rules, UI, network, and economy, which the requirements forbid (`docs/Classic_Games_Online_GDD_TDD.md:82`).

## Decision

| Area | Choice |
|------|--------|
| Layers | Domain / application / ports / infrastructure; each layer depends only on layers inward of it. |
| Domain purity | State, rules, actions, and events only; no scene, HTTP, SDK, or autoload access. |
| Ports | Small explicit interfaces with fail-explicit base methods; external data is validated in release builds, not by assertions alone. |
| Injection | Constructor or configuration injection at the composition root; minimal autoloads, never a gameplay autoload. |
| Game modules | `features/games/<game>/{domain,application,presentation,content}` with no cross-game imports. |

## Consequences

- UI renders snapshots and emits intents; it cannot grant currency or mutate authoritative state.
- Adding a game touches its own module plus the registry, satisfying AC-2.
- The composition root grows explicit wiring; that verbosity is accepted for testable dependencies.
- Port implementations can be swapped without editing callers (see ADR-0003 and ADR-0005).

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Gameplay autoload | Concentrates unrelated responsibilities and hides dependencies. |
| Dynamic remote imports | Violates explicit registration and domain purity. |
| UI-owned rules | Couples deterministic rules to presentation and transport. |

## Verification

- AC-2 (`GameRegistry` adds a second game without editing wallet, shop, auth, or router) via registry unit test.
- AC-8 (no Conga rules, bots, multiplayer, ads, or purchases) via scope diff review.
- AC-6 (`godot --headless --check-only --script` sweep) and P1-2 headless parse.
- Code review confirms no scene or HTTP imports under domain paths.

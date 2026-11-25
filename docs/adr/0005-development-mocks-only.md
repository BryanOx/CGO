# ADR-0005 — Development mocks only

Accepted · 2026-11-25 · Supersedes nothing

**Decision: simulated services are instantiated only when `BackendConfig.environment == "development"`; production composition wires remote adapters, and mocks stay in the export for parse safety.**

## Context

- The constraints state that simulated data exists only in development and that production composition wires remote adapters (`odd/tasks/platform-foundation.md:20`).
- The requirements allow fake providers for development and test but forbid false rewards in production (`docs/Classic_Games_Online_GDD_TDD.md:406-408`).
- AC-4 names a composition test plus an export filter; file exclusion alone cannot prove composition behavior (`odd/tasks/platform-foundation.md:60`).

## Decision

| Item | Choice |
|------|--------|
| Selection gate | `BackendConfig.environment == "development"` selects mock implementations in the composition root. |
| Production | Composition wires remote HTTP and WebSocket adapters; no mock instance is created. |
| Export | Mock scripts remain in the export for parse safety; file exclusion is not the behavior gate. |
| Rewards | Simulated services never produce production-visible currency, inventory, or results. |

## Consequences

- AC-4 is verified by asserting production composition types, not by checking an export filter alone.
- Every port has a real or fail-explicit implementation path (see ADR-0002), so an unwired service is visible.
- Removing mock files from the export later is a separate change that still requires a parse sweep.
- Tests and development runs share the same ports, so behavior stays comparable.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Exclude mock files from export as the only gate | Does not prove what production composition instantiates and weakens parse coverage. |
| Compile-time flags | Adds a second selection mechanism outside `BackendConfig`. |
| Mocks always available | Risks simulated rewards and data in production. |

## Verification

- AC-4 (production composition never instantiates mock services) via composition test; the export filter is supporting evidence, not the gate.
- P1-3 Godot headless parse with mocks still present in the export.
- P1-6 (`godot --headless -s res://tests/run_tests.gd`) covers composition behavior.
- P0-2 document readback: this record is present in `docs/adr/README.md`.

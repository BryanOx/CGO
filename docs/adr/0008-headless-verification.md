# ADR-0008 — Headless verification harness

Accepted · 2026-11-25 · Supersedes nothing

**Decision: Godot 4.7.2 headless is the only test harness, driven by a small in-repo GDScript runner; GUT and external dependencies are not adopted.**

## Context

- CI requires a fixed Godot version and a fixed harness, allowing GUT or another settled harness (`docs/Classic_Games_Online_GDD_TDD.md:457-459`).
- The feature constraints forbid new third-party Godot dependencies (`odd/tasks/platform-foundation.md:23`).
- The audit found a working Godot 4.7.2 headless binary with no `PATH` alias (`docs/audit/phase0.md:26-29`).

## Decision

| Item | Choice |
|------|--------|
| Harness | Godot 4.7.2 headless only; no other engine or runtime harness. |
| Runner | Small in-repo GDScript runner at `tests/run_tests.gd`; no GUT, addons, or vendored frameworks. |
| Coverage | Parse sweep, pure unit checks, and scene instantiation smoke checks. |
| CI | Pin Godot 4.7.2 and download the official Godot release; no unpinned `latest` channel. |
| Fixtures | JSON fixtures are validated with `python3 -m json.tool`; no rules are derived from them in Phase 1. |

## Consequences

- Tests must stay small and deterministic so the runner remains simple.
- Local runs use the explicit binary path recorded in the audit until a stable alias exists.
- Scene smoke checks prove instantiation only, not device-level rendering or UX evidence.
- Headless results are recorded in the tracker with exact commands, not described as CI-green without evidence.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| GUT | Third-party dependency not allowed in this feature. |
| External test framework | Adds setup and version drift outside the pinned engine. |
| Manual-only verification | No reproducible command or evidence for AC-5 and AC-6. |

## Verification

- AC-6: `godot --headless --check-only --script` sweep with zero parse errors.
- AC-5: scene instantiation smoke checks for all main scenes.
- P1-6: `godot --headless -s res://tests/run_tests.gd`.
- P0-3: `python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null` validates the frozen fixture.

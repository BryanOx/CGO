# ADR-0001 — Pin Godot 4.7.2 stable and keep the Mobile renderer

Accepted · 2026-11-25 · Supersedes nothing

**Decision: pin Godot 4.7.2 stable in CI and keep `renderer/rendering_method="mobile"`. The renderer choice is reversible through a new ADR backed by device profiling; it is not changed silently.**

## Context

- The audited binary reports `4.7.2.stable.official.ed1daf0bf` and matches the `4.7` feature in `client/project.godot:14`; it is not on `PATH` (`docs/audit/phase0.md:26-29`).
- The skeleton sets `renderer/rendering_method="mobile"` at `client/project.godot:28`; the requirements document proposes Compatibility at `docs/Classic_Games_Online_GDD_TDD.md:74` (`docs/audit/phase0.md:30-31`).
- The product is mobile-only, with a 60 fps mid-range and 30 fps low-end target (`docs/Classic_Games_Online_GDD_TDD.md:218-220`).

## Decision

| Item | Choice |
|------|--------|
| Engine | Godot 4.7.2 stable, pinned in CI from the official release download. |
| Renderer | Mobile renderer retained for this phase as the conservative default for the mobile-only target. |
| Skeleton | `client/project.godot` is not edited by this ADR; it is outside the Phase 0 edit surface. |
| Reversibility | Explicitly reversible: a new ADR with low-end profiling evidence may supersede this decision. |

## Consequences

- Local runs use the explicit binary path from the audit because no `godot` alias exists on `PATH`.
- Compatibility is not assumed to be faster on low-end devices; the choice is deferred until measured.
- `canvas_items` / `expand` stretch from `client/project.godot:19-20` remains the layout basis used by ADR-0004.
- Changing the renderer later needs a separate work unit and an ADR, not an incidental config edit.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Compatibility now | Proposed but unmeasured against the low-end mobile target. |
| Unpinned engine version | Breaks reproducible verification across machines. |
| Silently patch `project.godot` | Hides a decision and falls outside the Phase 0 edit surface. |

## Verification

- AC-6 (`godot --headless --check-only --script` sweep) must pass on the pinned version.
- P1-6 (`godot --headless -s res://tests/run_tests.gd`) must use the same pinned version.
- P0-2 document readback: this record is present in `docs/adr/README.md`.
- Version evidence from the audit: `<binary> --headless --version` returned `4.7.2.stable.official.ed1daf0bf`.

# ADR-0004 — Design system and mobile layout

Accepted · 2026-11-25 · Supersedes nothing

**Decision: a centralized `DesignTokens` resource generates the runtime `Theme`; layout uses a 360x800 logical baseline, containers and anchors, safe areas, 48 dp touch targets, and explicit loading/empty/error/offline and reduced-motion states.**

## Context

- The requirements set the 360x800 logical baseline, vertical orientation first, safe areas, containers, anchors, Theme, 48 dp targets, and mandatory UI states (`docs/Classic_Games_Online_GDD_TDD.md:194-220`).
- The audit records `canvas_items` / `expand` stretch in `client/project.godot:19-20` (`docs/audit/phase0.md:32`).
- Layout constants duplicated in scenes would make responsive changes unsafe.

## Decision

| Area | Choice |
|------|--------|
| Tokens | One `DesignTokens` resource owns colors, typography, spacing, radii, and motion values. |
| Theme | Runtime-generated from tokens; scenes consume the generated Theme instead of local overrides. |
| Layout | 360x800 logical baseline; containers and anchors only, with no absolute positioning. |
| Mobile | Safe-area container, approximately 48 dp touch targets, legible text, and configurable reduced motion. |
| States | Loading, empty, error, offline, reconnection, disabled, and success are required states for data-driven screens. |

## Consequences

- Token edits propagate to all screens without per-scene layout edits.
- Screen work cannot hide hardcoded pixels inside a control tree; AC-7 is reviewable.
- Non-blocking catalog downloads require a visible loading state rather than a frozen UI.
- Device evidence remains a later gate for UX changes; headless smoke checks cover instantiation only.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Absolute layout per screen | Breaks on different densities and safe areas. |
| Per-scene colors and spacing | Duplicates tokens and fails AC-7. |
| External UI dependency | Conflicts with the no-third-party-dependency constraint. |

## Verification

- AC-7 (safe-area and responsive breakpoints centralized) via component test plus code review.
- AC-5 (all main scenes instantiate headless) via scene smoke test; P1-4 and P1-5 cover instantiation.
- AC-6 (`godot --headless --check-only --script` sweep) over theme and layout scripts.
- P0-2 document readback: this record is present in `docs/adr/README.md`.

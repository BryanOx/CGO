# ADR-0006 — Asset license policy

Accepted · 2026-11-25 · Supersedes nothing

**Decision: no original asset is modified; no congauy asset enters `client/assets/` without a license entry; card art is CC BY-SA 3.0 with mandatory attribution; audio licensing is unknown and excluded; stable IDs are used instead of filenames.**

## Context

- The audit lists card art as CC BY-SA 3.0 derivative work with mandatory attribution to Basquetteur and gjenkins20 (`docs/audit/phase0.md:68-74`).
- All congauy audio has unknown licensing; a filename containing `HoliznaCC0` is not proof of a license (`docs/audit/phase0.md:83-84`).
- The requirements require inventorying provenance, keeping sources outside the export, and using stable IDs (`docs/Classic_Games_Online_GDD_TDD.md:222-249`).

## Decision

| Item | Choice |
|------|--------|
| Originals | Never modified; editable sources stay outside the export. |
| Card art | CC BY-SA 3.0 with mandatory attribution to Basquetteur and gjenkins20 before reuse. |
| Audio | All congauy OGG and MP3 assets excluded until licensing is confirmed. |
| Other assets | OG image, favicons, and utility SVGs have unknown license status and are excluded. |
| Copy gate | A license entry must exist before any congauy asset enters `client/assets/`. |
| Identifiers | Stable IDs only; filenames are never commercial IDs and published IDs do not change. |

## Consequences

- Phase 1 uses no congauy art or audio; the engine default icon is the only client asset observed in Phase 0.
- CC BY-SA share-alike acceptability remains an explicit gate before card art reuse (`docs/audit/phase0.md:103`).
- Attribution text must accompany any future card asset entry.
- Stable IDs decouple catalog entries from file renames and export compression.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Copy first, document later | Violates AC-1 and makes provenance unrecoverable. |
| Assume ownership implies a license | Possession is not a license grant. |
| Filename as ID | Breaks catalog stability when files are renamed or optimized. |

## Verification

- AC-1 (no original asset modified or copied into `client/assets` without a license entry) via audit doc plus `git status`.
- P0-2 document readback: this record is present in `docs/adr/README.md`.
- Pending validations in `docs/audit/phase0.md:100-106` remain gates, not silent approvals.

# ADR-0006 — Asset license policy

Accepted · 2026-11-25 · Supersedes nothing · Amended 2026-11-25 (audio license resolution, see Amendment below)

**Decision: no original asset is modified; no congauy asset enters `client/assets/` without a license entry; card art is CC BY-SA 3.0 with mandatory attribution; audio is CC0 (13 file-backed Kenney effects and 4 owner-declared HoliznaCC0 tracks); stable IDs are used instead of filenames.**

## Context

- The audit lists card art as CC BY-SA 3.0 derivative work with mandatory attribution to Basquetteur and gjenkins20 (`docs/audit/phase0.md:68-74`).
- At Phase 0 review time all congauy audio had unknown licensing; a filename containing `HoliznaCC0` alone was not accepted as proof (`docs/audit/phase0.md:83-84`). The owner supplied new license evidence later; see the Amendment.
- The requirements require inventorying provenance, keeping sources outside the export, and using stable IDs (`docs/Classic_Games_Online_GDD_TDD.md:222-249`).

## Decision

| Item | Choice |
|------|--------|
| Originals | Never modified; editable sources stay outside the export. |
| Card art | CC BY-SA 3.0 with mandatory attribution to Basquetteur and gjenkins20 before reuse. |
| Audio | 13 OGG effects copied as Kenney Casino Audio 1.1 (CC0 1.0, SHA-256 match against the source pack); 4 MP3 tracks copied under the owner's CC0 declaration with HoliznaCC0 provenance recorded. |
| Other assets | OG image, favicons, and utility SVGs have unknown license status and are excluded. |
| Copy gate | A license entry must exist before any congauy asset enters `client/assets/`. |
| Identifiers | Stable IDs only; filenames are never commercial IDs and published IDs do not change. |

## Amendment — 2026-11-25 (audio license resolution)

The owner supplied `/home/bryan/Descargas/kenney_casino-audio/License.txt` and declared all audio CC0. Two evidence classes are recorded separately; neither is silently upgraded:

| Group | Evidence | Result |
|-------|----------|--------|
| 13 OGG effects | Kenney Casino Audio 1.1 `License.txt` states CC0 1.0; all 13 files match the source pack byte-for-byte by SHA-256. | Copied with verbatim license, attribution, and manifest. |
| 4 MP3 tracks | No license file found in either repo or Downloads. `congauy/src/lib/audio.test.ts:5` quotes the shipped name `01 HoliznaCC0 - Dreams.mp3`; commit `7cb791d` renamed the four tracks to URL-safe slugs. The owner declares them CC0. | Copied with attribution recording an owner declaration, not an externally verified license. |

External verification of the HoliznaCC0 source was attempted but unavailable during this change, so the attribution must not claim it. The unlicensed status in `docs/audit/phase0.md` is historical Phase 0 evidence and is superseded for audio by `docs/audit/asset-ingestion.md`.

## Consequences

- Phase 1 originally used no congauy art or audio; the engine default icon was the only client asset observed in Phase 0. The later asset-pipeline feature ingested the licensed assets described above.
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

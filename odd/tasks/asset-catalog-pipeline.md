# Asset Catalog Pipeline — free tiers and future unlockables

Status: in progress. Scope: asset ingestion, license evidence, catalog taxonomy, and cosmetic metadata. No Conga gameplay, rewards, or purchases.

## Objective

Ingest the existing CC BY-SA card artwork from `congauy` into the Godot client without modifying the originals, and establish an asset catalog that distinguishes free, future paid, and future ad-reward assets. Prices and availability remain server authority; local resources only resolve visuals and stable IDs.

## Problem

The Phase 1 foundation has no `client/assets/` tree and no cosmetic catalog. The user asked to reuse the existing card images and sounds and to prepare folders for future paid and ad-reward assets. The Phase 0 audit documented card licensing but found no verifiable audio license, so ingestion cannot treat all groups equally.

## Constraints

- `congauy` files are read-only sources. Copy only; never edit, rename in place, or delete originals.
- No license is assumed from file possession or filename. Card art has documented CC BY-SA 3.0 terms; audio has no proof.
- Godot built-ins only; no new addons.
- Static typing, English artifacts, explicit composition, no autoloads (see `AGENTS.md`).
- Phase 1 scope remains: no Conga rules, bots, multiplayer, ads, real purchases, or backend.
- Stable IDs come from catalog metadata, never from a file path or filename.
- Server owns price, availability, ownership, and rewards. A local `CosmeticDefinition` is never purchase authority.

## Source of truth

- `docs/Classic_Games_Online_GDD_TDD.md` sections 03, 07, 12, 13.
- `docs/audit/phase0.md`, `docs/adr/0006-asset-license-policy.md`, `docs/adr/0005-development-mocks-only.md`.
- `congauy/public/cards/ATTRIBUTION.md`, `congauy/public/cards/README.md`, `congauy/assets/cards-src/pack/README.md`.

## Delivery strategy

`single-pr`. New branch `feat/asset-catalog-pipeline` from the verified foundation head. Push and PR remain user decisions.

## Checklist

- [x] AP-1 Record ingestion audit with exact counts, hashes, dimensions, and per-group license status in `docs/audit/asset-ingestion.md`.
- [ ] AP-2 Build `client/assets/` taxonomy and copy the 50 free card PNGs with attribution, provenance, and manifest; no original modified.
- [ ] AP-3 Add `CosmeticDefinition`, `CosmeticCatalog`, acquisition tiers (`free`, `paid`, `ad_reward`), fallback resolution, and AppContext wiring.
- [ ] AP-4 Use local cosmetic previews in the shop and Conga game-detail screens without changing price or ownership authority.
- [ ] AP-5 Add headless tests for attribution completeness, stable IDs, tier filtering, fallback, and scene smoke.
- [ ] AP-6 Audio ingestion — BLOCKED: requires an explicit license decision from the user. Folder exists with a gate note; no audio file is copied until resolved.

## Acceptance criteria

| ID | Criterion | Check |
|----|-----------|-------|
| AC-1 | All 50 copied card PNGs match the source manifest SHA-256 and measure 160x247. | Hash verification script |
| AC-2 | Attribution text is present beside the artwork and names the documented authors and CC BY-SA 3.0. | File readback |
| AC-3 | No file under `congauy/` changed; no audio copied without a license decision. | `git status` in both repos + inventory |
| AC-4 | Acquisition tiers are explicit in resources and filterable without editing UI or wallet code. | Catalog unit test |
| AC-5 | Missing asset key resolves to a fallback definition. | Catalog unit test |
| AC-6 | Shop and game-detail previews use local resources while prices still come from the service port. | Scene smoke + code review |
| AC-7 | Full headless suite stays green. | `run_tests.gd` + parse sweep |

## Verification evidence

| Task | Command | Result | Commit |
|------|---------|--------|--------|
| AP-1 | `python3 -m py_compile client/tools/verify_card_assets.py` | exit 0, no output | `docs(assets): record ingestion audit and asset verifier` |
| AP-2 | `sha256sum -c` against copied manifest | pending | — |
| AP-3 | Godot headless parse | pending | — |
| AP-4 | scene instantiation | pending | — |
| AP-5 | `run_tests.gd` | pending | — |
| AP-6 | blocked | pending user decision | — |

## Progress and rationale

- 2026-11-25: read-only inspection confirmed 50 card PNGs at 160x247 with a pinned `manifest.json`; 49 source SVGs with verified `sources.sha256`; 17 audio files (13 OGG effects, 4 MP3 tracks, 28.7 MB) with no license text or tags. `HoliznaCC0` appears only in historical filenames and is not accepted as proof.
- The generated PNGs are deterministic and already optimized at 546,916 bytes total across 50 files; the 90 MB SVG pack stays in `art_source` territory and is not copied into the mobile build. The manifest sum and on-disk sum agree; an earlier 468,356-byte note does not match either measurement.
- Acquisition tier is metadata, not a duplicate file tree: paid and ad-reward folders exist with explicit gate notes so future assets can be added without changing screens.
- 2026-11-25 (AP-1): `docs/audit/asset-ingestion.md` records the deterministic pipeline, measured inventory, and per-group license status. `client/tools/verify_card_assets.py` uses only the Python stdlib and checks manifest presence, SHA-256, byte size, and PNG IHDR dimensions.

## Next step

Execute AP-2, then close it with a work-unit commit before starting AP-3. Ask the user for the audio license decision after the card pipeline is verified.

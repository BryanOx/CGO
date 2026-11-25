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
- [x] AP-2 Build `client/assets/` taxonomy and copy the 50 free card PNGs with attribution, provenance, and manifest; no original modified.
- [x] AP-3 Add `CosmeticDefinition`, `CosmeticCatalog`, acquisition tiers (`free`, `paid`, `ad_reward`), fallback resolution, and AppContext wiring.
- [x] AP-4 Use local cosmetic previews in the shop and Conga game-detail screens without changing price or ownership authority.
- [x] AP-5 Add headless tests for attribution completeness, stable IDs, tier filtering, fallback, and scene smoke.
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
| AP-2 | `python3 client/tools/verify_card_assets.py` | `Verified 50 card assets.` (exit 0); `cmp` matched all 53 copied source files; `congauy git status --short` empty before and after | `feat(assets): ingest free conga card art with attribution` |
| AP-3 | `check_parse.gd` + `--quit-after 5` | `Parse check: 61 GDScript files checked, 0 failures.` (exit 0); smoke exit 0, no `SCRIPT ERROR`; temporary resource probe printed the expected item ID, preview, tier, and attribution path | `feat(catalog): add cosmetic definitions with acquisition tiers` |
| AP-4 | `check_parse.gd`, `run_tests.gd`, temporary preview probe | `Parse check: 61 GDScript files checked, 0 failures.`; `Tests: 6 passed, 0 failed.`; shop textured previews: 1; detail textured previews: 1 | `feat(ui): show local cosmetic previews in shop and game detail` |
| AP-5 | `run_tests.gd` | `Tests: 8 passed, 0 failed.` (exit 0); parse `63 GDScript files checked, 0 failures.` | `test(assets): verify catalog tiers and asset licenses` |
| AP-6 | blocked | pending user decision | — |

## Final verification evidence (2026-11-25)

| Command | Exact result |
|---------|--------------|
| `python3 client/tools/verify_card_assets.py` | `Verified 50 card assets.` (exit 0) |
| `"$G" --headless --path client --editor --quit` | exit 0, no `SCRIPT ERROR`; Godot 4.7.2 first scan and class registration completed |
| `"$G" --headless --path client -s res://tools/check_parse.gd` | `Parse check: 63 GDScript files checked, 0 failures.` (exit 0) |
| `"$G" --headless --path client -s res://tests/run_tests.gd` | `Tests: 8 passed, 0 failed.` (exit 0) |
| `"$G" --headless --path client --quit-after 5` | exit 0, no `SCRIPT ERROR` |
| `git -C /home/bryan/Documentos/projects/congauy status --short` | no output (exit 0) |
| `git status --short` | only the five AP-5 files staged for this commit |
| `git log --oneline -6` | `22c4172`, `b232aeb`, `98eaac6`, `3c24cd7`, `20fa398`, `1f5bb10` |

## Progress and rationale

- 2026-11-25: read-only inspection confirmed 50 card PNGs at 160x247 with a pinned `manifest.json`; 49 source SVGs with verified `sources.sha256`; 17 audio files (13 OGG effects, 4 MP3 tracks, 28.7 MB) with no license text or tags. `HoliznaCC0` appears only in historical filenames and is not accepted as proof.
- The generated PNGs are deterministic and already optimized at 546,916 bytes total across 50 files; the 90 MB SVG pack stays in `art_source` territory and is not copied into the mobile build. The manifest sum and on-disk sum agree; an earlier 468,356-byte note does not match either measurement.
- Acquisition tier is metadata, not a duplicate file tree: paid and ad-reward folders exist with explicit gate notes so future assets can be added without changing screens.
- 2026-11-25 (AP-1): `docs/audit/asset-ingestion.md` records the deterministic pipeline, measured inventory, and per-group license status. `client/tools/verify_card_assets.py` uses only the Python stdlib and checks manifest presence, SHA-256, byte size, and PNG IHDR dimensions.
- 2026-11-25 (AP-2): copied 50 PNGs plus the four provenance files with `cp`; `cmp` reported no mismatch. `find client/assets` reports 63 files and zero audio files. Folder gate notes state that tier is metadata, prices and availability are server authority, audio stays excluded, and stable IDs are never filenames.
- 2026-11-25 (AP-3): added typed `CosmeticDefinition`, `CosmeticTiers`, and `CosmeticCatalog`; `manifest.tres` uses stable ID `conga_deck_classic_red` and resolves the CC BY-SA card back. `main.gd` builds the catalog from an explicit path array and assigns it to `AppContext.cosmetics` without changing `configure()`. Godot-generated `.uid` files are committed to match the existing script convention.
- 2026-11-25 (AP-4): shop rows resolve stable item IDs through `context.cosmetics` and show a `TextureRect` beside the item tile when a local preview exists. Game detail uses the free tier definition compatible with the current game and shows a muted label when no preview is available. Price, availability, purchase, equip, and wallet behavior are unchanged.
- 2026-11-25 (AP-5): added `test_cosmetic_catalog.gd` and `test_asset_licenses.gd`; all eight suites pass headlessly. Tests cover stable IDs, all three tiers, fallback, resource values, attribution text, 50 manifest PNGs, zero audio files, and filenames that never equal item IDs.
- AP-6 remains BLOCKED: the 17 source audio files have no verifiable license, so no audio file is copied and no audio decision is implied by this work.

## Next step

Ask the user for the audio license decision to unblock AP-6. Push and PR remain user decisions.

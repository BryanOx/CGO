# Asset ingestion audit: congauy card art and audio into CGO

This audit records the evidence used to ingest card artwork and audio from the
read-only `congauy` repository into `client/assets/`. It follows
`docs/adr/0006-asset-license-policy.md`: originals are never modified, a license
entry precedes any copy, and stable IDs never come from filenames. Audio
evidence is split: the OGG effects have a file-backed CC0 license, while the MP3
music is CC0 by explicit owner declaration.

## Measured source inventory

Measurements were taken from `/home/bryan/Documentos/projects/congauy` with
read-only commands. The source repository was clean before and after ingestion
(`git status --short` returned no lines on branch `main`).

| Group | Path | Count | Bytes | Dimensions | License status |
|-------|------|-------|-------|------------|----------------|
| Card PNGs | `public/cards/*.png` | 50 | 546,916 | 160x247 for all files | **Documented CC BY-SA 3.0** derivative work; `public/cards/ATTRIBUTION.md` names Basquetteur and gjenkins20. |
| Manifest | `public/cards/manifest.json` | 1 | — | — | Timestamp-free SHA-256, byte count, and width/height for all 50 PNGs. |
| Source SVG pack | `assets/cards-src/pack/*.svg` | 49 | about 90 MB | Original raster 207x319; viewBox 66.24x102.08 | **Documented CC BY-SA 3.0**; provenance pinned by commit `907391d14b2b2d2fe41ec61207186ed64a838886` and `assets/cards-src/sources.sha256`. Excluded from the export. |
| Joker source | `assets/cards-src/joker.svg` | 1 | — | — | User-provided without a formal license grant. The raster `joker.png` is covered by the documented card-PNG attribution chain, but the editable source is not copied. |
| Audio effects | `public/sounds/cards/*.ogg` | 13 | 141,147 | — | **Documented CC0.** Kenney Casino Audio 1.1 `License.txt` is copied verbatim; SHA-256 matches the original pack. Included. |
| Music | `public/sounds/music/*.mp3` | 4 | 28,573,300 | — | **Documented by user declaration (CC0).** No license file exists; evidence is the historical `HoliznaCC0` filename in `congauy/src/lib/audio.test.ts:5` and rename commit `7cb791d`. Included. |
| Scaffolding visuals | `public/og-image.png`, `public/favicon.ico`, `src/app/favicon.ico`, `public/*.svg`, `client/icon.svg` | — | — | — | **Unknown.** Framework/tooling or engine defaults with no attribution file. Excluded from ingestion. |
| Fonts | none | 0 | 0 | — | Not applicable. No font file is present in either repository. |

The figure 546,916 bytes is the sum of the 50 `bytes` values in the source
manifest and the sum of the 50 on-disk file sizes. An earlier note quoting
468,356 bytes does not match either measurement and is not used.

## Deterministic generation pipeline

The PNGs are committed build outputs, not artwork authored inside CGO. The
source pipeline is `scripts/generate-card-art.mjs` in `congauy`:

1. Prerequisites are Node 20+, pinned `sharp@0.35.4`, and `unzip`.
2. `npm run cards:generate` fetches the SVG pack at the pinned `PACK_SHA`
   `907391d14b2b2d2fe41ec61207186ed64a838886`, skipping the fetch when the
   extracted pack is already present.
3. All 49 pack files are verified against `assets/cards-src/sources.sha256`
   before any write; a mismatch aborts with `[cards:generate] FAIL <name>`.
4. The script rasterizes 50 PNGs at 160x247 px, flattened on white with palette
   quantization q90, renames pack files to the domain suit names, skips files
   whose SHA-256 already matches the manifest, deletes stray PNGs, and rewrites
   the timestamp-free manifest.
5. Reruns are byte-identical: running the pipeline twice leaves
   `git diff --exit-code public/cards` clean. Offline tests in
   `scripts/__tests__/generate-card-art.test.mjs` pin the 50-file inventory and
   assert manifest parity.

CGO does not run this Node pipeline. It copies the already optimized PNGs and
their provenance files verbatim, then validates them with the Python stdlib
verifier in `client/tools/verify_card_assets.py`.

## Audio license evidence

The two audio groups have deliberately different evidence standards. No license
is inferred from file possession or from a filename alone.

### Effects: file-backed CC0

The Kenney `License.txt` is the authoritative license for the 13 OGG effects.
It names "Casino Audio (1.1) by Kenney Vleugels (Kenney.nl)" and "License
(Creative Commons Zero, CC0)". Exact commands and results:

```bash
sha256sum /home/bryan/Descargas/kenney_casino-audio/License.txt client/assets/common/audio/effects/LICENSE.txt
# 3d9c53acb6e236d760da14030f54bc53e1d8c2599f78470c36b96fddcde09221  both paths

sha256sum /home/bryan/Documentos/projects/congauy/public/sounds/cards/*.ogg
# 13 hashes listed; total 141147 bytes

sha256sum client/assets/common/audio/effects/*.ogg
# identical 13 hashes

for f in /home/bryan/Documentos/projects/congauy/public/sounds/cards/*.ogg; do cmp "$f" "/home/bryan/Descargas/kenney_casino-audio/Audio/$(basename "$f")" || exit 1; done
# exit 0: 13 OGG files match the original Kenney pack byte-for-byte

python3 client/tools/verify_audio_assets.py
# Verified 17 audio assets. (exit 0)
```

### Music: owner declaration, not file-backed

No separate license file for the four MP3 tracks was found in either source
repository or in Downloads. The user declared them CC0 as the asset owner and
instructed that no audio be excluded. Supporting provenance:

- `congauy/src/lib/audio.test.ts:5` quotes the shipped filename
  `01 HoliznaCC0 - Dreams.mp3`.
- Commit `7cb791d` (`chore(sounds): rename music tracks to URL-safe slugs`)
  renamed the four tracks to URL-safe slugs; its message names
  `01 HoliznaCC0 - Dreams.mp3` and "friends".
- `congauy/openspec/changes/archive/2026-09-25-screen-shell-audio/tasks.md:80`
  records the full mapping: dreams, day-jobs, childhood, dancing.

The Kenney license covers the OGG effects only. No external HoliznaCC0 license
URL was verified, and none is claimed. The declaration, the credit, and the
SHA-256 pins are recorded in `client/assets/common/audio/music/`.

## Ingestion decisions

| Decision | Rationale |
|----------|-----------|
| Copy the 50 PNGs, `manifest.json`, `ATTRIBUTION.md`, and `README.md` verbatim. | Documented CC BY-SA 3.0 terms with mandatory attribution are recorded beside the files. |
| Add `attribution.txt` as a short derived credit line. | Makes the required credit visible to a client build without parsing Markdown. |
| Copy the 13 OGG effects with verbatim license and attribution. | Kenney Casino Audio 1.1 is CC0 by file-backed license; SHA-256 matches the original pack. |
| Copy the 4 MP3 tracks with owner-declaration attribution. | The user declared them CC0 as the asset owner; the historical `HoliznaCC0` name and rename commit support provenance. No separate license file was found and no external verification is claimed. |
| Exclude the 49 source SVGs and the joker source. | About 90 MB of editable sources belong in `art_source/` territory and stay outside the mobile export; checksums remain in `congauy`. |
| Exclude scaffolding visuals and fonts. | Unknown license status, or no eligible file at all. |
| Use catalog item IDs, never PNG names. | `CosmeticDefinition.item_id` is the stable identifier; filenames may be renamed or re-encoded. |
| Keep paid and ad-reward folders empty with gate notes. | Tier is metadata; price, availability, ownership, and rewards remain server authority. |

## Verification commands

Run from the repository root with the pinned Godot binary quoted:

```bash
python3 client/tools/verify_card_assets.py
python3 client/tools/verify_audio_assets.py
G="/home/bryan/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
"$G" --headless --path client --editor --quit
"$G" --headless --path client -s res://tools/check_parse.gd
"$G" --headless --path client -s res://tests/run_tests.gd
"$G" --headless --path client --quit-after 5
git -C /home/bryan/Documentos/projects/congauy status --short
git status --short
git log --oneline -6
```

The card verifier checks file presence, SHA-256, byte size, and the PNG IHDR
dimensions declared in the copied manifest. The audio verifier checks 13 OGG
effects and 4 MP3 music files against both manifests, the license and
attribution text, and the exclusion gate outside the two licensed folders. Any
mismatch produces a nonzero exit. The Godot commands must exit 0 with no
`SCRIPT ERROR` line, and the `congauy` status command must produce no output.

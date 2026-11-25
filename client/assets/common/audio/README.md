# Audio inventory

All 17 source audio files from `congauy` are present in the client. No original
file was modified.

## Effects

The 13 OGG card sound effects in `effects/` are licensed Creative Commons Zero
(CC0) and are verbatim copies from `congauy/public/sounds/cards/`. SHA-256 values
match the Kenney Casino Audio 1.1 originals in the downloaded pack.
`effects/LICENSE.txt` holds the verbatim Kenney license, `effects/ATTRIBUTION.md`
records the credit and verification method, and `effects/manifest.json` pins
SHA-256 and byte counts.

## Music

The 4 MP3 tracks in `music/` are verbatim copies from
`congauy/public/sounds/music/`. They are CC0 by user declaration as the asset
owner: no separate license file was found, and the Kenney license does not
cover them. `music/ATTRIBUTION.md` records the HoliznaCC0 credit, the historical
filenames, and the limits of the evidence; `music/manifest.json` pins SHA-256,
byte counts, and original filenames.

Run `python3 client/tools/verify_audio_assets.py` to verify all 17 files, both
manifests, the license and attribution text, and the exclusion gate.

Acquisition tier is metadata only; prices and availability remain server
authority. Stable IDs are never filenames.

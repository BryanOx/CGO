# Card Assets

This directory holds the 50 committed card images used by the app
(static, zero runtime fetch):

- `oros_1.png` … `oros_12.png`, `copas_1.png` … `copas_12.png`,
  `espadas_1.png` … `espadas_12.png`, `bastos_1.png` … `bastos_12.png` —
  the 48 natural cards, 160×247 px
- `back.png` — card back
- `joker.png` — our own joker art
- `manifest.json` — per-file sha256 + byte size + dimensions (no timestamp;
  used by the pipeline's skip-if-identical and by the offline inventory test)
- `ATTRIBUTION.md` — CC BY-SA 3.0 attribution (required — see License Compliance)

## Provenance

- Upstream pack: <https://github.com/gjenkins20/spanish-playing-cards-svg>
  (vector adaptation by gjenkins20 of Basquetteur's original art)
- Pinned commit (`PACK_SHA`): `907391d14b2b2d2fe41ec61207186ed64a838886`
- Source checksums: `assets/cards-src/sources.sha256` (49 hashes, sha256sum format)
- Own source: `assets/cards-src/joker.svg` (our joker, committed)
- Raw pack SVGs (~90 MB) are **not** committed — they are gitignored under
  `assets/cards-src/pack/` and reproduce on demand from the pinned commit.

## Regenerate

Prerequisites: Node 20+, `sharp@0.35.4` (pinned devDependency), `unzip`.

```sh
npm install
npm run cards:generate
```

The script:

1. Fetches the pack zip at the pinned `PACK_SHA` (skipped if already present)
   and extracts it to the gitignored `assets/cards-src/pack/`.
2. Verifies every one of the 49 pack files against
   `assets/cards-src/sources.sha256` **before writing anything** — any
   checksum mismatch aborts with `[cards:generate] FAIL <name>` and exit 1.
3. Renders the 50 PNGs at 160×247 (flattened white, palette q90), skipping
   files whose sha256 already matches `manifest.json`, deleting stray PNGs,
   and rewriting the timestamp-free manifest.

Reruns are byte-identical: run twice, then `git diff --exit-code public/cards`.

## Tests

The offline pipeline tests live in `scripts/__tests__/generate-card-art.test.mjs`
(`npm test`):

- pins the 50-filename inventory (literal, spec-pinned)
- asserts committed inventory === manifest (sha256, bytes, 160×247, no strays)
- proves a tampered source fails loudly (exit non-zero, no writes)

## License

The card PNGs are CC BY-SA 3.0 derivatives — see `ATTRIBUTION.md`. The app
code keeps its own license.
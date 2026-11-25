# Attribution — Card Art

The PNG files in this directory (`public/cards/*.png`) are **derivative works**
of the Spanish-playing-cards SVG pack, reproduced here at 160×247 px via the
deterministic pipeline in `scripts/generate-card-art.mjs`.

## License: CC BY-SA 3.0

**The card PNGs in this directory are licensed under the
[Creative Commons Attribution-ShareAlike 3.0 Unported License](https://creativecommons.org/licenses/by-sa/3.0/)** —
this applies to `back.png`, the 48 suit PNGs, and `joker.png`'s use of the
pack's card design language.

This license is **separate from the license of the congauy application itself**.
The app code is not a derivative of this artwork and keeps its own licensing;
only the rasterized card images inherit the CC BY-SA 3.0 share-alike terms.

## Attribution chain

| Role | Author | Source |
|---|---|---|
| Original artwork | **Basquetteur** | [Wikimedia Commons — Spanish playing cards](https://commons.wikimedia.org/wiki/Category:Spanish_playing_cards) |
| Vector adaptation | **gjenkins20** | [spanish-playing-cards-svg](https://github.com/gjenkins20/spanish-playing-cards-svg) |

Recommended credit line (per upstream README):

```
Spanish playing card artwork by Basquetteur (Wikimedia Commons)
Vector adaptation by gjenkins20 (spanish-playing-cards-svg)
Rasterized to PNG by the congauy card-art pipeline.
Licensed under CC BY-SA 3.0
https://creativecommons.org/licenses/by-sa/3.0/
```

## Changes made (adaptation)

- The pack's SVGs were **rasterized and re-encoded** to 160×247 px PNGs at
  quality ~90 (`sharp`, librsvg): this is a transformation/adaptation of the
  original work.
- Pack filenames were **renamed to the app's domain suits**: `card_coins_*` →
  `oros_*`, `card_cups_*` → `copas_*`, `card_swords_*` → `espadas_*`,
  `card_clubs_*` → `bastos_*`, `card_back.svg` → `back.png`.
- `joker.png` is rasterized from **our own artwork**
  (`assets/cards-src/joker.svg`), authored for this project in the pack's
  simple style. We consider it our own original contribution; it echoes the
  pack's design language for visual consistency without copying pack content.

## Reproducibility

The exact upstream sources are pinned by commit hash and checksum:

- Upstream: `https://github.com/gjenkins20/spanish-playing-cards-svg`
- Pinned commit: `907391d14b2b2d2fe41ec61207186ed64a838886`
- Checksums: `assets/cards-src/sources.sha256` (49 files)

Any regeneration must use these pinned sources so the share-alike provenance
remains verifiable. See `README.md` in this directory.
# Client assets

This tree holds packaged visual resources used by the Godot client. Only files
with a recorded license entry are copied here. The complete evidence is in
`docs/audit/asset-ingestion.md`.

## Layout

| Path | Purpose |
|------|---------|
| `common/` | Cross-game resources. Audio and font folders are gate notes only. |
| `cards/` | Card artwork grouped by game and deck. |
| `boards/` | Reserved for board artwork; no assets yet. |
| `cosmetics/` | Declarative cosmetic catalog resources grouped by acquisition tier. |

## Ingestion rules

- A license entry and attribution must exist before any source asset is copied.
- Original files in the read-only `congauy` repository are never modified, moved, or regenerated inside CGO.
- Audio stays excluded until an explicit license decision is made. No audio file belongs in this tree yet.
- Stable IDs are defined by catalog metadata (`CosmeticDefinition.item_id`); filenames are never commercial IDs or availability keys.
- Acquisition tier is metadata only. Prices, availability, ownership, and rewards are server authority; local resources resolve visuals only.
- Editable sources stay outside the export in `art_source/` territory. The 49 source SVGs are not copied into the client.

The first licensed entry is `cards/conga/classic_red/`, containing 50 PNGs at
160x247 with CC BY-SA 3.0 attribution to Basquetteur and gjenkins20.

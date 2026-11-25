# Paid cosmetics (reserved)

This folder is intentionally empty of asset files. A future paid item needs a
recorded license, attribution, and a `CosmeticDefinition` with a stable ID that
is never a filename.

Tier is metadata only. The server owns price, availability, ownership, and
idempotent purchase validation; no Phase 1 code debits a wallet or grants an
item from this folder.

All 17 licensed audio assets now live under `res://assets/common/audio/` (13 CC0
Kenney effects with SHA-256 proof and 4 owner-declared CC0 HoliznaCC0 tracks);
see `docs/adr/0006-asset-license-policy.md`; no audio belongs in this paid folder.

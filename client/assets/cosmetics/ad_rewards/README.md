# Ad-reward cosmetics (reserved)

This folder is intentionally empty of asset files. A future rewarded item needs
a recorded license, attribution, and a `CosmeticDefinition` with a stable ID
that is never a filename.

Rewarded grants require a server-verified SSV receipt with a valid intent and
deduplicated transaction ID. A local file or a client callback never grants an
item. Tier is metadata only; price and availability remain server authority.
No ad SDK or reward behavior exists in Phase 1.

All 17 licensed audio assets now live under `res://assets/common/audio/` (13 CC0
Kenney effects with SHA-256 proof and 4 owner-declared CC0 HoliznaCC0 tracks);
see `docs/adr/0006-asset-license-policy.md`; no audio belongs in this ad-reward folder.

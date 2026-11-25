# Cosmetic catalog resources

This tree mirrors acquisition tiers without duplicating artwork:

| Tier | Folder | Status |
|------|--------|--------|
| `free` | `free/` | One Conga deck definition is packaged with the build. |
| `paid` | `paid/` | Reserved; no assets or purchase behavior yet. |
| `ad_reward` | `ad_rewards/` | Reserved; no assets or reward behavior yet. |

A `CosmeticDefinition` resolves visuals only. Tier is metadata, not an ownership
or purchase grant: prices, availability, ownership, and rewards are server
authority. Local resources never grant an item or change a wallet balance.

Stable IDs such as `conga_deck_classic_red` are defined in resources; filenames
are never used as commercial IDs. All 17 licensed audio assets now live under
`res://assets/common/audio/` (13 CC0 Kenney effects with SHA-256 proof and 4
owner-declared CC0 HoliznaCC0 tracks); see `docs/adr/0006-asset-license-policy.md`;
no audio belongs in this cosmetics tree.

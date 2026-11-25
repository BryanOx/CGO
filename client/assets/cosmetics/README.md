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
are never used as commercial IDs. Audio stays excluded until a license decision
is made.

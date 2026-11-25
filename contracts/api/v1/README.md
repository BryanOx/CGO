# API v1 contract (client-facing specification)

This is a specification only. No server code, database, or real transport is implemented in Phase 1. The client reaches these endpoints through `BackendConfig.endpoint()`; changing the base URL never touches business logic (ADR-0003, AC-3).

## Quick path

1. Change only `client/app/backend_config.tres` to point at a different backend.
2. Read the REST table for resource operations and the WebSocket section for match sessions.
3. Check `docs/adr/0003-backend-endpoint-and-transport.md` and `0009-deployment-boundary.md` before extending the contract.

## Conventions

| Rule | Requirement |
|------|-------------|
| Prefix | All REST paths start with `/v1/`; the client never embeds the prefix in a service call. |
| DTOs | Typed fields validated by allowlist on the server. Unknown fields are rejected. |
| Identity | The authenticated subject comes from the token, never from a `user_id` request field. |
| Mutations | Financial writes require `Idempotency-Key`; a repeated key with a different payload returns a conflict. |
| Pagination | Catalogs and rankings use cursor pagination. |
| Errors | Typed codes with a stable machine-readable `error_code`. |
| Transport | HTTPS for REST; native Godot WebSocket for match sessions. Socket.IO is not part of this contract. |

## REST endpoints

| Method | Path | Purpose | Phase |
|--------|------|---------|-------|
| POST | `/v1/auth/guest` | Start a recoverable guest session. | 1 (mocked) |
| POST | `/v1/auth/link` | Link a guest identity to a durable account. | 3 |
| GET | `/v1/me` | Read the authenticated profile. | 1 (mocked) |
| GET | `/v1/games` | List enabled game definitions. | 1 (local registry) |
| POST | `/v1/matchmaking` | Request a casual match. | 3 |
| DELETE | `/v1/matchmaking/:id` | Cancel a request idempotently. | 3 |
| POST | `/v1/rooms` | Create a private room. | 3 |
| POST | `/v1/rooms/:code/join` | Join a private room. | 3 |
| GET | `/v1/rankings/:game` | Read a ranked leaderboard page. | 1 (mocked), ranked writes gated to 6 |
| GET | `/v1/wallet` | Read the authoritative balance. | 1 (mocked) |
| GET | `/v1/catalog` | Read active shop offers. | 1 (mocked) |
| POST | `/v1/shop/purchases` | Purchase with idempotency key. | 4 |
| GET | `/v1/inventory` | Read owned and equipped items. | 1 (mocked) |
| PUT | `/v1/equipment/:slot` | Equip an owned cosmetic. | 4 |
| POST | `/v1/ads/intents` | Reserve a rewarded-ad intent. | 5 |
| GET | `/v1/rewards/:id` | Query a reward claim. | 5 |
| GET | `/v1/webhooks/admob` | Server-side verification callback; never called by the client. | 5 |

Only rows marked Phase 1 are wired to client ports today. The rest are reserved names so adapters can be added without changing screens.

## Read DTOs

| DTO | Fields |
|-----|--------|
| `GuestSessionDTO` | `user_id: string`, `token_expires_in: int` |
| `ProfileDTO` | `id: string`, `display_name: string`, `level: int` |
| `GameDTO` | `id: string`, `display_name: string`, `rules_version: string`, `modes: string[]`, `capabilities: string[]` |
| `WalletDTO` | `balance: int`, `currency: string` |
| `CatalogItemDTO` | `item_id: string`, `name: string`, `price: int`, `game_id: string`, `catalog_version: int`, `active: bool` |
| `InventoryItemDTO` | `item_id: string`, `equipped: bool`, `slot: string` |
| `RankingRowDTO` | `rank: int`, `player: string`, `score: int` |

`price` and `catalog_version` come from the server. A client-side `CosmeticDefinition` resolves visuals only; it is never purchase authority.

## Match-session WebSocket protocol

| Direction | Message | Fields |
|-----------|---------|--------|
| Client → server | `join` | `match_id`, `last_seq`, `protocol_version` |
| Server → client | `snapshot` | `seq`, `rules_version`, `visible_state` |
| Client → server | `action` | `action_id`, `expected_seq`, `type`, `payload` |
| Server → client | `ack` | `action_id`, `seq` |
| Server → client | `reject` | `code`, `current_seq` |
| Server → client | `event` / `snapshot` | `seq`, `visible_state` |
| Client → server | `resume` | `match_id`, `last_seq` |

The server owns the clock, the deck, the result, and the filtered snapshot. Reconnection uses backoff and jitter; a repeated `action_id` must not apply twice. No session messages are sent in Phase 1.

## Error codes

| Code | Meaning |
|------|---------|
| `INVALID_REQUEST` | Field, type, or payload outside the allowlist. |
| `UNAUTHORIZED` | Missing, expired, or revoked credentials. |
| `NOT_FOUND` | Unknown resource. |
| `PRICE_CHANGED` | Catalog version moved; client must ask for confirmation again. |
| `STALE_SEQUENCE` | Action seq no longer matches the authoritative snapshot. |
| `CONFLICT` | Idempotency key reused with a different payload. |

## Deployment boundary

The backend is deployed later on Ubuntu Server under systemd. Only the API is exposed through ngrok or Cloudflare Tunnel. The client stores a base URL and an API version; it never stores tunnel tokens, admin credentials, or database details. Confirm the tunnel hostname by changing `BackendConfig.base_url`, not by editing service code.

## Verification

- `godot --headless --path client -s res://tests/run_tests.gd` — config and composition tests cover endpoint composition and environment gating.
- ADR-0003 records why Socket.IO is not adopted; any future change requires a new ADR with a documented technical need.
- No real endpoint is contacted in Phase 1; development composition uses deterministic mocks.

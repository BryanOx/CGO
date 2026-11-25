# ADR-0003 — Backend configuration and transport

Accepted · 2026-11-25 · Supersedes nothing

**Decision: one `BackendConfig` resource owns the base URL, API version, timeout, and environment; REST serves profile/shop/catalog/wallet, native WebSocket serves match sessions, and Socket.IO is NOT adopted.**

## Context

- The requirements specify REST for profile, shop, and ranking plus WebSocket for match sessions with a versioned protocol and validated DTOs (`docs/Classic_Games_Online_GDD_TDD.md:80`, `:298-325`).
- The audit records that the endpoint must be configuration, not business logic (`docs/audit/phase0.md:93`).
- Godot provides a native WebSocket client; no Phase 1 requirement needs a second bidirectional protocol layer.

## Decision

| Item | Choice |
|------|--------|
| Configuration | A single `BackendConfig` resource holds `base_url`, `api_version`, `timeout`, and `environment` (the last used by ADR-0005). |
| REST | Profile, shop, catalog, and wallet read/write operations use REST with versioned paths and validated DTOs. |
| WebSocket | Match sessions use Godot's native WebSocket client with versioned messages and server-authoritative snapshots. |
| Socket.IO | NOT adopted. Native WebSocket support exists and no bidirectional requirement justifies an extra protocol layer; future adoption requires a documented technical need approved by a new ADR. |
| Scope | No backend implementation in Phase 1; adapters consume configuration only. |

## Consequences

- Changing `BackendConfig.base_url` changes no business-logic file, satisfying AC-3.
- Adapters never hardcode endpoints or timeouts; protocol version mismatches are explicit errors.
- Session concerns such as reconnection, sequence numbers, and ACK persistence remain Phase 3 work.
- A Socket.IO proposal must first show a technical need that native WebSocket cannot meet.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Socket.IO | Extra protocol layer without a documented technical need; no client-side requirement in Phase 1. |
| Hardcoded endpoints | Couples configuration to business logic and breaks AC-3. |
| WebSocket for catalog and wallet | Mixes server-authoritative session transport into simple resource requests. |

## Verification

- AC-3 (switching `BackendConfig.base_url` changes no business-logic file) via config test plus this ADR.
- AC-8 (no multiplayer implementation in Phase 1) via scope diff review.
- P1-2 and P1-3 Godot headless parse of config and adapter scripts.
- P0-2 document readback: this record is present in `docs/adr/README.md`.

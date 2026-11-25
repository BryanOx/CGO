# ADR-0009 — Deployment boundary

Accepted · 2026-11-25 · Supersedes nothing

**Decision: the backend is deployed later on Ubuntu Server under systemd; only the API is exposed through ngrok or Cloudflare Tunnel; the client stores only a configurable base URL and never embeds credentials or tunnel details.**

## Context

- The requirements place the backend in a monorepo with a single API/WS process, TLS proxying, server-side secrets, and validation of environment configuration (`docs/Classic_Games_Online_GDD_TDD.md:251-282`, `:418-430`).
- Backend work is scheduled for Phase 3, after the foundation and vertical slice (`docs/Classic_Games_Online_GDD_TDD.md:471-480`).
- AC-3 requires endpoint changes to stay out of business logic, and AC-8 excludes backend gameplay from Phase 1 (`odd/tasks/platform-foundation.md:59`, `:64`).

## Decision

| Item | Choice |
|------|--------|
| Deployment | Later phase: Ubuntu Server with systemd managing the API/WS process. |
| Exposure | API only, through ngrok or Cloudflare Tunnel; no direct database or internal port exposure. |
| Client config | `BackendConfig.base_url` only; no credentials, API keys, or tunnel details in the client or export. |
| Phase 1 | No backend code, migrations, server modules, or tunnel configuration are written. |

## Consequences

- Development and production endpoints differ by configuration, supporting AC-3.
- Server authority, persistence, and reconnection remain unverified until the backend phase.
- Tunnel selection and systemd units are operator decisions deferred to deployment.
- Secrets stay server-side; public builds contain no administrative credentials.

## Alternatives

| Option | Why rejected |
|--------|--------------|
| Embed tunnel URL and credentials in the client | Exposes secrets and couples builds to an operator environment. |
| Deploy backend in Phase 1 | Violates AC-8 and the phase plan. |
| Expose database or internal services publicly | Unnecessary attack surface; only the API is required. |

## Verification

- AC-3 (switching `BackendConfig.base_url` changes no business-logic file) via config test plus this ADR.
- AC-8 (no Conga rules, bots, multiplayer, ads, or purchases) via scope diff review.
- P0-2 document readback: this record is present in `docs/adr/README.md`.

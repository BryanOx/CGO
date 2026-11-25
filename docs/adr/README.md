# Architecture Decision Records

Phase 0 decisions for the Platform Foundation feature. Each record states one decision, its evidence, its consequences, and the tracker criterion or command that verifies it. Read the records in order before touching client code.

## Quick path

1. Read ADR-0001 through ADR-0009 in the order below.
2. Check the gates in `docs/audit/phase0.md` before reusing any asset or porting rules.
3. Verify the document set with the readback command in `odd/tasks/platform-foundation.md` (P0-2).

## Index

| ADR | Decision | Tracker link |
|-----|----------|--------------|
| [0001](0001-godot-version-and-renderer.md) | Pin Godot 4.7.2 stable; keep the Mobile renderer, reversibly. | AC-6, AC-8, P0-2 readback |
| [0002](0002-layered-architecture-and-ports.md) | Domain / application / ports / infrastructure with inward dependencies and explicit injection. | AC-2, AC-6, AC-8 |
| [0003](0003-backend-endpoint-and-transport.md) | One `BackendConfig` resource; REST plus native WebSocket; no Socket.IO. | AC-3, AC-8 |
| [0004](0004-design-system-and-mobile-layout.md) | Centralized tokens, generated Theme, 360x800 baseline, safe areas, 48 dp targets. | AC-7, AC-5, AC-6 |
| [0005](0005-development-mocks-only.md) | Mocks only when `BackendConfig.environment == "development"`; behavior is the gate. | AC-4, P1-3 parse |
| [0006](0006-asset-license-policy.md) | No original modified; licensed assets only; CC0 audio with split evidence; stable IDs. | AC-1 |
| [0007](0007-modular-game-registry.md) | Immutable `GameDefinition` resources in `GameRegistry`; Conga is metadata plus placeholder. | AC-2, AC-8 |
| [0008](0008-headless-verification.md) | Godot 4.7.2 headless only; small in-repo GDScript runner; no GUT or external dependency. | AC-5, AC-6, P1-6 |
| [0009](0009-deployment-boundary.md) | Later Ubuntu Server/systemd backend; API exposed via tunnel; client stores a base URL only. | AC-3, AC-8, P0-2 readback |

## Conventions

Each record uses the same five sections: Context, Decision, Consequences, Alternatives, Verification. Status is Accepted unless a later ADR explicitly supersedes it. Supersession requires a new numbered record that names the decision it replaces; no decision here silently edits `client/project.godot` or an original asset.

## Next step

Implement Phase 1 from `odd/tasks/platform-foundation.md`; keep these records and `docs/audit/phase0.md` as the input to that work.

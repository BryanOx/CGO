# Repository rules

These rules are mandatory for every contributor and agent in this repository. Phase 1 builds the foundation only: no Conga rules, bots, multiplayer, ads, purchases, or backend implementation.

## Quick path

1. Read `docs/Classic_Games_Online_GDD_TDD.md` sections 01-04, 06-09, and 15-17, then `docs/adr/README.md` and ADR-0001 through ADR-0009.
2. Read `odd/tasks/platform-foundation.md` and work only on the task assigned to you.
3. Change files inside your folder ownership, run the verification commands, and close the task with one conventional commit.

## Mandatory rules

| Rule | Requirement |
|------|-------------|
| Read before code | The GDD, the ADRs, and the task tracker are inputs to every change. Do not invent Conga rules or SDK APIs. |
| Static typing | Every GDScript variable, parameter, and return value is explicitly typed. Use `StringName` with `&"..."` literals for stable IDs. |
| Dependency direction | Dependencies point inward: infrastructure → application → domain. Domain code never imports scenes, HTTP clients, SDKs, or gameplay autoloads. |
| Composition | Inject dependencies through constructors or configuration. There is no monolithic autoload and no gameplay manager. |
| Folder ownership | Stay inside the folders assigned to your task. Do not create empty placeholder folders or cross-game imports. |
| Phase 1 scope | No Conga rules, bots, multiplayer, advertisements, purchases, or backend code. Conga is metadata plus a non-playable placeholder. |
| Asset license gate | No original asset is modified. No asset from `congauy` enters `client/assets/` without a recorded license entry. Audio stays excluded until licensed. |
| No destructive edits | Treat files under `/home/bryan/Documentos/projects/congauy` and `client/icon.svg` as read-only. Never overwrite original sources. |
| Built-ins only | No third-party Godot dependencies, addons, or test frameworks. Godot 4.7.2 built-ins only. |
| Test evidence | Record exact commands and results in `odd/tasks/platform-foundation.md`. Never claim CI is green without evidence. |
| Commits | One conventional commit per work unit (`feat:`, `fix:`, `chore:`, `docs:`, `test:`). Include tracker evidence and tests with the behavior they verify. Do not add AI attribution trailers. |

## Folder ownership

| Path | Responsibility |
|------|----------------|
| `app/` | Composition root, router, screen contracts, and configuration resources. |
| `core/ports/` | Service contracts and fail-explicit base implementations. |
| `core/domain/` | Game-agnostic state contracts. No scenes or transport. |
| `core/application/` | Registries and application-level coordination. |
| `core/infrastructure/` | Mock, remote, and local storage adapters. |
| `games/<game>/` | One game module: domain, application, presentation, and content. |
| `shared/theme/` and `shared/ui/` | Centralized design tokens, generated Theme, and reusable controls. |
| `tools/` | In-repo validation scripts. |
| `tests/` | Headless runner and checks. Created by the test owner, not by feature writers. |
| `contracts/` | Frozen reference fixtures. Read-only after a phase freeze. |
| `docs/` and `odd/` | Evidence, decisions, and the task tracker. |

## Verification commands

Set the pinned binary once per shell. It has a space in its path, so always quote the variable.

```bash
G="/home/bryan/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"

"$G" --headless --path client --editor --quit
"$G" --headless --path client -s res://tools/check_parse.gd
"$G" --headless --path client -s res://tests/run_tests.gd
python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null
```

The first command registers classes and imports resources. The second is the parse sweep. The third is the in-repo test runner. All must exit 0; any `SCRIPT ERROR` line is a failure.

## Checklist

- [ ] The change touches only owned folders and creates no empty directories.
- [ ] GDScript is fully typed and uses `StringName` IDs.
- [ ] No Phase 1 scope violation and no unlicensed asset was added.
- [ ] Exact verification output is recorded in the tracker before commit.

## Next step

Start from the first unchecked task in `odd/tasks/platform-foundation.md`.

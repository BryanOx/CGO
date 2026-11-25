# Phase 0 audit: repository, Conga rules, assets, and toolchain

Phase 0 closed with evidence. No original asset was modified and no game logic was ported. This document is the input for the Phase 1 architecture decisions in `docs/adr/`.

## Quick path

1. Read the repository inventory table to understand what exists.
2. Read the asset license table before adding any visual resource to `client/assets/`.
3. Apply the pending validations as gates before Phase 2.

## Repository inventory

| Repository | Path | Nature | Phase 0 use |
|------------|------|--------|-------------|
| CGO | `/home/bryan/Documentos/projects/CGO` | Bare Godot 4.7 skeleton. `docs/Classic_Games_Online_GDD_TDD.md`, `client/project.godot`, `client/icon.svg`. No Git history, no scenes, no `.gd` files. | Target platform. Read-only audit of the skeleton. |
| congauy | `/home/bryan/Documentos/projects/congauy` | Next.js 16 App Router, React 19, TypeScript, Tailwind v4, Zustand, Firebase, Vitest. Remote `github.com/BryanOx/conga-uy.git`. | Reference for rules and asset provenance only. Not a Godot codebase and not a drop-in port. |

Evidence: `congauy/README.md:1-6`, `congauy/package.json:2-22`, `congauy/src/app/page.tsx:5-10`, `CGO/client/project.godot:9-28`.

Routes in congauy: `src/app/juego/page.tsx`, `src/app/sala/page.tsx`, `src/app/sala/[codigo]/page.tsx`. There is no `project.godot` and no `.gd` file in that repository.

## Toolchain

| Item | Verified value | Evidence |
|------|----------------|----------|
| Godot binary | `/home/bryan/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64` | `--headless --version` |
| Godot version | `4.7.2.stable.official.ed1daf0bf` | Same command; matches `client/project.godot:14` feature `4.7` |
| Duplicate binary | `/home/bryan/Documentos/godot-projects/cat-game/.godot/odd-engine/godot`, same version | File inspection |
| PATH availability | No `godot`, `godot4`, or headless alias on `PATH` | `command -v` sweep |
| Renderer in skeleton | `renderer/rendering_method="mobile"` | `client/project.godot:28` |
| Renderer proposed by spec | Compatibility initially | Requirements doc line 74 |
| Stretch | `canvas_items` / `expand` | `client/project.godot:19-20` |
| Node / npm | Available via nvm (`v26.5.0`) | `command -v` |
| Skill registry | None in CGO or global skills dir; only `skill-registry/SKILL.md` and `_shared/skill-resolver.md` exist | Filesystem inspection |

The renderer discrepancy is a decision, not an error to silently patch. It is recorded in ADR-0001.

## Conga rules baseline (reference only)

These facts are recorded so Phase 2 ports observed behavior instead of invented rules. No rule is implemented in Phase 1.

| Topic | Observed behavior | Evidence |
|-------|-------------------|----------|
| Deck | 48 naturals: 4 suits x ranks 1-12, plus 2 jokers = 50 cards | `congauy/src/domain/cards.ts:6-25`, `:55-69` |
| Suits | `oros`, `copas`, `espadas`, `bastos` | Same file |
| Players and hand | 2-6 players, 7 cards per hand | `congauy/src/domain/match.ts:38-40` |
| Round flow | `Deal(seed) -> RoundStart(mano receives 8th card) -> Turn(draw -> meld -> discard) -> CanCut? -> Score` | `congauy/src/domain/match.ts:4`, `:186-220` |
| Turn advance | Discard increments `turnsTaken` and advances `turnPlayer` | `congauy/src/domain/match.ts:520-548` |
| House rules | 13 toggles with Uruguayan defaults | `congauy/src/domain/rules.ts:13-57` |
| Melds | 3-7 card `trio`, `escalera`, `conga` | `congauy/src/domain/melds.ts:66-115` |
| Cut legality | Explicit predicate in the domain, not in UI | `congauy/src/domain/cut.ts:39-76` |
| Scoring | Deadwood; clean 7-run is instant `chinchon`; `menos diez` gives -10; elimination when cumulative score exceeds the limit | `congauy/src/domain/scoring.ts:46-105` |
| Other pure modules | `actions.ts`, `bot.ts`, `shuffle.ts`, `exhaustion.ts`, `projection.ts` | `congauy/src/domain/` |
| Tests | 71 `*.test.ts` / `*.tsx` / `*.mjs` files | File count |

The pure TypeScript modules are a suitable source for deterministic fixtures. Parity tests between a future GDScript engine and this TypeScript engine remain a Phase 2/3 gate; they are not started here.

## Asset inventory and license status

### CGO

| Asset | Path | Status |
|-------|------|--------|
| Default Godot icon, 128x128 SVG | `client/icon.svg`, `client/icon.svg.import` | Engine default. No license, README, or attribution file in CGO. |

No fonts, audio, `.tres`, or `.tscn` resources exist in CGO.

### congauy card art

| Asset group | Path | Dimensions | License |
|-------------|------|------------|---------|
| 50 card PNGs (48 suits, back, joker) | `congauy/public/cards/` | 160x247 | **CC BY-SA 3.0**, derivative work. Attribution to Basquetteur and gjenkins20 is mandatory. Evidence: `public/cards/ATTRIBUTION.md:7-33`. |
| 49 source SVGs + joker source | `congauy/assets/cards-src/pack/`, `congauy/assets/cards-src/joker.svg` | Original raster 207x319 per `assets/cards-src/pack/README.md:26-30` | Same provenance chain; pinned hashes in `assets/cards-src/sources.sha256`. |
| Manifest and provenance | `congauy/public/cards/README.md:1-59` | — | Read before any reuse. |

### congauy other assets

| Asset group | Path | License status |
|-------------|------|----------------|
| Open Graph image, 1200x630 | `congauy/public/og-image.png` | Unknown; no attribution found. |
| Favicons, 27x32 | `congauy/public/favicon.ico`, `congauy/src/app/favicon.ico` | Unknown; no attribution found. |
| Utility SVGs (`file`, `globe`, `next`, `vercel`, `window`) | `congauy/public/*.svg` | Unknown; framework/tooling defaults. |
| 13 OGG effects, about 172 KB total | `congauy/public/sounds/cards/` | Unknown. No formal license file; `src/lib/audio.test.ts:4-8` only references an original filename containing `HoliznaCC0`, which is not proof of licensing. |
| 4 MP3 tracks, about 28 MB | `congauy/public/sounds/music/` | Unknown. Same caveat. |
| Fonts | None in either repository | N/A |

## Decisions forced by this audit

| ID | Decision |
|----|----------|
| ADR-0001 | Pin Godot 4.7.2 stable and resolve the renderer discrepancy explicitly. |
| ADR-0002 | Layers and ports keep rules, transport, and UI independent. |
| ADR-0003 | Backend endpoint is configuration; REST plus native WebSocket contracts; no Socket.IO. |
| ADR-0004 | Cockpit theme and mobile layout are generated from centralized tokens. |
| ADR-0005 | Mock services are development-only; production composition wires adapters. |
| ADR-0006 | No asset is copied into the client until its license is recorded. |
| ADR-0007 | Games are registered by immutable definitions, not by hardcoded screen maps. |
| ADR-0008 | Headless Godot is the verification harness; no external test dependency. |

## Pending validations (gates, not blockers for Phase 1)

- [ ] Confirm audio licensing before any sound is reused. Until then, no congauy audio enters `client/assets/`.
- [ ] Confirm that CC BY-SA 3.0 attribution and share-alike terms are acceptable for the target distribution before reusing card art.
- [ ] Confirm Godot export templates for Android/iOS on the target build machine; none were verified in Phase 0.
- [ ] Confirm a concrete ad SDK only in Phase 5. No SDK is selected now.
- [ ] Confirm signature, privacy, and billing requirements before any store submission.

## Next step

P0-2: write the ADR set that records the decisions above, then close P0-1 and P0-2 as work-unit commits on the feature branch.

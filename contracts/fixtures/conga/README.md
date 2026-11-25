# Conga rules baseline (reference-only)

`rules-baseline.json` freezes only the Conga facts already verified in `docs/audit/phase0.md:38-56`. No Conga rules, bots, or multiplayer are derived from it in Phase 1 (AC-8).

## Quick path

1. Read the audit evidence in `docs/audit/phase0.md:38-56` before using any value.
2. Validate the file: `python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null`.
3. Do not import these values into client code during Phase 1; this is a reference baseline.

## Frozen facts

| Group | Content | Audit evidence |
|-------|---------|----------------|
| Deck | 48 naturals (4 suits x ranks 1-12) plus 2 jokers = 50 cards | `docs/audit/phase0.md:44` |
| Suits | `oros`, `copas`, `espadas`, `bastos` | `docs/audit/phase0.md:45` |
| Players and hand | 2-6 players, 7 cards per hand | `docs/audit/phase0.md:46` |
| Round flow | Deal, RoundStart eighth card, draw-meld-discard turn, cut question, score; discard advances the turn | `docs/audit/phase0.md:47-48` |
| Melds | 3-7 card `trio`, `escalera`, `conga` | `docs/audit/phase0.md:50` |
| Cut legality | Explicit domain predicate, not UI logic | `docs/audit/phase0.md:51` |
| Scoring | Deadwood, clean 7-run instant `chinchon`, `menos diez` -10, elimination above the cumulative limit | `docs/audit/phase0.md:52` |
| House rules | 13 toggles with Uruguayan defaults | `docs/audit/phase0.md:49` |

The JSON `source` object carries both audit line references and the upstream congauy paths recorded by the audit. Paths beginning with `congauy/` belong to the read-only reference repository, not to this repository.

## Behavioral examples

`behavioral_examples` is empty. The authoritative audit does not name a congauy test file with a deterministic example transcribed verbatim, so no example is invented here. Behavioral fixtures are frozen in Phase 2, together with parity tests. No card IDs, scores, or seeds are invented in this file.

## Status and verification

`phase` is `reference-only` and `status` states that no Conga implementation is derived from this file in Phase 1. Validation result for P0-3: `python3 -m json.tool contracts/fixtures/conga/rules-baseline.json >/dev/null` exits 0 with no output.

## Next step

Keep this file frozen until Phase 2; port rules and capture deterministic examples only when the Conga vertical slice opens.

# Joker Idea: Polychrome Ability Copying

[Back to the Joker idea index](../NEW_JOKER_IDEAS.md)

## Confirmed Concept

A Legendary Joker copies the abilities of all owned Polychrome Jokers.

Only Blueprint-compatible abilities are eligible. Polychrome Jokers whose abilities are not Blueprint-compatible are excluded.

The copying Joker always excludes itself from its targets, even if it becomes Polychrome.

Stop any copy chain when it would revisit a Joker already being evaluated in that chain. This prevents indirect loops through Blueprint, Brainstorm, or other copying Jokers. Track the active chain rather than blocking a card globally for the entire event, so separate valid activations can still occur.

Blueprint may copy the Legendary Joker normally; only cyclic paths are blocked.

Evaluate eligible copied abilities from left to right, following the owned Jokers' positions.

Debuffed Jokers are excluded from the copied targets.

Copy abilities only, not edition bonuses. In particular, do not copy the Polychrome edition's XMult bonus.

Confirmed example: with this Legendary Joker, a Polychrome Blueprint targeting it, and a Polychrome Mult-producing Joker, the Legendary copies the Mult ability but skips the Blueprint path that would return to itself. During Blueprint's separate normal activation, Blueprint can copy the Legendary and obtain the Mult ability as well. Skipping a cyclic path does not stop evaluation of other eligible targets.

This document captures a design discussion. No name or implementation has been approved yet.

## Questions to Resolve

- How should multiple copies of this Legendary Joker interact?
- What temporary name should be used?

## Proposed Direction

- **Rarity:** Legendary, as requested.
- **Role:** Reward collecting Polychrome Jokers with additional activations of their abilities.
- **Pack:** Pack 3 (Development), if implementation is requested.
- **Artwork default:** `BalapoJokers` at position `(1, 1)` unless another asset is requested.
- **Implementation direction:** Reuse `SMODS.blueprint_effect(copier, copied_card, context)`, found in `reference/Steamodded/src/utils.lua`, for Blueprint/Brainstorm-style ability copying. Verify multi-target result handling and add the confirmed active-chain guard rather than relying only on the helper's depth limit.

## Discussion Record

- **Confirmed rarity:** Legendary.
- **Confirmed effect:** Copy the abilities of all owned Polychrome Jokers.
- **Confirmed eligibility:** Only Polychrome Jokers with Blueprint-compatible abilities are copied.
- **Confirmed self-exclusion:** Never copy its own ability, including when Polychrome.
- **Confirmed recursion rule:** Stop a copy chain before revisiting a Joker already active in that chain. Valid Blueprint copying remains allowed.
- **Confirmed activation order:** Copy eligible abilities from left to right, following Joker positions.
- **Confirmed debuffed-target behavior:** Do not copy debuffed Jokers.
- **Confirmed edition behavior:** Copy abilities only; do not copy Polychrome edition bonuses.
- **Status:** Design in progress; no implementation or playtesting.
- **Next step:** Clarify multiple-copy behavior and choose a temporary name.

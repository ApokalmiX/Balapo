# Joker Idea: Loose Ends

[Back to the Joker idea index](../NEW_JOKER_IDEAS.md)

## Confirmed Concept

Cards that do not score have a 1 in 2 chance to be destroyed.

The effect targets playing cards played as part of a hand that do not contribute to scoring. Cards left in hand are outside this scope.

Example provided by the user: when playing Three of a Kind with additional cards, the additional cards that do not score are eligible for destruction. The three scoring cards are not targets.

Destruction must occur during the same destruction phase as native Glass Cards, rather than through a separately timed effect.

The base 1 in 2 destruction chance is affected by probability modifiers, including effects such as Oops! All 6s!.

Each eligible card receives an independent destruction roll. Within the same played hand, some eligible cards may be destroyed while others survive.

Each owned active copy provides an additional independent roll for each eligible card, until destruction is determined. A card must only be destroyed once. Without probability modifiers, the combined destruction chance is 50% with one copy, 75% with two, and 87.5% with three.

Blueprint and Brainstorm are compatible. Each valid copied activation adds an independent roll, following the same rule as an additional active copy.

Initial balance is Uncommon rarity and a $6 purchase price, approved as a starting point for playtesting.

Implementation should use actual scoring membership rather than assuming that every card outside the named poker combination is non-scoring. Interactions that make additional cards score still need to be checked.

The approved temporary name is Loose Ends. This is a design specification, not an implementation request.

## Presentation

- **Approved temporary name:** Loose Ends.
- **Artwork:** Use the default `BalapoJokers` atlas position `(1, 1)` unless another asset is requested.

## Proposed Direction

- **Role:** Deck thinning through cards that do not contribute to scoring.
- **Trade-off:** Useful cards may be destroyed when they fail to score.
- **Pack:** Pack 3 (Development), if implementation is requested.
- **Artwork default:** `BalapoJokers` at position `(1, 1)` unless another asset is requested.
- **Confirmed initial balance:** Uncommon rarity, $6 purchase price; revisit after playtesting.

## Implementation Reference

- The base game's Glass Card destruction phase is in `reference/Balatro/functions/state_events.lua`.
- The local Steamodded patches route that phase through `SMODS.calculate_destroying_cards` in `reference/Steamodded/lovely/better_calc.toml`.
- Investigate that phase's handling of non-scoring played cards before implementing. Use the normal destruction notifications and cleanup rather than a separate delayed removal.

## Discussion Record

- **Confirmed:** Non-scoring cards have a 1 in 2 chance to be destroyed.
- **Confirmed target scope:** Played playing cards that do not score when a hand is played.
- **Example:** Non-scoring extra cards played alongside Three of a Kind are the intended targets.
- **Confirmed timing:** The same destruction phase as native Glass Cards.
- **Confirmed probability modifiers:** Probability-changing effects apply to the base 1 in 2 chance.
- **Confirmed roll behavior:** Each eligible card receives an independent destruction roll.
- **Confirmed duplicate behavior:** Each active copy adds an independent roll until destruction is determined; never destroy a card twice.
- **Confirmed copying behavior:** Blueprint and Brainstorm are compatible and add independent rolls when copying the effect.
- **Confirmed initial balance:** Uncommon rarity and a $6 purchase price.
- **Confirmed temporary name:** Loose Ends.
- **Status:** Design in progress; no code or playtesting.
- **Next step:** Implement in Pack 3 when requested, using the default artwork, then verify the destruction-phase interactions in game.

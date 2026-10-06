# Joker Idea: Restock

[Back to the Joker idea index](../NEW_JOKER_IDEAS.md)

## Confirmed Concept

A utility Joker refreshes the shop's booster packs every ten rerolls.

The reroll counter carries over between shops. Leaving a shop does not reset progress toward the next refresh.

Free rerolls count toward the ten-reroll threshold, just like paid rerolls.

Refresh the entire booster offering, following the user's intended analogy with normal shop rerolls: replace all remaining boosters and refill the slots whose boosters have already been purchased. Respect the current shop's booster capacity rather than assuming a fixed number of slots.

Count rerolls only while the Joker is owned and not debuffed. A debuff pauses the counter without resetting its existing progress; counting resumes after the debuff ends. Rerolls made before acquiring the Joker do not count.

Each owned copy has its own counter. If multiple copies reach ten on the same reroll, perform only one booster refresh for that reroll; each counter that reached ten completes its cycle. Copies acquired at different times may reach the threshold on different rerolls.

The Joker is incompatible with Blueprint and Brainstorm; only actual owned copies maintain counters.

Selling a copy discards its progress. Each newly acquired copy starts with a counter of zero.

Initial balance is Uncommon rarity and a $6 purchase price, approved as a starting point for playtesting.

The approved temporary name is Restock. This document records a design discussion, not an implementation request.

## Presentation

- **Approved temporary name:** Restock.
- **Artwork:** Use the default `BalapoJokers` atlas position `(1, 1)` unless another asset is requested.
- **Counter display:** Show progress toward the next refresh, such as `3/10`.

## Proposed Direction

- **Role:** Provide additional access to booster packs during extensive shop rerolling.
- **Trigger:** Every tenth counted reroll; repeat for subsequent groups of ten.
- **Pack:** Pack 3 (Development), if implementation is requested.
- **Artwork default:** `BalapoJokers` at position `(1, 1)` unless another asset is requested.
- **Presentation:** Display progress toward the next booster refresh.
- **Implementation investigation:** Check reroll contexts and shop booster generation in local Steamodded and Balatro references.

## Discussion Record

- **Confirmed:** Refresh shop booster packs every ten rerolls.
- **Confirmed counter persistence:** Accumulate rerolls across shops; do not reset progress when leaving a shop.
- **Confirmed free-reroll behavior:** Count both free and paid rerolls.
- **Confirmed refresh scope:** Refresh all booster slots, including slots emptied by purchases.
- **Confirmed activation:** Count only while owned and not debuffed; preserve progress through debuffs.
- **Confirmed duplicate behavior:** Each copy tracks its own progress; simultaneous threshold crossings cause only one booster refresh.
- **Confirmed copying compatibility:** Incompatible with Blueprint and Brainstorm.
- **Confirmed sale behavior:** Selling discards that copy's progress; newly acquired copies start at zero.
- **Confirmed initial balance:** Uncommon rarity and a $6 purchase price.
- **Confirmed temporary name:** Restock.
- **Status:** Initial design specified; no implementation or playtesting.
- **Next step:** Implement in Pack 3 when requested, then verify booster regeneration and counter behavior in game.

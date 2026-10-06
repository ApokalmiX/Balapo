# Joker Idea: Encore

[Back to the Joker idea index](../NEW_JOKER_IDEAS.md)

## Confirmed Concept

The last playable hand is also considered the first hand played.

The trigger is playing a hand when exactly one hand remains available in the current round.

The first-hand treatment applies only to Joker abilities that check for the first hand played. It does not alter boss behavior, first-draw events, statistics, unlock conditions, or the round's actual hand counters.

Preserve normal last-hand Joker effects alongside the first-hand effects. The remaining-hands counter is unchanged, allowing effects such as Dusk and Acrobat to continue recognizing the last hand.

If the first hand is also the last available hand, first-hand effects activate normally only once. The Joker changes eligibility; it does not add a duplicate activation.

The effect is active while at least one owned copy is not debuffed. Multiple copies do not stack. The Joker is incompatible with Blueprint and Brainstorm.

Implemented under the provisional name Encore. This name was selected during implementation and can be changed later.

## Balance and Presentation

- **Confirmed initial balance:** Uncommon rarity and a $6 purchase price, as a starting point for playtesting.
- **Provisional implementation name:** Encore.
- **Artwork:** `BalapoJokers` at position `(1, 1)`.

## Proposed Direction

- **Role:** Enable first-hand synergies again on the round's last available hand.
- **Pack:** Pack 3 (Development), implementation complete.
- **Artwork default:** `BalapoJokers` at position `(1, 1)` unless another asset is requested.
- **Implementation investigation:** Inspect first-hand checks and round counter updates before choosing an approach that preserves real hand consumption and last-hand behavior.

## Approved Implementation Direction

- Use a shared approach rather than a separate special case for each base-game Joker.
- During Joker evaluation on the last playable hand, temporarily present `G.GAME.current_round.hands_played` as `0`, the value checked by first-hand abilities such as DNA and Sixth Sense.
- Restore the actual value immediately after evaluation, including on errors. Do not persist the synthetic value or expose it to unrelated game processing.
- Leave `hands_left` and actual hand consumption unchanged so normal last-hand effects remain active.
- Verify nested copying, retriggers, deferred callbacks, and save/load behavior before considering the implementation complete.
- This direction is based on local base-game checks. Other mods may use independent first-hand conditions and require separate compatibility assessment.
- Implemented in `src/jokers/pack_3/encore.lua` through a wrapper around `Card.calculate_joker` that delegates to the previous implementation.
- Apply the synthetic first-hand counter only to Joker evaluations for the current played hand with `hands_left == 0`, which is the native last-hand value after consuming the played hand.
- Skip discard, pre-discard, end-of-round, and first-draw contexts. Calls for non-Joker cards are unchanged.
- Preserve all return values, including additional results used by Steamodded.
- Nested evaluations restore their parent's counter; the outer evaluation restores the real counter. Deferred callbacks see the restored value.

## Validation

- Mocked Lua checks in `tests/encore.lua` pass for ownership, debuffs, last-hand eligibility, first/last coexistence, unrelated contexts, non-Joker cards, destruction contexts, duplicate copies, a single available hand, nested evaluation, deferred callbacks, error recovery, and removal.
- Existing Curated Shop mocked checks also pass.
- No mod compilation was performed.
- The user reported that an initial in-game trial appears to work correctly. The exact combinations tested were not specified.
- Detailed checks of DNA, Sixth Sense, copied abilities, save/load, and compatibility with other installed mods have not been individually recorded.

## Discussion Record

- **Confirmed description:** The last playable hand is also considered the first hand played.
- **Confirmed trigger:** Play a hand with exactly one hand remaining in the current round.
- **Confirmed scope:** First-hand-played Joker abilities only; preserve boss behavior, drawing events, statistics, unlock conditions, and real round counters.
- **Confirmed coexistence:** Preserve normal last-hand Joker effects alongside first-hand effects.
- **Confirmed single-hand behavior:** When the first hand is also the last available hand, do not duplicate first-hand activations.
- **Confirmed activation and copying:** Active while at least one non-debuffed copy is owned; copies do not stack; incompatible with Blueprint and Brainstorm.
- **Confirmed initial balance:** Uncommon rarity and a $6 purchase price.
- **Approved implementation direction:** Temporarily expose a first-hand counter only during Joker evaluation and restore the real value afterward; use a shared approach for base-game Jokers.
- **Status:** Implemented under the provisional name Encore; mocked behavior checks pass, and the user reported a successful initial in-game trial.
- **Next step:** Record any additional in-game observations or issues as they arise.

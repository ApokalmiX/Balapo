# Balapo — New Joker Design and Implementation Notes

## Purpose

Use this document to capture ideas discussed during voice conversations and develop them into clear Joker specifications. Unresolved questions remain open; a recorded idea does not imply approval to implement it.

For the broader direction of the mod, see [Future Development Ideas](FUTURE_DEVELOPMENT.md).

## Document Organization

Keep one Markdown file per Joker in the joker_ideas/ directory. Use this document as the index and reusable specification template. Add conversation notes and design decisions to the relevant Joker file.

## Idea List

| Working name | Core effect | Intended strategy | Open questions | Status |
| --- | --- | --- | --- | --- |
| [Curated Shop (approved temporary name)](joker_ideas/curated_shop.md) | Exclude newly generated individual Tarot, Planet, and playing-card offers; replace prohibited forced offers with eligible offers and consume triggering tags normally. Preserve existing stock, boosters, and eligible Spectral offers. Active while at least one non-debuffed copy is owned; copies do not stack. Incompatible with Blueprint and Brainstorm. Initial balance: Uncommon, $6. | Find Jokers more consistently at the expense of other shop options. | Pack; final name can be revisited later. | Design in progress |

Suggested statuses: To discuss, Design in progress, Ready to implement, Implemented, Playtesting, Deferred, Rejected.

## Joker Specification Template

### [Working name]

#### Concept

- **Theme or inspiration:**
- **Core effect in one sentence:**
- **Interesting player choice:**
- **Intended strategy and synergies:**
- **Difference from existing Jokers:**

#### Gameplay Rules

- **Trigger:** The exact event that activates the effect.
- **Eligible targets:** Which cards, hands, or other objects qualify?
- **Effect:** Chips, Mult, XMult, money, card changes, or another outcome.
- **Initial values:**
- **Scaling:** What changes over time, and under which conditions?
- **Limits and reset conditions:**
- **Timing:** When does the effect occur relative to scoring or other events?
- **Repeated triggers:** Should retriggers apply, and how often can the effect run?
- **Persistence:** What lasts for a hand, a round, or the entire run?

#### Balance

- **Rarity and cost:**
- **Expected role:** Early run, setup, payoff, or Endless progression.
- **Trade-offs or constraints:**
- **Strong combinations to examine:**
- **Situations where the Joker should remain useful:**
- **Potential loops or uncontrolled scaling:**

#### Implementation Questions

- **Pack and file location:** Choose the appropriate existing pack or discuss a new one.
- **Registration:** Define a unique key and register the Joker with `SMODS.Joker`.
- **Loading:** Add the new file to the selected pack's loader when implementation is approved.
- **Event handling:** Identify the relevant Steamodded contexts and callbacks before coding.
- **Stored state:** Specify initial values, updates, resets, and save/load behavior.
- **Scoring versus state changes:** Define which calls return a scoring effect and which mutate state.
- **Blueprint and Brainstorm:** Decide whether copying is supported and how copied effects handle state.
- **Other interactions:** Consider debuffs, retriggers, duplicate Jokers, and card removal where relevant.
- **Availability:** Decide whether appearance in the pool requires a particular deck state.
- **Reference checks:** Verify uncertain behavior against local Steamodded documentation and game sources.

#### Presentation

- **Displayed name:**
- **Effect description:** Write concise English text matching the actual rules.
- **Dynamic values and tooltips:** Specify what the player needs to see.
- **Artwork:** Use the existing `BalapoJokers` atlas at position `(1, 1)` by default unless another position is requested.
- **Feedback:** Messages or visual cues needed to make the effect understandable.

#### Manual Playtest Scenarios

- A normal case that triggers the effect.
- A case that does not meet the trigger conditions.
- Relevant retrigger and copying interactions.
- State reset and save/load behavior, if the Joker stores state.
- Relevant empty, missing, debuffed, or removed targets.
- A strong synergy and a longer Endless run, when applicable.

Record expected results and actual observations for the scenarios selected. Compilation is only performed when explicitly requested.

#### Discussion and Decision

- **Confirmed details:**
- **Open questions:**
- **Alternatives considered:**
- **Decision and rationale:**
- **Next step:**

## Working Method

1. Capture the idea as expressed in the conversation.
2. Separate confirmed rules from suggestions and unresolved questions.
3. Clarify triggering, timing, scaling, and copying behavior.
4. Check relevant local references without modifying the `reference` directory.
5. Implement only when requested, then record relevant playtest observations.
6. Update the specification when the design changes.

## Conversation Notes

### [Joker or topic]

- **Idea discussed:**
- **Confirmed details:**
- **Questions to revisit:**
- **Decision:**
- **Next step:**

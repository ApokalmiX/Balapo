# Joker Idea: Curated Shop

[Back to the Joker idea index](../NEW_JOKER_IDEAS.md)

## Confirmed Effect

Tarot cards, Planet cards, and playing cards no longer appear in the shop.

The restriction applies only to cards sold individually. Booster packs appear normally, and their contents are unaffected.

Buying the Joker does not replace cards already displayed in the shop. The restriction applies to newly generated offers.

Spectral cards remain eligible as individual shop offers when another effect enables them. This Joker does not enable Spectral offers by itself.

Debuffing the Joker suspends its shop restriction. The restriction resumes when the Joker is no longer debuffed.

The restriction also applies to individual offers forced by tags or other mods. Forced generation must not bypass the exclusion of Tarot cards, Planet cards, or playing cards while the effect is active.

Replace any prohibited forced offer with an eligible offer so that the number of cards offered in the shop stays unchanged.

If a tag generated the prohibited offer, consume that tag normally when its eligible replacement is generated.

Multiple copies do not provide an additional benefit. The restriction remains active while at least one owned copy is not debuffed, including when another copy is sold or debuffed.

The Joker is incompatible with Blueprint and Brainstorm.

The initial balance settings are Uncommon rarity and a $6 purchase price, approved as a starting point for playtesting.

The approved temporary name is Curated Shop. The final name may be revisited later.

Selling the Joker does not immediately change displayed shop cards. Normal offer generation resumes on the next reroll or subsequent shop generation, provided no other active copy maintains the restriction.

These gameplay rules are confirmed by the user. All other choices below are proposals or questions, not approved implementation decisions.

## Proposed Design

- **Confirmed temporary name:** Curated Shop; not a final naming decision.
- **Role:** A utility Joker that makes searching for other Jokers more consistent.
- **Trade-off:** Occupies a Joker slot and removes direct access to three types of shop cards.
- **Confirmed debuff behavior:** Suspend the restriction while the Joker is debuffed, and resume it when the debuff ends.
- **Confirmed ownership rule:** Apply while at least one non-debuffed copy is owned.
- **Confirmed scope:** Only individually sold cards are affected. Booster pack availability and contents remain unchanged.
- **Proposed timing:** Affect newly generated individual shop cards, including rerolls. Leave vouchers unchanged.
- **Confirmed existing stock on purchase:** Cards already displayed remain unchanged when the Joker is acquired.
- **Confirmed sale behavior:** Leave displayed cards unchanged. Restore normal eligibility for newly generated offers after sale, including the next reroll.
- **Other removal behavior:** Proposed identical to sale. Another active copy maintains the restriction.
- **Confirmed Spectral behavior:** Spectral cards remain eligible when another effect enables their individual shop appearance. The shop is not restricted to Jokers alone.
- **Proposed remaining-offer selection:** Select from the remaining eligible types using their relative weights.
- **Scaling:** None; this is a binary shop restriction.
- **Confirmed duplicate behavior:** No additional effect; one remaining non-debuffed copy maintains the restriction.
- **Confirmed Blueprint and Brainstorm compatibility:** Incompatible; copying this binary restriction provides no additional benefit.
- **Confirmed initial rarity and cost:** Uncommon at $6, as a starting point for playtesting. Revisit after observing how much it improves Joker searches.
- **Pack:** Undecided.

## Proposed Description

“Tarot cards, Planet cards, and playing cards no longer appear in the shop.”

The description applies to newly generated individual shop offers. Existing cards are not replaced on purchase.

## Implementation Notes

- Register a unique `SMODS.Joker` key and load its file through the chosen pack.
- Use `BalapoJokers` at position `(1, 1)` unless another asset is requested.
- The local Steamodded source generates normal shop cards through `SMODS.create_shop_card` and selects their type through `SMODS.poll_object_type` in `reference/Steamodded/src/utils/weights.lua`.
- That selection reads type weights from the run state. The base-game source also contains Tarot, Planet, and playing-card shop rates.
- Investigate a shop-specific filtering approach for the installed Steamodded version. Avoid assuming that a global type-selection change affects only the shop.
- Preserve other effects that change shop rates, including vouchers. Selling or debuffing the Joker must not restore stale values or overwrite changes made while it was owned.
- Account for multiple copies, loading a saved run, and changes to ownership or debuff state.
- Normal shop generation has tutorial and tag overrides before type selection in the inspected Steamodded source. Filtering normal type weights alone is therefore insufficient to enforce the confirmed restriction on forced offers. Investigate these generation paths and relevant mod interactions before choosing the implementation.
- Replace prohibited forced offers with eligible offers, preserving the number of shop cards. Consume a triggering tag normally when generating the replacement. The replacement selection method and handling of other mod effects remain implementation questions.
- Define a fallback if no eligible type has a positive weight.
- No Lua implementation has been requested or created for this idea.

## Questions to Resolve

- Which pack should contain this Joker?

## Manual Playtest Plan

- While the Joker is active, open and reroll several shops: no prohibited individual cards should be generated under the proposed scope.
- Activate playing-card shop availability through relevant vouchers and verify that the restriction still applies.
- Check Spectral availability and forced offers against the final agreed rules.
- Buy, sell, debuff, and remove the Joker; verify the agreed timing and restoration behavior.
- Own two copies and remove one; the remaining active copy should preserve the restriction.
- Save and reload with the Joker owned; verify the shop behavior remains correct.
- Verify booster packs and vouchers follow the agreed scope.
- Assess whether improved Joker access justifies its price, rarity, and occupied slot.

## Discussion Record

- **Confirmed:** Tarot cards, Planet cards, and playing cards no longer appear as individual shop offers. Booster packs and their contents remain unchanged.
- **Confirmed purchase timing:** Buying the Joker leaves existing shop cards unchanged; the restriction applies to newly generated offers.
- **Confirmed Spectral behavior:** Individual Spectral offers remain possible when enabled by another effect.
- **Confirmed debuff behavior:** The shop restriction stops during a debuff and resumes when it ends.
- **Confirmed forced-offer behavior:** Tags and other mods cannot force prohibited individual cards to appear while the restriction is active.
- **Confirmed replacement behavior:** Replace prohibited forced offers with eligible offers, preserving the number of cards in the shop.
- **Confirmed tag consumption:** Consume the triggering tag normally when its prohibited offer is replaced by an eligible offer.
- **Confirmed duplicate behavior:** Multiple copies do not stack; the restriction remains active while at least one non-debuffed copy is owned.
- **Confirmed copying compatibility:** Incompatible with Blueprint and Brainstorm.
- **Confirmed initial balance:** Uncommon rarity and a $6 purchase price, to be assessed during playtesting.
- **Confirmed temporary name:** Curated Shop, with the final name left open for later.
- **Confirmed sale behavior:** Selling the Joker does not change displayed cards; the next reroll uses normal shop generation unless another active copy maintains the restriction.
- **Proposed:** The replacement selection method and behavior for removal other than sale.
- **Status:** Design in progress; no playtesting performed.
- **Next step:** Choose the pack, then resolve remaining implementation details before coding is requested. The temporary name is approved; final naming can be revisited later.

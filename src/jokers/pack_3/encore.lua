local function encore_active()
    for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
        if joker.config.center.key == 'j_balapo_encore'
            and not joker.debuff and not joker.getting_sliced then
            return true
        end
    end
    return false
end

local function pack_results(...)
    return {n = select('#', ...), ...}
end

local original_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context, ...)
    local round = G.GAME and G.GAME.current_round
    local played_hand = context and G.play and context.full_hand == G.play.cards
        and #G.play.cards > 0
    local evaluate_as_first = self.ability and self.ability.set == 'Joker'
        and played_hand and round and round.hands_left == 0
        and not context.discard and not context.pre_discard
        and not context.end_of_round and not context.first_hand_drawn
        and encore_active()

    if not evaluate_as_first then
        return original_calculate_joker(self, context, ...)
    end

    -- Only the synchronous Joker evaluation sees a first-hand counter.
    -- Nested copies restore the parent's value before the outer call restores
    -- the actual round count. Deferred events run after restoration.
    local hands_played = round.hands_played
    round.hands_played = 0
    local results = pack_results(pcall(original_calculate_joker, self, context, ...))
    round.hands_played = hands_played
    if not results[1] then error(results[2], 0) end
    return unpack(results, 2, results.n)
end

SMODS.Joker {
    key = 'encore',
    loc_txt = {
        name = 'Encore',
        text = {
            'The {C:attention}last hand{} of each round',
            'also counts as the {C:attention}first hand{}',
            'for {C:attention}Joker{} abilities',
        },
    },
    config = {extra = {}},
    rarity = 2,
    cost = 6,
    atlas = 'BalapoJokers',
    pos = {x = 1, y = 1},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
}

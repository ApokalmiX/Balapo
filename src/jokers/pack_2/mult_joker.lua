local function get_poker_hand_mult(hand_name)
	if G.GAME and G.GAME.hands and hand_name and G.GAME.hands[hand_name] then
		return G.GAME.hands[hand_name].mult or 0
	end

	return 0
end

-- Mult Joker
SMODS.Joker {
	key = 'mult_joker',
	loc_txt = {
		name = 'Mult Joker',
		text = {
			"Played {C:attention}Mult Cards{} give",
			"the {C:mult}Mult{} of the played",
			"{C:attention}poker hand{} when scored"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_mult
		return { vars = { } }
	end,
	config = { extra = { } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 2, y = 3 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            SMODS.has_enhancement(context.other_card, 'm_mult') then
            local hand_mult = get_poker_hand_mult(context.scoring_name)
			if hand_mult > 0 then
				return {
                	mult = hand_mult
            	}
			end
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_mult') then
                return true
            end
        end
        return false
    end
}

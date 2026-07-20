local function get_poker_hand_chips(hand_name)
	if G.GAME and G.GAME.hands and hand_name and G.GAME.hands[hand_name] then
		return G.GAME.hands[hand_name].chips or 0
	end

	return 0
end

-- Chips Joker
SMODS.Joker {
	key = 'bonus_joker',
	loc_txt = {
		name = 'Bonus Joker',
		text = {
			"Played {C:attention}Bonus Cards{} give",
			"the {C:chips}Chips{} of the played",
			"{C:attention}poker hand{} when scored"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
		return { vars = { } }
	end,
	config = { extra = { } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 3 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            SMODS.has_enhancement(context.other_card, 'm_bonus') then
            local hand_chips = get_poker_hand_chips(context.scoring_name)
			if hand_chips > 0 then
				return {
                	chips = hand_chips
            	}
			end
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_bonus') then
                return true
            end
        end
        return false
    end
}

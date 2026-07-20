-- Caerulean
SMODS.Joker {
	key = 'caerulean',
	loc_txt = {
		name = 'Caerulean',
		text = {
			"Scored {C:blue}Blue Seals{}",
			"give {X:mult,C:white} X#1# {} Mult per level",
			"of played {C:attention}poker hand{}",
			"{C:inactive}(1 + {X:mult,C:white}#1#{C:inactive} x {C:attention}hand level{C:inactive})"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_SEALS.Blue
		return { vars = { card.ability.extra.x_mult } }
	end,
	config = { extra = { x_mult = 0.02 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 2 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.individual and
		context.cardarea == G.play and
		context.other_card and
		context.other_card.seal == 'Blue' then

			if G.GAME.last_hand_played then

				local level = G.GAME.hands[G.GAME.last_hand_played].level
				local x_mult = 1 + (level*card.ability.extra.x_mult)

				if x_mult > 1 then
					return {
						x_mult = x_mult,
						card = card
					}
				end
			end

		end

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Blue' then
				return true
			end
		end
		return false
	end
}

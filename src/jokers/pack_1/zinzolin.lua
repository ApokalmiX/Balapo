-- Zinzolin
SMODS.Joker {
	key = 'zinzolin',
	loc_txt = {
		name = 'Zinzolin',
		text = {
			"{C:purple}Purple Seal{} have",
			"{C:green}#1# in #2#{} chance to",
			"create {C:spectral}Spectral{} card"
		}
	},
	config = { extra = { odds = 2 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 2 },
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_SEALS.Purple
		return { vars = { G.GAME and G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
	end,
	calculate = function(self, card, context)

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Purple' then
				return true
			end
		end
		return false
	end
}

local original_calculate_seal = Card.calculate_seal

function Card:calculate_seal(context)

	if not self.debuff and context.discard and context.other_card == self then
		if self.seal == 'Purple' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then

			local zinzolin = SMODS.find_card('j_balapo_zinzolin')[1]

			if zinzolin then
				if pseudorandom('j_balapo_zinzolin') < G.GAME.probabilities.normal / zinzolin.ability.extra.odds then

					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					G.E_MANAGER:add_event(Event({
						trigger = 'before',
						delay = 0.0,
						func = (function()
							local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'j_balapo_zinzolin')
							card:add_to_deck()
							G.consumeables:emplace(card)
							G.GAME.consumeable_buffer = 0
							return true
						end)
					}))
					card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
					return nil, true
				end
			end

		end
	end

	return original_calculate_seal(self, context)

end

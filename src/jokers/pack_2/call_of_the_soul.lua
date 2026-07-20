-- Call of the Soul
SMODS.Joker {
	key = 'call_of_the_soul',
	loc_txt = {
		name = 'The Call of the Soul',
		text = {
			"Create a {C:spectral}The Soul{} card",
			"after {C:attention}Finisher Blind{} is defeated",
			"{C:inactive}(Must have room)"
		}
	},
	config = { extra = { } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 3 },
	cost = 10,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'c_soul', set = 'Spectral'}
		return { vars = {} }
	end,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		if context.end_of_round and
		not context.repetition and
		not context.individual and
		G.GAME.blind.boss then

			sendDebugMessage('BlindName:' .. G.GAME.blind.name)

			local boss_blind = get_blind(G.GAME.blind.name)
			sendDebugMessage('BlindName2:' .. boss_blind.name)

			local showdown = safe_get(boss_blind, "boss.showdown")
			if not showdown then
				return
			end

			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                        local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_soul', 'test2')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                    }))

                return {
                	message = '+1 The Soul',
                	colour = G.C.SECONDARY_SET.Spectral
				}
			end
		end
	end
}

-- Auralist
SMODS.Joker {
	key = 'auralist',
	loc_txt = {
		name = 'Auralist',
		text = {
			"After {C:attention}5{} scoring",
			"{C:attention}Ace{} played,",
			"create an {C:spectral}Aura{} card",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/5)",
			"{C:inactive}(Must have room)"
		}
	},
	config = { extra = { ace_played = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'c_aura', set = 'Spectral'}
		return { vars = { card.ability.extra.ace_played } }
	end,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.before and
		context.main_eval and
		not context.blueprint then

			local ace_cards = 0
            for _, v in ipairs(context.scoring_hand) do
                if v:get_id() == 14 and not v.debuff then ace_cards = ace_cards + 1 end
        	end

			card.ability.extra.ace_played = card.ability.extra.ace_played + ace_cards

		end

		if context.after and not context.blueprint then
			if card.ability.extra.ace_played >= 5 then
				card.ability.extra.ace_played = card.ability.extra.ace_played - 5
			end
		end

		if context.joker_main then

			if card.ability.extra.ace_played >= 5 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then

                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1

                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                        local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_aura', 'auralist')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                    }))

                return {
                	message = '+1 Aura',
                	colour = G.C.SECONDARY_SET.Spectral
				}
			end

		end

	end
}

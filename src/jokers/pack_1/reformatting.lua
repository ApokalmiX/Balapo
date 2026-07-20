-- Reformatting
SMODS.Joker {
	key = 'reformatting',
	loc_txt = {
		name = 'Reformatting',
		text = {
			"When {C:attention}Blind{} is selected,",
			"remove the {C:dark_edition}edition{} of",
			"the {C:attention}Joker{} to the right",
			"and gains {X:mult,C:white}X#2#{} Mult",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult)"
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.x_mult, card.ability.extra.xmult_bonus } }
	end,
	config = { extra = { xmult_bonus = 1 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 0 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.setting_blind and not context.blueprint then

			local current_pos = 0
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					current_pos = i
					break
				end
			end

			local other_joker = G.jokers.cards[current_pos+1]

			if other_joker and other_joker.edition then

				G.E_MANAGER:add_event(Event({
					func = function()
						card.ability.x_mult = card.ability.x_mult + card.ability.extra.xmult_bonus
						card:juice_up(0.8, 0.8)
						other_joker:set_edition(nil, true)
						other_joker:set_cost()
						play_sound('slice1', 0.96 + math.random() * 0.08)
						return true
					end
				}))

				card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT, delay = 0.75, card = card})
				return

			end

		end

		if context.joker_main then
			return {
				x_mult = card.ability.x_mult
			}
		end

	end,
	in_pool = function(self, args)
        for _, joker in ipairs(G.jokers.cards or {}) do
        	if joker.edition ~= nil then
        		return true
            end
        end
        return false
    end
}

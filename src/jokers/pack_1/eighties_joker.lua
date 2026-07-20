-- Eighties Joker
SMODS.Joker {
	key = 'eighties_joker',
	loc_txt = {
		name = 'Eighties Joker',
		text = {
			"{C:attention}Jokers{} grant their",
			"{C:dark_edition}edition{} bonus when a",
			"card from the same",
			"{C:dark_edition}edition{} is scored"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_foil
        info_queue[#info_queue+1] = G.P_CENTERS.e_holo
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
		return { vars = {} }
    end,
	pos = { x = 0, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.individual and context.cardarea == G.play and context.other_card then

			if context.other_card.edition == nil then
				return
			end

			if context.other_card.debuff then
				return
			end

			local ret = {
				no_juice = true
			}
			local realRet = {
				extra = ret
			}

			for i = 1, #G.jokers.cards do

				local other_joker = G.jokers.cards[i]
				if other_joker.edition and not other_joker.debuff then

					if other_joker.edition.holo and context.other_card.edition.holo then

						ret.func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									other_joker:juice_up(0.1, 0.1)
									return true
								end
							}))
						end
						ret.extra = {
							mult = 10,
							no_juice = true
						}
						ret = ret.extra

					end

					if other_joker.edition.foil and context.other_card.edition.foil then

						ret.func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									other_joker:juice_up(0.1, 0.1)
									return true
								end
							}))
						end
						ret.extra = {
							chips = 50,
							no_juice = true
						}
						ret = ret.extra

					end

					if other_joker.edition.polychrome and context.other_card.edition.polychrome then

						ret.func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									other_joker:juice_up(0.1, 0.1)
									return true
								end
							}))
						end
						ret.extra = {
							x_mult = 1.5,
							no_juice = true
						}
						ret = ret.extra

					end

				end

			end

			if realRet.extra.extra then
				return realRet
			end

		end

	end
}

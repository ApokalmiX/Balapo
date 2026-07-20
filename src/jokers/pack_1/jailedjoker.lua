-- Jailed Joker
SMODS.Joker {
	key = 'jailedjoker',
	loc_txt = {
		name = 'Jailed Joker',
		text = {
			"Sell this card to",
			"apply {C:attention}Eternal{} to",
			"all other Jokers",
			"{C:inactive}(If compatible)"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'eternal', set = 'Other'}
		return { vars = {} }
    end,
	pos = { x = 3, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	calculate = function(self, card, context)

		if context.selling_self and not context.blueprint then

			local jokers = {}
            for i=1, #G.jokers.cards do
				if G.jokers.cards[i] ~= card then
                    jokers[#jokers+1] = G.jokers.cards[i]
					G.jokers.cards[i]:set_eternal(true)
                end
            end

			if #jokers > 0 then
	            card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Eternalized!'})
            end

		end

	end
}

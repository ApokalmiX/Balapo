-- Ghost Joker
SMODS.Joker {
	key = 'ghostjoker',
	loc_txt = {
		name = 'Ghost Joker',
		text = {
			"After selling {C:attention}1{} {C:dark_edition}Negative{} Joker",
			"sell this card to apply",
			"{C:dark_edition}Negative{} to a random Joker",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/1)"
		}
	},
	config = { extra = { negative_joker_sold = 0 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 2, y = 1 },
	cost = 10,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.e_negative
		return { vars = { card.ability.extra.negative_joker_sold } }
	end,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	calculate = function(self, card, context)

		if context.selling_self and not context.blueprint then

			-- Self Negative case
			if card.edition and card.edition.negative then
				card.ability.extra.negative_joker_sold = card.ability.extra.negative_joker_sold + 1
			end

			if card.ability.extra.negative_joker_sold < 1 then
				return
			end

			local eval = function(card) return (card.ability.extra.negative_joker_sold >= 1) and not G.RESET_JIGGLES end
			juice_card_until(card, eval, true)

			local jokers = {}
            for i=1, #G.jokers.cards do
				if G.jokers.cards[i] ~= card and (not G.jokers.cards[i].edition) then
                    jokers[#jokers+1] = G.jokers.cards[i]
                end
            end

			if #jokers > 0 then
	            card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Negatived!'})
				local chosen_joker = pseudorandom_element(jokers, pseudoseed('ghostjoker'))
				local edition = {negative = true}
				chosen_joker:set_edition(edition, true)
            else
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_not_allowed_ex')})
            end

		end

		if context.selling_card and not context.blueprint  then

			if context.blueprint then
				return
			end

			if context.card == nil then
				return
			end

			if context.card.edition == nil then
				return
			end

			if context.card.debuff then
				return
			end

			if context.card.edition.negative and context.card.ability.set == 'Joker' then

				card.ability.extra.negative_joker_sold = card.ability.extra.negative_joker_sold + 1

				if card.ability.extra.negative_joker_sold == 1 then
					local eval = function(card) return not card.REMOVED end
	                juice_card_until(card, eval, true)
	            end

				return {
	            	message = (card.ability.extra.negative_joker_sold < 1) and (card.ability.extra.negative_joker_sold..'/'..2) or localize('k_active_ex'),
                	colour = G.C.FILTER
                }
			end

		end

	end
}

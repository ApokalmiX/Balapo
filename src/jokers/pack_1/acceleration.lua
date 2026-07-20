-- Acceleration
SMODS.Joker {
	key = 'acceleration',
	loc_txt = {
		name = 'Acceleration',
		text = {
			"{C:attention}+1{} hand size",
			"after each hand played,",
			"resets at the end of the round",
			"{C:inactive}(Currently {C:attention}+#1#{C:inactive} hand size)"
		}
	},
	config = { extra = { h_size = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 5, y = 0 },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.h_size } }
	end,
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	add_to_deck = function(self, card, from_debuff)
		G.hand:change_size(card.ability.extra.h_size)
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.hand:change_size(-card.ability.extra.h_size)
	end,
	calculate = function(self, card, context)

		-- Reset end of round
		if context.end_of_round and not context.blueprint and card.ability.extra.h_size > 0 then
			G.hand:change_size(-card.ability.extra.h_size)
			card.ability.extra.h_size = 0
			return {
				message = localize('k_reset'),
				colour = G.C.RED,
				card = card
			}
		end

		-- Hand size increment
		if context.before and not context.blueprint then
			card.ability.extra.h_size = card.ability.extra.h_size+1
			G.hand:change_size(1)
			return {
				message = '+1 hand size!',
				colour = G.C.RED,
				card = card
			}
		end

	end
}

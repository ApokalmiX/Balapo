-- Quarry Joker
SMODS.Joker {
	key = 'quarry_joker',
	loc_txt = {
		name = 'Quarry Joker',
		text = {
			"Draw {C:attention}1{} extra card",
			"each time a {C:attention}Stone Card{}",
			"is discarded"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_stone
		return { vars = { } }
	end,
	config = { extra = { cards = 1, pending_cards = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		if context.discard and
		context.other_card and
		not context.other_card.debuff and
		SMODS.has_enhancement(context.other_card, 'm_stone') then
			card.ability.extra.pending_cards = (card.ability.extra.pending_cards or 0) + card.ability.extra.cards

			return {
				message = "DRAW",
				colour = G.C.CHIPS
			}
		end

		local pending_cards = card.ability.extra.pending_cards or 0
		if context.drawing_cards and pending_cards > 0 then
			card.ability.extra.pending_cards = 0

			return {
				modify = context.amount + pending_cards
			}
		end
	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if SMODS.has_enhancement(playing_card, 'm_stone') then
				return true
			end
		end
		return false
	end
}

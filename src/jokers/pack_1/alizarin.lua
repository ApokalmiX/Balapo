-- Alizarin
SMODS.Joker {
	key = 'alizarin',
	loc_txt = {
		name = 'Alizarin',
		text = {
			"Gain {C:attention}1{} charge each time",
			"a {C:red}Red Seal{} is discarded,",
			"With each hand played",
			"distributes the charges",
			"as additional {C:attention}retriggers{}",
			"on each card played",
			"{C:inactive}(Rounded down)",
			"{C:inactive}(Currently {C:attention}+#1#{}{C:inactive} charge)"
		}
	},
	config = { extra = { charges = 0, rettrigers = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 3, y = 2 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_SEALS.Red
		return { vars = { card.ability.extra.charges } }
	end,
	calculate = function(self, card, context)

		if context.discard and
		not context.blueprint and
		not context.other_card.debuff and
		context.other_card.seal == 'Red' then

			card.ability.extra.charges = card.ability.extra.charges + 1

			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.ORANGE
			}
		end

		if context.before and
		context.main_eval and
		not context.blueprint then

			local played_cards = #context.scoring_hand
			card.ability.extra.rettrigers = math.floor(card.ability.extra.charges / played_cards)
			if card.ability.extra.rettrigers == 0 then
				return
			end

			local charges_used = card.ability.extra.rettrigers * played_cards
			card.ability.extra.charges = card.ability.extra.charges - charges_used
		end

		if context.repetition and
		context.cardarea == G.play and
		card.ability.extra.rettrigers > 0 then
			return {
				repetitions = card.ability.extra.rettrigers
			}
		end

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Red' then
				return true
			end
		end
		return false
	end
}

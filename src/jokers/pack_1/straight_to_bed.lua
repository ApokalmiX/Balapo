-- Straight to the Bed
SMODS.Joker {
	key = 'straight_to_bed',
	loc_txt = {
		name = 'Straight to the Bed',
		text = {
			"Retrigger all cards played",
			"if played hand",
			"contains a {C:attention}Straight{},",
			"Retriggers an additional time",
			"if the played hand also",
			"contains a {C:attention}Flush{}"
		}
	},
	config = { extra = { repetitions = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 5, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.before and not context.blueprint then
			card.ability.extra.repetitions = 0
			if next(context.poker_hands['Straight']) then
				card.ability.extra.repetitions = 1
				if next(context.poker_hands['Flush']) then
					card.ability.extra.repetitions = 2
				end
			end
		end

		if card.ability.extra.repetitions and
		card.ability.extra.repetitions > 0 and
		context.repetition and
		context.cardarea == G.play then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra.repetitions,
				card = card
			}
		end
	end
}

-- Collector's Album
SMODS.Joker {
	key = 'collectorsalbum',
	loc_txt = {
		name = 'Collector\'s Album',
		text = {
			"{C:dark_edition}Edition{} of cards",
			"{C:attention}held in hand{}",
			"counts in scoring"
		}
	},
	config = { },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 3, y = 0 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.end_of_round then
			return
		end

		if context.individual and context.cardarea == G.hand and context.other_card then

			if context.other_card.edition == nil then
				return
			end

			if context.other_card.debuff then
				return
			end

			if context.other_card.edition.holo then
				return {
                	mult = context.other_card.edition.mult
				}
			end

			if context.other_card.edition.foil then
				return {
					chips = context.other_card.edition.chips
				}
			end

			if context.other_card.edition.polychrome then
				return {
                	x_mult = context.other_card.edition.x_mult
				}
			end

		end

	end,
	in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
        	if playing_card.edition ~= nil then
        		return true
            end
        end
        return false
    end
}

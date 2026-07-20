-- Exorcist Joker
local function exorcist_joker_is_played_card(target_card, full_hand)
	for _, played_card in ipairs(full_hand or {}) do
		if played_card == target_card then
			return true
		end
	end
	return false
end

SMODS.Joker {
	key = 'exorcist_joker',
	loc_txt = {
		name = 'Exorcist Joker',
		text = {
			"Played {C:attention}debuffed{} cards",
			"are {C:red}destroyed{}",
			"at end of hand"
		}
	},
	config = { extra = {} },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		if context.destroy_card and
		context.destroy_card.debuff and
		exorcist_joker_is_played_card(context.destroy_card, context.full_hand) then
			return {
				remove = true,
				message = "Exorcised!",
				colour = G.C.RED
			}
		end
	end
}

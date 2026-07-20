local function count_card_suits(card)
	local suits = { 'Hearts', 'Diamonds', 'Spades', 'Clubs' }
	local suit_count = 0

	for _, suit in ipairs(suits) do
		if card:is_suit(suit, nil, true) then
			suit_count = suit_count + 1
		end
	end

	return suit_count
end

-- Colorblind Joker
SMODS.Joker {
	key = 'colorblind_joker',
	loc_txt = {
		name = 'Colorblind Joker',
		text = {
			"Played cards counted",
			"as at least {C:attention}2{} suits",
			"give {X:mult,C:white}X#1#{} Mult",
			"when scored"
		}
	},
	config = { extra = { x_mult = 2 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,
	calculate = function(self, card, context)
		if context.individual and
		context.cardarea == G.play and
		context.other_card and
		count_card_suits(context.other_card) >= 2 then
			return {
				x_mult = card.ability.extra.x_mult,
				card = card
			}
		end
	end
}

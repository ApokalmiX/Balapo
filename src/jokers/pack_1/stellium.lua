-- Stellium
SMODS.Joker {
	key = 'stellium',
	loc_txt = {
		name = 'Stellium',
		text = {
			"{C:planet}Planet{} cards increase",
			"hand level by the level",
			"of the weakest {C:attention}poker hand{}"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 5, y = 2 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	calculate = function(self, card, context)
	end
}

local original_level_up_hand = level_up_hand

function level_up_hand(card, hand, instant, amount)

	amount = amount or 1

	if card and
		card.ability and
		card.ability.consumeable and
		card.ability.consumeable.hand_type and
		next(SMODS.find_card("j_balapo_stellium")) then

		local weakest_level = nil

		for k, v in pairs(G.GAME.hands) do

			if v.visible then

				if not weakest_level then
					weakest_level = v.level
				end

				if v.level < weakest_level then
					weakest_level = v.level
				end

			end

        end

		amount = weakest_level

		original_level_up_hand(card, hand, instant, amount)
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level = "+" .. amount})
		delay(1.3)
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})

	else
		original_level_up_hand(card, hand, instant, amount)
	end

end

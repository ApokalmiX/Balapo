-- Golden Eye
SMODS.Joker {
	key = 'goldeneye',
	loc_txt = {
		name = 'Golden Eye',
		text = {
			"{X:mult,C:white}X#1#{} Mult every",
			"time {C:money}${} is obtained",
			"during the hand played"
		}
	},
	config = { extra = { xmult_bonus = 1.5 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 0 },
	soul_pos = { x = 2, y = 0 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult_bonus } }
	end,
	calculate = function(self, card, context)
		if G.STATE == G.STATES.HAND_PLAYED and context.dollar_gain then
			return {
				x_mult = card.ability.extra.xmult_bonus
			}
		end
	end
}

-- store original ease_dollars function
local original_ease_dollars = ease_dollars

-- redefine ease_dollars function
function ease_dollars(dollars)

	original_ease_dollars(dollars)

	if type(dollars) == "number" and dollars > 0 then
		for i=1, #G.jokers.cards do
			local joker = G.jokers.cards[i];
			local name = joker.ability.name
			if (name == 'j_balapo_goldeneye' or name == "Blueprint" or name == "Brainstorm") and not joker.debuff then
				context = { dollar_gain = true }
				local effects = { eval_card(joker, context) }
				if next(effects) then
					SMODS.trigger_effects(effects, joker)
				end
			end
	    end
	end

end

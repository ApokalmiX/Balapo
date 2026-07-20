local function isBefore(currentJoker, relativeJoker)
	for i, joker in ipairs(G.jokers.cards) do
		if joker == currentJoker then
			return true
		elseif joker == relativeJoker then
			return false
		end
	end
	return false
end

local function count_active_rare_jokers()
	local rare_jokers = 0
	if not G.jokers or not G.jokers.cards then
		return rare_jokers
	end

	for _, joker in ipairs(G.jokers.cards) do
		if joker and
		not joker.debuff and
		joker.config and
		joker.config.center and
		joker.config.center.rarity == 3 then
			rare_jokers = rare_jokers + 1
		end
	end

	return rare_jokers
end

-- Inception
SMODS.Joker {
	key = 'inception',
	loc_txt = {
		name = 'Inception',
		text = {
			"This Joker gives {X:mult,C:white}X1{} Mult",
			"for each {C:red}Rare{} Joker",
			"on every {C:attention}3rd{} trigger",
			"of the same played card",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult)"
		}
	},
	config = { extra = { rare_jokers = 0 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 2 },
	cost = 9,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		card.ability.extra.rare_jokers = count_active_rare_jokers()
		return { vars = { card.ability.extra.rare_jokers } }
	end,
	calculate = function(self, card, context)

		if context.before and not context.blueprint then

			-- Reset trigger count for played cards
			for i, playing_card in ipairs(context.full_hand) do
				playing_card.inception_trigger = nil
			end

		end

		if context.individual and context.cardarea == G.play then

			if context.other_card == nil then
				return
			end

			if not context.blueprint then

				-- Trigger count calculation
				if context.other_card.inception_trigger == nil then
					context.other_card.inception_trigger = 0
				end

				context.other_card.inception_trigger = context.other_card.inception_trigger + 1
				if context.other_card.inception_trigger == 4 then
					context.other_card.inception_trigger = 1
				end

			end

			if not context.other_card.inception_trigger then
				return
			end

			local applyMult = false

			if context.blueprint then
				if isBefore(context.blueprint_card, card) then
					-- The trigger count is not incremented yet
					applyMult = context.other_card.inception_trigger == 2
				else
					applyMult = context.other_card.inception_trigger == 3
				end
			else
				applyMult = context.other_card.inception_trigger == 3
			end

			if applyMult then
				card.ability.extra.rare_jokers = count_active_rare_jokers()
				if card.ability.extra.rare_jokers > 1 then
					return {
						x_mult = card.ability.extra.rare_jokers,
						card = card
					}
				end
			end

		end
	end
}

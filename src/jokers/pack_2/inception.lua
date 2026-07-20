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

local function get_inception_triggers(playing_card)
	playing_card.balapo_inception_triggers = playing_card.balapo_inception_triggers or {}
	return playing_card.balapo_inception_triggers
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
				playing_card.balapo_inception_triggers = nil
			end

		end

		if context.individual and context.cardarea == G.play then

			if context.other_card == nil then
				return
			end

			local inception_triggers = get_inception_triggers(context.other_card)
			local trigger_count = inception_triggers[card] or 0

			if not context.blueprint then

				-- Trigger count calculation for this Inception copy only
				trigger_count = trigger_count + 1
				if trigger_count == 4 then
					trigger_count = 1
				end
				inception_triggers[card] = trigger_count
			end

			if trigger_count == 0 then
				return
			end

			local applyMult = false

			if context.blueprint then
				if isBefore(context.blueprint_card, card) then
					-- The trigger count is not incremented yet
					applyMult = trigger_count == 2
				else
					applyMult = trigger_count == 3
				end
			else
				applyMult = trigger_count == 3
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

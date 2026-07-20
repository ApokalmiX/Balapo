-- Mouse Hole

local function get_smallest_id_if_multiple_ids(scoring_hand)
	local cards = scoring_hand

	if #cards < 2 then
		return nil
	end

	local id_set = {}
	for _, card in ipairs(cards) do
		if card.ability.effect ~= 'Stone Card' then
			id_set[card:get_id()] = true
		end
	end

	local unique_ids_list = {}
	for id in pairs(id_set) do
		table.insert(unique_ids_list, id)
	end

	if #unique_ids_list < 2 then
		return nil
	end

	local min_id = unique_ids_list[1]
	for i = 2, #unique_ids_list do
		if unique_ids_list[i] < min_id then
			min_id = unique_ids_list[i]
		end
	end

	return min_id
end

SMODS.Joker {
	key = 'mousehole',
	loc_txt = {
		name = 'Mouse Hole',
		text = {
			"{C:attention}Lowest{} ranked cards",
			"of the played hand",
			"give {X:mult,C:white} X#1# {} Mult when scored",
			"{C:inactive}(Requires at least two different rank cards)"
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,
	config = { extra = { current_lowest_rank = 0, x_mult = 1.5 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		-- Lowest rank calculation
		if context.before and not context.blueprint then
			card.ability.extra.current_lowest_rank = get_smallest_id_if_multiple_ids(context.scoring_hand)
		end

		if context.individual and context.cardarea == G.play then
			if card.ability.extra.current_lowest_rank == nil then
				return
			end
			if context.other_card:get_id() == card.ability.extra.current_lowest_rank then
				return {
					x_mult = card.ability.extra.x_mult,
					card = card
				}
			end
		end

	end
}

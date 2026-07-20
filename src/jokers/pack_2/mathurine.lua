local function get_edition_type(joker)
	if not joker or not joker.edition then
		return nil
	end

	if joker.edition.type then
		return joker.edition.type
	end

	if joker.edition.foil then
		return 'foil'
	end
	if joker.edition.holo then
		return 'holo'
	end
	if joker.edition.polychrome then
		return 'polychrome'
	end
	if joker.edition.negative then
		return 'negative'
	end

	return nil
end

local function count_matching_edition_jokers(card)
	local count = 0
	local edition_type = get_edition_type(card)
	if not edition_type then return count end
	if not G.jokers or not G.jokers.cards then return count end
	for _, v in ipairs(G.jokers.cards) do
		if v and type(v) == 'table' and not v.debuff and get_edition_type(v) == edition_type then
			count = count + 1
		end
	end
	return count
end

local function find_right_joker(card)
	if not G.jokers or not G.jokers.cards then return nil end
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i] == card then
			return G.jokers.cards[i + 1]
		end
	end
	return nil
end

local function update_mathurine_blueprint_compat(card)
	local right_joker = find_right_joker(card)
	if right_joker and right_joker ~= card and right_joker.config and right_joker.config.center and right_joker.config.center.blueprint_compat then
		card.ability.blueprint_compat = 'compatible'
	else
		card.ability.blueprint_compat = 'incompatible'
	end
end

-- Mathurine
SMODS.Joker {
	key = 'mathurine',
	loc_txt = {
		name = 'Mathurine',
		text = {
			"Copies the ability of",
			"{C:attention}Joker{} to the right",
			"once per {C:attention}Joker{} with",
			"the same {C:dark_edition}edition{}",
			"{C:inactive}(Currently {C:attention}#1#{}{C:inactive} copies)"
		}
	},
	config = { extra = { copy_count = 0 } },
	rarity = 4,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 4 },
	soul_pos = { x = 1, y = 4 },
	cost = 20,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		card.ability.extra.copy_count = count_matching_edition_jokers(card)
		card.ability.blueprint_compat_ui = card.ability.blueprint_compat_ui or ''
		card.ability.blueprint_compat_check = nil
		return {
			vars = { card.ability.extra.copy_count },
			main_end = (card.area and card.area == G.jokers) and {
				{n=G.UIT.C, config={align = "bm", minh = 0.4}, nodes={
					{n=G.UIT.C, config={ref_table = card, align = "m", colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06, func = 'blueprint_compat'}, nodes={
						{n=G.UIT.T, config={ref_table = card.ability, ref_value = 'blueprint_compat_ui', colour = G.C.UI.TEXT_LIGHT, scale = 0.32*0.8}},
					}}
				}}
			} or nil
		}
	end,
	update = function(self, card, dt)
		card.ability.extra.copy_count = count_matching_edition_jokers(card)
		update_mathurine_blueprint_compat(card)
	end,
	calculate = function(self, card, context)
		local copy_count = count_matching_edition_jokers(card)
		if copy_count <= 0 then return end

		local right_joker = find_right_joker(card)
		if not right_joker or right_joker.debuff then return end
		if not (right_joker.config and right_joker.config.center and right_joker.config.center.blueprint_compat) then return end

		local effects = {}
        for i = 1, copy_count do
        	effects[#effects+1] = SMODS.blueprint_effect(card, right_joker, context)
        end
        if next(effects) then return SMODS.merge_effects(effects) end
	end
}

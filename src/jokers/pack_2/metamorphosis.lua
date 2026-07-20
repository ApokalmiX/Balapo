local function metamorphosis_find_right_joker(card)
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i] == card then
			return G.jokers.cards[i + 1]
		end
	end
	return nil
end

local function metamorphosis_get_rarity_key(rarity)
	return ({ 'Common', 'Uncommon', 'Rare', 'Legendary' })[rarity] or rarity
end

local function metamorphosis_poll_joker_center(rarity)
	local pool = SMODS.get_clean_pool('Joker', metamorphosis_get_rarity_key(rarity), nil, 'balapo_metamorphosis')
	if not pool or #pool == 0 or pool[1] == 'empty_rarity' then
		return nil
	end

	local center_key = pseudorandom_element(pool, pseudoseed('balapo_metamorphosis'))
	return center_key and G.P_CENTERS[center_key] or nil
end

local function metamorphosis_place_joker_at(card, target_index)
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i] == card then
			table.remove(G.jokers.cards, i)
			break
		end
	end

	table.insert(G.jokers.cards, math.min(target_index, #G.jokers.cards + 1), card)
	G.jokers:set_ranks()
	G.jokers:align_cards()
end

local function metamorphosis_create_replacement_joker(source_joker, target_joker, target_index, new_center)
	local new_joker = SMODS.create_card({
		set = 'Joker',
		area = G.jokers,
		key = new_center.key,
		key_append = 'balapo_metamorphosis'
	})

	new_joker.T.x = target_joker.T.x
	new_joker.T.y = target_joker.T.y
	new_joker.facing = 'back'
	new_joker.sprite_facing = 'back'
	target_joker:remove()
	new_joker:add_to_deck()
	G.jokers:emplace(new_joker, nil, true)
	metamorphosis_place_joker_at(new_joker, target_index)
	G.GAME.joker_buffer = 0
	source_joker:juice_up(0.8, 0.8)
	return new_joker
end

-- Metamorphosis
SMODS.Joker {
	key = 'metamorphosis',
	loc_txt = {
		name = 'Metamorphosis',
		text = {
			"When {C:attention}Blind{} is selected,",
			"transform the {C:attention}Joker{} to",
			"the right into a random",
			"{C:attention}Joker{} of the same {C:attention}rarity{}"
		}
	},
	config = { extra = { } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	calculate = function(self, card, context)
		if context.setting_blind and not context.blueprint then
			local target_joker = metamorphosis_find_right_joker(card)
			if not target_joker or
			target_joker.getting_sliced or
			target_joker.debuff or
			target_joker.ability.eternal or
			not (target_joker.config and target_joker.config.center) then
				return
			end

			local target_rarity = target_joker.config.center.rarity
			local new_center = metamorphosis_poll_joker_center(target_rarity)
			if not new_center then
				return
			end

			local target_index = 0
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == target_joker then
					target_index = i
					break
				end
			end

			if target_index == 0 then
				return
			end

			target_joker.getting_sliced = true
			G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) - 1

			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.15,
				func = function()
					target_joker:flip()
					play_sound('card1', 1.0)
					target_joker:juice_up(0.3, 0.3)
					return true
				end
			}))
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.15,
				func = function()
					local new_joker = metamorphosis_create_replacement_joker(card, target_joker, target_index, new_center)
					new_joker:flip()
					play_sound('tarot2', 0.85 + math.random() * 0.3, 0.6)
					new_joker:juice_up(0.3, 0.3)
					return true
				end
			}))

			card_eval_status_text(card, 'extra', nil, nil, nil, {
				message = 'Transformed!',
				colour = G.C.FILTER,
				no_juice = true
			})
		end
	end
}

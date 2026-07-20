local function hiding_place_captured_jokers(card)
	card.ability.extra.captured_jokers = card.ability.extra.captured_jokers or {}
	return card.ability.extra.captured_jokers
end

local function hiding_place_find_right_joker(card)
	for i = 1, #G.jokers.cards do
		if G.jokers.cards[i] == card then
			return G.jokers.cards[i + 1]
		end
	end
	return nil
end

local function hiding_place_restore_joker(saved_card, silent)
	local center = saved_card.save_fields and G.P_CENTERS[saved_card.save_fields.center]
	if not center then
		return nil
	end

	local front = saved_card.save_fields and G.P_CARDS[saved_card.save_fields.card] or G.P_CARDS.empty
	local restored_joker = Card(G.jokers.T.x, G.jokers.T.y, G.CARD_W, G.CARD_H, front, center)
	restored_joker:load(saved_card)
	restored_joker.getting_sliced = nil
	restored_joker:add_to_deck()
	G.jokers:emplace(restored_joker)
	restored_joker:start_materialize(nil, silent)
	return restored_joker
end

-- Hiding place
SMODS.Joker {
	key = 'hiding_place',
	loc_txt = {
		name = 'Hiding Place',
		text = {
			"When {C:attention}Blind{} is selected,",
			"capture the {C:attention}Joker{} to the right",
			"Sell this card to restore",
			"captured {C:attention}Jokers{}",
			"Can capture up to {C:attention}#2#{} Jokers",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2# Jokers)",
			"{C:inactive}(Must have room)"
		}
	},
	config = { extra = { captured_jokers = {}, max_captured = 3 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 12,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	loc_vars = function(self, info_queue, card)
		local captured_jokers = hiding_place_captured_jokers(card)
		return { vars = { #captured_jokers, card.ability.extra.max_captured } }
	end,
	calculate = function(self, card, context)
		if context.setting_blind and not context.blueprint then
			local captured_jokers = hiding_place_captured_jokers(card)
			if #captured_jokers >= card.ability.extra.max_captured then
				return
			end

			local target_joker = hiding_place_find_right_joker(card)
			if not target_joker or
			target_joker.getting_sliced or
			target_joker.ability.eternal then
				return
			end

			target_joker.getting_sliced = true
			target_joker:remove_from_deck()
			captured_jokers[#captured_jokers + 1] = target_joker:save()
			G.GAME.joker_buffer = (G.GAME.joker_buffer or 0) - 1

			G.E_MANAGER:add_event(Event({
				func = function()
					G.GAME.joker_buffer = 0
					card:juice_up(0.8, 0.8)
					target_joker:start_dissolve({HEX("57ecab")}, nil, 1.6)
					play_sound('slice1', 0.96 + math.random() * 0.08)
					return true
				end
			}))

			card_eval_status_text(card, 'extra', nil, nil, nil, {
				message = #captured_jokers..'/'..card.ability.extra.max_captured,
				colour = G.C.FILTER,
				no_juice = true
			})
		end

		if context.selling_self and not context.blueprint then
			local captured_jokers = hiding_place_captured_jokers(card)
			if #captured_jokers == 0 then
				return
			end

			local available_slots = math.max(0, G.jokers.config.card_limit - (#G.jokers.cards - 1 + (G.GAME.joker_buffer or 0)))

			for i = 1, math.min(available_slots, #captured_jokers) do
				local saved_card = captured_jokers[i]
				local restore_delay = 0.15 * (i - 1)
				local silent = i > 1
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = restore_delay,
					func = function()
						hiding_place_restore_joker(saved_card, silent)
						return true
					end
				}))
			end

			if available_slots > 0 then
				card_eval_status_text(card, 'extra', nil, nil, nil, {
					message = '+'..math.min(available_slots, #captured_jokers)..' Jokers',
					colour = G.C.FILTER
				})
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {
					message = localize('k_no_room_ex'),
					colour = G.C.RED
				})
			end

			card.ability.extra.captured_jokers = {}
		end
	end
}

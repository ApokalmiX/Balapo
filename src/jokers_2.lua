-- The Conductor
SMODS.Joker {
	key = 'the_conductor',
	loc_txt = {
		name = 'The Conductor',
		text = {
			"Create a {C:attention}Voucher Tag{}",
			"after {C:attention}Boss Blind{} is defeated"
		}
	},
	config = { extra = { } },
	rarity = 3,
	atlas = 'BalapoJokers',
	loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'tag_voucher', set = 'Tag'}
		return { vars = {} }
    end,
	pos = { x = 0, y = 3 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		if context.end_of_round and
		not context.repetition and
		not context.individual and
		G.GAME.blind.boss then
			card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+1 Voucher Tag!", colour = G.C.FILTER})
			G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_voucher'))
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
		end
	end
}

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

local function get_poker_hand_chips(hand_name)
	if G.GAME and G.GAME.hands and hand_name and G.GAME.hands[hand_name] then
		return G.GAME.hands[hand_name].chips or 0
	end

	return 0
end

local function get_poker_hand_mult(hand_name)
	if G.GAME and G.GAME.hands and hand_name and G.GAME.hands[hand_name] then
		return G.GAME.hands[hand_name].mult or 0
	end

	return 0
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

local function is_first_active_joker(card)
	if not G.jokers or not G.jokers.cards then
		return false
	end

	local center_key = card.config and card.config.center and card.config.center.key
	for _, joker in ipairs(G.jokers.cards) do
		if joker and
		not joker.debuff and
		joker.config and
		joker.config.center and
		joker.config.center.key == center_key then
			return joker == card
		end
	end

	return false
end

local function upgrade_lucky_cats()
	if not G.jokers or not G.jokers.cards then
		return
	end

	for _, joker in ipairs(G.jokers.cards) do
		if joker and
		not joker.debuff and
		joker.ability and
		joker.ability.name == 'Lucky Cat' then
			joker.ability.x_mult = joker.ability.x_mult + joker.ability.extra
			card_eval_status_text(joker, 'extra', nil, nil, nil, {
				message = localize('k_upgrade_ex'),
				colour = G.C.MULT
			})
		end
	end
end

-- Lucky Joker
SMODS.Joker {
	key = 'lucky_joker',
	loc_txt = {
		name = 'Lucky Joker',
		text = {
			"{C:attention}Lucky Cards{} held in",
			"hand can trigger",
			"their effects"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
		return { vars = { } }
	end,
	config = { extra = { } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	calculate = function(self, card, context)
		if not is_first_active_joker(card) then
			return
		end

		if context.individual and
		context.cardarea == G.hand and
		not context.end_of_round and
		G.STATE == G.STATES.HAND_PLAYED and
		context.other_card and
		not context.other_card.debuff and
		SMODS.has_enhancement(context.other_card, 'm_lucky') then
			local lucky_card = context.other_card
			local ret = {
				card = lucky_card,
				message_card = lucky_card,
				juice_card = lucky_card
			}
			local triggered = false

			if lucky_card.ability.mult > 0 and
			SMODS.pseudorandom_probability(lucky_card, 'lucky_mult', 1, 5) then
				ret.mult = lucky_card.ability.mult
				triggered = true
			end

			if lucky_card.ability.p_dollars > 0 and
			SMODS.pseudorandom_probability(lucky_card, 'lucky_money', 1, 15) then
				ret.p_dollars = lucky_card.ability.p_dollars
				triggered = true
			end

			if triggered then
				lucky_card.lucky_trigger = true
				upgrade_lucky_cats()
				return ret
			end
		end
	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if SMODS.has_enhancement(playing_card, 'm_lucky') then
				return true
			end
		end
		return false
	end
}

-- Chips Joker
SMODS.Joker {
	key = 'bonus_joker',
	loc_txt = {
		name = 'Bonus Joker',
		text = {
			"Played {C:attention}Bonus Cards{} give",
			"the {C:chips}Chips{} of the played",
			"{C:attention}poker hand{} when scored"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
		return { vars = { } }
	end,
	config = { extra = { } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 3 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            SMODS.has_enhancement(context.other_card, 'm_bonus') then
            local hand_chips = get_poker_hand_chips(context.scoring_name)
			if hand_chips > 0 then
				return {
                	chips = hand_chips
            	}
			end
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_bonus') then
                return true
            end
        end
        return false
    end
}

-- Mult Joker
SMODS.Joker {
	key = 'mult_joker',
	loc_txt = {
		name = 'Mult Joker',
		text = {
			"Played {C:attention}Mult Cards{} give",
			"the {C:mult}Mult{} of the played",
			"{C:attention}poker hand{} when scored"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_mult
		return { vars = { } }
	end,
	config = { extra = { } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 2, y = 3 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
            SMODS.has_enhancement(context.other_card, 'm_mult') then
            local hand_mult = get_poker_hand_mult(context.scoring_name)
			if hand_mult > 0 then
				return {
                	mult = hand_mult
            	}
			end
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_mult') then
                return true
            end
        end
        return false
    end
}

-- Quarry Joker
SMODS.Joker {
	key = 'quarry_joker',
	loc_txt = {
		name = 'Quarry Joker',
		text = {
			"Draw {C:attention}1{} extra card",
			"each time a {C:attention}Stone Card{}",
			"is discarded"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_stone
		return { vars = { } }
	end,
	config = { extra = { cards = 1, pending_cards = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		if context.discard and
		context.other_card and
		not context.other_card.debuff and
		SMODS.has_enhancement(context.other_card, 'm_stone') then
			card.ability.extra.pending_cards = (card.ability.extra.pending_cards or 0) + card.ability.extra.cards

			return {
				message = "DRAW",
				colour = G.C.CHIPS
			}
		end

		local pending_cards = card.ability.extra.pending_cards or 0
		if context.drawing_cards and pending_cards > 0 then
			card.ability.extra.pending_cards = 0

			return {
				modify = context.amount + pending_cards
			}
		end
	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if SMODS.has_enhancement(playing_card, 'm_stone') then
				return true
			end
		end
		return false
	end
}

-- Wild Joker
SMODS.Joker {
	key = 'wild_joker',
	loc_txt = {
		name = 'Wild Joker',
		text = {
			"All played {C:attention}Wild{} cards",
			"have a {C:green}#1# in #2#{} chance of",
			"getting a random {C:attention}seal",
			"and a {C:green}#1# in #3#{} chance of",
			"getting a random {C:dark_edition}edition"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_wild
		return { vars = {
			G.GAME and G.GAME.probabilities.normal or 1,
			card.ability.extra.seal_odds,
			card.ability.extra.edition_odds
		} }
	end,
	config = { extra = { seal_odds = 3, edition_odds = 5 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 3, y = 3 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	calculate = function(self, card, context)
		if context.before and context.main_eval and not context.blueprint then
            local applied = 0
            for _, scored_card in ipairs(context.scoring_hand) do

                if SMODS.has_enhancement(scored_card, 'm_wild') then

                	local sealed = false
                	local editioned = false

					if scored_card.seal == nil and pseudorandom('balapo_wild_joker') < G.GAME.probabilities.normal / card.ability.extra.seal_odds then
						sealed = true
						scored_card:set_seal(SMODS.poll_seal({ guaranteed = true, type_key = 'balapo_wild_joker_seal' }))
					end

					if scored_card.edition == nil and pseudorandom('balapo_wild_joker') < G.GAME.probabilities.normal / card.ability.extra.edition_odds then
						editioned = true
						local edition = poll_edition('balapo_wild_joker', nil, true, true)
						scored_card:set_edition(edition, true)
					end

					if sealed == true or editioned == true then
						applied = applied + 1
						G.E_MANAGER:add_event(Event({
                        	func = function()
                        	    scored_card:juice_up()
                        	    return true
                        	end
                    	}))
					end

                end

            end
            if applied > 0 then
                return {
                    message = "Wild!",
                    colour = G.C.MONEY
                }
            end
        end
    end,
    in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(playing_card, 'm_wild') then
                return true
            end
        end
        return false
    end
}

function safe_get(obj, path)
    local current = obj
    for key in string.gmatch(path, "[^.]+") do
        if type(current) ~= "table" then return nil end
        current = current[key]
        if current == nil then return nil end
    end
    return current
end

function get_blind(name)
	for k, v in pairs(G.P_BLINDS) do
        if v and v.name and v.name == name then
            return v
        end
    end
    return nil
end

-- Call of the Soul
SMODS.Joker {
	key = 'call_of_the_soul',
	loc_txt = {
		name = 'The Call of the Soul',
		text = {
			"Create a {C:spectral}The Soul{} card",
			"after {C:attention}Finisher Blind{} is defeated",
			"{C:inactive}(Must have room)"
		}
	},
	config = { extra = { } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 3 },
	cost = 10,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'c_soul', set = 'Spectral'}
		return { vars = {} }
	end,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		if context.end_of_round and
		not context.repetition and
		not context.individual and
		G.GAME.blind.boss then

			sendDebugMessage('BlindName:' .. G.GAME.blind.name)

			local boss_blind = get_blind(G.GAME.blind.name)
			sendDebugMessage('BlindName2:' .. boss_blind.name)

			local showdown = safe_get(boss_blind, "boss.showdown")
			if not showdown then
				return
			end

			if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                        local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_soul', 'test2')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                    }))

                return {
                	message = '+1 The Soul',
                	colour = G.C.SECONDARY_SET.Spectral
				}
			end
		end
	end
}

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

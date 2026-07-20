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

local function find_legendaries()
    local results = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _, v in pairs(area.cards) do
                if v and type(v) == 'table' and v.config.center.rarity == 4 and v.config.center.key ~= 'j_balapo_mathurine' and not v.debuff then
                    table.insert(results, v)
                end
            end
        end
    end
    return results
end

-- Mathurine
SMODS.Joker {
	key = 'mathurine',
	loc_txt = {
		name = 'Mathurine',
		text = {
			"Copies ability of",
			"all your {C:attention}Legendary{} {C:attention}Jokers{}",
			"{C:inactive}(If compatible)"
		}
	},
	config = { extra = { } },
	rarity = 4,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 4 },
	soul_pos = { x = 1, y = 4 },
	cost = 20,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)
		local legendaries = find_legendaries()
		local effects = {}
        for i = 1, #legendaries do
        	effects[#effects+1] = SMODS.blueprint_effect(card, legendaries[i], context)
        end
        if next(effects) then return SMODS.merge_effects(effects) end
	end
}

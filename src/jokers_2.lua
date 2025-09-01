--
-- Metadata
--

SMODS.Joker {
	key = 'metadata',
	loc_txt = {
		name = 'Metadata',
		text = {
			"Create a random {C:attention}Tag{}",
			"at the end of the {C:attention}shop{}"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	calculate = function(self, card, context)

		if context.ending_shop then

			return {
				func = function()
					G.E_MANAGER:add_event(Event({
						func = (function()

							G.E_MANAGER:add_event(Event({
								func = function()

									local keys = {}
									for key, _ in pairs(G.P_TAGS) do
									    table.insert(keys, key)
									end

									local tag_key = pseudorandom_element(keys, pseudoseed('metadata'))
									sendDebugMessage('TagName:' .. tag_key)

									if tag_key == 'tag_orbital' then

										local _poker_hands = {}
    									for k, v in pairs(G.GAME.hands) do
        									if v.visible then _poker_hands[#_poker_hands+1] = k end
    									end

										G.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
									end

									local tag = Tag(tag_key, false, 'Big')
									add_tag(tag)

									G.orbital_hand = nil

                            		play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                            		play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)

                                    return true
                                end
                            }))

                            SMODS.calculate_effect({ message = 'Tagged', colour = G.C.PURPLE },
                                context.blueprint_card or card)
                            return true

                        end)
                    }))
                end
            }

        end

	end
}

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

-- Inception
SMODS.Joker {
	key = 'inception',
	loc_txt = {
		name = 'Inception',
		text = {
			"Played cards apply",
			"the {X:mult,C:white} Xmult {} of",
			"the {C:attention}Joker{} to the right",
			"every {C:attention}3{} triggers"
		}
	},
	config = { extra = { current_mult = 0 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 2 },
	cost = 9,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		-- Reset triggers table and get joker to copy
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

				-- trigger count calculation
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
					-- the trigger count is not incremented yet
					applyMult = context.other_card.inception_trigger == 2
				else
					applyMult = context.other_card.inception_trigger == 3
				end
			else
				applyMult = context.other_card.inception_trigger == 3
			end

			if applyMult then

				-- right joker calculation
				local right_joker = nil
				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i] == card then
						right_joker = G.jokers.cards[i+1]
					end
				end
				if right_joker == nil then
					return
				end

				-- Mult update (realtime)
				card.ability.extra.current_mult = 1
				if right_joker ~= card then

					-- This way of doing things is not very clean but there is no
					-- unique way to detect the xmult of a joker, so we handle all
					-- the special cases manually.

					if right_joker.ability.name == 'Steel Joker' then
						-- Specific case for Stone Joker (Realtime xmult calculation)
						card.ability.extra.current_mult = 1 + right_joker.ability.extra*right_joker.ability.steel_tally

					elseif
					right_joker.ability.name == 'Baseball Card' or
					right_joker.ability.name == 'Acrobat' or
					right_joker.ability.name == 'Flower Pot' or
					right_joker.ability.name == 'Seeing Double' or
					right_joker.ability.name == "Driver's License" or
					right_joker.ability.name == "Blackboard" then
						card.ability.extra.current_mult = right_joker.ability.extra

					elseif right_joker.ability.name == 'Caino' then
						card.ability.extra.current_mult = right_joker.ability.caino_xmult

					elseif right_joker.ability.name == "Lucky Cat" then
						card.ability.extra.current_mult = right_joker.ability.x_mult

					elseif right_joker.ability.x_mult > 1 then
						-- Normal xMult case
						card.ability.extra.current_mult = right_joker.ability.x_mult

					elseif type(right_joker.ability.extra) == "table" then

						if right_joker.ability.extra.x_mult and right_joker.ability.extra.x_mult > 1 then
							-- Specific case for custom jokers
							card.ability.extra.current_mult = right_joker.ability.extra.x_mult

						elseif right_joker.ability.extra.Xmult and right_joker.ability.extra.Xmult > 1 then
							-- Specific case for Loyalty Card, Cavendish and Card Sharp
							card.ability.extra.current_mult = right_joker.ability.extra.Xmult
						end
					end

					-- Prevent nil attribution
					if card.ability.extra.current_mult == nil then
						card.ability.extra.current_mult = 1
					end

				end

				if card.ability.extra.current_mult > 1 then
					return {
						x_mult = card.ability.extra.current_mult,
						card = card
					}
				end

			end

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

-- WIP
SMODS.Joker {
	key = 'test',
	loc_txt = {
		name = 'Test',
		text = {
			"Only {C:attention}Jokers{} can",
			"appear int the {C:attention}Shop{}"
		}
	},
	config = { extra = { } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	add_to_deck = function(self, card, from_debuff)
		G.GAME.joker_rate = 100
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.GAME.joker_rate = 20
	end,
}

-- Chips Joker
SMODS.Joker {
	key = 'bonus_joker',
	loc_txt = {
		name = 'Bonus Joker',
		text = {
			"Played {C:attention}Bonus{} cards give",
			"{C:chips}+#2#{} Chips when scored,",
			"increase by {C:chips}+#1#{} Chips",
			"each time it triggers",
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_bonus
		return { vars = { card.ability.extra.chips_bonus, card.ability.extra.extra_chips } }
	end,
	config = { extra = { chips_bonus = 5, extra_chips = 0 } },
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
            local current_bonus =  card.ability.extra.extra_chips
			if not context.blueprint then
				card.ability.extra.extra_chips = card.ability.extra.extra_chips + card.ability.extra.chips_bonus
				return {
					message = localize('k_upgrade_ex'),
                	colour = G.C.CHIPS,
                	message_card = card,
					chips = current_bonus
            	}
			elseif current_bonus > 0 then
				return {
                	chips = current_bonus
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
			"Played {C:attention}Mult{} cards give",
			"{C:mult}+#2#{} Mult when scored,",
			"increase by {C:mult}+#1#{} Mult",
			"each time it triggers",
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS.m_mult
		return { vars = { card.ability.extra.mult_bonus, card.ability.extra.extra_mult } }
	end,
	config = { extra = { mult_bonus = 1, extra_mult = 0 } },
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
            local current_bonus =  card.ability.extra.extra_mult
			if not context.blueprint then
				card.ability.extra.extra_mult = card.ability.extra.extra_mult + card.ability.extra.mult_bonus
				return {
					message = localize('k_upgrade_ex'),
                	colour = G.C.MULT,
                	message_card = card,
                	mult = current_bonus
            	}
			elseif current_bonus > 0 then
				return {
                	mult = current_bonus
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

-- WIP
SMODS.Joker {
	key = 'test2',
	loc_txt = {
		name = 'Test',
		text = {
			"Create a {C:spectral}The Soul{} card",
			"after {C:attention}Finisher Blind{} is defeated",
			"{C:inactive}(Must have room)"
		}
	},
	config = { extra = { } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 1 },
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
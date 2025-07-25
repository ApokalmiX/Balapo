SMODS.Atlas {
	-- Key for code to find it with
	key = "BalapoJokers",
	-- The name of the file, for the code to pull the atlas from
	path = "jokers.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

-- Golden Eye
SMODS.Joker {
	key = 'goldeneye',
	loc_txt = {
		name = 'Golden Eye',
		text = {
			"This Joker gains {X:mult,C:white}X#2#{} Mult",
			"every time {C:money}${}",
			"is obtained during the round,",
			"resets at the end of the round",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult)"
		}
	},
	config = { extra = { xmult_bonus = 0.25, prevDollars = 0, pending_bonus = 0, hook = false }, x_mult = 1 },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 0 },
	soul_pos = { x = 2, y = 0 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.x_mult, card.ability.extra.xmult_bonus } }
	end,
	update = function(self, card, dt)
		updateState()
	end,
	calculate = function(self, card, context)

		-- Reset end of round
		if context.end_of_round and not context.blueprint and card.ability.x_mult > 1 then
			card.ability.x_mult = 1
			--sendDebugMessage("Golden Eye reset")
			return {
				message = localize('k_reset'),
                colour = G.C.RED,
				card = card
            }
		end

		-- Global xmult bonus
		if context.joker_main then
			--sendDebugMessage("Golden Eye final xmult: " .. tostring(card.ability.x_mult))
			if card.ability.x_mult > 1 then
				return {
					Xmult_mod = card.ability.x_mult,
					message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.x_mult } }
				}
			end
		end

	end
}

-- store original ease_dollars function
local original_ease_dollars = ease_dollars

-- redefine ease_dollars function
function ease_dollars(dollars)

	original_ease_dollars(dollars)

	if active == false then
		return
	end

	if (dollars or 0) > 0 then

		-- increment jokers bonus
		for i=1, #G.jokers.cards do
			local joker = G.jokers.cards[i];
			if joker.ability.name == 'j_balapo_goldeneye' then
	        	joker.ability.x_mult = joker.ability.x_mult + joker.ability.extra.xmult_bonus
				card_eval_status_text(joker, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT, delay = 0.75, card = joker})
			end
	    end

	end

end

-- create empty table
local current_jokers = {}

active = false

-- watch state to definie activation condition
function updateState()

	if G.STATE == G.STATES.DRAW_TO_HAND or
	G.STATE == G.STATES.SELECTING_HAND then
		active = true
	end

	if G.STATE == G.STATES.NEW_ROUND or
	G.STATE == G.STATES.ROUND_EVAL or
	G.STATE == G.STATES.SHOP then
		active = false
	end

end

-- Eighties Joker
SMODS.Joker {
	key = 'eighties_joker',
	loc_txt = {
		name = 'Eighties Joker',
		text = {
			"{C:attention}Jokers{} grant their",
			"{C:dark_edition}edition{} bonus when a",
			"card from the same",
			"{C:dark_edition}edition{} is scored"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.individual and context.cardarea == G.play and context.other_card then

			if context.other_card.edition == nil then
				return
			end

			if context.other_card.debuff then
				return
			end

			local ret = {
				no_juice = true
			}
			local realRet = {
				extra = ret
			}

			for i = 1, #G.jokers.cards do

				local other_joker = G.jokers.cards[i]
				if other_joker.edition and not other_joker.debuff then

					if other_joker.edition.holo and context.other_card.edition.holo then

						ret.func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									other_joker:juice_up(0.1, 0.1)
									return true
								end
							}))
						end
						ret.extra = {
							mult = 10,
							no_juice = true
						}
						ret = ret.extra

					end

					if other_joker.edition.foil and context.other_card.edition.foil then

						ret.func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									other_joker:juice_up(0.1, 0.1)
									return true
								end
							}))
						end
						ret.extra = {
							chips = 50,
							no_juice = true
						}
						ret = ret.extra

					end

					if other_joker.edition.polychrome and context.other_card.edition.polychrome then

						ret.func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									other_joker:juice_up(0.1, 0.1)
									return true
								end
							}))
						end
						ret.extra = {
							x_mult = 1.5,
							no_juice = true
						}
						ret = ret.extra

					end

				end

			end

			if realRet.extra.extra then
				return realRet
			end

		end

	end
}

-- Reformatting
SMODS.Joker {
	key = 'reformatting',
	loc_txt = {
		name = 'Reformatting',
		text = {
			"When {C:attention}Blind{} is selected,",
			"remove the {C:dark_edition}edition{} of",
			"the {C:attention}Joker{} to the right",
			"and gains {X:mult,C:white}X#2#{} Mult",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{}{C:inactive} Mult)"
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.x_mult, card.ability.extra.xmult_bonus } }
	end,
	config = { extra = { xmult_bonus = 1 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 0 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.setting_blind and not context.blueprint then

			local current_pos = 0
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					current_pos = i
					break
				end
			end

			local other_joker = G.jokers.cards[current_pos+1]

			if other_joker and other_joker.edition then

				G.E_MANAGER:add_event(Event({
					func = function()
						card.ability.x_mult = card.ability.x_mult + card.ability.extra.xmult_bonus
						card:juice_up(0.8, 0.8)
						other_joker:set_edition(nil, true)
						other_joker:set_cost()
						play_sound('slice1', 0.96 + math.random() * 0.08)
						return true
					end
				}))

				card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT, delay = 0.75, card = card})
				return

			end

		end

		if context.joker_main then
			return {
				x_mult = card.ability.x_mult
			}
		end

	end,
	in_pool = function(self, args)
        for _, joker in ipairs(G.jokers.cards or {}) do
        	if joker.edition ~= nil then
        		return true
            end
        end
        return false
    end
}

-- Collector's Album
SMODS.Joker {
	key = 'collectorsalbum',
	loc_txt = {
		name = 'Collector\'s Album',
		text = {
			"{C:dark_edition}Edition{} of cards",
			"{C:attention}held in hand{}",
			"counts in scoring"
		}
	},
	config = { },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 3, y = 0 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.end_of_round then
			return
		end

		if context.individual and context.cardarea == G.hand and context.other_card then

			if context.other_card.edition == nil then
				return
			end

			if context.other_card.debuff then
				return
			end

			if context.other_card.edition.holo then
				return {
                	mult = context.other_card.edition.mult
				}
			end

			if context.other_card.edition.foil then
				return {
					chips = context.other_card.edition.chips
				}
			end

			if context.other_card.edition.polychrome then
				return {
                	x_mult = context.other_card.edition.x_mult
				}
			end

		end

	end,
	in_pool = function(self, args)
        for _, playing_card in ipairs(G.playing_cards or {}) do
        	if playing_card.edition ~= nil then
        		return true
            end
        end
        return false
    end
}

-- Auralist
SMODS.Joker {
	key = 'auralist',
	loc_txt = {
		name = 'Auralist',
		text = {
			"After {C:attention}5{} scoring",
			"{C:attention}Ace{} played,",
			"create an {C:spectral}Aura{} card",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/5)",
			"{C:inactive}(Must have room)"
		}
	},
	config = { extra = { ace_played = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 0, y = 0 },
	cost = 7,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.ace_played } }
	end,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.before and
		context.main_eval and
		not context.blueprint then

			local ace_cards = 0
            for _, v in ipairs(context.scoring_hand) do
                if v:get_id() == 14 and not v.debuff then ace_cards = ace_cards + 1 end
        	end

			card.ability.extra.ace_played = card.ability.extra.ace_played + ace_cards

		end

		if context.after and not context.blueprint then
			if card.ability.extra.ace_played >= 5 then
				card.ability.extra.ace_played = card.ability.extra.ace_played - 5
			end
		end

		if context.joker_main then

			if card.ability.extra.ace_played >= 5 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then

                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1

                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = (function()
                        local card = create_card(nil, G.consumeables, nil, nil, nil, nil, 'c_aura', 'auralist')
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                        G.GAME.consumeable_buffer = 0
                        return true
                    end)
                    }))

                return {
                	message = '+1 Aura',
                	colour = G.C.SECONDARY_SET.Spectral
				}
			end

		end

	end
}

-- Ghost Joker
SMODS.Joker {
	key = 'ghostjoker',
	loc_txt = {
		name = 'Ghost Joker',
		text = {
			"After selling {C:attention}1{} {C:dark_edition}Negative{} Joker",
			"sell this card to apply",
			"{C:dark_edition}Negative{} to a random Joker",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}/1)"
		}
	},
	config = { extra = { negative_joker_sold = 0 } },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 2, y = 1 },
	cost = 10,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.negative_joker_sold } }
	end,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	calculate = function(self, card, context)

		if context.selling_self and not context.blueprint then

			-- Self Negative case
			if card.edition and card.edition.negative then
				card.ability.extra.negative_joker_sold = card.ability.extra.negative_joker_sold + 1
			end

			if card.ability.extra.negative_joker_sold < 1 then
				return
			end

			local eval = function(card) return (card.ability.extra.negative_joker_sold >= 1) and not G.RESET_JIGGLES end
			juice_card_until(card, eval, true)

			local jokers = {}
            for i=1, #G.jokers.cards do
				if G.jokers.cards[i] ~= card and (not G.jokers.cards[i].edition) then
                    jokers[#jokers+1] = G.jokers.cards[i]
                end
            end

			if #jokers > 0 then
	            card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Negatived!'})
				local chosen_joker = pseudorandom_element(jokers, pseudoseed('ghostjoker'))
				local edition = {negative = true}
				chosen_joker:set_edition(edition, true)
            else
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_not_allowed_ex')})
            end

		end

		if context.selling_card and not context.blueprint  then

			if context.blueprint then
				return
			end

			if context.card == nil then
				return
			end

			if context.card.edition == nil then
				return
			end

			if context.card.debuff then
				return
			end

			if context.card.edition.negative and context.card.ability.set == 'Joker' then

				card.ability.extra.negative_joker_sold = card.ability.extra.negative_joker_sold + 1

				if card.ability.extra.negative_joker_sold == 1 then
					local eval = function(card) return not card.REMOVED end
	                juice_card_until(card, eval, true)
	            end

				return {
	            	message = (card.ability.extra.negative_joker_sold < 1) and (card.ability.extra.negative_joker_sold..'/'..2) or localize('k_active_ex'),
                	colour = G.C.FILTER
                }
			end

		end

	end
}

-- Jailed Joker
SMODS.Joker {
	key = 'jailedjoker',
	loc_txt = {
		name = 'Jailed Joker',
		text = {
			"Sell this card to",
			"apply {C:attention}Eternal{} to",
			"all other Jokers",
			"{C:inactive}(If compatible)"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 3, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = false,
	calculate = function(self, card, context)

		if context.selling_self and not context.blueprint then

			local jokers = {}
            for i=1, #G.jokers.cards do
				if G.jokers.cards[i] ~= card then
                    jokers[#jokers+1] = G.jokers.cards[i]
					G.jokers.cards[i]:set_eternal(true)
                end
            end

			if #jokers > 0 then
	            card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Eternalized!'})
            end

		end

	end
}

-- Mouse Hole
SMODS.Joker {
	key = 'mousehole',
	loc_txt = {
		name = 'Mouse Hole',
		text = {
			"Lowest-ranked card",
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

-- Acceleration
SMODS.Joker {
	key = 'acceleration',
	loc_txt = {
		name = 'Acceleration',
		text = {
			"{C:attention}+1{} hand size",
			"after each hand played,",
			"resets at the end of the round",
			"{C:inactive}(Currently {C:attention}+#1#{C:inactive} hand size)"
		}
	},
	config = { extra = { h_size = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 5, y = 0 },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.h_size } }
	end,
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	add_to_deck = function(self, card, from_debuff)
		G.hand:change_size(card.ability.extra.h_size)
	end,
	remove_from_deck = function(self, card, from_debuff)
		G.hand:change_size(-card.ability.extra.h_size)
	end,
	calculate = function(self, card, context)

		-- Reset end of round
		if context.end_of_round and not context.blueprint and card.ability.extra.h_size > 0 then
			G.hand:change_size(-card.ability.extra.h_size)
			card.ability.extra.h_size = 0
			return {
				message = localize('k_reset'),
				colour = G.C.RED,
				card = card
			}
		end

		-- Hand size increment
		if context.before and not context.blueprint then
			card.ability.extra.h_size = card.ability.extra.h_size+1
			G.hand:change_size(1)
			return {
				message = '+1 hand size!',
				colour = G.C.RED,
				card = card
			}
		end

	end
}

-- Straight to the Bed
SMODS.Joker {
	key = 'straight_to_bed',
	loc_txt = {
		name = 'Straight to the Bed',
		text = {
			"Retrigger all cards played",
			"if played hand",
			"contains a {C:attention}Straight{},",
			"Retriggers an additional time",
			"if the played hand also",
			"contains a {C:attention}Flush{}"
		}
	},
	config = { extra = { repetitions = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 5, y = 1 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.before and not context.blueprint then
			card.ability.extra.repetitions = 0
			if next(context.poker_hands['Straight']) then
				card.ability.extra.repetitions = 1
				if next(context.poker_hands['Flush']) then
					card.ability.extra.repetitions = 2
				end
			end
		end

		if card.ability.extra.repetitions and
		card.ability.extra.repetitions > 0 and
		context.repetition and
		context.cardarea == G.play then
			return {
				message = localize('k_again_ex'),
				repetitions = card.ability.extra.repetitions,
				card = card
			}
		end
	end
}

-- Alizarin
SMODS.Joker {
	key = 'alizarin',
	loc_txt = {
		name = 'Alizarin',
		text = {
			"Gain {C:attention}1{} charge each time",
			"a {C:red}Red Seal{} is discarded,",
			"With each hand played",
			"distributes the charges",
			"as additional {C:attention}retriggers{}",
			"on each card played",
			"{C:inactive}(Rounded down)",
			"{C:inactive}(Currently {C:attention}+#1#{}{C:inactive} charge)"
		}
	},
	config = { extra = { charges = 0, rettrigers = 0 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 3, y = 2 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.charges } }
	end,
	calculate = function(self, card, context)

		if context.discard and
		not context.blueprint and
		not context.other_card.debuff and
		context.other_card.seal == 'Red' then

			card.ability.extra.charges = card.ability.extra.charges + 1

			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.ORANGE
			}
		end

		if context.before and
		context.main_eval and
		not context.blueprint then

			local played_cards = #context.scoring_hand
			card.ability.extra.rettrigers = math.floor(card.ability.extra.charges / played_cards)
			if card.ability.extra.rettrigers == 0 then
				return
			end

			local charges_used = card.ability.extra.rettrigers * played_cards
			card.ability.extra.charges = card.ability.extra.charges - charges_used
		end

		if context.repetition and
		context.cardarea == G.play and
		card.ability.extra.rettrigers > 0 then
			return {
				repetitions = card.ability.extra.rettrigers
			}
		end

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Red' then
				return true
			end
		end
		return false
	end
}

-- Caerulean
SMODS.Joker {
	key = 'caerulean',
	loc_txt = {
		name = 'Caerulean',
		text = {
			"Scored {C:blue}Blue Seals{}",
			"give {X:mult,C:white} X#1# {} Mult per level",
			"of played {C:attention}poker hand{}",
			"{C:inactive}(1 + {X:mult,C:white}#1#{C:inactive} x {C:attention}hand level{C:inactive})"
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,
	config = { extra = { x_mult = 0.02 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 4, y = 2 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.individual and
		context.cardarea == G.play and
		context.other_card and
		context.other_card.seal == 'Blue' then

			if G.GAME.last_hand_played then

				local level = G.GAME.hands[G.GAME.last_hand_played].level
				local x_mult = 1 + (level*card.ability.extra.x_mult)

				if x_mult > 1 then
					return {
						x_mult = x_mult,
						card = card
					}
				end
			end

		end

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Blue' then
				return true
			end
		end
		return false
	end
}

-- Gamboge
SMODS.Joker {
	key = 'gamboge',
	loc_txt = {
		name = 'Gamboge',
		text = {
			"Scored {C:money}Gold Seals{}",
			"give {C:money}$#1#{} for each",
			"{C:attention}Gold{} card",
			"held in hand"
		}
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.dollars } }
	end,
	config = { extra = { dollars = 3 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 2, y = 2 },
	cost = 7,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	calculate = function(self, card, context)

		if context.individual and
		context.cardarea == G.play and
		context.other_card and
		context.other_card.seal == 'Gold' then

			local ret = {
				no_juice = true
			}
			local realRet = {
				extra = ret
			}

			for k, v in pairs(G.hand.cards) do
				if v and
				SMODS.has_enhancement(v, 'm_gold') and
				--v.seal == 'Gold' and
				not v.debuff then

					G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars

					ret.func = function()
						G.E_MANAGER:add_event(Event({
							func = function()
								G.GAME.dollar_buffer = 0
								v:juice_up(0.1, 0.1)
								return true
							end
						}))
					end
					ret.extra = {
						dollars = card.ability.extra.dollars,
						no_juice = true
					}
					ret = ret.extra

				end
			end

			if realRet.extra.extra then
				return realRet
			end

		end

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Gold' then
				return true
			end
		end
		return false
	end
}

-- Zinzolin
SMODS.Joker {
	key = 'zinzolin',
	loc_txt = {
		name = 'Zinzolin',
		text = {
			"{C:purple}Purple Seal{} have",
			"{C:green}#1# in #2#{} chance to",
			"create {C:spectral}Spectral{} card"
		}
	},
	config = { extra = { odds = 2 } },
	rarity = 2,
	atlas = 'BalapoJokers',
	pos = { x = 1, y = 2 },
	cost = 5,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	loc_vars = function(self, info_queue, card)
		return { vars = { G.GAME and G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
	end,
	calculate = function(self, card, context)

	end,
	in_pool = function(self, args)
		for _, playing_card in ipairs(G.playing_cards or {}) do
			if playing_card.seal == 'Purple' then
				return true
			end
		end
		return false
	end
}

local original_calculate_seal = Card.calculate_seal

function Card:calculate_seal(context)

	if not self.debuff and context.discard and context.other_card == self then
		if self.seal == 'Purple' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then

			local zinzolin = SMODS.find_card('j_balapo_zinzolin')[1]

			if zinzolin then
				if pseudorandom('j_balapo_zinzolin') < G.GAME.probabilities.normal / zinzolin.ability.extra.odds then

					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					G.E_MANAGER:add_event(Event({
						trigger = 'before',
						delay = 0.0,
						func = (function()
							local card = create_card('Spectral',G.consumeables, nil, nil, nil, nil, nil, 'j_balapo_zinzolin')
							card:add_to_deck()
							G.consumeables:emplace(card)
							G.GAME.consumeable_buffer = 0
							return true
						end)
					}))
					card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
					return nil, true
				end
			end

		end
	end

	return original_calculate_seal(self, context)

end

-- Stellium
SMODS.Joker {
	key = 'stellium',
	loc_txt = {
		name = 'Stellium',
		text = {
			"{C:planet}Planet{} cards increase",
			"hand level by the level",
			"of the weakest {C:attention}poker hand{}"
		}
	},
	config = { },
	rarity = 3,
	atlas = 'BalapoJokers',
	pos = { x = 5, y = 2 },
	cost = 10,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	calculate = function(self, card, context)
	end
}

local original_level_up_hand = level_up_hand

function level_up_hand(card, hand, instant, amount)

	amount = amount or 1

	if card and
	card.ability and
	card.ability.consumeable and
	card.ability.consumeable.hand_type and
	next(SMODS.find_card("j_balapo_stellium")) then

		local weakest_level = nil

		for k, v in pairs(G.GAME.hands) do

			if v.visible then

				if not weakest_level then
					weakest_level = v.level
				end

				if v.level < weakest_level then
					weakest_level = v.level
				end

			end

        end

		amount = weakest_level

		original_level_up_hand(card, hand, instant, amount)
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level = "+" .. amount})
		delay(1.3)
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})

	else
		original_level_up_hand(card, hand, instant, amount)
	end

end
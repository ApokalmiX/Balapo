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

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

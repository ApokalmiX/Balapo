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
		info_queue[#info_queue+1] = G.P_SEALS.Gold
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

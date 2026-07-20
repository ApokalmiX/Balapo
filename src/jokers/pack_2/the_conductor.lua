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

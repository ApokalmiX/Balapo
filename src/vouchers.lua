SMODS.Atlas {
	-- Key for code to find it with
	key = "BalapoVouchers",
	-- The name of the file, for the code to pull the atlas from
	path = "vouchers.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Voucher {
	key = "wheel_check",
	loc_txt = {
		name = 'Wheel Check',
		text = {
			"{C:attention}The Wheel of Fortune{}",
			"have a {C:attention}X3{} higher",
			"chance of applying the",
			"{C:dark_edition}Polychrome{} edition"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'c_wheel_of_fortune', set = 'Tarot'}
        info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
		return { vars = {} }
    end,
	atlas = 'BalapoVouchers',
	pos = { x = 0, y = 0 },
	cost = 10,
	config = { mult = 10 },
	unlocked = true,
	discovered = true,
	redeem = function(self, card)
		G.GAME.balapo_wheel_check = 3
	end,
	unredeem = function(self, card)
		G.GAME.balapo_wheel_check = 1
	end,
	in_pool = function(self, args)
		return true
	end
}

SMODS.Voucher {
	key = "wheel_bias",
	loc_txt = {
		name = 'Wheel Bias',
		text = {
			"{C:attention}The Wheel of Fortune{}",
			"may apply {C:dark_edition}Negative{} edition"
		}
	},
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = {key = 'c_wheel_of_fortune', set = 'Tarot'}
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
		return { vars = {} }
    end,
	atlas = 'BalapoVouchers',
	pos = { x = 0, y = 1 },
	cost = 10,
	config = { x_mult = 1.5 },
	unlocked = true,
	discovered = true,
	requires = { "v_balapo_wheel_check" },
	redeem = function(self, card)
		G.GAME.balapo_wheel_bias = true
	end,
	unredeem = function(self, card)
		G.GAME.balapo_wheel_bias = false
	end,
	in_pool = function(self, args)
		return true
	end,
	draw = function(self, card, layer)
		card.children.center:draw_shader('negative', nil, card.ARGS.send_to_shader)
	end
}

local original_poll_edition = poll_edition

function poll_edition(_key, _mod, _no_neg, _guaranteed)
	if _key == 'wheel_of_fortune' and G.GAME.balapo_wheel_check then
		if G.GAME.balapo_wheel_bias then
			_no_neg = false
		end
		local edition_poll = pseudorandom(pseudoseed(_key))
		if edition_poll > 1 - 0.003*50 and not _no_neg then
            return {negative = true}
        elseif edition_poll > 1 - 0.006*75 then
            return {polychrome = true}
        else
            return {holo = true}
		end
	end
	return original_poll_edition(_key, _mod, _no_neg, _guaranteed)
end
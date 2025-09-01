local config = SMODS.current_mod.config

SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
          align = "cm",
          padding = 0.05,
          colour = G.C.CLEAR,
        },
        nodes = {
          create_toggle({
              label = "Jokers pack 1 (restart required)",
              ref_table = config,
              ref_value = "joker_pack_1",
          }),
          create_toggle({
              label = "Jokers pack 2 (restart required)",
              ref_table = config,
              ref_value = "joker_pack_2",
          })
        },
      }
end

if config.joker_pack_1 then
    SMODS.load_file("src/jokers_1.lua")()
end

if config.joker_pack_2 then
    SMODS.load_file("src/jokers_2.lua")()
end

SMODS.load_file("src/vouchers.lua")()
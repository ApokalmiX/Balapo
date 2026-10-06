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
          }),
          create_toggle({
              label = "Jokers pack 3 - Development (restart required)",
              ref_table = config,
              ref_value = "joker_pack_3",
          })
        },
      }
end

SMODS.load_file("src/jokers/atlas.lua")()

if config.joker_pack_1 then
    SMODS.load_file("src/jokers/pack_1.lua")()
end

if config.joker_pack_2 then
    SMODS.load_file("src/jokers/pack_2.lua")()
end

if config.joker_pack_3 then
    SMODS.load_file("src/jokers/pack_3.lua")()
end

SMODS.load_file("src/vouchers.lua")()

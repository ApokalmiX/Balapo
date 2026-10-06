local prohibited_sets = {
    Tarot = true,
    Planet = true,
    Base = true,
    Default = true,
    Enhanced = true,
    ['Playing Card'] = true,
    playing_card = true,
}

local function curated_shop_active()
    for _, joker in ipairs(G.jokers and G.jokers.cards or {}) do
        if joker.config.center.key == 'j_balapo_curated_shop'
            and not joker.debuff and not joker.getting_sliced then
            return true
        end
    end
    return false
end

local function curated_shop_type()
    local types = {'Joker'}
    if SMODS.ConsumableType and SMODS.ConsumableType.obj_buffer then
        for _, set in ipairs(SMODS.ConsumableType.obj_buffer) do
            if not prohibited_sets[set] then
                types[#types + 1] = set
            end
        end
    else
        types[#types + 1] = 'Spectral'
    end

    local total = 0
    for _, set in ipairs(types) do
        total = total + math.max(0, G.GAME[set:lower() .. '_rate'] or 0)
    end
    -- Keep the shop populated even if all eligible type weights are zero.
    if total <= 0 then return 'Joker' end

    local roll = pseudorandom('balapo_curated_shop_type' .. G.GAME.round_resets.ante) * total
    for _, set in ipairs(types) do
        local weight = math.max(0, G.GAME[set:lower() .. '_rate'] or 0)
        if weight > 0 and roll < weight then return set end
        roll = roll - weight
    end
    return 'Joker'
end

-- Filter before construction so ordinary replacement Jokers receive normal
-- shop editions and stickers. Tags still execute and consume themselves.
local original_create_card = create_card
create_card = function(set, area, legendary, rarity, skip_materialize, soulable, forced_key, key_append)
    local forced_center = forced_key and G.P_CENTERS[forced_key]
    local actual_set = forced_center and forced_center.set or set
    if area and area == G.shop_jokers and curated_shop_active() and prohibited_sets[actual_set] then
        set = curated_shop_type()
        legendary, rarity, soulable, forced_key = nil, nil, nil, nil
        -- SMODS.create_card may have supplied a playing-card front.
        local front = SMODS.set_create_card_front
        SMODS.set_create_card_front = nil
        local success, card = pcall(original_create_card, set, area, legendary, rarity,
            skip_materialize, soulable, forced_key, key_append)
        SMODS.set_create_card_front = front
        if not success then error(card, 0) end
        return card
    end
    return original_create_card(set, area, legendary, rarity, skip_materialize, soulable, forced_key, key_append)
end

local function curated_shop_replacement_center()
    local set = curated_shop_type()
    local pool, pool_key = get_current_pool(set, nil, nil, 'balapo_curated_shop')
    local eligible = {}
    for _, key in ipairs(pool) do
        local center = G.P_CENTERS[key]
        if center and not prohibited_sets[center.set] then
            eligible[#eligible + 1] = key
        end
    end
    if #eligible == 0 then return G.P_CENTERS.j_joker end
    return G.P_CENTERS[pseudorandom_element(eligible, pseudoseed(pool_key))]
end

-- Tutorial overrides and mods may construct a Card directly, bypassing
-- create_card. Convert that offer in place to preserve queued UI/tag references.
local original_create_card_for_shop = create_card_for_shop
create_card_for_shop = function(area)
    local card = original_create_card_for_shop(area)
    if card and area and area == G.shop_jokers and curated_shop_active()
        and prohibited_sets[card.ability.set] then
        local couponed = card.ability.couponed
        card:set_ability(curated_shop_replacement_center())
        card:set_base(nil, true)
        card.config.card_key = nil
        card.ability.couponed = couponed
        card:set_cost()
    end
    return card
end

SMODS.Joker {
    key = 'curated_shop',
    loc_txt = {
        name = 'Curated Shop',
        text = {
            '{C:attention}Tarot{}, {C:attention}Planet{}, and',
            '{C:attention}playing cards{} no longer',
            'appear individually in the {C:attention}shop{}',
            '{C:inactive}(Existing offers and boosters unchanged)',
        },
    },
    config = {extra = {}},
    rarity = 2,
    cost = 6,
    atlas = 'BalapoJokers',
    pos = {x = 1, y = 1},
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
}

-- Run with a Lua 5.1-compatible interpreter from the project root.
local registered, last_request, next_offer
local roll = 0
local fail_creation = false
local tag_count = 0

G = {
    jokers = {cards = {}},
    shop_jokers = {},
    pack_cards = {},
    shop_vouchers = {},
    GAME = {
        joker_rate = 20, tarot_rate = 4, planet_rate = 4,
        playing_card_rate = 4, spectral_rate = 0,
        round_resets = {ante = 1},
    },
    P_CENTERS = {},
}

for key, set in pairs({
    j_joker = 'Joker', c_tarot = 'Tarot', c_planet = 'Planet',
    c_spectral = 'Spectral', c_base = 'Default', c_bonus = 'Enhanced',
}) do
    G.P_CENTERS[key] = {key = key, set = set}
end

local centers = {
    Joker = 'j_joker', Tarot = 'c_tarot', Planet = 'c_planet',
    Spectral = 'c_spectral', Base = 'c_base', Enhanced = 'c_bonus',
}

local function make_card(center)
    local card = {config = {center = center}, ability = {set = center.set}}
    function card:set_ability(new_center)
        self.config.center = new_center
        self.ability = {set = new_center.set}
    end
    function card:set_base(front, initial)
        assert(initial, 'Replacement must not trigger a deck modification')
        self.config.card = front
    end
    function card:set_cost() self.cost_updated = true end
    return card
end

SMODS = {
    ConsumableType = {obj_buffer = {'Tarot', 'Planet', 'Spectral'}},
    Joker = function(definition) registered = definition end,
}

function pseudorandom() return roll end
function pseudoseed(seed) return seed end
function pseudorandom_element(pool) return pool[1] end
function get_current_pool(set)
    return {'UNAVAILABLE', centers[set]}, 'test_pool'
end

function create_card(set, area, legendary, rarity, skip, soulable, key, append)
    if fail_creation then error('creation failure') end
    last_request = {
        set = set, key = key, rarity = rarity, legendary = legendary,
        soulable = soulable, front = SMODS.set_create_card_front,
    }
    return make_card(G.P_CENTERS[key or centers[set]])
end

function create_card_for_shop(area)
    if next_offer.direct then
        tag_count = tag_count + 1
        local card = make_card(G.P_CENTERS[next_offer.key])
        card.ability.couponed = true
        next_offer.reference = card
        return card
    end
    return create_card(next_offer.set, area, nil, nil, nil, nil, next_offer.key)
end

dofile('src/jokers/pack_3/curated_shop.lua')
assert(registered.key == 'curated_shop')
assert(registered.rarity == 2 and registered.cost == 6)
assert(registered.blueprint_compat == false)
assert(registered.pos.x == 1 and registered.pos.y == 1)
assert(dofile('config.lua').joker_pack_3 == true)

local function own(debuff)
    return {config = {center = {key = 'j_balapo_curated_shop'}}, debuff = debuff}
end

-- Inactive and debuffed copies leave generation untouched.
assert(create_card('Tarot', G.shop_jokers).ability.set == 'Tarot')
G.jokers.cards = {own(true)}
assert(create_card('Planet', G.shop_jokers).ability.set == 'Planet')
G.jokers.cards = {own(false)}

-- Block all prohibited sets and forced keys, without editing run rates.
for _, set in ipairs({'Tarot', 'Planet', 'Base', 'Enhanced'}) do
    assert(create_card(set, G.shop_jokers).ability.set == 'Joker')
end
create_card('Joker', G.shop_jokers, true, 1, nil, true, 'c_tarot')
assert(last_request.set == 'Joker' and last_request.key == nil)
assert(last_request.rarity == nil and last_request.legendary == nil and last_request.soulable == nil)
assert(G.GAME.tarot_rate == 4 and G.GAME.planet_rate == 4 and G.GAME.playing_card_rate == 4)

-- Spectral offers require positive existing weight; a zero-weight pool falls back.
roll = 0.99
assert(create_card('Tarot', G.shop_jokers).ability.set == 'Joker')
G.GAME.spectral_rate = 10
assert(create_card('Tarot', G.shop_jokers).ability.set == 'Spectral')
assert(create_card('Spectral', G.shop_jokers).ability.set == 'Spectral')
G.GAME.joker_rate, G.GAME.spectral_rate = 0, 0
assert(create_card('Tarot', G.shop_jokers).ability.set == 'Joker')
G.GAME.joker_rate = 20
roll = 0

-- Booster contents and other areas are unaffected, including forced keys.
assert(create_card('Tarot', G.pack_cards).ability.set == 'Tarot')
assert(create_card('Joker', G.pack_cards, nil, nil, nil, nil, 'c_planet').ability.set == 'Planet')
assert(create_card('Base', G.pack_cards).ability.set == 'Default')
assert(create_card('Tarot', G.shop_vouchers).ability.set == 'Tarot')

-- Preserve queued tag/UI references for offers constructed directly.
for _, key in ipairs({'c_tarot', 'c_planet', 'c_base', 'c_bonus'}) do
    next_offer = {direct = true, key = key}
    local card = create_card_for_shop(G.shop_jokers)
    assert(card == next_offer.reference)
    assert(card.ability.set == 'Joker' and card.ability.couponed and card.cost_updated)
end
assert(tag_count == 4)

-- Buying does not touch existing stock, and one active copy is sufficient.
local existing = make_card(G.P_CENTERS.c_tarot)
G.shop_jokers.cards = {existing}
G.jokers.cards = {own(true), own(false)}
assert(create_card('Tarot', G.shop_jokers).ability.set == 'Joker')
assert(existing.ability.set == 'Tarot')
table.remove(G.jokers.cards, 2)
assert(create_card('Tarot', G.shop_jokers).ability.set == 'Tarot')
G.jokers.cards = {}
assert(create_card('Planet', G.shop_jokers).ability.set == 'Planet')

-- Playing-card front overrides are suppressed and restored even after errors.
G.jokers.cards = {own(false)}
local front = {}
SMODS.set_create_card_front = front
create_card('Base', G.shop_jokers)
assert(last_request.front == nil and SMODS.set_create_card_front == front)
fail_creation = true
assert(not pcall(create_card, 'Tarot', G.shop_jokers))
assert(SMODS.set_create_card_front == front)

print('Curated Shop behavior checks passed')

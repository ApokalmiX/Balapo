-- Run with a Lua 5.1-compatible interpreter from the project root.
local registered
local calls = 0
local nested, deferred
local full_hand = {{}}

G = {
    GAME = {current_round = {hands_played = 3, hands_left = 0}},
    jokers = {cards = {}},
    play = {cards = full_hand},
}
SMODS = {Joker = function(definition) registered = definition end}
Card = {}

function Card:calculate_joker(context, ...)
    calls = calls + 1
    if context.raise_error then error('evaluation failure') end
    if context.nested then
        nested:calculate_joker({full_hand = full_hand, joker_main = true})
        assert(G.GAME.current_round.hands_played == 0, 'Nested call lost the parent counter')
    end
    if context.defer then
        deferred = function() return G.GAME.current_round.hands_played end
    end
    return {
        first = G.GAME.current_round.hands_played == 0,
        last = G.GAME.current_round.hands_left == 0,
    }, nil, 'post', select('#', ...)
end

dofile('src/jokers/pack_3/encore.lua')
assert(registered.key == 'encore' and registered.rarity == 2 and registered.cost == 6)
assert(registered.blueprint_compat == false)
assert(registered.pos.x == 1 and registered.pos.y == 1)

local function joker(key, debuff)
    return setmetatable({
        ability = {set = 'Joker'}, config = {center = {key = key}}, debuff = debuff,
    }, {__index = Card})
end
local target = joker('j_test')
nested = joker('j_copy')
local encore = joker('j_balapo_encore')
local context = {full_hand = full_hand, before = true}

-- Ownership and debuffs determine eligibility without persistent counters.
assert(not target:calculate_joker(context).first)
G.jokers.cards = {encore}
local effect, empty, post, argument_count = target:calculate_joker(context, 'extra', nil)
assert(effect.first and effect.last)
assert(empty == nil and post == 'post' and argument_count == 2)
assert(G.GAME.current_round.hands_played == 3 and G.GAME.current_round.hands_left == 0)
encore.debuff = true
assert(not target:calculate_joker(context).first)
encore.debuff = false

-- Non-last hands retain normal behavior.
G.GAME.current_round.hands_left = 1
assert(not target:calculate_joker(context).first)
G.GAME.current_round.hands_left = 0

-- Other contexts and non-Joker cards do not see a synthetic first hand.
for _, other_context in ipairs({
    {first_hand_drawn = true}, {end_of_round = true}, {setting_blind = true},
    {full_hand = full_hand, discard = true},
    {full_hand = full_hand, pre_discard = true},
    {full_hand = full_hand, end_of_round = true},
    {full_hand = full_hand, first_hand_drawn = true},
    {full_hand = {{}}},
}) do
    assert(not target:calculate_joker(other_context).first)
end
local consumable = joker('c_test')
consumable.ability.set = 'Planet'
assert(not consumable:calculate_joker(context).first)

-- Destruction checks used by Sixth Sense and normal scoring both see eligibility.
assert(target:calculate_joker({full_hand = full_hand, destroying_card = full_hand[1]}).first)
assert(target:calculate_joker({full_hand = full_hand, joker_main = true}).first)

-- Multiple owned copies and a genuine first/last hand do not add activations.
G.jokers.cards = {encore, joker('j_balapo_encore')}
local before_calls = calls
target:calculate_joker(context)
assert(calls == before_calls + 1)
G.GAME.current_round.hands_played = 0
before_calls = calls
assert(target:calculate_joker(context).first)
assert(calls == before_calls + 1 and G.GAME.current_round.hands_played == 0)
G.GAME.current_round.hands_played = 3

-- Nested copies, deferred work, and exceptions restore the original state.
target:calculate_joker({full_hand = full_hand, nested = true, defer = true})
assert(G.GAME.current_round.hands_played == 3 and deferred() == 3)
assert(not pcall(target.calculate_joker, target, {full_hand = full_hand, raise_error = true}))
assert(G.GAME.current_round.hands_played == 3)

-- Removing the final active copy stops the effect; a debuffed duplicate cannot keep it alive.
G.jokers.cards = {joker('j_balapo_encore', true)}
assert(not target:calculate_joker(context).first)
G.jokers.cards = {}
assert(not target:calculate_joker(context).first)

print('Encore behavior checks passed')

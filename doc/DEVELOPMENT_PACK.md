# Development Joker Pack

Pack 3 is reserved for experimental Jokers that are still being developed or playtested.

## Activation

- The pack is enabled by default. A previously saved explicit setting still takes precedence.
- Enable **Jokers pack 3 - Development (restart required)** in the mod configuration to load it.
- Restart the game after changing the option.
- Packs 1 and 2 can be enabled or disabled independently of this pack.
- The pack currently contains Curated Shop and Encore.

## Adding a Joker

1. Record the design in a dedicated file under `doc/joker_ideas/` and link it from [the idea index](NEW_JOKER_IDEAS.md).
2. When implementation is requested, create the Joker file under `src/jokers/pack_3/`.
3. Load the file from `src/jokers/pack_3.lua` using the same `SMODS.load_file` pattern as the other packs.
4. Use the `BalapoJokers` atlas at position `(1, 1)` unless another asset is requested.
5. Enable the development pack, restart the game, and perform relevant manual playtests.
6. Record results and unresolved issues in the Joker's design document.

## First Planned Joker

[Curated Shop](joker_ideas/curated_shop.md) is implemented in this pack and awaits in-game playtesting.

## Additional Implemented Joker

[Encore](joker_ideas/last_hand_first.md) makes the last available hand also count as the first for Joker abilities. It is implemented; the user reported that an initial in-game trial appears to work correctly.

SMODS.Atlas {
    key = "reality_warp_decks",
    path = "decks.png",
    px = 71,
    py = 95
}

local function reparse_deck_entry(entry)
    if not entry then return end
    local parse_fn = loc_parse_string or function(s) return { { strings = { s }, control = {} } } end

    if entry.text then
        entry.text_parsed = {}
        for _, line in ipairs(entry.text) do
            if type(line) == 'table' then
                local sub = {}
                for _, sub_line in ipairs(line) do
                    sub[#sub + 1] = parse_fn(sub_line) or { { strings = { tostring(sub_line) }, control = {} } }
                end
                entry.text_parsed[#entry.text_parsed + 1] = sub
            else
                entry.text_parsed[#entry.text_parsed + 1] = parse_fn(line) or { { strings = { tostring(line) }, control = {} } }
            end
        end
    else
        entry.text_parsed = entry.text_parsed or {}
    end

    if entry.name then
        entry.name_parsed = {}
        local names = (type(entry.name) == 'table') and entry.name or { entry.name }
        for _, line in ipairs(names) do
            entry.name_parsed[#entry.name_parsed + 1] = parse_fn(line) or { { strings = { tostring(line) }, control = {} } }
        end
    else
        entry.name_parsed = entry.name_parsed or {}
    end
end

reality_warp_DECKS = reality_warp_DECKS or {}
reality_warp_DECK_HOOKS = reality_warp_DECK_HOOKS or {}
reality_warp_DECK_LOCS = reality_warp_DECK_LOCS or {}

function register_reality_warp_deck(deck_def)
    if not deck_def or not deck_def.key then return end
    reality_warp_DECKS[deck_def.key] = deck_def
    if deck_def.loc_txt then
        reality_warp_DECK_LOCS[deck_def.key] = {
            name = deck_def.loc_txt.name or deck_def.name,
            text = deck_def.loc_txt.text
        }
    end
    local back_obj = SMODS.Back(deck_def)
    if inject_reality_warp_deck_localization then
        inject_reality_warp_deck_localization()
    end
    return back_obj
end

function add_reality_warp_deck_hook(deck_key, hook_fn)
    if not deck_key or not hook_fn then return end
    reality_warp_DECK_HOOKS[deck_key] = reality_warp_DECK_HOOKS[deck_key] or {}
    table.insert(reality_warp_DECK_HOOKS[deck_key], hook_fn)
end

SMODS.Back {
    name = 'Caveman Deck',
    key = 'cavernicola',
    atlas = 'reality_warp_decks',
    pos = { x = 0, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Caveman Deck',
        text = {
            "Start with only {C:attention}A, 2, 3, 4, 6, 8{} of each suit in your full deck,",
            "all other starting cards are {C:attention}Stone Cards{},",
            "{C:red}-1{} Hand"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                local is_combo = false
                if CardSleeves and G.GAME then
                    if G.GAME.cavernicola_sleeve_combo then
                        is_combo = true
                    elseif G.GAME.selected_sleeve then
                        local s = tostring(G.GAME.selected_sleeve.key or G.GAME.selected_sleeve.name or G.GAME.selected_sleeve)
                        if string.find(string.lower(s), "cavernicola", 1, true) ~= nil then
                            is_combo = true
                        end
                    end
                end

                if G.playing_cards then
                    local keep_ranks = is_combo and { ['Ace'] = true, ['2'] = true, ['3'] = true }
                        or { ['Ace'] = true, ['2'] = true, ['3'] = true, ['4'] = true, ['6'] = true, ['8'] = true }
                    for _, card in ipairs(G.playing_cards) do
                        local val = card.base and card.base.value
                        if not keep_ranks[val] then
                            card:set_ability(G.P_CENTERS.m_stone)
                        end
                    end
                end

                if not is_combo then
                    G.GAME.starting_params.hands = G.GAME.starting_params.hands - 1
                    G.GAME.round_resets.hands = math.max(1, G.GAME.round_resets.hands - 1)
                    ease_hands_played(-1)
                end

                return true
            end
        }))
    end
}

SMODS.Back {
    name = 'Strategist Deck',
    key = 'strategist',
    atlas = 'reality_warp_decks',
    pos = { x = 1, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Strategist Deck',
        text = {
            "Start with a {C:attention}24-card deck{}",
            "{C:inactive}(Aces, Kings, Queens, Jacks, 10s, 9s){}",
            "Start with {C:attention}Magic Trick{} voucher,",
            "Start with {C:money}$0{}, {C:red}-1{} hand, {C:red}-2{} discards,",
            "Blind score targets are {C:attention}X1.2{}"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                local is_combo = G.GAME and (G.GAME.strategist_sleeve_combo or is_sleeve_matching("strategist"))
                if G.playing_cards then
                    for i = #G.playing_cards, 1, -1 do
                        local card = G.playing_cards[i]
                        local val = card.base and card.base.value
                        local keep = false
                        if is_combo then
                            keep = (val == 'Ace' or val == 'King' or val == 'Queen' or val == 'Jack' or val == '10')
                        else
                            keep = (val == 'Ace' or val == 'King' or val == 'Queen' or val == 'Jack' or val == '10' or val == '9')
                        end
                        if not keep then
                            if card.area then
                                card.area:remove_card(card)
                            end
                            card:remove()
                            table.remove(G.playing_cards, i)
                        end
                    end
                end

                G.GAME.dollars = 0

                G.GAME.round_resets.hands = math.max(1, G.GAME.round_resets.hands - 1)
                ease_hands_played(-1)

                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 2)
                ease_discard(-2)

                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers['v_magic_trick'] = true
                if is_combo then
                    G.GAME.used_vouchers['v_tarot_merchant'] = true
                    if G.GAME.shop then
                        G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
                    end
                    G.GAME.modifiers = G.GAME.modifiers or {}
                    G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 0) + 1
                end

                G.GAME.starting_params.ante_scaling = (G.GAME.starting_params.ante_scaling or 1) * 1.2

                return true
            end
        }))
    end
}

SMODS.Back {
    name = 'Overseer Deck',
    key = 'overseer',
    atlas = 'reality_warp_decks',
    pos = { x = 2, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Overseer Deck',
        text = {
            "Creates a random {C:spectral}Spectral card{}",
            "at the end of round {C:inactive}(except Rot, Soul and Secrets){},",
            "{C:attention}Tags are always doubled{},",
            "Joker prices are {C:red}X1.5{},",
            "Start with {C:money}$5{}, {C:red}-1{} hand, {C:red}-1{} discard"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.overseer_deck = true
                local is_combo = G.GAME and (G.GAME.overseer_sleeve_combo or is_sleeve_matching("overseer"))
                if is_combo then
                    G.GAME.overseer_no_markup = true
                    G.GAME.dollars = 7
                else
                    G.GAME.dollars = 5
                    G.GAME.round_resets.hands = math.max(1, G.GAME.round_resets.hands - 1)
                    ease_hands_played(-1)
                end

                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)

                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        local is_combo = G.GAME and (G.GAME.overseer_sleeve_combo or is_sleeve_matching("overseer"))
        if not is_combo and context.end_of_round and not context.individual and not context.repetition then
            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local forbidden = {
                            ['c_rot'] = true,
                            ['c_reality_warp_rot'] = true,
                            ['c_soul'] = true,
                            ['c_the_gang'] = true,
                            ['c_reality_warp_the_gang'] = true,
                            ['the_gang'] = true,
                            ['c_la_muchachada'] = true,
                            ['c_reality_warp_la_muchachada'] = true,
                            ['la_muchachada'] = true,
                        }
                        local valid_spectrals = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Spectral'] then
                            for _, center in ipairs(G.P_CENTER_POOLS['Spectral']) do
                                local k = center.key
                                local is_nemesis = (k == 'c_wraith' or string.find(k, 'nemesis', 1, true) or string.find(k, 'wraith', 1, true))
                                local is_forbidden = not is_nemesis and (
                                    forbidden[k] or
                                    string.find(k, 'rot', 1, true) or
                                    string.find(k, 'soul', 1, true) or
                                    string.find(k, 'the_gang', 1, true) or
                                    string.find(k, 'muchachada', 1, true) or
                                    string.find(k, 'secret', 1, true) or
                                    string.find(k, 'legendary', 1, true)
                                )
                                if not is_forbidden then
                                    table.insert(valid_spectrals, k)
                                end
                            end
                        end
                        local chosen_key = (#valid_spectrals > 0) and pseudorandom_element(valid_spectrals, pseudoseed('overseer')) or 'c_ankh'
                        local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_key, 'overseer')
                        scard:add_to_deck()
                        G.consumeables:emplace(scard)
                        scard:juice_up(0.5, 0.5)
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Back {
    name = 'Friendly Deck',
    key = 'friendly',
    atlas = 'reality_warp_decks',
    pos = { x = 3, y = 0 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Friendly Deck',
        text = {
            "Start run with {C:attention}2 random Negative Eternal Jokers{},",
            "{C:inactive}(At least 1 Uncommon or Rare, no Secrets/Legendaries){},",
            "{C:red}-1{} Joker slot, {C:red}-1{} Discard, {C:money}+$4{}"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                local is_combo = false
                if CardSleeves and G.GAME then
                    if G.GAME.friendly_sleeve_combo then
                        is_combo = true
                    elseif G.GAME.selected_sleeve then
                        local s = tostring(G.GAME.selected_sleeve.key or G.GAME.selected_sleeve.name or G.GAME.selected_sleeve)
                        if string.find(string.lower(s), "friendly", 1, true) ~= nil then
                            is_combo = true
                        end
                    end
                end

                local num_jokers = is_combo and 3 or 2
                local slot_penalty = is_combo and 2 or 1

                if G.jokers and G.jokers.config then
                    G.jokers.config.card_limit = math.max(1, G.jokers.config.card_limit - slot_penalty)
                end
                if G.GAME and G.GAME.starting_params and G.GAME.starting_params.joker_slots then
                    G.GAME.starting_params.joker_slots = math.max(1, G.GAME.starting_params.joker_slots - slot_penalty)
                end

                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)

                if not is_combo then
                    ease_dollars(4)
                end

                play_sound('foil1')
                for i = 1, num_jokers do
                    local new_joker = nil
                    local attempts = 0
                    repeat
                        attempts = attempts + 1
                        local roll = pseudorandom('friendly_roll_' .. i .. '_' .. attempts)
                        local roll_type = 'common'

                        if is_combo then
                            if roll < 0.01 then -- 1 en 100 de ser secreto
                                roll_type = 'secret'
                            elseif roll < 0.06 then -- 1 en 20 de ser legendario (0.01 + 0.05)
                                roll_type = 'legendary'
                            elseif roll < 0.185 then -- 1 en 8 de ser raro (0.06 + 0.125)
                                roll_type = 'rare'
                            elseif roll < 0.435 then -- 1 en 4 de ser poco comun (0.185 + 0.25)
                                roll_type = 'uncommon'
                            else -- 1 en 2 de ser comun (resto)
                                roll_type = 'common'
                            end
                        else
                            if i == 1 then
                                if roll < 0.35 then
                                    roll_type = 'rare'
                                else
                                    roll_type = 'uncommon'
                                end
                            else
                                if roll < 0.125 then -- 1 en 8 de ser raro
                                    roll_type = 'rare'
                                elseif roll < 0.375 then -- 1 en 4 de ser poco comun (0.125 + 0.25)
                                    roll_type = 'uncommon'
                                else -- 1 en 2 de ser comun (resto)
                                    roll_type = 'common'
                                end
                            end
                        end

                        if roll_type == 'secret' then
                            local secret_keys = {
                                'esteban', 'thiago', 'black_hole_joker',
                                'squele', 'bluxdir', 'charles', 'mochi',
                                'helin', 'raytracing', 'paco', 'yairo',
                                'kyra'
                            }
                            local valid_secrets = {}
                            for _, sk in ipairs(secret_keys) do
                                local k = 'j_reality_warp_' .. sk
                                if G.P_CENTERS and G.P_CENTERS[k] then
                                    table.insert(valid_secrets, k)
                                end
                            end
                            if #valid_secrets == 0 and G.P_CENTERS then
                                for pk, pv in pairs(G.P_CENTERS) do
                                    if pv.set == 'Joker' and (pv.is_secret or pv.rarity == 'Secret') then
                                        table.insert(valid_secrets, pk)
                                    end
                                end
                            end
                            local chosen_secret = (#valid_secrets > 0) and pseudorandom_element(valid_secrets, pseudoseed('friendly_secret_' .. i .. '_' .. attempts)) or nil
                            if chosen_secret then
                                new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen_secret, 'friendly_secret')
                            else
                                new_joker = create_card('Joker', G.jokers, true, nil, nil, false, nil, 'friendly_legendary')
                            end
                        elseif roll_type == 'legendary' then
                            new_joker = create_card('Joker', G.jokers, true, nil, nil, false, nil, 'friendly_legendary')
                        elseif roll_type == 'rare' then
                            new_joker = create_card('Joker', G.jokers, false, 0.99, nil, false, nil, 'friendly_rare')
                        elseif roll_type == 'uncommon' then
                            new_joker = create_card('Joker', G.jokers, false, 0.8, nil, false, nil, 'friendly_uncommon')
                        else -- common
                            new_joker = create_card('Joker', G.jokers, false, 0.5, nil, false, nil, 'friendly_common')
                        end

                        if new_joker and roll_type ~= 'secret' and is_invalid_eternal_joker(new_joker) then
                            if new_joker.area then new_joker.area:remove_card(new_joker) end
                            new_joker:remove()
                            new_joker = nil
                        end
                    until new_joker or attempts >= 20

                    if not new_joker then
                        new_joker = create_card('Joker', G.jokers, false, 0.5, nil, false, nil, 'friendly_fallback')
                    end

                    new_joker:set_eternal(true)
                    if new_joker.ability then new_joker.ability.eternal = true end
                    new_joker:set_edition({ negative = true }, true)
                    new_joker:add_to_deck()
                    G.jokers:emplace(new_joker)
                    new_joker:juice_up(0.5, 0.5)
                end
                return true
            end
        }))
    end
}

SMODS.Back {
    name = 'Alchemist Deck',
    key = 'alchemist',
    atlas = 'reality_warp_decks',
    pos = { x = 0, y = 1 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Alchemist Deck',
        text = {
            "Start run with the voucher",
            "{C:attention,T:v_reality_warp_destilacion_recurrente}Recurring Distillation{}"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.alchemist_deck = true
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers.v_reality_warp_destilacion_recurrente = true
                G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true
                G.GAME.used_vouchers.v_destilacion_recurrente = true
                G.GAME.used_vouchers.destilacion_recurrente = true

                local is_combo = G.GAME and (G.GAME.alchemist_sleeve_combo or is_sleeve_matching("alchemist"))
                if is_combo then
                    G.GAME.alchemist_sleeve_combo = true
                    if not G.GAME.alchemist_fusion_kyra_given and G.jokers then
                        G.GAME.alchemist_fusion_kyra_given = true
                        local kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_reality_warp_kyra', 'alchemist_fusion')
                        if not kyra_card or not kyra_card.config then
                            kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'kyra', 'alchemist_fusion_fallback')
                        end
                        if kyra_card then
                            kyra_card:set_eternal(true)
                            if kyra_card.ability then kyra_card.ability.eternal = true end
                            kyra_card:add_to_deck()
                            G.jokers:emplace(kyra_card)
                            kyra_card:juice_up(0.6, 0.6)
                            card_eval_status_text(kyra_card, 'extra', nil, nil, nil, { message = 'Kyra Summoned!', colour = G.C.GOLD })
                        end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if (context.first_hand_drawn or context.setting_blind) and not context.blueprint and not context.individual and not context.repetition then
            G.GAME.used_vouchers = G.GAME.used_vouchers or {}
            G.GAME.used_vouchers.v_reality_warp_destilacion_recurrente = true
            G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true

            local is_combo = G.GAME and (G.GAME.alchemist_sleeve_combo or is_sleeve_matching("alchemist"))
            if is_combo and not G.GAME.alchemist_fusion_kyra_given and G.jokers then
                G.GAME.alchemist_fusion_kyra_given = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_reality_warp_kyra', 'alchemist_fusion')
                        if not kyra_card or not kyra_card.config then
                            kyra_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'kyra', 'alchemist_fusion_fallback')
                        end
                        if kyra_card then
                            kyra_card:set_eternal(true)
                            if kyra_card.ability then kyra_card.ability.eternal = true end
                            kyra_card:add_to_deck()
                            G.jokers:emplace(kyra_card)
                            kyra_card:juice_up(0.6, 0.6)
                            card_eval_status_text(kyra_card, 'extra', nil, nil, nil, { message = 'Kyra Summoned!', colour = G.C.GOLD })
                        end
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Back {
    name = 'Colosseum Deck',
    key = 'coliseo',
    atlas = 'reality_warp_decks',
    pos = { x = 1, y = 1 },
    config = { dollars = 100 },
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Colosseum Deck',
        text = {
            "Start run in {C:attention}Battle of Gods{} mode",
            "with {C:attention}24 Antes{} required to win,",
            "starts with {C:money}$100{}, {C:attention}Perishable Stencil & Blueprint{} (4 rounds),",
            "{C:attention}Taster{}, {C:attention}Critic{}, {C:attention}Planet Merchant{},",
            "{C:attention}Seed Money{}, and {C:attention}Money Tree{} vouchers,",
            "and all poker hands gain {C:attention}+3 levels{}"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.GAME.battle_of_gods = true
        G.GAME.coliseo_deck = true
        G.GAME.win_ante = 24
        if G.GAME.starting_params then
            G.GAME.starting_params.dollars = 100
        end
        G.GAME.dollars = 100
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.battle_of_gods = true
                G.GAME.coliseo_deck = true
                G.GAME.win_ante = 24
                if G.GAME.starting_params then
                    G.GAME.starting_params.dollars = 100
                end

                if G.GAME.round_resets and (not G.GAME.round_resets.ante or G.GAME.round_resets.ante == 1) then
                    local base_1 = 4000
                    if G.GAME.blind and not G.GAME.blind.disabled then
                        local b_type = G.GAME.blind.get_type and G.GAME.blind:get_type() or 'Small'
                        local mult = (b_type == 'Boss' and 2) or (b_type == 'Big' and 1.5) or 1
                        G.GAME.blind.chips = math.floor(base_1 * mult)
                        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    end
                end

                local cur_dollars = G.GAME.dollars or 4
                if cur_dollars ~= 100 then
                    ease_dollars(100 - cur_dollars)
                end

                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                local v_keys = {
                    'v_reality_warp_catador', 'v_Witch brew_catador', 'v_catador', 'catador',
                    'v_reality_warp_critico', 'v_Witch brew_critico', 'v_critico', 'critico',
                    'v_planet_merchant', 'planet_merchant', 'v_telescope',
                    'v_seed_money', 'seed_money', 'v_money_tree', 'money_tree'
                }
                for _, k in ipairs(v_keys) do
                    G.GAME.used_vouchers[k] = true
                end
                if G.P_CENTERS['v_reality_warp_catador'] and G.P_CENTERS['v_reality_warp_catador'].redeem then
                    pcall(function() G.P_CENTERS['v_reality_warp_catador']:redeem() end)
                end
                if G.P_CENTERS['v_reality_warp_critico'] and G.P_CENTERS['v_reality_warp_critico'].redeem then
                    pcall(function() G.P_CENTERS['v_reality_warp_critico']:redeem() end)
                end
                if G.P_CENTERS['v_seed_money'] and G.P_CENTERS['v_seed_money'].redeem then
                    pcall(function() G.P_CENTERS['v_seed_money']:redeem() end)
                end
                if G.P_CENTERS['v_money_tree'] and G.P_CENTERS['v_money_tree'].redeem then
                    pcall(function() G.P_CENTERS['v_money_tree']:redeem() end)
                end
                G.GAME.interest_cap = 100
                if G.GAME.planet_rate then
                    G.GAME.planet_rate = G.GAME.planet_rate * 2
                end

                if G.jokers then
                    local starter_keys = { 'j_stencil', 'j_blueprint' }
                    for _, s_key in ipairs(starter_keys) do
                        local s_card = create_card('Joker', G.jokers, nil, nil, nil, nil, s_key, 'coliseo_deck')
                        s_card:set_perishable(true)
                        s_card.ability.perish_tally = 4
                        s_card:add_to_deck()
                        G.jokers:emplace(s_card)
                    end
                end

                if G.GAME and G.GAME.hands then
                    for handname, _ in pairs(G.GAME.hands) do
                        level_up_hand(nil, handname, true, 3)
                    end
                end

                if apply_battle_of_gods_bg then
                    apply_battle_of_gods_bg()
                end

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.8,
                    blocking = false,
                    func = function()
                        if G.GAME and G.GAME.coliseo_deck and not G.GAME.charles_shop_offered and (not G.GAME.round_resets.ante or G.GAME.round_resets.ante == 1) then
                            G.GAME.charles_shop_offered = true
                            if prompt_charles_coliseo_choice then
                                prompt_charles_coliseo_choice()
                            end
                        end
                        return true
                    end
                }))

                return true
            end
        }))
    end,
    calculate = function(self, back, context)
    end
}

SMODS.Back {
    name = 'Dark Merchant Deck',
    key = 'dark_merchant',
    atlas = 'reality_warp_decks',
    pos = { x = 2, y = 1 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Dark Merchant Deck',
        text = {
            "Start run with {C:dark_edition}+$10{} Dark Money,",
            "Gain {C:dark_edition}+$5{} extra Dark Money",
            "when defeating a {C:attention}Boss Blind{},",
            "{C:attention}Black Market{} is guaranteed",
            "to appear in every shop"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.GAME.dark_merchant_deck = true
        G.GAME.black_market_available = true
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.dark_merchant_deck = true
                G.GAME.black_market_available = true
                ease_dark_coins(10)
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
    end
}

SMODS.Back {
    name = 'Witcher Deck',
    key = 'witcher',
    atlas = 'reality_warp_decks',
    pos = { x = 3, y = 1 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Witcher Deck',
        text = {
            "Start run with {C:attention}+1{} Consumable slot",
            "and {C:attention}2 random Potions{},",
            "Defeating a {C:attention}Boss Blind{} creates a random",
            "{C:attention}Potion{} or {C:spectral}Spectral Card{},",
            "{C:red}-1{} Hand size"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.GAME.witcher_deck = true
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.witcher_deck = true
                if G.consumeables and G.consumeables.config then
                    G.consumeables.config.card_limit = (G.consumeables.config.card_limit or 2) + 1
                end
                if G.GAME.starting_params then
                    G.GAME.starting_params.consumable_slots = (G.GAME.starting_params.consumable_slots or 2) + 1
                end

                G.GAME.round_resets.hand_size = math.max(1, (G.GAME.round_resets.hand_size or 8) - 1)
                if G.hand and G.hand.change_size then
                    G.hand:change_size(-1)
                end

                for i = 1, 2 do
                    if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        local p_card = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'witcher_deck'))
                            or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'witcher_deck')
                        if p_card then
                            p_card:add_to_deck()
                            G.consumeables:emplace(p_card)
                            p_card:juice_up(0.5, 0.5)
                        end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, back, context)
        if context.end_of_round and G.GAME and G.GAME.blind and G.GAME.blind.boss and not context.individual and not context.repetition then
            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local roll = pseudorandom('witcher_reward')
                        local reward_type = (roll < 0.5) and 'Potion' or 'Spectral'
                        local reward_card = (reward_type == 'Potion' and ((create_potion_card_safe and create_potion_card_safe(G.consumeables, 'witcher_boss')) or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'witcher_boss')))
                            or create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'witcher_boss')
                        if reward_card then
                            reward_card:add_to_deck()
                            G.consumeables:emplace(reward_card)
                            reward_card:juice_up(0.5, 0.5)
                            card_eval_status_text(reward_card, 'extra', nil, nil, nil, { message = 'Witcher Spoils!', colour = G.C.GOLD })
                        end
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Back {
    name = 'Contractor Deck',
    key = 'contractor',
    atlas = 'reality_warp_decks',
    pos = { x = 0, y = 2 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Contractor Deck',
        text = {
            "Start run with a {C:attention}Mega Job Application{} pack",
            "and the {C:attention}Hired Joker{}"
        }
    },
    apply = function(self, back)
        G.GAME.contractor_deck = true
        G.E_MANAGER:add_event(Event({
            func = function()
                local joker = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_reality_warp_hired_joker', 'contractor_deck')
                if joker then
                    joker:add_to_deck()
                    G.jokers:emplace(joker)
                    joker:juice_up(0.5, 0.5)
                end
                local tag_k = (G.P_TAGS and G.P_TAGS['tag_reality_warp_contratista'] and 'tag_reality_warp_contratista') or (G.P_TAGS and G.P_TAGS['tag_contratista'] and 'tag_contratista') or 'tag_reality_warp_contratista'
                add_tag(Tag(tag_k))
                return true
            end
        }))
    end
}

SMODS.Back {
    name = "Gambler's Deck",
    key = 'gambler',
    atlas = 'reality_warp_decks',
    pos = { x = 1, y = 2 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = "Gambler's Deck",
        text = {
            "All {C:green}probabilities{} are",
            "divided in {C:attention}half{}",
            "{C:inactive}(ex: {C:green}1 in 4{C:inactive} -> {C:green}1 in 2{C:inactive}){}"
        }
    },
    apply = function(self, back)
        G.GAME.gambler_deck = true
        if G.GAME.probabilities then
            for k, v in pairs(G.GAME.probabilities) do
                G.GAME.probabilities[k] = v * 2
            end
        else
            G.GAME.probabilities = { normal = 2 }
        end
    end
}

SMODS.Back {
    name = 'Academic Deck',
    key = 'academic',
    atlas = 'reality_warp_decks',
    pos = { x = 2, y = 2 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Academic Deck',
        text = {
            "All {C:attention}Face cards{} in your starting deck",
            "begin with a random {C:attention}Job Enhancement{}"
        }
    },
    apply = function(self, back)
        G.GAME.academic_deck = true
        G.E_MANAGER:add_event(Event({
            func = function()
                local job_enhancements = {
                    get_diamond_enhancement_center(),
                    get_sprout_enhancement_center(),
                    get_investment_enhancement_center(),
                    get_lead_enhancement_center(),
                    get_jeweled_enhancement_center(),
                    get_fossil_enhancement_center(),
                    get_tonic_enhancement_center(),
                    get_roulette_enhancement_center(),
                    get_geode_enhancement_center(),
                    get_oil_enhancement_center(),
                    get_clue_enhancement_center(),
                    get_bounty_enhancement_center()
                }
                if G.playing_cards then
                    for _, card in ipairs(G.playing_cards) do
                        if card:is_face() then
                            local chosen_center = pseudorandom_element(job_enhancements, pseudoseed('academic_job_enh'))
                            if chosen_center then
                                card:set_ability(chosen_center)
                            end
                        end
                    end
                end
                return true
            end
        }))
    end
}

SMODS.Back {
    name = 'Minigame Deck',
    key = 'minigames',
    atlas = 'reality_warp_decks',
    pos = { x = 3, y = 2 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Minigame Deck',
        text = {
            "Start run with a random {C:attention}Minigame Joker{}",
            "{C:inactive}(Pachinko, Ethernet, Shell Game, Claw Machine){},",
            "{C:red}-1{} Discard"
        }
    },
    apply = function(self, back)
        G.GAME.minigame_deck = true
        G.GAME.round_resets.discards = math.max(1, (G.GAME.round_resets.discards or 3) - 1)
        ease_discard(-1)
        G.E_MANAGER:add_event(Event({
            func = function()
                local minigame_keys = {
                    'j_reality_warp_pachinko',
                    'j_reality_warp_ethernet',
                    'j_reality_warp_shell_game',
                    'j_reality_warp_claw_machine'
                }
                local chosen = pseudorandom_element(minigame_keys, pseudoseed('minigame_deck'))
                local card = create_card('Joker', G.jokers, nil, nil, nil, nil, chosen, 'minigame_deck')
                if card then
                    card:add_to_deck()
                    G.jokers:emplace(card)
                    card:juice_up(0.5, 0.5)
                end
                return true
            end
        }))
    end
}

SMODS.Back {
    name = 'Deck of Wishes',
    key = 'wishes',
    atlas = 'reality_warp_decks',
    pos = { x = 0, y = 3 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Deck of Wishes',
        text = {
            "Gain a random {C:attention}Consumable{} at end of round,",
            "{C:attention}+1 Choice{} in all Booster Packs"
        }
    },
    apply = function(self, back)
        G.GAME.wishes_deck = true
        G.GAME.modifiers.booster_choice_mod = (G.GAME.modifiers.booster_choice_mod or 0) + 1
    end,
    calculate = function(self, back, context)
        if context.end_of_round and not context.individual and not context.repetition then
            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local pool = {'Tarot', 'Planet', 'Spectral', 'Potion'}
                        local c_type = pseudorandom_element(pool, pseudoseed('wishes_deck_cons'))
                        local card = (c_type == 'Potion' and ((create_potion_card_safe and create_potion_card_safe(G.consumeables, 'wishes_deck')) or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'wishes_deck')))
                            or create_card(c_type, G.consumeables, nil, nil, nil, nil, nil, 'wishes_deck')
                        if card then
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            card:juice_up(0.5, 0.5)
                            card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Wish Granted!', colour = G.C.PURPLE })
                        end
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Back {
    name = 'Bounty Hunter Deck',
    key = 'bounty_hunter',
    atlas = 'reality_warp_decks',
    pos = { x = 1, y = 3 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Bounty Hunter Deck',
        text = {
            "Defeating a {C:attention}Boss Blind{} awards a random",
            "{C:attention}Bounty{}: {C:money}Cash ($15){}, {C:tarot}Tarot{},",
            "{C:spectral}Spectral Card{}, or {C:attention}Tag{}"
        }
    },
    apply = function(self, back)
        G.GAME.bounty_hunter_deck = true
    end,
    calculate = function(self, back, context)
        if context.end_of_round and G.GAME and G.GAME.blind and G.GAME.blind.boss and not context.individual and not context.repetition then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local roll = pseudorandom('bounty_hunter_reward')
                    if roll < 0.3 then
                        ease_dollars(15)
                        card_eval_status_text(G.deck and G.deck.cards[1] or G.play, 'extra', nil, nil, nil, { message = 'Bounty: +$15!', colour = G.C.MONEY })
                    elseif roll < 0.6 then
                        if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                            local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'bounty_hunter')
                            if card then
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                card:juice_up(0.5, 0.5)
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Bounty Spectral!', colour = G.C.SECONDARY_SET.Spectral })
                            end
                        else
                            ease_dollars(15)
                        end
                    elseif roll < 0.85 then
                        if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                            local card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'bounty_hunter')
                            if card then
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                card:juice_up(0.5, 0.5)
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Bounty Tarot!', colour = G.C.SECONDARY_SET.Tarot })
                            end
                        else
                            ease_dollars(15)
                        end
                    else
                        local tag_pool = get_current_pool('Tag')
                        local tag_key = pseudorandom_element(tag_pool, pseudoseed('bounty_hunter_tag'))
                        add_tag(Tag(tag_key))
                        play_sound('generic1', 0.9 + 0.2*math.random(), 0.8)
                    end
                    return true
                end
            }))
        end
    end
}

SMODS.Back {
    name = 'Galactic Deck',
    key = 'galactica',
    atlas = 'reality_warp_decks',
    pos = { x = 2, y = 3 },
    config = {},
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Galactic Deck',
        text = {
            "Start run with a random",
            "{C:attention}Outsider{} or {C:purple}Amalgam{} Joker"
        }
    },
    loc_vars = function(self, info_queue, back)
        return { vars = {} }
    end,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            func = function()
                local pool = {}
                if G.P_CENTERS then
                    for k, v in pairs(G.P_CENTERS) do
                        if v.set == 'Joker' and (v.is_secret or v.is_amalgam) and k ~= 'j_reality_warp_mad_ghost' then
                            table.insert(pool, k)
                        end
                    end
                end
                if #pool == 0 then
                    pool = {
                        'j_reality_warp_esteban', 'j_reality_warp_thiago', 'j_reality_warp_black_hole_joker',
                        'j_reality_warp_squele', 'j_reality_warp_bluxdir', 'j_reality_warp_charles',
                        'j_reality_warp_mochi', 'j_reality_warp_helin', 'j_reality_warp_raytracing',
                        'j_reality_warp_paco', 'j_reality_warp_yairo', 'j_reality_warp_kyra',
                        'j_reality_warp_astra', 'j_reality_warp_mew_mew', 'j_reality_warp_brainprint',
                        'j_reality_warp_vampiric_midas', 'j_reality_warp_certified_programming',
                        'j_reality_warp_galactic_traveler', 'j_reality_warp_colorful_street'
                    }
                end
                local chosen = pseudorandom_element(pool, 'galactic_deck')
                if chosen then
                    SMODS.add_card({ key = chosen })
                end
                return true
            end
        }))
    end
}

function inject_reality_warp_deck_localization()
    if not (G.localization and G.localization.descriptions) then return end
    G.localization.descriptions.Back = G.localization.descriptions.Back or {}

    local deck_locs = {
        cavernicola = {
            name = "Caveman Deck",
            text = {
                "Start run with only {C:attention}A, 2, 3, 4, 6, 8{} of each suit,",
                "All other starting cards become {C:attention}Stone Cards{},",
                "{C:red}-1{} Hand"
            }
        },
        strategist = {
            name = "Strategist Deck",
            text = {
                "Start run with a {C:attention}24-card deck{} {C:inactive}(9 through Ace){},",
                "Start with {C:attention}Magic Trick{} voucher and {C:money}$0{},",
                "Blind score targets are {C:attention}X1.2{},",
                "{C:red}-1{} Hand, {C:red}-2{} Discards"
            }
        },
        overseer = {
            name = "Overseer Deck",
            text = {
                "Creates a random {C:spectral}Spectral card{} at end of round",
                "{C:inactive}(except Rot, Soul and Secrets){},",
                "{C:attention}Tags are always doubled{},",
                "Joker prices are {C:red}X1.5{},",
                "Start with {C:money}$5{}, {C:red}-1{} Hand, {C:red}-1{} Discard"
            }
        },
        friendly = {
            name = "Friendly Deck",
            text = {
                "Start run with {C:attention}2{} random {C:dark_edition}Negative{} {C:attention}Eternal Jokers{},",
                "{C:inactive}(At least 1 Uncommon or Rare, no Secrets/Legendaries){},",
                "{C:red}-1{} Joker Slot, {C:red}-1{} Discard, {C:money}+$4{}"
            }
        },
        alchemist = {
            name = "Alchemist Deck",
            text = {
                "Start run with the voucher",
                "{C:attention,T:v_reality_warp_destilacion_recurrente}Recurring Distillation{}"
            }
        },
        coliseo = {
            name = "Colosseum Deck",
            text = {
                "Start run in {C:attention}Battle of Gods{} mode",
                "with {C:attention}24 Antes{} required to win,",
                "starts with {C:money}$100{}, {C:attention}2 Perishable Stencils{} (2 rounds),",
                "{C:attention}Taster{}, {C:attention}Critic{}, {C:attention}Planet Merchant{},",
                "{C:attention}Seed Money{}, and {C:attention}Money Tree{} vouchers,",
                "and all poker hands gain {C:attention}+3 levels{}"
            }
        },
        dark_merchant = {
            name = "Dark Merchant Deck",
            text = {
                "Start run with {C:dark_edition}+$10{} Dark Money,",
                "Gain {C:dark_edition}+$5{} extra Dark Money",
                "when defeating a {C:attention}Boss Blind{},",
                "{C:attention}Black Market{} is guaranteed",
                "to appear in every shop"
            }
        },
        witcher = {
            name = "Witcher Deck",
            text = {
                "Start run with {C:attention}+1{} Consumable slot",
                "and {C:attention}2 random Potions{},",
                "Defeating a {C:attention}Boss Blind{} creates a random",
                "{C:attention}Potion{} or {C:spectral}Spectral Card{},",
                "{C:red}-1{} Hand size"
            }
        },
        contractor = {
            name = "Contractor Deck",
            text = {
                "Start run with a {C:attention}Mega Job Application{} pack",
                "and the {C:attention}Hired Joker{}"
            }
        },
        contratista = {
            name = "Contractor Deck",
            text = {
                "Start run with a {C:attention}Mega Job Application{} pack",
                "and the {C:attention}Hired Joker{}"
            }
        },
        gambler = {
            name = "Gambler's Deck",
            text = {
                "All {C:green}probabilities{} are",
                "divided in {C:attention}half{}",
                "{C:inactive}(ex: {C:green}1 in 4{C:inactive} -> {C:green}1 in 2{C:inactive}){}"
            }
        },
        apostador = {
            name = "Gambler's Deck",
            text = {
                "All {C:green}probabilities{} are",
                "divided in {C:attention}half{}",
                "{C:inactive}(ex: {C:green}1 in 4{C:inactive} -> {C:green}1 in 2{C:inactive}){}"
            }
        },
        academic = {
            name = "Academic Deck",
            text = {
                "All {C:attention}Face cards{} in your starting deck",
                "begin with a random {C:attention}Job Enhancement{}"
            }
        },
        academica = {
            name = "Academic Deck",
            text = {
                "All {C:attention}Face cards{} in your starting deck",
                "begin with a random {C:attention}Job Enhancement{}"
            }
        },
        minigames = {
            name = "Minigame Deck",
            text = {
                "Start run with a random {C:attention}Minigame Joker{}",
                "{C:inactive}(Pachinko, Ethernet, Shell Game, Claw Machine){},",
                "{C:red}-1{} Discard"
            }
        },
        minijuegos = {
            name = "Minigame Deck",
            text = {
                "Start run with a random {C:attention}Minigame Joker{}",
                "{C:inactive}(Pachinko, Ethernet, Shell Game, Claw Machine){},",
                "{C:red}-1{} Discard"
            }
        },
        wishes = {
            name = "Deck of Wishes",
            text = {
                "Gain a random {C:attention}Consumable{} at end of round,",
                "{C:attention}+1 Choice{} in all Booster Packs"
            }
        },
        deseos = {
            name = "Deck of Wishes",
            text = {
                "Gain a random {C:attention}Consumable{} at end of round,",
                "{C:attention}+1 Choice{} in all Booster Packs"
            }
        },
        bounty_hunter = {
            name = "Bounty Hunter Deck",
            text = {
                "Defeating a {C:attention}Boss Blind{} awards a random",
                "{C:attention}Bounty{}: {C:money}Cash ($15){}, {C:tarot}Tarot{},",
                "{C:spectral}Spectral Card{}, or {C:attention}Tag{}"
            }
        },
        cazarecompensas = {
            name = "Bounty Hunter Deck",
            text = {
                "Defeating a {C:attention}Boss Blind{} awards a random",
                "{C:attention}Bounty{}: {C:money}Cash ($15){}, {C:tarot}Tarot{},",
                "{C:spectral}Spectral Card{}, or {C:attention}Tag{}"
            }
        },
        galactic = {
            name = "Galactic Deck",
            text = {
                "Start run with a random",
                "{C:attention}Outsider{} or {C:purple}Amalgam{} Joker"
            }
        },
        galactica = {
            name = "Galactic Deck",
            text = {
                "Start run with a random",
                "{C:attention}Outsider{} or {C:purple}Amalgam{} Joker"
            }
        }
    }

    if reality_warp_DECK_LOCS then
        for k, v in pairs(reality_warp_DECK_LOCS) do
            if not deck_locs[k] then
                deck_locs[k] = v
            end
        end
    end

    if SMODS and SMODS.Back and SMODS.Back.obj_table then
        for k, obj in pairs(SMODS.Back.obj_table) do
            local clean_k = tostring(obj.key or k):gsub('^b_reality_warp_', ''):gsub('^b_', ''):gsub('^reality_warp_', '')
            if obj.loc_txt and not deck_locs[clean_k] then
                deck_locs[clean_k] = {
                    name = obj.loc_txt.name or obj.name,
                    text = obj.loc_txt.text
                }
            end
        end
    end

    for key, data in pairs(deck_locs) do
        local keys_to_set = {
            "b_" .. key,
            "b_reality_warp_" .. key,
            key,
            "reality_warp_" .. key
        }
        for _, k in ipairs(keys_to_set) do
            local entry = G.localization.descriptions.Back[k] or {}
            entry.name = data.name
            entry.text = copy_table(data.text)
            reparse_deck_entry(entry)
            G.localization.descriptions.Back[k] = entry
        end
    end

    for _, b_entry in pairs(G.localization.descriptions.Back) do
        if type(b_entry) == 'table' then
            reparse_deck_entry(b_entry)
        end
    end

    setmetatable(G.localization.descriptions.Back, nil)
end

inject_reality_warp_deck_localization()

local orig_init_loc_decks = init_localization
function init_localization()
    if orig_init_loc_decks then orig_init_loc_decks() end
    inject_reality_warp_deck_localization()
end

if Back then
    if Back.init then
        local orig_back_init = Back.init
        function Back:init(selected_back)
            orig_back_init(self, selected_back)
            if self.effect and not self.effect.config then
                self.effect.config = {}
            end
        end
    end
    if Back.generate_UI then
        local orig_back_generate_ui = Back.generate_UI
        function Back:generate_UI(other, ui_scale, min_dims, challenge)
            if other and not other.config then
                other.config = {}
            end
            if self and self.effect and not self.effect.config then
                self.effect.config = {}
            end
            local ui = orig_back_generate_ui(self, other, ui_scale, min_dims, challenge)
            local name_to_check = other and other.name or self.name
            if ui and ui.nodes and name_to_check ~= 'Challenge Deck' then
                local rows = 0
                local function scan_rows(node)
                    if not node or type(node) ~= 'table' then return end
                    if node.n == G.UIT.R and node.nodes then
                        for _, c in ipairs(node.nodes) do
                            if c.n == G.UIT.T or (c.n == G.UIT.O and c.config and c.config.object) then
                                rows = rows + 1
                                return
                            end
                        end
                    end
                    if node.nodes then
                        for _, c in ipairs(node.nodes) do scan_rows(c) end
                    end
                end
                scan_rows(ui)

                local mult = (rows <= 1 and 1.30)
                    or (rows <= 2 and 1.25)
                    or (rows <= 3 and 1.20)
                    or 1.15

                local function enlarge(node)
                    if not node or type(node) ~= 'table' then return end
                    if node.config and node.config.scale then
                        node.config.scale = node.config.scale * mult
                    end
                    if node.config and node.config.object and node.config.object.scale then
                        node.config.object.scale = node.config.object.scale * mult
                        if node.config.object.update_text then
                            node.config.object:update_text(true)
                        end
                    end
                    if node.nodes then
                        for _, c in ipairs(node.nodes) do enlarge(c) end
                    end
                end
                enlarge(ui)
            end
            return ui
        end
    end
end

if Back and not G.reality_warp_back_trigger_hooked then
    G.reality_warp_back_trigger_hooked = true
    local orig_trigger_effect = Back.trigger_effect
    function Back:trigger_effect(args)
        local ret1, ret2 = nil, nil
        if orig_trigger_effect then
            ret1, ret2 = orig_trigger_effect(self, args)
        end
        local current_key = self.effect and self.effect.center and self.effect.center.key
        if current_key and reality_warp_DECK_HOOKS then
            local clean_k = tostring(current_key):gsub('^b_reality_warp_', ''):gsub('^b_', ''):gsub('^reality_warp_', '')
            local hooks = reality_warp_DECK_HOOKS[clean_k] or reality_warp_DECK_HOOKS[current_key]
            if hooks then
                for _, fn in ipairs(hooks) do
                    local h1, h2 = fn(self, args)
                    if h1 ~= nil then ret1 = h1 end
                    if h2 ~= nil then ret2 = h2 end
                end
            end
        end
        return ret1 or (args and args.chips), ret2 or (args and args.mult)
    end
end


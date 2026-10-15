
SMODS.Atlas {
    key = "reality_warp_sleeves",
    path = "sleeves.png",
    px = 73,
    py = 95
}
local function reparse_sleeve_entry(entry)
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

local function is_deck_matching(target_key)
    if not target_key then return false end
    local ok, res = pcall(function()
        if CardSleeves and CardSleeves.Sleeve and CardSleeves.Sleeve.get_current_deck_key then
            local current = CardSleeves.Sleeve.get_current_deck_key() or ""
            current = tostring(current)
            if current == target_key
                or current == "b_" .. target_key
                or current == "b_reality_warp_" .. target_key
                or string.find(current, target_key, 1, true) ~= nil then
                return true
            end
        end
        if CardSleeves and CardSleeves.current_deck then
            local current = tostring(CardSleeves.current_deck)
            if string.find(current, target_key, 1, true) ~= nil then
                return true
            end
        end
        if G and G.GAME then
            local b = G.GAME.selected_back or G.GAME.viewed_back
            if b then
                local k = b.name or (b.effect and b.effect.center and b.effect.center.key) or b.key or ""
                k = tostring(k)
                if k == target_key or string.find(k, target_key, 1, true) ~= nil then
                    return true
                end
            end
        end
        if G and G.deck and G.deck.name then
            local d = tostring(G.deck.name)
            if string.find(d, target_key, 1, true) ~= nil then
                return true
            end
        end
        return false
    end)
    return ok and res or false
end

local function inject_sleeve_localization()
    if not (G.localization and G.localization.descriptions) then return end
    G.localization.descriptions.Sleeve = G.localization.descriptions.Sleeve or {}

    local sleeve_locs = {
        friendly = {
            name = "Friendly Sleeve",
            text = {
                "Start run with {C:attention}1{} random {C:dark_edition}Negative{} {C:attention}Eternal Joker{},",
                "{C:inactive}(Any rarity, no Secret or sell/destroy Jokers){},",
                "{C:red}-1{} Discard"
            }
        },
        friendly_alt = {
            name = "Friendly Sleeve (Fusion)",
            text = {
                "{C:attention}Friendly Fusion{}:",
                "Spawns {C:attention}3{} {C:dark_edition}Negative{} {C:attention}Eternal Jokers{},",
                "{C:inactive}(Any rarity, chance of Legendary or Secret){},",
                "{C:red}-2{} Joker Slots, {C:red}-1{} Discard"
            }
        },

        cavernicola = {
            name = "Caveman Sleeve",
            text = {
                "All starting {C:attention}Face Cards{} {C:inactive}(J, Q, K){}",
                "become {C:attention}Stone Cards{},",
                "{C:blue}+1{} Hand"
            }
        },
        cavernicola_alt = {
            name = "Caveman Sleeve (Fusion)",
            text = {
                "{C:attention}Prehistoric Fusion{}:",
                "Start with only {C:attention}Aces, 2s, and 3s{} (4 of each),",
                "All other starting cards become {C:attention}Stone Cards{},",
                "Stone Cards give {C:mult}+1{} Mult when scored,",
                "{C:blue}+1{} Hand"
            }
        },

        strategist = {
            name = "Strategist Sleeve",
            text = {
                "Start with {C:attention}Magic Trick{} voucher,",
                "Start with {C:money}$5{},",
                "{C:red}-1{} Discard"
            }
        },
        strategist_alt = {
            name = "Strategist Sleeve (Fusion)",
            text = {
                "{C:attention}Grandmaster Fusion{}:",
                "Deck reduced to {C:attention}20 cards{} {C:inactive}(10 through Ace){},",
                "Start with {C:attention}Magic Trick{} and {C:attention}Tarot Merchant{},",
                "{C:attention}+1{} Shop card slot, played hands give {C:money}+$1{}"
            }
        },

        overseer = {
            name = "Overseer Sleeve",
            text = {
                "{C:attention}Tags are always doubled{},",
                "Defeating Boss Blind creates random {C:spectral}Spectral card{}"
            }
        },
        overseer_alt = {
            name = "Overseer Sleeve (Fusion)",
            text = {
                "{C:attention}Omniscient Fusion{}:",
                "Creates {C:attention}2{} random {C:spectral}Spectral cards{} at end of round,",
                "Tags are {C:attention}tripled (X3){},",
                "No Joker price markup penalty, start with {C:money}$7{} and {C:blue}+1{} Hand"
            }
        },
        alchemist = {
            name = "Alchemist Sleeve",
            text = {
                "Creates {C:attention}1 random Potion{}",
                "at start of each round",
                "{C:inactive}(Must have consumable space){}"
            }
        },
        alchemist_alt = {
            name = "Alchemist Sleeve (Fusion)",
            text = {
                "{C:attention}Alchemical Fusion{}:",
                "At start of run, summons",
                "{C:attention}Kyra{} {C:dark_edition}(Eternal){},",
                "and grants {C:attention}Recurring Distillation{} voucher each round",
                "{C:inactive}(Potions take 0 consumable slots){}"
            }
        }
    }

    for key, data in pairs(sleeve_locs) do
        local keys_to_set = {
            "sleeve_" .. key,
            "sleeve_reality_warp_" .. key,
            key,
            "reality_warp_" .. key
        }
        for _, k in ipairs(keys_to_set) do
            local entry = G.localization.descriptions.Sleeve[k] or {}
            entry.name = data.name
            entry.text = copy_table(data.text)
            reparse_sleeve_entry(entry)
            G.localization.descriptions.Sleeve[k] = entry
        end
    end

    for _, s_entry in pairs(G.localization.descriptions.Sleeve) do
        if type(s_entry) == 'table' then
            reparse_sleeve_entry(s_entry)
        end
    end

    setmetatable(G.localization.descriptions.Sleeve, nil)
end

local registered_sleeves = false
function register_reality_warp_sleeves()
    if registered_sleeves then return end
    if not (CardSleeves and CardSleeves.Sleeve) then return end
    registered_sleeves = true

    local mod_obj = (get_reality_warp_mod and get_reality_warp_mod())
        or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'])
        or reality_warp_MOD
        or SMODS.current_mod
    local prev_current_mod = SMODS.current_mod
    if mod_obj then
        SMODS.current_mod = mod_obj
    end

    inject_sleeve_localization()

    CardSleeves.Sleeve {
        key = "friendly",
        name = "Friendly Sleeve",
        atlas = "reality_warp_sleeves",
        pos = { x = 3, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Friendly Sleeve",
            text = {
                "Start run with {C:attention}1 random Negative Eternal Joker{},",
                "{C:inactive}(Except Legendary or Secret){},",
                "{C:red}-1{} Discard"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("friendly")
            local raw_k = (self.original_key or self.key or "friendly")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_reality_warp_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_reality_warp_" .. base_key .. "_alt") or ("sleeve_reality_warp_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.friendly_sleeve_selected = true
            local is_combo = is_deck_matching("friendly")
            if is_combo then
                G.GAME.friendly_sleeve_combo = true
            else
                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        play_sound('foil1')
                        local new_joker = nil
                        local attempts = 0
                        repeat
                            attempts = attempts + 1
                            local rarity_roll = pseudorandom('friendly_sleeve_rarity_' .. attempts)
                            local rarity_float = (rarity_roll > 0.95 and 0.99) or (rarity_roll > 0.70 and 0.8) or 0.5
                            new_joker = create_card('Joker', G.jokers, false, rarity_float, nil, false, nil, 'friendly_sleeve')
                            if new_joker and is_invalid_eternal_joker(new_joker) then
                                if new_joker.area then new_joker.area:remove_card(new_joker) end
                                new_joker:remove()
                                new_joker = nil
                            end
                        until new_joker or attempts >= 20
                        if not new_joker then
                            new_joker = create_card('Joker', G.jokers, false, 0.5, nil, false, nil, 'friendly_sleeve_fallback')
                        end
                        new_joker:set_eternal(true)
                        if new_joker.ability then new_joker.ability.eternal = true end
                        new_joker:set_edition({ negative = true }, true)
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        new_joker:juice_up(0.5, 0.5)
                        return true
                    end
                }))
            end
        end
    }

    CardSleeves.Sleeve {
        key = "cavernicola",
        name = "Caveman Sleeve",
        atlas = "reality_warp_sleeves",
        pos = { x = 0, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Caveman Sleeve",
            text = {
                "All starting {C:attention}Face Cards{} (J, Q, K)",
                "become {C:attention}Stone Cards{},",
                "{C:blue}+1{} Hand"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("cavernicola")
            local raw_k = (self.original_key or self.key or "cavernicola")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_reality_warp_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_reality_warp_" .. base_key .. "_alt") or ("sleeve_reality_warp_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.cavernicola_sleeve_selected = true
            local is_combo = is_deck_matching("cavernicola")
            if is_combo then
                G.GAME.cavernicola_sleeve_combo = true
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                ease_hands_played(1)
            else
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                ease_hands_played(1)

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if G.playing_cards then
                            for _, card in ipairs(G.playing_cards) do
                                if card:is_face() then
                                    card:set_ability(G.P_CENTERS.m_stone)
                                    card:juice_up(0.2, 0.2)
                                end
                            end
                        end
                        return true
                    end
                }))
            end
        end,
        calculate = function(self, sleeve, context)
            if G.GAME and G.GAME.cavernicola_sleeve_combo then
                if context.cardarea == G.play and context.individual and context.other_card then
                    if context.other_card.ability and (context.other_card.ability.name == 'Stone Card' or context.other_card.ability.effect == 'Stone Card') then
                        return {
                            mult = 1,
                            card = context.other_card
                        }
                    end
                end
            end
        end
    }

    CardSleeves.Sleeve {
        key = "strategist",
        name = "Strategist Sleeve",
        atlas = "reality_warp_sleeves",
        pos = { x = 1, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Strategist Sleeve",
            text = {
                "Start with {C:attention}Magic Trick{} voucher,",
                "Start with {C:money}$5{}, {C:red}-1{} Discard"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("strategist")
            local raw_k = (self.original_key or self.key or "strategist")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_reality_warp_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_reality_warp_" .. base_key .. "_alt") or ("sleeve_reality_warp_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.strategist_sleeve_selected = true
            local is_combo = is_deck_matching("strategist")
            if is_combo then
                G.GAME.strategist_sleeve_combo = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        if G.playing_cards then
                            for i = #G.playing_cards, 1, -1 do
                                local card = G.playing_cards[i]
                                local val = card.base and card.base.value
                                if val == '9' then
                                    if card.area then card.area:remove_card(card) end
                                    card:remove()
                                    table.remove(G.playing_cards, i)
                                end
                            end
                        end
                        return true
                    end
                }))

                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers['v_tarot_merchant'] = true

                if G.GAME.shop then
                    G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
                end

                G.GAME.modifiers = G.GAME.modifiers or {}
                G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 0) + 1
            else
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers['v_magic_trick'] = true
                ease_dollars(5)
                G.GAME.round_resets.discards = math.max(0, G.GAME.round_resets.discards - 1)
                ease_discard(-1)
            end
        end
    }

    CardSleeves.Sleeve {
        key = "overseer",
        name = "Overseer Sleeve",
        atlas = "reality_warp_sleeves",
        pos = { x = 2, y = 0 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Overseer Sleeve",
            text = {
                "{C:attention}Tags are always doubled{},",
                "Defeating a Boss Blind creates a random {C:spectral}Spectral card{}"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("overseer")
            local raw_k = (self.original_key or self.key or "overseer")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_reality_warp_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_reality_warp_" .. base_key .. "_alt") or ("sleeve_reality_warp_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.overseer_sleeve_selected = true
            local is_combo = is_deck_matching("overseer")
            if is_combo then
                G.GAME.overseer_sleeve_combo = true
                G.GAME.overseer_no_markup = true
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
                ease_hands_played(1)
                ease_dollars(5)
            else
                G.GAME.overseer_sleeve_active = true
            end
        end,
        calculate = function(self, sleeve, context)
            local is_combo = G.GAME and G.GAME.overseer_sleeve_combo
            if is_combo then
                if context.end_of_round and not context.individual and not context.repetition then
                    for i = 1, 2 do
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
                                    local chosen_key = (#valid_spectrals > 0) and pseudorandom_element(valid_spectrals, pseudoseed('overseer_sleeve_combo_' .. i)) or 'c_ankh'
                                    local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_key, 'overseer_combo')
                                    scard:add_to_deck()
                                    G.consumeables:emplace(scard)
                                    scard:juice_up(0.5, 0.5)
                                    return true
                                end
                            }))
                        end
                    end
                end
            else
                if context.end_of_round and G.GAME and G.GAME.blind and G.GAME.blind.boss and not context.individual and not context.repetition then
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
                                local chosen_key = (#valid_spectrals > 0) and pseudorandom_element(valid_spectrals, pseudoseed('overseer_sleeve_boss')) or 'c_ankh'
                                local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, chosen_key, 'overseer_boss')
                                scard:add_to_deck()
                                G.consumeables:emplace(scard)
                                scard:juice_up(0.5, 0.5)
                                return true
                            end
                        }))
                    end
                end
            end
        end
    }

    CardSleeves.Sleeve {
        key = "alchemist",
        name = "Alchemist Sleeve",
        atlas = "reality_warp_sleeves",
        pos = { x = 0, y = 1 },
        config = {},
        unlocked = true,
        discovered = true,
        loc_txt = {
            name = "Alchemist Sleeve",
            text = {
                "Creates {C:attention}1 random Potion{}",
                "at start of each round",
                "{C:inactive}(Must have consumable space){}"
            }
        },
        loc_vars = function(self, info_queue, card)
            local is_combo = is_deck_matching("alchemist")
            local raw_k = (self.original_key or self.key or "alchemist")
            local base_key = string.gsub(string.gsub(raw_k, "^sleeve_reality_warp_", ""), "^sleeve_", "")
            base_key = string.gsub(base_key, "_alt$", "")
            local key = is_combo and ("sleeve_reality_warp_" .. base_key .. "_alt") or ("sleeve_reality_warp_" .. base_key)
            return { key = key, vars = {} }
        end,
        apply = function(self, sleeve)
            G.GAME.alchemist_sleeve_selected = true
            local is_combo = is_deck_matching("alchemist")
            if is_combo then
                G.GAME.alchemist_sleeve_combo = true
                G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                G.GAME.used_vouchers.v_reality_warp_destilacion_recurrente = true
                G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true
                G.GAME.used_vouchers.v_destilacion_recurrente = true
                G.GAME.used_vouchers.destilacion_recurrente = true

                G.E_MANAGER:add_event(Event({
                    func = function()
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
                        return true
                    end
                }))
            else
                G.GAME.alchemist_sleeve_active = true
            end
        end,
        calculate = function(self, sleeve, context)
            local is_combo = G.GAME and G.GAME.alchemist_sleeve_combo
            if is_combo then
                if (context.first_hand_drawn or context.setting_blind) and not context.blueprint and not context.individual and not context.repetition then
                    G.GAME.used_vouchers = G.GAME.used_vouchers or {}
                    G.GAME.used_vouchers.v_reality_warp_destilacion_recurrente = true
                    G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true

                    if not G.GAME.alchemist_fusion_kyra_given and G.jokers then
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
            else
                if context.first_hand_drawn and not context.blueprint and not context.individual and not context.repetition then
                    local can_spawn = G.consumeables and (#G.consumeables.cards < G.consumeables.config.card_limit or (G.jokers and next(find_joker('Kyra'))))
                    if can_spawn then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'alchemist_sleeve'))
                                    or create_card('Potion', G.consumeables, nil, nil, nil, nil, nil, 'alchemist_sleeve')
                                if new_potion then
                                    new_potion:add_to_deck()
                                    G.consumeables:emplace(new_potion)
                                    new_potion:juice_up(0.5, 0.5)
                                    card_eval_status_text(new_potion, 'extra', nil, nil, nil, { message = '+1 Potion!', colour = G.C.SECONDARY_SET.Enhanced })
                                end
                                return true
                            end
                        }))
                    end
                end
            end
        end
    }

    SMODS.current_mod = prev_current_mod
    inject_sleeve_localization()
end

if CardSleeves and CardSleeves.Sleeve then
    register_reality_warp_sleeves()
end

local orig_init_loc_sleeves = init_localization
function init_localization()
    if orig_init_loc_sleeves then orig_init_loc_sleeves() end
    if CardSleeves and CardSleeves.Sleeve then
        register_reality_warp_sleeves()
    end
    inject_sleeve_localization()
end

local orig_game_delete_run = Game.delete_run
function Game:delete_run(...)
    if G.GAME and G.GAME.selected_sleeve and G.GAME.selected_sleeve ~= "sleeve_casl_none" and G.GAME.selected_sleeve ~= "" then
        G._last_selected_sleeve = G.GAME.selected_sleeve
        G.viewed_sleeve = G.GAME.selected_sleeve
        if G.PROFILES and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].MEMORY then
            G.PROFILES[G.SETTINGS.profile].MEMORY.sleeve = G.GAME.selected_sleeve
        end
    end
    return orig_game_delete_run(self, ...)
end

local orig_game_start_run = Game.start_run
function Game:start_run(args)
    args = args or {}
    if CardSleeves and CardSleeves.Sleeve then
        if not registered_sleeves then
            register_reality_warp_sleeves()
        end
        if not args.casl_sleeve_choice then
            local prev_sleeve = G._last_selected_sleeve
                or G.viewed_sleeve
                or (G.PROFILES and G.PROFILES[G.SETTINGS.profile] and (
                    (G.PROFILES[G.SETTINGS.profile].last_choices and G.PROFILES[G.SETTINGS.profile].last_choices.casl_sleeve_choice)
                    or (G.PROFILES and G.PROFILES[G.SETTINGS.profile].MEMORY and G.PROFILES[G.SETTINGS.profile].MEMORY.sleeve)
                ))
            if prev_sleeve and prev_sleeve ~= "sleeve_casl_none" and prev_sleeve ~= "" then
                args.casl_sleeve_choice = prev_sleeve
                G.viewed_sleeve = prev_sleeve
            end
        end
    end
    inject_sleeve_localization()
    return orig_game_start_run(self, args)
end

if Card and Card.hover then
    local orig_card_hover = Card.hover
    function Card:hover()
        if G.localization and G.localization.descriptions and G.localization.descriptions.Sleeve then
            for _, s_entry in pairs(G.localization.descriptions.Sleeve) do
                if type(s_entry) == 'table' and (not s_entry.text_parsed or not next(s_entry.text_parsed)) then
                    reparse_sleeve_entry(s_entry)
                end
            end
        end
        return orig_card_hover(self)
    end
end

-- ----------------------------------------------------------------------------
-- CardSleeves trigger_effect nil safety guard
-- ----------------------------------------------------------------------------

if CardSleeves and CardSleeves.Sleeve then
    CardSleeves.Sleeve.trigger_effect = CardSleeves.Sleeve.trigger_effect or function(self, args) end
    if CardSleeves.Sleeve.obj_table then
        for _, s in pairs(CardSleeves.Sleeve.obj_table) do
            if type(s) == 'table' and not s.trigger_effect then
                s.trigger_effect = function(self, args) end
            end
        end
    end
end

if Card and Card.set_base then
    local orig_card_set_base = Card.set_base
    function Card:set_base(card, initial)
        if CardSleeves and CardSleeves.Sleeve then
            if not CardSleeves.Sleeve.trigger_effect then
                CardSleeves.Sleeve.trigger_effect = function(self, args) end
            end
            if CardSleeves.Sleeve.obj_table then
                for _, s in pairs(CardSleeves.Sleeve.obj_table) do
                    if type(s) == 'table' and not s.trigger_effect then
                        s.trigger_effect = function(self, args) end
                    end
                end
            end
        end
        if G and G.P_CENTERS then
            for _, c in pairs(G.P_CENTERS) do
                if type(c) == 'table' and (c.set == 'Sleeve' or c.original_key) and not c.trigger_effect then
                    c.trigger_effect = function(self, args) end
                end
            end
        end
        if G and G.P_CENTER_POOLS and G.P_CENTER_POOLS['Sleeve'] then
            for _, c in ipairs(G.P_CENTER_POOLS['Sleeve']) do
                if type(c) == 'table' and not c.trigger_effect then
                    c.trigger_effect = function(self, args) end
                end
            end
        end
        if G and G.GAME and G.GAME.selected_sleeve and type(G.GAME.selected_sleeve) == 'table' and not G.GAME.selected_sleeve.trigger_effect then
            G.GAME.selected_sleeve.trigger_effect = function(self, args) end
        end
        return orig_card_set_base(self, card, initial)
    end
end


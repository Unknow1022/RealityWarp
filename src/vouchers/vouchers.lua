SMODS.Atlas {
    key = "reality_warp_vouchers",
    path = "vouchers.png",
    px = 71,
    py = 95
}
SMODS.Voucher {
    key = 'catador',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 0 },
    cost = 10,
    loc_txt = {
        name = 'Taster',
        text = {
            "{C:common}Common Jokers{} appear",
            "{C:attention}less frequently{} in shop",
            "{C:inactive,s:0.8}(Art by le_ginger_){}"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_catador = true
        G.GAME.used_vouchers['v_Witch brew_catador'] = true
        G.GAME.used_vouchers.v_catador = true
        G.GAME.used_vouchers.catador = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_catador = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_catador'] = false
        end
    end
}

SMODS.Voucher {
    key = 'critico',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_catador' },
    pos = { x = 1, y = 0 },
    cost = 10,
    loc_txt = {
        name = 'Critic',
        text = {
            "{C:common}Common Jokers{} no longer",
            "appear in shop",
            "{C:inactive,s:0.8}(Art by le_ginger_){}"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_critico = true
        G.GAME.used_vouchers['v_Witch brew_critico'] = true
        G.GAME.used_vouchers.v_critico = true
        G.GAME.used_vouchers.critico = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_critico = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_critico'] = false
        end
    end
}

SMODS.Voucher {
    key = 'embrujo',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 1 },
    cost = 10,
    loc_txt = {
        name = 'Embrujo',
        text = {
            "{C:attention}Potions{} appear {C:attention}2X{}",
            "more frequently in shop"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_embrujo = true
        G.GAME.used_vouchers['v_Witch brew_embrujo'] = true
        G.GAME.used_vouchers.v_embrujo = true
        G.GAME.used_vouchers.embrujo = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_embrujo = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_embrujo'] = false
        end
    end
}

SMODS.Voucher {
    key = 'caldero',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_embrujo' },
    pos = { x = 1, y = 1 },
    cost = 10,
    loc_txt = {
        name = 'Caldero',
        text = {
            "{C:attention}Potions{} appear {C:attention}4X{}",
            "more frequently in shop"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_caldero = true
        G.GAME.used_vouchers['v_Witch brew_caldero'] = true
        G.GAME.used_vouchers.v_caldero = true
        G.GAME.used_vouchers.caldero = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_caldero = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_caldero'] = false
        end
    end
}

SMODS.Voucher {
    key = 'destilacion_recurrente',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 2 },
    cost = 10,
    loc_txt = {
        name = 'Recurring Distillation',
        text = {
            "{C:attention}15% chance{} for any used",
            "{C:attention}consumable{} to be recreated"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_destilacion_recurrente = true
        G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] = true
        G.GAME.used_vouchers.v_destilacion_recurrente = true
        G.GAME.used_vouchers.destilacion_recurrente = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_destilacion_recurrente = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_destilacion_recurrente'] = false
        end
    end
}

SMODS.Voucher {
    key = 'destilacion_infinita',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_destilacion_recurrente' },
    pos = { x = 1, y = 2 },
    cost = 10,
    loc_txt = {
        name = 'Infinite Distillation',
        text = {
            "{C:attention}45% chance{} for any used",
            "{C:attention}consumable{} to be recreated"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_destilacion_infinita = true
        G.GAME.used_vouchers['v_Witch brew_destilacion_infinita'] = true
        G.GAME.used_vouchers.v_destilacion_infinita = true
        G.GAME.used_vouchers.destilacion_infinita = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_destilacion_infinita = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_destilacion_infinita'] = false
        end
    end
}

if Card and Card.use_consumeable then
    local orig_use_consumeable_vouchers = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local voucher_chance = 0
        if G.GAME and G.GAME.used_vouchers then
            if G.GAME.used_vouchers.v_reality_warp_destilacion_infinita or G.GAME.used_vouchers['v_Witch brew_destilacion_infinita'] or G.GAME.used_vouchers.v_destilacion_infinita or G.GAME.used_vouchers.destilacion_infinita then
                voucher_chance = 45
            elseif G.GAME.used_vouchers.v_reality_warp_destilacion_recurrente or G.GAME.used_vouchers['v_Witch brew_destilacion_recurrente'] or G.GAME.used_vouchers.v_destilacion_recurrente or G.GAME.used_vouchers.destilacion_recurrente then
                voucher_chance = 15
            end
        end

        local will_recreate = false
        local saved_set = (self.ability and self.ability.set) or 'Tarot'
        local saved_key = (self.config and self.config.center and self.config.center.key) or (self.ability and self.ability.name)

        if voucher_chance > 0 and not copier and saved_key and saved_key ~= '' then
            if pseudorandom('destilacion_voucher') < (voucher_chance / 100) then
                will_recreate = true
            end
        end

        local ret = orig_use_consumeable_vouchers(self, area, copier)

        if will_recreate then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                        play_sound('tarot2', 1.4, 0.85)
                        play_sound('gold_seal', 1.3, 0.9)
                        local new_card = create_card(saved_set, G.consumeables, nil, nil, nil, nil, saved_key, 'destilacion')
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                        new_card:juice_up(0.6, 0.6)
                        card_eval_status_text(new_card, 'extra', nil, nil, nil, {
                            message = 'Destilado!',
                            colour = G.C.SECONDARY_SET.Tarot
                        })
                    end
                    return true
                end
            }))
        end

        return ret
    end
end

SMODS.Voucher {
    key = 'ambrosia',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 3 },
    cost = 10,
    config = { extra = { dollars = 20 } },
    loc_txt = {
        name = 'Ambrosia',
        text = {
            "Earn {C:money}+$#1#{} for each",
            "{C:attention}Blind{} defeated"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    in_pool = function(self, args)
        local count = 0
        if G.vouchers and G.vouchers.cards then
            count = #G.vouchers.cards
        elseif G.GAME and G.GAME.used_vouchers then
            for k, v in pairs(G.GAME.used_vouchers) do
                if v and string.sub(k, 1, 2) == 'v_' then
                    count = count + 1
                end
            end
        end
        return count >= 4
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_ambrosia = true
        G.GAME.used_vouchers['v_Witch brew_ambrosia'] = true
        G.GAME.used_vouchers.v_ambrosia = true
        G.GAME.used_vouchers.ambrosia = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_ambrosia = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_ambrosia'] = false
        end
    end
}

SMODS.Voucher {
    key = 'nectar',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_ambrosia' },
    pos = { x = 1, y = 3 },
    cost = 10,
    config = { extra = { blind_reduction = 5, hand_size = 1, vouchers = 1, shop_space = 1, hands = 1 } },
    loc_txt = {
        name = 'Nectar',
        text = {
            "{C:attention}-#1#%{} Chip Requirement,",
            "{C:attention}+#2#{} Hand Size,",
            "{C:attention}+#3#{} Voucher on Shop,",
            "{C:attention}+#4#{} Shop Space,",
            "{C:attention}+#5#{} Hand"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.blind_reduction,
            card.ability.extra.hand_size,
            card.ability.extra.vouchers,
            card.ability.extra.shop_space,
            card.ability.extra.hands
        } }
    end,
    in_pool = function(self, args)
        local count = 0
        if G.vouchers and G.vouchers.cards then
            count = #G.vouchers.cards
        elseif G.GAME and G.GAME.used_vouchers then
            for k, v in pairs(G.GAME.used_vouchers) do
                if v and string.sub(k, 1, 2) == 'v_' then
                    count = count + 1
                end
            end
        end
        return count >= 4
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_nectar = true
        G.GAME.used_vouchers['v_Witch brew_nectar'] = true
        G.GAME.used_vouchers.v_nectar = true
        G.GAME.used_vouchers.nectar = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_nectar = false
            G.GAME.current_round.voucher.spawn['v_Witch brew_nectar'] = false
        end
        if G.hand and G.hand.change_size then
            G.hand:change_size(card.ability.extra.hand_size or 1)
        end
        if G.GAME and G.GAME.round_resets then
            G.GAME.round_resets.hand_size = (G.GAME.round_resets.hand_size or 8) + (card.ability.extra.hand_size or 1)
            G.GAME.round_resets.hands = (G.GAME.round_resets.hands or 4) + (card.ability.extra.hands or 1)
        end
        if ease_hands_played then
            ease_hands_played(card.ability.extra.hands or 1)
        end
        if change_shop_size then
            change_shop_size(card.ability.extra.shop_space or 1)
        end
        if G.shop_vouchers and G.shop_vouchers.cards then
            G.shop_vouchers.config.card_limit = G.shop_vouchers.config.card_limit + (card.ability.extra.vouchers or 1)
            local v_key = get_next_voucher_key and get_next_voucher_key(true)
            if v_key and G.P_CENTERS and G.P_CENTERS[v_key] then
                local v_card = Card(G.shop_vouchers.T.x + G.shop_vouchers.T.w/2, G.shop_vouchers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[v_key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                create_shop_card_ui(v_card, 'Voucher', G.shop_vouchers)
                v_card:start_materialize()
                G.shop_vouchers:emplace(v_card)
                G.shop_vouchers.T.w = G.shop_vouchers.config.card_limit * 1.02 * G.CARD_W
                if G.shop_vouchers.align_cards then G.shop_vouchers:align_cards() end
                if G.shop and G.shop.recalculate then G.shop:recalculate() end
            end
        end
    end
}

SMODS.Voucher {
    key = 'four_leaf_clover',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 4 },
    cost = 10,
    config = { extra = { odds = 4 } },
    loc_txt = {
        name = 'Four Leaf Clover',
        text = {
            "If you {C:red}fail{} a probability,",
            "the next one has a {C:green}#1# in #2#{}",
            "chance to be {C:attention}guaranteed{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or 4
        return { vars = { '' .. (G.GAME and G.GAME.probabilities.normal or 1), odds } }
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_four_leaf_clover = true
        G.GAME.used_vouchers.v_four_leaf_clover = true
        G.GAME.used_vouchers.four_leaf_clover = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_four_leaf_clover = false
            G.GAME.current_round.voucher.spawn.v_four_leaf_clover = false
        end
    end
}

SMODS.Voucher {
    key = 'loaded_d20',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_four_leaf_clover' },
    pos = { x = 1, y = 4 },
    cost = 10,
    loc_txt = {
        name = 'Loaded D20',
        text = {
            "If you {C:red}fail{} a probability,",
            "the next one is",
            "{C:attention}guaranteed{}"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_loaded_d20 = true
        G.GAME.used_vouchers.v_loaded_d20 = true
        G.GAME.used_vouchers.loaded_d20 = true
        G.GAME.used_vouchers.v_reality_warp_oops_all_20d = true
        G.GAME.used_vouchers.v_oops_all_20d = true
        G.GAME.used_vouchers.oops_all_20d = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_loaded_d20 = false
            G.GAME.current_round.voucher.spawn.v_loaded_d20 = false
            G.GAME.current_round.voucher.spawn.v_reality_warp_oops_all_20d = false
            G.GAME.current_round.voucher.spawn.v_oops_all_20d = false
        end
    end
}

function get_most_used_jokers(limit)
    limit = limit or 1
    local profile = (G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile]) or nil
    local usage = (profile and profile.joker_usage) or {}
    local jokers = {}
    for k, v in pairs(usage) do
        local center = G.P_CENTERS and G.P_CENTERS[k]
        if center and center.set == 'Joker' and not center.no_pool_flag then
            local count = 0
            if type(v) == 'table' then
                count = v.count or 0
                if count == 0 and v.wins then
                    for _, w in pairs(v.wins) do
                        count = count + (type(w) == 'number' and w or 1)
                    end
                end
            elseif type(v) == 'number' then
                count = v
            end
            if count > 0 then
                table.insert(jokers, { key = k, count = count, order = (type(v) == 'table' and v.order) or (center.order or 0) })
            end
        end
    end

    table.sort(jokers, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        return (a.order or 0) < (b.order or 0)
    end)

    local result = {}
    for i = 1, math.min(limit, #jokers) do
        table.insert(result, jokers[i].key)
    end

    local fallbacks = { 'j_joker', 'j_greedy_joker', 'j_lusty_joker' }
    local fb_idx = 1
    while #result < limit and fb_idx <= #fallbacks do
        local fb = fallbacks[fb_idx]
        local already = false
        for _, r in ipairs(result) do if r == fb then already = true; break end end
        if not already and G.P_CENTERS and G.P_CENTERS[fb] then
            table.insert(result, fb)
        end
        fb_idx = fb_idx + 1
    end

    return result
end

local function get_joker_display_name(key)
    if not key or not (G.P_CENTERS and G.P_CENTERS[key]) then return "-" end
    local name = nil
    if localize then
        pcall(function()
            name = localize({ type = 'name_text', key = key, set = 'Joker' })
        end)
    end
    if not name or name == '' or string.find(name, 'ERROR') then
        name = G.P_CENTERS[key].name or key
    end
    return name
end

SMODS.Voucher {
    key = 'delivery_box',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 5 },
    cost = 10,
    loc_txt = {
        name = 'Delivery Box',
        text = {
            "Your most used Joker",
            "{C:attention}#1#{}",
            "appears {C:attention}often{} in the shop",
            "{C:inactive}(regardless of rarity){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local top = get_most_used_jokers(1)
        local name = get_joker_display_name(top[1])
        return { vars = { name } }
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_delivery_box = true
        G.GAME.used_vouchers.v_delivery_box = true
        G.GAME.used_vouchers.delivery_box = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_delivery_box = false
            G.GAME.current_round.voucher.spawn.v_delivery_box = false
        end
    end
}

SMODS.Voucher {
    key = 'vip_drone',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_delivery_box' },
    pos = { x = 1, y = 5 },
    cost = 10,
    loc_txt = {
        name = 'VIP Drone',
        text = {
            "Your {C:attention}3 most used Jokers{}",
            "appear {C:attention}often{} in the shop",
            "{C:inactive,s:0.85}#1#, #2#, #3#{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local top = get_most_used_jokers(3)
        local n1 = get_joker_display_name(top[1])
        local n2 = get_joker_display_name(top[2])
        local n3 = get_joker_display_name(top[3])
        return { vars = { n1, n2, n3 } }
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_vip_drone = true
        G.GAME.used_vouchers.v_vip_drone = true
        G.GAME.used_vouchers.vip_drone = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_vip_drone = false
            G.GAME.current_round.voucher.spawn.v_vip_drone = false
        end
    end
}

local function draw_glitch_voucher_effect(card, layer)
    if not card or not card.children or not card.children.center then return end
    if layer and layer ~= 'card' and layer ~= 'both' then return end
    if card.sprite_facing and card.sprite_facing ~= 'front' then return end

    local current_time = (love.timer and love.timer.getTime()) or (G.TIMERS and G.TIMERS.REAL) or 0

    local sh = G.SHADERS and (G.SHADERS['reality_warp_glitch'] or G.SHADERS['glitch'])
    if sh then
        if not G.SHADERS['glitch'] then G.SHADERS['glitch'] = sh end
        if not G.SHADERS['reality_warp_glitch'] then G.SHADERS['reality_warp_glitch'] = sh end
        pcall(function()
            if sh:hasUniform('time') then sh:send('time', current_time) end
            if sh:hasUniform('glitch') then sh:send('glitch', { 0.5, current_time }) end
            if sh:hasUniform('reality_warp_glitch') then sh:send('reality_warp_glitch', { 0.5, current_time }) end
        end)
        local sh_name = G.SHADERS['reality_warp_glitch'] and 'reality_warp_glitch' or 'glitch'
        card.children.center:draw_shader(sh_name, nil, { 0.5, current_time })
    end
end

SMODS.Voucher {
    key = 'error_404',
    atlas = 'reality_warp_vouchers',
    pos = { x = 0, y = 6 },
    cost = 10,
    unlocked = false,
    draw = function(self, card, layer)
        draw_glitch_voucher_effect(card, layer)
    end,
    loc_txt = {
        name = 'ERROR 404',
        text = {
            "{C:dark_edition}Glitch{} consumable appears",
            "more frequently {C:inactive}({C:green}1 in 15{} each round)"
        },
        unlock = {
            "Use a {C:dark_edition}Glitch{} on",
            "any {C:attention}Joker{}"
        }
    },
    locked_loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    check_for_unlock = function(self, args)
        if args and args.type == 'rw_used_glitch' then
            return true
        end
        local p = G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile]
        if p and p.career_stats and (p.career_stats.rw_glitches_used or 0) > 0 then
            return true
        end
        return false
    end,
    in_pool = function(self, args)
        local p = G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile]
        local used_career = p and p.career_stats and (p.career_stats.rw_glitches_used or 0) > 0
        local used_run = G.GAME and G.GAME.rw_glitches_used and G.GAME.rw_glitches_used > 0
        return (used_career or used_run or false)
    end,
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_error_404 = true
        G.GAME.used_vouchers.v_error_404 = true
        G.GAME.used_vouchers.error_404 = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_error_404 = false
            G.GAME.current_round.voucher.spawn.v_error_404 = false
        end
    end
}

SMODS.Voucher {
    key = 'overclock',
    atlas = 'reality_warp_vouchers',
    requires = { 'v_reality_warp_error_404' },
    pos = { x = 1, y = 6 },
    cost = 10,
    draw = function(self, card, layer)
        draw_glitch_voucher_effect(card, layer)
    end,
    loc_txt = {
        name = 'Overclock',
        text = {
            "{C:dark_edition}Glitch{} consumable appears",
            "much more frequently {C:inactive}({C:green}1 in 5{} each round)"
        }
    },
    redeem = function(self, card)
        G.GAME.used_vouchers = G.GAME.used_vouchers or {}
        G.GAME.used_vouchers.v_reality_warp_overclock = true
        G.GAME.used_vouchers.v_overclock = true
        G.GAME.used_vouchers.overclock = true
        if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
            G.GAME.current_round.voucher.spawn.v_reality_warp_overclock = false
            G.GAME.current_round.voucher.spawn.v_overclock = false
        end
    end
}

SMODS.DrawStep {
    key = 'glitch_vouchers_shader',
    order = 22,
    func = function(self, layer)
        local ck = self.config and self.config.center and (self.config.center.key or self.config.center_key)
        if ck and (
            ck == 'v_reality_warp_error_404' or ck == 'v_error_404' or ck == 'error_404' or
            ck == 'v_reality_warp_overclock' or ck == 'v_overclock' or ck == 'overclock'
        ) then
            draw_glitch_voucher_effect(self, layer)
        end
    end
}

local function has_loaded_d20()
    return G.GAME and G.GAME.used_vouchers and (
        G.GAME.used_vouchers.v_reality_warp_loaded_d20 or
        G.GAME.used_vouchers.v_loaded_d20 or
        G.GAME.used_vouchers.loaded_d20 or
        G.GAME.used_vouchers.v_reality_warp_oops_all_20d or
        G.GAME.used_vouchers.v_oops_all_20d or
        G.GAME.used_vouchers.oops_all_20d
    )
end

local function has_four_leaf_clover()
    return G.GAME and G.GAME.used_vouchers and (
        G.GAME.used_vouchers.v_reality_warp_four_leaf_clover or
        G.GAME.used_vouchers.v_four_leaf_clover or
        G.GAME.used_vouchers.four_leaf_clover
    )
end

G.reality_warp_modify_odds = function(den) return den end

if SMODS and SMODS.pseudorandom_probability then
    local orig_smods_pseudorandom_probability = SMODS.pseudorandom_probability
    function SMODS.pseudorandom_probability(trigger_obj, seed, base_numerator, base_denominator, identifier, no_mod)
        local loaded = has_loaded_d20()
        local clover = has_four_leaf_clover()

        if not loaded and not clover then
            return orig_smods_pseudorandom_probability(trigger_obj, seed, base_numerator, base_denominator, identifier, no_mod)
        end

        local is_guaranteed = false
        if G.GAME and G.GAME.rw_prob_failed then
            G.GAME.rw_prob_failed = false
            if loaded then
                is_guaranteed = true
            elseif clover then
                local odds = (G.GAME.probabilities.normal or 1) / 4
                if pseudorandom('four_leaf_clover') < odds then
                    is_guaranteed = true
                end
            end
        end

        local result = orig_smods_pseudorandom_probability(trigger_obj, seed, base_numerator, base_denominator, identifier, no_mod)

        if is_guaranteed then
            result = true
            if SMODS.post_prob and #SMODS.post_prob > 0 then
                SMODS.post_prob[#SMODS.post_prob].result = true
            end
        end

        if not result then
            if G.GAME then
                G.GAME.rw_prob_failed = true
            end
        end

        return result
    end
end

if get_next_voucher_key then
    local orig_get_next_voucher_key = get_next_voucher_key
    function get_next_voucher_key(from_tag)
        local key = orig_get_next_voucher_key(from_tag)
        local count = 0
        if G.vouchers and G.vouchers.cards then
            count = #G.vouchers.cards
        elseif G.GAME and G.GAME.used_vouchers then
            for k, v in pairs(G.GAME.used_vouchers) do
                if v and string.sub(k, 1, 2) == 'v_' then
                    count = count + 1
                end
            end
        end
        if count < 4 then
            local attempts = 0
            while attempts < 50 and key and (string.find(key, 'ambrosia') or string.find(key, 'nectar')) do
                attempts = attempts + 1
                key = orig_get_next_voucher_key(from_tag)
            end
        end
        local p = G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile]
        local glitch_used = (p and p.career_stats and (p.career_stats.rw_glitches_used or 0) > 0) or (G.GAME and G.GAME.rw_glitches_used and G.GAME.rw_glitches_used > 0)
        if not glitch_used then
            local attempts = 0
            while attempts < 50 and key and (string.find(key, 'error_404') or string.find(key, 'overclock')) do
                attempts = attempts + 1
                key = orig_get_next_voucher_key(from_tag)
            end
        end
        return key
    end
end

if G.FUNCS and G.FUNCS.cash_out then
    local orig_cash_out_ambrosia = G.FUNCS.cash_out
    G.FUNCS.cash_out = function(e)
        if G.GAME and G.GAME.used_vouchers and (G.GAME.used_vouchers.v_reality_warp_ambrosia or G.GAME.used_vouchers['v_Witch brew_ambrosia'] or G.GAME.used_vouchers.v_ambrosia or G.GAME.used_vouchers.ambrosia) then
            ease_dollars(20)
            if G.HUD and G.HUD:get_UIE_by_ID('dollar_text_UI') then
                card_eval_status_text(G.HUD:get_UIE_by_ID('dollar_text_UI'), 'extra', nil, nil, nil, { message = '+$20 Ambrosia!', colour = G.C.MONEY })
            end
        end
        return orig_cash_out_ambrosia(e)
    end
end

if Blind and Blind.set_blind then
    local orig_blind_set_blind_nectar = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        local ret = orig_blind_set_blind_nectar(self, blind, reset, silent)
        if G.GAME and G.GAME.used_vouchers and (G.GAME.used_vouchers.v_reality_warp_nectar or G.GAME.used_vouchers.v_nectar or G.GAME.used_vouchers.nectar) then
            if self.chips then
                self.chips = math.max(1, math.floor(self.chips * 0.95))
                self.chip_text = number_format(self.chips)
            end
        end
        return ret
    end
end

if G.UIDEF and G.UIDEF.shop then
    local orig_uidef_shop_nectar = G.UIDEF.shop
    G.UIDEF.shop = function()
        local ret = orig_uidef_shop_nectar()
        if G.GAME and G.GAME.used_vouchers and (G.GAME.used_vouchers.v_reality_warp_nectar or G.GAME.used_vouchers.v_nectar or G.GAME.used_vouchers.nectar) then
            if G.shop_vouchers and G.shop_vouchers.cards and #G.shop_vouchers.cards < (G.shop_vouchers.config.card_limit or 1) + 1 then
                G.shop_vouchers.config.card_limit = math.max(G.shop_vouchers.config.card_limit or 1, #G.shop_vouchers.cards + 1)
                local v_key = get_next_voucher_key and get_next_voucher_key(true)
                if v_key and G.P_CENTERS and G.P_CENTERS[v_key] then
                    local v_card = Card(G.shop_vouchers.T.x + G.shop_vouchers.T.w/2, G.shop_vouchers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[v_key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(v_card, 'Voucher', G.shop_vouchers)
                    v_card:start_materialize()
                    G.shop_vouchers:emplace(v_card)
                    G.shop_vouchers.T.w = G.shop_vouchers.config.card_limit * 1.02 * G.CARD_W
                    if G.shop_vouchers.align_cards then G.shop_vouchers:align_cards() end
                    if G.shop and G.shop.recalculate then G.shop:recalculate() end
                end
            end
        end
        return ret
    end
end


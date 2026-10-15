SMODS.Atlas {
    key = "reality_warp_stakes",
    path = "reality_warp_stakes.png",
    px = 29,
    py = 29
}

SMODS.Atlas {
    key = "reality_warp_stake_stickers",
    path = "reality_warp_stake_stickers.png",
    px = 71,
    py = 95
}

SMODS.Sticker {
    key = "weakened",
    atlas = "reality_warp_stickers",
    pos = { x = 0, y = 2 },
    badge_colour = HEX('94a3b8'),
    prefix_config = { key = false },
    sets = { Joker = true },
    rate = 0.3,
    needs_enable_flag = true,
    should_apply = function(self, card, center, area, bypass_roll)
        return G.GAME and G.GAME.modifiers and G.GAME.modifiers.enable_weakened_in_shop and
            SMODS.Sticker.should_apply(self, card, center, area, bypass_roll)
    end,
    apply = function(self, card, val)
        SMODS.Sticker.apply(self, card, val)
        if card and card.ability then
            card.ability.weakened = val
        end
    end,
    loc_txt = {
        name = "Weakened",
        text = {
            "All scoring and dollar values",
            "granted by this Joker are {C:attention}halved{}"
        }
    }
}

SMODS.Stake {
    key = 'diamond',
    above_stake = 'gold',
    applied_stakes = { 'gold' },
    prefix_config = { above_stake = { mod = false }, applied_stakes = { mod = false } },
    pos = { x = 0, y = 0 },
    sticker_pos = { x = 0, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('5eead4'),
    shiny = true,
    loc_txt = {
        name = 'Diamond Stake',
        text = {
            "Required Ante to win",
            "is increased to {C:attention}Ante 9{}"
        }
    },
    modifiers = function()
        G.GAME.win_ante = 9
    end
}

SMODS.Stake {
    key = 'obsidian',
    above_stake = 'diamond',
    applied_stakes = { 'diamond' },
    pos = { x = 1, y = 0 },
    sticker_pos = { x = 1, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('334155'),
    shiny = false,
    loc_txt = {
        name = 'Obsidian Stake',
        text = {
            "Editions are {C:attention}less likely{}",
            "to appear in the shop"
        }
    },
    modifiers = function()
        G.GAME.modifiers.reduced_edition_rate = true
    end
}

SMODS.Stake {
    key = 'greedy',
    above_stake = 'obsidian',
    applied_stakes = { 'obsidian' },
    pos = { x = 8, y = 0 },
    sticker_pos = { x = 8, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('10b981'),
    shiny = true,
    loc_txt = {
        name = 'Greedy Stake',
        text = {
            "Lose {C:money}$1{} when",
            "leaving the shop"
        }
    },
    modifiers = function()
        G.GAME.modifiers.exit_shop_lose_dollar = true
    end
}

SMODS.Stake {
    key = 'amber',
    above_stake = 'greedy',
    applied_stakes = { 'greedy' },
    pos = { x = 2, y = 0 },
    sticker_pos = { x = 2, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('f59e0b'),
    shiny = true,
    loc_txt = {
        name = 'Amber Stake',
        text = {
            "{C:dark_edition}Negative{} cards no longer",
            "appear in the shop"
        }
    },
    modifiers = function()
        G.GAME.modifiers.no_shop_negatives = true
    end
}

SMODS.Stake {
    key = 'sapphire',
    above_stake = 'amber',
    applied_stakes = { 'amber' },
    pos = { x = 3, y = 0 },
    sticker_pos = { x = 3, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('3b82f6'),
    shiny = true,
    loc_txt = {
        name = 'Sapphire Stake',
        text = {
            "Vouchers cost",
            "{C:money}$15{}"
        }
    },
    modifiers = function()
        G.GAME.modifiers.voucher_cost_increase = 5
    end
}

SMODS.Stake {
    key = 'amethyst',
    above_stake = 'sapphire',
    applied_stakes = { 'sapphire' },
    pos = { x = 4, y = 0 },
    sticker_pos = { x = 4, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('a855f7'),
    shiny = true,
    loc_txt = {
        name = 'Amethyst Stake',
        text = {
            "{C:attention}-1{} Consumable slot",
            "{C:inactive}(Min: 1){}"
        }
    },
    modifiers = function()
        G.GAME.starting_params.consumable_slots = math.max(1, (G.GAME.starting_params.consumable_slots or 2) - 1)
    end
}

SMODS.Stake {
    key = 'platinum',
    above_stake = 'amethyst',
    applied_stakes = { 'amethyst' },
    pos = { x = 5, y = 0 },
    sticker_pos = { x = 5, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('cbd5e1'),
    shiny = true,
    loc_txt = {
        name = 'Platinum Stake',
        text = {
            "Shop Jokers can have",
            "the {C:attention}Weakened{} sticker"
        }
    },
    modifiers = function()
        G.GAME.modifiers.enable_weakened_in_shop = true
    end
}

SMODS.Stake {
    key = 'void',
    above_stake = 'platinum',
    applied_stakes = { 'platinum' },
    pos = { x = 6, y = 0 },
    sticker_pos = { x = 6, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('1e1035'),
    shiny = false,
    loc_txt = {
        name = 'Void Stake',
        text = {
            "{C:purple}Dark Market{} items have a",
            "{C:attention}10%{} price increase"
        }
    },
    modifiers = function()
        G.GAME.modifiers.black_market_price_increase = 0.10
    end
}

SMODS.Stake {
    key = 'big',
    above_stake = 'void',
    applied_stakes = { 'void' },
    pos = { x = 9, y = 0 },
    sticker_pos = { x = 9, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('ef4444'),
    shiny = true,
    loc_txt = {
        name = 'Big Stake',
        text = {
            "{C:attention}Big Blinds{} can now",
            "be {C:attention}Boss Blinds{}"
        }
    },
    modifiers = function()
        G.GAME.modifiers.big_blind_boss_chance = true
    end
}

SMODS.Stake {
    key = 'celestial',
    above_stake = 'big',
    applied_stakes = { 'big' },
    pos = { x = 7, y = 0 },
    sticker_pos = { x = 7, y = 0 },
    atlas = 'reality_warp_stakes',
    sticker_atlas = 'reality_warp_stake_stickers',
    colour = HEX('c084fc'),
    shiny = true,
    loc_txt = {
        name = 'Celestial Stake',
        text = {
            "Every {C:attention}4 Antes{} Boss Blinds",
            "become {C:attention}Showdown Blinds{}"
        }
    },
    modifiers = function()
        G.GAME.modifiers.celestial_stake = true
    end
}

if reset_blinds then
    local orig_reset_blinds = reset_blinds
    function reset_blinds()
        orig_reset_blinds()
        if G.GAME and G.GAME.modifiers and G.GAME.modifiers.big_blind_boss_chance then
            local get_boss = get_new_boss_filtered or get_new_boss
            if get_boss and pseudorandom('big_stake_boss') < 0.5 then
                G.GAME.round_resets.blind_choices.Big = get_boss(false)
            end
        end
        if G.GAME and G.GAME.modifiers and G.GAME.modifiers.celestial_stake then
            local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 1
            if ante % 4 == 0 and ante >= 1 and get_new_boss_filtered then
                G.GAME.round_resets.blind_choices.Boss = get_new_boss_filtered(true)
            end
        end
    end
end

if get_new_boss then
    local orig_get_new_boss = get_new_boss
    function get_new_boss(...)
        if G.GAME and G.GAME.modifiers and G.GAME.modifiers.celestial_stake then
            local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 1
            if ante % 4 == 0 and ante >= 1 and get_new_boss_filtered then
                return get_new_boss_filtered(true)
            end
        end
        return orig_get_new_boss(...)
    end
end

if SMODS and SMODS.get_new_blind then
    local orig_smods_get_new_blind = SMODS.get_new_blind
    function SMODS.get_new_blind(blind_type)
        if G.GAME and G.GAME.modifiers and G.GAME.modifiers.big_blind_boss_chance then
            if (blind_type == "big" or blind_type == "Big") and pseudorandom('big_stake_smods') < 0.5 then
                blind_type = "boss"
            end
        end
        return orig_smods_get_new_blind(blind_type)
    end
end

-- Palettes for Mod Stake & Sticker Fire Effect (Reality Warp Exclusives only)
local STAKE_FIRE_COLORS = {
    -- Reality Warp Custom Stakes & Stickers
    ['stake_reality_warp_diamond'] = { r = 0.37, g = 0.92, b = 0.83, core = {0.85, 1.0, 0.95} },
    ['reality_warp_diamond']       = { r = 0.37, g = 0.92, b = 0.83, core = {0.85, 1.0, 0.95} },
    ['diamond']                    = { r = 0.37, g = 0.92, b = 0.83, core = {0.85, 1.0, 0.95} },

    ['stake_reality_warp_obsidian']= { r = 0.22, g = 0.28, b = 0.38, core = {1.0, 0.45, 0.15} },
    ['reality_warp_obsidian']      = { r = 0.22, g = 0.28, b = 0.38, core = {1.0, 0.45, 0.15} },
    ['obsidian']                   = { r = 0.22, g = 0.28, b = 0.38, core = {1.0, 0.45, 0.15} },

    ['stake_reality_warp_greedy']  = { r = 0.06, g = 0.73, b = 0.51, core = {0.65, 1.0, 0.75} },
    ['reality_warp_greedy']        = { r = 0.06, g = 0.73, b = 0.51, core = {0.65, 1.0, 0.75} },
    ['greedy']                     = { r = 0.06, g = 0.73, b = 0.51, core = {0.65, 1.0, 0.75} },

    ['stake_reality_warp_amber']   = { r = 0.96, g = 0.62, b = 0.04, core = {1.0, 0.92, 0.40} },
    ['reality_warp_amber']         = { r = 0.96, g = 0.62, b = 0.04, core = {1.0, 0.92, 0.40} },
    ['amber']                      = { r = 0.96, g = 0.62, b = 0.04, core = {1.0, 0.92, 0.40} },

    ['stake_reality_warp_sapphire']= { r = 0.23, g = 0.51, b = 0.96, core = {0.65, 0.85, 1.0} },
    ['reality_warp_sapphire']      = { r = 0.23, g = 0.51, b = 0.96, core = {0.65, 0.85, 1.0} },
    ['sapphire']                   = { r = 0.23, g = 0.51, b = 0.96, core = {0.65, 0.85, 1.0} },

    ['stake_reality_warp_amethyst']= { r = 0.66, g = 0.33, b = 0.97, core = {0.92, 0.70, 1.0} },
    ['reality_warp_amethyst']      = { r = 0.66, g = 0.33, b = 0.97, core = {0.92, 0.70, 1.0} },
    ['amethyst']                   = { r = 0.66, g = 0.33, b = 0.97, core = {0.92, 0.70, 1.0} },

    ['stake_reality_warp_platinum']= { r = 0.80, g = 0.84, b = 0.88, core = {1.0, 1.0, 1.0} },
    ['reality_warp_platinum']      = { r = 0.80, g = 0.84, b = 0.88, core = {1.0, 1.0, 1.0} },
    ['platinum']                   = { r = 0.80, g = 0.84, b = 0.88, core = {1.0, 1.0, 1.0} },

    ['stake_reality_warp_void']    = { r = 0.49, g = 0.23, b = 0.93, core = {0.25, 0.08, 0.40} },
    ['reality_warp_void']          = { r = 0.49, g = 0.23, b = 0.93, core = {0.25, 0.08, 0.40} },
    ['void']                       = { r = 0.49, g = 0.23, b = 0.93, core = {0.25, 0.08, 0.40} },

    ['stake_reality_warp_big']     = { r = 0.94, g = 0.27, b = 0.27, core = {1.0, 0.85, 0.35} },
    ['reality_warp_big']           = { r = 0.94, g = 0.27, b = 0.27, core = {1.0, 0.85, 0.35} },
    ['big']                        = { r = 0.94, g = 0.27, b = 0.27, core = {1.0, 0.85, 0.35} },

    ['stake_reality_warp_celestial']= { r = 0.85, g = 0.71, b = 0.89, core = {0.65, 0.92, 1.0} },
    ['reality_warp_celestial']     = { r = 0.85, g = 0.71, b = 0.89, core = {0.65, 0.92, 1.0} },
    ['celestial']                  = { r = 0.85, g = 0.71, b = 0.89, core = {0.65, 0.92, 1.0} },

    -- Mod Ability Sticker
    ['weakened']                   = { r = 0.58, g = 0.64, b = 0.72, core = {0.90, 0.92, 0.98} },
}

local function get_stake_fire_color(k)
    if not k then return nil end
    if type(k) == 'number' then
        k = (G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[k] and G.P_CENTER_POOLS.Stake[k].key) or tostring(k)
    end
    k = tostring(k)
    if STAKE_FIRE_COLORS[k] then return STAKE_FIRE_COLORS[k] end
    local clean = k:gsub('^stake_reality_warp_', ''):gsub('^reality_warp_', ''):gsub('^stake_', ''):gsub('_sticker$', '')
    return STAKE_FIRE_COLORS[clean] or STAKE_FIRE_COLORS['stake_' .. clean] or STAKE_FIRE_COLORS['stake_reality_warp_' .. clean]
end

local function draw_stake_fire(x, y, w, h, col)
    if not love or not love.graphics or not col then return end
    local t = love.timer and love.timer.getTime() or 0
    local cx = x + w * 0.5
    local cy = y + h * 0.5
    local base_r = math.min(w, h) * 0.50

    love.graphics.push('all')
    love.graphics.setBlendMode('add', 'alphamultiply')

    -- 1. Outer dynamic flame tongues dancing around perimeter
    local num_flames = 14
    for i = 1, num_flames do
        local angle = (i / num_flames) * math.pi * 2 + math.sin(t * 2.2 + i) * 0.14
        local flicker = math.sin(t * 7.0 + i * 2.1) * 0.30 + math.cos(t * 11.0 - i * 1.5) * 0.15
        local upward_bias = -math.sin(angle) * 0.15
        local flame_len = base_r * (1.18 + 0.30 * flicker + upward_bias)

        local fx = cx + math.cos(angle) * flame_len
        local fy = cy + math.sin(angle) * flame_len

        local tangent = angle + math.pi * 0.5
        local hw = base_r * 0.22
        local bx1 = cx + math.cos(angle) * (base_r * 0.80) + math.cos(tangent) * hw
        local by1 = cy + math.sin(angle) * (base_r * 0.80) + math.sin(tangent) * hw
        local bx2 = cx + math.cos(angle) * (base_r * 0.80) - math.cos(tangent) * hw
        local by2 = cy + math.sin(angle) * (base_r * 0.80) - math.cos(tangent) * hw

        love.graphics.setColor(col.r, col.g, col.b, 0.60 + 0.20 * math.sin(t * 4.5 + i))
        love.graphics.polygon('fill', bx1, by1, fx, fy, bx2, by2)

        local core_c = col.core or {1, 1, 1}
        local core_fx = cx + math.cos(angle) * (flame_len * 0.65)
        local core_fy = cy + math.sin(angle) * (flame_len * 0.65)
        love.graphics.setColor(core_c[1], core_c[2], core_c[3], 0.75 + 0.20 * math.cos(t * 5.5 + i))
        love.graphics.polygon('fill', bx1, by1, core_fx, core_fy, bx2, by2)
    end

    -- 2. Radial flame glow rings
    for ring = 1, 3 do
        local r_mult = 1.0 + ring * 0.08 + math.sin(t * 3.5 + ring) * 0.04
        local alpha = (0.35 / ring) * (0.8 + 0.2 * math.sin(t * 2.8 + ring * 1.2))
        love.graphics.setColor(col.r, col.g, col.b, alpha)
        love.graphics.circle('fill', cx, cy, base_r * r_mult, 32)
    end

    -- 3. Drifting sparks/embers
    for spark = 1, 8 do
        local st = (t * 1.5 + spark * 0.618) % 1.0
        local s_angle = (spark * 0.785) + math.sin(t * 1.2 + spark) * 0.4
        local s_dist = base_r * (0.90 + st * 0.60)
        local sx = cx + math.cos(s_angle) * s_dist
        local sy = cy + math.sin(s_angle) * s_dist - (st * base_r * 0.35)
        local s_size = (1.0 - st) * (base_r * 0.12)
        local s_alpha = (1.0 - st) * 0.85
        local core_c = col.core or {1, 1, 1}
        love.graphics.setColor(core_c[1], core_c[2], core_c[3], s_alpha)
        love.graphics.circle('fill', sx, sy, math.max(0.015, s_size), 8)
    end

    love.graphics.pop()
end

-- Hook: Scale Big Stake texture & Draw custom dominant color Fire Effect on stake sprite
if get_stake_sprite then
    local orig_get_stake_sprite = get_stake_sprite
    function get_stake_sprite(_stake, _scale)
        local is_big = false
        local stake_key = nil
        if _stake and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[_stake] then
            stake_key = G.P_CENTER_POOLS.Stake[_stake].key
        elseif type(_stake) == 'string' or type(_stake) == 'number' then
            stake_key = _stake
        end
        if stake_key == 'stake_reality_warp_big' or stake_key == 'stake_big' or stake_key == 'big' then
            is_big = true
        end
        if is_big and (_scale or 1) >= 1.0 then
            _scale = (_scale or 1) * 1.3
        end
        local sprite = orig_get_stake_sprite(_stake, _scale)
        local fire_col = get_stake_fire_color(stake_key)
        if fire_col and sprite then
            local orig_sprite_draw_self = sprite.draw_self
            sprite.draw_self = function(_sprite, overlay, ...)
                if prep_draw then
                    prep_draw(_sprite, 1)
                    draw_stake_fire(0, 0, _sprite.T.w, _sprite.T.h, fire_col)
                    love.graphics.pop()
                end
                if orig_sprite_draw_self then
                    return orig_sprite_draw_self(_sprite, overlay, ...)
                else
                    return Sprite.draw_self(_sprite, overlay, ...)
                end
            end
        end
        return sprite
    end
end

-- Hook: Draw fire effect on stake tower cards and stake stickers on cards
local card_draw_stake_fire_ref = Card.draw
function Card:draw(layer)
    if (layer == 'card' or layer == 'both' or not layer) and self.params and self.params.run_select_stake_tower then
        local st_info = self.params.run_select_stake_tower
        local stake_k = st_info[2]
        local fire_col = get_stake_fire_color(stake_k)
        if fire_col and prep_draw then
            prep_draw(self, 1)
            draw_stake_fire(0, 0, self.T.w, self.T.h, fire_col)
            love.graphics.pop()
        end
    end

    card_draw_stake_fire_ref(self, layer)

    -- Draw fire particles on stake win stickers and ability stickers attached to cards
    if (layer == 'card' or layer == 'both' or not layer) and prep_draw then
        local is_legendary = self.config and self.config.center and (
            self.config.center.soul_pos or
            self.config.center.rarity == 4 or
            self.children.floating_sprite ~= nil or
            self.config.center.legendary == true
        )
        local float_x, float_y, rot_mod, sc_mod = 0, 0, 0, 0
        if is_legendary then
            local real_t = (G.TIMERS and G.TIMERS.REAL) or (love.timer and love.timer.getTime()) or 0
            sc_mod = 0.05 + 0.04 * math.sin(1.8 * real_t) + 0.04 * math.sin((real_t - math.floor(real_t)) * math.pi * 14) * (1 - (real_t - math.floor(real_t))) ^ 3
            rot_mod = 0.08 * math.sin(1.219 * real_t) + 0.04 * math.sin(real_t * math.pi * 5) * (1 - (real_t - math.floor(real_t))) ^ 2
            float_y = math.sin(1.8 * real_t) * (self.T.h * 0.035)
            float_x = math.cos(1.219 * real_t) * (self.T.w * 0.02)
        end

        local st = self.sticker
        if not st and self.config and self.config.center and get_joker_win_sticker then
            st = get_joker_win_sticker(self.config.center)
        end
        if not st and self.sticker_run and self.sticker_run ~= 'NONE' and G.SETTINGS and G.SETTINGS.run_stake_stickers then
            st = self.sticker_run
        end
        if st then
            local fire_col = get_stake_fire_color(st)
            if fire_col then
                prep_draw(self, 1)
                if is_legendary then
                    love.graphics.translate(self.T.w * 0.5 + float_x, self.T.h * 0.5 + float_y)
                    love.graphics.rotate(rot_mod)
                    love.graphics.scale(1 + sc_mod, 1 + sc_mod)
                    love.graphics.translate(-self.T.w * 0.5, -self.T.h * 0.5)
                end
                local sw = self.T.w * 0.36
                local sh = self.T.h * 0.36
                local sx = self.T.w * 0.81 - sw * 0.5
                local sy = self.T.h * 0.16 - sh * 0.5
                draw_stake_fire(sx, sy, sw, sh, fire_col)
                love.graphics.pop()
            end
        end

        if self.ability and self.ability.weakened then
            local fire_col = get_stake_fire_color('weakened')
            if fire_col then
                prep_draw(self, 1)
                if is_legendary then
                    love.graphics.translate(self.T.w * 0.5 + float_x, self.T.h * 0.5 + float_y)
                    love.graphics.rotate(rot_mod)
                    love.graphics.scale(1 + sc_mod, 1 + sc_mod)
                    love.graphics.translate(-self.T.w * 0.5, -self.T.h * 0.5)
                end
                local sw, sh = self.T.w * 0.32, self.T.h * 0.32
                draw_stake_fire(self.T.w * 0.18 - sw * 0.5, self.T.h * 0.82 - sh * 0.5, sw, sh, fire_col)
                love.graphics.pop()
            end
        end
    end
end

-- Hook: Amber Stake (no negative in shop) & Obsidian Stake (reduced edition rate)
if poll_edition then
    local orig_poll_edition = poll_edition
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        if G.GAME and G.GAME.modifiers then
            if G.GAME.modifiers.no_shop_negatives and _key and string.sub(_key, 1, 3) == 'edi' then
                _no_neg = true
            end
            if G.GAME.modifiers.reduced_edition_rate and _key and string.sub(_key, 1, 3) == 'edi' and not _guaranteed then
                _mod = (_mod or 1) * 0.5
            end
        end
        return orig_poll_edition(_key, _mod, _no_neg, _guaranteed)
    end
end

-- Hook: Greedy Stake (Lose $1 when leaving shop)
if G.FUNCS and G.FUNCS.toggle_shop then
    local orig_toggle_shop = G.FUNCS.toggle_shop
    G.FUNCS.toggle_shop = function(e)
        if G.shop and G.GAME and G.GAME.modifiers and G.GAME.modifiers.exit_shop_lose_dollar then
            ease_dollars(-1)
        end
        return orig_toggle_shop(e)
    end
end

-- Fix: Register win sticker tooltips so hover info shows completed stake
local STAKE_STICKER_DESCS = {
    diamond = { name = "Diamond Sticker", stake = "Diamond Stake" },
    obsidian = { name = "Obsidian Sticker", stake = "Obsidian Stake" },
    greedy = { name = "Greedy Sticker", stake = "Greedy Stake" },
    amber = { name = "Amber Sticker", stake = "Amber Stake" },
    sapphire = { name = "Sapphire Sticker", stake = "Sapphire Stake" },
    amethyst = { name = "Amethyst Sticker", stake = "Amethyst Stake" },
    platinum = { name = "Platinum Sticker", stake = "Platinum Stake" },
    void = { name = "Void Sticker", stake = "Void Stake" },
    big = { name = "Big Sticker", stake = "Big Stake" },
    celestial = { name = "Celestial Sticker", stake = "Celestial Stake" },
}

local function parse_mod_loc_entry(entry)
    if not entry then return end
    entry.text_parsed = {}
    if entry.text then
        for _, line in ipairs(entry.text) do
            entry.text_parsed[#entry.text_parsed + 1] = (loc_parse_string and loc_parse_string(line)) or { { strings = { line }, control = {} } }
        end
    end
    entry.name_parsed = {}
    if entry.name then
        local names = type(entry.name) == 'table' and entry.name or { entry.name }
        for _, line in ipairs(names) do
            entry.name_parsed[#entry.name_parsed + 1] = (loc_parse_string and loc_parse_string(line)) or { { strings = { line }, control = {} } }
        end
    end
end

local function register_mod_stake_sticker_loc()
    if not G.localization or not G.localization.descriptions then return end
    G.localization.descriptions.Other = G.localization.descriptions.Other or {}
    for k, v in pairs(STAKE_STICKER_DESCS) do
        local entry = {
            name = v.name,
            text = {
                "Used this to win on",
                "{C:attention}" .. v.stake .. "{} difficulty"
            }
        }
        parse_mod_loc_entry(entry)
        G.localization.descriptions.Other[k .. '_sticker'] = entry
        G.localization.descriptions.Other['reality_warp_' .. k .. '_sticker'] = entry
        G.localization.descriptions.Other['stake_reality_warp_' .. k .. '_sticker'] = entry
    end
end

register_mod_stake_sticker_loc()

local orig_init_loc_stakes = init_localization
function init_localization()
    if orig_init_loc_stakes then orig_init_loc_stakes() end
    register_mod_stake_sticker_loc()
end



if G.UIDEF and G.UIDEF.viewed_stake_option then
    local orig_viewed_stake_option = G.UIDEF.viewed_stake_option
    function G.UIDEF.viewed_stake_option()
        local ret = orig_viewed_stake_option()
        local viewed_k = G.viewed_stake and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[G.viewed_stake] and G.P_CENTER_POOLS.Stake[G.viewed_stake].key
        if viewed_k == 'stake_reality_warp_big' or viewed_k == 'big' or viewed_k == 'stake_big' then
            if ret and ret.config then
                ret.config.minw = (ret.config.minw or 6) + 0.5
            end
        end
        return ret
    end
end

-- Celestial Stake Deck Win Unique Particles
if SMODS and SMODS.DrawStep then
    SMODS.DrawStep {
        key = 'celestial_deck_particles',
        order = 96,
        func = function(self)
            if self.children and self.children.celestial_particles and self.children.celestial_particles.draw then
                self.children.celestial_particles:draw()
            end
        end
    }
end

local card_update_celestial_ref = Card.update
function Card:update(dt)
    card_update_celestial_ref(self, dt)
    local is_celestial_deck = false
    local deck_key = nil
    if self.params and type(self.params.viewed_back) == 'table' and self.params.viewed_back.effect and self.params.viewed_back.effect.center then
        deck_key = self.params.viewed_back.effect.center.key
    elseif self.params and self.params.viewed_back and self.custom_back and type(self.custom_back) == 'table' and self.custom_back.effect and self.custom_back.effect.center then
        deck_key = self.custom_back.effect.center.key
    elseif self.area and self.area == G.deck and G.GAME and type(G.GAME.selected_back) == 'table' and G.GAME.selected_back.effect and G.GAME.selected_back.effect.center then
        deck_key = G.GAME.selected_back.effect.center.key
    end
    
    if deck_key and G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].deck_usage and G.PROFILES[G.SETTINGS.profile].deck_usage[deck_key] and G.PROFILES[G.SETTINGS.profile].deck_usage[deck_key].wins_by_key then
        local w = G.PROFILES[G.SETTINGS.profile].deck_usage[deck_key].wins_by_key
        if w['stake_reality_warp_celestial'] or w['celestial'] or w['stake_celestial'] then
            is_celestial_deck = true
        end
    end
    if self.sticker and (self.sticker == 'celestial' or self.sticker == 'stake_reality_warp_celestial') then
        is_celestial_deck = true
    end

    if is_celestial_deck and Particles and self.states and self.states.visible then
        if not self.children.celestial_particles then
            local p = Particles(0, 0, 0, 0, {
                timer = 0.08,
                scale = 0.20,
                speed = 0.5,
                lifespan = 1.3,
                attach = self,
                colours = { HEX('c084fc'), HEX('ffd700'), HEX('38bdf8'), HEX('ffffff') },
                fill = true,
                initialize = true
            })
            p.custom_draw = true
            self.children.celestial_particles = p
        end
    elseif self.children and self.children.celestial_particles then
        pcall(function() self.children.celestial_particles:remove() end)
        self.children.celestial_particles = nil
    end
end


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

-- Palettes for Stake Fire Effect (Dominant Color + Hot Core)
local STAKE_FIRE_COLORS = {
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
}

local function draw_stake_fire(x, y, w, h, col)
    if not love or not love.graphics or not col then return end
    local t = love.timer and love.timer.getTime() or 0
    local cx = x + w * 0.5
    local cy = y + h * 0.5
    local base_r = math.min(w, h) * 0.48

    love.graphics.push('all')
    love.graphics.setBlendMode('add', 'alphamultiply')

    -- 1. Outer dynamic flame tongues dancing around perimeter
    local num_flames = 12
    for i = 1, num_flames do
        local angle = (i / num_flames) * math.pi * 2 + math.sin(t * 1.8 + i) * 0.12
        local flicker = math.sin(t * 6.0 + i * 2.1) * 0.30 + math.cos(t * 9.5 - i * 1.5) * 0.15
        local upward_bias = -math.sin(angle) * 0.12
        local flame_len = base_r * (1.10 + 0.25 * flicker + upward_bias)

        local fx = cx + math.cos(angle) * flame_len
        local fy = cy + math.sin(angle) * flame_len

        local tangent = angle + math.pi * 0.5
        local hw = base_r * 0.20
        local bx1 = cx + math.cos(angle) * (base_r * 0.85) + math.cos(tangent) * hw
        local by1 = cy + math.sin(angle) * (base_r * 0.85) + math.sin(tangent) * hw
        local bx2 = cx + math.cos(angle) * (base_r * 0.85) - math.cos(tangent) * hw
        local by2 = cy + math.sin(angle) * (base_r * 0.85) - math.cos(tangent) * hw

        love.graphics.setColor(col.r, col.g, col.b, 0.35 + 0.15 * math.sin(t * 4.5 + i))
        love.graphics.polygon('fill', bx1, by1, fx, fy, bx2, by2)

        local core_c = col.core or {1, 1, 1}
        local core_fx = cx + math.cos(angle) * (flame_len * 0.65)
        local core_fy = cy + math.sin(angle) * (flame_len * 0.65)
        love.graphics.setColor(core_c[1], core_c[2], core_c[3], 0.50 + 0.2 * math.cos(t * 5.5 + i))
        love.graphics.polygon('fill', bx1, by1, core_fx, core_fy, bx2, by2)
    end

    -- 2. Radial flame glow rings
    for ring = 1, 3 do
        local r_mult = 1.0 + ring * 0.07 + math.sin(t * 3.5 + ring) * 0.03
        local alpha = (0.25 / ring) * (0.8 + 0.2 * math.sin(t * 2.8 + ring * 1.2))
        love.graphics.setColor(col.r, col.g, col.b, alpha)
        love.graphics.circle('fill', cx, cy, base_r * r_mult, 32)
    end

    -- 3. Drifting sparks/embers
    for spark = 1, 5 do
        local st = (t * 1.6 + spark * 1.618) % 1.0
        local s_angle = (spark * 1.25) + math.sin(t + spark) * 0.4
        local s_dist = base_r * (0.92 + st * 0.45)
        local sx = cx + math.cos(s_angle) * s_dist
        local sy = cy + math.sin(s_angle) * s_dist - (st * base_r * 0.25)
        local s_size = (1.0 - st) * (base_r * 0.07)
        local s_alpha = (1.0 - st) * 0.65
        local core_c = col.core or {1, 1, 1}
        love.graphics.setColor(core_c[1], core_c[2], core_c[3], s_alpha)
        love.graphics.circle('fill', sx, sy, s_size, 8)
    end

    love.graphics.pop()
end

-- Hook: Scale Big Stake texture & Draw custom dominant color Fire Effect
if get_stake_sprite then
    local orig_get_stake_sprite = get_stake_sprite
    function get_stake_sprite(_stake, _scale)
        local is_big = false
        local stake_key = nil
        if _stake and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[_stake] then
            stake_key = G.P_CENTER_POOLS.Stake[_stake].key
        elseif type(_stake) == 'string' then
            stake_key = _stake
        end
        if stake_key == 'stake_reality_warp_big' or stake_key == 'stake_big' or stake_key == 'big' then
            is_big = true
        end
        if is_big then
            _scale = (_scale or 1) * 1.3
        end
        local sprite = orig_get_stake_sprite(_stake, _scale)
        local fire_col = STAKE_FIRE_COLORS[stake_key]
        if fire_col and sprite then
            local orig_sprite_draw = sprite.draw
            sprite.draw = function(_sprite)
                draw_stake_fire(_sprite.VT.x, _sprite.VT.y, _sprite.VT.w, _sprite.VT.h, fire_col)
                if orig_sprite_draw then
                    orig_sprite_draw(_sprite)
                else
                    Sprite.draw(_sprite)
                end
            end
        end
        return sprite
    end
end

-- Hook: Draw fire effect on stake tower cards and stake stickers on cards
local card_draw_stake_fire_ref = Card.draw
function Card:draw(layer)
    if layer == 'card' and self.params and self.params.run_select_stake_tower then
        local st_info = self.params.run_select_stake_tower
        local stake_k = st_info[2]
        local fire_col = STAKE_FIRE_COLORS[stake_k]
        if fire_col then
            draw_stake_fire(self.VT.x, self.VT.y, self.VT.w, self.VT.h, fire_col)
        end
    end
    card_draw_stake_fire_ref(self, layer)

    -- Draw fire particles on stake stickers attached to cards/jokers/decks
    if (layer == 'card' or layer == 'both' or not layer) and self.children and self.children.center then
        local st = self.sticker or ((self.sticker_run and self.sticker_run ~= 'NONE') and G.SETTINGS and G.SETTINGS.run_stake_stickers and self.sticker_run)
        if st then
            local fire_col = STAKE_FIRE_COLORS[st]
            if not fire_col then
                local stripped = string.gsub(tostring(st), '_sticker$', '')
                fire_col = STAKE_FIRE_COLORS[stripped]
            end
            if fire_col then
                local center = self.children.center
                local sw = center.VT.w * 0.55
                local sh = center.VT.h * 0.55
                local sx = center.VT.x + center.VT.w * 0.5 - sw * 0.5
                local sy = center.VT.y + center.VT.h * 0.28 - sh * 0.5
                draw_stake_fire(sx, sy, sw, sh, fire_col)
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

-- Hook: Widen Stake Menu when Big Stake is selected or in applied stakes
if G.UIDEF and G.UIDEF.SMODS_current_stake then
    local orig_SMODS_current_stake = G.UIDEF.SMODS_current_stake
    function G.UIDEF.SMODS_current_stake()
        local current_stake_key = G.GAME and G.GAME.stake and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake and G.P_CENTER_POOLS.Stake[G.GAME.stake] and G.P_CENTER_POOLS.Stake[G.GAME.stake].key
        if not current_stake_key or not SMODS or not SMODS.build_stake_chain then return orig_SMODS_current_stake() end
        
        local stake_chain = SMODS.build_stake_chain(G.P_STAKES[current_stake_key])
        local applied_stakes = {}
        for i, v in ipairs(G.P_CENTER_POOLS.Stake) do
            if stake_chain[i] and v.key ~= current_stake_key then
                applied_stakes[#applied_stakes+1] = v.key
            end
        end
        applied_stakes[#applied_stakes+1] = current_stake_key

        local has_big = false
        for _, k in ipairs(applied_stakes) do
            if k == 'stake_reality_warp_big' or k == 'big' or k == 'stake_big' then
                has_big = true
                break
            end
        end

        if not has_big then
            return orig_SMODS_current_stake()
        end

        local stakes = {}
        local applied_stake
        for i, key in ipairs(applied_stakes) do
            local _stake_center = G.P_STAKES[key]
            local order = _stake_center.order
            local _stake_desc = {}
            if _stake_center then
                local t, res = {}, {}
                if _stake_center.loc_vars and type(_stake_center.loc_vars) == 'function' then
                    res = _stake_center:loc_vars({}) or {}
                end
                t.vars = res.vars or {}
                t.key = res.key or _stake_center.key
                t.set = res.set or _stake_center.set
                localize{type = 'descriptions', key = t.key, set = t.set, nodes = _stake_desc, vars = t.vars}
                if _stake_center.applied_stakes and #_stake_center.applied_stakes > 0 then _stake_desc[#_stake_desc] = nil end
            end
            local stake_sprite = get_stake_sprite(order, 0.8)

            local stake_node = {n=G.UIT.R, config={align = "cl", padding = 0.06, minw = 7.7}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.1, minw = 1.3, r=true, colour=G.C.BLACK}, nodes={
                    {n=G.UIT.O, config={object = stake_sprite}}
                }},
                {n=G.UIT.C, config={align='cm'}, nodes = {
                    {n=G.UIT.C, config={align = "cm", padding = 0.05, colour = get_stake_col(order), r = 0.05, stretch = true, diff = i < #applied_stakes and 1.3 or 2.4}, nodes={
                        {n=G.UIT.R, config={align = "cm", padding = 0.05, colour = adjust_alpha(G.C.WHITE, 0.95), r = 0.05, minw = 5.9, stretch = true, diff = i < #applied_stakes and 1.4 or 2.5}, nodes={
                            {n=G.UIT.R, config={align = "cm", padding = 0.03, minh = 0.7, minw = 4.1}, nodes={transparent_multiline_text(_stake_desc)}}
                        }}
                    }}
                }},
                {n=G.UIT.C, config={minw = 0.15}}
            }}
            if i < #applied_stakes then
                table.insert(stakes, 1, stake_node)
            else
                applied_stake = stake_node
            end
        end

        local box = SMODS.UIScrollBox({
            content = {
                definition = {n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR, minw = 7.7 }, nodes = stakes},
                config = { align = "cm" },
            },
            overflow = {node_config = {maxh = 4.7}},
            sync_mode = "offset",
        })
        local current_col = {
            {n=G.UIT.C, config = {align='tl', r=true, colour=G.C.BLACK, padding = 0.08, minw = 7.9}, nodes = {
                applied_stake,
                {n=G.UIT.R, config = {minh = 0.05, colour = G.C.L_BLACK}},
                {n=G.UIT.R, nodes = {{n=G.UIT.O, config = { object = box }}}}
            }}
        }
        if box then
            local bar = SMODS.GUI.scrollbar({
                h = 6,
                w = 0.3,
                knob_h = 0.8,
                colour = G.C.RED,
                bg_colour = { 0, 0, 0, 0.15 },
                scroll_collision_obj = box,
                scroll_mult = 1.6,
            })
            bar.config.align = "tm"
            table.insert(current_col, bar)
        end
        
        return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, r = 0.1, padding = 0.1}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
                {n=G.UIT.T, config={text = 'Applied stakes', scale = 0.65, colour = G.C.WHITE}}
            }},
            {n=G.UIT.R, config = {align = 'cm', padding = 0.2}, nodes = current_col}
        }}
    end
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


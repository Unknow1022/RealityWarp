SMODS.Atlas {
    key = "secret_jokers",
    path = "secret_jokers.png",
    px = 71,
    py = 95
}
G.C.PINK = G.C.PINK or HEX('ec4899')
local function register_secret_joker(def)
    def.rarity = def.rarity or 4
    def.is_secret = true
    def.unlocked = (def.unlocked == nil and true) or def.unlocked
    def.soul_pos = def.soul_pos or { x = 1, y = (def.pos and def.pos.y) or 0 }
    def.cost = def.cost or 20
    def.in_pool = def.in_pool or function(self, args)
        return false, { allow_duplicates = false }
    end
    def.set_card_type_badge = def.set_card_type_badge or function(self, card, badges)
        badges[1] = create_badge('Outsider', HEX('000000'), G.C.WHITE, 1.2)
    end
    def.set_badges = def.set_badges or function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Outsider', HEX('000000'), G.C.WHITE, 1.2)
        end
    end
    local orig_add = def.add_to_deck
    def.add_to_deck = function(self, card, from_debuff)
        if botg_trigger_mod_achievement then
            botg_trigger_mod_achievement('forbidden_craft')
        end
        if orig_add then return orig_add(self, card, from_debuff) end
    end
    return SMODS.Joker(def)
end

local SECRET_JOKER_PALETTES = {
    ['esteban']                     = { HEX('646464'), HEX('909090'), HEX('c0c0c0'), HEX('ffffff'), HEX('303030') },
    ['thiago']                      = { HEX('a1a0ff'), HEX('c0c0ff'), HEX('4948c8'), HEX('162ca2'), HEX('ffffff') },
    ['black_hole_joker']            = { HEX('ff6b00'), HEX('ff9d56'), HEX('424242'), HEX('1e1f88'), HEX('ffffff') },
    ['squele']                      = { HEX('ff2400'), HEX('ffffff'), HEX('291e1e'), HEX('e8413e'), HEX('000000') },
    ['bluxdir']                     = { HEX('00df00'), HEX('00be00'), HEX('016400'), HEX('b6fe6c'), HEX('ffffff') },
    ['charles']                     = { HEX('f40000'), HEX('a90000'), HEX('ee0000'), HEX('ff2a00'), HEX('ffffff') },
    ['mochi']                       = { HEX('c400ca'), HEX('e100ca'), HEX('ffe22b'), HEX('82ebff'), HEX('ffffff') },
    ['helin']                       = { HEX('8d60b5'), HEX('00ff3d'), HEX('bababa'), HEX('3c3c3c'), HEX('ffffff') },
    ['raytracing']                  = { HEX('7093cf'), HEX('e0ac54'), HEX('606060'), HEX('415d8d'), HEX('ffffff') },
    ['paco']                        = { HEX('ebb746'), HEX('fefe46'), HEX('ffd16d'), HEX('ff0005'), HEX('ffffff') },
    ['yairo']                       = { HEX('6c93c5'), HEX('8fb6e8'), HEX('3506d5'), HEX('ff91ed'), HEX('ffffff') },
    ['kyra']                        = { HEX('69e8f6'), HEX('292d2f'), HEX('363636'), HEX('00e5ff'), HEX('ffffff') },
    ['brainprint']                  = { HEX('4b69cf'), HEX('7d93e2'), HEX('c6d2fc'), HEX('f9edd3'), HEX('ffffff') },
    ['vampiric_midas']              = { HEX('fee25d'), HEX('ffcc7e'), HEX('af823c'), HEX('e8413e'), HEX('ffffff') },
    ['certified_programming']       = { HEX('60a356'), HEX('80ff01'), HEX('b6fe6c'), HEX('404040'), HEX('ffd700') },
    ['galactic_traveler']           = { HEX('3d4b74'), HEX('415b89'), HEX('fadc34'), HEX('fede2e'), HEX('ffffff') },
    ['colorful_street']             = { HEX('27773c'), HEX('6ea43e'), HEX('75648b'), HEX('fadc34'), HEX('ffffff') },
    ['astra']                       = { HEX('d488f2'), HEX('e7acff'), HEX('bf73dd'), HEX('873ba5'), HEX('ffffff') },
    ['marie']                       = { HEX('3afb41'), HEX('9effa1'), HEX('65ff57'), HEX('ffda61'), HEX('ffffff') },
    ['callie']                      = { HEX('ff4dca'), HEX('ff77dd'), HEX('ff3efc'), HEX('ffda61'), HEX('ffffff') },
    ['sally']                       = { HEX('e8413e'), HEX('e85f5c'), HEX('ff0000'), HEX('8c000c'), HEX('ffffff') },
    ['mime_king']                   = { HEX('e8463d'), HEX('fa4c3a'), HEX('edf1f8'), HEX('ffd700'), HEX('ffffff') },
    ['photo_album']                 = { HEX('926e3b'), HEX('fd5f55'), HEX('fbf1e1'), HEX('4f6367'), HEX('ffffff') },
    ['pirate_egg']                  = { HEX('fddd30'), HEX('fda200'), HEX('4f6367'), HEX('bfc7d5'), HEX('ffffff') },
    ['reinforced_boots']            = { HEX('ffe682'), HEX('f7e07c'), HEX('dbb83e'), HEX('caad3b'), HEX('ffffff') },
    ['wee_comedian']                = { HEX('69e8f6'), HEX('009cfd'), HEX('26acff'), HEX('cd2f25'), HEX('ffffff') },
    ['golden_lucky_cat']            = { HEX('fac15e'), HEX('ffc360'), HEX('fb2700'), HEX('fbf5ea'), HEX('ffffff') },
    ['unrecognizable_antique']      = { HEX('6a9068'), HEX('82b171'), HEX('dbf574'), HEX('e7d3bc'), HEX('4f6367') },
    ['macabre_emoji']               = { HEX('b54d25'), HEX('9c2d06'), HEX('ff0f00'), HEX('ff6b00'), HEX('ffffff') },
    ['marina']                      = { HEX('28d2dc'), HEX('6eebf5'), HEX('1c7d86'), HEX('102830'), HEX('ffffff') },
    ['perla']                       = { HEX('f5b9d2'), HEX('ffdc82'), HEX('e2aac1'), HEX('926a7b'), HEX('ffffff') },
    ['espectro_del_balance']        = { HEX('a06ef0'), HEX('d2aaff'), HEX('9365dd'), HEX('604092'), HEX('ffffff') },
    ['balance_spectre']             = { HEX('a06ef0'), HEX('d2aaff'), HEX('9365dd'), HEX('604092'), HEX('ffffff') },
    ['midas_vampirico']             = { HEX('fee25d'), HEX('ffcc7e'), HEX('af823c'), HEX('e8413e'), HEX('ffffff') },
    ['programacion_certificacion']  = { HEX('60a356'), HEX('80ff01'), HEX('b6fe6c'), HEX('404040'), HEX('ffd700') },
    ['viajero_galactico']           = { HEX('3d4b74'), HEX('415b89'), HEX('fadc34'), HEX('fede2e'), HEX('ffffff') },
    ['calle_colorida']              = { HEX('27773c'), HEX('6ea43e'), HEX('75648b'), HEX('fadc34'), HEX('ffffff') },
    ['rey_de_mimos']                = { HEX('e8463d'), HEX('fa4c3a'), HEX('edf1f8'), HEX('ffd700'), HEX('ffffff') },
    ['album_de_fotos']              = { HEX('926e3b'), HEX('fd5f55'), HEX('fbf1e1'), HEX('4f6367'), HEX('ffffff') },
    ['huevo_pirata']                = { HEX('fddd30'), HEX('fda200'), HEX('4f6367'), HEX('bfc7d5'), HEX('ffffff') },
    ['botas_reforzadas']            = { HEX('ffe682'), HEX('f7e07c'), HEX('dbb83e'), HEX('caad3b'), HEX('ffffff') },
    ['gato_dorado_suerte']          = { HEX('fac15e'), HEX('ffc360'), HEX('fb2700'), HEX('fbf5ea'), HEX('ffffff') },
    ['antiguedad_irreconocible']    = { HEX('6a9068'), HEX('82b171'), HEX('dbf574'), HEX('e7d3bc'), HEX('4f6367') },
    ['emoji_macabro']               = { HEX('b54d25'), HEX('9c2d06'), HEX('ff0f00'), HEX('ff6b00'), HEX('ffffff') },
    ['mad_ghost']                   = { HEX('9333ea'), HEX('c8a9d1'), HEX('a78ebb'), HEX('e8c7e8'), HEX('ffffff') },
    ['mew_mew']                     = { HEX('ec4899'), HEX('f76d92'), HEX('fb82a1'), HEX('f7f1e4'), HEX('ffffff') },
}

local function get_secret_palette(card, center)
    local key = (center and (center.key or center.name)) or (card and get_card_key and get_card_key(card)) or ''
    key = string.lower(tostring(key))
    local clean_key = key:gsub('^j_reality_warp_', ''):gsub('^j_', '')
    if SECRET_JOKER_PALETTES[clean_key] then
        return SECRET_JOKER_PALETTES[clean_key]
    end
    for k, palette in pairs(SECRET_JOKER_PALETTES) do
        if string.find(key, k, 1, true) then
            return palette
        end
    end
    if string.find(key, 'black_hole', 1, true) then return SECRET_JOKER_PALETTES['black_hole_joker'] end
    if string.find(key, 'astra', 1, true) then return SECRET_JOKER_PALETTES['astra'] end
    if string.find(key, 'marie', 1, true) then return SECRET_JOKER_PALETTES['marie'] end
    if string.find(key, 'callie', 1, true) then return SECRET_JOKER_PALETTES['callie'] end
    if string.find(key, 'sally', 1, true) then return SECRET_JOKER_PALETTES['sally'] end
    if string.find(key, 'programacion', 1, true) or string.find(key, 'certificacion', 1, true) or string.find(key, 'certified', 1, true) or string.find(key, 'programming', 1, true) then return SECRET_JOKER_PALETTES['certified_programming'] end
    if string.find(key, 'viajero', 1, true) or string.find(key, 'galactico', 1, true) or string.find(key, 'galactic', 1, true) or string.find(key, 'traveler', 1, true) then return SECRET_JOKER_PALETTES['galactic_traveler'] end
    if string.find(key, 'calle', 1, true) or string.find(key, 'colorida', 1, true) or string.find(key, 'colorful', 1, true) or string.find(key, 'street', 1, true) then return SECRET_JOKER_PALETTES['colorful_street'] end
    if string.find(key, 'midas', 1, true) or string.find(key, 'vampirico', 1, true) or string.find(key, 'vampiric', 1, true) then return SECRET_JOKER_PALETTES['vampiric_midas'] end
    if string.find(key, 'mime', 1, true) or string.find(key, 'mimo', 1, true) then return SECRET_JOKER_PALETTES['mime_king'] end
    if string.find(key, 'photo', 1, true) or string.find(key, 'album', 1, true) or string.find(key, 'foto', 1, true) then return SECRET_JOKER_PALETTES['photo_album'] end
    if string.find(key, 'egg', 1, true) or string.find(key, 'huevo', 1, true) or string.find(key, 'pirat', 1, true) then return SECRET_JOKER_PALETTES['pirate_egg'] end
    if string.find(key, 'boot', 1, true) or string.find(key, 'bota', 1, true) then return SECRET_JOKER_PALETTES['reinforced_boots'] end
    if string.find(key, 'wee', 1, true) or string.find(key, 'comedian', 1, true) then return SECRET_JOKER_PALETTES['wee_comedian'] end
    if string.find(key, 'lucky_cat', 1, true) or string.find(key, 'gato', 1, true) then return SECRET_JOKER_PALETTES['golden_lucky_cat'] end
    if string.find(key, 'antique', 1, true) or string.find(key, 'antiguedad', 1, true) then return SECRET_JOKER_PALETTES['unrecognizable_antique'] end
    if string.find(key, 'emoji', 1, true) or string.find(key, 'macabre', 1, true) or string.find(key, 'macabro', 1, true) then return SECRET_JOKER_PALETTES['macabre_emoji'] end
    if string.find(key, 'marina', 1, true) then return SECRET_JOKER_PALETTES['marina'] end
    if string.find(key, 'perla', 1, true) then return SECRET_JOKER_PALETTES['perla'] end
    if string.find(key, 'balance', 1, true) or string.find(key, 'espectro', 1, true) then return SECRET_JOKER_PALETTES['espectro_del_balance'] end
    if string.find(key, 'mad_ghost', 1, true) then return SECRET_JOKER_PALETTES['mad_ghost'] end
    if string.find(key, 'mew_mew', 1, true) then return SECRET_JOKER_PALETTES['mew_mew'] end
    if (center and (center.is_amalgam or center.rarity == 'Amalgam')) or (card and is_amalgam_card and is_amalgam_card(card)) then
        return { HEX('8a2be2'), HEX('bf55ec'), HEX('00ffff'), HEX('ffffff') }
    end
    return { HEX('d4af37'), HEX('ffffff'), HEX('ff4500'), HEX('00e5ff') }
end

local function add_secret_particles(card, center)
    if not card or not (card.VT or card.T) then return end
    if card.children and card.children.secret_particles then
        card.children.secret_particles:remove()
        card.children.secret_particles = nil
    end

    local palette = get_secret_palette(card, center)
    local p = Particles(0, 0, 0, 0, {
        timer = 0.08,
        scale = 0.16,
        speed = 0.55,
        lifespan = 1.6,
        attach = card,
        colours = palette,
        fill = true,
        padding = 0,
        vel_variation = 0.5,
        initialize = true,
    })
    p.custom_draw = true
    card.children.secret_particles = p
end

SMODS.DrawStep {
    key = 'secret_particles',
    order = 65,
    func = function(self)
        if self.children and self.children.secret_particles and (self.config.center.discovered or self.bypass_discovery_center) then
            self.children.secret_particles:draw()
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

local function draw_mad_ghost_companion(self, is_front)
    local c = self.config and self.config.center
    if not (c and (c.key == 'j_reality_warp_mew_mew' or c.key == 'mew_mew')) then return end

    if not self.children.mad_ghost_card or not self.children.mad_ghost_soul then
        local atlas = (SMODS and SMODS.get_atlas and (SMODS.get_atlas('reality_warp_secret_jokers') or SMODS.get_atlas('secret_jokers')))
            or (G.ASSET_ATLAS and (G.ASSET_ATLAS['reality_warp_secret_jokers'] or G.ASSET_ATLAS['secret_jokers']))
        if atlas then
            if not self.children.mad_ghost_card then
                self.children.mad_ghost_card = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, atlas, { x = 2, y = 15 })
                self.children.mad_ghost_card.role.draw_major = self
                self.children.mad_ghost_card.states.hover.can = false
                self.children.mad_ghost_card.states.click.can = false
            end
            if not self.children.mad_ghost_soul then
                self.children.mad_ghost_soul = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, atlas, { x = 3, y = 15 })
                self.children.mad_ghost_soul.role.draw_major = self
                self.children.mad_ghost_soul.states.hover.can = false
                self.children.mad_ghost_soul.states.click.can = false
            end
        end
    end

    local t = ((G.TIMERS and G.TIMERS.REAL) or 0) * 1.2
    local z = math.cos(t)
    if is_front and z < 0 then return end
    if not is_front and z >= 0 then return end

    local float_x = 1.95 * math.sin(t)
    local float_y = -0.20 + 0.85 * math.sin(2 * t)
    local scale_mod = -0.38 + 0.12 * z
    local rotate_mod = 0.14 * math.cos(t)

    local prev_overlay = G.BRUTE_OVERLAY
    G.BRUTE_OVERLAY = { 1, 1, 1, 0.25 }
    local sh = G.SHADERS and (G.SHADERS['reality_warp_neon_grid'] or G.SHADERS['neon_grid'])
    local sh_name = sh and (G.SHADERS['reality_warp_neon_grid'] and 'reality_warp_neon_grid' or 'neon_grid')
    if sh and not G.SHADERS['neon_grid'] then G.SHADERS['neon_grid'] = sh end
    if sh then
        pcall(function()
            if sh:hasUniform('time') then
                sh:send('time', (G.TIMERS and G.TIMERS.REAL) or (love.timer and love.timer.getTime()) or 0)
            end
        end)
    end
    if self.children.mad_ghost_card then
        pcall(function()
            if sh_name then
                self.children.mad_ghost_card:draw_shader(sh_name, nil, self.ARGS and self.ARGS.send_to_shader or { 0, 0 }, nil, self.children.center, scale_mod, rotate_mod, float_x, float_y)
            else
                self.children.mad_ghost_card:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod, float_x, float_y)
            end
        end)
    end
    if self.children.mad_ghost_soul then
        pcall(function()
            if sh_name then
                self.children.mad_ghost_soul:draw_shader(sh_name, nil, self.ARGS and self.ARGS.send_to_shader or { 0, 0 }, nil, self.children.center, scale_mod, rotate_mod, float_x, float_y)
            else
                self.children.mad_ghost_soul:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod, float_x, float_y)
            end
        end)
    end
    G.BRUTE_OVERLAY = prev_overlay
end

SMODS.DrawStep {
    key = 'mew_mew_mad_ghost_behind',
    order = -15,
    func = function(self)
        draw_mad_ghost_companion(self, false)
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'mew_mew_mad_ghost_in_front',
    order = 65,
    func = function(self)
        draw_mad_ghost_companion(self, true)
    end,
    conditions = { vortex = false, facing = 'front' },
}

if SMODS and SMODS.Shader and not (SMODS.Shaders and (SMODS.Shaders['neon_grid'] or SMODS.Shaders['reality_warp_neon_grid'])) then
    SMODS.Shader {
        key = 'neon_grid',
        path = 'neon_grid.fs'
    }
end

SMODS.DrawStep {
    key = 'mew_mew_mad_ghost_shader',
    order = 21,
    func = function(self)
        local c = self.config and self.config.center
        if not c then return end
        local k = c.key
        if k == 'j_reality_warp_mew_mew' or k == 'mew_mew'
        or k == 'j_reality_warp_mad_ghost' or k == 'mad_ghost' then
            local sh = G.SHADERS and (G.SHADERS['reality_warp_neon_grid'] or G.SHADERS['neon_grid'])
            if sh then
                if not G.SHADERS['neon_grid'] then G.SHADERS['neon_grid'] = sh end
                local t = (G.TIMERS and G.TIMERS.REAL) or (love.timer and love.timer.getTime()) or 0
                pcall(function()
                    if sh:hasUniform('time') then
                        sh:send('time', t)
                    end
                end)
                local sh_name = G.SHADERS['reality_warp_neon_grid'] and 'reality_warp_neon_grid' or 'neon_grid'
                if self.children and self.children.center then
                    self.children.center:draw_shader(sh_name, nil, self.ARGS.send_to_shader)
                end
                if self.children and self.children.floating_sprite then
                    local scale_mod = 0.05 + 0.03 * math.sin(1.8 * t)
                    local rotate_mod = 0.02 * math.cos(1.2 * t)
                    self.children.floating_sprite:draw_shader(sh_name, nil, self.ARGS.send_to_shader, nil, self.children.center, scale_mod, rotate_mod)
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

if Game and Game.update then
    local orig_game_update_neon = Game.update
    function Game:update(dt)
        orig_game_update_neon(self, dt)
        local sh = G.SHADERS and (G.SHADERS['reality_warp_neon_grid'] or G.SHADERS['neon_grid'])
        if sh then
            if not G.SHADERS['neon_grid'] then G.SHADERS['neon_grid'] = sh end
            pcall(function()
                if sh:hasUniform('time') then
                    sh:send('time', (G.TIMERS and G.TIMERS.REAL) or (love.timer and love.timer.getTime()) or 0)
                end
            end)
        end
    end
end

if SMODS.draw_ignore_keys then
    SMODS.draw_ignore_keys.secret_particles = true
    SMODS.draw_ignore_keys.mad_ghost_sprite = true
    SMODS.draw_ignore_keys.mad_ghost_card = true
    SMODS.draw_ignore_keys.mad_ghost_soul = true
end

local orig_card_set_sprites = Card.set_sprites
function Card:set_sprites(_center, _front)
    orig_card_set_sprites(self, _center, _front)
    if self.children and self.children.secret_particles then
        self.children.secret_particles:remove()
        self.children.secret_particles = nil
    end
    local c = _center or self.config.center
    if self.children and not (c and (c.key == 'j_reality_warp_mew_mew' or c.key == 'mew_mew')) then
        if self.children.mad_ghost_card then
            self.children.mad_ghost_card:remove()
            self.children.mad_ghost_card = nil
        end
        if self.children.mad_ghost_soul then
            self.children.mad_ghost_soul:remove()
            self.children.mad_ghost_soul = nil
        end
        if self.children.mad_ghost_sprite then
            self.children.mad_ghost_sprite:remove()
            self.children.mad_ghost_sprite = nil
        end
    end
    if c and (c.key == 'j_reality_warp_mew_mew' or c.key == 'mew_mew') then
        local atlas = (SMODS and SMODS.get_atlas and (SMODS.get_atlas('reality_warp_secret_jokers') or SMODS.get_atlas('secret_jokers')))
            or (G.ASSET_ATLAS and (G.ASSET_ATLAS['reality_warp_secret_jokers'] or G.ASSET_ATLAS['secret_jokers']))
        if atlas then
            if not self.children.mad_ghost_card then
                self.children.mad_ghost_card = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, atlas, { x = 2, y = 15 })
                self.children.mad_ghost_card.role.draw_major = self
                self.children.mad_ghost_card.states.hover.can = false
                self.children.mad_ghost_card.states.click.can = false
            end
            if not self.children.mad_ghost_soul then
                self.children.mad_ghost_soul = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, atlas, { x = 3, y = 15 })
                self.children.mad_ghost_soul.role.draw_major = self
                self.children.mad_ghost_soul.states.hover.can = false
                self.children.mad_ghost_soul.states.click.can = false
            end
        end
    end
    if c and (c.is_secret or c.is_amalgam or (is_secret_card and is_secret_card(self)) or (is_amalgam_card and is_amalgam_card(self))) then
        add_secret_particles(self, c)
    end
end

local orig_card_remove = Card.remove
function Card:remove()
    if self.children and self.children.secret_particles then
        self.children.secret_particles:remove()
        self.children.secret_particles = nil
    end
    if self.children and self.children.mad_ghost_card then
        self.children.mad_ghost_card:remove()
        self.children.mad_ghost_card = nil
    end
    if self.children and self.children.mad_ghost_soul then
        self.children.mad_ghost_soul:remove()
        self.children.mad_ghost_soul = nil
    end
    if self.children and self.children.mad_ghost_sprite then
        self.children.mad_ghost_sprite:remove()
        self.children.mad_ghost_sprite = nil
    end
    return orig_card_remove(self)
end

register_secret_joker {
    key = 'esteban',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Esteban',
        text = {
            "Played {C:spades}Spades{} and {C:clubs}Clubs{}",
            "give {X:mult,C:white}X#1#{} Mult when scored"
        }
    },
    config = { extra = { xmult = 2.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 2.5
        return { vars = { xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Spades') or context.other_card:is_suit('Clubs') then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2.5,
                    card = card
                }
            end
        end
    end
}

register_secret_joker {
    key = 'thiago',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'Thiago',
        text = {
            "Gives {X:mult,C:white}+X1{} Mult for every",
            "{C:chips}#1# Chips{} scored in hand"
        }
    },
    config = { extra = { chips_per_xmult = 20 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local chips_req = (card and card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or (self.config and self.config.extra and self.config.extra.chips_per_xmult) or 20
        return { vars = { chips_req } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local current_chips = (hand_chips and hand_chips > 0 and hand_chips) or (context.chips and context.chips > 0 and context.chips) or 0
            local chips_req = (card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or 20
            local xmult = math.floor(current_chips / chips_req)
            if xmult > 1 then
                return {
                    Xmult = xmult,
                    card = card
                }
            end
        end
    end
}

register_secret_joker {
    key = 'black_hole_joker',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'Black Hole',
        text = {
            "Raises final {C:chips}Chips{} and",
            "{C:mult}Mult{} to the power of {C:attention}^#1#{}"
        }
    },
    config = { extra = { pow = 1.2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local pow = (card and card.ability and card.ability.extra and card.ability.extra.pow) or (self.config and self.config.extra and self.config.extra.pow) or 1.2
        return { vars = { pow } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local pow = (card.ability and card.ability.extra and card.ability.extra.pow) or 1.2

            if hand_chips and hand_chips > 1 then
                hand_chips = math.floor(hand_chips ^ pow)
            end
            if mult and mult > 1 then
                mult = math.floor(mult ^ pow)
            end

            update_hand_text({ sound = 'chips2', modded = true }, { chips = hand_chips, mult = mult })

            return {
                message = '^' .. tostring(pow) .. '!',
                colour = G.C.DARK_EDITION,
                card = card
            }
        end
    end
}

register_secret_joker {
    key = 'squele',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
    loc_txt = {
        name = 'Squele',
        text = {
            "Played {C:hearts}Hearts{} give {C:mult}+#1#{} Mult",
            "and {X:mult,C:white}X#2#{} Mult when scored.",
            "{C:green}#3# in #4#{} chance to create a",
            "{C:dark_edition}Negative{} {C:attention}Bloodstone{}"
        }
    },
    config = { extra = { mult = 10, xmult = 1.5, odds = 8 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        if info_queue and G.P_CENTERS then
            if G.P_CENTERS.j_bloodstone then table.insert(info_queue, G.P_CENTERS.j_bloodstone) end
            if G.P_CENTERS.e_negative then table.insert(info_queue, G.P_CENTERS.e_negative) end
        end
        local mult = (card and card.ability and card.ability.extra and card.ability.extra.mult) or (self.config and self.config.extra and self.config.extra.mult) or 10
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 1.5
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or (self.config and self.config.extra and self.config.extra.odds) or 8
        local num, den = SMODS.get_probability_vars(card, 1, odds, 'squele_project')
        return { vars = { mult, xmult, num, den } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Hearts') then
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 8
            local does_project = SMODS.pseudorandom_probability(card, 'squele_project', 1, odds)

            if does_project and not context.blueprint and G.jokers then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_j = SMODS.add_card { key = 'j_bloodstone', edition = 'e_negative', key_append = 'squele' }
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Negative Bloodstone!', colour = G.C.DARK_EDITION })
                        return true
                    end
                }))
            end

            return {
                mult = card.ability.extra.mult,
                x_mult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

register_secret_joker {
    key = 'bluxdir',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 4 },
    soul_pos = { x = 1, y = 4 },
    loc_txt = {
        name = 'Bluxdir',
        text = {
            "All {C:attention}Booster Packs{}",
            "are {C:money}free{}"
        }
    },
    config = {},
    blueprint_compat = false,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.bluxdir_free_boosters = true
        if G.shop_booster and G.shop_booster.cards then
            for _, b in ipairs(G.shop_booster.cards) do
                b.cost = 0
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bluxdir_free_boosters = nil
        if G.shop_booster and G.shop_booster.cards then
            for _, b in ipairs(G.shop_booster.cards) do
                if b.set_cost then b:set_cost() end
            end
        end
    end,
    calculate = function(self, card, context)
    end
}

register_secret_joker {
    key = 'charles',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 5 },
    soul_pos = { x = 1, y = 5 },
    loc_txt = {
        name = 'Charles',
        text = {
            "Earn {C:money}$#2#{} for each scored card.",
            "Played {C:spades}Spades{} and {C:hearts}Hearts{}",
            "give {X:mult,C:white}X#1#{} Mult when scored"
        }
    },
    config = { extra = { xmult = 2, dollars = 5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or (self.config and self.config.extra and self.config.extra.xmult) or 2
        local dollars = (card and card.ability and card.ability.extra and card.ability.extra.dollars) or (self.config and self.config.extra and self.config.extra.dollars) or 5
        return { vars = { xmult, dollars } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if has_charles_and_mochi() then
                return {
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            if has_charles_and_mochi() then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        card:juice_up(0.8, 0.8)
                        return true
                    end
                }))
            end
        end

        if context.individual and context.cardarea == G.play then
            local dollars = (card.ability and card.ability.extra and card.ability.extra.dollars) or 5
            local gives_xmult = context.other_card:is_suit('Spades') or context.other_card:is_suit('Hearts')
            local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2

            if gives_xmult then
                return {
                    x_mult = xmult,
                    dollars = dollars,
                    card = card
                }
            else
                return {
                    dollars = dollars,
                    card = card
                }
            end
        end
    end
}

register_secret_joker {
    key = 'mochi',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 6 },
    soul_pos = { x = 1, y = 6 },
    loc_txt = {
        name = 'Mochi',
        text = {
            "Scored cards become {C:attention}Wild Cards{}.",
            "Gives {X:mult,C:white}+X#1#{} Mult for each",
            "{C:attention}Wild Card{} in your full deck",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult_gain = (card and card.ability and card.ability.extra and card.ability.extra.xmult_gain) or (self.config and self.config.extra and self.config.extra.xmult_gain) or 0.25
        local wild_count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if is_wild_card(pcard) then
                    wild_count = wild_count + 1
                end
            end
        end
        local current_xmult = 1.0 + (wild_count * xmult_gain)
        return { vars = { xmult_gain, current_xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card.config and context.other_card.config.center ~= G.P_CENTERS.m_wild then
                context.other_card:set_ability(G.P_CENTERS.m_wild)
                context.other_card:juice_up()
            end
        end

        if context.joker_main then
            local wild_count = 0
            if G.playing_cards then
                for _, pcard in ipairs(G.playing_cards) do
                    if is_wild_card(pcard) then
                        wild_count = wild_count + 1
                    end
                end
            end
            local xmult_gain = (card.ability and card.ability.extra and card.ability.extra.xmult_gain) or 0.25
            local total_xmult = 1.0 + (wild_count * xmult_gain)
            if total_xmult > 1 then
                return {
                    Xmult = total_xmult
                }
            end
        end
    end
}

register_secret_joker {
    key = 'helin',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 7 },
    soul_pos = { x = 1, y = 7 },
    loc_txt = {
        name = 'Helin',
        text = {
            "Raises {C:mult}Mult{} to the power",
            "of {X:mult,C:white}^#1#{} at end of scoring"
        }
    },
    config = { extra = { power = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local power = (card and card.ability and card.ability.extra and card.ability.extra.power) or (self.config and self.config.extra and self.config.extra.power) or 2
        return { vars = { power } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local pow = (card.ability and card.ability.extra and card.ability.extra.power) or 2
            if to_big or (Talisman and Talisman.config_file) then
                return {
                    e_mult = pow,
                    card = card
                }
            elseif SMODS.Scoring_Parameters and SMODS.Scoring_Parameters.mult then
                local mult_param = SMODS.Scoring_Parameters.mult
                local cur = mult_param.current
                if cur and (type(cur) == 'table' or cur >= 1) then
                    local target = type(cur) == 'table' and (cur ^ pow) or math.floor(cur ^ pow)
                    mult_param:modify(target - cur)
                    return {
                        message = '^' .. tostring(pow) .. ' Mult!',
                        colour = G.C.DARK_EDITION,
                        card = card
                    }
                end
            else
                return {
                    e_mult = pow,
                    message = '^' .. tostring(pow) .. ' Mult!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}

register_secret_joker {
    key = 'raytracing',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 8 },
    soul_pos = { x = 1, y = 8 },
    loc_txt = {
        name = 'RayTracing',
        text = {
            "Creates {C:attention}2{} random {C:dark_edition}Negative{}",
            "{C:spectral}Spectral{} cards at end of round"
        }
    },
    config = {},
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local spectral_cards = {}
                    if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Spectral'] then
                        for _, center in ipairs(G.P_CENTER_POOLS['Spectral']) do
                            table.insert(spectral_cards, center.key)
                        end
                    end
                    for i = 1, 2 do
                        local chosen_spectral = (#spectral_cards > 0) and pseudorandom_element(spectral_cards, 'raytracing_spectral') or 'c_ankh'
                        SMODS.add_card { key = chosen_spectral, edition = 'e_negative', key_append = 'raytracing' }
                    end
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+2 Negative Spectrals!', colour = G.C.DARK_EDITION })
                    card:juice_up(0.6, 0.6)
                    return true
                end
            }))
        end
    end
}

register_secret_joker {
    key = 'paco',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 9 },
    soul_pos = { x = 1, y = 9 },
    loc_txt = {
        name = 'Paco',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult for each",
            "remaining {C:attention}discard{}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_per_discard = 3 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local xmult_per_discard = (card and card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or (self.config and self.config.extra and self.config.extra.xmult_per_discard) or 3
        local total_xmult = math.max(1, discards * xmult_per_discard)
        return { vars = { xmult_per_discard, total_xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            local xmult_per_discard = (card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or 3
            local total_xmult = discards * xmult_per_discard
            if total_xmult > 1 then
                return {
                    Xmult = total_xmult
                }
            end
        end
    end
}

register_secret_joker {
    key = 'yairo',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 10 },
    soul_pos = { x = 1, y = 10 },
    loc_txt = {
        name = 'Yairo',
        text = {
            "Played {C:attention}6s{} and {C:attention}7s{} give",
            "{X:mult,C:white}X#1#{} Mult and {X:chips,C:white}X#2#{} Chips",
            "when scored"
        }
    },
    config = { extra = { xmult = 3, xchips = 1.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 3, ex.xchips or 1.5 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = (context.other_card.get_id and context.other_card:get_id()) or (context.other_card.base and context.other_card.base.id)
            local val = context.other_card.base and context.other_card.base.value
            if id == 6 or id == 7 or val == '6' or val == '7' then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3,
                    x_chips = (card.ability and card.ability.extra and card.ability.extra.xchips) or 1.5,
                    card = card
                }
            end
        end
    end
}

register_secret_joker {
    key = 'kyra',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 11 },
    soul_pos = { x = 1, y = 11 },
    loc_txt = {
        name = 'Kyra',
        text = {
            "{C:attention}Potions{} don't take consumable space.",
            "Click button and pay {C:money}$#1#{}",
            "to brew a random {C:attention}Potion{}."
        }
    },
    config = { extra = { cost = 2 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local cost = (card and card.ability and card.ability.extra and card.ability.extra.cost) or (self.config and self.config.extra and self.config.extra.cost) or 2
        return { vars = { cost } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card:juice_up(0.3, 0.4)
        end
    end
}

G.FUNCS = G.FUNCS or {}

G.FUNCS.can_pay_kyra = function(e)
    local card = e.config.ref_table
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= 2 and not (card and card.debuff) and not (G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT) then
        e.config.colour = G.C.GOLD
        e.config.button = 'pay_kyra'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.pay_kyra = function(e)
    local card = e.config.ref_table
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= 2 and G.consumeables then
        ease_dollars(-2)
        play_sound('coin3')
        if card then card:juice_up(0.6, 0.6) end
        G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            func = function()
                local new_potion = SMODS.add_card {
                    set = 'Potion',
                    area = G.consumeables,
                    key_append = 'kyra'
                }
                if not new_potion or not new_potion.config then
                    new_potion = SMODS.add_card {
                        set = 'Spectral',
                        area = G.consumeables,
                        key_append = 'kyra_fallback'
                    }
                end
                G.GAME.consumeable_buffer = math.max(0, (G.GAME.consumeable_buffer or 1) - 1)
                if new_potion then
                    new_potion:juice_up(0.6, 0.6)
                end
                card_eval_status_text(card or new_potion, 'extra', nil, nil, nil, { message = '+Potion', colour = G.C.GREEN })
                if botg_trigger_mod_achievement then
                    botg_trigger_mod_achievement('underworld_syndicate')
                end
                return true
            end
        }))
    end
end

function get_marina_debuff_cost(card)
    if card and card.ability and card.ability.set == 'Joker' then
        return 5
    end
    return 1
end

local orig_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local t = orig_use_and_sell_buttons(card)
    if not t or not t.nodes or not t.nodes[1] or not t.nodes[1].nodes then return t end

    if card and card.area and card.area.config and card.area.config.type == 'joker' and card_has_key(card, 'kyra') and not card.debuff then
        local pay_button = {
            n = G.UIT.R,
            config = { align = 'cl' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cr" },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "cr",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = G.C.GOLD,
                                one_press = false,
                                button = 'pay_kyra',
                                func = 'can_pay_kyra'
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "tm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "POTION", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "$2", colour = G.C.WHITE, scale = 0.52, shadow = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        table.insert(t.nodes[1].nodes, pay_button)
    end

    if card and card.area and card.area.config and card.area.config.type == 'joker' and card_has_key(card, 'marina') and not card.debuff then
        local hack_button = {
            n = G.UIT.R,
            config = { align = 'cl' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cr" },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "cr",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = HEX('28d2dc'),
                                one_press = false,
                                button = 'marina_open_hack_menu',
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "tm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "HACK", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "MENU", colour = G.C.WHITE, scale = 0.28, shadow = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        table.insert(t.nodes[1].nodes, hack_button)
    end

    if card and card.debuff and get_active_marina and get_active_marina() then
        local cost = get_marina_debuff_cost(card)
        local hack_debuff_button = {
            n = G.UIT.R,
            config = { align = 'cl' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cr" },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "cr",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = HEX('28d2dc'),
                                one_press = false,
                                button = 'marina_hack_debuff_card',
                                func = 'can_marina_hack_debuff'
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "tm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "HACK", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "$" .. tostring(cost), colour = G.C.WHITE, scale = 0.45, shadow = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        table.insert(t.nodes[1].nodes, hack_debuff_button)
    end

    if card and card.area and card.area.config and card.area.config.type == 'joker' and card_has_key(card, 'sally') and not card.debuff then
        local sally_quiz_button = {
            n = G.UIT.R,
            config = { align = 'cl' },
            nodes = {
                {
                    n = G.UIT.C,
                    config = { align = "cr" },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                ref_table = card,
                                align = "cr",
                                padding = 0.1,
                                r = 0.08,
                                minw = 1.25,
                                hover = true,
                                shadow = true,
                                colour = HEX('e8413e'),
                                one_press = false,
                                button = 'sally_open_question_menu',
                            },
                            nodes = {
                                { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "tm" },
                                    nodes = {
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", maxw = 1.25 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "TRIVIA", colour = G.C.WHITE, scale = 0.38, shadow = true } }
                                            }
                                        },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm" },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "QUIZ", colour = G.C.WHITE, scale = 0.28, shadow = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        table.insert(t.nodes[1].nodes, sally_quiz_button)
    end

    return t
end

function register_amalgam_joker(def)
    def.rarity = def.rarity or 4
    def.is_amalgam = true
    def.unlocked = (def.unlocked == nil and true) or def.unlocked
    def.soul_pos = def.soul_pos or { x = 1, y = (def.pos and def.pos.y) or 0 }
    def.cost = def.cost or 25
    def.in_pool = def.in_pool or function(self, args)
        return false, { allow_duplicates = false }
    end
    def.set_card_type_badge = def.set_card_type_badge or function(self, card, badges)
        badges[1] = create_badge('Amalgam', HEX('8a2be2'), G.C.WHITE, 1.2)
    end
    def.set_badges = def.set_badges or function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Amalgam', HEX('8a2be2'), G.C.WHITE, 1.2)
        end
    end
    return SMODS.Joker(def)
end

register_amalgam_joker {
    key = 'brainprint',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 12 },
    soul_pos = { x = 1, y = 12 },
    loc_txt = {
        name = 'Brainprint',
        text = {
            "Copies abilities of the {C:attention}Jokers{}",
            "to the immediate left and right"
        }
    },
    config = {},
    blueprint_compat = false,
    calculate = function(self, card, context)
        if not G.jokers or not G.jokers.cards then return end
        local my_idx = nil
        for idx, j in ipairs(G.jokers.cards) do
            if j == card then my_idx = idx; break end
        end
        if not my_idx then return end

        local left_joker = (my_idx > 1) and G.jokers.cards[my_idx - 1] or nil
        local right_joker = (my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1] or nil

        local left_ret = nil
        local right_ret = nil

        if left_joker and left_joker ~= card and is_joker_copiable(left_joker) then
            left_ret = SMODS.blueprint_effect(card, left_joker, context)
        end

        if right_joker and right_joker ~= card and is_joker_copiable(right_joker) then
            right_ret = SMODS.blueprint_effect(card, right_joker, context)
        end

        if left_ret and right_ret then
            if type(left_ret) == 'table' and type(right_ret) == 'table' then
                local merged = {}
                for k, v in pairs(left_ret) do merged[k] = v end
                if right_ret.chips then merged.chips = (merged.chips or 0) + right_ret.chips end
                if right_ret.mult then merged.mult = (merged.mult or 0) + right_ret.mult end
                if right_ret.x_mult or right_ret.Xmult then
                    local xm1 = merged.x_mult or merged.Xmult or 1
                    local xm2 = right_ret.x_mult or right_ret.Xmult or 1
                    merged.x_mult = xm1 * xm2
                end
                if right_ret.dollars then merged.dollars = (merged.dollars or 0) + right_ret.dollars end
                merged.card = card
                return merged
            else
                return left_ret
            end
        elseif left_ret then
            if type(left_ret) == 'table' then left_ret.card = card end
            return left_ret
        elseif right_ret then
            if type(right_ret) == 'table' then right_ret.card = card end
            return right_ret
        end
    end
}

register_amalgam_joker {
    key = 'vampiric_midas',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 0 },
    soul_pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Vampiric Midas',
        text = {
            "Turns scored cards into {C:attention}Gold Cards{},",
            "then absorbs their enhancements to gain",
            "{X:mult,C:white}+X#1#{} Mult each {C:inactive}(keeps seals & editions){}",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        if context.blueprint then return nil end

        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local cards_to_process = context.scoring_hand or context.full_hand or {}

            for _, c in ipairs(cards_to_process) do
                if not c.debuff and c.config.center ~= G.P_CENTERS.m_gold then
                    c:set_ability(G.P_CENTERS.m_gold, nil, true)
                    local target = c
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target then target:juice_up() end
                            return true
                        end
                    }))
                end
            end

            local absorbed_count = 0
            for _, c in ipairs(cards_to_process) do
                if not c.debuff and c.config.center ~= G.P_CENTERS.c_base then
                    absorbed_count = absorbed_count + 1
                    c:set_ability(G.P_CENTERS.c_base, nil, true)
                    local target = c
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            if target then target:juice_up() end
                            return true
                        end
                    }))
                end
            end

            if absorbed_count > 0 then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + absorbed_count * (card.ability.extra.xmult_gain or 0.25)
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                    colour = G.C.RED,
                    card = card
                }
            end
        end

        if context.joker_main and not context.blueprint and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

register_amalgam_joker {
    key = 'certified_programming',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 1 },
    soul_pos = {
        x = 3,
        y = 1,
        draw = function(card, scale_mod, rotate_mod)
            if card.children.floating_sprite then
                scale_mod = scale_mod or (0.07 + 0.02 * math.sin(1.8 * G.TIMERS.REAL))
                rotate_mod = rotate_mod or (0.05 * math.sin(1.219 * G.TIMERS.REAL))
                card.hover_tilt = (card.hover_tilt or 1) * 1.5
                card.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, 2 * scale_mod, 2 * rotate_mod)
                card.hover_tilt = (card.hover_tilt or 1.5) / 1.5
            end
        end
    },
    loc_txt = {
        name = 'Certified Programming',
        text = {
            "At start of round, adds {C:attention}2{} cards with a",
            "random {C:attention}Seal{} and {C:attention}Enhancement{} to hand.",
            "Gains {X:mult,C:white}+X#1#{} Mult when any card is added to deck",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0 } }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local target_card = context.blueprint_card or card
            G.E_MANAGER:add_event(Event({
                func = function()
                    local created_cards = {}
                    for i = 1, 2 do
                        local _card = create_playing_card({
                            front = pseudorandom_element(G.P_CARDS, pseudoseed('cert_fr' .. i)),
                            center = G.P_CENTERS.c_base
                        }, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Enhanced })
                        local seals = { 'Red', 'Blue', 'Gold', 'Purple' }
                        local chosen_seal = pseudorandom_element(seals, pseudoseed('cert_seal' .. i))
                        _card:set_seal(chosen_seal, true)
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Enhanced then
                            local chosen_enh = pseudorandom_element(G.P_CENTER_POOLS.Enhanced, pseudoseed('cert_enh' .. i))
                            if chosen_enh then _card:set_ability(chosen_enh) end
                        end
                        created_cards[#created_cards + 1] = _card
                    end
                    G.hand:sort()
                    card_eval_status_text(target_card, 'extra', nil, nil, nil, { message = localize('k_plus_card') })
                    if playing_card_joker_effects then
                        playing_card_joker_effects(created_cards)
                    elseif SMODS and SMODS.calculate_context then
                        SMODS.calculate_context({ playing_card_added = true, cards = created_cards })
                    end
                    return true
                end
            }))
        end
        if context.playing_card_added and not context.blueprint and context.cards and #context.cards > 0 then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + #context.cards * (card.ability.extra.xmult_gain or 0.25)
            return {
                message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                colour = G.C.RED,
                card = card
            }
        end
        if context.joker_main and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

register_amalgam_joker {
    key = 'galactic_traveler',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 2 },
    soul_pos = { x = 3, y = 2 },
    loc_txt = {
        name = 'Galactic Traveler',
        text = {
            "{C:blue}Planets{} and {C:blue}Celestial Packs{} are {C:attention}free{}.",
            "Gains {X:mult,C:white}+X#1#{} Mult per {C:blue}Planet{} used.",
            "Doubles sell value of {C:blue}Planets{}.",
            "{C:green}#3# in #4#{} chance to level up played hand",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { xmult_gain = 0.25, xmult = 1.0, odds = 2 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        local num, den = SMODS.get_probability_vars(card, 1, extra.odds or 2, 'galactic_traveler')
        return { vars = { extra.xmult_gain or 0.25, extra.xmult or 1.0, num, den } }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.I and G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end
        }))
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.I and G.I.CARD then
                    for _, v in pairs(G.I.CARD) do
                        if v.set_cost then v:set_cost() end
                    end
                end
                return true
            end
        }))
    end,
    calculate = function(self, card, context)
        if context.blueprint then return nil end
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 2
            if SMODS.pseudorandom_probability(card, 'galactic_traveler', 1, odds) then
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(context.scoring_name, 'poker_hands'), chips = G.GAME.hands[context.scoring_name].chips, mult = G.GAME.hands[context.scoring_name].mult, level=G.GAME.hands[context.scoring_name].level})
                level_up_hand(card, context.scoring_name, nil, 1)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
                return {
                    message = localize('k_level_up_ex'),
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
        if context.using_consumeable and not context.blueprint then
            if context.consumeable and context.consumeable.ability and context.consumeable.ability.set == 'Planet' then
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + (card.ability.extra.xmult_gain or 0.25)
                return {
                    message = localize{type = 'variable', key = 'a_xmult', vars = { card.ability.extra.xmult }},
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.joker_main and (card.ability.extra.xmult or 1.0) > 1 then
            return {
                Xmult = card.ability.extra.xmult,
                card = card
            }
        end
    end
}

register_amalgam_joker {
    key = 'colorful_street',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 3 },
    soul_pos = { x = 3, y = 3 },
    loc_txt = {
        name = 'Colorful Street',
        text = {
            "{C:attention}Flushes{} and {C:attention}Straights{} can be made with {C:attention}4 cards{}.",
            "{C:attention}Straights{} can skip gaps of {C:attention}1 rank{}.",
            "{C:hearts}Hearts{} & {C:diamonds}Diamonds{} count as same suit,",
            "{C:spades}Spades{} & {C:clubs}Clubs{} count as same suit"
        }
    },
    config = {},
    blueprint_compat = false
}

local COMPONENT_JOKERS_BY_AMALGAM = {
    ['brainprint']                  = { 'j_blueprint', 'j_brainstorm' },
    ['vampiric_midas']              = { 'j_midas_mask', 'j_vampire' },
    ['midas_vampirico']             = { 'j_midas_mask', 'j_vampire' },
    ['certified_programming']       = { 'j_hologram', 'j_certificate' },
    ['programacion_certificacion']   = { 'j_hologram', 'j_certificate' },
    ['galactic_traveler']           = { 'j_constellation', 'j_astronomer' },
    ['viajero_galactico']           = { 'j_constellation', 'j_astronomer' },
    ['colorful_street']             = { 'j_four_fingers', 'j_shortcut', 'j_smeared' },
    ['calle_colorida']               = { 'j_four_fingers', 'j_shortcut', 'j_smeared' },
    ['unrecognizable_antique']       = { 'j_ancient', 'j_smeared' },
    ['antiguedad_irreconocible']     = { 'j_ancient', 'j_smeared' },
    ['macabre_emoji']               = { 'j_smiley', 'j_scary_face' },
    ['emoji_macabro']               = { 'j_smiley', 'j_scary_face' },
    ['mime_king']                   = { 'j_mime', 'j_baron' },
    ['rey_de_mimos']                = { 'j_mime', 'j_baron' },
    ['photo_album']                 = { 'j_hanging_chad', 'j_photograph' },
    ['album_de_fotos']              = { 'j_hanging_chad', 'j_photograph' },
    ['pirate_egg']                  = { 'j_swashbuckler', 'j_egg' },
    ['huevo_pirata']                = { 'j_swashbuckler', 'j_egg' },
    ['reinforced_boots']            = { 'j_bootstraps', 'j_bull' },
    ['botas_reforzadas']            = { 'j_bootstraps', 'j_bull' },
    ['wee_comedian']                = { 'j_wee', 'j_hiker' },
    ['golden_lucky_cat']            = { 'j_lucky_cat', 'j_oops' },
    ['gato_dorado_suerte']          = { 'j_lucky_cat', 'j_oops' },
}

local AMALGAM_CONSTITUENTS_MAP = {
    ['Astronomer']          = { 'galactic_traveler', 'viajero_galactico' },
    ['j_astronomer']        = { 'galactic_traveler', 'viajero_galactico' },
    ['Constellation']       = { 'galactic_traveler', 'viajero_galactico' },
    ['j_constellation']     = { 'galactic_traveler', 'viajero_galactico' },
    ['Four Fingers']        = { 'colorful_street', 'calle_colorida' },
    ['j_four_fingers']      = { 'colorful_street', 'calle_colorida' },
    ['Cuatro Dedos']        = { 'colorful_street', 'calle_colorida' },
    ['Shortcut']            = { 'colorful_street', 'calle_colorida' },
    ['j_shortcut']          = { 'colorful_street', 'calle_colorida' },
    ['Atajo']               = { 'colorful_street', 'calle_colorida' },
    ['Smeared Joker']       = { 'colorful_street', 'calle_colorida', 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['j_smeared']           = { 'colorful_street', 'calle_colorida', 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['Comodín Manchado']    = { 'colorful_street', 'calle_colorida', 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['Comodin Manchado']    = { 'colorful_street', 'calle_colorida', 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['Ancient Joker']       = { 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['j_ancient']           = { 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['Comodín Antiguo']     = { 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['Comodin Antiguo']     = { 'unrecognizable_antique', 'antiguedad_irreconocible' },
    ['Midas Mask']          = { 'vampiric_midas', 'midas_vampirico' },
    ['j_midas_mask']        = { 'vampiric_midas', 'midas_vampirico' },
    ['Máscara de Midas']    = { 'vampiric_midas', 'midas_vampirico' },
    ['Vampire']             = { 'vampiric_midas', 'midas_vampirico' },
    ['j_vampire']           = { 'vampiric_midas', 'midas_vampirico' },
    ['Vampiro']             = { 'vampiric_midas', 'midas_vampirico' },
    ['Hologram']            = { 'certified_programming', 'programacion_certificacion' },
    ['j_hologram']          = { 'certified_programming', 'programacion_certificacion' },
    ['Holograma']           = { 'certified_programming', 'programacion_certificacion' },
    ['Certificate']         = { 'certified_programming', 'programacion_certificacion' },
    ['j_certificate']       = { 'certified_programming', 'programacion_certificacion' },
    ['Certificado']         = { 'certified_programming', 'programacion_certificacion' },
    ['Blueprint']           = { 'brainprint' },
    ['j_blueprint']         = { 'brainprint' },
    ['Brainstorm']          = { 'brainprint' },
    ['j_brainstorm']        = { 'brainprint' },
    ['Mime']                = { 'mime_king', 'rey_de_mimos' },
    ['j_mime']              = { 'mime_king', 'rey_de_mimos' },
    ['Baron']               = { 'mime_king', 'rey_de_mimos' },
    ['j_baron']             = { 'mime_king', 'rey_de_mimos' },
    ['Hanging Chad']        = { 'photo_album', 'album_de_fotos' },
    ['j_hanging_chad']      = { 'photo_album', 'album_de_fotos' },
    ['Photograph']          = { 'photo_album', 'album_de_fotos' },
    ['j_photograph']        = { 'photo_album', 'album_de_fotos' },
    ['Swashbuckler']        = { 'pirate_egg', 'huevo_pirata' },
    ['j_swashbuckler']      = { 'pirate_egg', 'huevo_pirata' },
    ['Egg']                 = { 'pirate_egg', 'huevo_pirata' },
    ['j_egg']               = { 'pirate_egg', 'huevo_pirata' },
    ['Bootstraps']          = { 'reinforced_boots', 'botas_reforzadas' },
    ['j_bootstraps']        = { 'reinforced_boots', 'botas_reforzadas' },
    ['Bull']                = { 'reinforced_boots', 'botas_reforzadas' },
    ['j_bull']              = { 'reinforced_boots', 'botas_reforzadas' },
    ['Wee Joker']           = { 'wee_comedian' },
    ['j_wee']               = { 'wee_comedian' },
    ['Hiker']               = { 'wee_comedian' },
    ['j_hiker']             = { 'wee_comedian' },
    ['Lucky Cat']           = { 'golden_lucky_cat', 'gato_dorado_suerte' },
    ['j_lucky_cat']         = { 'golden_lucky_cat', 'gato_dorado_suerte' },
    ['Oops! All 6s']        = { 'golden_lucky_cat', 'gato_dorado_suerte' },
    ['j_oops']              = { 'golden_lucky_cat', 'gato_dorado_suerte' },
    ['Smiley Face']         = { 'macabre_emoji', 'emoji_macabro' },
    ['j_smiley']            = { 'macabre_emoji', 'emoji_macabro' },
    ['Scary Face']          = { 'macabre_emoji', 'emoji_macabro' },
    ['j_scary_face']        = { 'macabre_emoji', 'emoji_macabro' },
}

local orig_find_joker = find_joker
function find_joker(name, non_debuff)
    local jokers = orig_find_joker and orig_find_joker(name, non_debuff) or {}
    local name_key = string.lower(tostring(name or ''))
    if G.jokers and G.jokers.cards then
        for _, v in ipairs(G.jokers.cards) do
            if v and (non_debuff or not v.debuff) then
                local matches = false
                local center = v.config and v.config.center
                local c_key = string.lower(tostring((center and center.key) or v.config.center_key or ''))
                local c_name = string.lower(tostring((center and center.name) or (v.ability and v.ability.name) or ''))
                if name_key == 'shortcut' and (c_key == 'j_shortcut' or c_name == 'shortcut' or c_name == 'atajo' or card_has_key(v, 'shortcut') or card_has_key(v, 'atajo')) then
                    matches = true
                elseif name_key == 'four fingers' and (c_key == 'j_four_fingers' or c_name == 'four fingers' or c_name == 'cuatro dedos' or card_has_key(v, 'four_fingers')) then
                    matches = true
                end
                if matches then
                    local already_in = false
                    for _, ex in ipairs(jokers) do
                        if ex == v then already_in = true; break end
                    end
                    if not already_in then table.insert(jokers, v) end
                end
            end
        end
    end
    local amalgam_matches = AMALGAM_CONSTITUENTS_MAP[name]
    if amalgam_matches and G.jokers and G.jokers.cards then
        for _, v in ipairs(G.jokers.cards) do
            if v and (non_debuff or not v.debuff) then
                for _, a_key in ipairs(amalgam_matches) do
                    if card_has_key(v, a_key) then
                        local already_in = false
                        for _, existing in ipairs(jokers) do
                            if existing == v then already_in = true; break end
                        end
                        if not already_in then
                            table.insert(jokers, v)
                        end
                        break
                    end
                end
            end
        end
    end
    return jokers
end

local function sync_amalgam_used_jokers()
    if not (G.jokers and G.jokers.cards and G.GAME and G.GAME.used_jokers) then return end
    local owned_comps = {}
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff then
            for amalgam_key, comps in pairs(COMPONENT_JOKERS_BY_AMALGAM) do
                if card_has_key(j, amalgam_key) then
                    for _, comp_key in ipairs(comps) do
                        owned_comps[comp_key] = true
                    end
                end
            end
        end
    end
    for _, comps in pairs(COMPONENT_JOKERS_BY_AMALGAM) do
        for _, comp_key in ipairs(comps) do
            if owned_comps[comp_key] then
                G.GAME.used_jokers[comp_key] = true
            else
                local actually_owns = false
                for _, j in ipairs(G.jokers.cards) do
                    if j.config and j.config.center and j.config.center.key == comp_key then
                        actually_owns = true
                        break
                    end
                end
                if not actually_owns then
                    G.GAME.used_jokers[comp_key] = nil
                end
            end
        end
    end
end

local orig_card_add_to_deck = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    local ret = orig_card_add_to_deck and orig_card_add_to_deck(self, from_debuff)
    sync_amalgam_used_jokers()
    return ret
end

local orig_card_remove_from_deck = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    local ret = orig_card_remove_from_deck and orig_card_remove_from_deck(self, from_debuff)
    sync_amalgam_used_jokers()
    return ret
end

local orig_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    sync_amalgam_used_jokers()
    local pool, pool_key = orig_get_current_pool(_type, _rarity, _legendary, _append)
    if _type == 'Joker' and pool and not (next(find_joker("Showman"))) then
        local banned = {}
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff then
                    for amalgam_key, comps in pairs(COMPONENT_JOKERS_BY_AMALGAM) do
                        if card_has_key(j, amalgam_key) then
                            for _, comp_key in ipairs(comps) do
                                banned[comp_key] = true
                            end
                        end
                    end
                end
            end
        end
        if next(banned) then
            local has_available = false
            for _, k in ipairs(pool) do
                if k ~= 'UNAVAILABLE' and not banned[k] then
                    has_available = true
                    break
                end
            end
            if has_available then
                for i = 1, #pool do
                    if pool[i] ~= 'UNAVAILABLE' and banned[pool[i]] then
                        pool[i] = 'UNAVAILABLE'
                    end
                end
            end
        end
    end
    return pool, pool_key
end

local function has_viajero_galactico()
    if not (G and G.jokers and G.jokers.cards) then return false end
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff and (card_has_key(j, 'galactic_traveler') or card_has_key(j, 'viajero_galactico')) then
            return true
        end
    end
    return false
end

local orig_card_set_cost = Card.set_cost
function Card:set_cost()
    orig_card_set_cost(self)
    if self.ability and self.ability.set == 'Planet' and has_viajero_galactico() then
        self.sell_cost = math.max(2, (self.sell_cost or 1) * 2)
        self.sell_cost_label = self.sell_cost
    end
end

register_secret_joker {
    key = 'astra',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 13 },
    soul_pos = { x = 1, y = 13 },
    loc_txt = {
        name = 'Astral Calamity',
        text = {
            "Used {C:planet}Planet{} cards give",
            "{C:attention}+#1#{} extra level.",
            "{C:spectral}Black Hole{} gives",
            "{C:attention}+#2#{} extra levels."
        }
    },
    config = { extra = { extra_planet_levels = 1, extra_black_hole_levels = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        if info_queue and G.P_CENTERS and G.P_CENTERS.c_black_hole then
            table.insert(info_queue, G.P_CENTERS.c_black_hole)
        end
        local extra = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { extra.extra_planet_levels or 1, extra.extra_black_hole_levels or 2 } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable then
            local cons = context.consumeable
            if cons then
                local k = (cons.config and cons.config.center and cons.config.center.key)
                    or (cons.ability and cons.ability.name)
                    or ''
                local is_black_hole = (k == 'c_black_hole' or cons.ability.name == 'Black Hole' or string.find(string.lower(tostring(k)), 'black_hole'))
                local is_planet = (cons.ability and cons.ability.set == 'Planet')

                if is_black_hole then
                    local extra_levels = (card.ability and card.ability.extra and card.ability.extra.extra_black_hole_levels) or 2
                    for hand_name, _ in pairs(G.GAME.hands) do
                        level_up_hand(card, hand_name, true, extra_levels)
                    end
                    return {
                        message = '+' .. tostring(extra_levels) .. ' Extra Levels!',
                        colour = G.C.SECONDARY_SET.Spectral
                    }
                elseif is_planet then
                    local target_hand = (cons.ability and (cons.ability.hand_type or (cons.ability.consumeable and cons.ability.consumeable.hand_type)))
                        or (cons.config and cons.config.center and cons.config.center.config and cons.config.center.config.hand_type)
                    if target_hand and G.GAME.hands[target_hand] then
                        local extra_levels = (card.ability and card.ability.extra and card.ability.extra.extra_planet_levels) or 1
                        level_up_hand(card, target_hand, nil, extra_levels)
                        return {
                            message = '+' .. tostring(extra_levels) .. ' Extra Level!',
                            colour = G.C.SECONDARY_SET.Planet
                        }
                    end
                end
            end
        end
    end
}

if G.P_CENTERS then
    G.P_CENTERS.j_reality_warp_astral_calamity = G.P_CENTERS.j_reality_warp_astra
    G.P_CENTERS.astral_calamity = G.P_CENTERS.j_reality_warp_astra
end

register_secret_joker {
    key = 'marie',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 14 },
    soul_pos = { x = 1, y = 14 },
    loc_txt = {
        name = 'Marie',
        text = {
            "{C:attention}Enhanced{} cards give",
            "{X:mult,C:white}X#1#{} Mult when scored.",
            "Retriggers {C:attention}1{} time with a {C:attention}Seal{},",
            "and {C:attention}1{} more time with an {C:attention}Edition{}"
        }
    },
    config = { extra = { x_mult = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.x_mult) or 2 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local other = context.other_card
            if other then
                local is_enhanced = (other.config and other.config.center and other.config.center ~= G.P_CENTERS.c_base and other.config.center.set == 'Enhanced') or (other.ability and other.ability.set == 'Enhanced')
                if is_enhanced then
                    local base_xmult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2
                    return {
                        x_mult = base_xmult,
                        card = card
                    }
                end
            end
        end

        if context.repetition and context.cardarea == G.play then
            local other = context.other_card
            if other then
                local has_seal = (other.seal ~= nil and other.seal ~= '')
                local has_ed = (other.edition ~= nil and not other.edition.base)
                local reps = (has_seal and 1 or 0) + (has_ed and 1 or 0)

                if reps > 0 then
                    return {
                        repetitions = reps,
                        card = card,
                        message = localize('k_again_ex')
                    }
                end
            end
        end
    end
}

register_secret_joker {
    key = 'callie',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 15 },
    soul_pos = { x = 1, y = 15 },
    loc_txt = {
        name = 'Callie',
        text = {
            "Scored cards gain a random missing",
            "{C:attention}Enhancement{}, {C:attention}Seal{}, or {C:attention}Edition{}",
            "{C:inactive}(except Negative, once per card){}"
        }
    },
    config = { extra = {} },
    blueprint_compat = false,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local target = context.other_card
            if target and not target.debuff then
                target.ability = target.ability or {}
                if not target.ability.callie_upgraded then
                    local has_enh = (target.config and target.config.center and target.config.center ~= G.P_CENTERS.c_base)
                    local has_seal = (target.seal ~= nil and target.seal ~= '')
                    local has_ed = (target.edition ~= nil and not target.edition.base)

                    local types = {}
                    if not has_enh then table.insert(types, 'enh') end
                    if not has_seal then table.insert(types, 'seal') end
                    if not has_ed then table.insert(types, 'edition') end

                    if #types == 0 then
                        target.ability.callie_upgraded = true
                        return
                    end

                    local has_marie = false
                    if G.jokers and G.jokers.cards then
                        for _, jk in ipairs(G.jokers.cards) do
                            if jk.config and jk.config.center and (jk.config.center.key == 'j_reality_warp_marie' or jk.config.center.key == 'marie' or (jk.config.center.key and string.find(jk.config.center.key:lower(), 'marie'))) then
                                has_marie = true; break
                            end
                        end
                    end

                    local gift_type = pseudorandom_element(types, pseudoseed('callie_choice'))

                    if gift_type == 'enh' then
                        local pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Enhanced then
                            for _, enh in ipairs(G.P_CENTER_POOLS.Enhanced) do
                                if enh.key and enh.key ~= 'c_base' then
                                    table.insert(pool, enh)
                                end
                            end
                        end
                        if #pool > 0 then
                            local chosen = pseudorandom_element(pool, pseudoseed('callie_enh'))
                            if chosen then target:set_ability(chosen) end
                        end
                    elseif gift_type == 'seal' then
                        local seal_pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Seal and #G.P_CENTER_POOLS.Seal > 0 then
                            for _, s in ipairs(G.P_CENTER_POOLS.Seal) do
                                local k = s.key or s.name
                                if k then table.insert(seal_pool, k) end
                            end
                        elseif G.P_SEALS then
                            for k, _ in pairs(G.P_SEALS) do
                                table.insert(seal_pool, k)
                            end
                        end
                        if #seal_pool == 0 then
                            seal_pool = { 'Red', 'Blue', 'Gold', 'Purple' }
                        end
                        local chosen_seal = pseudorandom_element(seal_pool, pseudoseed('callie_seal'))
                        target:set_seal(chosen_seal, true)
                    elseif gift_type == 'edition' then
                        local ed_pool = {}
                        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Edition and #G.P_CENTER_POOLS.Edition > 0 then
                            for _, ed in ipairs(G.P_CENTER_POOLS.Edition) do
                                local ed_k = ed.key or ed.name
                                if ed_k and ed_k ~= 'base' and ed_k ~= 'e_base' and ed_k ~= 'negative' and ed_k ~= 'e_negative' then
                                    table.insert(ed_pool, ed_k)
                                end
                            end
                        end
                        if #ed_pool == 0 then
                            ed_pool = { 'foil', 'holo', 'polychrome' }
                        end
                        local chosen_ed = pseudorandom_element(ed_pool, pseudoseed('callie_ed'))
                        local clean_key = type(chosen_ed) == 'string' and chosen_ed:gsub('^e_', '') or chosen_ed
                        target:set_edition({ [clean_key] = true }, true, true)
                    end

                    target.ability.callie_upgraded = true
                    target:juice_up(0.3, 0.3)
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.GOLD,
                        card = card
                    }
                end
            end
        end
    end
}

local SALLY_QUESTIONS = {
    {
        q = "How many Jokers does the original Balatro have?",
        options = { "A) 45", "B) 100", "C) 150", "D) 200" },
        answer = 1,
        reward = 5
    },
    {
        q = "In which year was Balatro nominated as GOTY?",
        options = { "A) 2022", "B) 2023", "C) 2024", "D) 2025" },
        answer = 3,
        reward = 5
    },
    {
        q = "How many Legendary Jokers exist in the original Balatro?",
        options = { "A) 3", "B) 4", "C) 5", "D) 6" },
        answer = 3,
        reward = 5
    },
    {
        q = "How many Chips does the Foil edition give?",
        options = { "A) +25 Chips", "B) +50 Chips", "C) +75 Chips", "D) +100 Chips" },
        answer = 2,
        reward = 5
    },
    {
        q = "How much Mult does the Holographic edition give?",
        options = { "A) +5 Mult", "B) +10 Mult", "C) +15 Mult", "D) +20 Mult" },
        answer = 2,
        reward = 5
    },
    {
        q = "How much XMult does the Polychrome edition give?",
        options = { "A) X1.2 Mult", "B) X1.5 Mult", "C) X2.0 Mult", "D) X3.0 Mult" },
        answer = 2,
        reward = 5
    },
    {
        q = "How many Joker slots does the Negative edition give?",
        options = { "A) +1 Slot", "B) +2 Slots", "C) +3 Slots", "D) No Slots" },
        answer = 1,
        reward = 5
    },
    {
        q = "Who is the main protagonist in The Legend of Zelda?",
        options = { "A) Zelda", "B) Link", "C) Ganon", "D) Epona" },
        answer = 2,
        reward = 10
    },
    {
        q = "In Minecraft, which block is required for a Nether Portal frame?",
        options = { "A) Obsidian", "B) Bedrock", "C) Netherrack", "D) Crying Obsidian" },
        answer = 1,
        reward = 10
    },
    {
        q = "Which company created the classic arcade game Pac-Man?",
        options = { "A) Nintendo", "B) Namco", "C) Konami", "D) Sega" },
        answer = 2,
        reward = 10
    },
    {
        q = "In Dark Souls, what is the catchphrase of Solaire of Astora?",
        options = { "A) Stay Awhile and Listen", "B) Praise the Sun", "C) Git Gud", "D) Fear the Old Blood" },
        answer = 2,
        reward = 10
    },
    {
        q = "In Super Mario 64, how many total Power Stars can you collect?",
        options = { "A) 70", "B) 100", "C) 120", "D) 150" },
        answer = 3,
        reward = 10
    }
}

local function open_sally_question_menu(sally_card)
    if not (create_UIBox_generic_options and G.FUNCS and G.FUNCS.overlay_menu) then return end
    sally_card.ability = sally_card.ability or {}
    sally_card.ability.extra = sally_card.ability.extra or {}

    if sally_card.ability.extra.question_answered then
        local contents = {
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.1 },
                nodes = {
                    { n = G.UIT.T, config = { text = "SALLY'S TRIVIA SHOW", scale = 0.55, colour = HEX('e8413e'), shadow = true } }
                }
            },
            {
                n = G.UIT.R, config = { align = "cm", padding = 0.15, colour = HEX('18181b'), r = 0.12, outline = 0.02, outline_colour = HEX('71717a') },
                nodes = {
                    { n = G.UIT.T, config = { text = "Trivia already answered for this blind! Come back next blind!", scale = 0.35, colour = HEX('fef08a') } }
                }
            }
        }
        local t = create_UIBox_generic_options({
            back_func = 'exit_overlay_menu',
            back_label = "Close",
            contents = contents
        })
        G.FUNCS.overlay_menu{ definition = t }
        return
    end

    if not sally_card.ability.extra.current_question then
        sally_card.ability.extra.current_question = pseudorandom_element(SALLY_QUESTIONS, pseudoseed('sally_question'))
    end
    local cur_q = sally_card.ability.extra.current_question

    local function make_choice_button(idx, opt_text)
        return {
            n = G.UIT.C,
            config = {
                align = "cm", minw = 3.9, minh = 0.52, r = 0.1, padding = 0.04,
                hover = true,
                colour = HEX('27272a'),
                outline = 0.025,
                outline_colour = HEX('e8413e'),
                button = 'sally_choose_answer',
                ref_table = { sally = sally_card, choice_index = idx, question = cur_q },
                shadow = true
            },
            nodes = {
                { n = G.UIT.T, config = { text = opt_text, scale = 0.33, colour = G.C.WHITE, shadow = true } }
            }
        }
    end

    local reward_val = cur_q.reward or 5
    local contents = {
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.06 },
            nodes = {
                { n = G.UIT.T, config = { text = "SALLY'S TRIVIA SHOW", scale = 0.52, colour = HEX('e8413e'), shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.03 },
            nodes = {
                { n = G.UIT.T, config = { text = "Answer correctly to win $" .. tostring(reward_val) .. "!", scale = 0.3, colour = G.C.WHITE } }
            }
        },
        {
            n = G.UIT.R, config = {
                align = "cm", padding = 0.1, colour = HEX('18181b'),
                r = 0.12, outline = 0.03, outline_colour = HEX('e8413e'), minw = 8.1
            },
            nodes = {
                { n = G.UIT.T, config = { text = cur_q.q, scale = 0.35, colour = HEX('fef08a'), shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.04 },
            nodes = {
                make_choice_button(1, cur_q.options[1]),
                { n = G.UIT.B, config = { w = 0.2, h = 0.1 } },
                make_choice_button(2, cur_q.options[2]),
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.04 },
            nodes = {
                make_choice_button(3, cur_q.options[3]),
                { n = G.UIT.B, config = { w = 0.2, h = 0.1 } },
                make_choice_button(4, cur_q.options[4]),
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.04 },
            nodes = {}
        }
    }

    local t = create_UIBox_generic_options({
        back_func = 'exit_overlay_menu',
        back_label = "Close",
        contents = contents
    })
    G.FUNCS.overlay_menu{ definition = t }
end

G.FUNCS = G.FUNCS or {}
G.FUNCS.sally_open_question_menu = function(e)
    local card = e.config.ref_table
    if card then
        open_sally_question_menu(card)
    end
end

G.FUNCS.sally_choose_answer = function(e)
    local ref = e.config.ref_table
    if not ref or not ref.sally or not ref.question then return end
    local sally = ref.sally
    local q = ref.question
    local chosen = ref.choice_index
    local is_correct = (chosen == q.answer)

    G.FUNCS.exit_overlay_menu()

    sally.ability = sally.ability or {}
    sally.ability.extra = sally.ability.extra or {}
    sally.ability.extra.question_answered = true

    if is_correct then
        local reward = q.reward or 5
        play_sound('coin2')
        sally:juice_up(0.8, 0.8)
        ease_dollars(reward)
        card_eval_status_text(sally, 'extra', nil, nil, nil, { message = 'CORRECT! +$' .. reward, colour = G.C.GOLD })
        sally.ability.extra.completed = true
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.add_card { set = 'Tarot', edition = 'e_negative', key_append = 'sally' }
                return true
            end
        }))
    else
        play_sound('cancel')
        sally:juice_up(0.4, 0.4)
        card_eval_status_text(sally, 'extra', nil, nil, nil, { message = 'WRONG!', colour = G.C.RED })
    end
end

register_secret_joker {
    key = 'sally',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 16 },
    soul_pos = { x = 1, y = 16 },
    loc_txt = {
        name = 'Sally',
        text = {
            "Answer a {C:attention}Trivia Question{} each blind",
            "to earn {C:money}$5{} {C:inactive}($10 for Multiple Choice){}",
            "and a random {C:dark_edition}Negative{} consumable",
            "{C:inactive}(Current: #1#){}"
        }
    },
    config = { extra = { question_answered = false, completed = false } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local cur_q = ex.current_question
        local reward = cur_q and cur_q.reward or 5
        local status_str = ex.question_answered and "Answered" or ("Pending ($" .. reward .. ") - Click TRIVIA")
        return { vars = { status_str } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.completed = false
            card.ability.extra.question_answered = false
            card.ability.extra.current_question = pseudorandom_element(SALLY_QUESTIONS, pseudoseed('sally_question'))
            card.ability.extra._counted_for_trial = nil
        end
    end
}

register_amalgam_joker {
    key = 'mime_king',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 4 },
    soul_pos = { x = 3, y = 4 },
    loc_txt = {
        name = 'Mime King',
        text = {
            "{C:attention}Kings{} held in hand",
            "give {X:mult,C:white}X#1#{} Mult.",
            "Cards held in hand",
            "retrigger {C:attention}#2#{} times."
        }
    },
    config = { extra = { x_mult = 2, repetitions = 2 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 2, ex.repetitions or 2 } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card:get_id() == 13 then
                return {
                    x_mult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2,
                    card = card
                }
            end
        end
        if context.repetition and context.cardarea == G.hand and not context.end_of_round then
            return {
                message = localize('k_again_ex'),
                repetitions = (card.ability and card.ability.extra and card.ability.extra.repetitions) or 2,
                card = card
            }
        end
    end
}

register_amalgam_joker {
    key = 'photo_album',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 5 },
    soul_pos = { x = 3, y = 5 },
    loc_txt = {
        name = 'Photo Album',
        text = {
            "First {C:attention}face card{} gives",
            "{X:mult,C:white}X#1#{} Mult.",
            "First played card retriggers {C:attention}#2#{} times,",
            "{C:attention}face cards{} retrigger {C:attention}#3#{} time."
        }
    },
    config = { extra = { x_mult = 2.5, first_reps = 3, face_reps = 1 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 2.5, ex.first_reps or 3, ex.face_reps or 1 } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local reps = 0
            if context.other_card == context.scoring_hand[1] then
                reps = reps + ((card.ability and card.ability.extra and card.ability.extra.first_reps) or 3)
            end
            if context.other_card:is_face() then
                reps = reps + ((card.ability and card.ability.extra and card.ability.extra.face_reps) or 1)
            end
            if reps > 0 then
                return {
                    message = localize('k_again_ex'),
                    repetitions = reps,
                    card = card
                }
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                local first_face = nil
                for _, c in ipairs(context.scoring_hand or {}) do
                    if c:is_face() then first_face = c; break end
                end
                if first_face and context.other_card == first_face then
                    return {
                        x_mult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2.5,
                        card = card
                    }
                end
            end
        end
    end
}

register_amalgam_joker {
    key = 'pirate_egg',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 6 },
    soul_pos = { x = 3, y = 6 },
    loc_txt = {
        name = 'Pirate Egg',
        text = {
            "Gains {C:money}$5{} sell value at end of round.",
            "{X:mult,C:white}X0.1{} Mult per {C:money}$1{} sell value",
            "of all owned {C:attention}Jokers{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { mult_per_dollar = 0.1 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local total_sell = 0
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                total_sell = total_sell + (j.sell_cost or 1)
            end
        end
        local xm = 1 + total_sell * 0.1
        return { vars = { string.format('%.1f', xm) } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.repetition then
            card.ability.extra_value = (card.ability.extra_value or 0) + 5
            card:set_cost()
            return {
                message = localize('k_val_up'),
                colour = G.C.MONEY,
                card = card
            }
        end
        if context.joker_main then
            local total_sell = 0
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    total_sell = total_sell + (j.sell_cost or 1)
                end
            end
            local xm = 1 + total_sell * 0.1
            if xm > 1 then
                return {
                    Xmult = xm,
                    card = card
                }
            end
        end
    end
}

register_amalgam_joker {
    key = 'reinforced_boots',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 7 },
    soul_pos = { x = 3, y = 7 },
    loc_txt = {
        name = 'Reinforced Boots',
        text = {
            "{C:mult}+10{} Mult and {C:chips}+5{} Chips",
            "for every {C:money}$1{} you have",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips and {C:mult}+#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { chips_per_dollar = 5, mult_per_dollar = 10 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local d = math.max(0, (G.GAME and G.GAME.dollars or 0) + ((G.GAME and G.GAME.dollar_buffer) or 0))
        return { vars = { d * 5, d * 10 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local d = math.max(0, (G.GAME and G.GAME.dollars or 0) + ((G.GAME and G.GAME.dollar_buffer) or 0))
            if d > 0 then
                return {
                    chips = d * 5,
                    mult = d * 10,
                    card = card
                }
            end
        end
    end
}

register_amalgam_joker {
    key = 'wee_comedian',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 8 },
    soul_pos = { x = 3, y = 8 },
    loc_txt = {
        name = 'Wee Comedian',
        text = {
            "Gains {C:chips}+10{} Chips per scored {C:attention}2{},",
            "scored {C:attention}2s{} retrigger {C:attention}2{} times",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips){}",
            "Played {C:attention}Ace, 2, 3, 5, 8{} give {C:mult}+16{} Mult."
        }
    },
    config = { extra = { chips = 0, chip_gain = 10 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.chips or 0 } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:get_id() == 2 then
                return {
                    repetitions = 2,
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            local fib = (id == 14 or id == 2 or id == 3 or id == 5 or id == 8)
            local res = {}
            if id == 2 and not context.blueprint then
                card.ability.extra.chips = (card.ability.extra.chips or 0) + 10
            end
            if fib then
                res.mult = 16
                res.card = card
                return res
            end
        end

        if context.joker_main then
            if (card.ability.extra.chips or 0) > 0 then
                return {
                    chips = card.ability.extra.chips,
                    card = card
                }
            end
        end
    end
}

register_amalgam_joker {
    key = 'golden_lucky_cat',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 9 },
    soul_pos = { x = 3, y = 9 },
    loc_txt = {
        name = 'Golden Lucky Cat',
        text = {
            "Adds {C:attention}+2{} to all {C:green}probabilities{}.",
            "Gains {X:mult,C:white}+X0.5{} Mult whenever any",
            "{C:attention}Lucky{} card or probability triggers",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { x_mult = 1.0, gain = 0.5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult or 1.0 } }
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.GAME and G.GAME.probabilities then
            G.GAME.probabilities.normal = (G.GAME.probabilities.normal or 1) + 2
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if G.GAME and G.GAME.probabilities then
            G.GAME.probabilities.normal = math.max(1, (G.GAME.probabilities.normal or 1) - 2)
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local other = context.other_card
            if other.lucky_trigger then
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) + 0.5
                return {
                    message = 'Lucky! +X0.5',
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
        if context.joker_main and (card.ability.extra.x_mult or 1.0) > 1 then
            return {
                x_mult = card.ability.extra.x_mult,
                card = card
            }
        end
    end
}

register_amalgam_joker {
    key = 'unrecognizable_antique',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 10 },
    soul_pos = { x = 3, y = 10 },
    loc_txt = {
        name = 'Unrecognizable Antique',
        text = {
            "Played cards of chosen color suit give {X:mult,C:white}X2{} Mult.",
            "{C:hearts}Hearts{} & {C:diamonds}Diamonds{} count as same suit,",
            "{C:spades}Spades{} & {C:clubs}Clubs{} count as same suit.",
            "{C:inactive}(Current suit: {C:attention}#1#{C:inactive}){}"
        }
    },
    config = { extra = { suit_group = 'Red' } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        if G.GAME and G.GAME.current_round and G.GAME.current_round.rw_antique_suit_group then
            ex.suit_group = G.GAME.current_round.rw_antique_suit_group
        end
        return { vars = { ex.suit_group or 'Red' } }
    end,
    set_ability = function(self, card, initial, delay_sprites)
        if card and card.ability and card.ability.extra then
            if G.GAME and G.GAME.current_round and G.GAME.current_round.rw_antique_suit_group then
                card.ability.extra.suit_group = G.GAME.current_round.rw_antique_suit_group
            else
                card.ability.extra.suit_group = card.ability.extra.suit_group or 'Red'
            end
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            if not (G.GAME and G.GAME.current_round and G.GAME.current_round.rw_antique_rolled) then
                if G.GAME and G.GAME.current_round then
                    G.GAME.current_round.rw_antique_rolled = true
                    G.GAME.current_round.rw_antique_suit_group = (pseudorandom('antiguedad_group') < 0.5) and 'Red' or 'Black'
                end
            end
            local grp = (G.GAME and G.GAME.current_round and G.GAME.current_round.rw_antique_suit_group) or card.ability.extra.suit_group or 'Red'
            card.ability.extra.suit_group = grp
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    local k = j.config and j.config.center and j.config.center.key
                    if (k == 'j_reality_warp_unrecognizable_antique' or k == 'unrecognizable_antique') and j.ability and j.ability.extra then
                        j.ability.extra.suit_group = grp
                    end
                end
            end
        end
        if context.end_of_round then
            if G.GAME and G.GAME.current_round then
                G.GAME.current_round.rw_antique_rolled = nil
            end
        end
        if context.individual and context.cardarea == G.play then
            local target_grp = (G.GAME and G.GAME.current_round and G.GAME.current_round.rw_antique_suit_group) or card.ability.extra.suit_group or 'Red'
            card.ability.extra.suit_group = target_grp
            local other = context.other_card
            local s = other.base and other.base.suit
            local grp = (s == 'Hearts' or s == 'Diamonds') and 'Red' or 'Black'
            if grp == target_grp then
                return {
                    x_mult = 2,
                    card = card
                }
            end
        end
    end
}

register_amalgam_joker {
    key = 'macabre_emoji',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 11 },
    soul_pos = { x = 3, y = 11 },
    loc_txt = {
        name = 'Macabre Emoji',
        text = {
            "Played {C:attention}face cards{} give",
            "{C:mult}+20{} Mult and {C:chips}+100{} Chips",
            "when scored"
        }
    },
    config = { extra = { mult = 20, chips = 100 } },
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                return {
                    mult = 20,
                    chips = 100,
                    card = card
                }
            end
        end
    end
}

if COMPONENT_JOKERS_BY_AMALGAM then
    COMPONENT_JOKERS_BY_AMALGAM['mime_king'] = { 'j_mime', 'j_baron' }
    COMPONENT_JOKERS_BY_AMALGAM['photo_album'] = { 'j_hanging_chad', 'j_photograph' }
    COMPONENT_JOKERS_BY_AMALGAM['pirate_egg'] = { 'j_swashbuckler', 'j_egg' }
    COMPONENT_JOKERS_BY_AMALGAM['reinforced_boots'] = { 'j_bootstraps', 'j_bull' }
    COMPONENT_JOKERS_BY_AMALGAM['wee_comedian'] = { 'j_wee', 'j_hiker' }
    COMPONENT_JOKERS_BY_AMALGAM['golden_lucky_cat'] = { 'j_lucky_cat', 'j_oops' }
    COMPONENT_JOKERS_BY_AMALGAM['unrecognizable_antique'] = { 'j_ancient', 'j_smeared' }
    COMPONENT_JOKERS_BY_AMALGAM['macabre_emoji'] = { 'j_smiley', 'j_scary_face' }
    COMPONENT_JOKERS_BY_AMALGAM['rey_de_mimos'] = COMPONENT_JOKERS_BY_AMALGAM['mime_king']
    COMPONENT_JOKERS_BY_AMALGAM['album_de_fotos'] = COMPONENT_JOKERS_BY_AMALGAM['photo_album']
    COMPONENT_JOKERS_BY_AMALGAM['huevo_pirata'] = COMPONENT_JOKERS_BY_AMALGAM['pirate_egg']
    COMPONENT_JOKERS_BY_AMALGAM['botas_reforzadas'] = COMPONENT_JOKERS_BY_AMALGAM['reinforced_boots']
    COMPONENT_JOKERS_BY_AMALGAM['gato_dorado_suerte'] = COMPONENT_JOKERS_BY_AMALGAM['golden_lucky_cat']
    COMPONENT_JOKERS_BY_AMALGAM['antiguedad_irreconocible'] = COMPONENT_JOKERS_BY_AMALGAM['unrecognizable_antique']
    COMPONENT_JOKERS_BY_AMALGAM['emoji_macabro'] = COMPONENT_JOKERS_BY_AMALGAM['macabre_emoji']
end

function get_active_marina()
    if not (G and G.jokers and G.jokers.cards) then return nil end
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff and card_has_key(j, 'marina') then
            return j
        end
    end
    return nil
end

local function get_marina_target(card)
    if not card or not card.ability then return nil end
    card.ability.extra = card.ability.extra or {}
    local target_id = card.ability.extra.hacked_target_id
    if G.jokers and G.jokers.cards then
        if target_id then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and (j.ID == target_id or j.sort_id == target_id) then
                    return j
                end
            end
        end
        local eligible = {}
        for _, j in ipairs(G.jokers.cards) do
            if j ~= card then
                table.insert(eligible, j)
            end
        end
        if #eligible > 0 then
            local chosen = pseudorandom_element(eligible, pseudoseed('marina_target'))
            if chosen then
                card.ability.extra.hacked_target_id = chosen.ID or chosen.sort_id
                card.ability.extra.hacked_target_name = (chosen.config and chosen.config.center and chosen.config.center.name) or "Joker"
                return chosen
            end
        end
    end
    card.ability.extra.hacked_target_id = nil
    card.ability.extra.hacked_target_name = nil
    return nil
end

local function clean_marina_temp_areas()
    if G.marina_temp_areas then
        for _, area in ipairs(G.marina_temp_areas) do
            if area.cards then
                for _, c in ipairs(area.cards) do
                    if c.remove then c:remove() end
                end
            end
            if area.remove then area:remove() end
        end
        G.marina_temp_areas = nil
    end
end

if G.FUNCS and G.FUNCS.exit_overlay_menu then
    local orig_marina_exit_overlay_menu = G.FUNCS.exit_overlay_menu
    G.FUNCS.exit_overlay_menu = function()
        clean_marina_temp_areas()
        orig_marina_exit_overlay_menu()
    end
end

local function open_marina_hack_menu(marina_card)
    if not (create_UIBox_generic_options and G.FUNCS and G.FUNCS.overlay_menu) then return end
    clean_marina_temp_areas()
    G.marina_temp_areas = {}

    local total_jokers = (G.jokers and G.jokers.cards) or {}
    local current_target = get_marina_target(marina_card)
    local cur_target_id = marina_card.ability and marina_card.ability.extra and marina_card.ability.extra.hacked_target_id

    local card_scale = (#total_jokers > 5) and 0.52 or 0.65
    local joker_cols = {}

    for _, j in ipairs(total_jokers) do
        local is_marina = (j == marina_card)
        local is_current = (current_target == j or (cur_target_id and (j.ID == cur_target_id or j.sort_id == cur_target_id)))

        local c_area = CardArea(
            0, 0,
            G.CARD_W * card_scale,
            G.CARD_H * card_scale,
            { card_limit = 1, type = 'title', highlight_limit = 0, card_w = G.CARD_W * card_scale }
        )
        table.insert(G.marina_temp_areas, c_area)
        local copy = copy_card(j, nil, card_scale)
        c_area:emplace(copy)

        local action_btn = nil
        if is_marina then
            action_btn = {
                n = G.UIT.R, config = {
                    align = "cm", minw = 1.4, minh = 0.45, r = 0.1,
                    colour = G.C.UI.BACKGROUND_INACTIVE
                },
                nodes = {
                    { n = G.UIT.T, config = { text = "MARINA (SOURCE)", scale = 0.25, colour = G.C.UI.TEXT_INACTIVE } }
                }
            }
        elseif is_current then
            action_btn = {
                n = G.UIT.R, config = {
                    align = "cm", minw = 1.4, minh = 0.45, r = 0.1,
                    colour = HEX('15803d'),
                    outline = 0.03, outline_colour = G.C.GREEN
                },
                nodes = {
                    { n = G.UIT.T, config = { text = "CURRENT TARGET", scale = 0.28, colour = G.C.WHITE, shadow = true } }
                }
            }
        else
            action_btn = {
                n = G.UIT.R, config = {
                    align = "cm", minw = 1.4, minh = 0.45, r = 0.1,
                    hover = true,
                    colour = HEX('0284c7'),
                    button = 'marina_choose_joker_target',
                    ref_table = { marina = marina_card, target = j },
                    shadow = true
                },
                nodes = {
                    { n = G.UIT.T, config = { text = "HACK TARGET", scale = 0.32, colour = G.C.WHITE, shadow = true } }
                }
            }
        end

        local j_name = (j.config and j.config.center and localize{type = 'name_text', key = j.config.center.key, set = 'Joker'}) or "Joker"

        table.insert(joker_cols, {
            n = G.UIT.C,
            config = {
                align = "cm",
                padding = 0.08,
                r = 0.12,
                colour = is_current and { 0.05, 0.2, 0.2, 0.85 } or { 0.08, 0.08, 0.12, 0.8 },
                outline = is_current and 0.04 or 0.02,
                outline_colour = is_current and HEX('28d2dc') or { 0.3, 0.3, 0.4, 0.5 }
            },
            nodes = {
                {
                    n = G.UIT.R, config = { align = "cm", padding = 0.04 },
                    nodes = { { n = G.UIT.O, config = { object = c_area } } }
                },
                {
                    n = G.UIT.R, config = { align = "cm", padding = 0.02, maxw = 1.8 },
                    nodes = {
                        { n = G.UIT.T, config = { text = j_name, scale = 0.25, colour = G.C.WHITE } }
                    }
                },
                action_btn
            }
        })
    end

    local debuffed_cards = {}
    local function collect_debuffed(area)
        if area and area.cards then
            for _, c in ipairs(area.cards) do
                if c.debuff then table.insert(debuffed_cards, c) end
            end
        end
    end
    collect_debuffed(G.jokers)
    collect_debuffed(G.hand)
    collect_debuffed(G.consumeables)

    local debuff_cols = {}
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0

    if #debuffed_cards > 0 then
        for _, c in ipairs(debuffed_cards) do
            local cost = get_marina_debuff_cost(c)
            local can_afford_repair = (cur_dollars >= cost)
            local c_area = CardArea(
                0, 0,
                G.CARD_W * 0.5,
                G.CARD_H * 0.5,
                { card_limit = 1, type = 'title', highlight_limit = 0, card_w = G.CARD_W * 0.5 }
            )
            table.insert(G.marina_temp_areas, c_area)
            local copy = copy_card(c, nil, 0.5)
            c_area:emplace(copy)

            table.insert(debuff_cols, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.06,
                    r = 0.1,
                    colour = { 0.18, 0.06, 0.06, 0.8 },
                    outline = 0.03,
                    outline_colour = G.C.RED
                },
                nodes = {
                    {
                        n = G.UIT.R, config = { align = "cm", padding = 0.03 },
                        nodes = { { n = G.UIT.O, config = { object = c_area } } }
                    },
                    {
                        n = G.UIT.R, config = {
                            align = "cm", minw = 1.2, minh = 0.4, r = 0.08,
                            hover = can_afford_repair,
                            colour = can_afford_repair and HEX('16a34a') or G.C.UI.BACKGROUND_INACTIVE,
                            button = can_afford_repair and 'marina_menu_repair_card' or nil,
                            ref_table = { marina = marina_card, card = c },
                            shadow = can_afford_repair
                        },
                        nodes = {
                            { n = G.UIT.T, config = { text = "REPAIR ($" .. tostring(cost) .. ")", scale = 0.28, colour = can_afford_repair and G.C.WHITE or G.C.UI.TEXT_INACTIVE, shadow = can_afford_repair } }
                        }
                    }
                }
            })
        end
    end

    local contents = {
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.1 },
            nodes = {
                { n = G.UIT.T, config = { text = "MARINA'S HACK TERMINAL", scale = 0.55, colour = HEX('28d2dc'), shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.03 },
            nodes = {
                { n = G.UIT.T, config = { text = "Select a target Joker to trigger +3 extra times on every calculation:", scale = 0.32, colour = G.C.WHITE } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.08, colour = HEX('0f172a'), r = 0.15, outline = 0.03, outline_colour = HEX('28d2dc') },
            nodes = (#joker_cols > 0) and joker_cols or {
                { n = G.UIT.T, config = { text = "No other Jokers available to hack!", scale = 0.35, colour = G.C.UI.TEXT_INACTIVE } }
            }
        }
    }

    if #debuffed_cards > 0 then
        table.insert(contents, {
            n = G.UIT.R, config = { align = "cm", padding = 0.06 },
            nodes = {
                { n = G.UIT.T, config = { text = "DEBUFFED CARDS OVERRIDE ($1 Cards / $5 Jokers):", scale = 0.34, colour = HEX('fbbf24'), shadow = true } }
            }
        })
        table.insert(contents, {
            n = G.UIT.R, config = { align = "cm", padding = 0.06, colour = HEX('18181b'), r = 0.12, outline = 0.02, outline_colour = HEX('fbbf24') },
            nodes = debuff_cols
        })
    end

    local t = create_UIBox_generic_options({
        back_func = 'exit_overlay_menu',
        back_label = "Close",
        contents = contents
    })
    G.FUNCS.overlay_menu{ definition = t }
end

G.FUNCS = G.FUNCS or {}

G.FUNCS.marina_open_hack_menu = function(e)
    local card = e.config.ref_table
    if card then
        open_marina_hack_menu(card)
    end
end

G.FUNCS.marina_choose_joker_target = function(e)
    local marina = e.config.ref_table.marina
    local target = e.config.ref_table.target
    if marina and target then
        marina.ability.extra = marina.ability.extra or {}
        marina.ability.extra.hacked_target_id = target.ID or target.sort_id
        marina.ability.extra.hacked_target_name = (target.config and target.config.center and target.config.center.name) or "Joker"
        play_sound('chips2')
        target:juice_up(0.7, 0.7)
        marina:juice_up(0.7, 0.7)
        card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'HACKED (+3)!', colour = HEX('28d2dc') })
        G.FUNCS.exit_overlay_menu()
    end
end

G.FUNCS.marina_menu_repair_card = function(e)
    local marina = e.config.ref_table.marina
    local card = e.config.ref_table.card
    local cost = get_marina_debuff_cost(card)
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= cost and card then
        ease_dollars(-cost)
        card.marina_repaired = true
        card:set_debuff(false)
        card.debuff = false
        play_sound('coin3')
        card:juice_up(0.6, 0.6)
        if marina then marina:juice_up(0.5, 0.5) end
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'UNHACKED!', colour = HEX('28d2dc') })
        open_marina_hack_menu(marina)
    end
end

G.FUNCS.can_marina_hack_debuff = function(e)
    local card = e.config.ref_table
    local cost = get_marina_debuff_cost(card)
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= cost and card and card.debuff and not (G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND or G.STATE == G.STATES.PLAY_TAROT) then
        e.config.colour = HEX('28d2dc')
        e.config.button = 'marina_hack_debuff_card'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.marina_hack_debuff_card = function(e)
    local card = e.config.ref_table
    local cost = get_marina_debuff_cost(card)
    local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
    if cur_dollars >= cost and card and card.debuff then
        ease_dollars(-cost)
        card.marina_repaired = true
        card:set_debuff(false)
        card.debuff = false
        play_sound('coin3')
        card:juice_up(0.6, 0.6)
        if card.children and card.children.use_button then
            card.children.use_button:remove()
            card.children.use_button = nil
        end
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'UNHACKED!', colour = HEX('28d2dc') })
        local marina = get_active_marina()
        if marina then marina:juice_up(0.5, 0.5) end
    end
end

if Card and Card.set_debuff then
    local orig_marina_set_debuff = Card.set_debuff
    function Card:set_debuff(should_debuff)
        if self.marina_repaired then
            self.debuff = false
            return orig_marina_set_debuff(self, false)
        end
        return orig_marina_set_debuff(self, should_debuff)
    end
end

local orig_marina_reset_blind = reset_blind
function reset_blind()
    if G.hand and G.hand.cards then for _, c in ipairs(G.hand.cards) do c.marina_repaired = nil end end
    if G.deck and G.deck.cards then for _, c in ipairs(G.deck.cards) do c.marina_repaired = nil end end
    if G.jokers and G.jokers.cards then for _, c in ipairs(G.jokers.cards) do c.marina_repaired = nil end end
    if orig_marina_reset_blind then return orig_marina_reset_blind() end
end

if Card and Card.highlight then
    local orig_marina_highlight = Card.highlight
    function Card:highlight(is_highlighted)
        local ret = orig_marina_highlight(self, is_highlighted)
        if self.debuff and get_active_marina and get_active_marina() and self.area == G.hand then
            if is_highlighted then
                if not self.children.use_button and G.UIDEF and G.UIDEF.use_and_sell_buttons then
                    local btns = G.UIDEF.use_and_sell_buttons(self)
                    if btns then
                        self.children.use_button = UIBox{
                            definition = btns,
                            config = { align = "bm", offset = { x = 0, y = 0.5 }, parent = self }
                        }
                    end
                end
            else
                if self.children.use_button then
                    self.children.use_button:remove()
                    self.children.use_button = nil
                end
            end
        end
        return ret
    end
end

register_secret_joker {
    key = 'marina',
    atlas = 'secret_jokers',
    pos = { x = 0, y = 17 },
    soul_pos = { x = 1, y = 17 },
    loc_txt = {
        name = 'Marina',
        text = {
            "Hacks a random Joker, causing its",
            "effects to repeat {C:attention}#1#{} additional times.",
            "{C:inactive}(Currently Hacking: {C:attention}#2#{}{C:inactive}){}",
            "Use {C:green}Hack{} to manually select a target,",
            "or reactivate debuffed {C:attention}cards{} ({C:money}$#3#{})",
            "and {C:attention}Jokers{} ({C:money}$#4#{})."
        }
    },
    config = { extra = { repetitions = 3, cost_card = 1, cost_joker = 5 } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local target = get_marina_target(card)
        local target_name = "None"
        if target and target.config and target.config.center then
            target_name = localize{type = 'name_text', key = target.config.center.key, set = 'Joker'}
            if not target_name or target_name == '' or string.find(target_name, 'ERROR') then
                target_name = target.config.center.name or "Joker"
            end
        end
        return {
            vars = {
                (card.ability and card.ability.extra and card.ability.extra.repetitions) or 3,
                target_name,
                (card.ability and card.ability.extra and card.ability.extra.cost_card) or 1,
                (card.ability and card.ability.extra and card.ability.extra.cost_joker) or 5
            }
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        get_marina_target(card)
    end,
    calculate = function(self, card, context)
        if (context.retrigger_joker_check or context.retrigger_joker) and not context.retrigger_joker then
            local target = get_marina_target(card)
            if target and context.other_card == target then
                return {
                    message = localize('k_again_ex'),
                    repetitions = (card.ability and card.ability.extra and card.ability.extra.repetitions) or 3,
                    card = card
                }
            end
        end
    end
}

register_secret_joker {
    key = 'perla',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 12 },
    soul_pos = { x = 3, y = 12 },
    loc_txt = {
        name = 'Pearl',
        text = {
            "{C:attention}Interest{} has no limit."
        }
    },
    config = { extra = {} },
    blueprint_compat = true,
    add_to_deck = function(self, card, from_debuff)
        card.ability.extra_orig_interest_cap = G.GAME.interest_cap or 25
        G.GAME.interest_cap = 999999999
        G.GAME.perla_active = true
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.interest_cap = card.ability.extra_orig_interest_cap or 25
        G.GAME.perla_active = nil
    end,
    calculate = function(self, card, context)
    end
}

register_secret_joker {
    key = 'espectro_del_balance',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 13 },
    soul_pos = { x = 3, y = 13 },
    loc_txt = {
        name = 'Balance Spectre',
        text = {
            "Balances {C:chips}Chips{} and {C:mult}Mult{}",
            "when scoring hand.",
            "{C:inactive}(Plasma Deck effect){}"
        }
    },
    config = { extra = {} },
    blueprint_compat = true,
    calculate = function(self, card, context)
        if (context.joker_main and not context.debuffed_hand) or context.forcetrigger then
            return {
                balance = true,
            }
        end
    end
}

if SMODS and SMODS.Sound then
    SMODS.Sound {
        key = 'pink_gasp',
        path = 'pink-gasp.mp3',
    }
    SMODS.Sound {
        key = 'pink_surprise',
        path = 'pink_surprise.mp3',
    }
end

local function play_mew_sound(sound_key, pitch, volume)
    pitch = pitch or 1
    volume = volume or 1
    local candidates = {
        'reality_warp_' .. sound_key,
        sound_key,
        'reality_warp_' .. sound_key:gsub('_', '-'),
        sound_key:gsub('_', '-')
    }
    for _, k in ipairs(candidates) do
        if G.AUDIO and G.AUDIO[k] then
            play_sound(k, pitch, volume)
            return
        end
    end
    pcall(play_sound, 'reality_warp_' .. sound_key, pitch, volume)
end

local function trigger_mega_flirt_visual()
    if ease_background_colour then
        ease_background_colour {
            new_colour = HEX('f472b6'),
            special_colour = HEX('fb7185'),
            contrast = 2,
            _is_reality_warp_theme = true,
            _mega_flirt = true
        }
    end

    if G.GAME then
        G.GAME.mega_flirt_until = ((G.TIMERS and G.TIMERS.REAL) or (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0) + 5.0
    end

    G.reality_warp_mega_flirt_hearts = G.reality_warp_mega_flirt_hearts or {}
    local screen_w = (love and love.graphics and love.graphics.getWidth and love.graphics.getWidth()) or 1920
    local screen_h = (love and love.graphics and love.graphics.getHeight and love.graphics.getHeight()) or 1080
    local heart_palette = {
        { 0.98, 0.42, 0.65, 0.95 },
        { 0.96, 0.28, 0.55, 0.90 },
        { 1.00, 0.65, 0.82, 0.95 },
        { 0.95, 0.15, 0.45, 0.85 },
        { 1.00, 0.80, 0.90, 0.95 }
    }

    for _ = 1, 36 do
        local max_l = 4.0 + (math.random() * 1.0)
        table.insert(G.reality_warp_mega_flirt_hearts, {
            x = math.random() * screen_w,
            y = (screen_h * 0.35) + math.random() * (screen_h * 0.75),
            speed = 90 + math.random() * 140,
            sway = 25 + math.random() * 35,
            phase = math.random() * 6.28,
            size = 22 + math.random() * 26,
            rot = (math.random() - 0.5) * 0.4,
            life = max_l,
            max_life = max_l,
            alpha = 0,
            color = heart_palette[math.random(1, #heart_palette)]
        })
    end

    if Particles and G.ROOM_ATTACH then
        local p = Particles(0, 0, 0, 0, {
            timer = 0.02,
            pulse_max = 28,
            max = 0,
            scale = 0.38,
            speed = 1.3,
            lifespan = 2.2,
            attach = G.ROOM_ATTACH,
            colours = { HEX('ec4899'), HEX('f472b6'), HEX('fb7185'), HEX('ffffff'), HEX('f43f5e'), HEX('fda4af') },
            fill = true
        })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 4.5,
            blockable = false,
            blocking = false,
            func = function()
                if p and p.fade then p:fade(0.5, 1) end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 5.2,
            blockable = false,
            blocking = false,
            func = function()
                if p and p.remove then p:remove() end
                return true
            end
        }))
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 5.0,
        blockable = false,
        blocking = false,
        func = function()
            if G.GAME then G.GAME.mega_flirt_until = nil end
            if ease_background_colour_blind then
                ease_background_colour_blind(G.STATE or G.STATES.SELECTING_HAND)
            elseif ease_background_colour then
                local bg_col = (G.C and G.C.BLIND and G.C.BLIND['Small']) or (G.C and G.C.BACKGROUND and G.C.BACKGROUND.D) or HEX('374244')
                ease_background_colour{
                    new_colour = bg_col,
                    special_colour = bg_col,
                    contrast = 1
                }
            end
            return true
        end
    }))
end

if Game and Game.update then
    local orig_game_update = Game.update
    function Game:update(dt)
        orig_game_update(self, dt)
        if G.reality_warp_mega_flirt_hearts and #G.reality_warp_mega_flirt_hearts > 0 then
            local t = (love and love.timer and love.timer.getTime and love.timer.getTime()) or ((G.TIMERS and G.TIMERS.REAL) or 0)
            for i = #G.reality_warp_mega_flirt_hearts, 1, -1 do
                local h = G.reality_warp_mega_flirt_hearts[i]
                h.life = h.life - dt
                if h.life <= 0 then
                    table.remove(G.reality_warp_mega_flirt_hearts, i)
                else
                    h.y = h.y - h.speed * dt
                    h.x = h.x + math.sin(t * 2.8 + h.phase) * (h.sway * dt)
                    h.rot = math.sin(t * 2.0 + h.phase) * 0.22
                    if h.life < 0.8 then
                        h.alpha = math.max(0, h.life / 0.8)
                    elseif (h.max_life - h.life) < 0.4 then
                        h.alpha = math.min(1, (h.max_life - h.life) / 0.4)
                    else
                        h.alpha = 1.0
                    end
                end
            end
        end
    end
end

local function has_mew_mew_active()
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            local k = j.config and j.config.center and j.config.center.key
            if k == 'j_reality_warp_mew_mew' or k == 'mew_mew' then
                return true
            end
        end
    end
    if G.hand and G.hand.cards then
        for _, c in ipairs(G.hand.cards) do
            local k = c.config and c.config.center and c.config.center.key
            if k == 'j_reality_warp_mew_mew' or k == 'mew_mew' then
                return true
            end
        end
    end
    return false
end

local function get_mew_mew_asset(name)
    G.mew_mew_asset_cache = G.mew_mew_asset_cache or {}
    if G.mew_mew_asset_cache[name] then return G.mew_mew_asset_cache[name] end
    local raw_path = (reality_warp_MOD and reality_warp_MOD.path) or (SMODS and SMODS.current_mod and SMODS.current_mod.path) or "Mods/Balatro Reality Warp/"
    local mod_path = (string.sub(raw_path, -1) == '/' or string.sub(raw_path, -1) == '\\') and raw_path or (raw_path .. '/')
    local scale = (G.SETTINGS and G.SETTINGS.GRAPHICS and G.SETTINGS.GRAPHICS.texture_scaling) or 2
    local candidates = {
        mod_path .. "assets/" .. scale .. "x/" .. name .. ".png",
        mod_path .. "assets/2x/" .. name .. ".png",
        mod_path .. "assets/1x/" .. name .. ".png"
    }
    for _, full_path in ipairs(candidates) do
        if nfs and nfs.getInfo and nfs.getInfo(full_path) then
            local file_data = nfs.newFileData(full_path)
            if file_data then
                local img_data = love.image.newImageData(file_data)
                G.mew_mew_asset_cache[name] = love.graphics.newImage(img_data)
                return G.mew_mew_asset_cache[name]
            end
        elseif love.filesystem and love.filesystem.getInfo and love.filesystem.getInfo(full_path) then
            G.mew_mew_asset_cache[name] = love.graphics.newImage(full_path)
            return G.mew_mew_asset_cache[name]
        end
    end
    return nil
end

local function trigger_mew_mew_celebration()
    G.reality_warp_mega_flirt_hearts = G.reality_warp_mega_flirt_hearts or {}
    local sw = (love and love.graphics and love.graphics.getWidth and love.graphics.getWidth()) or 1920
    local sh = (love and love.graphics and love.graphics.getHeight and love.graphics.getHeight()) or 1080
    local scale = math.max(1.5, math.min(3.0, sh / 440))
    local heart_palette = {
        { 0.98, 0.42, 0.65, 0.95 },
        { 0.96, 0.28, 0.55, 0.90 },
        { 1.00, 0.65, 0.82, 0.95 },
        { 0.95, 0.15, 0.45, 0.85 },
        { 1.00, 0.80, 0.90, 0.95 },
        { 1.00, 1.00, 1.00, 0.95 }
    }
    for i = 0, 4 do
        local rx = 0.88 - i * 0.19
        local dw = 61 * scale
        local dh = 38 * scale
        local dx = sw * rx - (dw * 0.5)
        local dy = sh - dh + (8 * scale)
        for _ = 1, 5 do
            local max_l = 1.8 + math.random() * 1.2
            table.insert(G.reality_warp_mega_flirt_hearts, {
                x = dx + (dw * 0.5) + (math.random() - 0.5) * (dw * 0.7),
                y = dy - (math.random() * 25),
                speed = 130 + math.random() * 150,
                sway = 28 + math.random() * 35,
                phase = math.random() * 6.28,
                size = 18 + math.random() * 18,
                rot = (math.random() - 0.5) * 0.4,
                life = max_l,
                max_life = max_l,
                alpha = 0,
                color = heart_palette[math.random(1, #heart_palette)]
            })
        end
    end
    play_sound('tarot1', 1.35, 0.5)
end

if not G.reality_warp_mega_flirt_draw_hooked and love and love.draw then
    G.reality_warp_mega_flirt_draw_hooked = true
    local orig_love_draw = love.draw
    love.draw = function(...)
        orig_love_draw(...)
        local hearts = G.reality_warp_mega_flirt_hearts
        if hearts and #hearts > 0 and love and love.graphics then
            love.graphics.push('all')
            love.graphics.origin()
            love.graphics.setShader()
            for i = 1, #hearts do
                local h = hearts[i]
                local alpha = h.alpha or 1
                if alpha > 0.01 then
                    local col = h.color or { 1, 0.4, 0.7, 1 }
                    local r = h.size * 0.5
                    love.graphics.push()
                    love.graphics.translate(h.x, h.y)
                    if h.rot then love.graphics.rotate(h.rot) end
                    love.graphics.setColor(col[1], col[2], col[3], alpha * (col[4] or 1))
                    love.graphics.circle('fill', -r * 0.48, -r * 0.2, r * 0.52)
                    love.graphics.circle('fill', r * 0.48, -r * 0.2, r * 0.52)
                    love.graphics.polygon('fill', -r * 0.96, -r * 0.08, r * 0.96, -r * 0.08, 0, r * 1.08)
                    love.graphics.pop()
                end
            end
            love.graphics.pop()
        end
    end
end

local function pick_mew_mew_hand(card)
    local available = {}
    if G.GAME and G.GAME.hands then
        local current = (G.GAME.current_round and G.GAME.current_round.mew_mew_hand) or (card and card.ability and card.ability.extra and card.ability.extra.target_hand) or ''
        for h, _ in pairs(G.GAME.hands) do
            if (not SMODS or not SMODS.is_poker_hand_visible or SMODS.is_poker_hand_visible(h)) and h ~= current then
                table.insert(available, h)
            end
        end
    end
    if #available == 0 then
        available = { 'Pair', 'Two Pair', 'Three of a Kind', 'Full House', 'Flush', 'Straight' }
    end
    local hand = pseudorandom_element(available, 'mew_mew')
    if G.GAME and G.GAME.current_round then
        G.GAME.current_round.mew_mew_hand = hand
    end
    return hand
end

local function sync_all_mew_mew(chosen_hand)
    if G.GAME and G.GAME.current_round and chosen_hand then
        G.GAME.current_round.mew_mew_hand = chosen_hand
    end
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            local k = j.config and j.config.center and j.config.center.key
            if (k == 'j_reality_warp_mew_mew' or k == 'mew_mew') and j.ability and j.ability.extra then
                j.ability.extra.target_hand = chosen_hand
            end
        end
    end
end

local function spawn_mew_mew_heart_burst(card)
    local click_x, click_y
    if G.CONTROLLER and G.CONTROLLER.cursor_position and G.CONTROLLER.cursor_position.x then
        click_x = G.CONTROLLER.cursor_position.x
        click_y = G.CONTROLLER.cursor_position.y
    elseif card and card.VT and card.VT.x and G.TILESCALE and G.TILESIZE then
        local room_x = (G.ROOM and G.ROOM.T and G.ROOM.T.x) or 0
        local room_y = (G.ROOM and G.ROOM.T and G.ROOM.T.y) or 0
        click_x = (card.VT.x + (card.VT.w or 1) * 0.5) * (G.TILESCALE * G.TILESIZE) + room_x
        click_y = (card.VT.y + (card.VT.h or 1) * 0.5) * (G.TILESCALE * G.TILESIZE) + room_y
    else
        local screen_w = (love and love.graphics and love.graphics.getWidth and love.graphics.getWidth()) or 1920
        local screen_h = (love and love.graphics and love.graphics.getHeight and love.graphics.getHeight()) or 1080
        click_x = screen_w * 0.5
        click_y = screen_h * 0.5
    end

    G.reality_warp_mega_flirt_hearts = G.reality_warp_mega_flirt_hearts or {}
    local heart_palette = {
        { 0.98, 0.42, 0.65, 0.95 },
        { 0.96, 0.28, 0.55, 0.90 },
        { 1.00, 0.65, 0.82, 0.95 },
        { 0.95, 0.15, 0.45, 0.85 },
        { 1.00, 0.80, 0.90, 0.95 }
    }

    for _ = 1, 14 do
        local max_l = 1.0 + (math.random() * 0.7)
        table.insert(G.reality_warp_mega_flirt_hearts, {
            x = click_x + (math.random() - 0.5) * 60,
            y = click_y + (math.random() - 0.5) * 35,
            speed = 110 + math.random() * 95,
            sway = 22 + math.random() * 25,
            phase = math.random() * 6.28,
            size = 9 + math.random() * 8,
            rot = (math.random() - 0.5) * 0.45,
            life = max_l,
            max_life = max_l,
            alpha = 0,
            color = heart_palette[math.random(1, #heart_palette)]
        })
    end

    if Particles and card and card.T then
        local p = Particles(card.T.x, card.T.y, card.T.w or 1, card.T.h or 1, {
            timer = 0.02,
            pulse_max = 16,
            max = 0,
            scale = 0.26,
            speed = 1.3,
            lifespan = 0.7,
            attach = G.ROOM_ATTACH or card,
            colours = { HEX('ec4899'), HEX('f472b6'), HEX('fb7185'), HEX('ffffff'), HEX('f43f5e'), HEX('fda4af') },
            fill = true
        })
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            blockable = false,
            blocking = false,
            func = function()
                if p and p.fade then p:fade(0.3, 1) end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.9,
            blockable = false,
            blocking = false,
            func = function()
                if p and p.remove then p:remove() end
                return true
            end
        }))
    end
end

if Card and Card.click then
    local orig_card_click = Card.click
    function Card:click(...)
        local is_mew = (self.config and self.config.center and (self.config.center.key == 'j_reality_warp_mew_mew' or self.config.center.key == 'mew_mew'))
        if not is_mew and type(card_has_key) == 'function' then
            is_mew = card_has_key(self, 'mew_mew')
        end

        if is_mew then
            local now = (love and love.timer and love.timer.getTime and love.timer.getTime()) or ((G.TIMERS and G.TIMERS.REAL) or 0)
            if self.mew_last_click and (now - self.mew_last_click) < 1.2 then
                self.mew_click_count = (self.mew_click_count or 0) + 1
            else
                self.mew_click_count = 1
            end
            self.mew_last_click = now

            if self.mew_click_count >= 5 then
                play_mew_sound('pink_surprise', 1.0 + (math.random() - 0.5) * 0.1, 1.0)
                self:juice_up(0.6, 0.5)
                spawn_mew_mew_heart_burst(self)
            else
                play_mew_sound('pink_gasp', 0.95 + math.random() * 0.1, 0.9)
                self:juice_up(0.25, 0.2)
            end
        end

        return orig_card_click(self, ...)
    end
end

register_secret_joker {
    key = 'mew_mew',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 14 },
    soul_pos = { x = 3, y = 14 },
    cost = 20,
    blueprint_compat = true,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge('Outsider', HEX('000000'), G.C.WHITE, 1.2)
    end,
    set_badges = function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Outsider', HEX('000000'), G.C.WHITE, 1.2)
        end
        badges[#badges + 1] = create_badge('Mew mew!', HEX('ec4899'), G.C.WHITE, 1.0)
    end,
    config = { extra = { xmult = 1.5, xmult_gain = 0.25, target_hand = 'Pair' } },
    loc_txt = {
        name = 'Mew mew!',
        text = {
            "Played cards each give {X:mult,C:white}X#1#{} Mult.",
            "Increases by {X:mult,C:white}+X#2#{} Mult when",
            "{C:attention}#3#{} is played",
            "{C:inactive}(Poker hand changes each played hand){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        if G.GAME and G.GAME.current_round and G.GAME.current_round.mew_mew_hand then
            ex.target_hand = G.GAME.current_round.mew_mew_hand
        end
        local xmult = ex.xmult or 1.5
        local gain = ex.xmult_gain or 0.25
        local target = ex.target_hand or 'Pair'
        local target_loc = (type(localize) == 'function' and localize(target, 'poker_hands')) or target
        if info_queue and G.P_CENTERS and (G.P_CENTERS.j_reality_warp_mad_ghost or G.P_CENTERS.mad_ghost) then
            info_queue[#info_queue + 1] = G.P_CENTERS.j_reality_warp_mad_ghost or G.P_CENTERS.mad_ghost
        end
        return { vars = { xmult, gain, target_loc } }
    end,
    set_ability = function(self, card, initial, delay_sprites)
        if card and card.ability and card.ability.extra then
            if G.GAME and G.GAME.current_round and G.GAME.current_round.mew_mew_hand then
                card.ability.extra.target_hand = G.GAME.current_round.mew_mew_hand
            elseif not card.ability.extra.target_hand or card.ability.extra.target_hand == '' then
                card.ability.extra.target_hand = 'Pair'
            end
            card.ability.extra.xmult = card.ability.extra.xmult or 1.5
            card.ability.extra.xmult_gain = card.ability.extra.xmult_gain or 0.25
        end
    end,
    calculate = function(self, card, context)
        local ex = card.ability and card.ability.extra
        if not ex then return end

        if context.setting_blind and not context.blueprint then
            if not (G.GAME and G.GAME.current_round and G.GAME.current_round.mew_mew_hand) or not ex.target_hand or ex.target_hand == '' then
                local h = pick_mew_mew_hand(card)
                sync_all_mew_mew(h)
            else
                ex.target_hand = G.GAME.current_round.mew_mew_hand
            end
        end

        if context.before and not context.blueprint then
            if G.GAME and G.GAME.current_round then
                G.GAME.current_round.mew_mew_rerolled_this_hand = nil
            end
            if not (G.GAME and G.GAME.current_round and G.GAME.current_round.mew_mew_hand) or not ex.target_hand or ex.target_hand == '' then
                local h = pick_mew_mew_hand(card)
                sync_all_mew_mew(h)
            else
                ex.target_hand = G.GAME.current_round.mew_mew_hand
            end
            if context.scoring_name == ex.target_hand then
                local old_xmult = ex.xmult or 1.5
                ex.xmult = (ex.xmult or 1.5) + (ex.xmult_gain or 0.25)
                play_mew_sound('pink_gasp')

                ex.last_celebration_mult = ex.last_celebration_mult or math.floor(old_xmult)
                if math.floor(ex.xmult) > ex.last_celebration_mult then
                    ex.last_celebration_mult = math.floor(ex.xmult)
                    pcall(trigger_mew_mew_celebration)
                end

                return {
                    message = 'Upgrade! X' .. string.format('%.2f', ex.xmult),
                    colour = HEX('ec4899'),
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            return {
                x_mult = ex.xmult or 1.5,
                card = card
            }
        end

        if context.after and not context.blueprint then
            if not (G.GAME and G.GAME.current_round and G.GAME.current_round.mew_mew_rerolled_this_hand) then
                if G.GAME and G.GAME.current_round then
                    G.GAME.current_round.mew_mew_rerolled_this_hand = true
                end
                local h = pick_mew_mew_hand(card)
                sync_all_mew_mew(h)
            elseif G.GAME and G.GAME.current_round and G.GAME.current_round.mew_mew_hand then
                ex.target_hand = G.GAME.current_round.mew_mew_hand
            end
        end
    end
}

register_secret_joker {
    key = 'mad_ghost',
    atlas = 'secret_jokers',
    pos = { x = 2, y = 15 },
    soul_pos = { x = 3, y = 15 },
    cost = 20,
    blueprint_compat = false,
    no_collection = true,
    omit = true,
    in_pool = function(self, args)
        return false, { allow_duplicates = false }
    end,
    set_card_type_badge = function(self, card, badges)
        badges[1] = create_badge('Outsider', HEX('000000'), G.C.WHITE, 1.2)
    end,
    set_badges = function(self, card, badges)
        if badges and #badges > 0 then
            badges[1] = create_badge('Outsider', HEX('000000'), G.C.WHITE, 1.2)
        end
        badges[#badges + 1] = create_badge('Mad Ghost', HEX('9333ea'), G.C.WHITE, 1.0)
    end,
    config = {},
    loc_txt = {
        name = 'Mad Ghost',
        text = {
            "Mew mew's companion"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end
}



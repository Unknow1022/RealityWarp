-- ============================================================================
-- Reality Warp - Game Mode: "Apagón" (Blackout)
-- ============================================================================

G.apagon_active = false
G.apagon_intro_timer = 0
G.apagon_lantern_on = false
G.apagon_ghosts = {}
G.apagon_particles = {}
G.apagon_spawn_timer = 0
G.apagon_dissolve_particles = {}

local JOKER_GHOST_KEYS = {
    'j_joker', 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker',
    'j_gluttenous_joker', 'j_jolly', 'j_zany', 'j_mad', 'j_crazy',
    'j_droll', 'j_sly', 'j_wily', 'j_clever', 'j_devious', 'j_crafty',
    'j_half', 'j_mime', 'j_credit_card', 'j_ceremonial', 'j_banner',
    'j_mystic_summit', 'j_marble', 'j_loyalty_card', 'j_dusk', 'j_fibonacci'
}

-- ----------------------------------------------------------------------------
-- Mode Launch Handler
-- ----------------------------------------------------------------------------

G.FUNCS = G.FUNCS or {}

G.FUNCS.reality_warp_start_apagon_run = function(e)
    G.SETTINGS.paused = false
    if G.OVERLAY_MENU then
        G.FUNCS.exit_overlay_menu()
    end

    G.apagon_active = true
    G.apagon_intro_timer = 0
    G.apagon_lantern_on = false
    G.apagon_ghosts = {}
    G.apagon_particles = {}
    G.apagon_dissolve_particles = {}
    G.apagon_spawn_timer = 3.0

    if G.FUNCS and G.FUNCS.start_run then
        G.FUNCS.start_run(e or { config = {} }, {
            deck = 'b_red',
            stake = 1
        })
    end
    if G.GAME then
        G.GAME.apagon_active = true
    end
end

-- ----------------------------------------------------------------------------
-- State Synchronization Hook (Start & End of Runs)
-- ----------------------------------------------------------------------------

local orig_game_start_run = Game.start_run
function Game:start_run(args)
    if orig_game_start_run then orig_game_start_run(self, args) end
    if self.GAME and self.GAME.apagon_active then
        G.apagon_active = true
        G.apagon_intro_timer = 0
        G.apagon_lantern_on = false
        G.apagon_ghosts = {}
        G.apagon_particles = {}
        G.apagon_dissolve_particles = {}
        G.apagon_spawn_timer = 3.0
    else
        G.apagon_active = false
        G.apagon_ghosts = {}
        G.apagon_particles = {}
    end
end

-- ----------------------------------------------------------------------------
-- Game Update Loop: Flashlight & Ghost Spawning / Banishment
-- ----------------------------------------------------------------------------

local orig_game_update = Game.update
function Game:update(dt)
    if orig_game_update then orig_game_update(self, dt) end

    if not G.apagon_active or not G.GAME or not G.GAME.apagon_active then return end
    if G.SETTINGS.paused then return end

    local mx, my = love.mouse.getPosition()
    local t = love.timer and love.timer.getTime() or 0

    -- 1. Intro sequence: pitch darkness until lantern sparks
    if not G.apagon_lantern_on then
        G.apagon_intro_timer = G.apagon_intro_timer + dt
        if G.apagon_intro_timer >= 1.2 then
            G.apagon_lantern_on = true
            play_sound('fire1', 1.15, 0.85)
            play_sound('tarot1', 1.3, 0.7)
            -- Initial fiery burst at mouse
            for _ = 1, 24 do
                table.insert(G.apagon_particles, {
                    x = mx + math.random(-15, 15),
                    y = my + math.random(-15, 15),
                    vx = math.random(-60, 60),
                    vy = math.random(-120, -30),
                    life = 0.6 + math.random() * 0.4,
                    max_life = 0.8,
                    size = math.random(4, 9),
                    col = ({
                        {1.0, 0.25, 0.1},
                        {1.0, 0.60, 0.05},
                        {1.0, 0.90, 0.2}
                    })[math.random(1, 3)]
                })
            end
        end
        return
    end

    -- 2. Emit fiery orange, red, and yellow lantern particles at cursor
    for _ = 1, 2 do
        table.insert(G.apagon_particles, {
            x = mx + math.random(-6, 6),
            y = my + math.random(-6, 6),
            vx = math.random(-20, 20),
            vy = math.random(-65, -20),
            life = 0.4 + math.random() * 0.35,
            max_life = 0.6,
            size = math.random(3, 7),
            col = ({
                {0.95, 0.22, 0.12}, -- Fire Red
                {0.98, 0.58, 0.08}, -- Warm Orange
                {1.00, 0.88, 0.22}  -- Bright Yellow
            })[math.random(1, 3)]
        })
    end

    -- Update lantern particles
    for i = #G.apagon_particles, 1, -1 do
        local p = G.apagon_particles[i]
        p.life = p.life - dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        if p.life <= 0 then
            table.remove(G.apagon_particles, i)
        end
    end

    -- Update ghost banishment dissolve particles
    for i = #G.apagon_dissolve_particles, 1, -1 do
        local p = G.apagon_dissolve_particles[i]
        p.life = p.life - dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        if p.life <= 0 then
            table.remove(G.apagon_dissolve_particles, i)
        end
    end

    -- 3. Spawn wandering Ghost Jokers
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()
    G.apagon_spawn_timer = G.apagon_spawn_timer - dt

    if G.apagon_spawn_timer <= 0 and #G.apagon_ghosts < 7 then
        G.apagon_spawn_timer = 4.0 + math.random() * 3.0
        local spawn_left = math.random() < 0.5
        local gx = spawn_left and -50 or (sw + 50)
        local gy = math.random(120, math.max(150, sh - 180))
        local speed = 35 + math.random() * 45
        local vx = spawn_left and speed or -speed
        local vy = (math.random() - 0.5) * 30
        local j_key = JOKER_GHOST_KEYS[math.random(#JOKER_GHOST_KEYS)]

        table.insert(G.apagon_ghosts, {
            x = gx,
            y = gy,
            vx = vx,
            vy = vy,
            base_y = gy,
            key = j_key,
            health = 1.0,
            max_health = 1.0,
            seed = math.random(1, 99999),
            hover_time = 0
        })
        play_sound('whoosh', 0.85, 0.6)
    end

    -- 4. Update Ghosts & Check Lantern Collision
    local lantern_radius = 165 + math.sin(t * 5.0) * 8

    for i = #G.apagon_ghosts, 1, -1 do
        local g = G.apagon_ghosts[i]
        g.x = g.x + g.vx * dt
        g.y = g.base_y + math.sin(t * 2.2 + g.seed) * 35

        -- Bounce off screen edges
        if g.x < 30 and g.vx < 0 then g.vx = -g.vx end
        if g.x > sw - 30 and g.vx > 0 then g.vx = -g.vx end
        if g.base_y < 100 then g.base_y = 100 end
        if g.base_y > sh - 160 then g.base_y = sh - 160 end

        -- Check distance to lantern
        local dx = g.x - mx
        local dy = g.y - my
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist <= lantern_radius then
            -- Shining lantern on ghost drains its health!
            g.health = g.health - dt / 1.15
            g.hover_time = g.hover_time + dt
            -- Emit spectral spark particles
            table.insert(G.apagon_dissolve_particles, {
                x = g.x + math.random(-25, 25),
                y = g.y + math.random(-25, 25),
                vx = math.random(-40, 40),
                vy = math.random(-60, 20),
                life = 0.35 + math.random() * 0.25,
                max_life = 0.5,
                size = math.random(3, 6),
                col = {0.45, 0.85, 1.0}
            })

            -- Ghost vanished!
            if g.health <= 0 then
                play_sound('tarot1', 1.4, 0.8)
                play_sound('holo1', 1.3, 0.75)
                for _ = 1, 18 do
                    table.insert(G.apagon_dissolve_particles, {
                        x = g.x + math.random(-20, 20),
                        y = g.y + math.random(-20, 20),
                        vx = math.random(-80, 80),
                        vy = math.random(-80, 80),
                        life = 0.5 + math.random() * 0.4,
                        max_life = 0.7,
                        size = math.random(4, 8),
                        col = ({
                            {0.65, 0.95, 1.0},
                            {0.30, 0.65, 0.95},
                            {1.00, 0.95, 0.80}
                        })[math.random(1, 3)]
                    })
                end
                table.remove(G.apagon_ghosts, i)
            end
        end
    end

    -- 5. Game Over Condition: 7 Ghosts accumulate!
    if #G.apagon_ghosts >= 7 and G.STATE ~= G.STATES.GAME_OVER then
        play_sound('cancel', 0.8, 1.0)
        G.STATE = G.STATES.GAME_OVER
        G.STATE_COMPLETE = false
        if attention_text then
            attention_text({
                text = 'OVERRUN BY GHOSTS (7/7)!',
                scale = 0.9,
                hold = 3.0,
                backdrop_colour = HEX('ef4444'),
                align = 'cm',
                offset = { x = 0, y = -1 }
            })
        end
    end
end

-- ----------------------------------------------------------------------------
-- Render Hook: Flying Ghosts & Darkness Overlay with Lantern Stencil
-- ----------------------------------------------------------------------------

local function draw_apagon_ghosts(mx, my, lantern_radius)
    local t = love.timer and love.timer.getTime() or 0
    for _, g in ipairs(G.apagon_ghosts) do
        local dx = g.x - mx
        local dy = g.y - my
        local dist = math.sqrt(dx * dx + dy * dy)
        local illuminated = dist <= lantern_radius

        love.graphics.push('all')
        love.graphics.translate(g.x, g.y)
        -- Hover tilt
        love.graphics.rotate(math.sin(t * 3.0 + g.seed) * 0.08)

        local alpha = illuminated and 0.88 or 0.15
        local scale = 0.75 + math.sin(t * 4.0 + g.seed) * 0.03

        -- Ghost aura glow
        love.graphics.setBlendMode('add', 'alphamultiply')
        love.graphics.setColor(0.35, 0.75, 0.95, alpha * 0.5)
        love.graphics.circle('fill', 0, 0, 42 * scale, 32)

        -- Health bar when taking damage under lantern
        if illuminated and g.health < 1.0 then
            love.graphics.setBlendMode('alpha')
            love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
            love.graphics.rectangle('fill', -24, -48, 48, 6, 2)
            love.graphics.setColor(0.9, 0.2, 0.2, 0.95)
            love.graphics.rectangle('fill', -24, -48, 48 * math.max(0, g.health), 6, 2)
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.rectangle('line', -24, -48, 48, 6, 2)
        end

        -- Draw Joker Center sprite with spectral color
        local center = G.P_CENTERS and G.P_CENTERS[g.key]
        if center and G.ASSET_ATLAS and G.ASSET_ATLAS[center.atlas or 'Joker'] then
            local atlas = G.ASSET_ATLAS[center.atlas or 'Joker']
            love.graphics.setBlendMode('alpha')
            love.graphics.setColor(0.85, 0.95, 1.0, alpha)
            love.graphics.draw(atlas.image, atlas.quads[center.pos.x .. '_' .. center.pos.y] or atlas.quads['1_0'], -35 * scale, -48 * scale, 0, scale, scale)
        else
            -- Fallback spectral card silhouette
            love.graphics.setColor(0.7, 0.9, 1.0, alpha)
            love.graphics.rectangle('fill', -24, -36, 48, 72, 6)
        end

        love.graphics.pop()
    end
end

-- ----------------------------------------------------------------------------
-- Love2D Draw Hook: Fullscreen Darkness, Lantern Stencil & Flying Ghost Jokers
-- ----------------------------------------------------------------------------

if not G.reality_warp_apagon_draw_hooked and love and love.draw then
    G.reality_warp_apagon_draw_hooked = true
    local orig_love_draw = love.draw
    love.draw = function(...)
        orig_love_draw(...)

        if not G.apagon_active or not G.GAME or not G.GAME.apagon_active then return end

        local sw = love.graphics.getWidth()
        local sh = love.graphics.getHeight()
        local mx, my = love.mouse.getPosition()
        local t = love.timer and love.timer.getTime() or 0
        local lantern_radius = 165 + math.sin(t * 5.0) * 8

        love.graphics.push('all')
        love.graphics.origin()
        love.graphics.setShader()

        -- 1. Draw flying Ghost Jokers
        draw_apagon_ghosts(mx, my, lantern_radius)

        -- 2. Draw dissipation particles
        love.graphics.setBlendMode('add', 'alphamultiply')
        for _, p in ipairs(G.apagon_dissolve_particles) do
            local prog = p.life / p.max_life
            love.graphics.setColor(p.col[1], p.col[2], p.col[3], prog * 0.8)
            love.graphics.circle('fill', p.x, p.y, p.size * prog, 8)
        end

        -- 3. Stencil darkness mask: hole at lantern cursor reveals the Balatro UI underneath!
        if G.apagon_lantern_on then
            love.graphics.stencil(function()
                love.graphics.circle('fill', mx, my, lantern_radius, 64)
            end, 'replace', 1)
            love.graphics.setStencilTest('equal', 0)
        end

        -- Darkness overlay covering entire screen (outside the lantern hole)
        love.graphics.setColor(0.015, 0.015, 0.025, 0.96)
        love.graphics.rectangle('fill', 0, 0, sw, sh)

        if G.apagon_lantern_on then
            love.graphics.setStencilTest()

            -- Soft atmospheric flashlight beam border
            love.graphics.setBlendMode('add', 'alphamultiply')
            love.graphics.setColor(1.0, 0.65, 0.2, 0.08 + 0.03 * math.sin(t * 4.0))
            love.graphics.circle('fill', mx, my, lantern_radius, 64)

            -- Fiery rising sparks at mouse cursor (Orange, Red, Yellow)
            for _, p in ipairs(G.apagon_particles) do
                local prog = p.life / p.max_life
                love.graphics.setColor(p.col[1], p.col[2], p.col[3], prog * 0.85)
                love.graphics.circle('fill', p.x, p.y, p.size * prog, 8)
            end

            -- 4. Ghost Danger HUD Indicator (Centered at top)
            local num_g = #G.apagon_ghosts
            local hud_col = (num_g >= 5) and {0.95, 0.2, 0.2, 0.95} or (num_g >= 3 and {0.95, 0.8, 0.15, 0.9} or {0.2, 0.9, 0.5, 0.85})
            love.graphics.setBlendMode('alpha')
            love.graphics.setColor(0.05, 0.05, 0.08, 0.85)
            love.graphics.rectangle('fill', sw * 0.5 - 90, 16, 180, 32, 6)
            love.graphics.setColor(hud_col[1], hud_col[2], hud_col[3], hud_col[4])
            love.graphics.rectangle('line', sw * 0.5 - 90, 16, 180, 32, 6)
            local ghost_text = "GHOSTS: " .. tostring(num_g) .. " / 7"
            love.graphics.printf(ghost_text, sw * 0.5 - 90, 24, 180, "center")
        end

        love.graphics.pop()
    end
end

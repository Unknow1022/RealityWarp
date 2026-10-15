-- ============================================================================
-- Reality Warp - Game Mode: "Apagón" (Blackout)
-- ============================================================================

G.apagon_active = false
G.apagon_starting = false
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

local BOSS_JOKER_GHOST_KEYS = {
    'j_baron',      -- Baron (Rare: Victorian noble suit)
    'j_vampire',    -- Vampire (Uncommon: vampire cape & count suit)
    'j_space',      -- Space Joker (Uncommon: astronaut suit)
    'j_showman',    -- Showman (Uncommon: ringmaster suit & top hat)
    'j_matador',    -- Matador (Uncommon: bullfighter costume)
    'j_burglar',    -- Burglar (Uncommon: masked burglar suit)
    'j_troubadour', -- Troubadour (Uncommon: medieval minstrel costume)
}

-- ----------------------------------------------------------------------------
-- Audio: fire_loop Registration & Continuous Loop Controller
-- ----------------------------------------------------------------------------

if SMODS and SMODS.Sound then
    SMODS.Sound {
        key = 'fire_loop',
        path = 'fire_loop.mp3'
    }
end

local fire_loop_source = nil

local function silence_game_for_apagon()
    if G.SETTINGS and G.SETTINGS.SOUND then
        -- Restore master and game sounds volume if previously zeroed out
        if G.apagon_prev_sound_settings and G.apagon_prev_sound_settings.volume then
            G.SETTINGS.SOUND.volume = G.apagon_prev_sound_settings.volume
            G.SETTINGS.SOUND.game_sounds_volume = G.apagon_prev_sound_settings.game_sounds_volume or 100
        end
        if G.SETTINGS.SOUND.volume == 0 then
            G.SETTINGS.SOUND.volume = 100
        end
        if G.SETTINGS.SOUND.game_sounds_volume == 0 then
            G.SETTINGS.SOUND.game_sounds_volume = 100
        end

        if not G.apagon_prev_sound_settings or not G.apagon_prev_sound_settings.music_volume then
            G.apagon_prev_sound_settings = {
                music_volume = G.SETTINGS.SOUND.music_volume
            }
        end
        G.SETTINGS.SOUND.music_volume = 0

        if G.SOUND_MANAGER and G.SOUND_MANAGER.channel then
            pcall(function()
                G.SOUND_MANAGER.channel:push({
                    type = 'modulate',
                    desired_track = '',
                    dt = 0.01,
                    sound_settings = G.SETTINGS.SOUND,
                    pitch_mod = 1.0,
                    splash_vol = 0
                })
            end)
        end
    end
end

local function restore_apagon_sound()
    if G.apagon_prev_sound_settings and G.SETTINGS and G.SETTINGS.SOUND then
        G.SETTINGS.SOUND.music_volume = G.apagon_prev_sound_settings.music_volume or 100
        local restored_settings = G.SETTINGS.SOUND
        G.apagon_prev_sound_settings = nil

        if G.SOUND_MANAGER and G.SOUND_MANAGER.channel then
            pcall(function()
                G.SOUND_MANAGER.channel:push({
                    type = 'modulate',
                    dt = 0.5,
                    sound_settings = restored_settings,
                    pitch_mod = 1.0
                })
            end)
        end
    end
end

local function start_fire_loop()
    if fire_loop_source and fire_loop_source:isPlaying() then
        pcall(function() fire_loop_source:setVolume(0.70) end)
        return
    end
    if not fire_loop_source then
        local mod = (SMODS and (SMODS.current_mod or (SMODS.Mods and SMODS.Mods["reality_warp"])))
        local mod_path = (mod and mod.path) or ""
        if mod_path ~= "" and not mod_path:match("[/\\]$") then
            mod_path = mod_path .. "/"
        end
        local candidates = {
            mod_path .. "assets/sounds/fire_loop.mp3",
            "assets/sounds/fire_loop.mp3",
            mod_path .. "fire_loop.mp3"
        }
        for _, path in ipairs(candidates) do
            local ok, src = pcall(love.audio.newSource, path, "stream")
            if ok and src then
                fire_loop_source = src
                break
            end
            if NFS and NFS.newFileData then
                local ok_fd, fd = pcall(NFS.newFileData, path)
                if ok_fd and fd then
                    local ok_s, src_nfs = pcall(love.audio.newSource, fd, "stream")
                    if ok_s and src_nfs then
                        fire_loop_source = src_nfs
                        break
                    end
                end
            end
            if NFS and NFS.read then
                local ok2, data = pcall(NFS.read, 'data', path)
                if ok2 and data then
                    local ok3, src2 = pcall(love.audio.newSource, data, "stream")
                    if ok3 and src2 then
                        fire_loop_source = src2
                        break
                    end
                end
            end
        end
    end
    if fire_loop_source then
        pcall(function()
            fire_loop_source:setLooping(true)
            fire_loop_source:setVolume(0.70)
            fire_loop_source:play()
        end)
    else
        pcall(play_sound, 'fire_loop', 1.0, 0.70)
    end
end

local function stop_fire_loop()
    if fire_loop_source then
        pcall(function()
            fire_loop_source:stop()
        end)
    end
    restore_apagon_sound()
end

-- ----------------------------------------------------------------------------
-- Random Deck & Sleeve Picker
-- ----------------------------------------------------------------------------

local function get_random_apagon_deck_and_sleeve()
    local available_decks = {}
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Back'] then
        for _, center in ipairs(G.P_CENTER_POOLS['Back']) do
            if center and center.key and center.key ~= 'b_coliseo' and center.key ~= 'b_reality_warp_coliseo' and center.key ~= 'b_challenge' then
                if center.unlocked ~= false then
                    table.insert(available_decks, center.key)
                end
            end
        end
    end
    if #available_decks == 0 then
        available_decks = {
            'b_red', 'b_blue', 'b_yellow', 'b_green', 'b_black',
            'b_magic', 'b_nebula', 'b_ghost', 'b_abandoned', 'b_checkered',
            'b_zodiac', 'b_painted', 'b_anaglyph', 'b_plasma', 'b_erratic'
        }
    end
    local chosen_deck = available_decks[math.random(1, #available_decks)]

    local chosen_sleeve = nil
    if CardSleeves and CardSleeves.Sleeve and G.P_CENTER_POOLS and G.P_CENTER_POOLS['Sleeve'] then
        local available_sleeves = {}
        for _, center in ipairs(G.P_CENTER_POOLS['Sleeve']) do
            if center and center.key and center.key ~= 'sleeve_casl_none' then
                if center.unlocked ~= false then
                    table.insert(available_sleeves, center.key)
                end
            end
        end
        if #available_sleeves > 0 then
            chosen_sleeve = available_sleeves[math.random(1, #available_sleeves)]
        end
    end

    return chosen_deck, chosen_sleeve
end

-- ----------------------------------------------------------------------------
-- Mode Launch Handler
-- ----------------------------------------------------------------------------

G.FUNCS = G.FUNCS or {}

G.FUNCS.reality_warp_start_apagon_run = function(e)
    G.SETTINGS.paused = false
    if G.OVERLAY_MENU then
        G.FUNCS.exit_overlay_menu()
    end

    stop_fire_loop()
    G.apagon_active = true
    G.apagon_starting = true
    G.apagon_intro_timer = 0
    G.apagon_lantern_on = false
    G.apagon_ghosts = {}
    G.apagon_particles = {}
    G.apagon_dissolve_particles = {}
    G.apagon_spawn_timer = 0
    G.apagon_last_real_time = nil

    local chosen_deck, chosen_sleeve = get_random_apagon_deck_and_sleeve()
    local run_args = {
        deck = chosen_deck,
        stake = 1,
        apagon = true
    }
    if chosen_sleeve then
        run_args.casl_sleeve_choice = chosen_sleeve
        run_args.sleeve = chosen_sleeve
        if G.GAME then G.GAME.selected_sleeve = chosen_sleeve end
        G.viewed_sleeve = chosen_sleeve
        G._last_selected_sleeve = chosen_sleeve
    end
    if G.P_CENTERS and G.P_CENTERS[chosen_deck] and Back then
        G.GAME.selected_back = Back(G.P_CENTERS[chosen_deck])
        G.GAME.viewed_back = Back(G.P_CENTERS[chosen_deck])
        G.viewed_back = Back(G.P_CENTERS[chosen_deck])
    end

    if G.FUNCS and G.FUNCS.start_run then
        G.FUNCS.start_run(e or { config = {} }, run_args)
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
    local is_apagon = G.apagon_starting or G.apagon_active or (args and args.apagon) or (self.GAME and self.GAME.apagon_active)
    G.apagon_starting = nil

    if orig_game_start_run then orig_game_start_run(self, args) end

    if is_apagon then
        if self.GAME then
            self.GAME.apagon_active = true
            if args and args.deck and G.P_CENTERS and G.P_CENTERS[args.deck] and Back then
                self.GAME.selected_back = Back(G.P_CENTERS[args.deck])
            end
            if args and args.casl_sleeve_choice then
                self.GAME.selected_sleeve = args.casl_sleeve_choice
            end
        end
        G.apagon_active = true
        G.apagon_intro_timer = 0
        G.apagon_lantern_on = false
        G.apagon_ghosts = {}
        G.apagon_particles = {}
        G.apagon_dissolve_particles = {}
        G.apagon_spawn_timer = 0
        G.apagon_last_real_time = nil

        silence_game_for_apagon()
    else
        stop_fire_loop()
        G.apagon_active = false
        G.apagon_ghosts = {}
        G.apagon_particles = {}
    end
end

local orig_game_main_menu = Game.main_menu
function Game:main_menu(change_context)
    stop_fire_loop()
    G.apagon_active = false
    G.apagon_starting = nil
    if orig_game_main_menu then orig_game_main_menu(self, change_context) end
end

if Game and Game.delete_run then
    local orig_game_delete_run = Game.delete_run
    function Game:delete_run(...)
        stop_fire_loop()
        G.apagon_active = false
        G.apagon_starting = nil
        return orig_game_delete_run(self, ...)
    end
end

if G.FUNCS and G.FUNCS.go_to_menu then
    local orig_go_to_menu = G.FUNCS.go_to_menu
    G.FUNCS.go_to_menu = function(e)
        stop_fire_loop()
        G.apagon_active = false
        G.apagon_starting = nil
        orig_go_to_menu(e)
    end
end

-- ----------------------------------------------------------------------------
-- Audio: Disable In-Game Music During Apagón Runs (Sound Effects Remain Active)
-- ----------------------------------------------------------------------------

if modulate_sound then
    local orig_modulate_sound = modulate_sound
    function modulate_sound(dt)
        local is_apagon = G.apagon_active or (G.GAME and G.GAME.apagon_active)
        if is_apagon then
            local prev_video_soundtrack = G.video_soundtrack
            G.video_soundtrack = ''
            orig_modulate_sound(dt)
            G.video_soundtrack = prev_video_soundtrack
            return
        end
        return orig_modulate_sound(dt)
    end
end

if love and love.quit then
    local orig_love_quit = love.quit
    love.quit = function(...)
        restore_apagon_sound()
        return orig_love_quit(...)
    end
end

-- ----------------------------------------------------------------------------
-- Ghost Spawner: 1 in 3 Chance Per Selected Blind
-- ----------------------------------------------------------------------------

local function spawn_apagon_ghost()
    if #G.apagon_ghosts >= 7 then return end
    local sw, sh = love.graphics.getDimensions()
    local mx, my = love.mouse.getPosition()

    -- Spawn in deep shadows far from mouse cursor
    local gx = (mx < sw * 0.5) and (sw - math.random(80, 220)) or math.random(80, 220)
    local gy = (my < sh * 0.5) and (sh - math.random(100, 220)) or math.random(110, 230)
    local is_boss = (math.random(1, 8) == 1)
    local j_key = is_boss and BOSS_JOKER_GHOST_KEYS[math.random(#BOSS_JOKER_GHOST_KEYS)]
        or JOKER_GHOST_KEYS[math.random(#JOKER_GHOST_KEYS)]
    local max_hp = is_boss and 2.5 or 1.0

    table.insert(G.apagon_ghosts, {
        x = gx,
        y = gy,
        vx = (math.random() - 0.5) * (is_boss and 70 or 45),
        vy = (math.random() - 0.5) * (is_boss and 70 or 45),
        key = j_key,
        is_boss = is_boss,
        health = max_hp,
        max_health = max_hp,
        seed = math.random(1, 99999),
        hover_time = 0
    })
    pcall(play_sound, 'whoosh1', 0.85, 0.10)
    pcall(play_sound, 'foil1', 0.75, 0.10)
end

-- Ghost Spawner moved to real-time 30-second interval in Game:update

-- ----------------------------------------------------------------------------
-- Game Update Loop: Flashlight & Ghost Spawning / Banishment
-- ----------------------------------------------------------------------------

local orig_game_update = Game.update
function Game:update(dt)
    if orig_game_update then orig_game_update(self, dt) end

    local is_active = G.apagon_active or (G.GAME and G.GAME.apagon_active)
    if not is_active then
        stop_fire_loop()
        return
    end
    G.apagon_active = true

    if G.SETTINGS.paused then return end

    local sw = (love.graphics and love.graphics.getWidth()) or 1536
    local sh = (love.graphics and love.graphics.getHeight()) or 864
    local mx, my = love.mouse.getPosition()
    local t = love.timer and love.timer.getTime() or 0

    -- 1. Intro sequence: pitch darkness until lantern sparks
    if not G.apagon_lantern_on then
        G.apagon_intro_timer = G.apagon_intro_timer + dt
        if G.apagon_intro_timer >= 1.2 then
            G.apagon_lantern_on = true
            -- Low-pitched chip sound when fire appears on screen
            pcall(play_sound, 'chips1', 0.72, 1.0)
            start_fire_loop()

            -- Guarantee initial ghost so the screen is never empty on start
            if #G.apagon_ghosts == 0 then
                spawn_apagon_ghost()
            end

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
    else
        -- Ensure fire_loop keeps playing continuously throughout the run
        if not fire_loop_source or not fire_loop_source:isPlaying() then
            start_fire_loop()
        end
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

    -- 3. Update Ghosts & Check Lantern Collision
    local lantern_radius = 220 + math.sin(t * 4.0) * 8
    local damage_radius = lantern_radius * 0.60
    local flee_range = lantern_radius * 1.05

    for i = #G.apagon_ghosts, 1, -1 do
        local g = G.apagon_ghosts[i]
        local dx = g.x - mx
        local dy = g.y - my
        local dist = math.sqrt(dx * dx + dy * dy)

        -- Flee and hide from the player's flashlight beam into darkness (Boss ghosts move faster)
        local base_flee = g.is_boss and 215 or 145
        local max_speed = g.is_boss and 220 or 150
        if dist < flee_range and dist > 1 then
            local flee_intensity = (1 - (dist / flee_range))
            local flee_speed = flee_intensity * base_flee
            local nx = dx / dist
            local ny = dy / dist
            local lateral_x = -ny * math.sin(t * 4.5 + g.seed) * (g.is_boss and 75 or 55)
            local lateral_y = nx * math.sin(t * 4.5 + g.seed) * (g.is_boss and 75 or 55)
            g.vx = g.vx + (nx * flee_speed + lateral_x) * dt
            g.vy = g.vy + (ny * flee_speed + lateral_y) * dt
        else
            g.vx = g.vx * (1 - 0.6 * dt)
            g.vy = g.vy * (1 - 0.6 * dt)
        end

        local cur_speed = math.sqrt(g.vx * g.vx + g.vy * g.vy)
        if cur_speed > max_speed then
            g.vx = (g.vx / cur_speed) * max_speed
            g.vy = (g.vy / cur_speed) * max_speed
        elseif cur_speed < (g.is_boss and 25 or 15) then
            local dir = (g.vx >= 0) and 1 or -1
            g.vx = dir * (g.is_boss and 35 or 20)
        end

        g.x = g.x + g.vx * dt
        g.y = g.y + g.vy * dt

        -- Boundary collision
        local pad = 45
        if g.x < pad then
            g.x = pad
            g.vx = math.abs(g.vx) * 0.8
        elseif g.x > sw - pad then
            g.x = sw - pad
            g.vx = -math.abs(g.vx) * 0.8
        end
        if g.y < pad + 50 then
            g.y = pad + 50
            g.vy = math.abs(g.vy) * 0.8
        elseif g.y > sh - pad - 50 then
            g.y = sh - pad - 50
            g.vy = -math.abs(g.vy) * 0.8
        end

        -- Shining lantern inner impact core slowly drains ghost health; closer to center = more health lost
        if dist <= damage_radius then
            local center_factor = math.max(0, 1 - (dist / damage_radius))
            local drain_rate = 0.10 + 0.35 * (center_factor * center_factor)
            g.health = g.health - dt * drain_rate
            g.hover_time = g.hover_time + dt
            table.insert(G.apagon_dissolve_particles, {
                x = g.x + math.random(-25, 25),
                y = g.y + math.random(-25, 25),
                vx = math.random(-35, 35),
                vy = math.random(-50, 15),
                life = 0.30 + math.random() * 0.20,
                max_life = 0.45,
                size = math.random(2, 5),
                col = g.is_boss and {0.95, 0.20, 0.25} or {0.45, 0.85, 1.0}
            })

            -- Ghost vanished!
            if g.health <= 0 then
                pcall(play_sound, 'tarot1', 1.4, 0.10)
                pcall(play_sound, 'holo1', 1.3, 0.10)
                local burst_count = g.is_boss and 32 or 18
                for _ = 1, burst_count do
                    table.insert(G.apagon_dissolve_particles, {
                        x = g.x + math.random(-20, 20),
                        y = g.y + math.random(-20, 20),
                        vx = math.random(-80, 80),
                        vy = math.random(-80, 80),
                        life = 0.5 + math.random() * 0.4,
                        max_life = 0.7,
                        size = math.random(4, 8),
                        col = g.is_boss and ({
                            {0.95, 0.18, 0.22},
                            {1.00, 0.35, 0.15},
                            {0.80, 0.08, 0.12}
                        })[math.random(1, 3)] or ({
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

    -- 4. Ghost Spawner: 1 in 3 chance every 15 real unscaled seconds (unaffected by game speed)
    local cur_real = (G.TIMERS and G.TIMERS.REAL) or (love.timer and love.timer.getTime()) or 0
    if not G.apagon_last_real_time then G.apagon_last_real_time = cur_real end
    local real_delta = cur_real - G.apagon_last_real_time
    G.apagon_last_real_time = cur_real
    if real_delta < 0 or real_delta > 1.0 then
        real_delta = (love.timer and love.timer.getDelta()) or dt
    end

    G.apagon_spawn_timer = (G.apagon_spawn_timer or 0) + real_delta
    if G.apagon_spawn_timer >= 15 then
        G.apagon_spawn_timer = G.apagon_spawn_timer - 15
        -- If no ghosts currently exist, guarantee spawn so run is never empty; otherwise 1 in 3 chance
        if #G.apagon_ghosts == 0 or math.random(1, 3) == 1 then
            spawn_apagon_ghost()
        end
    end

    -- 5. Game Over Condition: 7 Ghosts accumulate!
    if #G.apagon_ghosts >= 7 and G.STATE ~= G.STATES.GAME_OVER then
        stop_fire_loop()
        pcall(play_sound, 'cancel', 0.8, 1.0)
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
-- Ghost Renderer
-- ----------------------------------------------------------------------------

local function draw_apagon_ghosts(mx, my, lantern_radius)
    local t = love.timer and love.timer.getTime() or 0
    for _, g in ipairs(G.apagon_ghosts) do
        local dx = g.x - mx
        local dy = g.y - my
        local dist = math.sqrt(dx * dx + dy * dy)
        local illuminated = G.apagon_lantern_on and (dist <= lantern_radius)

        love.graphics.push('all')
        love.graphics.translate(g.x, g.y)
        love.graphics.rotate(math.sin(t * 3.0 + g.seed) * 0.08)

        local scale = (g.is_boss and 1.05 or 0.85) + math.sin(t * 4.0 + g.seed) * 0.04

        local center = G.P_CENTERS and G.P_CENTERS[g.key]
        local atlas = (G.ANIMATION_ATLAS and G.ANIMATION_ATLAS[center and center.atlas or 'Joker'])
            or (G.ASSET_ATLAS and G.ASSET_ATLAS[center and center.atlas or 'Joker'])
            or (G.ANIMATION_ATLAS and G.ANIMATION_ATLAS['Joker'])
            or (G.ASSET_ATLAS and G.ASSET_ATLAS['Joker'])

        local q = nil
        if atlas and atlas.image and center then
            local pos_x = (center.pos and center.pos.x) or 0
            local pos_y = (center.pos and center.pos.y) or 0
            local px = atlas.px or 71
            local py = atlas.py or 95
            atlas.quads = atlas.quads or {}
            local q_key = pos_x .. '_' .. pos_y
            if not atlas.quads[q_key] then
                local iw, ih = atlas.image:getDimensions()
                atlas.quads[q_key] = love.graphics.newQuad(pos_x * px, pos_y * py, px, py, iw, ih)
            end
            q = atlas.quads[q_key]
        end

        if illuminated then
            -- Fade in visibility progressively as light touches the ghost
            local light_factor = math.max(0.25, 1 - (dist / lantern_radius))
            love.graphics.setBlendMode('add', 'alphamultiply')
            if g.is_boss then
                love.graphics.setColor(0.95, 0.18, 0.22, 0.60 * light_factor)
            else
                love.graphics.setColor(0.35, 0.75, 0.95, 0.45 * light_factor)
            end
            love.graphics.circle('fill', 0, 0, (g.is_boss and 52 or 44) * scale, 32)

            -- Health bar when taking damage under lantern
            local max_hp = g.max_health or 1.0
            if g.health < max_hp then
                love.graphics.setBlendMode('alpha')
                love.graphics.setColor(0.1, 0.1, 0.1, 0.85 * light_factor)
                local bar_w = g.is_boss and 62 or 52
                local bar_h = g.is_boss and 8 or 7
                local bar_x = -bar_w * 0.5
                local bar_y = g.is_boss and -58 or -52
                love.graphics.rectangle('fill', bar_x, bar_y, bar_w, bar_h, 2)
                if g.is_boss then
                    love.graphics.setColor(0.95, 0.12, 0.12, 0.95 * light_factor)
                else
                    love.graphics.setColor(0.9, 0.2, 0.2, 0.95 * light_factor)
                end
                love.graphics.rectangle('fill', bar_x, bar_y, bar_w * math.max(0, g.health / max_hp), bar_h, 2)
                if g.is_boss then
                    love.graphics.setColor(1.0, 0.45, 0.45, 0.95 * light_factor)
                else
                    love.graphics.setColor(1, 1, 1, 0.9 * light_factor)
                end
                love.graphics.rectangle('line', bar_x, bar_y, bar_w, bar_h, 2)
            end

            -- Render Joker with ghost shader (Boss ghosts have distinctive crimson red tint)
            love.graphics.setBlendMode('alpha')
            if g.is_boss then
                love.graphics.setColor(1.0, 0.32, 0.32, light_factor)
            else
                love.graphics.setColor(1, 1, 1, light_factor)
            end

            local sh = G.SHADERS and (G.SHADERS['reality_warp_ghost'] or G.SHADERS['ghost'])
            local shader_applied = false
            if sh and atlas and atlas.image then
                pcall(function()
                    if sh:hasUniform('time') then sh:send('time', t) end
                    if sh:hasUniform('ghost') then sh:send('ghost', { 0.5, t }) end
                    if sh:hasUniform('dissolve') then sh:send('dissolve', 0.0) end
                    if sh:hasUniform('shadow') then sh:send('shadow', false) end
                    if sh:hasUniform('burn_colour_1') then sh:send('burn_colour_1', {0, 0, 0, 0}) end
                    if sh:hasUniform('burn_colour_2') then sh:send('burn_colour_2', {0, 0, 0, 0}) end
                    if sh:hasUniform('texture_details') then
                        local pos_x = (center and center.pos and center.pos.x) or 0
                        local pos_y = (center and center.pos and center.pos.y) or 0
                        local px = atlas.px or 71
                        local py = atlas.py or 95
                        sh:send('texture_details', { pos_x, pos_y, px, py })
                    end
                    if sh:hasUniform('image_details') then
                        local iw, ih = atlas.image:getDimensions()
                        sh:send('image_details', { iw, ih })
                    end
                    love.graphics.setShader(sh)
                    shader_applied = true
                end)
            end

            if q and atlas and atlas.image then
                love.graphics.draw(atlas.image, q, -35 * scale, -48 * scale, 0, scale, scale)
            else
                love.graphics.setColor(g.is_boss and 0.95 or 0.5, g.is_boss and 0.22 or 0.8, g.is_boss and 0.22 or 0.95, 0.85 * light_factor)
                love.graphics.rectangle('fill', -24, -36, 48, 72, 6)
            end

            if shader_applied then
                love.graphics.setShader()
            end
        else
            -- Outside lantern: only small subtle illumination (Boss has glowing crimson red illumination)
            love.graphics.setBlendMode('add', 'alphamultiply')
            if g.is_boss then
                love.graphics.setColor(0.95, 0.16, 0.20, 0.38 + 0.10 * math.sin(t * 3.0 + g.seed))
                love.graphics.circle('fill', 0, 0, 30 * scale, 24)
            else
                love.graphics.setColor(0.18, 0.52, 0.88, 0.28 + 0.08 * math.sin(t * 3.0 + g.seed))
                love.graphics.circle('fill', 0, 0, 24 * scale, 24)
            end
        end

        love.graphics.pop()
    end
end

-- ----------------------------------------------------------------------------
-- Darkness Canvas & Progressive Radial Gradient
-- ----------------------------------------------------------------------------

local apagon_canvas = nil
local function get_apagon_canvas(w, h)
    if not apagon_canvas or apagon_canvas:getWidth() ~= w or apagon_canvas:getHeight() ~= h then
        apagon_canvas = love.graphics.newCanvas(w, h)
    end
    return apagon_canvas
end

local radial_lantern_img = nil
local function get_radial_lantern_image()
    if not radial_lantern_img then
        local size = 256
        local id = love.image.newImageData(size, size)
        local center = size * 0.5
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local dx = x - center + 0.5
                local dy = y - center + 0.5
                local norm_d = math.sqrt(dx * dx + dy * dy) / center
                if norm_d > 1.0 then norm_d = 1.0 end
                -- Progressive illumination falloff (quadratic curve)
                -- Center is clear (alpha 0.0), smoothly darkens towards outer radius to 0.97
                local falloff = norm_d * norm_d
                local smooth_a = falloff * 0.97
                id:setPixel(x, y, 0.012, 0.012, 0.022, smooth_a)
            end
        end
        radial_lantern_img = love.graphics.newImage(id)
    end
    return radial_lantern_img
end

-- ----------------------------------------------------------------------------
-- Master Darkness & Flashlight Render Pass
-- ----------------------------------------------------------------------------

local function render_apagon_overlay()
    local is_active = G.apagon_active or (G.GAME and G.GAME.apagon_active)
    if not is_active then return end
    G.apagon_active = true

    local cur_t = (love.timer and love.timer.getTime()) or (G.TIMERS and G.TIMERS.REAL) or 0
    if G.rw_apagon_last_draw_time and math.abs(cur_t - G.rw_apagon_last_draw_time) < 0.0001 then
        return
    end
    G.rw_apagon_last_draw_time = cur_t

    local sw, sh = love.graphics.getDimensions()
    local mx, my = love.mouse.getPosition()
    local t = cur_t
    local lantern_radius = 220 + math.sin(t * 4.0) * 8

    love.graphics.push('all')
    love.graphics.origin()
    love.graphics.setShader()
    love.graphics.setCanvas()

    -- 1. Create and render darkness canvas with progressive lantern aperture
    local canvas = get_apagon_canvas(sw, sh)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    -- Fill canvas with pitch darkness
    love.graphics.setColor(0.012, 0.012, 0.022, 0.97)
    love.graphics.rectangle('fill', 0, 0, sw, sh)

    if G.apagon_lantern_on then
        -- Progressive soft radial aperture: center is transparent, smoothly darkens outwards
        local r_img = get_radial_lantern_image()
        if r_img then
            love.graphics.setBlendMode('replace')
            love.graphics.setColor(1, 1, 1, 1)
            local iw = r_img:getWidth()
            local s = (lantern_radius * 2) / iw
            love.graphics.draw(r_img, mx, my, 0, s, s, iw * 0.5, iw * 0.5)
        end
    end

    love.graphics.setCanvas()
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, 0, 0)

    -- 2. Draw Flying Ghosts
    draw_apagon_ghosts(mx, my, lantern_radius)

    -- 3. Draw spectral dissipation particles
    love.graphics.setBlendMode('add', 'alphamultiply')
    for _, p in ipairs(G.apagon_dissolve_particles) do
        local prog = p.life / p.max_life
        love.graphics.setColor(p.col[1], p.col[2], p.col[3], prog * 0.8)
        love.graphics.circle('fill', p.x, p.y, p.size * prog, 8)
    end

    -- 4. Lantern effects at mouse cursor
    if G.apagon_lantern_on then
        -- Progressive warm ambient illumination
        love.graphics.setBlendMode('add', 'alphamultiply')
        love.graphics.setColor(1.0, 0.65, 0.2, 0.09 + 0.02 * math.sin(t * 4.0))
        love.graphics.circle('fill', mx, my, lantern_radius * 0.45, 48)
        love.graphics.setColor(1.0, 0.50, 0.15, 0.04 + 0.015 * math.sin(t * 4.0))
        love.graphics.circle('fill', mx, my, lantern_radius * 0.8, 64)

        -- Fiery rising sparks at mouse cursor (Orange, Red, Yellow)
        for _, p in ipairs(G.apagon_particles) do
            local prog = p.life / p.max_life
            love.graphics.setColor(p.col[1], p.col[2], p.col[3], prog * 0.85)
            love.graphics.circle('fill', p.x, p.y, p.size * prog, 8)
        end

        -- 5. Ghost Danger HUD Indicator (Centered at top)
        local num_g = #G.apagon_ghosts
        local hud_col = (num_g >= 5) and {0.95, 0.2, 0.2, 0.95} or (num_g >= 3 and {0.95, 0.8, 0.15, 0.9} or {0.2, 0.9, 0.5, 0.85})
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(0.05, 0.05, 0.08, 0.88)
        love.graphics.rectangle('fill', sw * 0.5 - 90, 16, 180, 32, 6)
        love.graphics.setColor(hud_col[1], hud_col[2], hud_col[3], hud_col[4])
        love.graphics.rectangle('line', sw * 0.5 - 90, 16, 180, 32, 6)
        local ghost_text = "GHOSTS: " .. tostring(num_g) .. " / 7"
        love.graphics.printf(ghost_text, sw * 0.5 - 90, 24, 180, "center")
    end

    love.graphics.pop()
end

-- ----------------------------------------------------------------------------
-- Double Hook: love.draw AND Game.draw
-- ----------------------------------------------------------------------------

if not G.reality_warp_apagon_draw_hooked then
    G.reality_warp_apagon_draw_hooked = true
    if love and love.draw then
        local orig_love_draw = love.draw
        love.draw = function(...)
            orig_love_draw(...)
            render_apagon_overlay()
        end
    end
    if Game and Game.draw then
        local orig_game_draw = Game.draw
        function Game:draw(...)
            orig_game_draw(self, ...)
            render_apagon_overlay()
        end
    end
end

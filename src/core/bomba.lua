-- ============================================================================
-- Reality Warp - Game Mode: "Bomba" (Time Bomb)
-- ============================================================================

G.bomba_active = false
G.bomba_starting = false
G.bomba_timer = 50.0
G.bomba_timer_adding = 0
G.bomba_last_real_time = nil
G.bomba_button_rect = nil
G.bomba_tick_acc = 0

-- ----------------------------------------------------------------------------
-- Audio: wartimer & wartimerup Registration
-- ----------------------------------------------------------------------------

if SMODS and SMODS.Sound then
    SMODS.Sound {
        key = 'wartimer',
        path = 'wartimer.mp3'
    }
    SMODS.Sound {
        key = 'wartimerup',
        path = 'wartimerup.mp3'
    }
end

local function play_bomba_sound(sound_key, pitch, volume)
    pitch = pitch or 1
    volume = volume or 1
    local candidates = {
        'reality_warp_' .. sound_key,
        sound_key
    }
    for _, k in ipairs(candidates) do
        if G.AUDIO and G.AUDIO[k] then
            play_sound(k, pitch, volume)
            return
        end
    end
    pcall(play_sound, 'reality_warp_' .. sound_key, pitch, volume)
end

-- ----------------------------------------------------------------------------
-- Random Deck & Sleeve Selector
-- ----------------------------------------------------------------------------

local function get_random_bomba_deck_and_sleeve()
    local available_decks = {}
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Back'] then
        for _, b in ipairs(G.P_CENTER_POOLS['Back']) do
            if b.unlocked ~= false and b.discovered ~= false and b.key ~= 'b_challenge' then
                table.insert(available_decks, b.key)
            end
        end
    end
    if #available_decks == 0 then
        available_decks = { 'b_red', 'b_blue', 'b_yellow', 'b_green', 'b_black' }
    end
    local chosen_deck = available_decks[math.random(#available_decks)]
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
-- Mode Entry Callback
-- ----------------------------------------------------------------------------

G.FUNCS = G.FUNCS or {}

G.FUNCS.reality_warp_start_bomba_run = function(e)
    G.SETTINGS.paused = false
    if G.OVERLAY_MENU then
        G.FUNCS.exit_overlay_menu()
    end

    G.bomba_active = true
    G.bomba_starting = true
    G.bomba_timer = 50.0
    G.bomba_timer_adding = 0
    G.bomba_last_real_time = nil

    local chosen_deck, chosen_sleeve = get_random_bomba_deck_and_sleeve()
    local run_args = {
        deck = chosen_deck,
        stake = 1,
        bomba = true
    }
    if chosen_sleeve then
        run_args.casl_sleeve_choice = chosen_sleeve
        run_args.sleeve = chosen_sleeve
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
        G.GAME.bomba_active = true
        G.GAME.bomba_timer = 50.0
    end
end

-- ----------------------------------------------------------------------------
-- Buy Time: $1 = +10 Seconds
-- ----------------------------------------------------------------------------

G.FUNCS.reality_warp_buy_bomba_time = function(e)
    if not (G.bomba_active or (G.GAME and G.GAME.bomba_active)) then return end
    local dollars = (G.GAME and G.GAME.dollars) or 0
    if dollars >= 1 then
        ease_dollars(-1)
        G.bomba_timer_adding = (G.bomba_timer_adding or 0) + 10
        play_bomba_sound('wartimerup', 1.15, 0.60)
        pcall(play_sound, 'coin1', 1.15, 0.6)
        if card_eval_status_text and G.HUD and G.HUD:get_UIE_by_ID('dollar_text_UI') then
            card_eval_status_text(G.HUD:get_UIE_by_ID('dollar_text_UI'), 'extra', nil, nil, nil, {
                message = '+10s Defused!',
                colour = HEX('22c55e')
            })
        end
    else
        pcall(play_sound, 'cancel', 1.0, 0.6)
    end
end

-- ----------------------------------------------------------------------------
-- Blind Victory Hook: +40 Seconds Per Won Round
-- ----------------------------------------------------------------------------

if Blind and Blind.defeat then
    local orig_blind_defeat = Blind.defeat
    function Blind:defeat(silent)
        if (G.bomba_active or (G.GAME and G.GAME.bomba_active)) and not self.reality_warp_bomba_rewarded then
            self.reality_warp_bomba_rewarded = true
            G.bomba_timer_adding = (G.bomba_timer_adding or 0) + 40
            play_bomba_sound('wartimerup', 1.0, 0.75)
            if attention_text then
                attention_text({
                    text = '+40s DEFUSED!',
                    scale = 0.85,
                    hold = 2.0,
                    backdrop_colour = HEX('22c55e'),
                    align = 'cm',
                    offset = { x = 0, y = -1.2 }
                })
            end
        end
        return orig_blind_defeat(self, silent)
    end
end

if Blind and Blind.set_blind then
    local orig_blind_set_blind = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        self.reality_warp_bomba_rewarded = nil
        return orig_blind_set_blind(self, blind, reset, silent)
    end
end

-- ----------------------------------------------------------------------------
local function restore_bomba_gamespeed()
    if G.bomba_prev_gamespeed and G.SETTINGS then
        G.SETTINGS.GAMESPEED = G.bomba_prev_gamespeed
        G.bomba_prev_gamespeed = nil
    end
end

local orig_game_start_run = Game.start_run
function Game:start_run(args)
    local is_bomba = G.bomba_starting or G.bomba_active or (args and args.bomba) or (self.GAME and self.GAME.bomba_active)
    G.bomba_starting = nil

    if orig_game_start_run then orig_game_start_run(self, args) end

    if is_bomba then
        if G.SETTINGS then
            if not G.bomba_prev_gamespeed then
                G.bomba_prev_gamespeed = G.SETTINGS.GAMESPEED
            end
            G.SETTINGS.GAMESPEED = 4
        end
        if self.GAME then
            self.GAME.bomba_active = true
            self.GAME.bomba_timer = 50.0
            if args and args.deck and G.P_CENTERS and G.P_CENTERS[args.deck] and Back then
                self.GAME.selected_back = Back(G.P_CENTERS[args.deck])
            end
            if args and args.casl_sleeve_choice and not self.GAME.selected_sleeve then
                self.GAME.selected_sleeve = args.casl_sleeve_choice
            end
        end
        G.bomba_active = true
        G.bomba_timer = 50.0
        G.bomba_timer_adding = 0
        G.bomba_last_real_time = nil
    else
        restore_bomba_gamespeed()
        G.bomba_active = false
        G.bomba_timer = nil
        G.bomba_timer_adding = 0
    end
end

local orig_game_main_menu = Game.main_menu
function Game:main_menu(change_context)
    restore_bomba_gamespeed()
    G.bomba_active = false
    G.bomba_starting = nil
    if orig_game_main_menu then orig_game_main_menu(self, change_context) end
end

if Game and Game.delete_run then
    local orig_game_delete_run = Game.delete_run
    function Game:delete_run(...)
        restore_bomba_gamespeed()
        G.bomba_active = false
        G.bomba_starting = nil
        return orig_game_delete_run(self, ...)
    end
end

if G.FUNCS and G.FUNCS.go_to_menu then
    local orig_go_to_menu = G.FUNCS.go_to_menu
    G.FUNCS.go_to_menu = function(e)
        restore_bomba_gamespeed()
        G.bomba_active = false
        G.bomba_starting = nil
        orig_go_to_menu(e)
    end
end

if love and love.quit then
    local orig_love_quit = love.quit
    love.quit = function(...)
        restore_bomba_gamespeed()
        return orig_love_quit(...)
    end
end

-- ----------------------------------------------------------------------------
-- Game:update Loop: Real-Time Countdown & Detonation
-- ----------------------------------------------------------------------------

local orig_game_update = Game.update
function Game:update(dt)
    if orig_game_update then orig_game_update(self, dt) end

    local is_active = G.bomba_active or (G.GAME and G.GAME.bomba_active)
    if not is_active then return end
    G.bomba_active = true

    if G.SETTINGS.paused or (G.OVERLAY_MENU and not G.OVERLAY_MENU.REMOVED) then
        G.bomba_last_real_time = nil
        return
    end

    -- Real unscaled delta calculation (immune to game speed)
    local cur_real = (G.TIMERS and G.TIMERS.REAL) or (love.timer and love.timer.getTime()) or 0
    if not G.bomba_last_real_time then G.bomba_last_real_time = cur_real end
    local real_delta = cur_real - G.bomba_last_real_time
    G.bomba_last_real_time = cur_real
    if real_delta < 0 or real_delta > 1.0 then
        real_delta = (love.timer and love.timer.getDelta()) or dt
    end

    -- 1. Rapidly count up added time (+40s on round win or +10s purchase) while playing wartimerup
    if G.bomba_timer_adding and G.bomba_timer_adding > 0 then
        local add_speed = 36.0 -- 40s ticks up rapidly in ~1.1s
        local add_step = math.min(G.bomba_timer_adding, add_speed * real_delta)
        G.bomba_timer = (G.bomba_timer or 0) + add_step
        G.bomba_timer_adding = G.bomba_timer_adding - add_step
        if G.GAME then G.GAME.bomba_timer = G.bomba_timer end

        G.bomba_up_sound_timer = (G.bomba_up_sound_timer or 0) + real_delta
        if G.bomba_up_sound_timer >= 1.2 and G.bomba_timer_adding > 0 then
            G.bomba_up_sound_timer = 0
            play_bomba_sound('wartimerup', 1.0, 0.70)
        end
    else
        G.bomba_timer_adding = 0
        G.bomba_up_sound_timer = nil
    end

    -- 2. Timer counts down only when in an active round (playing hands / discarding)
    local round_active = (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND)
    if round_active then
        local prev_sec = math.floor(G.bomba_timer or 0)
        G.bomba_timer = math.max(0, (G.bomba_timer or 50.0) - real_delta)
        if G.GAME then G.GAME.bomba_timer = G.bomba_timer end
        local cur_sec = math.floor(G.bomba_timer)

        -- Wartimer: single beep per second with the bomb (30% volume)
        if cur_sec < prev_sec and cur_sec >= 0 then
            play_bomba_sound('wartimer', 1.0, 0.30)
        end

        -- Detonation!
        if G.bomba_timer <= 0 and G.STATE ~= G.STATES.GAME_OVER then
            pcall(play_sound, 'explosion_release1', 0.8, 1.0)
            G.STATE = G.STATES.GAME_OVER
            G.STATE_COMPLETE = false
            if attention_text then
                attention_text({
                    text = 'TIME BOMB DETONATED! (0.0s)',
                    scale = 0.9,
                    hold = 4.0,
                    backdrop_colour = HEX('dc2626'),
                    align = 'cm',
                    offset = { x = 0, y = -1 }
                })
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Render Pass: Continuous Red Pulsing Background & Digital Bomb HUD
-- ----------------------------------------------------------------------------

local function render_bomba_overlay()
    local is_active = G.bomba_active or (G.GAME and G.GAME.bomba_active)
    if not is_active then return end
    G.bomba_active = true

    local cur_t = (love.timer and love.timer.getTime()) or (G.TIMERS and G.TIMERS.REAL) or 0
    if G.rw_bomba_last_draw_time and math.abs(cur_t - G.rw_bomba_last_draw_time) < 0.0001 then
        return
    end
    G.rw_bomba_last_draw_time = cur_t

    local sw = (love.graphics and love.graphics.getWidth()) or 1536
    local sh = (love.graphics and love.graphics.getHeight()) or 864
    local mx, my = love.mouse.getPosition()
    local t = cur_t
    local timer = G.bomba_timer or 50.0

    love.graphics.push('all')
    love.graphics.origin()
    love.graphics.setShader()

    -- 1. Red Flashing Background Pulse
    local freq = (timer <= 10) and 8.0 or ((timer <= 25) and 4.5 or 2.2)
    local min_a = (timer <= 10) and 0.12 or ((timer <= 25) and 0.06 or 0.03)
    local max_a = (timer <= 10) and 0.38 or ((timer <= 25) and 0.22 or 0.13)
    local pulse = (math.sin(t * freq) * 0.5 + 0.5)
    local red_alpha = min_a + pulse * (max_a - min_a)

    love.graphics.setBlendMode('add', 'alphamultiply')
    love.graphics.setColor(0.95, 0.12, 0.12, red_alpha)
    love.graphics.rectangle('fill', 0, 0, sw, sh)

    -- Red edge vignette border
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(0.85, 0.05, 0.05, red_alpha * 0.75)
    love.graphics.setLineWidth(12)
    love.graphics.rectangle('line', 6, 6, sw - 12, sh - 12)

    -- 2. Digital Countdown HUD & Interactive "+10s ($1)" Button (Top Center)
    local hud_w = 265
    local hud_h = 42
    local hud_x = sw * 0.5 - hud_w * 0.5
    local hud_y = 12

    local jitter_x = 0
    local jitter_y = 0
    if timer <= 10 then
        jitter_x = math.random(-2, 2)
        jitter_y = math.random(-1, 1)
    end

    -- HUD Casing
    love.graphics.setColor(0.08, 0.08, 0.10, 0.92)
    love.graphics.rectangle('fill', hud_x + jitter_x, hud_y + jitter_y, hud_w, hud_h, 6)
    local border_col = (timer <= 10) and {1.0, 0.2, 0.2, 0.95} or ((timer <= 25) and {0.98, 0.55, 0.15, 0.9} or {0.25, 0.85, 0.45, 0.85})
    love.graphics.setColor(border_col[1], border_col[2], border_col[3], border_col[4])
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', hud_x + jitter_x, hud_y + jitter_y, hud_w, hud_h, 6)

    -- Digital Clock Display
    local mins = math.floor(timer / 60)
    local secs = math.floor(timer % 60)
    local tenths = math.floor((timer * 10) % 10)
    local clock_str = string.format("%02d:%02d.%d", mins, secs, tenths)

    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.print("BOMB: " .. clock_str, hud_x + 12 + jitter_x, hud_y + 12 + jitter_y)

    -- Interactive Button: [+10s ($1)]
    local btn_w = 92
    local btn_h = 28
    local btn_x = hud_x + hud_w - btn_w - 8 + jitter_x
    local btn_y = hud_y + 7 + jitter_y

    G.bomba_button_rect = { x = btn_x, y = btn_y, w = btn_w, h = btn_h }

    local hovered = (mx >= btn_x and mx <= btn_x + btn_w and my >= btn_y and my <= btn_y + btn_h)
    local dollars = (G.GAME and G.GAME.dollars) or 0
    local can_afford = (dollars >= 1)

    if not can_afford then
        love.graphics.setColor(0.25, 0.25, 0.30, 0.85)
    elseif hovered then
        love.graphics.setColor(0.18, 0.75, 0.35, 0.95)
    else
        love.graphics.setColor(0.12, 0.55, 0.25, 0.90)
    end
    love.graphics.rectangle('fill', btn_x, btn_y, btn_w, btn_h, 4)

    love.graphics.setColor(hovered and {1, 1, 1, 1} or {0.9, 0.9, 0.9, 0.9})
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', btn_x, btn_y, btn_w, btn_h, 4)

    love.graphics.printf("+10s ($1)", btn_x, btn_y + 6, btn_w, "center")

    love.graphics.pop()
end

-- ----------------------------------------------------------------------------
-- Mouse Click Handler for "+10s ($1)" Button
-- ----------------------------------------------------------------------------

if love and love.mousepressed then
    local orig_mousepressed = love.mousepressed
    love.mousepressed = function(x, y, button, ...)
        if button == 1 and (G.bomba_active or (G.GAME and G.GAME.bomba_active)) and G.bomba_button_rect then
            local r = G.bomba_button_rect
            if x >= r.x and x <= r.x + r.w and y >= r.y and y <= r.y + r.h then
                G.FUNCS.reality_warp_buy_bomba_time()
                return
            end
        end
        return orig_mousepressed(x, y, button, ...)
    end
end

-- ----------------------------------------------------------------------------
-- Double Hook: love.draw AND Game.draw
-- ----------------------------------------------------------------------------

if not G.reality_warp_bomba_draw_hooked then
    G.reality_warp_bomba_draw_hooked = true
    if love and love.draw then
        local orig_love_draw = love.draw
        love.draw = function(...)
            orig_love_draw(...)
            render_bomba_overlay()
        end
    end
    if Game and Game.draw then
        local orig_game_draw = Game.draw
        function Game:draw(...)
            orig_game_draw(self, ...)
            render_bomba_overlay()
        end
    end
end

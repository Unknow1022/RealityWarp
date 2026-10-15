-- ============================================================================
-- Reality Warp - Special Game Modes & Main Menu Hub ("Other / Otros" Button)
-- ============================================================================

G.REALITY_WARP_GAME_MODES = G.REALITY_WARP_GAME_MODES or {}

function register_reality_warp_game_mode(mode_def)
    if not mode_def or not mode_def.id then return end
    for i, m in ipairs(G.REALITY_WARP_GAME_MODES) do
        if m.id == mode_def.id then
            G.REALITY_WARP_GAME_MODES[i] = mode_def
            return
        end
    end
    table.insert(G.REALITY_WARP_GAME_MODES, mode_def)
    table.sort(G.REALITY_WARP_GAME_MODES, function(a, b) return (a.order or 99) < (b.order or 99) end)
end

-- ----------------------------------------------------------------------------
-- Initial Game Modes Registration with Formatted Multi-Line Text
-- ----------------------------------------------------------------------------

register_reality_warp_game_mode({
    id = 'botg',
    title = 'BATTLE OF GODS',
    badge = 'ANTE 24',
    badge_colour = HEX('B71C1C'),
    desc_lines = {
        "Ascend through 24 grueling Antes.",
        "Face Olympian Gods & Fused Bosses.",
        "Starts at Ante 1 with $100 & Colosseum Deck."
    },
    features = {
        "Pocket Familiars Companion Active",
        "Exclusive Pantheon Booster Packs"
    },
    button_label = 'PLAY NOW',
    button_colour = HEX('B71C1C'),
    button_callback = 'reality_warp_start_botg_run',
    secondary_button_label = 'STAKE',
    secondary_button_colour = G.C.BLUE,
    secondary_button_callback = 'reality_warp_botg_setup_run',
    order = 1
})

register_reality_warp_game_mode({
    id = 'nursery',
    title = 'THE NURSERY',
    badge = '28 FAMILIARS',
    badge_colour = HEX('2E7D32'),
    desc_lines = {
        "Sanctuary for all 28 Pocket Boss Familiars.",
        "Feed, play, rest, and bond with companions.",
        "Level up familiars up to 5x potency."
    },
    features = {
        "Care actions: Feed, Play, Sleep, Pet",
        "Assign lead familiar to accompany runs"
    },
    button_label = 'ENTER NURSERY',
    button_colour = HEX('2E7D32'),
    button_callback = 'reality_warp_enter_nursery',
    order = 2
})

register_reality_warp_game_mode({
    id = 'joker_trials',
    title = 'JOKER TRIALS',
    badge = 'GAUNTLETS',
    badge_colour = HEX('6A1B9A'),
    desc_lines = {
        "Gauntlets built around unique mod Jokers.",
        "Special deck rules and win conditions.",
        "Exclusive trial challenges and mastery."
    },
    features = {
        "Curated themed starting loadouts",
        "Unique rules and modified stakes"
    },
    button_label = 'VIEW TRIALS',
    button_colour = HEX('6A1B9A'),
    button_callback = 'reality_warp_open_joker_trials_modal',
    order = 3
})

register_reality_warp_game_mode({
    id = 'apagon',
    title = 'BLACKOUT',
    badge = 'SURVIVAL',
    badge_colour = HEX('d97706'),
    desc_lines = {
        "Total blackout engulfs the entire casino.",
        "Your mouse becomes a lantern of burning embers.",
        "Hover over cards and UI to pierce the dark.",
        "Banish floating Ghost Jokers before 7 swarm!"
    },
    features = {
        "Dynamic Fiery Mouse Flashlight",
        "Wandering Ghost Jokers Hunter (7 = Game Over)"
    },
    button_label = 'PLAY BLACKOUT',
    button_colour = HEX('d97706'),
    button_callback = 'reality_warp_start_apagon_run',
    order = 4
})

register_reality_warp_game_mode({
    id = 'bomba',
    title = 'TIME BOMB',
    badge = 'SURVIVAL',
    badge_colour = HEX('dc2626'),
    desc_lines = {
        "A ticking time bomb threatens the table.",
        "Pulsing red alert flashes across the room.",
        "Start with 50 seconds to win the round.",
        "Blind victory adds +40s; buy time at $1 for +10s."
    },
    features = {
        "Continuous Red Alert Pulsing Screen",
        "50s Round Timer (+40s per Blind Won)",
        "Emergency Time Purchase: $1 = +10s"
    },
    button_label = 'PLAY TIME BOMB',
    button_colour = HEX('dc2626'),
    button_callback = 'reality_warp_start_bomba_run',
    order = 5
})

-- ----------------------------------------------------------------------------
-- UI Builder: Other Game Modes Hub (Compact & Proportionate)
-- ----------------------------------------------------------------------------

local function create_mode_card(mode)
    local desc_nodes = {}
    if mode.desc_lines then
        for _, line in ipairs(mode.desc_lines) do
            table.insert(desc_nodes, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.01 },
                nodes = {
                    { n = G.UIT.T, config = { text = line, scale = 0.25, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                }
            })
        end
    end

    local feat_nodes = {}
    if mode.features then
        for _, feat in ipairs(mode.features) do
            table.insert(feat_nodes, {
                n = G.UIT.R,
                config = { align = "cl", padding = 0.01 },
                nodes = {
                    { n = G.UIT.T, config = { text = "• " .. feat, scale = 0.23, colour = G.C.WHITE, shadow = true } }
                }
            })
        end
    end

    local action_buttons = {}
    if mode.button_label then
        table.insert(action_buttons, UIBox_button({
            label = { mode.button_label },
            button = mode.button_callback,
            colour = mode.button_colour or G.C.RED,
            minw = mode.secondary_button_label and 1.85 or 3.8,
            minh = 0.52,
            scale = 0.3,
            emboss = 0.06,
            col = true
        }))
    end
    if mode.secondary_button_label then
        table.insert(action_buttons, UIBox_button({
            label = { mode.secondary_button_label },
            button = mode.secondary_button_callback,
            colour = mode.secondary_button_colour or G.C.BLUE,
            minw = 1.85,
            minh = 0.52,
            scale = 0.3,
            emboss = 0.06,
            col = true
        }))
    end

    return {
        n = G.UIT.C,
        config = {
            align = "cm",
            padding = 0.06,
            r = 0.1,
            colour = G.C.L_BLACK,
            minw = 4.35,
            maxw = 4.45,
            minh = 2.4,
            emboss = 0.05,
            outline = 1.2,
            outline_colour = G.C.BLACK
        },
        nodes = {
            -- Title & Badge Row
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.03 },
                nodes = {
                    { n = G.UIT.T, config = { text = mode.title, scale = 0.34, colour = mode.badge_colour or G.C.WHITE, shadow = true } },
                    { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.04, r = 0.06, colour = mode.badge_colour or G.C.RED, minw = 1.0, minh = 0.22 },
                        nodes = {
                            { n = G.UIT.T, config = { text = mode.badge or "MODE", scale = 0.2, colour = G.C.WHITE, shadow = true } }
                        }
                    }
                }
            },
            -- Description lines
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.02 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = desc_nodes
                    }
                }
            },
            -- Bullet points / Features
            {
                n = G.UIT.R,
                config = { align = "cl", padding = 0.02 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cl" },
                        nodes = feat_nodes
                    }
                }
            },
            -- Action Buttons
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.04 },
                nodes = action_buttons
            }
        }
    }
end

function create_UIBox_reality_warp_other_modes()
    local modes = G.REALITY_WARP_GAME_MODES or {}
    local row1_nodes = {}
    local row2_nodes = {}

    for i, mode in ipairs(modes) do
        if i <= 3 then
            table.insert(row1_nodes, create_mode_card(mode))
        else
            table.insert(row2_nodes, create_mode_card(mode))
        end
    end

    local grid_nodes = {}
    if #row1_nodes > 0 then
        table.insert(grid_nodes, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.04 },
            nodes = row1_nodes
        })
    end
    if #row2_nodes > 0 then
        table.insert(grid_nodes, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.04 },
            nodes = row2_nodes
        })
    end

    local t = create_UIBox_generic_options({
        back_func = 'reality_warp_exit_other_modes',
        contents = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.04 },
                nodes = {
                    { n = G.UIT.T, config = { text = "SPECIAL GAME MODES", scale = 0.52, colour = G.C.GOLD, shadow = true } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.02 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Exclusive Reality Warp challenges, chambers, and companion sanctuaries", scale = 0.28, colour = G.C.UI.TEXT_LIGHT } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.04 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", minw = 9.1, maxw = 9.3 },
                        nodes = grid_nodes
                    }
                }
            }
        }
    })
    return t
end

-- ----------------------------------------------------------------------------
-- Callbacks for Mode Navigation
-- ----------------------------------------------------------------------------

G.FUNCS = G.FUNCS or {}

G.FUNCS.reality_warp_open_other_modes = function(e)
    G.SETTINGS.paused = true
    if G.trials_joker_area then
        G.trials_joker_area:remove()
        G.trials_joker_area = nil
    end
    G.FUNCS.overlay_menu{
        definition = create_UIBox_reality_warp_other_modes(),
    }
end

G.FUNCS.reality_warp_exit_other_modes = function(e)
    G.FUNCS.exit_overlay_menu()
end

G.FUNCS.reality_warp_noop = function(e)
    play_sound('cancel', 1.0, 0.8)
end

-- Battle of Gods Start Handlers
G.FUNCS.reality_warp_start_botg_run = function(e)
    G.SETTINGS.paused = false
    if G.OVERLAY_MENU then
        G.FUNCS.exit_overlay_menu()
    end
    local coliseo_center = (G.P_CENTERS and (G.P_CENTERS['b_reality_warp_coliseo'] or G.P_CENTERS['b_coliseo']))
    if coliseo_center and Back then
        G.GAME.selected_back = Back(coliseo_center)
        G.GAME.viewed_back = Back(coliseo_center)
    end
    if G.FUNCS and G.FUNCS.start_run then
        G.FUNCS.start_run(e or { config = {} }, {
            deck = coliseo_center and coliseo_center.key or 'b_reality_warp_coliseo',
            stake = 1
        })
    end
end

G.FUNCS.reality_warp_botg_setup_run = function(e)
    if G.OVERLAY_MENU then
        G.FUNCS.exit_overlay_menu()
    end
    local coliseo_center = (G.P_CENTERS and (G.P_CENTERS['b_reality_warp_coliseo'] or G.P_CENTERS['b_coliseo']))
    if coliseo_center and Back then
        G.GAME.selected_back = Back(coliseo_center)
        G.GAME.viewed_back = Back(coliseo_center)
    end
    if create_UIBox_run_setup then
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{ definition = create_UIBox_run_setup() }
    elseif G.FUNCS and G.FUNCS.setup_run then
        G.FUNCS.setup_run(e or { config = {}, UIBox = {} })
    end
end

-- Nursery Entry & Modal Handlers
G.FUNCS.reality_warp_enter_nursery = function(e)
    G.nursery_picker_open = false
    G.FUNCS.reality_warp_open_nursery_modal(e)
end

G.FUNCS.reality_warp_open_nursery_modal = function(e)
    G.SETTINGS.paused = true
    if G.UIDEF and G.UIDEF.nursery_tab then
        G.FUNCS.overlay_menu{
            definition = create_UIBox_generic_options({
                back_func = 'reality_warp_open_other_modes',
                contents = {
                    {
                        n = G.UIT.O,
                        config = {
                            id = 'tab_contents',
                            object = UIBox{
                                definition = G.UIDEF.nursery_tab('Nursery'),
                                config = { offset = { x = 0, y = 0 }, align = 'cm' }
                            }
                        }
                    }
                }
            })
        }
    end
end

-- Joker Trials Modal Handler
G.FUNCS.reality_warp_open_joker_trials_modal = function(e)
    G.SETTINGS.paused = true
    if G.UIDEF and G.UIDEF.outsider_trials_tab then
        G.FUNCS.overlay_menu{
            definition = create_UIBox_generic_options({
                back_func = 'reality_warp_open_other_modes',
                contents = {
                    {
                        n = G.UIT.O,
                        config = {
                            id = 'tab_contents',
                            object = UIBox{
                                definition = G.UIDEF.outsider_trials_tab('Joker Trials'),
                                config = { offset = { x = 0, y = 0 }, align = 'cm' }
                            }
                        }
                    }
                }
            })
        }
    end
end

-- ----------------------------------------------------------------------------
-- Hook: Insert "OTHER" Button into Main Menu Beside [ PLAY ]
-- ----------------------------------------------------------------------------

if create_UIBox_main_menu_buttons then
    local orig_create_menu_buttons = create_UIBox_main_menu_buttons
    function create_UIBox_main_menu_buttons()
        local menu = orig_create_menu_buttons()
        if menu and menu.nodes and menu.nodes[1] and menu.nodes[1].nodes and menu.nodes[1].nodes[1] and menu.nodes[1].nodes[1].nodes then
            local buttons = menu.nodes[1].nodes[1].nodes
            local exists = false
            for _, b in ipairs(buttons) do
                if b.config and (b.config.id == 'reality_warp_other_modes_button' or b.config.button == 'reality_warp_open_other_modes') then
                    exists = true
                    break
                end
            end
            if not exists then
                local other_btn = UIBox_button({
                    id = "reality_warp_other_modes_button",
                    minh = 1.55,
                    minw = 1.7,
                    col = true,
                    button = "reality_warp_open_other_modes",
                    label = {"OTHER"},
                    colour = HEX('8B0000')
                })
                table.insert(buttons, 2, other_btn)
            end
            -- Adjust container padding so all 6 buttons fit cleanly without overlapping Profile
            if menu.nodes[1].nodes[1].config then
                menu.nodes[1].nodes[1].config.padding = 0.08
            end
        end
        return menu
    end
end

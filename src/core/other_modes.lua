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
-- Initial Game Modes Registration
-- ----------------------------------------------------------------------------

register_reality_warp_game_mode({
    id = 'botg',
    title = 'BATTLE OF GODS',
    badge = 'Ante 24 Showdown',
    badge_colour = HEX('B71C1C'),
    desc = 'Ascend through 24 intense Antes facing Olympian Gods, fused boss encounters, and pantheon showdowns. Starts at Ante 1 with $100 and Colosseum bonuses.',
    features = {
        '24 Antes to Victory with God Bosses',
        'Pocket Familiars Companion Slot Active',
        'Exclusive Pantheon Booster Packs'
    },
    button_label = 'PLAY NOW',
    button_colour = HEX('B71C1C'),
    button_callback = 'reality_warp_start_botg_run',
    secondary_button_label = 'SELECT STAKE',
    secondary_button_colour = G.C.BLUE,
    secondary_button_callback = 'reality_warp_botg_setup_run',
    order = 1
})

register_reality_warp_game_mode({
    id = 'nursery',
    title = 'THE NURSERY',
    badge = '28 Familiars',
    badge_colour = HEX('2E7D32'),
    desc = 'Visit the interactive sanctuary of all 28 Pocket Mini-Boss Familiars. Feed, play, rest, and level up companions to boost their abilities in your runs.',
    features = {
        'Feed, Play, Sleep, and Pet Familiars',
        'Levels boost familiar power up to 5x',
        'Assign your Lead Companion for runs'
    },
    button_label = 'ENTER NURSERY',
    button_colour = HEX('2E7D32'),
    button_callback = 'reality_warp_open_nursery_modal',
    order = 2
})

register_reality_warp_game_mode({
    id = 'joker_trials',
    title = 'JOKER TRIALS',
    badge = 'Exclusive Gauntlets',
    badge_colour = HEX('6A1B9A'),
    desc = 'Challenge gauntlets built around unique Outsider and mod Jokers with dedicated deck configurations, special modifiers, and win conditions.',
    features = {
        'Curated themed trial decks',
        'Custom rules and special stakes',
        'Unlock unique badges and mastery'
    },
    button_label = 'VIEW TRIALS',
    button_colour = HEX('6A1B9A'),
    button_callback = 'reality_warp_open_joker_trials_modal',
    order = 3
})

register_reality_warp_game_mode({
    id = 'chronos_rift',
    title = 'CHRONOS RIFT',
    badge = 'Coming Soon',
    badge_colour = G.C.UI.BACKGROUND_INACTIVE,
    desc = 'Temporal anomalies, dimensional glitch tears, and endless boss rush modes will be added here in upcoming Reality Warp updates.',
    features = {
        'Glitch Tear Distortions',
        'Endless Boss Rush Chambers',
        'Automatically expands with new modes'
    },
    button_label = 'LOCKED',
    button_colour = G.C.UI.BACKGROUND_INACTIVE,
    button_callback = 'reality_warp_noop',
    order = 4
})

-- ----------------------------------------------------------------------------
-- UI Builder: Other Game Modes Hub
-- ----------------------------------------------------------------------------

local function create_mode_card(mode)
    local feat_nodes = {}
    if mode.features then
        for _, feat in ipairs(mode.features) do
            table.insert(feat_nodes, {
                n = G.UIT.R,
                config = { align = "cl", padding = 0.02 },
                nodes = {
                    { n = G.UIT.T, config = { text = "• " .. feat, scale = 0.26, colour = G.C.WHITE } }
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
            minw = mode.secondary_button_label and 2.4 or 4.6,
            minh = 0.65,
            scale = 0.34,
            emboss = 0.08,
            col = true
        }))
    end
    if mode.secondary_button_label then
        table.insert(action_buttons, UIBox_button({
            label = { mode.secondary_button_label },
            button = mode.secondary_button_callback,
            colour = mode.secondary_button_colour or G.C.BLUE,
            minw = 2.4,
            minh = 0.65,
            scale = 0.34,
            emboss = 0.08,
            col = true
        }))
    end

    return {
        n = G.UIT.C,
        config = {
            align = "cm",
            padding = 0.1,
            r = 0.12,
            colour = G.C.L_BLACK,
            minw = 5.6,
            minh = 3.6,
            emboss = 0.06,
            outline = 1.5,
            outline_colour = G.C.BLACK
        },
        nodes = {
            -- Title & Badge Row
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.04 },
                nodes = {
                    { n = G.UIT.T, config = { text = mode.title, scale = 0.44, colour = mode.badge_colour or G.C.WHITE } },
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.06, r = 0.08, colour = mode.badge_colour or G.C.RED, minw = 1.4, minh = 0.3 },
                        nodes = {
                            { n = G.UIT.T, config = { text = mode.badge or "MODE", scale = 0.22, colour = G.C.WHITE } }
                        }
                    }
                }
            },
            -- Description
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.04, minw = 5.2 },
                nodes = {
                    { n = G.UIT.T, config = { text = mode.desc, scale = 0.27, colour = G.C.UI.TEXT_LIGHT } }
                }
            },
            -- Bullet points / Features
            {
                n = G.UIT.R,
                config = { align = "cl", padding = 0.04, minw = 5.2 },
                nodes = feat_nodes
            },
            -- Action Buttons
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.06 },
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
        if i <= 2 then
            table.insert(row1_nodes, create_mode_card(mode))
        else
            table.insert(row2_nodes, create_mode_card(mode))
        end
    end

    local grid_nodes = {}
    if #row1_nodes > 0 then
        table.insert(grid_nodes, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.08 },
            nodes = row1_nodes
        })
    end
    if #row2_nodes > 0 then
        table.insert(grid_nodes, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.08 },
            nodes = row2_nodes
        })
    end

    local t = create_UIBox_generic_options({
        back_func = 'reality_warp_exit_other_modes',
        contents = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    { n = G.UIT.T, config = { text = "SPECIAL GAME MODES", scale = 0.72, colour = G.C.GOLD } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.02 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Exclusive Reality Warp challenges, chambers, and companion sanctuaries", scale = 0.32, colour = G.C.UI.TEXT_LIGHT } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = grid_nodes
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
        G.FUNCS.start_run(nil, {
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
    if G.FUNCS and G.FUNCS.setup_run then
        G.FUNCS.setup_run()
    end
end

-- Nursery Modal Handler
G.FUNCS.reality_warp_open_nursery_modal = function(e)
    G.SETTINGS.paused = true
    G.nursery_picker_open = false
    if G.UIDEF and G.UIDEF.nursery_tab then
        G.FUNCS.overlay_menu{
            definition = create_UIBox_generic_options({
                back_func = 'reality_warp_open_other_modes',
                contents = {
                    {
                        n = G.UIT.R,
                        config = { id = 'tab_contents', align = "cm" },
                        nodes = {
                            G.UIDEF.nursery_tab('Nursery')
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
                        n = G.UIT.R,
                        config = { id = 'tab_contents', align = "cm" },
                        nodes = {
                            G.UIDEF.outsider_trials_tab('Joker Trials')
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
                    minw = 1.85,
                    col = true,
                    button = "reality_warp_open_other_modes",
                    label = {"OTHER"},
                    colour = HEX('8B0000')
                })
                -- Insert at position 2 (directly beside PLAY button)
                table.insert(buttons, 2, other_btn)
            end
        end
        return menu
    end
end

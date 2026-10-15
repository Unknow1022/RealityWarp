
function get_reality_warp_mod()
    if SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] then
        return SMODS.Mods['reality_warp']
    end
    if SMODS and SMODS.findMod then
        local found = SMODS.findMod('reality_warp')
        if found and found[1] then return found[1] end
    end
    if reality_warp_MOD then
        return reality_warp_MOD
    end
    if SMODS and SMODS.current_mod then
        return SMODS.current_mod
    end
    return nil
end

function get_reality_warp_config()
    local mod = get_reality_warp_mod()
    if mod and mod.config then
        return mod.config
    end
    if SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config then
        return SMODS.Mods['reality_warp'].config
    end
    return {}
end

function save_reality_warp_config()
    local mod = get_reality_warp_mod()
    if SMODS and SMODS.save_mod_config and mod then
        pcall(function() SMODS.save_mod_config(mod) end)
    end
    local cfg = get_reality_warp_config()
    local new_runs = cfg.new_runs == true
    local new_challenges = cfg.new_challenges ~= false
    local new_spectrals_and_jobs = cfg.new_spectrals_and_jobs ~= false
    local new_boss_blinds = cfg.new_boss_blinds ~= false
    local fast_animations = cfg.fast_animations == true
    local botg_music = cfg.botg_music ~= false and cfg.secret_power_theme ~= false
    local config_str = "return {\n" ..
        "    [\"new_runs\"] = " .. tostring(new_runs) .. ",\n" ..
        "    [\"new_challenges\"] = " .. tostring(new_challenges) .. ",\n" ..
        "    [\"new_spectrals_and_jobs\"] = " .. tostring(new_spectrals_and_jobs) .. ",\n" ..
        "    [\"new_boss_blinds\"] = " .. tostring(new_boss_blinds) .. ",\n" ..
        "    [\"fast_animations\"] = " .. tostring(fast_animations) .. ",\n" ..
        "    [\"botg_music\"] = " .. tostring(botg_music) .. ",\n" ..
        "}\n"
    local mod_path = (mod and mod.path) or ""
    if SMODS and SMODS.NFS and SMODS.NFS.write and mod_path ~= "" then
        pcall(function() SMODS.NFS.write(mod_path .. "config.lua", config_str) end)
    elseif NFS and NFS.write and mod_path ~= "" then
        pcall(function() NFS.write(mod_path .. "config.lua", config_str) end)
    elseif love and love.filesystem and love.filesystem.write then
        pcall(function() love.filesystem.write("config.lua", config_str) end)
    end
end

local ENGLISH_CHALLENGE_NAMES = {
    ['c_reality_warp_high_roller_casino'] = "High Roller's Casino",
    ['c_reality_warp_high_roller_casino'] = "High Roller's Casino",
    ['high_roller_casino'] = "High Roller's Casino",
    ['c_reality_warp_casino_roller'] = "High Roller's Casino",
    ['c_reality_warp_casino_roller'] = "High Roller's Casino",
    ['casino_roller'] = "High Roller's Casino",

    ['c_reality_warp_absolute_silence'] = 'Absolute Silence',
    ['c_reality_warp_absolute_silence'] = 'Absolute Silence',
    ['absolute_silence'] = 'Absolute Silence',
    ['c_reality_warp_silencio_absoluto'] = 'Absolute Silence',
    ['c_reality_warp_silencio_absoluto'] = 'Absolute Silence',
    ['silencio_absoluto'] = 'Absolute Silence',

    ['c_reality_warp_sacred_symmetry'] = 'Sacred Symmetry',
    ['c_reality_warp_sacred_symmetry'] = 'Sacred Symmetry',
    ['sacred_symmetry'] = 'Sacred Symmetry',
    ['c_reality_warp_geometria_sagrada'] = 'Sacred Symmetry',
    ['c_reality_warp_geometria_sagrada'] = 'Sacred Symmetry',
    ['geometria_sagrada'] = 'Sacred Symmetry',

    ['c_reality_warp_predatory_loan'] = 'Predatory Loan',
    ['c_reality_warp_predatory_loan'] = 'Predatory Loan',
    ['predatory_loan'] = 'Predatory Loan',
    ['c_reality_warp_deuda_extrema'] = 'Predatory Loan',
    ['c_reality_warp_deuda_extrema'] = 'Predatory Loan',
    ['deuda_extrema'] = 'Predatory Loan',

    ['c_reality_warp_the_forge_and_mine'] = 'The Forge & The Mine',
    ['c_reality_warp_the_forge_and_mine'] = 'The Forge & The Mine',
    ['the_forge_and_mine'] = 'The Forge & The Mine',
    ['c_reality_warp_forja_y_mina'] = 'The Forge & The Mine',
    ['c_reality_warp_forja_y_mina'] = 'The Forge & The Mine',
    ['forja_y_mina'] = 'The Forge & The Mine',

    ['c_reality_warp_parity_duel'] = 'Parity Duel',
    ['c_reality_warp_parity_duel'] = 'Parity Duel',
    ['parity_duel'] = 'Parity Duel',
    ['c_reality_warp_duelo_numerico'] = 'Parity Duel',
    ['c_reality_warp_duelo_numerico'] = 'Parity Duel',
    ['duelo_numerico'] = 'Parity Duel',

    ['c_reality_warp_living_canvas'] = 'The Living Canvas',
    ['c_reality_warp_living_canvas'] = 'The Living Canvas',
    ['living_canvas'] = 'The Living Canvas',
    ['c_reality_warp_lienzo_vivo'] = 'The Living Canvas',
    ['c_reality_warp_lienzo_vivo'] = 'The Living Canvas',
    ['lienzo_vivo'] = 'The Living Canvas',

    ['c_reality_warp_edition_tycoon'] = 'Edition Tycoon',
    ['c_reality_warp_edition_tycoon'] = 'Edition Tycoon',
    ['edition_tycoon'] = 'Edition Tycoon',
    ['c_reality_warp_coleccionista_brillos'] = 'Edition Tycoon',
    ['c_reality_warp_coleccionista_brillos'] = 'Edition Tycoon',
    ['coleccionista_brillos'] = 'Edition Tycoon',

    ['c_reality_warp_code_red_er'] = 'Code Red ER',
    ['c_reality_warp_code_red_er'] = 'Code Red ER',
    ['code_red_er'] = 'Code Red ER',
    ['c_reality_warp_urgencias_medicas'] = 'Code Red ER',
    ['c_reality_warp_urgencias_medicas'] = 'Code Red ER',
    ['urgencias_medicas'] = 'Code Red ER',

    ['c_reality_warp_singular_saturation'] = 'Singular Saturation',
    ['c_reality_warp_singular_saturation'] = 'Singular Saturation',
    ['singular_saturation'] = 'Singular Saturation',
    ['c_reality_warp_sobresaturacion'] = 'Singular Saturation',
    ['c_reality_warp_sobresaturacion'] = 'Singular Saturation',
    ['sobresaturacion'] = 'Singular Saturation',

    ['c_omelette_1'] = 'The Omelette',
    ['c_city_1'] = '15 Minute City',
    ['c_rich_1'] = 'Rich get Richer',
    ['c_knife_1'] = "On a Knife's Edge",
    ['c_xray_1'] = 'X-ray Vision',
    ['c_mad_world_1'] = 'Mad World',
    ['c_luxury_1'] = 'Luxury Tax',
    ['c_non_perishable_1'] = 'Non-Perishable',
    ['c_medusa_1'] = 'Medusa',
    ['c_double_nothing_1'] = 'Double or Nothing',
    ['c_typecast_1'] = 'Typecast',
    ['c_inflation_1'] = 'Inflation',
    ['c_bram_poker_1'] = 'Bram Poker',
    ['c_fragile_1'] = 'Fragile',
    ['c_monolith_1'] = 'Monolith',
    ['c_blast_off_1'] = 'Blast Off',
    ['c_five_card_1'] = 'Five-Card Draw',
    ['c_golden_needle_1'] = 'Golden Needle',
    ['c_cruelty_1'] = 'Cruelty',
    ['c_jokerless_1'] = 'Jokerless',
}

function reparse_localization_entry(entry)
    if not entry then return end
    if loc_parse_string then
        if entry.text then
            entry.text_parsed = {}
            local flat_text = {}
            local function parse_lines(lines)
                for _, line in ipairs(lines) do
                    if type(line) == 'table' then
                        parse_lines(line)
                    elseif type(line) == 'string' then
                        flat_text[#flat_text + 1] = line
                        entry.text_parsed[#entry.text_parsed + 1] = loc_parse_string(line)
                    end
                end
            end
            parse_lines(entry.text)
            entry.text = flat_text
        else
            entry.text_parsed = entry.text_parsed or {}
        end
        if entry.name then
            entry.name_parsed = {}
            local function parse_names(names)
                for _, line in ipairs(names) do
                    if type(line) == 'table' then
                        parse_names(line)
                    elseif type(line) == 'string' then
                        entry.name_parsed[#entry.name_parsed + 1] = loc_parse_string(line)
                    end
                end
            end
            local names = (type(entry.name) == 'table') and entry.name or { entry.name }
            parse_names(names)
        else
            entry.name_parsed = entry.name_parsed or {}
        end
        if entry.unlock then
            entry.unlock_parsed = {}
            local flat_unlock = {}
            local function parse_unlocks(lines)
                for _, line in ipairs(lines) do
                    if type(line) == 'table' then
                        parse_unlocks(line)
                    elseif type(line) == 'string' then
                        flat_unlock[#flat_unlock + 1] = line
                        entry.unlock_parsed[#entry.unlock_parsed + 1] = loc_parse_string(line)
                    end
                end
            end
            local ulines = (type(entry.unlock) == 'table') and entry.unlock or { entry.unlock }
            parse_unlocks(ulines)
            entry.unlock = flat_unlock
        else
            entry.unlock_parsed = entry.unlock_parsed or {}
        end
    else
        entry.text_parsed = entry.text_parsed or {}
        entry.name_parsed = entry.name_parsed or {}
        entry.unlock_parsed = entry.unlock_parsed or {}
    end
end

local SPANISH_TRANSLATIONS = {
    descriptions = {
        Joker = {
            j_reality_warp_mad_ghost = {
                name = 'Mad Ghost',
                text = {
                    "Acompañante de mew mew"
                }
            }
        },
        Tag = {},
        Other = {
            bull_market = {
                name = 'Mercado Alcista',
                text = {
                    "¡Alto optimismo!",
                    "Las acciones suben a {C:money}$12-$18{}.",
                    "{C:inactive}(Superar Ciega en 1 mano){}"
                }
            },
            bear_market = {
                name = 'Mercado Bajista',
                text = {
                    "¡Desplome del mercado!",
                    "Las acciones bajan a {C:money}$2-$5{}.",
                    "{C:inactive}(Usar todas las manos en una ronda){}"
                }
            }
        }
    },
    misc = {
        dictionary = {
            ['k_job'] = 'Empleo',
            ['b_job_cards'] = 'Cartas de Empleo',
            ['k_job_pack'] = 'Solicitud de Empleo'
        }
    }
}

function apply_reality_warp_language()
    local lang = G.SETTINGS and G.SETTINGS.language or 'en-us'
    if lang ~= 'es_419' and lang ~= 'es_ES' then return end

    if SPANISH_TRANSLATIONS.descriptions and G.localization.descriptions then
        for cat, items in pairs(SPANISH_TRANSLATIONS.descriptions) do
            G.localization.descriptions[cat] = G.localization.descriptions[cat] or {}
            for k, v in pairs(items) do
                G.localization.descriptions[cat][k] = v
                reparse_localization_entry(v)
            end
        end
    end
    if SPANISH_TRANSLATIONS.misc and G.localization.misc then
        for cat, items in pairs(SPANISH_TRANSLATIONS.misc) do
            G.localization.misc[cat] = G.localization.misc[cat] or {}
            for k, v in pairs(items) do
                G.localization.misc[cat][k] = v
            end
        end
    end
end

local function init_reality_warp_localization()
    if not G.localization then return end

    if G.localization.descriptions then
        for _, set_table in pairs(G.localization.descriptions) do
            if type(set_table) == 'table' then
                for _, entry in pairs(set_table) do
                    if type(entry) == 'table' and not entry.text_parsed then
                        reparse_localization_entry(entry)
                    end
                end
            end
        end

        G.localization.descriptions.Other = G.localization.descriptions.Other or {}
        G.localization.descriptions.Other['bull_market'] = {
            name = 'Bull Market',
            text = {
                "High market optimism!",
                "Next round's stock price rises",
                "sharply to {C:money}$12-$18{}.",
                "{C:inactive}(Triggered by beating Blind in 1 hand){}"
            }
        }
        G.localization.descriptions.Other['bear_market'] = {
            name = 'Bear Market',
            text = {
                "Market downturn and crash!",
                "Next round's stock price falls",
                "sharply to {C:money}$2-$5{}.",
                "{C:inactive}(Triggered by using all hands in a round){}"
            }
        }
        reparse_localization_entry(G.localization.descriptions.Other['bull_market'])
        reparse_localization_entry(G.localization.descriptions.Other['bear_market'])
    end

    if G.localization.misc then
        if not G.localization.misc.challenge_names then
            G.localization.misc.challenge_names = {}
        end
        for k, v in pairs(ENGLISH_CHALLENGE_NAMES) do
            G.localization.misc.challenge_names[k] = v
        end

        if G.localization.misc.v_dictionary then
            G.localization.misc.v_dictionary['ch_c_single_random_suit'] = 'Deck consists of a single random suit'
            G.localization.misc.v_dictionary['ch_c_all_perishable'] = 'All Jokers are perishable'
        end
        if G.localization.misc.dictionary then
            G.localization.misc.dictionary['ch_c_single_random_suit'] = 'Deck consists of a single random suit'
            G.localization.misc.dictionary['ch_c_all_perishable'] = 'All Jokers are perishable'
            G.localization.misc.dictionary['k_job'] = 'Job'
            G.localization.misc.dictionary['b_job_cards'] = 'Job Cards'
            G.localization.misc.dictionary['k_job_pack'] = 'Job Application'
        end
    end

    if G.CHALLENGES then
        for _, ch in ipairs(G.CHALLENGES) do
            if ch and ch.id and ENGLISH_CHALLENGE_NAMES[ch.id] then
                ch.name = ENGLISH_CHALLENGE_NAMES[ch.id]
            end
        end
    end

    apply_reality_warp_language()

    if protect_reality_warp_from_auto_translation then
        protect_reality_warp_from_auto_translation()
    end

    if alias_all_reality_warp_centers then
        alias_all_reality_warp_centers()
    end
end

function protect_reality_warp_from_auto_translation()
    if not G.localization or not G.localization.descriptions then return end
    if G.P_CENTERS then
        for k, v in pairs(G.P_CENTERS) do
            local str = tostring(k)
            if (string.find(str, 'reality_warp', 1, true) or (v.mod and v.mod.id == 'reality_warp')) then
                local set_name = v.set or 'Joker'
                G.localization.descriptions[set_name] = G.localization.descriptions[set_name] or {}
                local entry = G.localization.descriptions[set_name][k] or G.localization.descriptions[set_name][v.key]
                if not entry and G.localization.descriptions[set_name] then
                    entry = {}
                    G.localization.descriptions[set_name][k] = entry
                end
                if entry then
                    if v.loc_txt then
                        if v.loc_txt.name then entry.name = v.loc_txt.name end
                        if v.loc_txt.text then entry.text = v.loc_txt.text end
                        if v.loc_txt.unlock then entry.unlock = v.loc_txt.unlock end
                    end
                    if v.unlock and not entry.unlock then
                        entry.unlock = v.unlock
                    end
                    reparse_localization_entry(entry)
                end
            end
        end
    end
end

if type(auto_translate) == 'function' then
    local _orig_auto_trans = auto_translate
    auto_translate = function(text, key, ...)
        local str = tostring(key or '')
        if string.find(str, 'reality_warp', 1, true) or string.find(str, 'reality_warp', 1, true) then
            return text
        end
        return _orig_auto_trans(text, key, ...)
    end
end

local original_init_loc = init_localization
function init_localization()
    if original_init_loc then original_init_loc() end
    init_reality_warp_localization()
end

local function build_reality_warp_config_tab()
    local cfg = get_reality_warp_config()

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.06,
            colour = G.C.CLEAR
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.12,
                    r = 0.16,
                    colour = {0.05, 0.05, 0.09, 0.92},
                    outline = 1.2,
                    outline_colour = {0.35, 0.22, 0.6, 0.8},
                    emboss = 0.05
                },
                nodes = {
                    -- Top Header
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "BALATRO: REALITY WARP",
                                    scale = 0.50,
                                    colour = G.C.GOLD,
                                    shadow = true
                                }
                            }
                        }
                    },
                    -- Sub-capsules / Badges
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.04 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.04, r = 0.08, colour = {0.50, 0.15, 0.80, 0.85} },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "v1.0.0",
                                            scale = 0.22,
                                            colour = G.C.WHITE,
                                            shadow = true
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.04, r = 0.08, colour = {0.16, 0.16, 0.24, 0.85} },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "BY UNKNOW102",
                                            scale = 0.22,
                                            colour = G.C.UI.TEXT_LIGHT
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.04, r = 0.08, colour = {0.14, 0.28, 0.58, 0.85} },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "STEAMODDED API",
                                            scale = 0.22,
                                            colour = G.C.GOLD
                                        }
                                    }
                                }
                            }
                        }
                    },
                    -- Flavor Quote
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "\"Reality bends at your fingertips. Toggle expansion modules below.\"",
                                    scale = 0.22,
                                    colour = G.C.UI.TEXT_LIGHT
                                }
                            }
                        }
                    },
                    -- Main Dual Panels (Gameplay & Aesthetics)
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.05 },
                        nodes = {
                            -- Left Panel: Gameplay Modules
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "tm",
                                    padding = 0.08,
                                    r = 0.12,
                                    colour = {0.08, 0.09, 0.16, 0.90},
                                    outline = 1.0,
                                    outline_colour = {0.20, 0.35, 0.65, 0.70}
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            padding = 0.05,
                                            r = 0.08,
                                            colour = {0.15, 0.28, 0.58, 0.80}
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = "✦ GAMEPLAY MODULES ✦",
                                                    scale = 0.27,
                                                    colour = G.C.WHITE,
                                                    shadow = true
                                                }
                                            }
                                        }
                                    },
                                    create_toggle({
                                        label = "New Runs",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "new_runs",
                                        callback = function(val)
                                            save_reality_warp_config()
                                        end,
                                        info = {
                                            "Optional. Seeds generate divergent",
                                            "variations from vanilla Balatro."
                                        }
                                    }),
                                    create_toggle({
                                        label = "New Challenges",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "new_challenges",
                                        callback = function(val)
                                            save_reality_warp_config()
                                            if reality_warp_sync_challenges then
                                                reality_warp_sync_challenges(cfg.new_challenges)
                                            end
                                        end,
                                        info = {
                                            "Toggles the 10 synergy challenges",
                                            "added by this mod in real-time."
                                        }
                                    }),
                                    create_toggle({
                                        label = "New Spectrals & Jobs",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "new_spectrals_and_jobs",
                                        callback = function(val)
                                            save_reality_warp_config()
                                        end,
                                        info = {
                                            "Toggles custom Job cards and new",
                                            "Spectrals in the consumable pool."
                                        }
                                    }),
                                    create_toggle({
                                        label = "New Boss Blinds",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "new_boss_blinds",
                                        callback = function(val)
                                            save_reality_warp_config()
                                        end,
                                        info = {
                                            "Enables Reality Warp's 11 Boss Blinds",
                                            "(The Pole, The Rod, The Door, etc)."
                                        }
                                    }),
                                    create_toggle({
                                        label = "Battle of Gods",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "battle_of_gods",
                                        callback = function(val)
                                            save_reality_warp_config()
                                        end,
                                        info = {
                                            "Post-Ante 8 Battle of Gods mode."
                                        }
                                    })
                                }
                            },
                            -- Right Panel: Aesthetics & Audio
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "tm",
                                    padding = 0.08,
                                    r = 0.12,
                                    colour = {0.12, 0.08, 0.18, 0.90},
                                    outline = 1.0,
                                    outline_colour = {0.55, 0.22, 0.75, 0.70}
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            padding = 0.05,
                                            r = 0.08,
                                            colour = {0.45, 0.16, 0.62, 0.80}
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = "✦ AESTHETICS & AUDIO ✦",
                                                    scale = 0.27,
                                                    colour = G.C.WHITE,
                                                    shadow = true
                                                }
                                            }
                                        }
                                    },
                                    create_toggle({
                                        label = "Purple/Red Menu BG",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "custom_menu_bg",
                                        callback = function(val)
                                            save_reality_warp_config()
                                            if apply_reality_warp_menu_bg then
                                                apply_reality_warp_menu_bg(val)
                                            end
                                        end,
                                        info = {
                                            "Changes main menu vortex background",
                                            "to mystic purple and red ambient tones."
                                        }
                                    }),
                                    create_toggle({
                                        label = "Fast Animations",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "fast_animations",
                                        callback = function(val)
                                            save_reality_warp_config()
                                        end,
                                        info = {
                                            "Reduces delays on custom mechanics",
                                            "(Slot spins, transforms) for speed."
                                        }
                                    }),
                                    create_toggle({
                                        label = "BotG Soundtrack",
                                        w = 2.6,
                                        scale = 0.72,
                                        label_scale = 0.28,
                                        ref_table = cfg,
                                        ref_value = "botg_music",
                                        callback = function(val)
                                            cfg.secret_power_theme = val
                                            save_reality_warp_config()
                                        end,
                                        info = {
                                            "Battle of Gods Soundtrack",
                                            "(Orchestral Joker Theme)",
                                            "When disabled, completely turns off",
                                            "mod custom music and restores original."
                                        }
                                    })
                                }
                            }
                        }
                    },
                    -- Randomize Stake Stickers Button (Permanent)
                    {
                        n = G.UIT.R,
                        config = {
                            id = "rw_cheat_container",
                            align = "cm",
                            padding = 0.08,
                            r = 0.12,
                            colour = {0.14, 0.08, 0.22, 0.95},
                            outline = 1.2,
                            outline_colour = G.C.GOLD
                        },
                        nodes = {
                            UIBox_button({
                                button = "rw_apply_random_stake_stickers",
                                label = { "✦ RANDOMIZE ALL STAKE STICKERS ✦" },
                                minw = 4.8,
                                minh = 0.72,
                                scale = 0.32,
                                colour = G.C.GOLD,
                                col = true
                            }),
                            {
                                n = G.UIT.R,
                                config = { align = "cm", padding = 0.02 },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "Randomizes stake win stickers across all Jokers and Decks",
                                            scale = 0.20,
                                            colour = G.C.UI.TEXT_LIGHT
                                        }
                                    }
                                }
                            }
                        }
                    },
                    -- Bottom Status Pill
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            padding = 0.05,
                            r = 0.08,
                            colour = {0.05, 0.14, 0.08, 0.85},
                            outline = 1.0,
                            outline_colour = {0.15, 0.45, 0.20, 0.60}
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "● Settings are automatically saved in real-time",
                                    scale = 0.22,
                                    colour = G.C.GREEN
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end

G.FUNCS = G.FUNCS or {}
G.FUNCS.rw_apply_random_stake_stickers = function(e)
    local profile = G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile]
    if not profile then return end
    profile.joker_usage = profile.joker_usage or {}
    profile.deck_usage = profile.deck_usage or {}
    profile.deck_stakes = profile.deck_stakes or {}

    local all_stakes = {}
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Stake then
        for i, s in ipairs(G.P_CENTER_POOLS.Stake) do
            table.insert(all_stakes, { index = i, key = s.key })
        end
    end
    if #all_stakes == 0 then
        for i = 1, 8 do table.insert(all_stakes, { index = i, key = 'stake_' .. i }) end
    end

    if G.P_CENTERS then
        for k, center in pairs(G.P_CENTERS) do
            if center.set == 'Joker' then
                profile.joker_usage[k] = profile.joker_usage[k] or {
                    count = 1,
                    order = center.order or 1,
                    wins = {},
                    losses = {},
                    wins_by_key = {},
                    losses_by_key = {}
                }
                local ju = profile.joker_usage[k]
                ju.wins = {}
                ju.wins_by_key = {}
                local chosen_stake = pseudorandom_element(all_stakes, pseudoseed('rw_cheat_j_' .. k .. '_' .. math.random(1, 99999)))
                for _, s in ipairs(all_stakes) do
                    if s.index <= chosen_stake.index then
                        ju.wins[s.index] = 1
                        ju.wins_by_key[s.key] = 1
                    end
                end
            end
        end
    end

    if G.P_CENTERS then
        for k, center in pairs(G.P_CENTERS) do
            if center.set == 'Back' then
                profile.deck_usage[k] = profile.deck_usage[k] or {
                    count = 1,
                    order = center.order or 1,
                    wins = {},
                    losses = {},
                    wins_by_key = {},
                    losses_by_key = {}
                }
                local du = profile.deck_usage[k]
                du.wins = {}
                du.wins_by_key = {}
                local chosen_stake = pseudorandom_element(all_stakes, pseudoseed('rw_cheat_d_' .. k .. '_' .. math.random(1, 99999)))
                profile.deck_stakes[k] = chosen_stake.index
                for _, s in ipairs(all_stakes) do
                    if s.index <= chosen_stake.index then
                        du.wins[s.index] = 1
                        du.wins_by_key[s.key] = 1
                    end
                end
            end
        end
    end

    if G.save_progress then G:save_progress() end
    if G.save_settings then G:save_settings() end

    play_sound('gold_seal', 1.3, 0.9)
    play_sound('holo1', 1.4, 0.7)
    attention_text({
        text = 'STAKE STICKERS RANDOMIZED!',
        scale = 0.8,
        hold = 1.5,
        backdrop_colour = HEX('ffd700'),
        align = 'cm',
        offset = { x = 0, y = -1 }
    })
end

local mod_init = get_reality_warp_mod()
if mod_init then
    mod_init.config = mod_init.config or {}
    if mod_init.config.new_runs == nil then mod_init.config.new_runs = false end
    if mod_init.config.new_challenges == nil then mod_init.config.new_challenges = true end
    if mod_init.config.new_spectrals_and_jobs == nil then mod_init.config.new_spectrals_and_jobs = true end
    if mod_init.config.new_boss_blinds == nil then mod_init.config.new_boss_blinds = true end
    if mod_init.config.fast_animations == nil then mod_init.config.fast_animations = false end
    if mod_init.config.custom_menu_bg == nil then mod_init.config.custom_menu_bg = true end
    if mod_init.config.botg_music == nil then
        if mod_init.config.secret_power_theme ~= nil then
            mod_init.config.botg_music = mod_init.config.secret_power_theme
        else
            mod_init.config.botg_music = true
        end
    end
    if mod_init.config.secret_power_theme == nil then mod_init.config.secret_power_theme = true end
    if mod_init.config.battle_of_gods == nil then mod_init.config.battle_of_gods = true end
    if mod_init.config.unlocked_cheat_stickers == nil then mod_init.config.unlocked_cheat_stickers = false end
    mod_init.config_tab = build_reality_warp_config_tab
end
if SMODS and SMODS.current_mod then
    SMODS.current_mod.config_tab = build_reality_warp_config_tab
end

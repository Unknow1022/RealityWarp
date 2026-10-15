
if not to_number then
    function to_number(x)
        if type(x) == 'table' then
            if x.to_number then return x:to_number() end
            return tonumber(x[1]) or 0
        end
        return tonumber(x) or 0
    end
end

local function patch_malverk(target)
    if target and target.set_defaults and not target._patched_set_defaults then
        local orig = target.set_defaults
        target.set_defaults = function(pack, ...)
            if not pack then return end
            return orig(pack, ...)
        end
        target._patched_set_defaults = true
    end
end

if malverk then patch_malverk(malverk) end
if Malverk then patch_malverk(Malverk) end
if SMODS and SMODS.Mods and SMODS.Mods['malverk'] then patch_malverk(SMODS.Mods['malverk']) end

local shader_meta = debug.getregistry() and debug.getregistry().Shader
if shader_meta and shader_meta.send then
    local orig_shader_send = shader_meta.send
    shader_meta.send = function(self, name, ...)
        if self.hasUniform and not self:hasUniform(name) then
            return
        end
        local ok, res = pcall(orig_shader_send, self, name, ...)
        if not ok then
            return
        end
        return res
    end
end

if SMODS then
    local orig_localize_box = SMODS.localize_box
    SMODS.localize_box = function(lines, args)
        if not lines or type(lines) ~= 'table' then
            lines = (type(lines) == 'string' and lines ~= '') and { lines } or {}
        end
        if orig_localize_box then
            return orig_localize_box(lines, args)
        end
        return {}
    end
end

if create_popup_UIBox_tooltip then
    local orig_create_popup_UIBox_tooltip = create_popup_UIBox_tooltip
    create_popup_UIBox_tooltip = function(tooltip)
        if tooltip and type(tooltip.text) == 'table' then
            local clean_text = {}
            for _, line in ipairs(tooltip.text) do
                if line and line ~= '' then
                    table.insert(clean_text, line)
                end
            end
            tooltip.text = clean_text
        end
        return orig_create_popup_UIBox_tooltip(tooltip)
    end
end

function get_card_key(card)
    if not card then return nil end
    return (card.config and card.config.center and card.config.center.key)
        or (card.config and card.config.center_key)
        or (card.ability and card.ability.name)
        or nil
end

function card_has_key(card, key)
    if not card or not key then return false end
    local k = get_card_key(card)
    if not k then return false end
    if k == key then return true end
    if string.find(k, key, 1, true) ~= nil then return true end
    return false
end

function has_charles_and_mochi()
    if not (G and G.jokers and G.jokers.cards) then return false end
    local has_charles, has_mochi = false, false
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff then
            if card_has_key(j, 'charles') then has_charles = true end
            if card_has_key(j, 'mochi') then has_mochi = true end
        end
    end
    return has_charles and has_mochi
end

function is_secret_card(card)
    if not card then return false end
    if card.is_secret or (card.config and card.config.center and card.config.center.is_secret) then return true end
    local key = get_card_key(card) or ''
    key = string.lower(tostring(key))
    local secret_names = {
        'esteban', 'thiago', 'black_hole', 'squele', 'bluxdir', 'charles', 'mochi', 'helin', 'raytracing', 'paco', 'yairo', 'kyra',
        'astra', 'marie', 'callie', 'sally', 'marina', 'perla', 'espectro_del_balance'
    }
    for _, name in ipairs(secret_names) do
        if string.find(key, name, 1, true) then return true end
    end
    return false
end

function is_amalgam_card(card)
    if not card then return false end
    if card.is_amalgam or (card.config and card.config.center and (card.config.center.is_amalgam or card.config.center.rarity == 'Amalgam')) then return true end
    local key = get_card_key(card) or ''
    key = string.lower(tostring(key))
    local amalgam_names = {
        'brainprint', 'vampiric_midas', 'certified_programming', 'galactic_traveler', 'colorful_street',
        'mime_king', 'photo_album', 'pirate_egg', 'reinforced_boots', 'wee_comedian', 'golden_lucky_cat', 'unrecognizable_antique', 'macabre_emoji',
        'midas_vampirico', 'programacion_certificacion', 'viajero_galactico', 'calle_colorida', 'rey_de_mimos', 'album_de_fotos', 'huevo_pirata', 'botas_reforzadas', 'gato_dorado_suerte', 'antiguedad_irreconocible', 'emoji_macabro', 'amalgam', 'amalgama'
    }
    for _, name in ipairs(amalgam_names) do
        if string.find(key, name, 1, true) then return true end
    end
    return false
end

function emit_secret_screen_sparkles(colours)
    if not (G and G.ROOM_ATTACH and G.ROOM_ATTACH.children and Particles) then return end
    if G.GAME and G.TIMERS and G.TIMERS.REAL then
        if G.GAME.last_secret_sparkle_time and (G.TIMERS.REAL - G.GAME.last_secret_sparkle_time < 0.25) then
            return
        end
        G.GAME.last_secret_sparkle_time = G.TIMERS.REAL
    end

    colours = colours or { G.C.WHITE, HEX('8a2be2'), HEX('d4af37'), HEX('ff00ff'), HEX('00ffff') }
    local p = Particles(0, 0, 0, 0, {
        timer = 0.015,
        pulse_max = 24,
        max = 0,
        scale = 0.32,
        speed = 1.3,
        lifespan = 1.1,
        attach = G.ROOM_ATTACH,
        colours = colours,
        fill = true
    })

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.75,
        blockable = false,
        blocking = false,
        func = function()
            if p and p.fade then p:fade(0.35, 1) end
            return true
        end
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 1.25,
        blockable = false,
        blocking = false,
        func = function()
            if p and p.remove then p:remove() end
            return true
        end
    }))
end

function is_invalid_eternal_joker(card)
    if not card then return true end
    if is_secret_card(card) then return true end
    local key = get_card_key(card) or ''
    key = string.lower(tostring(key))
    local invalid_keys = {
        'gros_michel', 'cavendish', 'ice_cream', 'popcorn', 'turtle_bean',
        'ramen', 'seltzer', 'diet_cola', 'egg', 'invisible', 'luchador',
        'mr_bones', 'blueberry', 'parca', 'ceremonial'
    }
    for _, ik in ipairs(invalid_keys) do
        if string.find(key, ik, 1, true) then return true end
    end
    return false
end

function is_sleeve_matching(target_key)
    if not target_key then return false end
    if G and G.GAME then
        if G.GAME[target_key .. "_sleeve_combo"] then return true end
        if G.GAME[target_key .. "_sleeve_active"] then return true end
        if G.GAME[target_key .. "_sleeve_selected"] then return true end
        if G.GAME.selected_sleeve then
            local s = tostring(G.GAME.selected_sleeve.key or G.GAME.selected_sleeve.name or G.GAME.selected_sleeve)
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
        if G.GAME.sleeve then
            local s = tostring(G.GAME.sleeve.key or G.GAME.sleeve.name or G.GAME.sleeve)
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
    end
    if CardSleeves then
        if CardSleeves.get_current_sleeve then
            local s = tostring(CardSleeves.get_current_sleeve() or "")
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
        if CardSleeves.Sleeve and CardSleeves.Sleeve.get_current_sleeve_key then
            local s = tostring(CardSleeves.Sleeve.get_current_sleeve_key() or "")
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
        if CardSleeves.current_sleeve then
            local s = tostring(CardSleeves.current_sleeve)
            if string.find(s, target_key, 1, true) ~= nil then return true end
        end
    end
    return false
end

function is_wild_card(pcard)
    if not pcard then return false end
    if SMODS and SMODS.has_enhancement and SMODS.has_enhancement(pcard, 'm_wild') then
        return true
    end
    if pcard.ability then
        if pcard.ability.name == 'Wild Card' or pcard.ability.effect == 'Wild Card' or pcard.ability.label == 'Wild Card' then
            return true
        end
    end
    if pcard.config then
        if pcard.config.center_key == 'm_wild' then return true end
        if type(pcard.config.center) == 'table' and pcard.config.center.key == 'm_wild' then return true end
        if type(pcard.config.center) == 'string' and pcard.config.center == 'm_wild' then return true end
        if pcard.config.center == G.P_CENTERS.m_wild then return true end
    end
    return false
end

function is_joker_copiable(card)
    if not card then return false end
    if card.debuff then return false end

    local key = get_card_key(card) or ''
    key = tostring(key)
    local name = (card.ability and card.ability.name) or (card.config and card.config.center and card.config.center.name) or ''
    name = tostring(name)

    if name == 'Chameleon' or name == 'Brainprint' or 
       string.find(key, 'brainprint', 1, true) or string.find(key, 'chameleon_joker', 1, true) then
        return false
    end

    if card.config and card.config.center and card.config.center.blueprint_compat == false then
        return false
    end
    if card.ability and card.ability.blueprint_compat == false then
        return false
    end

    return true
end

local card_generate_UIBox_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(...)
    ensure_custom_seals_discovered()
    local is_secret = is_secret_card(self)
    if is_secret then
        G.GAME_IS_RENDERING_SECRET_CARD = true
    end
    local res = card_generate_UIBox_ref(self, ...)
    G.GAME_IS_RENDERING_SECRET_CARD = false

    local is_brainprint = card_has_key(self, 'brainprint') or (self.ability and self.ability.name == 'Brainprint')
    if is_brainprint and res and res.main and G.jokers and G.jokers.cards then
        local my_idx = nil
        for idx, j in ipairs(G.jokers.cards) do
            if j == self then my_idx = idx; break end
        end
        local left_joker = (my_idx and my_idx > 1) and G.jokers.cards[my_idx - 1] or nil
        local right_joker = (my_idx and my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1] or nil

        local l_compat = left_joker and is_joker_copiable(left_joker)
        local r_compat = right_joker and is_joker_copiable(right_joker)

        local l_name = left_joker and ((left_joker.ability and left_joker.ability.name) or (left_joker.config and left_joker.config.center and left_joker.config.center.name)) or "None"
        local r_name = right_joker and ((right_joker.ability and right_joker.ability.name) or (right_joker.config and right_joker.config.center and right_joker.config.center.name)) or "None"

        local brainprint_ui_box = {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.CLEAR, padding = 0.04 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = l_compat and G.C.GREEN or G.C.RED, r = 0.08, padding = 0.03, minw = 2.4, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " [L] " .. (l_compat and "Compatible" or "Incompatible") .. " (" .. l_name .. ") ", colour = G.C.WHITE, scale = 0.28 } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = r_compat and G.C.GREEN or G.C.RED, r = 0.08, padding = 0.03, minw = 2.4, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " [R] " .. (r_compat and "Compatible" or "Incompatible") .. " (" .. r_name .. ") ", colour = G.C.WHITE, scale = 0.28 } }
                    }
                }
            }
        }
        table.insert(res.main, { brainprint_ui_box })
    end

    if self.doppelganger_reflected and res and res.main then
        local rand_mult = math.random(-50, -1)
        local rand_chips = math.random(-100, -5)
        local rand_div = string.format('%.1f', math.random(15, 50) / 10)
        local glitch_glyphs = { "?", "!", "#", "$", "@", "%", "&", "Ø", "§", "¿" }
        local g1 = glitch_glyphs[math.random(1, #glitch_glyphs)] .. glitch_glyphs[math.random(1, #glitch_glyphs)]
        local g2 = glitch_glyphs[math.random(1, #glitch_glyphs)] .. glitch_glyphs[math.random(1, #glitch_glyphs)]

        res.main = {
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", colour = HEX('1c2833'), r = 0.08, padding = 0.06, minw = 2.6, emboss = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = " [ POSSESSED BY DOPPELGÄNGER ] ", colour = HEX('e74c3c'), scale = 0.32 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.03 },
                    nodes = {
                        { n = G.UIT.T, config = { text = g1 .. " INVERTED EFFECT " .. g2, colour = HEX('aeb6bf'), scale = 0.3 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = tostring(rand_mult) .. " Mult  /  " .. tostring(rand_chips) .. " Chips", colour = G.C.RED, scale = 0.3 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Divides Mult by /" .. tostring(rand_div), colour = HEX('ff7675'), scale = 0.28 } }
                    }
                }
            },
            {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "(Ignores cards on retrigger)", colour = HEX('7f8c8d'), scale = 0.25 } }
                    }
                }
            }
        }
    end

    return res
end

if Card.generate_card_ui then
    local gen_card_ui_ref = Card.generate_card_ui
    function Card:generate_card_ui(...)
        local is_secret = is_secret_card(self)
        if is_secret then
            G.GAME_IS_RENDERING_SECRET_CARD = true
        end
        local res = gen_card_ui_ref(self, ...)
        G.GAME_IS_RENDERING_SECRET_CARD = false
        return res
    end
end

G.C.reality_warp_BADGE_COL = G.C.reality_warp_BADGE_COL or { 0, 0, 0, 1 }
G.C.reality_warp_TEXT_COL = G.C.reality_warp_TEXT_COL or { 1, 1, 1, 1 }

if not G.reality_warp_badge_timer_hooked and Game and Game.update then
    G.reality_warp_badge_timer_hooked = true
    local orig_game_update = Game.update
    function Game:update(dt)
        orig_game_update(self, dt)
        if G.TIMERS and G.TIMERS.REAL then
            local t = (math.sin(G.TIMERS.REAL * 2.5) + 1) * 0.5
            G.C.reality_warp_BADGE_COL[1] = t
            G.C.reality_warp_BADGE_COL[2] = t
            G.C.reality_warp_BADGE_COL[3] = t
            G.C.reality_warp_BADGE_COL[4] = 1

            G.C.reality_warp_TEXT_COL[1] = 1 - t
            G.C.reality_warp_TEXT_COL[2] = 1 - t
            G.C.reality_warp_TEXT_COL[3] = 1 - t
            G.C.reality_warp_TEXT_COL[4] = 1
        end
    end
end

local create_badge_ref = create_badge
function create_badge(text, badge_colour, text_colour, scale)
    if type(text) == 'table' then
        return text
    end
    if type(text) == 'string' then
        local t_lower = string.lower(text)
        if t_lower == 'reality_warp' or t_lower == 'reality_warp_expansion' or t_lower == 'reality_warp_expansion' or t_lower == 'witcher brew expansion' or t_lower == 'reality warp' or t_lower == 'balatro: reality warp' or string.find(t_lower, 'witch.*brew') or string.find(t_lower, 'reality.*warp') then
            text = 'Reality Warp'
            badge_colour = G.C.reality_warp_BADGE_COL
            text_colour = G.C.reality_warp_TEXT_COL
        end
    end
    if G.GAME_IS_RENDERING_SECRET_CARD and (text == 'Legendary' or text == 'Legendario' or text == 'Secret' or text == 'Secreto' or text == 'Outsider' or (localize and text == localize('k_legendary'))) then
        text = 'Outsider'
        badge_colour = HEX('000000')
        text_colour = G.C.WHITE
    end
    if type(text) ~= 'string' then
        text = tostring(text or '')
    end
    return create_badge_ref(text, badge_colour, text_colour, scale)
end

function check_witcher_joker_achievements()
    if not (G.jokers and G.jokers.cards and botg_trigger_mod_achievement) then return end

    local leg_count = 0
    local sec_count = 0
    local mod_joker_count = 0
    local song_count = 0
    local has_finance_joker = false
    local has_god_joker = false

    for _, j in ipairs(G.jokers.cards) do
        local k = (j.config and j.config.center and j.config.center.key) or ''
        local rarity = (j.config and j.config.center and j.config.center.rarity) or 1
        local is_mod = string.find(k, 'reality_warp') or string.find(k, 'witch')

        if is_mod then
            mod_joker_count = mod_joker_count + 1
        end
        if rarity == 4 or rarity == 'Legendary' or string.find(k, 'geralt') or string.find(k, 'ciri') or string.find(k, 'yennefer') or string.find(k, 'triss') or string.find(k, 'regis') then
            leg_count = leg_count + 1
        end
        if rarity == 'Secret' or rarity == 'Amalgam' or string.find(k, 'secret') or string.find(k, 'amalgam') or (j.ability and j.ability.is_secret) then
            sec_count = sec_count + 1
        end
        if (j.ability and j.ability.is_song) or string.find(k, 'song') or string.find(k, 'bard') or string.find(k, 'ballad') or string.find(k, 'hymn') or string.find(k, 'requiem') or string.find(k, 'symphony') then
            song_count = song_count + 1
        end
        if string.find(k, 'shareholder') or string.find(k, 'slot_machine') or string.find(k, 'tycoon') or string.find(k, 'merchant') or string.find(k, 'banker') then
            has_finance_joker = true
        end
        if string.find(k, 'zeus') or string.find(k, 'hades') or string.find(k, 'ares') or string.find(k, 'athena') or string.find(k, 'chronos') or string.find(k, 'poseidon') or string.find(k, 'god_') or (j.ability and j.ability.god) then
            has_god_joker = true
        end
    end

    if leg_count >= 2 then
        botg_trigger_mod_achievement('court_of_legends')
    end
    if sec_count >= 3 then
        botg_trigger_mod_achievement('forbidden_pantheon')
    end
    if mod_joker_count >= 5 then
        botg_trigger_mod_achievement('wolf_school_arsenal')
    end
    if song_count >= 2 then
        botg_trigger_mod_achievement('grand_symphony')
    end
    if has_finance_joker and G.GAME and G.GAME.dollars and G.GAME.dollars >= 100 then
        botg_trigger_mod_achievement('high_finance')
    end
    if has_god_joker then
        botg_trigger_mod_achievement('godly_vessel')
    end
end

if CardArea and CardArea.emplace then
    local orig_cardarea_emplace = CardArea.emplace
    function CardArea:emplace(card, ...)
        if not card then return end
        local ret = orig_cardarea_emplace(self, card, ...)
        if self == G.jokers and check_witcher_joker_achievements then
            check_witcher_joker_achievements()
        end
        return ret
    end
end

function ease_job_pack_background()
    ease_colour(G.C.DYN_UI.MAIN, HEX('4a4a54'))
    ease_colour(G.C.DYN_UI.DARK, HEX('24242a'))
    ease_background_colour{new_colour = HEX('4a4a54'), special_colour = HEX('6b6b78'), contrast = 2}
end

local card_open_ref = Card.open
function Card:open()
    local is_job_pack = self.ability and self.ability.set == 'Booster' and (
        (self.ability.name and string.find(self.ability.name, 'job_pack')) or
        (self.config and self.config.center and (self.config.center.kind == 'Job' or (self.config.center.key and string.find(self.config.center.key, 'job_pack'))))
    )
    local is_mod_pack = self.ability and self.ability.set == 'Booster' and (
        is_job_pack or
        (self.ability.name and (string.find(self.ability.name, 'witch') or string.find(self.ability.name, 'alchemy') or string.find(self.ability.name, 'potion'))) or
        (self.config and self.config.center and self.config.center.key and (string.find(self.config.center.key, 'reality_warp') or string.find(self.config.center.key, 'witch') or string.find(self.config.center.key, 'alchemy')))
    )
    if is_mod_pack and botg_trigger_mod_achievement then
        botg_trigger_mod_achievement('herb_forager')
    end
    local ret = card_open_ref(self)
    if is_job_pack then
        ease_job_pack_background()
    end
    return ret
end

if localize then
    local orig_localize = localize
    function localize(args, misc_cat)
        if type(args) == 'string' then
            if args == 'k_job_pack' or args == 'k_job_pack_1' or args == 'k_job_pack_2' or args == 'k_job_pack_3' then
                return 'Job Application'
            end
        elseif type(args) == 'table' then
            if args.key == 'k_job_pack' then
                return 'Job Application'
            end
            if args.type == 'descriptions' and args.set and args.key and G.localization and G.localization.descriptions then
                local set = G.localization.descriptions[args.set]
                local target = set and set[args.key]
                if target and type(target) == 'table' and not target.text_parsed then
                    target.text_parsed = {}
                    if target.text and type(target.text) == 'table' and loc_parse_string then
                        for _, line in ipairs(target.text) do
                            target.text_parsed[#target.text_parsed + 1] = loc_parse_string(line)
                        end
                    end
                    if not target.name_parsed and target.name and loc_parse_string then
                        target.name_parsed = {}
                        local names = type(target.name) == 'table' and target.name or { target.name }
                        for _, line in ipairs(names) do
                            target.name_parsed[#target.name_parsed + 1] = loc_parse_string(line)
                        end
                    end
                end
            elseif (args.type == 'other' or args.type == 'Other') and args.key and G.localization and G.localization.descriptions and G.localization.descriptions.Other then
                local target = G.localization.descriptions.Other[args.key]
                if target and type(target) == 'table' and not target.text_parsed then
                    target.text_parsed = {}
                    if target.text and type(target.text) == 'table' then
                        for _, line in ipairs(target.text) do
                            target.text_parsed[#target.text_parsed + 1] = (loc_parse_string and loc_parse_string(line)) or { { strings = { line }, control = {} } }
                        end
                    end
                    if not target.name_parsed and target.name then
                        target.name_parsed = {}
                        local names = type(target.name) == 'table' and target.name or { target.name }
                        for _, line in ipairs(names) do
                            target.name_parsed[#target.name_parsed + 1] = (loc_parse_string and loc_parse_string(line)) or { { strings = { line }, control = {} } }
                        end
                    end
                end
            end
        end
        local res = orig_localize(args, misc_cat)
        if res == 'ERROR' and type(args) == 'string' then
            if args == 'k_job_pack' or string.find(args, 'job_pack') then
                return 'Job Application'
            end
        end
        return res
    end
end

function check_all_suits_flushed_unlock(self, args)
    if (args.type == 'hand' or args.type == 'play_hand') and args.scoring_hand and #args.scoring_hand >= 4 then
        G.GAME.flushed_suits = G.GAME.flushed_suits or {}
        local suits = {'Hearts', 'Spades', 'Clubs', 'Diamonds'}
        for _, s in ipairs(suits) do
            local matches = true
            for _, c in ipairs(args.scoring_hand) do
                if not c:is_suit(s) then matches = false; break end
            end
            if matches then
                G.GAME.flushed_suits[s] = true
            end
        end
        if G.GAME.flushed_suits.Hearts and G.GAME.flushed_suits.Spades and G.GAME.flushed_suits.Clubs and G.GAME.flushed_suits.Diamonds then
            return true
        end
    end
    if G.GAME and G.GAME.flushed_suits and G.GAME.flushed_suits.Hearts and G.GAME.flushed_suits.Spades and G.GAME.flushed_suits.Clubs and G.GAME.flushed_suits.Diamonds then
        return true
    end
end

local card_redeem_ref = Card.redeem
function Card:redeem(...)
    local key = (self.config and self.config.center and self.config.center.key) or self.config.center_key or (self.ability and self.ability.name)
    if key == 'v_blank' or key == 'v_reality_warp_blank' or key == 'blank' then
        if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] then
            G.PROFILES[G.SETTINGS.profile].blank_vouchers_bought = (G.PROFILES[G.SETTINGS.profile].blank_vouchers_bought or 0) + 1
        end
        check_for_unlock({ type = 'blank_voucher_bought' })
    end
    if key and (string.find(key, 'catador') or string.find(key, 'critico') or string.find(key, 'reality_warp')) then
        if botg_trigger_mod_achievement then botg_trigger_mod_achievement('royal_connoisseur') end
    end

    local ret = card_redeem_ref(self, ...)

    if self.ability and self.ability.set == 'Voucher' then
        local raw_key = (self.config and self.config.center and self.config.center.key) or self.config.center_key or ""
        local c_key = self.config.center_key or raw_key
        local keys_to_mark = {
            raw_key,
            c_key,
            string.gsub(raw_key, 'reality_warp_', 'Witch brew_'),
            string.gsub(raw_key, 'Witch brew_', 'reality_warp_'),
            string.gsub(raw_key, 'v_reality_warp_', 'v_'),
            string.gsub(raw_key, 'v_Witch brew_', 'v_'),
            string.gsub(raw_key, 'v_reality_warp_', ''),
            string.gsub(raw_key, 'v_Witch brew_', '')
        }
        if G.GAME then
            G.GAME.used_vouchers = G.GAME.used_vouchers or {}
            for _, k in ipairs(keys_to_mark) do
                if k and k ~= "" then
                    G.GAME.used_vouchers[k] = true
                end
            end
            if G.GAME.current_round and G.GAME.current_round.voucher and G.GAME.current_round.voucher.spawn then
                for _, target_k in ipairs(keys_to_mark) do
                    if target_k and target_k ~= "" then
                        G.GAME.current_round.voucher.spawn[target_k] = false
                    end
                end
            end
        end
    end

    return ret
end

function is_oil_card(card)
    if not card then return false end
    if card.config and card.config.center then
        local k = card.config.center.key
        if k == 'oil' or k == 'm_reality_warp_oil' or k == 'm_oil' then return true end
    end
    if SMODS and SMODS.has_enhancement and SMODS.has_enhancement(card, 'oil') then return true end
    if card.ability and (card.ability.name == 'Oil Card' or card.ability.effect == 'Oil Card') then return true end
    return false
end

if eval_card then
    local eval_card_ref = eval_card
    function eval_card(card, context)
        if card and (card.destroyed or card.shattered) then
            return {}, {}
        end
        if G.GAME and G.GAME.reality_warp_hand_debuffed and context and (context.after or context.joker_main or context.before) then
            return {}, {}
        end
        local ret, post_trig = eval_card_ref(card, context)
        if context and not context.repetition and not context.repetition_only and context.cardarea == G.play and context.scoring_hand and not (card.destroyed or card.shattered) and not card.debuff then
            local oil_count = 0
            for _, other in ipairs(context.scoring_hand) do
                if other ~= card and is_oil_card(other) and not other.debuff then
                    oil_count = oil_count + 1
                end
            end
            if oil_count > 0 then
                ret = ret or {}
                ret.mult = (ret.mult or 0) + (5 * oil_count)
            end
        end
        if ret and ret.dollars and (ret.mult or ret.h_mult or ret.x_mult or ret.Xmult) then
            if G.GAME then G.GAME.lucky_hit_both = true end
            check_for_unlock({ type = 'lucky_both' })
        end
        return ret or {}, post_trig or {}
    end
end

function reality_warp_flip_apply(args)
    if not args or not args.targets then return end
    local card = args.card
    local raw_targets = args.targets
    local targets = {}
    if raw_targets.is and raw_targets:is(Card) then
        targets = { raw_targets }
    elseif type(raw_targets) == 'table' then
        for _, t in ipairs(raw_targets) do
            if t and t.is and t:is(Card) then
                table.insert(targets, t)
            end
        end
    end
    if #targets == 0 then return end

    if card then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
    end

    for i = 1, #targets do
        local percent = (#targets > 1) and (1.15 - (i - 0.999) / (#targets - 0.998) * 0.3) or 1.0
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                targets[i]:flip()
                play_sound('card1', percent)
                targets[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end

    delay(0.2)

    for i = 1, #targets do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                if args.apply then
                    args.apply(targets[i], i)
                end
                return true
            end
        }))
    end

    local up_sound = args.sound or 'tarot2'
    for i = 1, #targets do
        local percent = (#targets > 1) and (0.85 + (i - 0.999) / (#targets - 0.998) * 0.3) or 1.0
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                targets[i]:flip()
                play_sound(up_sound, percent, 0.6)
                targets[i]:juice_up(0.4, 0.4)
                if args.message then
                    card_eval_status_text(targets[i], 'extra', nil, nil, nil, { message = args.message, colour = args.colour or G.C.GOLD })
                end
                return true
            end
        }))
    end

    if args.unhighlight ~= false then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
    delay(0.3)
end

function reset_reality_warp_boss_ui(state)
    if G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
        local cur_state = state or (G and G.STATE)
        if cur_state == G.STATES.SELECTING_HAND 
           or cur_state == G.STATES.HAND_PLAYED 
           or cur_state == G.STATES.DRAW_TO_HAND 
           or cur_state == G.STATES.PLAY_TAROT 
           or (G.TAROT_INTERRUPT and G.TAROT_INTERRUPT ~= G.STATES.SHOP and G.TAROT_INTERRUPT ~= G.STATES.ROUND_EVAL and G.TAROT_INTERRUPT ~= G.STATES.BLIND_SELECT) then
            return
        end
    end

    state = state or (G and G.STATE)
    if G.C and G.C.DYN_UI then
        local fixed_ui = HEX('374244')
        local def_boss_main = darken(G.C.BLACK, 0.05)
        local def_boss_dark = lighten(G.C.BLACK, 0.07)

        if G.C.DYN_UI.MAIN then
            ease_colour(G.C.DYN_UI.MAIN, fixed_ui)
        end
        if G.C.DYN_UI.DARK then
            ease_colour(G.C.DYN_UI.DARK, fixed_ui)
        end
        if G.C.DYN_UI.BOSS_MAIN then
            ease_colour(G.C.DYN_UI.BOSS_MAIN, def_boss_main)
        end
        if G.C.DYN_UI.BOSS_DARK then
            ease_colour(G.C.DYN_UI.BOSS_DARK, def_boss_dark)
        end
        if G.C.DYN_UI.BOSS_PALE then
            ease_colour(G.C.DYN_UI.BOSS_PALE, fixed_ui)
        end
    end

    if G.GAME then
        G.GAME.blind_color = nil
        G.GAME.doppelganger_target = nil
        G.GAME.doppelganger_hand_mult = 0
        G.GAME.doppelganger_hand_chips = 0
        G.GAME.doppelganger_hand_xmult = 1
        G.GAME.doppelganger_hand_xchips = 1
        G.GAME.doppelganger_target_name = nil
    end
    if G.ARGS then
        G.ARGS.blind_colour = nil
    end

    if ease_background_colour then
        local bg_col = (G.C and G.C.BLIND and G.C.BLIND['Small']) or (G.C and G.C.BACKGROUND and G.C.BACKGROUND.D) or HEX('374244')
        ease_background_colour{
            new_colour = bg_col,
            special_colour = bg_col,
            contrast = 1
        }
    end
end

if ease_background_colour then
    local orig_ease_bg = ease_background_colour
    function ease_background_colour(args)
        if G.GAME and G.GAME.mega_flirt_until and G.TIMERS and G.TIMERS.REAL and G.TIMERS.REAL < G.GAME.mega_flirt_until and not (args and args._mega_flirt) then
            return
        end
        if args and not args._is_reality_warp_theme and G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
            local is_pack = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or
                             G.STATE == G.STATES.STANDARD_PACK or G.STATE == G.STATES.BUFFOON_PACK or
                             G.STATE == G.STATES.PLANET_PACK)
            local not_in_menu = (G.STATE ~= G.STATES.SHOP and G.STATE ~= G.STATES.ROUND_EVAL and G.STATE ~= G.STATES.BLIND_SELECT)
            if not_in_menu and not is_pack then
                local theme = get_reality_warp_blind_theme and get_reality_warp_blind_theme(G.GAME.blind)
                if theme then
                    args.new_colour = theme.new_colour
                    args.special_colour = theme.special_colour
                    args.tertiary_colour = theme.tertiary_colour
                    args.contrast = theme.contrast or 2
                    args._is_reality_warp_theme = true
                elseif G.GAME.blind.boss then
                    local def_small = (G.C and G.C.BLIND and G.C.BLIND['Small'])
                    local is_default_bg = (args.new_colour == def_small) or (type(args.new_colour) == 'table' and def_small and args.new_colour[1] == def_small[1] and args.new_colour[2] == def_small[2] and args.new_colour[3] == def_small[3])
                    if is_default_bg then return end
                end
            end
        end
        return orig_ease_bg(args)
    end
end

if Blind and Blind.change_colour then
    local orig_blind_change_colour = Blind.change_colour
    function Blind:change_colour(blind_col)
        if self.boss and not self.disabled then
            local theme = get_reality_warp_blind_theme and get_reality_warp_blind_theme(self)
            if theme then
                if G.C and G.C.DYN_UI then
                    if theme.boss_colour then ease_colour(G.C.DYN_UI.BOSS_MAIN, theme.boss_colour) end
                    if theme.tertiary_colour or theme.boss_colour then ease_colour(G.C.DYN_UI.BOSS_DARK, theme.tertiary_colour or theme.boss_colour) end
                    if theme.special_colour then ease_colour(G.C.DYN_UI.MAIN, theme.special_colour) end
                    if theme.tertiary_colour then ease_colour(G.C.DYN_UI.DARK, theme.tertiary_colour) end
                end
                return
            end
        end
        orig_blind_change_colour(self, blind_col)
    end
end

if ease_background_colour_blind then
    local orig_ease_bg_blind = ease_background_colour_blind
    function ease_background_colour_blind(state, blind_override)
        local blind = G.GAME and G.GAME.blind
        local blindname = blind_override or (blind and blind.name ~= '' and blind.name) or ''

        local is_pack = (state == G.STATES.TAROT_PACK or state == G.STATES.SPECTRAL_PACK or
                         state == G.STATES.STANDARD_PACK or state == G.STATES.BUFFOON_PACK or
                         state == G.STATES.PLANET_PACK)

        local theme = nil
        if not is_pack and blind and blind.boss and not blind.disabled then
            theme = get_reality_warp_blind_theme and get_reality_warp_blind_theme(blind)
        elseif not is_pack and blindname ~= '' and blindname ~= 'Small Blind' and blindname ~= 'Big Blind' then
            theme = get_reality_warp_blind_theme and get_reality_warp_blind_theme(blindname)
        end

        if theme and state ~= G.STATES.SHOP and state ~= G.STATES.ROUND_EVAL then
            ease_custom_blind_background(blind or blindname)
            return
        end

        orig_ease_bg_blind(state, blind_override)

        if state == G.STATES.ROUND_EVAL or state == G.STATES.BLIND_SELECT or state == G.STATES.SHOP or blind_override == '' then
            reset_reality_warp_boss_ui(state)
        end
    end
end

local function reset_sale_tag_effects()
    if G.GAME then
        G.GAME.sale_tag_active = nil
        G.GAME.dark_alchemy_tag_active = nil
        if G.GAME.round_resets and G.GAME.round_resets.temp_reroll_cost then
            G.GAME.round_resets.temp_reroll_cost = nil
            if calculate_reroll_cost then
                calculate_reroll_cost(true)
            end
        end
        if G.GAME.discount_percent and G.GAME.discount_percent > 0 then
            local legitimate_discount = 0
            if G.GAME.used_vouchers then
                if G.GAME.used_vouchers.v_liquidation then
                    legitimate_discount = 50
                elseif G.GAME.used_vouchers.v_clearance_sale then
                    legitimate_discount = 25
                end
            end
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j.config and j.config.center and (j.config.center.key == 'j_reality_warp_merchant_joker' or j.config.center.key == 'j_crack_businessman' or j.config.center.name == 'Merchant' or j.config.center.name == 'Businessman') then
                        legitimate_discount = legitimate_discount + 25
                    end
                end
            end
            if G.GAME.discount_percent > legitimate_discount then
                G.GAME.discount_percent = legitimate_discount
            end
        end
    end
end

if G.FUNCS and G.FUNCS.toggle_shop then
    local orig_toggle_shop = G.FUNCS.toggle_shop
    G.FUNCS.toggle_shop = function(e)
        reset_sale_tag_effects()
        local ret = orig_toggle_shop(e)
        reset_reality_warp_boss_ui(G.STATES.BLIND_SELECT)
        return ret
    end
end

if new_round then
    local orig_new_round_sale = new_round
    function new_round()
        reset_sale_tag_effects()
        return orig_new_round_sale()
    end
end

local set_blind_ref = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    reset_sale_tag_effects()
    local ret = set_blind_ref(self, blind, reset, silent)
    if G.GAME and G.GAME.stick_penalty then
        self.chips = math.floor(self.chips * G.GAME.stick_penalty)
        G.GAME.stick_penalty = nil
    end

    if blind and self.boss and not self.disabled then
        local theme = get_reality_warp_blind_theme and get_reality_warp_blind_theme(self)
        if theme and ease_custom_blind_background then
            ease_custom_blind_background(self)
        end
    elseif not blind or not self.boss or self.disabled then
        reset_reality_warp_boss_ui()
    end

    return ret
end

if Blind.disable then
    local blind_disable_ref = Blind.disable
    function Blind:disable()
        local ret = blind_disable_ref(self)
        reset_reality_warp_boss_ui()
        return ret
    end
end

if Blind.defeat then
    local blind_defeat_ref = Blind.defeat
    function Blind:defeat(silent)
        local ret = blind_defeat_ref(self, silent)
        reset_reality_warp_boss_ui()
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                reset_reality_warp_boss_ui()
                return true
            end
        }))

        if self.boss and G.GAME and G.GAME.current_round and (G.GAME.current_round.hands_played or 0) <= 1 then
            local b_key = (self.config and self.config.blind and self.config.blind.key) or (G.GAME.blind and G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key)
            local suffix = b_key and b_key:match('^bl_(.+)$')
            local fam_key = suffix and ('c_reality_warp_baby_' .. suffix)
            local center = fam_key and G.P_CENTERS[fam_key]
            if center and (center.unlocked == false or not center.discovered) then
                unlock_card(center)
                discover_card(center)
                if G.PROFILES and G.PROFILES[G.SETTINGS.profile] then
                    local p = G.PROFILES[G.SETTINGS.profile]
                    p.witch_discovered_familiars = p.witch_discovered_familiars or {}
                    p.witch_discovered_familiars[fam_key] = true
                end
                play_sound('gold_seal', 1.2, 0.8)
                attention_text({
                    text = "FAMILIAR RESCUED! " .. (center.loc_txt and center.loc_txt.name or "Familiar"),
                    scale = 0.55,
                    hold = 2.5,
                    backdrop_colour = G.C.GOLD,
                    align = 'cm',
                    offset = {x = 0, y = -1.5}
                })
                if G.save_progress then G:save_progress() end
            end
        end

        if G.GAME then
            G.GAME.reality_warp_blinds_defeated = (G.GAME.reality_warp_blinds_defeated or 0) + 1
            if G.GAME.chips and self.chips and G.GAME.chips >= (self.chips * 2) then
                G.GAME.reality_warp_cascade_double = true
                G.GAME.reality_warp_cascada_double = true
            end
            local disc_used = (G.GAME.current_round and G.GAME.current_round.discards_used) or 0
            if disc_used == 0 then
                G.GAME.reality_warp_no_discard_win = true
            end
            if self.boss then
                G.GAME.reality_warp_boss_defeated = true
                G.GAME.reality_warp_bosses_slain = (G.GAME.reality_warp_bosses_slain or 0) + 1
                G.GAME.reality_warp_bosses_slain_types = G.GAME.reality_warp_bosses_slain_types or {}
                local bkey = (self.config and self.config.blind and self.config.blind.key) or (self.name or 'Boss')
                G.GAME.reality_warp_bosses_slain_types[bkey] = true
                if disc_used == 0 then
                    G.GAME.reality_warp_boss_nodiscard = true
                end
            end
            if check_for_unlock then
                check_for_unlock({ type = 'defeat_blind', blind = self })
                if G.GAME.reality_warp_cascade_double then check_for_unlock({ type = 'cascade_double' }) end
                if G.GAME.reality_warp_no_discard_win then check_for_unlock({ type = 'no_discard_win' }) end
                if G.GAME.reality_warp_boss_nodiscard then check_for_unlock({ type = 'boss_nodiscard' }) end
                if G.GAME.reality_warp_bosses_slain and G.GAME.reality_warp_bosses_slain >= 5 then check_for_unlock({ type = 'mercenary' }) end
                if G.GAME.reality_warp_bosses_slain and G.GAME.reality_warp_bosses_slain >= 10 then check_for_unlock({ type = 'world_devourer' }) end
                if G.GAME.reality_warp_blinds_defeated and G.GAME.reality_warp_blinds_defeated >= 10 then check_for_unlock({ type = 'entomologist' }) end
            end
        end

        return ret
    end
end

local game_update_ref = Game.update
function Game:update(dt)
    game_update_ref(self, dt)
    if G.STATE == G.STATES.SHOP and G.GAME then
        if not G.GAME.entered_shop_dollars then
            G.GAME.entered_shop_dollars = G.GAME.dollars or 0
        end
    elseif G.STATE ~= G.STATES.SHOP and G.GAME and G.GAME.entered_shop_dollars then
        local entered = (to_number and to_number(G.GAME.entered_shop_dollars)) or tonumber(G.GAME.entered_shop_dollars) or 0
        local current = (to_number and to_number(G.GAME.dollars)) or tonumber(G.GAME.dollars) or 0
        if entered >= 50 and current <= 10 then
            check_for_unlock({ type = 'leave_shop' })
        end
        G.GAME.entered_shop_dollars = nil
    end
end

if G.FUNCS and G.FUNCS.evaluate_play then
    local orig_eval_play = G.FUNCS.evaluate_play
    G.FUNCS.evaluate_play = function(e)
        if G.GAME and G.play and G.play.cards then
            G.GAME.reality_warp_countdown_cards = (G.GAME.reality_warp_countdown_cards or 0) + #G.play.cards
            local hand_text = G.FUNCS.get_poker_hand_info and G.FUNCS.get_poker_hand_info(G.play.cards)
            if hand_text then
                G.GAME.reality_warp_diff_hands_map = G.GAME.reality_warp_diff_hands_map or {}
                G.GAME.reality_warp_diff_hands_map[hand_text] = true
                local d_cnt = 0
                for _ in pairs(G.GAME.reality_warp_diff_hands_map) do d_cnt = d_cnt + 1 end
                G.GAME.reality_warp_diff_hands = d_cnt
            end
            if check_for_unlock then
                if G.GAME.reality_warp_countdown_cards == 10 then
                    check_for_unlock({ type = 'countdown_cards' })
                end
                if G.GAME.reality_warp_diff_hands and G.GAME.reality_warp_diff_hands >= 3 then
                    check_for_unlock({ type = 'diff_hands' })
                end
                if G.jokers and G.jokers.cards and #G.jokers.cards == 0 then
                    check_for_unlock({ type = 'no_jokers_activated' })
                end
            end
        end
        return orig_eval_play(e)
    end
end

if reset_round then
    local orig_reset_round = reset_round
    function reset_round()
        orig_reset_round()
        if G.GAME then
            G.GAME.reality_warp_countdown_cards = 0
            G.GAME.reality_warp_diff_hands_map = {}
            G.GAME.reality_warp_diff_hands = 0
            G.GAME.reality_warp_cascade_double = nil
            G.GAME.reality_warp_cascada_double = nil
            G.GAME.reality_warp_no_discard_win = nil
        end
    end
end

if win_game then
    local orig_win_game = win_game
    function win_game(...)
        if G.GAME then
            G.GAME.reality_warp_run_won = true
            if check_for_unlock then
                check_for_unlock({ type = 'win_game' })
            end
        end
        return orig_win_game(...)
    end
end

if ease_dollars then
    local orig_ease_dollars = ease_dollars
    function ease_dollars(mod, instant)
        orig_ease_dollars(mod, instant)
        if G.GAME and G.GAME.dollars and check_for_unlock then
            if G.GAME.dollars >= 50 then
                check_for_unlock({ type = 'money' })
            end
            if G.GAME.dollars >= 100 then
                check_for_unlock({ type = 'money_100' })
            end
        end
    end
end

local use_card_ref = Card.use_consumeable
function Card:use_consumeable(area, copier)
    if G.GAME and G.GAME.blind and (G.GAME.blind.name == 'b_reality_warp_mountain' or G.GAME.blind.name == 'mountain' or G.GAME.blind.key == 'b_reality_warp_mountain' or G.GAME.blind.name == 'The Mountain') and not G.GAME.blind.disabled then
        G.GAME.mountain_disabled_hand = true
        if G.GAME.blind.wiggle then G.GAME.blind:wiggle() end
        if G.hand and G.hand.parse_highlighted then
            G.hand:parse_highlighted()
        end
    end

    local set = (self.ability and self.ability.set) or (self.config and self.config.center and self.config.center.set)
    local ckey = (self.config and self.config.center and self.config.center.key) or (self.config and self.config.center_key) or ''

    if set == 'Potion' and (ckey == 'c_reality_warp_potion_amalgam' or ckey == 'potion_amalgam' or ckey == 'c_reality_warp_potion_amalgama' or ckey == 'potion_amalgama' or string.find(ckey, 'amalgam', 1, true) or string.find(ckey, 'amalgama', 1, true)) then
        if botg_trigger_mod_achievement then
            botg_trigger_mod_achievement('witcher_amalgam')
            botg_trigger_mod_achievement('apprentice_alchemist')
        end
        play_sound('timpani', 0.6, 1.0)
        play_sound('foil1', 0.75, 0.7)
        play_sound('polychrome1', 1.25, 0.85)
        play_sound('tarot2', 0.85, 0.6)
    elseif set == 'Potion' then
        if botg_trigger_mod_achievement then
            botg_trigger_mod_achievement('apprentice_alchemist')
        end
        play_sound('cancel', 1.35, 0.9)
        play_sound('tarot2', 1.25, 0.7)
    elseif set == 'Job' or string.find(ckey, '_job', 1, true) then
        if botg_trigger_mod_achievement then
            botg_trigger_mod_achievement('first_contract')
        end
        play_sound('crumple1', 0.9, 0.9)
        play_sound('tarot1', 0.7, 0.85)
        play_sound('coin6', 1.45, 0.75)
    elseif set == 'Spectral' and (string.find(ckey, 'reality_warp') or (self.config and self.config.center and self.config.center.atlas == 'c_spectrals')) then
        if botg_trigger_mod_achievement then
            botg_trigger_mod_achievement('mutagenic_trial')
        end
        play_sound('timpani', 0.5, 0.95)
        play_sound('tarot2', 0.65, 0.8)
        play_sound('foil1', 0.75, 0.7)
    end

    local ret = use_card_ref(self, area, copier)

    if G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
        local blind = G.GAME.blind
        local theme = get_reality_warp_blind_theme and get_reality_warp_blind_theme(blind)
        if G.E_MANAGER then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    if G.GAME and G.GAME.blind and not G.GAME.blind.disabled and (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.PLAY_TAROT or G.STATE == G.STATES.DRAW_TO_HAND) then
                        if theme and ease_custom_blind_background then
                            ease_custom_blind_background(blind)
                        elseif ease_background_colour_blind then
                            ease_background_colour_blind(G.STATE or G.STATES.SELECTING_HAND)
                        end
                    end
                    return true
                end
            }))
        end
    end

    return ret
end

local card_update_alert_ref = Card.update_alert
function Card:update_alert()
    if not self or not self.ability then return end
    local center = self.config and self.config.center
    if (self.ability and self.ability.set == 'Sticker')
        or (center and (center.set == 'Sticker' or (SMODS and SMODS.Stickers and SMODS.Stickers[center.key])
            or (type(center.key) == 'string' and (string.find(center.key, '_job') or string.find(center.key, 'insect_') or string.find(center.key, 'possession_'))))) then
        if center then
            center.alerted = true
            center.no_alert = true
        end
        if self.children and self.children.alert then
            self.children.alert:remove()
            self.children.alert = nil
        end
        return
    end
    return card_update_alert_ref(self)
end

local card_set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    if not center then
        center = (G.P_CENTERS and G.P_CENTERS.c_base) or { name = 'Default', set = 'Default', config = {} }
    end
    card_set_ability_ref(self, center, initial, delay_sprites)
    if not self.ability then
        self.ability = { name = 'Default', set = 'Default', mult = 0, chips = 0, x_mult = 1 }
    end
    if center and type(center) == 'table' then
        if center.key then
            self.config.center_key = center.key
        end
        local ckey = tostring(center.key or '')
        if string.find(ckey, 'reality_warp') or string.find(ckey, 'Witch brew') then
            local clean_name = (center.loc_txt and center.loc_txt.name) or (center.name and not string.find(center.name, '^[jvc]_') and center.name)
            if clean_name then
                self.label = clean_name
                self.ability.name = clean_name
            end
        end
    end
    if not initial and center and center.set == 'Enhanced' then
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff and card_has_key(j, 'runway') and j.ability and j.ability.extra then
                    local gain = j.ability.extra.xmult_gain or 0.1
                    j.ability.extra.xmult = (j.ability.extra.xmult or 1.0) + gain
                    card_eval_status_text(j, 'extra', nil, nil, nil, {
                        message = 'X' .. string.format('%.1f', j.ability.extra.xmult) .. ' Mult!',
                        colour = G.C.XMULT
                    })
                    j:juice_up(0.4, 0.4)
                end
            end
        end
    end
end

local card_update_ref = Card.update
function Card:update(dt)
    if not self.ability then
        if self.config and self.config.center then
            pcall(function() self:set_ability(self.config.center, true) end)
        end
        self.ability = self.ability or { name = 'Default', set = 'Default', mult = 0, chips = 0, x_mult = 1 }
    end
    card_update_ref(self, dt)
    if self.config and self.config.center and self.config.center.update and type(self.config.center.update) == 'function' then
        self.config.center:update(self, dt)
    end
    if self.area and self.area == G.jokers and not self.debuff and G.STATE and (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.HAND_PLAYED) then
        local key = (self.config and self.config.center and (self.config.center.key or self.config.center_key)) or ""
        local hands_played = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 0
        local discards_used = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_used) or 0

        local should_tremble = false
        if key == 'j_reality_warp_bluxdir' and hands_played == 0 then
            should_tremble = true
        elseif (key == 'j_reality_warp_extended_hand' or key == 'j_reality_warp_mano_extendida') and discards_used == 0 then
            should_tremble = true
        elseif (key == 'j_dna' or key == 'j_trading_card' or key == 'j_sixth_sense' or key == 'j_seance' or key == 'j_superposition') and hands_played == 0 then
            should_tremble = true
        elseif key == 'j_luchador' or key == 'j_diet_cola' or key == 'j_invisible' then
            should_tremble = true
        elseif key == 'j_mr_bones' and G.GAME and G.GAME.blind and G.GAME.blind.boss then
            should_tremble = true
        elseif self.ability and (self.ability.first_hand or self.ability.single_use or self.ability.tremble_active) then
            should_tremble = true
        end

        if should_tremble and G.TIMERS and G.TIMERS.REAL then
            if not self.last_tremble_time or (G.TIMERS.REAL - self.last_tremble_time > 0.42) then
                self.last_tremble_time = G.TIMERS.REAL
                self:juice_up(0.06, 0.03)
            end
        end
    end
end

local add_tag_ref = add_tag
function add_tag(tag)
    local ret = add_tag_ref(tag)
    if G.GAME and not G.GAME.overseer_duplicating_tag and tag then
        local is_combo = G.GAME.overseer_sleeve_combo or (G.GAME.overseer_deck and is_sleeve_matching("overseer"))
        if is_combo then
            G.GAME.overseer_duplicating_tag = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_tag1 = Tag(tag.key)
                    add_tag_ref(new_tag1)
                    local new_tag2 = Tag(tag.key)
                    add_tag_ref(new_tag2)
                    G.GAME.overseer_duplicating_tag = nil
                    return true
                end
            }))
        elseif G.GAME.overseer_deck or G.GAME.overseer_sleeve_active or is_sleeve_matching("overseer") then
            G.GAME.overseer_duplicating_tag = true
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_tag = Tag(tag.key)
                    add_tag_ref(new_tag)
                    G.GAME.overseer_duplicating_tag = nil
                    return true
                end
            }))
        end
    end
    return ret
end

local set_cost_ref = Card.set_cost
function Card:set_cost()
    set_cost_ref(self)
    local no_markup = G.GAME and (G.GAME.overseer_no_markup or G.GAME.overseer_sleeve_combo)
    if G.GAME and G.GAME.overseer_deck and not no_markup and self.ability and self.ability.set == 'Joker' then
        self.cost = math.max(1, math.floor(self.cost * 1.5))
    end
    if G.GAME and G.GAME.sale_tag_active then
        local is_shop_item = self.area and (self.area == G.shop_jokers or self.area == G.shop_booster or self.area == G.shop_vouchers)
        if is_shop_item then
            self.cost = math.max(1, math.floor(self.cost * 0.5))
        end
    end
    if G.GAME and G.GAME.bluxdir_free_boosters and ((self.ability and self.ability.set == 'Booster') or (self.area and self.area == G.shop_booster)) then
        self.cost = 0
    end
    if G.GAME and G.GAME.modifiers and G.GAME.modifiers.voucher_cost_increase and self.ability and self.ability.set == 'Voucher' then
        self.cost = math.max(1, self.cost + G.GAME.modifiers.voucher_cost_increase)
    end
end

local cardarea_emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    if not card then return end
    cardarea_emplace_ref(self, card, location, stay_flipped)
    if G.GAME and G.GAME.bluxdir_free_boosters and (self == G.shop_booster) then
        if card then
            card.cost = 0
            if card.set_cost then card:set_cost() end
        end
    end
    if G.GAME and G.GAME.sale_tag_active and (self == G.shop_jokers or self == G.shop_booster or self == G.shop_vouchers) then
        if card and card.set_cost then
            card:set_cost()
        end
    end
end

local reset_idol_card_ref = reset_idol_card
function reset_idol_card()
    reset_sale_tag_effects()
    if reset_idol_card_ref then
        return reset_idol_card_ref()
    end
end

local card_get_chip_h_x_mult_ref = Card.get_chip_h_x_mult
function Card:get_chip_h_x_mult()
    local is_silver = (self.seal == 'silver' or self.seal == 'reality_warp_silver')
    local is_steel = (self.ability and self.ability.name == 'Steel Card') or (self.config and self.config.center == G.P_CENTERS.m_steel)
    if is_silver and is_steel then
        return 2.5
    end
    if card_get_chip_h_x_mult_ref then
        return card_get_chip_h_x_mult_ref(self)
    end
    return 1
end

function format_soulmate_card_name(c)
    if not c or not c.base then return "None" end
    local val = tostring(c.base.value or '?')
    local suit = tostring(c.base.suit or '')
    return val .. " of " .. suit
end

function get_or_pick_soulmates()
    if not G.playing_cards or #G.playing_cards < 2 then return nil, nil end
    local sm1, sm2 = nil, nil
    for _, c in ipairs(G.playing_cards) do
        if c.ability and c.ability.is_soulmate then
            if not sm1 then sm1 = c
            elseif not sm2 and c ~= sm1 then sm2 = c end
        end
    end
    if not sm1 or not sm2 then
        local unbonded = {}
        for _, c in ipairs(G.playing_cards) do
            if not (c.ability and c.ability.is_soulmate) then
                table.insert(unbonded, c)
            end
        end
        if not sm1 and #unbonded > 0 then
            sm1 = pseudorandom_element(unbonded, pseudoseed('soulmate_1'))
            if sm1 then
                sm1.ability = sm1.ability or {}
                sm1.ability.is_soulmate = true
                for i = #unbonded, 1, -1 do if unbonded[i] == sm1 then table.remove(unbonded, i) end end
            end
        end
        if not sm2 and #unbonded > 0 then
            sm2 = pseudorandom_element(unbonded, pseudoseed('soulmate_2'))
            if sm2 then
                sm2.ability = sm2.ability or {}
                sm2.ability.is_soulmate = true
            end
        end
    end
    return sm1, sm2
end

local function has_taster_voucher()
    if not G.GAME or not G.GAME.used_vouchers then return false end
    return G.GAME.used_vouchers.v_reality_warp_catador or G.GAME.used_vouchers.v_catador or G.GAME.used_vouchers.catador
end

local function has_critic_voucher()
    if not G.GAME or not G.GAME.used_vouchers then return false end
    return G.GAME.used_vouchers.v_reality_warp_critico or G.GAME.used_vouchers.v_critico or G.GAME.used_vouchers.critico
end

local function is_common_rarity(r)
    if not r then return false end
    if r == 1 or r == 'Common' or r == 'common' or tostring(r) == '1' then return true end
    if type(r) == 'number' and r > 0 and r <= 0.85 then return true end
    return false
end

local function upgrade_common_rarity(r, seed)
    local is_str = (type(r) == 'string' and not tonumber(r))
    local roll = pseudorandom(seed or 'voucher_upgrade_rarity')
    if is_str then
        return (roll < 0.75) and 'Uncommon' or 'Rare'
    else
        return (roll < 0.75) and 2 or 3
    end
end

local get_current_joker_rarity_ref = get_current_joker_rarity
function get_current_joker_rarity(area, rarity_share)
    local rarity = get_current_joker_rarity_ref(area, rarity_share)
    if G.GAME then
        if has_critic_voucher() and is_common_rarity(rarity) then
            rarity = upgrade_common_rarity(rarity, 'critico_voucher')
        elseif has_taster_voucher() and is_common_rarity(rarity) then
            if pseudorandom('catador_voucher') < 0.75 then
                rarity = upgrade_common_rarity(rarity, 'catador_voucher_rarity')
            end
        end

        if G.GAME.merchant_rare_boost and G.GAME.merchant_rare_boost > 0 then
            if rarity ~= 3 and rarity ~= 'Rare' and pseudorandom('merchant_rare') < 0.35 then
                rarity = (type(rarity) == 'string' and not tonumber(rarity)) and 'Rare' or 3
            end
        end
    end
    return rarity
end

if SMODS and SMODS.poll_rarity then
    local orig_poll_rarity = SMODS.poll_rarity
    function SMODS.poll_rarity(key, rarity_share)
        local rarity = orig_poll_rarity(key, rarity_share)
        if key == 'Joker' and G.GAME then
            if has_critic_voucher() and is_common_rarity(rarity) then
                rarity = upgrade_common_rarity(rarity, 'critico_smods_poll')
            elseif has_taster_voucher() and is_common_rarity(rarity) then
                if pseudorandom('catador_smods_poll') < 0.75 then
                    rarity = upgrade_common_rarity(rarity, 'catador_smods_poll_rarity')
                end
            end
        end
        return rarity
    end
end

function reality_warp_player_has_showman()
    if SMODS and SMODS.find_card then
        local smods_showman = SMODS.find_card('j_ring_master')
        if smods_showman and #smods_showman > 0 then return true end
        local smods_showman2 = SMODS.find_card('j_showman')
        if smods_showman2 and #smods_showman2 > 0 then return true end
    end
    if find_joker then
        local vanilla_showman = find_joker('Showman')
        if vanilla_showman and #vanilla_showman > 0 then return true end
        local rm = find_joker('Ring Master')
        if rm and #rm > 0 then return true end
    end
    if G and G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if not j.debuff and j.config and j.config.center then
                local k = j.config.center.key or j.config.center_key or ''
                local n = (j.ability and j.ability.name) or (j.config.center.name) or ''
                if k == 'j_ring_master' or k == 'j_showman' or n == 'Showman' or n == 'Ring Master' then
                    return true
                end
            end
        end
    end
    return false
end
local player_has_showman = reality_warp_player_has_showman

function reality_warp_is_joker_duplicate(j_card)
    if not (G and j_card and j_card.config and j_card.config.center) then
        return false
    end
    local j_key = j_card.config.center.key or j_card.config.center_key
    local j_name = (j_card.ability and j_card.ability.name) or j_card.config.center.name

    -- 1. Check owned jokers
    if G.jokers and G.jokers.cards then
        for _, owned in ipairs(G.jokers.cards) do
            if owned ~= j_card then
                if j_key and owned.config and owned.config.center and (owned.config.center.key == j_key or owned.config.center_key == j_key) then
                    return true
                end
                if j_name and ((owned.ability and owned.ability.name == j_name) or (owned.config and owned.config.center and owned.config.center.name == j_name)) then
                    return true
                end
            end
        end
    end

    -- 2. Check other shop slots (avoid duplicate offers in same shop)
    if G.shop_jokers and G.shop_jokers.cards then
        for _, shop_c in ipairs(G.shop_jokers.cards) do
            if shop_c ~= j_card then
                if j_key and shop_c.config and shop_c.config.center and (shop_c.config.center.key == j_key or shop_c.config.center_key == j_key) then
                    return true
                end
                if j_name and ((shop_c.ability and shop_c.ability.name == j_name) or (shop_c.config and shop_c.config.center and shop_c.config.center.name == j_name)) then
                    return true
                end
            end
        end
    end

    -- 3. Check other booster pack cards (avoid duplicate offers in same pack)
    if G.pack_cards and G.pack_cards.cards then
        for _, pack_c in ipairs(G.pack_cards.cards) do
            if pack_c ~= j_card then
                if j_key and pack_c.config and pack_c.config.center and (pack_c.config.center.key == j_key or pack_c.config.center_key == j_key) then
                    return true
                end
                if j_name and ((pack_c.ability and pack_c.ability.name == j_name) or (pack_c.config and pack_c.config.center and pack_c.config.center.name == j_name)) then
                    return true
                end
            end
        end
    end

    return false
end
local is_joker_owned_by_player = reality_warp_is_joker_duplicate

function reality_warp_is_joker_key_owned(key)
    if not key then return false end
    if player_has_showman and player_has_showman() then return false end
    if reality_warp_player_has_showman and reality_warp_player_has_showman() then return false end
    if G.jokers and G.jokers.cards then
        for _, c in ipairs(G.jokers.cards) do
            local k = (c.config and c.config.center and c.config.center.key) or c.config.center_key
            if k == key then return true end
        end
    end
    if G.shop_jokers and G.shop_jokers.cards then
        for _, c in ipairs(G.shop_jokers.cards) do
            local k = (c.config and c.config.center and c.config.center.key) or c.config.center_key
            if k == key then return true end
        end
    end
    return false
end

function reality_warp_sync_owned_jokers()
    if not (G and G.GAME and G.GAME.used_jokers) then return end
    if reality_warp_player_has_showman() then return end
    local areas = { G.jokers, G.shop_jokers, G.pack_cards }
    for _, ar in ipairs(areas) do
        if ar and ar.cards then
            for _, j in ipairs(ar.cards) do
                local k = (j.config and j.config.center and j.config.center.key) or (j.config and j.config.center_key)
                if k then
                    G.GAME.used_jokers[k] = true
                end
                if j.ability and j.ability.name and G.P_CENTERS then
                    for pk, v in pairs(G.P_CENTERS) do
                        if v.name == j.ability.name then
                            G.GAME.used_jokers[pk] = true
                        end
                    end
                end
            end
        end
    end
end
local sync_owned_jokers_to_used = reality_warp_sync_owned_jokers

local function clean_leaked_duplicate_flags()
    if not player_has_showman() then
        if SMODS then
            if SMODS.create_card_allow_duplicates then SMODS.create_card_allow_duplicates = nil end
            if SMODS.poll_object_allow_duplicates then SMODS.poll_object_allow_duplicates = nil end
        end
    end
end

local orig_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    clean_leaked_duplicate_flags()
    if _type == 'Joker' then
        sync_owned_jokers_to_used()
    end
    return orig_get_current_pool(_type, _rarity, _legendary, _append)
end

if SMODS and SMODS.showman then
    local orig_smods_showman = SMODS.showman
    function SMODS.showman(card_key)
        if not player_has_showman() then
            return false
        end
        return orig_smods_showman(card_key)
    end
end

local create_card_ref = create_card
function create_card(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    clean_leaked_duplicate_flags()
    if type == 'Joker' then
        sync_owned_jokers_to_used()
    end

    if not forced_key and type == 'Spectral' and (area == G.pack_cards or key_append == 'spe' or (G.pack_cards and area == G.pack_cards)) then
        local muchachada_center_key = (G.P_CENTERS and G.P_CENTERS['c_reality_warp_the_gang'] and 'c_reality_warp_the_gang') or (G.P_CENTERS and G.P_CENTERS['c_reality_warp_la_muchachada'] and 'c_reality_warp_la_muchachada') or 'c_the_gang'
        local allow_spawn = not (G.GAME and G.GAME.used_jokers and G.GAME.used_jokers[muchachada_center_key]) or player_has_showman()
        if allow_spawn then
            local ante = (G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante) or 1
            if pseudorandom('la_muchachada_spectral_' .. (key_append or 'spe') .. ante) > 0.9985 then
                forced_key = muchachada_center_key
            end
        end
    end

    if not forced_key and type == 'Joker' and (area == G.shop_jokers or (key_append and string.find(key_append, 'sho'))) then
        local has_drone = G.GAME and G.GAME.used_vouchers and (G.GAME.used_vouchers.v_reality_warp_vip_drone or G.GAME.used_vouchers.v_vip_drone or G.GAME.used_vouchers.vip_drone)
        local has_box = G.GAME and G.GAME.used_vouchers and (G.GAME.used_vouchers.v_reality_warp_delivery_box or G.GAME.used_vouchers.v_delivery_box or G.GAME.used_vouchers.delivery_box)
        if has_drone or has_box then
            local card_count = (G.shop_jokers and G.shop_jokers.cards and #G.shop_jokers.cards) or 0
            local roll = pseudorandom('fav_joker_shop_' .. (G.GAME.round or 0) .. '_' .. (key_append or 'sho') .. card_count)
            if roll < 0.40 then
                local fav_list = (get_most_used_jokers and get_most_used_jokers(has_drone and 3 or 1)) or {}
                local available = {}
                for _, fk in ipairs(fav_list) do
                    if not reality_warp_is_joker_key_owned(fk) then
                        table.insert(available, fk)
                    end
                end
                if #available > 0 then
                    forced_key = pseudorandom_element(available, pseudoseed('fav_joker_pick'))
                end
            end
        end
    end

    local card = create_card_ref(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if type == 'Joker' and card and card.ability and card.ability.set == 'Joker' then
        if not forced_key then
            local c_rarity = (card.config and card.config.center and card.config.center.rarity) or card.ability.rarity
            if is_common_rarity(c_rarity) then
                local should_replace = false
                if has_critic_voucher() then
                    should_replace = true
                elseif has_taster_voucher() and pseudorandom('catador_create_check') < 0.75 then
                    should_replace = true
                end
                if should_replace then
                    local replacement_rarity = (pseudorandom('voucher_create_rarity') < 0.75) and 2 or 3
                    local new_card = create_card_ref('Joker', area, legendary, replacement_rarity, skip_materialize, soulable, nil, (key_append or '') .. '_vup')
                    if new_card then
                        card:remove()
                        card = new_card
                    end
                end
            end
        end

        if not player_has_showman() and (area == G.shop_jokers or (key_append and string.find(key_append, 'sho')) or area == G.pack_cards) then
            local attempts = 0
            while is_joker_owned_by_player(card) and attempts < 10 do
                attempts = attempts + 1
                local cur_rarity = (card.config and card.config.center and card.config.center.rarity) or card.ability.rarity
                local rep_card = create_card_ref('Joker', area, legendary, cur_rarity, skip_materialize, soulable, nil, (key_append or '') .. '_nodup' .. attempts)
                if rep_card then
                    card:remove()
                    card = rep_card
                else
                    break
                end
            end
            if card and card.config and card.config.center and G.GAME and G.GAME.used_jokers then
                local ck = card.config.center.key or card.config.center_key
                if ck then
                    G.GAME.used_jokers[ck] = true
                end
            end
        end

        if G.GAME and G.GAME.dark_alchemy_tag_active and not card.edition then
            local is_shop_or_pack = (area == G.shop_jokers or area == G.pack_cards or (key_append and (string.find(key_append, 'sho') or string.find(key_append, 'pack'))))
            if is_shop_or_pack then
                local neg_poll = pseudorandom(pseudoseed('dark_alchemy_' .. (key_append or 'sho') .. (card.ID or 0)))
                if neg_poll > 0.97 then
                    card:set_edition({ negative = true }, true)
                end
            end
        end
    end

    return card
end

local calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context, ...)
    if context and context.blueprint and not is_joker_copiable(self) then
        return nil
    end

    if context and context.falta_de_lectura_check then
        if context.blueprint or (self.ability and (self.ability.name == 'Blueprint' or self.ability.name == 'Brainstorm')) then
            return nil
        end
        local orig_add_event = G.E_MANAGER and G.E_MANAGER.add_event
        if orig_add_event then G.E_MANAGER.add_event = function() end end
        local ret, post = calculate_joker_ref(self, context, ...)
        if orig_add_event then G.E_MANAGER.add_event = orig_add_event end
        return ret, post
    end

    if context and (context.ending_shop or context.setting_blind) then
        if G.GAME then G.GAME.dark_alchemy_tag_active = nil end
    end

    local is_doppel_active = G.GAME and G.GAME.blind and not G.GAME.blind.disabled and 
        (G.GAME.blind.name == 'doppelganger' or G.GAME.blind.name == 'The Doppelgänger' or G.GAME.blind.key == 'b_reality_warp_doppelganger' or G.GAME.blind.key == 'doppelganger' or (G.GAME.blind.config and G.GAME.blind.config.blind and (G.GAME.blind.config.blind.key == 'doppelganger' or G.GAME.blind.config.blind.key == 'b_reality_warp_doppelganger')))

    local ret, post = calculate_joker_ref(self, context, ...)

    if not self.debuff and (is_secret_card(self) or is_amalgam_card(self)) then
        if (ret and type(ret) == 'table' and next(ret)) or (context and context.first_hand_drawn) then
            local is_amal = is_amalgam_card(self)
            local colours = is_amal and { HEX('8a2be2'), HEX('4b0082'), HEX('ba55d3'), G.C.WHITE, HEX('9370db') }
                                    or { HEX('ffd700'), HEX('ff69b4'), HEX('00ffff'), HEX('ff00ff'), G.C.WHITE }
            emit_secret_screen_sparkles(colours)
        end
    end

    if ret and type(ret) == 'table' and next(ret) and not self.debuff and context and not context.falta_de_lectura_check then
        local key = (self.config and self.config.center and self.config.center.key) or self.config.center_key or (self.ability and self.ability.name)
        local is_self = (key == 'j_reality_warp_falta_de_lectura_joker' or key == 'falta_de_lectura_joker' or key == 'j_falta_de_lectura_joker' or key == 'falta_de_lectura' or card_has_key(self, 'reading_deficiency_joker'))
        if not is_self then
            if context.joker_main or context.individual or context.before or context.repetition then
                if ret.mult or ret.chips or ret.Xmult or ret.x_mult or ret.dollars or ret.x_chips or ret.p_dollars or ret.message or ret.swap then
                    G.GAME.falta_de_lectura_other_activated = true
                end
            end
        end
    end

    if is_doppel_active and G.GAME.doppelganger_target and self == G.GAME.doppelganger_target and ret and type(ret) == 'table' and not self.debuff and context then
        if not context.end_of_round and not context.ending_shop and not context.starting_shop and not context.setting_blind and not context.doppel_sim and not context.edition and not context.selling_card and not context.buying_card and not context.open_booster and not context.skip_blind then
            local is_activation = false
            if (ret.mult and ret.mult ~= 0) or (ret.mult_mod and ret.mult_mod ~= 0) or (ret.h_mult and ret.h_mult ~= 0) or
               (ret.chips and ret.chips ~= 0) or (ret.chip_mod and ret.chip_mod ~= 0) or (ret.h_chips and ret.h_chips ~= 0) or
               (ret.Xmult and ret.Xmult ~= 1) or (ret.x_mult and ret.x_mult ~= 1) or (ret.Xmult_mod and ret.Xmult_mod ~= 1) or (ret.h_x_mult and ret.h_x_mult ~= 1) or
               (ret.x_chips and ret.x_chips ~= 1) or (ret.repetitions and ret.repetitions > 0) or
               ret.dollars or ret.p_dollars or ret.swap or ret.message or ret.level_up then
                is_activation = true
            end

            if is_activation and not G.GAME.doppel_triggered_in_hand then
                G.GAME.doppel_triggered_in_hand = true
                if G.GAME and G.GAME.blind then
                    G.GAME.blind:juice_up(0.4, 0.4)
                end
                self:juice_up(0.4, 0.4)
                play_sound('chips2', 0.8, 0.7)
            end
        end
    end

    return ret, post
end

if card_eval_status_text then
    local card_eval_status_text_ref = card_eval_status_text
    function card_eval_status_text(card, eval_type, amt, percent, dir, extra)
        if (eval_type == 'mult' or eval_type == 'h_mult') and type(amt) == 'number' and amt < 0 then
            extra = extra or {}
            extra.message = tostring(amt) .. ' Mult'
            eval_type = 'extra'
        elseif (eval_type == 'chips' or eval_type == 'h_chips') and type(amt) == 'number' and amt < 0 then
            extra = extra or {}
            extra.message = tostring(amt) .. ' Chips'
            eval_type = 'extra'
        elseif (eval_type == 'x_mult' or eval_type == 'h_x_mult') and type(amt) == 'number' and amt < 0.9999 and amt > 0 then
            local div_val = 1 / amt
            extra = extra or {}
            extra.message = '/' .. string.format('%.2g', div_val) .. ' Mult'
            eval_type = 'extra'
        end
        return card_eval_status_text_ref(card, eval_type, amt, percent, dir, extra)
    end
end

if poll_edition then
    local poll_edition_ref = poll_edition
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        if G.GAME and G.GAME.dark_alchemy_tag_active then
            local neg_poll = pseudorandom(pseudoseed((_key or 'edition_generic') .. '_dark_alchemy'))
            local neg_rate = 0.03 * (_mod or 1)
            if neg_poll > 1 - neg_rate then
                return { negative = true }
            end
        end
        return poll_edition_ref(_key, _mod, _no_neg, _guaranteed)
    end
end

if calculate_reroll_cost then
    local orig_calculate_reroll_cost = calculate_reroll_cost
    function calculate_reroll_cost(skip_increment)
        if G.GAME and G.GAME.dark_alchemy_tag_active and not skip_increment then
            G.GAME.current_round.reroll_cost_increase = (G.GAME.current_round.reroll_cost_increase or 0) + 1
        end
        return orig_calculate_reroll_cost(skip_increment)
    end
end

function is_reality_warp_blind(blind, target_key)
    if not blind then return false end
    local k = (blind.config and blind.config.blind and (blind.config.blind.key or blind.config.blind.name))
              or (blind.config and blind.config.center and (blind.config.center.key or blind.config.center.name))
              or blind.key or blind.name or ''
    k = string.gsub(k, '^bl_reality_warp_', '')
    k = string.gsub(k, '^b_reality_warp_', '')
    k = string.gsub(k, '^bl_', '')
    k = string.gsub(k, '^b_', '')
    if target_key then
        return k == target_key or string.find(string.lower(k), string.lower(target_key)) ~= nil
    end
    return k
end

function reality_warp_check_pinza_card_destroyed()
    if G.GAME and G.GAME.blind and is_reality_warp_blind(G.GAME.blind, 'pinza') then
        if not G.GAME.pinza_card_destroyed then
            G.GAME.pinza_card_destroyed = true
            if G.GAME.blind.disable then
                G.GAME.blind:disable()
            else
                G.GAME.blind.disabled = true
            end
            if G.GAME.blind.wiggle then
                G.GAME.blind:wiggle()
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    if G.jokers and G.jokers.cards then
                        for _, j in ipairs(G.jokers.cards) do
                            j:set_debuff(false)
                            j.debuff = false
                        end
                    end
                    play_sound('tarot2')
                    return true
                end
            }))
        end
    end
end

local card_start_dissolve_ref = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_sound)
    if (self.playing_card or (self.ability and (self.ability.set == 'Enhanced' or self.ability.set == 'Default')) or self.base) then
        reality_warp_check_pinza_card_destroyed()
    end

    return card_start_dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_sound)
end

function ensure_custom_seals_discovered()
    local seal_groups = {
        { 'silver', 'reality_warp_silver', 'Witch brew_silver' },
        { 'dark_green', 'reality_warp_dark_green', 'Witch brew_dark_green' },
        { 'white', 'reality_warp_white', 'Witch brew_white' }
    }
    if G and G.P_SEALS then
        for _, grp in ipairs(seal_groups) do
            local found = nil
            for _, k in ipairs(grp) do
                if G.P_SEALS[k] then found = G.P_SEALS[k]; break end
            end
            if found then
                for _, k in ipairs(grp) do
                    G.P_SEALS[k] = G.P_SEALS[k] or found
                    G.P_SEALS[k].discovered = true
                    G.P_SEALS[k].unlocked = true
                end
            end
        end
    end
    if SMODS and SMODS.Seals then
        for _, grp in ipairs(seal_groups) do
            local found = nil
            for _, k in ipairs(grp) do
                if SMODS.Seals[k] then found = SMODS.Seals[k]; break end
            end
            if found then
                for _, k in ipairs(grp) do
                    SMODS.Seals[k] = SMODS.Seals[k] or found
                end
            end
        end
    end
    if G and G.P_CENTER_POOLS and G.P_CENTER_POOLS.Seal then
        for _, s in ipairs(G.P_CENTER_POOLS.Seal) do
            if s.key and (string.find(s.key, 'dark_green') or string.find(s.key, 'white') or string.find(s.key, 'silver')) then
                s.discovered = true
                s.unlocked = true
            end
        end
    end
end

ensure_custom_seals_discovered()

local card_set_seal_ref = Card.set_seal
function Card:set_seal(_seal, silent, immediate)
    if _seal then
        if _seal == 'silver' or _seal == 'reality_warp_silver' or _seal == 'Witch brew_silver' then
            _seal = (G.P_SEALS and (G.P_SEALS['reality_warp_silver'] and 'reality_warp_silver' or G.P_SEALS['Witch brew_silver'] and 'Witch brew_silver' or G.P_SEALS['silver'] and 'silver')) or 'reality_warp_silver'
        elseif _seal == 'dark_green' or _seal == 'reality_warp_dark_green' or _seal == 'Witch brew_dark_green' then
            _seal = (G.P_SEALS and (G.P_SEALS['reality_warp_dark_green'] and 'reality_warp_dark_green' or G.P_SEALS['Witch brew_dark_green'] and 'Witch brew_dark_green' or G.P_SEALS['dark_green'] and 'dark_green')) or 'reality_warp_dark_green'
        elseif _seal == 'white' or _seal == 'reality_warp_white' or _seal == 'Witch brew_white' then
            _seal = (G.P_SEALS and (G.P_SEALS['reality_warp_white'] and 'reality_warp_white' or G.P_SEALS['Witch brew_white'] and 'Witch brew_white' or G.P_SEALS['white'] and 'white')) or 'reality_warp_white'
        end
    end
    return card_set_seal_ref(self, _seal, silent, immediate)
end

if SMODS and SMODS.Center and SMODS.Center.register then
    local orig_center_register = SMODS.Center.register
    function SMODS.Center:register()
        if not self.name and self.loc_txt and self.loc_txt.name then
            self.name = self.loc_txt.name
            self.label = self.loc_txt.name
        end
        orig_center_register(self)
        if self.loc_txt and self.loc_txt.name then
            self.name = self.loc_txt.name
            self.label = self.loc_txt.name
            self.mod_name = "Witch Brew"
        end
    end
end

local _joker_key_renames = {
    ['motorizado_joker'] = 'motorized_joker',
    ['contratado_joker'] = 'hired_joker',
    ['sello_aprobacion_joker'] = 'seal_of_approval_joker',
    ['charco_pintura_joker'] = 'paint_puddle_joker',
    ['lesionado_joker'] = 'injured_joker',
    ['mano_extendida'] = 'extended_hand',
    ['hoguera'] = 'bonfire',
    ['grieta_temporal'] = 'temporal_rift',
    ['inversion_polaridad'] = 'polarity_inversion',
    ['herencia'] = 'inheritance',
    ['ecosistema'] = 'ecosystem',
    ['subastador'] = 'auctioneer',
    ['parasitario'] = 'parasitic',
    ['mercenario'] = 'mercenary',
    ['cascada'] = 'cascade',
    ['parca_joker'] = 'reaper_joker',
    ['parca'] = 'reaper_joker',
    ['sobresaturado_joker'] = 'oversaturated_joker',
    ['radiacion'] = 'radiation',
    ['director_orquesta'] = 'orchestra_director',
    ['meteorologo'] = 'meteorologist',
    ['relojero_loco'] = 'mad_clockmaker',
    ['catalizador'] = 'catalyst',
    ['grafitero'] = 'graffiti_artist',
    ['hipnotista'] = 'hypnotist',
    ['alquimista_manos'] = 'potion_brewer',
    ['hand_alchemist'] = 'potion_brewer',
    ['entomologo'] = 'entomologist',
    ['devorador_mundos'] = 'world_devourer',
    ['devorador_de_mundos'] = 'world_devourer',
    ['paradoja_viviente'] = 'living_paradox',
    ['paradoja_viva'] = 'living_paradox',
    ['cronista_estrellas'] = 'star_chronicler',
    ['cronista'] = 'star_chronicler',
    ['midas_vampirico'] = 'vampiric_midas',
    ['programacion_certificacion'] = 'certified_programming',
    ['viajero_galactico'] = 'galactic_traveler',
    ['calle_colorida'] = 'colorful_street',
    ['rey_de_mimos'] = 'mime_king',
    ['album_de_fotos'] = 'photo_album',
    ['huevo_pirata'] = 'pirate_egg',
    ['botas_reforzadas'] = 'reinforced_boots',
    ['gato_dorado_suerte'] = 'golden_lucky_cat',
    ['antiguedad_irreconocible'] = 'unrecognizable_antique',
    ['emoji_macabro'] = 'macabre_emoji',
    ['falta_de_lectura_joker'] = 'reading_deficiency_joker',
    ['designer_joker'] = 'disenador_joker',
    ['duelo_de_valores_joker'] = 'duel_of_value_joker',
}

local _reality_warp_key_renames = {
    ['c_reality_warp_potion_estiramiento'] = 'c_reality_warp_potion_stretch',
    ['c_reality_warp_potion_rayo'] = 'c_reality_warp_potion_lightning',
    ['c_reality_warp_potion_ventisca'] = 'c_reality_warp_potion_blizzard',
    ['c_reality_warp_potion_furia'] = 'c_reality_warp_potion_fury',
    ['c_reality_warp_potion_amalgama'] = 'c_reality_warp_potion_amalgam',
    ['c_reality_warp_potion_mercurio'] = 'c_reality_warp_potion_mercury',
    ['c_reality_warp_potion_espejo'] = 'c_reality_warp_potion_mirror',
    ['c_reality_warp_potion_reloj'] = 'c_reality_warp_potion_clock',
    ['c_reality_warp_potion_golondrina'] = 'c_reality_warp_potion_swallow',
    ['c_reality_warp_potion_lechuza'] = 'c_reality_warp_potion_tawny_owl',
    ['c_reality_warp_potion_filtro_petri'] = 'c_reality_warp_potion_petri',
    ['c_reality_warp_potion_oropendola'] = 'c_reality_warp_potion_golden_oriole',
    ['c_reality_warp_potion_sangre_negra'] = 'c_reality_warp_potion_black_blood',
    ['c_reality_warp_refuerzo'] = 'c_reality_warp_reinforcement',
    ['c_reality_warp_nigromancia'] = 'c_reality_warp_necromancy',
    ['c_reality_warp_erradicacion'] = 'c_reality_warp_eradication',
    ['c_reality_warp_transmutacion'] = 'c_reality_warp_transmutation',
    ['c_reality_warp_la_muchachada'] = 'c_reality_warp_the_gang',
    ['c_reality_warp_minero_job'] = 'c_reality_warp_miner_job',
}
for old_k, new_k in pairs(_joker_key_renames) do
    _reality_warp_key_renames['j_reality_warp_' .. old_k] = 'j_reality_warp_' .. new_k
    _reality_warp_key_renames['j_' .. old_k] = 'j_reality_warp_' .. new_k
end

function alias_all_reality_warp_centers()
    if G and G.P_CENTERS then
        local mt = getmetatable(G.P_CENTERS)
        if not mt then
            mt = {}
            setmetatable(G.P_CENTERS, mt)
        end
        if not mt._reality_warp_fallback then
            local orig_index = mt.__index
            mt.__index = function(t, k)
                if orig_index then
                    local res = type(orig_index) == 'function' and orig_index(t, k) or orig_index[k]
                    if res ~= nil then return res end
                end
                if type(k) == 'string' then
                    if string.find(k, 'Witch brew') then
                        local clean_k = string.gsub(k, 'Witch brew', 'reality_warp')
                        return rawget(t, clean_k)
                    end
                    if _reality_warp_key_renames[k] then
                        return rawget(t, _reality_warp_key_renames[k])
                    end
                end
                return nil
            end
            mt._reality_warp_fallback = true
        end

        for k, v in pairs(G.P_CENTERS) do
            if type(k) == 'string' then
                if string.find(k, 'Witch brew_') then
                    G.P_CENTERS[k] = nil
                elseif type(v) == 'table' and string.find(k, 'reality_warp_') then
                    local clean_name = (v.loc_txt and v.loc_txt.name)
                    if not clean_name and G.localization and G.localization.descriptions then
                        local set_desc = G.localization.descriptions[v.set or 'Joker']
                        if set_desc and set_desc[k] and set_desc[k].name then
                            clean_name = set_desc[k].name
                        elseif set_desc and v.key and set_desc[v.key] and set_desc[v.key].name then
                            clean_name = set_desc[v.key].name
                        end
                    end
                    if clean_name then
                        v.name = clean_name
                        v.label = clean_name
                        v.mod_name = "Witch Brew"
                    end
                end
            end
        end
    end

    if SMODS and SMODS.Centers then
        for k, v in pairs(SMODS.Centers) do
            if type(k) == 'string' then
                if string.find(k, 'Witch brew_') then
                    SMODS.Centers[k] = nil
                elseif type(v) == 'table' and string.find(k, 'reality_warp_') then
                    local clean_name = (v.loc_txt and v.loc_txt.name) or (v.name and not string.find(v.name, '^[jvc]_') and v.name)
                    if clean_name then
                        v.name = clean_name
                        v.label = clean_name
                        v.mod_name = "Witch Brew"
                    end
                end
            end
        end
    end

    if SMODS and SMODS.Jokers then
        for k, v in pairs(SMODS.Jokers) do
            if type(k) == 'string' then
                if string.find(k, 'Witch brew_') then
                    SMODS.Jokers[k] = nil
                elseif type(v) == 'table' and string.find(k, 'reality_warp_') then
                    local clean_name = (v.loc_txt and v.loc_txt.name) or (v.name and not string.find(v.name, '^[jvc]_') and v.name)
                    if clean_name then
                        v.name = clean_name
                        v.label = clean_name
                        v.mod_name = "Witch Brew"
                    end
                end
            end
        end
    end

    if G and G.P_CENTER_POOLS then
        for _, pool in pairs(G.P_CENTER_POOLS) do
            if type(pool) == 'table' then
                local seen = {}
                for i = #pool, 1, -1 do
                    local c = pool[i]
                    local k = c and (c.key or c.name)
                    if k then
                        local norm_k = string.gsub(k, 'Witch brew', 'reality_warp')
                        if string.find(k, 'Witch brew_') or seen[norm_k] then
                            table.remove(pool, i)
                        else
                            seen[norm_k] = true
                        end
                    end
                end
            end
        end
    end

    if G and G.P_CENTERS then
        for old_k, _ in pairs(_joker_key_renames) do
            G.P_CENTERS['j_reality_warp_' .. old_k] = nil
            G.P_CENTERS['j_' .. old_k] = nil
        end
        G.P_CENTERS['c_reality_warp_refuerzo'] = nil
        G.P_CENTERS['c_reality_warp_nigromancia'] = nil
        G.P_CENTERS['c_reality_warp_erradicacion'] = nil
        G.P_CENTERS['c_reality_warp_transmutacion'] = nil
        G.P_CENTERS['c_reality_warp_la_muchachada'] = nil
        G.P_CENTERS['c_reality_warp_minero_job'] = nil

        if suppress_all_sticker_alerts then suppress_all_sticker_alerts() end

        if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].all_unlocked then
            for k, v in pairs(G.P_CENTERS) do
                if type(k) == 'string' and (string.find(k, 'reality_warp') or string.find(k, '_job') or string.find(k, 'insect_') or string.find(k, 'possession_') or (v and v.set == 'Sticker')) then
                    v.unlocked = true
                    v.discovered = true
                    v.alerted = true
                    v.no_alert = true
                end
            end
            if suppress_all_sticker_alerts then suppress_all_sticker_alerts() end
        end
    end
end

function suppress_all_sticker_alerts()
    if G and G.P_CENTERS then
        for k, v in pairs(G.P_CENTERS) do
            if v and (v.set == 'Sticker' or (SMODS and SMODS.Stickers and SMODS.Stickers[k])
                or (type(k) == 'string' and (string.find(k, '_job') or string.find(k, 'insect_') or string.find(k, 'possession_')))) then
                v.alerted = true
                v.discovered = true
                v.unlocked = true
                v.no_alert = true
            end
        end
    end
    if SMODS and SMODS.Stickers then
        for k, v in pairs(SMODS.Stickers) do
            v.alerted = true
            v.discovered = true
            v.unlocked = true
            v.no_alert = true
        end
    end
end

if G and G.FUNCS and G.FUNCS.unlock_all then
    local orig_unlock_all = G.FUNCS.unlock_all
    G.FUNCS.unlock_all = function(e)
        orig_unlock_all(e)
        suppress_all_sticker_alerts()
    end
end

if localize then
    local orig_localize = localize
    function localize(args, misc_cat)
        if args and type(args) == 'table' and args.type == 'name_text' and args.key then
            local key = tostring(args.key)
            if string.find(key, 'reality_warp') or string.find(key, 'Witch brew') or string.find(key, 'reality_warp') then
                local c = G.P_CENTERS and (G.P_CENTERS[key] or G.P_CENTERS['j_' .. key] or G.P_CENTERS[string.gsub(key, 'Witch brew', 'reality_warp')])
                if c and c.loc_txt and c.loc_txt.name then
                    return c.loc_txt.name
                end
                if c and c.name and not string.find(c.name, '^[jvc]_') and not string.find(c.name, 'reality_warp') and not string.find(c.name, 'Witch brew') then
                    return c.name
                end
                if G.localization and G.localization.descriptions then
                    local set = args.set or (c and c.set) or 'Joker'
                    local set_desc = G.localization.descriptions[set]
                    if set_desc then
                        local entry = set_desc[key] or set_desc['j_' .. key] or set_desc[string.gsub(key, 'Witch brew', 'reality_warp')]
                        if entry and entry.name then
                            return entry.name
                        end
                    end
                end
            end
        end
        return orig_localize(args, misc_cat)
    end
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
    alias_all_reality_warp_centers()
    if cardTable then
        if cardTable.save_fields then
            for k, v in pairs(cardTable.save_fields) do
                if type(v) == 'string' and string.find(v, 'Witch brew') then
                    cardTable.save_fields[k] = string.gsub(v, 'Witch brew', 'reality_warp')
                end
            end
        end
        if type(cardTable.label) == 'string' and string.find(cardTable.label, 'Witch brew') then
            cardTable.label = string.gsub(cardTable.label, 'Witch brew', 'reality_warp')
        end
    end
    return card_load_ref(self, cardTable, other_card)
end

local card_is_suit_ref = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    if not flush_calc and self.debuff and not bypass_debuff then return false end
    if G and G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if not j.debuff or bypass_debuff then
                if card_has_key(j, 'masterful_joker') then
                    if j.ability and j.ability.extra and j.ability.extra.mastered_ranks then
                        local rank = self.base and self.base.value
                        if rank and j.ability.extra.mastered_ranks[rank] then
                            return true
                        end
                    end
                end
                if card_has_key(j, 'unrecognizable_antique') or card_has_key(j, 'antiguedad_irreconocible') or
                   card_has_key(j, 'colorful_street') or card_has_key(j, 'calle_colorida') then
                    local s = self.base and self.base.suit
                    if (s == 'Hearts' or s == 'Diamonds') and (suit == 'Hearts' or suit == 'Diamonds') then
                        return true
                    end
                    if (s == 'Spades' or s == 'Clubs') and (suit == 'Spades' or suit == 'Clubs') then
                        return true
                    end
                end
            end
        end
    end
    return card_is_suit_ref(self, suit, bypass_debuff, flush_calc)
end

if get_flush then
    local orig_get_flush = get_flush
    function get_flush(hand)
        local ret = orig_get_flush(hand)
        if ret and #ret > 0 then return ret end
        local has_cs = false
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff and (card_has_key(j, 'colorful_street') or card_has_key(j, 'calle_colorida')) then
                    has_cs = true; break
                end
            end
        end
        if has_cs and hand and #hand >= 4 and #hand <= 5 then
            local suits = { "Spades", "Hearts", "Clubs", "Diamonds" }
            for _, s in ipairs(suits) do
                local t = {}
                for i = 1, #hand do
                    if hand[i]:is_suit(s, nil, true) then
                        table.insert(t, hand[i])
                    end
                end
                if #t >= 4 then
                    return { t }
                end
            end
        end
        return ret or {}
    end
end

if get_straight then
    local orig_get_straight = get_straight
    function get_straight(hand)
        local ret = orig_get_straight(hand)
        if ret and #ret > 0 then return ret end
        local has_cs = false
        local has_shortcut = false
        local has_four_fingers = false
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if not j.debuff then
                    if card_has_key(j, 'colorful_street') or card_has_key(j, 'calle_colorida') then
                        has_cs = true
                        has_shortcut = true
                        has_four_fingers = true
                    end
                    if card_has_key(j, 'shortcut') or card_has_key(j, 'atajo') or (j.ability and (j.ability.name == 'Shortcut' or j.ability.name == 'j_shortcut')) then
                        has_shortcut = true
                    end
                    if card_has_key(j, 'four_fingers') or card_has_key(j, 'cuatro_dedos') or (j.ability and (j.ability.name == 'Four Fingers' or j.ability.name == 'j_four_fingers')) then
                        has_four_fingers = true
                    end
                end
            end
        end
        if (has_cs or has_shortcut or has_four_fingers) and hand and #hand >= (has_four_fingers and 4 or 5) then
            local IDS = {}
            for i = 1, #hand do
                local id = hand[i]:get_id()
                if id and id > 1 and id < 15 then
                    if IDS[id] then
                        table.insert(IDS[id], hand[i])
                    else
                        IDS[id] = { hand[i] }
                    end
                end
            end
            local req_length = has_four_fingers and 4 or 5
            local straight_length = 0
            local skipped_rank = false
            local t = {}
            for j = 1, 14 do
                local rank_idx = (j == 1 and 14 or j)
                if IDS[rank_idx] then
                    straight_length = straight_length + 1
                    skipped_rank = false
                    for _, v in ipairs(IDS[rank_idx]) do
                        table.insert(t, v)
                    end
                elseif has_shortcut and not skipped_rank and j ~= 14 and straight_length > 0 then
                    skipped_rank = true
                else
                    straight_length = 0
                    skipped_rank = false
                    t = {}
                end
                if straight_length >= req_length then
                    return { t }
                end
            end
        end
        return ret or {}
    end
end

local function is_probability_seed(seed)
    if type(seed) ~= 'string' then return false end
    local s = string.lower(seed)
    local prob_seeds = {
        wheel_of_fortune = true, lucky_mult = true, lucky_money = true,
        space_joker = true, bloodstone = true, business = true,
        hallucination = true, gros_michel = true, cavendish = true,
        glass = true, ['8_ball'] = true, eight_ball = true,
        contratado = true, injured_joker = true, squele_project = true,
        perfectionism_neg = true, discord_tag = true, blacksmith_reward = true,
    }
    if prob_seeds[s] then return true end
    if string.find(s, 'prob') or string.find(s, 'chance') or string.find(s, 'luck')
       or string.find(s, 'wheel') or string.find(s, 'odds') or string.find(s, 'roll') then
        return true
    end
    return false
end

local pseudorandom_ref = pseudorandom
function pseudorandom(seed, min, max)
    if not min and not max then
        if G.GAME and G.GAME.lucky_one_guaranteed then
            G.GAME.lucky_one_guaranteed = false
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if not j.debuff and (card_has_key(j, 'lucky_one') or card_has_key(j, 'lucky_one_joker')) then
                        card_eval_status_text(j, 'extra', nil, nil, nil, { message = 'Guaranteed!', colour = G.C.GREEN })
                        j:juice_up(0.5, 0.5)
                    end
                end
            end
            return 0
        end
        if is_probability_seed(seed) and G and G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if (card_has_key(j, 'lucky_one_joker') or card_has_key(j, 'lucky_one')) and not j.debuff then
                    if j.ability and j.ability.extra and (j.ability.extra.charges or 0) > 0 then
                        j.ability.extra.charges = j.ability.extra.charges - 1
                        j.ability.extra.xmult = (j.ability.extra.xmult or 1.5) + (j.ability.extra.xmult_gain or 0.1)
                        card_eval_status_text(j, 'extra', nil, nil, nil, {
                            message = 'Guaranteed! (' .. j.ability.extra.charges .. '/5)',
                            colour = G.C.GREEN
                        })
                        play_sound('tarot1')
                        return 0.0000000001
                    end
                end
            end
        end
    end
    return pseudorandom_ref(seed, min, max)
end

function Card:spectral_shatter()
    local dissolve_time = 0.8
    self.shattered = true
    self.destroyed = true
    self.dissolve = 0
    self.dissolve_colours = {
        HEX('1b4d2e'),              -- Dark green
        HEX('2dd4bf'),              -- Spectral teal
        G.C.SECONDARY_SET.Spectral, -- Spectral blue
        {1, 1, 1, 0.95}             -- Ethereal white glimmer
    }
    self:juice_up(0.8, 0.5)

    reality_warp_check_pinza_card_destroyed()

    local childParts = Particles(0, 0, 0, 0, {
        timer_type = 'TOTAL',
        timer = 0.005 * dissolve_time,
        scale = 0.35,
        speed = 3.5,
        lifespan = 0.6 * dissolve_time,
        attach = self,
        colours = self.dissolve_colours,
        fill = true
    })

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay = 0.5 * dissolve_time,
        func = function()
            childParts:fade(0.2 * dissolve_time)
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            play_sound('magic_crumple' .. math.random(2, 3), 1.15 + math.random() * 0.1, 0.85)
            play_sound('whoosh2', 0.85, 0.7)
            play_sound('tarot2', 1.25, 0.6)
            play_sound('glass' .. math.random(1, 6), 1.4 + math.random() * 0.2, 0.45)
            play_sound('slice1', 1.1, 0.5)
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'ease',
        blockable = false,
        ref_table = self,
        ref_value = 'dissolve',
        ease_to = 1,
        delay = 0.6 * dissolve_time,
        func = function(t) return t end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        blockable = false,
        delay = 0.65 * dissolve_time,
        func = function()
            self:remove()
            if G.play and G.play.cards then
                for i = #G.play.cards, 1, -1 do
                    if G.play.cards[i] == self then
                        table.remove(G.play.cards, i)
                    end
                end
            end
            if G.hand and G.hand.cards then
                for i = #G.hand.cards, 1, -1 do
                    if G.hand.cards[i] == self then
                        table.remove(G.hand.cards, i)
                    end
                end
                G.hand:set_ranks()
                G.hand:align_cards()
            end
            if G.deck and G.deck.cards then
                for i = #G.deck.cards, 1, -1 do
                    if G.deck.cards[i] == self then
                        table.remove(G.deck.cards, i)
                    end
                end
            end
            if G.discard and G.discard.cards then
                for i = #G.discard.cards, 1, -1 do
                    if G.discard.cards[i] == self then
                        table.remove(G.discard.cards, i)
                    end
                end
            end
            if G.playing_cards then
                for i = #G.playing_cards, 1, -1 do
                    if G.playing_cards[i] == self then
                        table.remove(G.playing_cards, i)
                    end
                end
                for k, v in ipairs(G.playing_cards) do
                    v.playing_card = k
                end
            end
            return true
        end
    }))
end

function purge_reality_warp_ghost_cards()
    if G.hand and G.hand.cards then
        local removed_any = false
        for i = #G.hand.cards, 1, -1 do
            local c = G.hand.cards[i]
            if c.shattered or c.destroyed or c.removed or (c.dissolve and c.dissolve >= 1) then
                table.remove(G.hand.cards, i)
                removed_any = true
            end
        end
        if removed_any then
            G.hand:set_ranks()
            G.hand:align_cards()
        end
    end
    if G.deck and G.deck.cards then
        for i = #G.deck.cards, 1, -1 do
            local c = G.deck.cards[i]
            if c.destroyed or c.removed or (c.dissolve and c.dissolve >= 1) then
                table.remove(G.deck.cards, i)
            end
        end
    end
end

if Card.shatter then
    local card_shatter_ref = Card.shatter
    function Card:shatter()
        if (self.seal and (self.seal == 'dark_green' or self.seal == 'reality_warp_dark_green')) or self.dark_green_broken then
            return self:spectral_shatter()
        end
        reality_warp_check_pinza_card_destroyed()
        return card_shatter_ref(self)
    end
end

function is_reality_warp_blind(blind, target_key)
    if not blind then return false end
    local k = (blind.config and blind.config.blind and (blind.config.blind.key or blind.config.blind.name))
              or (blind.config and blind.config.center and (blind.config.center.key or blind.config.center.name))
              or blind.key or blind.name or ''
    k = string.gsub(k, '^bl_reality_warp_', '')
    k = string.gsub(k, '^b_reality_warp_', '')
    k = string.gsub(k, '^bl_', '')
    k = string.gsub(k, '^b_', '')
    if target_key then
        return k == target_key or string.find(string.lower(k), string.lower(target_key)) ~= nil
    end
    return k
end

function clear_reality_warp_phone_debuffs()
    local areas = { G.hand, G.play, G.deck, G.discard }
    for _, area in ipairs(areas) do
        if area and area.cards then
            for _, c in ipairs(area.cards) do
                if c.debuffed_by_phone then
                    c:set_debuff(false)
                    c.debuffed_by_phone = nil
                end
            end
        end
    end
    if G.playing_cards then
        for _, c in ipairs(G.playing_cards) do
            if c.debuffed_by_phone then
                c:set_debuff(false)
                c.debuffed_by_phone = nil
            end
        end
    end
end

if Blind and Blind.debuff_hand then
    local debuff_hand_ref = Blind.debuff_hand
    function Blind:debuff_hand(cards, hand, handname, check)
        if self.disabled then
            return debuff_hand_ref(self, cards, hand, handname, check)
        end

        local debuffed = false

        if is_reality_warp_blind(self, 'mountain') then
            if G.GAME and G.GAME.mountain_disabled_hand then
                if not check then
                    G.GAME.mountain_disabled_hand = nil
                end
                debuffed = true
            end
        elseif is_reality_warp_blind(self, 'door') then
            if cards and #cards > 0 and (#cards % 2 ~= 0) then
                debuffed = true
            end
        elseif is_reality_warp_blind(self, 'triangle') then
            if cards and #cards > 0 and (#cards % 2 == 0) then
                debuffed = true
            end
        elseif is_reality_warp_blind(self, 'guitar') then
            if cards and #cards == 5 then
                debuffed = true
            end
        end

        if not debuffed and self.config and self.config.blind and type(self.config.blind.debuff_hand) == 'function' then
            if self.config.blind.debuff_hand(self, cards, hand, handname, check) then
                debuffed = true
            end
        end

        if debuffed then
            self.triggered = true
            if not check then
                G.GAME.reality_warp_hand_debuffed = true
            end
            return true
        end

        return debuff_hand_ref(self, cards, hand, handname, check)
    end
end

if Blind and Blind.get_loc_debuff_text then
    local get_loc_debuff_text_ref = Blind.get_loc_debuff_text
    function Blind:get_loc_debuff_text()
        if is_reality_warp_blind(self, 'door') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Hands with odd number of cards do not score"
        end
        if is_reality_warp_blind(self, 'triangle') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Hands with even number of cards do not score"
        end
        if is_reality_warp_blind(self, 'guitar') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Hands containing 5 cards do not score"
        end
        if is_reality_warp_blind(self, 'mountain') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "Using consumables disables scoring on the next hand"
        end
        if is_reality_warp_blind(self, 'wizard') then
            return (self.loc_debuff_text and self.loc_debuff_text ~= '') and self.loc_debuff_text or "All Enhanced cards are debuffed"
        end
        return get_loc_debuff_text_ref(self)
    end
end

if Blind and Blind.debuff_card then
    local debuff_card_ref = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        if not self.disabled and is_reality_warp_blind(self, 'wizard') then
            if card and card.area ~= G.jokers then
                local is_enhanced = (card.ability and card.ability.set == 'Enhanced') or
                                   (card.config and card.config.center and card.config.center.set == 'Enhanced') or
                                   (card.config and card.config.center_key and G.P_CENTERS and G.P_CENTERS[card.config.center_key] and G.P_CENTERS[card.config.center_key].set == 'Enhanced')
                if is_enhanced then
                    card:set_debuff(true)
                    return true
                end
            end
        end
        if not self.disabled and is_reality_warp_blind(self, 'pinza') and not (G.GAME and G.GAME.pinza_card_destroyed) then
            if card and card.area == G.jokers then
                if card.has_attribute and (card:has_attribute("destroy_card") or card:has_attribute("boss_blind")) then
                    card:set_debuff(false)
                    return false
                end
                card:set_debuff(true)
                return true
            end
        end
        return debuff_card_ref(self, card, from_blind)
    end
end

if CardArea and CardArea.parse_highlighted then
    local parse_highlighted_ref = CardArea.parse_highlighted
    function CardArea:parse_highlighted()
        if self == G.hand and G.GAME and G.GAME.blind and is_reality_warp_blind(G.GAME.blind, 'phone') and not G.GAME.blind.disabled then
            if self.cards then
                for _, c in ipairs(self.cards) do
                    if c.debuffed_by_phone then
                        c:set_debuff(false)
                        c.debuffed_by_phone = nil
                    end
                end
            end

            if self.highlighted and #self.highlighted > 0 and G.FUNCS and G.FUNCS.get_poker_hand_info then
                local text, disp_text, poker_hands, scoring_hand = G.FUNCS.get_poker_hand_info(self.highlighted)
                if scoring_hand and #scoring_hand > 1 then
                    for i = 2, #scoring_hand do
                        scoring_hand[i]:set_debuff(true)
                        scoring_hand[i].debuffed_by_phone = true
                    end
                end
            end
        else
            if self == G.hand and self.cards then
                for _, c in ipairs(self.cards) do
                    if c.debuffed_by_phone then
                        c:set_debuff(false)
                        c.debuffed_by_phone = nil
                    end
                end
            end
        end

        return parse_highlighted_ref(self)
    end
end

function is_lead_card(card)
    if not card then return false end
    if card.config and card.config.center then
        local k = card.config.center.key
        if k == 'lead' or k == 'm_reality_warp_lead' or k == 'm_lead' then return true end
    end
    if SMODS and SMODS.has_enhancement and SMODS.has_enhancement(card, 'lead') then return true end
    if card.ability and (card.ability.name == 'Lead Card' or card.ability.effect == 'Lead Card') then return true end
    return false
end

function transmute_lead_card(card)
    if not card or not is_lead_card(card) or card.destroyed or card.shattered then return false end

    local pool = {
        { center = G.P_CENTERS.m_gold, msg = 'Transmuted to Gold!', colour = G.C.GOLD },
        { center = get_diamond_enhancement_center() or G.P_CENTERS.m_gold, msg = 'Transmuted to Shiny!', colour = HEX('1b4d2e') },
        { center = G.P_CENTERS.m_steel, msg = 'Transmuted to Metal!', colour = G.C.GREY }
    }
    local chosen = pseudorandom_element(pool, pseudoseed('lead_transmute')) or pool[math.random(1, #pool)]

    if chosen and chosen.center then
        card:set_ability(chosen.center)
        card:juice_up()
        card_eval_status_text(card, 'extra', nil, nil, nil, { message = chosen.msg, colour = chosen.colour })
        play_sound('tarot1', 1.0, 0.6)
        return true
    end
    return false
end

function check_and_transmute_lead_cards(cards)
end

if G and G.FUNCS and G.FUNCS.draw_from_play_to_discard then
    local draw_from_play_to_discard_ref = G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        local broken_cards = {}
        if G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                c.dark_green_scored_this_hand = nil
                if c.dark_green_broken then
                    broken_cards[#broken_cards + 1] = c
                end
            end
        end

        if #broken_cards > 0 then
            if G.jokers and G.jokers.cards then
                for j = 1, #G.jokers.cards do
                    eval_card(G.jokers.cards[j], { cardarea = G.jokers, remove_playing_cards = true, removed = broken_cards })
                end
            end
            check_for_unlock{ type = 'shatter', shattered = broken_cards }

            for _, c in ipairs(broken_cards) do
                c.shattered = true
                c.destroyed = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        card_eval_status_text(c, 'extra', nil, nil, nil, { message = 'Shattered!', colour = HEX('1b4d2e') })
                        c:spectral_shatter()
                        return true
                    end
                }))
            end
        end

        check_and_transmute_lead_cards(G.play and G.play.cards)

        if G.GAME then
            G.GAME.round_lead_scored = nil
        end

        if G.GAME then
            G.GAME.reality_warp_hand_debuffed = nil
        end
        clear_reality_warp_phone_debuffs()

        return draw_from_play_to_discard_ref(e)
    end
end

G.BOSS_TO_FAMILIAR_MAP = {
    ['bl_needle'] = 'baby_needle',
    ['bl_pillar'] = 'baby_pillar',
    ['bl_serpent'] = 'baby_serpent',
    ['bl_flint'] = 'baby_flint',
    ['bl_hook'] = 'baby_hook',
    ['bl_eye'] = 'baby_eye',
    ['bl_ox'] = 'baby_ox',
    ['bl_house'] = 'baby_house',
    ['bl_club'] = 'baby_club',
    ['bl_fish'] = 'baby_fish',
    ['bl_window'] = 'baby_window',
    ['bl_manacle'] = 'baby_manacle',
    ['bl_wall'] = 'baby_wall',
    ['bl_wheel'] = 'baby_wheel',
    ['bl_arm'] = 'baby_arm',
    ['bl_psychic'] = 'baby_psychic',
    ['bl_goad'] = 'baby_goad',
    ['bl_water'] = 'baby_water',
    ['bl_mouth'] = 'baby_mouth',
    ['bl_plant'] = 'baby_plant',
    ['bl_head'] = 'baby_head',
    ['bl_tooth'] = 'baby_tooth',
    ['bl_mark'] = 'baby_mark',
    ['bl_heart'] = 'baby_heart',
    ['bl_bell'] = 'baby_bell',
    ['bl_acorn'] = 'baby_acorn',
    ['bl_leaf'] = 'baby_leaf',
    ['bl_vessel'] = 'baby_vessel',
    ['The Needle'] = 'baby_needle',
    ['The Pillar'] = 'baby_pillar',
    ['The Serpent'] = 'baby_serpent',
    ['The Flint'] = 'baby_flint',
    ['The Hook'] = 'baby_hook',
    ['The Eye'] = 'baby_eye',
    ['The Ox'] = 'baby_ox',
    ['The House'] = 'baby_house',
    ['The Club'] = 'baby_club',
    ['The Fish'] = 'baby_fish',
    ['The Window'] = 'baby_window',
    ['The Manacle'] = 'baby_manacle',
    ['The Wall'] = 'baby_wall',
    ['The Wheel'] = 'baby_wheel',
    ['The Arm'] = 'baby_arm',
    ['The Psychic'] = 'baby_psychic',
    ['The Goad'] = 'baby_goad',
    ['The Water'] = 'baby_water',
    ['The Mouth'] = 'baby_mouth',
    ['The Plant'] = 'baby_plant',
    ['The Head'] = 'baby_head',
    ['The Tooth'] = 'baby_tooth',
    ['The Mark'] = 'baby_mark',
    ['Crimson Heart'] = 'baby_heart',
    ['Cerulean Bell'] = 'baby_bell',
    ['Amber Acorn'] = 'baby_acorn',
    ['Verdant Leaf'] = 'baby_leaf',
    ['Violet Vessel'] = 'baby_vessel',
}

if end_round then
    local end_round_lead_ref = end_round
    function end_round()
        local cards_to_check = (SMODS and SMODS.last_hand and SMODS.last_hand.scoring_hand) or (G.play and G.play.cards) or {}
        check_and_transmute_lead_cards(cards_to_check)

        local is_boss = G.GAME and G.GAME.blind and G.GAME.blind.boss

        if is_boss then
            if reset_all_nursery_cooldowns then reset_all_nursery_cooldowns()
            elseif G.reset_all_nursery_cooldowns then G.reset_all_nursery_cooldowns() end
        else
            if reduce_nursery_cooldowns then reduce_nursery_cooldowns(30)
            elseif G.reduce_nursery_cooldowns then G.reduce_nursery_cooldowns(30) end
        end

        if G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local fam_c = G.botg_familiars.cards[1]
            local f_key = fam_c.config and fam_c.config.center and fam_c.config.center.key
            local add_exp_fn = G.add_nursery_exp or add_nursery_exp
            if f_key and add_exp_fn then
                local exp_gain = is_boss and 50 or 25
                local leveled = add_exp_fn(f_key, exp_gain)
                if leveled then
                    play_sound('gold_seal', 1.2, 0.8)
                    fam_c:juice_up(0.6, 0.6)
                    local new_lvl = (botg_get_familiar_level and botg_get_familiar_level(f_key)) or 1
                    card_eval_status_text(fam_c, 'extra', nil, nil, nil, { message = 'Level Up! (Lv.' .. new_lvl .. ')', colour = G.C.GOLD })
                else
                    fam_c:juice_up(0.25, 0.25)
                    card_eval_status_text(fam_c, 'extra', nil, nil, nil, { message = '+' .. exp_gain .. ' EXP', colour = G.C.BLUE })
                end
            end
        end

        if is_boss and G.GAME and G.GAME.blind then
            local b_key = G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key
            local b_name = G.GAME.blind.name
            local boss_fam_key = G.BOSS_TO_FAMILIAR_MAP and (G.BOSS_TO_FAMILIAR_MAP[b_key] or G.BOSS_TO_FAMILIAR_MAP[b_name])
            if boss_fam_key then
                if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] then
                    local p = G.PROFILES[G.SETTINGS.profile]
                    p.witch_discovered_familiars = p.witch_discovered_familiars or {}
                    p.witch_discovered_familiars['c_reality_warp_' .. boss_fam_key] = true
                    if G.save_progress then G:save_progress() end
                end
                local add_exp_fn = G.add_nursery_exp or add_nursery_exp
                if add_exp_fn then
                    add_exp_fn(boss_fam_key, 75)
                end
                local fam_info = G.NURSERY_ROOM_BY_KEY and G.NURSERY_ROOM_BY_KEY[boss_fam_key]
                local fam_display_name = fam_info and fam_info.name or "Baby Boss"
                play_sound('gold_seal', 1.2, 0.8)
                attention_text({ text = "Boss Treat Earned! +75 EXP for " .. fam_display_name .. "!", scale = 0.45, hold = 2.0, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1.5} })
            end
        end

        if check_witcher_joker_achievements then
            check_witcher_joker_achievements()
        end

        return end_round_lead_ref()
    end
end

if G and G.FUNCS and G.FUNCS.draw_from_deck_to_hand then
    local draw_from_deck_to_hand_ref = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        purge_reality_warp_ghost_cards()
        if G.GAME then
            G.GAME.reality_warp_hand_debuffed = nil
        end
        clear_reality_warp_phone_debuffs()
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                c.dark_green_scored_this_hand = nil
            end
        end
        return draw_from_deck_to_hand_ref(e)
    end
end

if G and G.UIDEF and G.UIDEF.use_and_sell_buttons then
    local use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
    G.UIDEF.use_and_sell_buttons = function(card)
        local base_background = use_and_sell_buttons_ref(card)
        if not card or card.area ~= G.jokers or G.STATE == G.STATES.TUTORIAL then
            return base_background
        end
        if not base_background or not base_background.nodes or not base_background.nodes[1] or not base_background.nodes[1].nodes then
            return base_background
        end

            if card_has_key(card, 'slot_machine') then
                local bet_text = "Bet"
                table.insert(base_background.nodes[1].nodes, {
                    n = G.UIT.R,
                    config = { align = "cl" },
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
                                        one_press = true,
                                        button = 'slot_machine_bet',
                                        func = 'can_slot_machine_bet'
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
                                                        { n = G.UIT.T, config = { text = bet_text, colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                                    }
                                                },
                                                {
                                                    n = G.UIT.R,
                                                    config = { align = "cm" },
                                                    nodes = {
                                                        { n = G.UIT.T, config = { text = "$5", colour = G.C.WHITE, scale = 0.55, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

            if card_has_key(card, 'lesionado') or card_has_key(card, 'injured') then
                local transforms_text = "Transforms"
                table.insert(base_background.nodes[1].nodes, {
                    n = G.UIT.R,
                    config = { align = "cl" },
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
                                        colour = G.C.BLUE,
                                        one_press = true,
                                        button = 'injured_show_roster'
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
                                                        { n = G.UIT.T, config = { text = transforms_text, colour = G.C.WHITE, scale = 0.32, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

            if card_has_key(card, 'pachinko') then
                local ex = card.ability and card.ability.extra
                local can_play = ex and not ex.played_this_round and not card.debuff and (G.STATE == G.STATES.SELECTING_HAND)
                local btn_col = can_play and G.C.GREEN or G.C.UI.BACKGROUND_INACTIVE
                local btn_txt = (G.STATE ~= G.STATES.SELECTING_HAND and "In Round Only") or (ex and ex.played_this_round and "Played" or "Play")

                table.insert(base_background.nodes[1].nodes, {
                    n = G.UIT.R,
                    config = { align = "cl" },
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
                                        hover = can_play,
                                        shadow = true,
                                        colour = btn_col,
                                        one_press = true,
                                        button = can_play and 'pachinko_play' or nil,
                                        func = 'can_pachinko_play'
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
                                                        { n = G.UIT.T, config = { text = btn_txt, colour = G.C.WHITE, scale = 0.36, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

            if card_has_key(card, 'shell_game') then
                local ex = card.ability and card.ability.extra
                local can_play = ex and not ex.played_this_round and not card.debuff and (G.STATE == G.STATES.SELECTING_HAND)
                local btn_col = can_play and G.C.PURPLE or G.C.UI.BACKGROUND_INACTIVE
                local btn_txt = (G.STATE ~= G.STATES.SELECTING_HAND and "In Round Only") or (ex and ex.played_this_round and "Played" or "Play")

                table.insert(base_background.nodes[1].nodes, {
                    n = G.UIT.R,
                    config = { align = "cl" },
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
                                        minh = 0.6,
                                        hover = can_play,
                                        shadow = true,
                                        colour = btn_col,
                                        one_press = true,
                                        button = can_play and 'shell_game_play' or nil,
                                        func = 'can_shell_game_play'
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
                                                        { n = G.UIT.T, config = { text = btn_txt, colour = G.C.WHITE, scale = 0.36, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

            if card_has_key(card, 'claw_machine') then
                local ex = card.ability and card.ability.extra
                local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
                local cost = (ex and ex.cost) or 2
                local can_play = ex and not ex.played_this_round and not card.debuff and cur_d >= cost and (G.STATE == G.STATES.SELECTING_HAND)
                local btn_col = can_play and G.C.ORANGE or G.C.UI.BACKGROUND_INACTIVE
                local btn_txt = (G.STATE ~= G.STATES.SELECTING_HAND and "In Round Only") or (ex and ex.played_this_round and "Played") or (cur_d < cost and "$2 Req" or "Claw")

                table.insert(base_background.nodes[1].nodes, {
                    n = G.UIT.R,
                    config = { align = "cl" },
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
                                        minh = 0.6,
                                        hover = can_play,
                                        colour = btn_col,
                                        one_press = true,
                                        button = can_play and 'claw_machine_play' or nil,
                                        func = 'can_claw_machine_play'
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
                                                        { n = G.UIT.T, config = { text = btn_txt, colour = G.C.WHITE, scale = 0.36, shadow = true } }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            end

        return base_background
    end
end

if G and G.FUNCS then
    G.FUNCS.can_slot_machine_bet = function(e)
        local card = e.config.ref_table
        if card and card.ability and card.ability.extra then
            local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
            if card.ability.extra.bet_placed then
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            elseif cur_d >= 5 and G.STATE == G.STATES.SELECTING_HAND then
                e.config.colour = G.C.GOLD
                e.config.button = 'slot_machine_bet'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end
    end

    G.FUNCS.slot_machine_bet = function(e)
        local card = e.config.ref_table
        local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
        if card and card.ability and card.ability.extra and not card.ability.extra.bet_placed and cur_d >= 5 then
            ease_dollars(-5)
            card.ability.extra.bet_placed = true
            card.ability.extra.bet_amount = 5
            card.ability.extra.challenge_completed = false
            card:juice_up(0.5, 0.5)
            play_sound('coin1')
            local bet_msg = "Bet $5!"
            attention_text({
                text = bet_msg,
                scale = 0.9,
                hold = 1.0,
                major = card,
                backdrop_colour = G.C.GOLD,
                align = 'cm',
                silent = true
            })
            if e.UIBox then e.UIBox:recalculate(true) end
        end
    end

    G.FUNCS.injured_show_roster = function(e)
        if create_UIBox_generic_options and G.FUNCS.overlay_menu then
            local title = "Injured Joker Transformations"
            local subtitle = "At end of round (1 in 5 chance) can transform into:"
            local quote_rock = " - \"Let's rock!\""
            local quote_curse = " - \"Cursed!\""

            local t = create_UIBox_generic_options({
                back_func = 'exit_overlay_menu',
                contents = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.2}, nodes = {
                        {n = G.UIT.T, config = {text = title, scale = 0.6, colour = G.C.GOLD, shadow = true}}
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                        {n = G.UIT.T, config = {text = subtitle, scale = 0.4, colour = G.C.WHITE}}
                    }},
                    {n = G.UIT.R, config = {align = "cm", padding = 0.15, colour = G.C.L_BLACK, r = 0.1}, nodes = {
                        {n = G.UIT.C, config = {align = "cl", padding = 0.1}, nodes = {
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Motorized Joker", scale = 0.42, colour = G.C.ORANGE}},
                                {n = G.UIT.T, config = {text = quote_rock, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Stuntman", scale = 0.42, colour = G.C.ORANGE}},
                                {n = G.UIT.T, config = {text = quote_rock, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Invisible Joker", scale = 0.42, colour = G.C.RED}},
                                {n = G.UIT.T, config = {text = quote_curse, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Mr. Bones", scale = 0.42, colour = G.C.RED}},
                                {n = G.UIT.T, config = {text = quote_curse, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Vampire", scale = 0.42, colour = G.C.RED}},
                                {n = G.UIT.T, config = {text = quote_curse, scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.R, config = {align = "cl", padding = 0.04}, nodes = {
                                {n = G.UIT.T, config = {text = "• Joker Stencil", scale = 0.42, colour = G.C.PURPLE}},
                                {n = G.UIT.T, config = {text = " - \"?\"", scale = 0.35, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                        }}
                    }}
                }
            })
            G.FUNCS.overlay_menu{definition = t}
        end
    end

    G.FUNCS.can_pachinko_play = function(e)
        local card = e.config.ref_table
        if card and card.ability and card.ability.extra then
            local ex = card.ability.extra
            if not ex.played_this_round and not card.debuff and G.STATE == G.STATES.SELECTING_HAND then
                e.config.colour = G.C.GREEN
                e.config.button = 'pachinko_play'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end
    end

    local function update_pachinko_ui()
        if not (G.OVERLAY_MENU and G.OVERLAY_MENU.get_UIE_by_ID) then return end
        local e = G.OVERLAY_MENU:get_UIE_by_ID('pachinko_contents')
        if e then
            if e.config.object then
                e.config.object:remove()
                e.config.object = nil
            end
            e.config.object = UIBox{
                definition = G.UIDEF.pachinko_inner_content(),
                config = { offset = { x = 0, y = 0 }, align = 'cm', parent = e }
            }
            if G.OVERLAY_MENU.recalculate then
                G.OVERLAY_MENU:recalculate()
            end
        else
            if G.OVERLAY_MENU then G.FUNCS.overlay_menu{ definition = G.UIDEF.pachinko_overlay() } end
        end
    end

    G.UIDEF.pachinko_inner_content = function()
        local session = G.GAME and G.GAME.reality_warp_pachinko_session
        if not session then return { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {} } end

        local function make_peg_row(row_idx, count, is_staggered)
            local nodes = {}
            local hit_col = session.steps_cols and session.steps_cols[row_idx]
            local is_active_row = (session.step == row_idx)
            local substep = session.substep or 'hit'
            local dir = (session.steps_dirs and session.steps_dirs[row_idx]) or 1

            for p = 1, count do
                local is_hit = (is_active_row and p == hit_col)
                local peg_cell_content = nil

                if is_hit then
                    local hit_peg = {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            minw = 0.26,
                            minh = 0.26,
                            r = 0.13,
                            colour = G.C.GOLD,
                            emboss = 0.06,
                            shadow = true
                        },
                        nodes = {}
                    }

                    local ball_node = {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            minw = 0.36,
                            minh = 0.36,
                            r = 0.18,
                            colour = G.C.RED,
                            emboss = 0.08,
                            shadow = true
                        },
                        nodes = {}
                    }

                    if substep == 'hit' then
                        peg_cell_content = {
                            n = G.UIT.C,
                            config = { align = "cm" },
                            nodes = {
                                ball_node,
                                { n = G.UIT.B, config = { w = 0.02, h = 0.02 } },
                                hit_peg
                            }
                        }
                    else
                        if dir < 0 then
                            peg_cell_content = {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    ball_node,
                                    { n = G.UIT.B, config = { w = 0.04, h = 0.02 } },
                                    hit_peg
                                }
                            }
                        else
                            peg_cell_content = {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    hit_peg,
                                    { n = G.UIT.B, config = { w = 0.04, h = 0.02 } },
                                    ball_node
                                }
                            }
                        end
                    end
                else
                    peg_cell_content = {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            minw = 0.20,
                            minh = 0.20,
                            r = 0.10,
                            colour = G.C.WHITE,
                            emboss = 0.04
                        },
                        nodes = {}
                    }
                end

                table.insert(nodes, {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        padding = 0.02,
                        minw = is_staggered and 0.74 or 0.88,
                        minh = 0.50,
                        colour = G.C.CLEAR
                    },
                    nodes = { peg_cell_content }
                })
            end
            return { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = nodes }
        end

        local pocket_nodes = {}
        for b = 1, 5 do
            local won = (session.step == 5 and b == session.final_pocket)
            local p_info = (session.pocket_prizes and session.pocket_prizes[b]) or {
                label = "POCKET " .. b,
                text = (b == 3 and "+X0.50 Mult" or (b % 2 == 1 and "+50 Chips" or "+10 Mult")),
                col = (b == 3 and G.C.GOLD or (b % 2 == 1 and G.C.CHIPS or G.C.MULT))
            }
            local col = won and p_info.col or G.C.BLACK
            local border_col = won and G.C.WHITE or G.C.L_BLACK

            table.insert(pocket_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.05,
                    r = 0.08,
                    colour = col,
                    emboss = 0.06,
                    outline = won and 2 or 1.2,
                    outline_colour = border_col,
                    minw = 1.35,
                    minh = 0.76
                },
                nodes = {
                    { n = G.UIT.R, config = { align = "cm" }, nodes = {
                        { n = G.UIT.T, config = { text = p_info.label, scale = 0.18, colour = won and G.C.WHITE or G.C.UI.TEXT_INACTIVE } }
                    } },
                    { n = G.UIT.R, config = { align = "cm" }, nodes = {
                        { n = G.UIT.T, config = { text = p_info.text, scale = won and 0.26 or 0.22, colour = won and G.C.WHITE or p_info.col, shadow = won } }
                    } },
                    won and { n = G.UIT.R, config = { align = "cm" }, nodes = {
                        { n = G.UIT.T, config = { text = "WINNER", scale = 0.20, colour = G.C.WHITE, shadow = true } }
                    } } or nil
                }
            })
        end

        local launcher_node = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.03 },
            nodes = {
                (session.step == 0) and {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        padding = 0.04,
                        minw = 0.40,
                        minh = 0.40,
                        r = 0.20,
                        colour = G.C.RED,
                        emboss = 0.08,
                        shadow = true
                    },
                    nodes = {}
                } or {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        minw = 0.40,
                        minh = 0.12,
                        r = 0.06,
                        colour = G.C.L_BLACK
                    },
                    nodes = {}
                }
            }
        }

        local status_text = session.status_text or "Dropping steel ball into pins..."
        local status_col = (session.step == 5) and (session.prize_colour or G.C.GOLD) or (session.step > 0 and G.C.RED or G.C.GOLD)

        local btn_nodes = {}
        if session.step == 5 then
            table.insert(btn_nodes, UIBox_button({
                label = { "Collect & Continue" },
                button = 'exit_overlay_menu',
                colour = G.C.BLUE,
                minw = 3.2,
                minh = 0.6,
                scale = 0.38,
                emboss = 0.08,
                col = true
            }))
        else
            table.insert(btn_nodes, UIBox_button({
                label = { "Bouncing Ball..." },
                colour = G.C.UI.BACKGROUND_INACTIVE,
                minw = 3.2,
                minh = 0.6,
                scale = 0.35,
                emboss = 0.08,
                col = true
            }))
        end

        return {
            n = G.UIT.ROOT,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.08 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "PACHINKO MACHINE", scale = 0.6, colour = G.C.GOLD, shadow = true } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.03 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Impulse Launch Force: " .. session.force .. "%", scale = 0.32, colour = G.C.UI.TEXT_LIGHT } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.1, r = 0.12, colour = G.C.L_BLACK, emboss = 0.08, outline = 2, outline_colour = G.C.BLACK, minw = 7.5 },
                    nodes = {
                        launcher_node,
                        make_peg_row(1, 5, false),
                        make_peg_row(2, 6, true),
                        make_peg_row(3, 5, false),
                        make_peg_row(4, 6, true),
                        { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = {} },
                        { n = G.UIT.R, config = { align = "cm", padding = 0.03 }, nodes = pocket_nodes }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.06 },
                    nodes = {
                        { n = G.UIT.T, config = { text = status_text, scale = 0.36, colour = status_col, shadow = true } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.03 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Permanent Total: +" .. session.cur_chips .. " Chips | +" .. session.cur_mult .. " Mult | X" .. session.cur_xmult .. " Mult", scale = 0.28, colour = G.C.WHITE, shadow = true } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.08 },
                    nodes = btn_nodes
                }
            }
        }
    end

    G.UIDEF.pachinko_overlay = function()
        local session = G.GAME and G.GAME.reality_warp_pachinko_session
        if not session then return {} end

        return create_UIBox_generic_options({
            back_func = 'exit_overlay_menu',
            contents = {
                {
                    n = G.UIT.O,
                    config = {
                        id = 'pachinko_contents',
                        object = UIBox{
                            definition = G.UIDEF.pachinko_inner_content(),
                            config = { offset = { x = 0, y = 0 }, align = 'cm' }
                        },
                        align = 'cm'
                    }
                }
            }
        })
    end

    G.FUNCS.pachinko_play = function(e)
        local card = e.config.ref_table
        if not card or not card.ability or not card.ability.extra or card.ability.extra.played_this_round or card.debuff or G.STATE ~= G.STATES.SELECTING_HAND then return end
        card.ability.extra.played_this_round = true
        if e.UIBox then e.UIBox:recalculate(true) end

        local force = pseudorandom('pachinko_force', 70, 130)

        local pos = 3.0 + (force - 100) / 35.0
        local c1 = math.max(1, math.min(5, math.floor(pos + 0.5)))

        local roll2 = pseudorandom('pachinko_deflect')
        local dir2 = (roll2 > 0.5) and 1 or -1
        pos = math.max(1.0, math.min(6.0, pos + dir2 * 0.5))
        local c2 = math.max(1, math.min(6, math.floor(pos + 0.5)))

        local roll3 = pseudorandom('pachinko_deflect')
        local dir3 = (roll3 > 0.5) and 1 or -1
        pos = math.max(1.0, math.min(5.0, pos + dir3 * 0.5))
        local c3 = math.max(1, math.min(5, math.floor(pos + 0.5)))

        local roll4 = pseudorandom('pachinko_deflect')
        local dir4 = (roll4 > 0.5) and 1 or -1
        pos = math.max(1.0, math.min(6.0, pos + dir4 * 0.5))
        local c4 = math.max(1, math.min(6, math.floor(pos + 0.5)))

        local final_pocket = math.max(1, math.min(5, math.floor(pos + 0.5)))

        local pocket_prizes = {
            [1] = { type = 'chips', val = pseudorandom('pachinko_val', 40, 75), label = "POCKET 1", col = G.C.CHIPS },
            [2] = { type = 'mult',  val = pseudorandom('pachinko_val', 6, 12),  label = "POCKET 2", col = G.C.MULT },
            [3] = { type = 'x_mult', val = pseudorandom('pachinko_val', 25, 50) / 100.0, label = "JACKPOT", col = G.C.GOLD },
            [4] = { type = 'chips', val = pseudorandom('pachinko_val', 50, 90), label = "POCKET 4", col = G.C.CHIPS },
            [5] = { type = 'mult',  val = pseudorandom('pachinko_val', 8, 15),  label = "POCKET 5", col = G.C.MULT },
        }
        for b = 1, 5 do
            local p = pocket_prizes[b]
            if p.type == 'chips' then
                p.text = '+' .. p.val .. ' Chips'
            elseif p.type == 'mult' then
                p.text = '+' .. p.val .. ' Mult'
            else
                p.text = '+X' .. string.format('%.2f', p.val) .. ' Mult'
            end
        end

        local win_prize = pocket_prizes[final_pocket]
        if win_prize.type == 'chips' then
            card.ability.extra.chips = (card.ability.extra.chips or 0) + win_prize.val
        elseif win_prize.type == 'mult' then
            card.ability.extra.mult = (card.ability.extra.mult or 0) + win_prize.val
        elseif win_prize.type == 'x_mult' then
            card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) + win_prize.val
        end

        local dir1 = (force >= 100) and 1 or -1
        G.GAME.reality_warp_pachinko_session = {
            card = card,
            force = force,
            step = 0,
            substep = 'hit',
            steps_cols = { c1, c2, c3, c4 },
            steps_dirs = { dir1, dir2, dir3, dir4 },
            final_pocket = final_pocket,
            pocket_prizes = pocket_prizes,
            prize_msg = win_prize.text,
            prize_colour = win_prize.col,
            status_text = "Impulse launch: Dropping steel ball into pins...",
            cur_chips = card.ability.extra.chips or 0,
            cur_mult = card.ability.extra.mult or 0,
            cur_xmult = string.format('%.2f', card.ability.extra.x_mult or 1.0)
        }

        local speed = math.max(1, (G.SETTINGS and G.SETTINGS.GAMESPEED or 1))
        local hit_delay = math.max(0.26, 0.55 / math.sqrt(speed))
        local bounce_delay = math.max(0.20, 0.42 / math.sqrt(speed))
        local final_delay = math.max(0.32, 0.65 / math.sqrt(speed))

        if create_UIBox_generic_options and G.FUNCS.overlay_menu then
            play_sound('tarot2', 1.3, 0.8)
            G.FUNCS.overlay_menu{ definition = G.UIDEF.pachinko_overlay() }

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = hit_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.step = 1
                    sess.substep = 'hit'
                    sess.status_text = "Ball strikes Pin #" .. c1 .. "! PING!"
                    play_sound('chips1', 0.95, 0.85)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = bounce_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.substep = 'bounce'
                    sess.status_text = "Bouncing off Pin #" .. c1 .. ((dir1 > 0) and " to Right ->" or " <- to Left")
                    play_sound('chips2', 1.05, 0.75)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = hit_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.step = 2
                    sess.substep = 'hit'
                    sess.status_text = "Ball strikes Pin #" .. c2 .. "! PING!"
                    play_sound('chips1', 1.10, 0.85)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = bounce_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.substep = 'bounce'
                    sess.status_text = "Bouncing off Pin #" .. c2 .. ((dir2 > 0) and " to Right ->" or " <- to Left")
                    play_sound('chips2', 1.20, 0.75)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = hit_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.step = 3
                    sess.substep = 'hit'
                    sess.status_text = "Ball strikes Pin #" .. c3 .. "! PING!"
                    play_sound('chips1', 1.25, 0.85)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = bounce_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.substep = 'bounce'
                    sess.status_text = "Bouncing off Pin #" .. c3 .. ((dir3 > 0) and " to Right ->" or " <- to Left")
                    play_sound('chips2', 1.35, 0.75)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = hit_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.step = 4
                    sess.substep = 'hit'
                    sess.status_text = "Ball strikes Pin #" .. c4 .. "! PING!"
                    play_sound('chips1', 1.40, 0.85)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = bounce_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.substep = 'bounce'
                    sess.status_text = "Dropping into " .. sess.pocket_prizes[sess.final_pocket].label .. "..."
                    play_sound('chips2', 1.50, 0.75)
                    update_pachinko_ui()
                    return true
                end
            }))

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = final_delay,
                func = function()
                    if not (G.GAME and G.GAME.reality_warp_pachinko_session) then return true end
                    local sess = G.GAME.reality_warp_pachinko_session
                    sess.step = 5
                    sess.substep = 'land'
                    sess.status_text = "Ball landed in " .. sess.pocket_prizes[sess.final_pocket].label .. "! Won: " .. sess.prize_msg .. "!"
                    sess.cur_chips = sess.card.ability.extra.chips or 0
                    sess.cur_mult = sess.card.ability.extra.mult or 0
                    sess.cur_xmult = string.format('%.2f', sess.card.ability.extra.x_mult or 1.0)
                    play_sound('gold_seal', 1.2, 0.9)
                    if sess.card then sess.card:juice_up(0.6, 0.4) end
                    if notify_minigame_completed then notify_minigame_completed('pachinko') end
                    update_pachinko_ui()
                    return true
                end
            }))
        else
            play_sound('gold_seal', 1.2, 0.9)
            card:juice_up(0.6, 0.4)
            if notify_minigame_completed then notify_minigame_completed('pachinko') end
            attention_text({
                text = "Pachinko: " .. win_prize.text .. "!",
                scale = 0.8,
                hold = 1.6 / speed,
                backdrop_colour = win_prize.col,
                align = 'cm',
                offset = { x = 0, y = -1.5 }
            })
        end
    end

    G.FUNCS.can_shell_game_play = function(e)
        local card = e.config.ref_table
        if card and card.ability and card.ability.extra then
            local ex = card.ability.extra
            local can_play = not ex.played_this_round and not card.debuff and (G.STATE == G.STATES.SELECTING_HAND)
            if can_play then
                e.config.colour = G.C.PURPLE
                e.config.button = 'shell_game_play'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end
    end

    local function update_shell_game_ui()
        if not (G.OVERLAY_MENU and G.OVERLAY_MENU.get_UIE_by_ID) then return end
        local e = G.OVERLAY_MENU:get_UIE_by_ID('shell_game_contents')
        if e then
            if e.config.object then
                e.config.object:remove()
                e.config.object = nil
            end
            e.config.object = UIBox{
                definition = G.UIDEF.shell_game_inner_content(),
                config = { offset = { x = 0, y = 0 }, align = 'cm', parent = e }
            }
            if G.OVERLAY_MENU.recalculate then
                G.OVERLAY_MENU:recalculate()
            end
        else
            if G.OVERLAY_MENU then G.FUNCS.overlay_menu{ definition = G.UIDEF.shell_game_overlay() } end
        end
    end

    G.FUNCS.shell_game_set_prize = function(e)
        local prize = e.config.ref_table and e.config.ref_table.prize
        local session = G.GAME and G.GAME.reality_warp_shell_session
        if session and prize and session.stage ~= 'result' then
            session.target_prize = prize
            if session.card and session.card.ability and session.card.ability.extra then
                session.card.ability.extra.target_prize = prize
            end
            play_sound('button', 1.1, 0.7)
            update_shell_game_ui()
        end
    end

    local standard_acorn_pool = {
        { key = 'j_joker', name = "Joker", pos = { x = 0, y = 0 }, col = G.C.RED },
        { key = 'j_jolly', name = "Jolly Joker", pos = { x = 2, y = 0 }, col = G.C.ORANGE },
        { key = 'j_zany', name = "Zany Joker", pos = { x = 3, y = 0 }, col = G.C.RED },
        { key = 'j_mad', name = "Mad Joker", pos = { x = 4, y = 0 }, col = G.C.RED },
        { key = 'j_crazy', name = "Crazy Joker", pos = { x = 5, y = 0 }, col = G.C.RED },
        { key = 'j_droll', name = "Droll Joker", pos = { x = 6, y = 0 }, col = G.C.RED },
        { key = 'j_sly', name = "Sly Joker", pos = { x = 0, y = 1 }, col = G.C.BLUE },
        { key = 'j_wily', name = "Wily Joker", pos = { x = 1, y = 1 }, col = G.C.BLUE },
        { key = 'j_clever', name = "Clever Joker", pos = { x = 2, y = 1 }, col = G.C.BLUE },
        { key = 'j_devious', name = "Devious Joker", pos = { x = 3, y = 1 }, col = G.C.BLUE },
        { key = 'j_crafty', name = "Crafty Joker", pos = { x = 4, y = 1 }, col = G.C.BLUE },
        { key = 'j_abstract', name = "Abstract Joker", pos = { x = 6, y = 5 }, col = G.C.BLUE },
        { key = 'j_misprint', name = "Misprint", pos = { x = 5, y = 6 }, col = G.C.PURPLE },
        { key = 'j_scary_face', name = "Scary Face", pos = { x = 1, y = 4 }, col = G.C.CHIPS },
        { key = 'j_gros_michel', name = "Gros Michel", pos = { x = 4, y = 5 }, col = G.C.GOLD },
        { key = 'j_even_steven', name = "Even Steven", pos = { x = 2, y = 4 }, col = G.C.CHIPS },
        { key = 'j_odd_todd', name = "Odd Todd", pos = { x = 3, y = 4 }, col = G.C.CHIPS },
        { key = 'j_ice_cream', name = "Ice Cream", pos = { x = 8, y = 5 }, col = G.C.BLUE },
        { key = 'j_green_joker', name = "Green Joker", pos = { x = 4, y = 4 }, col = G.C.GREEN },
        { key = 'j_popcorn', name = "Popcorn", pos = { x = 9, y = 5 }, col = G.C.ORANGE },
        { key = 'j_ramen', name = "Ramen", pos = { x = 0, y = 6 }, col = G.C.RED },
    }

    local function make_joker_card_sprite(card_data, is_face_down, is_shaking, w, h)
        w = w or 1.15
        h = h or 1.55
        if Moveable and Sprite then
            local view = Moveable(0, 0, w, h)
            local key = card_data and card_data.key or 'j_joker'
            local center = G.P_CENTERS and G.P_CENTERS[key]
            local atlas = (center and center.atlas and G.ASSET_ATLAS and G.ASSET_ATLAS[center.atlas])
                       or (G.ASSET_ATLAS and G.ASSET_ATLAS['Joker'])
                       or (G.ASSET_ATLAS and G.ASSET_ATLAS['centers'])
            local pos = (center and center.pos) or (card_data and card_data.pos) or { x = 0, y = 0 }

            local back_atlas = (G.GAME and G.GAME.selected_back and G.ASSET_ATLAS and G.ASSET_ATLAS[G.GAME.selected_back.atlas or 'centers'])
                            or (G.ASSET_ATLAS and (G.ASSET_ATLAS['centers'] or G.ASSET_ATLAS['b_red']))
            local back_pos = (G.GAME and G.GAME.selected_back and G.GAME.selected_back.pos) or { x = 0, y = 0 }

            if is_face_down and back_atlas then
                view.icon_sprite = Sprite(0, 0, w, h, back_atlas, back_pos)
            elseif atlas then
                view.icon_sprite = Sprite(0, 0, w, h, atlas, pos)
            end

            view.is_shaking = is_shaking
            function view:draw()
                if self.icon_sprite then
                    local base_w = self.T.w
                    local base_h = self.T.h
                    local rot = 0
                    local bounce = 0
                    local scale_mod = 1
                    if self.is_shaking and G.TIMERS and G.TIMERS.REAL then
                        local t = G.TIMERS.REAL * 14
                        rot = math.sin(t) * 0.08
                        bounce = -math.abs(math.sin(t * 0.6)) * 0.045
                        scale_mod = 1 + (math.sin(t * 0.6) * 0.04)
                    end
                    self.icon_sprite.T.r = rot
                    self.icon_sprite.T.w = base_w * scale_mod
                    self.icon_sprite.T.h = base_h * scale_mod
                    self.icon_sprite.T.x = self.T.x + (base_w * (1 - scale_mod) * 0.5)
                    self.icon_sprite.T.y = self.T.y + bounce + (base_h * (1 - scale_mod) * 0.5)
                    self.icon_sprite:draw()
                end
                add_to_drawhash(self)
            end
            return { n = G.UIT.O, config = { object = view } }
        end
        return nil
    end

    local function roll_acorn_round()
        local pool = {}
        for _, j in ipairs(standard_acorn_pool) do table.insert(pool, j) end
        for i = #pool, 2, -1 do
            local r = math.random(1, i)
            pool[i], pool[r] = pool[r], pool[i]
        end
        local jokers = {}
        for i = 1, 5 do
            table.insert(jokers, pool[i])
        end
        local target_idx = math.random(1, 5)
        return jokers, jokers[target_idx]
    end

    G.FUNCS.shell_game_start_shuffle = function(e)
        local session = G.GAME and G.GAME.reality_warp_shell_session
        if not session or not session.jokers or session.stage ~= 'reveal' then return end

        session.stage = 'shuffling'
        session.status_text = "Flipping face down... Amber Acorn begins!"
        session.picked_idx = nil
        session.result_msg = ""
        play_sound('cardSlide1', 0.88, 0.8)
        update_shell_game_ui()

        local speed = math.max(1, (G.SETTINGS and G.SETTINGS.GAMESPEED) or 1)
        local step_delay = 0.42 / speed

        for s = 1, 5 do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = step_delay,
                func = function()
                    local sess = G.GAME and G.GAME.reality_warp_shell_session
                    if not sess or sess.stage ~= 'shuffling' then return true end
                    sess.status_text = "Amber Acorn: Shuffling... (" .. s .. "/5)"
                    local i = math.random(1, #sess.jokers)
                    local j = math.random(1, #sess.jokers)
                    while j == i do j = math.random(1, #sess.jokers) end
                    sess.jokers[i], sess.jokers[j] = sess.jokers[j], sess.jokers[i]
                    play_sound(s % 2 == 0 and 'cardSlide2' or 'cardSlide1', 0.90 + (s * 0.08), 0.8)
                    update_shell_game_ui()
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = step_delay,
            func = function()
                local sess = G.GAME and G.GAME.reality_warp_shell_session
                if not sess or sess.stage ~= 'shuffling' then return true end
                sess.stage = 'active'
                sess.status_text = "Shuffled! Click a face-down card to find " .. (sess.target_joker and sess.target_joker.name or "Target") .. "!"
                play_sound('gold_seal', 1.1, 0.7)
                update_shell_game_ui()
                return true
            end
        }))
    end

    G.FUNCS.shell_game_reset_and_play = function(e)
        local session = G.GAME and G.GAME.reality_warp_shell_session
        if not session then return end

        local jokers, target_joker = roll_acorn_round()
        session.stage = 'reveal'
        session.status_text = "FIND THIS JOKER: ★ " .. string.upper(target_joker.name) .. " ★"
        session.jokers = jokers
        session.target_joker = target_joker
        session.picked_idx = nil
        session.result_msg = ""
        session.won = false

        play_sound('cardSlide2', 1.1, 0.8)
        update_shell_game_ui()
    end

    G.FUNCS.shell_game_pick_cup = function(e)
        local cup_idx = e.config.ref_table and e.config.ref_table.cup_idx
        local session = G.GAME and G.GAME.reality_warp_shell_session
        if not session or not cup_idx or session.stage ~= 'active' or not session.jokers then return end

        session.picked_idx = cup_idx
        session.stage = 'result'
        local picked = session.jokers[cup_idx]
        local target = session.target_joker
        local card = session.card

        if picked and target and picked.key == target.key then
            session.won = true
            local prize = session.target_prize
            if prize == 'money' then
                ease_dollars(12)
                session.result_msg = "CORRECT! Found " .. target.name .. "! Won $12 Cash!"
            elseif prize == 'tarot' then
                if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                    local tcard = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'shell_game')
                    tcard:add_to_deck()
                    G.consumeables:emplace(tcard)
                    session.result_msg = "CORRECT! Found " .. target.name .. "! Won Tarot: " .. (tcard.ability.name or "Tarot") .. "!"
                else
                    ease_dollars(8)
                    session.result_msg = "CORRECT! Found " .. target.name .. "! (Slots full: awarded $8)!"
                end
            elseif prize == 'hands' then
                ease_hands_played(1)
                ease_discard(1)
                session.result_msg = "CORRECT! Found " .. target.name .. "! Won +1 Hand & +1 Discard!"
            elseif prize == 'mult' then
                if card and card.ability and card.ability.extra then
                    card.ability.extra.mult = (card.ability.extra.mult or 12) + 15
                end
                session.result_msg = "CORRECT! Found " .. target.name .. "! Joker gained +15 Mult permanently!"
            end
            play_sound('timpani', 1.2, 0.9)
            if card then card:juice_up(0.7, 0.4) end
        else
            session.won = false
            session.result_msg = "WRONG JOKER! Picked " .. (picked and picked.name or "Unknown") .. ", target was " .. (target and target.name or "Target") .. "! You get nothing."
            play_sound('cancel', 1.0, 0.9)
            if card then card:juice_up(0.3, 0.2) end
        end

        if notify_minigame_completed then
            notify_minigame_completed('shell_game')
        end

        update_shell_game_ui()
    end

    G.UIDEF.shell_game_inner_content = function()
        local session = G.GAME and G.GAME.reality_warp_shell_session
        if not session or not session.jokers then return { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {} } end

        local card_nodes = {}
        for i = 1, 5 do
            local jk = session.jokers[i]
            local is_picked = (session.picked_idx == i)
            local is_target = (jk and session.target_joker and jk.key == session.target_joker.key)
            local is_clickable = (session.stage == 'active')
            local is_face_down = (session.stage == 'active' or session.stage == 'shuffling')
            local is_shaking = (session.stage == 'reveal' and is_target)

            local sprite_node = make_joker_card_sprite(jk, is_face_down, is_shaking, 1.25, 1.68)

            local slot_bg = G.C.BLACK
            local slot_border = G.C.L_BLACK
            local slot_outline = 1.2
            if session.stage == 'reveal' then
                if is_target then
                    slot_bg = G.C.BLACK
                    slot_border = G.C.GOLD
                    slot_outline = 2
                end
            elseif session.stage == 'shuffling' then
                slot_bg = G.C.BLACK
                slot_border = G.C.L_BLACK
                slot_outline = 1.2
            elseif session.stage == 'active' then
                slot_bg = G.C.BLACK
                slot_border = G.C.BLUE
                slot_outline = 1.5
            elseif session.stage == 'result' then
                if is_picked then
                    slot_bg = session.won and G.C.BLACK or G.C.BLACK
                    slot_border = session.won and G.C.GREEN or G.C.RED
                    slot_outline = 2.5
                elseif is_target then
                    slot_bg = G.C.BLACK
                    slot_border = G.C.GOLD
                    slot_outline = 2
                end
            end

            local foot_label = nil
            if session.stage == 'reveal' then
                foot_label = is_target and { text = "TARGET", col = G.C.GOLD } or { text = jk.name, col = G.C.UI.TEXT_LIGHT }
            elseif session.stage == 'shuffling' then
                foot_label = { text = "Slot " .. i, col = G.C.UI.TEXT_INACTIVE }
            elseif session.stage == 'active' then
                foot_label = { text = "Select", col = G.C.GOLD }
            elseif session.stage == 'result' then
                if is_picked then
                    foot_label = { text = session.won and "WINNER" or "SELECTED", col = session.won and G.C.GREEN or G.C.RED }
                elseif is_target then
                    foot_label = { text = "TARGET", col = G.C.GOLD }
                else
                    foot_label = { text = jk.name, col = G.C.UI.TEXT_LIGHT }
                end
            end

            table.insert(card_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.04,
                    button = is_clickable and 'shell_game_pick_cup' or nil,
                    ref_table = { cup_idx = i },
                    hover = is_clickable,
                    colour = slot_bg,
                    emboss = 0.06,
                    r = 0.10,
                    outline = slot_outline,
                    outline_colour = slot_border,
                    shadow = is_clickable or is_shaking
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = sprite_node and { sprite_node } or {
                            { n = G.UIT.T, config = { text = is_face_down and "[ ? ]" or jk.name, scale = 0.35, colour = G.C.WHITE, shadow = true } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", minh = 0.32, padding = 0.02 },
                        nodes = {
                            { n = G.UIT.T, config = { text = foot_label.text, scale = 0.20, maxw = 1.25, colour = foot_label.col, shadow = true } }
                        }
                    }
                }
            })
        end

        local prize_nodes = {}
        local prizes = {
            { key = 'money', label = "$12 Cash", col = G.C.GOLD },
            { key = 'tarot', label = "Tarot Card", col = G.C.PURPLE },
            { key = 'hands', label = "+1 Hand & Discard", col = G.C.BLUE },
            { key = 'mult', label = "+15 Joker Mult", col = G.C.RED },
        }

        for _, p in ipairs(prizes) do
            local is_sel = (session.target_prize == p.key)
            local btn_col = is_sel and p.col or G.C.UI.BACKGROUND_INACTIVE
            local p_btn = {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.06,
                    minw = 1.9,
                    minh = 0.55,
                    r = 0.08,
                    colour = btn_col,
                    emboss = 0.08,
                    hover = (session.stage == 'reveal'),
                    shadow = true,
                    button = (session.stage == 'reveal') and 'shell_game_set_prize' or nil,
                    ref_table = { prize = p.key }
                },
                nodes = {
                    { n = G.UIT.T, config = { text = p.label, scale = 0.32, colour = is_sel and G.C.WHITE or G.C.UI.TEXT_INACTIVE, shadow = is_sel } }
                }
            }
            table.insert(prize_nodes, { n = G.UIT.C, config = { align = "cm", padding = 0.04 }, nodes = { p_btn } })
        end

        local bottom_action_node = nil
        if session.stage == 'result' then
            bottom_action_node = {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    UIBox_button({
                        label = {"Play Again"},
                        button = 'shell_game_reset_and_play',
                        colour = G.C.GREEN,
                        minw = 2.8,
                        minh = 0.65,
                        scale = 0.40,
                        emboss = 0.08,
                        col = true
                    }),
                    { n = G.UIT.B, config = { w = 0.3, h = 0.1 } },
                    UIBox_button({
                        label = {"Collect & Return"},
                        button = 'exit_overlay_menu',
                        colour = G.C.BLUE,
                        minw = 3.0,
                        minh = 0.65,
                        scale = 0.40,
                        emboss = 0.08,
                        col = true
                    })
                }
            }
        elseif session.stage == 'reveal' then
            bottom_action_node = {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    UIBox_button({
                        label = {"Shuffle Jokers"},
                        button = 'shell_game_start_shuffle',
                        colour = G.C.ORANGE,
                        minw = 4.4,
                        minh = 0.75,
                        scale = 0.44,
                        emboss = 0.08,
                        col = true
                    })
                }
            }
        elseif session.stage == 'shuffling' then
            bottom_action_node = {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            padding = 0.08,
                            minw = 4.4,
                            minh = 0.75,
                            r = 0.1,
                            colour = G.C.L_BLACK,
                            emboss = 0.08,
                            outline = 2,
                            outline_colour = G.C.ORANGE
                        },
                        nodes = {
                            { n = G.UIT.T, config = { text = "SHUFFLING JOKERS...", scale = 0.40, colour = G.C.ORANGE, shadow = true } }
                        }
                    }
                }
            }
        else
            bottom_action_node = {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Select one of the face-down cards from the tray above!", scale = 0.36, colour = G.C.GOLD, shadow = true } }
                }
            }
        end

        local cur_mult = (session.card and session.card.ability and session.card.ability.extra and session.card.ability.extra.mult) or 12
        local target_name = session.target_joker and session.target_joker.name or "Joker"

        return {
            n = G.UIT.ROOT,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.06 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "THE SHELL GAME", scale = 0.54, colour = G.C.GOLD, shadow = true } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.04 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                                padding = 0.08,
                                r = 0.1,
                                colour = G.C.L_BLACK,
                                emboss = 0.08,
                                outline = 2,
                                outline_colour = G.C.GOLD
                            },
                            nodes = {
                                { n = G.UIT.T, config = { text = "FIND THIS JOKER:  " .. string.upper(target_name), scale = 0.40, colour = G.C.WHITE, shadow = true } }
                            }
                        }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Current Joker Mult: +" .. cur_mult, scale = 0.32, colour = G.C.MULT } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Choose Reward to Play For:", scale = 0.32, colour = G.C.GOLD } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.04 },
                    nodes = prize_nodes
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.06 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                                padding = 0.10,
                                r = 0.14,
                                colour = G.C.L_BLACK,
                                emboss = 0.08,
                                outline = 2,
                                outline_colour = (session.stage == 'shuffling' and G.C.ORANGE) or (session.stage == 'active' and G.C.GOLD) or G.C.BLACK,
                                shadow = true
                            },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = "JOKERS (5 / 5)", scale = 0.28, colour = G.C.UI.TEXT_LIGHT } },
                                        { n = G.UIT.B, config = { w = 0.4, h = 0.1 } },
                                        { n = G.UIT.T, config = { text = session.status_text or "", scale = 0.30, colour = G.C.GOLD, shadow = true } }
                                    }
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.06 },
                                    nodes = card_nodes
                                },
                                (session.stage == 'result' and {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.04 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = session.result_msg or "", scale = 0.36, colour = session.won and G.C.GREEN or G.C.RED, shadow = true } }
                                    }
                                } or { n = G.UIT.R, config = { align = "cm" }, nodes = {} })
                            }
                        }
                    }
                },
                bottom_action_node
            }
        }
    end

    G.UIDEF.shell_game_overlay = function()
        local session = G.GAME and G.GAME.reality_warp_shell_session
        if not session then return {} end

        return create_UIBox_generic_options({
            back_func = 'exit_overlay_menu',
            contents = {
                {
                    n = G.UIT.O,
                    config = {
                        id = 'shell_game_contents',
                        object = UIBox{
                            definition = G.UIDEF.shell_game_inner_content(),
                            config = { offset = { x = 0, y = 0 }, align = 'cm' }
                        },
                        align = 'cm'
                    }
                }
            }
        })
    end

    G.FUNCS.shell_game_play = function(e)
        local card = e.config.ref_table
        if not card or not card.ability or not card.ability.extra then return end
        if card.ability.extra.played_this_round or card.debuff or G.STATE ~= G.STATES.SELECTING_HAND then return end
        card.ability.extra.played_this_round = true
        if e.UIBox then e.UIBox:recalculate(true) end

        local jokers, target_joker = roll_acorn_round()

        G.GAME.reality_warp_shell_session = {
            card = card,
            target_prize = card.ability.extra.target_prize or 'money',
            stage = 'reveal',
            status_text = "FIND THIS JOKER: ★ " .. string.upper(target_joker.name) .. " ★",
            jokers = jokers,
            target_joker = target_joker,
            picked_idx = nil,
            result_msg = "",
            won = false,
        }

        play_sound('tarot2', 1.1, 0.8)
        if create_UIBox_generic_options and G.FUNCS.overlay_menu then
            G.FUNCS.overlay_menu{ definition = G.UIDEF.shell_game_overlay() }
        else
            play_sound('gold_seal', 1.2, 0.9)
            card:juice_up(0.6, 0.4)
        end
    end

    G.FUNCS.can_claw_machine_play = function(e)
        local card = e.config.ref_table
        if card and card.ability and card.ability.extra then
            local ex = card.ability.extra
            local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
            local cost = ex.cost or 2
            local can_play = not ex.played_this_round and not card.debuff and cur_d >= cost and (G.STATE == G.STATES.SELECTING_HAND)
            if can_play then
                e.config.colour = G.C.ORANGE
                e.config.button = 'claw_machine_play'
            else
                e.config.colour = G.C.UI.BACKGROUND_INACTIVE
                e.config.button = nil
            end
        end
    end

    local function update_claw_machine_ui()
        if not (G.OVERLAY_MENU and G.OVERLAY_MENU.get_UIE_by_ID) then return end
        local e = G.OVERLAY_MENU:get_UIE_by_ID('claw_machine_contents')
        if e then
            if e.config.object then
                e.config.object:remove()
                e.config.object = nil
            end
            e.config.object = UIBox{
                definition = G.UIDEF.claw_machine_inner_content(),
                config = { offset = { x = 0, y = 0 }, align = 'cm', parent = e }
            }
            if G.OVERLAY_MENU.recalculate then
                G.OVERLAY_MENU:recalculate()
            end
        else
            if G.OVERLAY_MENU then G.FUNCS.overlay_menu{ definition = G.UIDEF.claw_machine_overlay() } end
        end
    end

    G.FUNCS.claw_machine_aim_left = function(e)
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if session and session.stage == 'aim' then
            if (session.crane_pos or 4) > 1 then
                session.crane_pos = session.crane_pos - 1
                play_sound('cardSlide1', 1.25, 0.6)
                update_claw_machine_ui()
            else
                play_sound('cancel', 1.3, 0.3)
            end
        end
    end

    G.FUNCS.claw_machine_aim_right = function(e)
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if session and session.stage == 'aim' then
            if (session.crane_pos or 4) < 7 then
                session.crane_pos = session.crane_pos + 1
                play_sound('cardSlide1', 1.25, 0.6)
                update_claw_machine_ui()
            else
                play_sound('cancel', 1.3, 0.3)
            end
        end
    end

    G.FUNCS.claw_machine_anchor = function(e)
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if not session or session.stage ~= 'aim' then return end

        session.stage = 'anchored'
        session.drop_depth = 2
        session.status_text = "CLAW ANCHORED TO BOX #" .. (session.crane_pos or 4) .. "! CLICK 'PULL UP! (JALAR)' TO RETRIEVE IT!"
        play_sound('chips1', 1.2, 0.9)
        play_sound('button', 0.9, 0.9)
        update_claw_machine_ui()
    end

    G.FUNCS.claw_machine_reaim = function(e)
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if not session or session.stage ~= 'anchored' then return end

        session.stage = 'aim'
        session.drop_depth = 0
        session.status_text = "Select any surprise box to anchor the claw!"
        play_sound('cardSlide1', 1.1, 0.8)
        update_claw_machine_ui()
    end

    G.FUNCS.claw_machine_select_slot = function(e)
        local slot = e.config.ref_table and e.config.ref_table.slot
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if session and session.stage == 'aim' and slot then
            session.crane_pos = slot
            G.FUNCS.claw_machine_anchor()
        end
    end

    G.FUNCS.claw_machine_pull = function(e)
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if not session or session.stage ~= 'anchored' then return end

        session.stage = 'pulling'
        session.drop_depth = 1
        session.status_text = "HEAVING CRANE UPWARD! Pulling surprise box toward the chute..."
        play_sound('cardSlide2', 0.95, 0.8)
        update_claw_machine_ui()

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.45,
            func = function()
                if not (G.GAME and G.GAME.reality_warp_claw_session) then return true end
                local sess = G.GAME.reality_warp_claw_session
                sess.drop_depth = 0
                sess.status_text = "Box reached collection chute! Inspecting contents..."
                play_sound('cardSlide1', 1.15, 0.8)
                update_claw_machine_ui()
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.45,
            func = function()
                if not (G.GAME and G.GAME.reality_warp_claw_session) then return true end
                local sess = G.GAME.reality_warp_claw_session
                sess.stage = 'result'
                sess.drop_depth = 0
                local target = sess.prizes[sess.crane_pos]
                local card = sess.card

                if target.type == 'empty' then
                    sess.won = false
                    sess.outcome = 'empty'
                    sess.result_msg = "EMPTY BOX! You pulled the box up, but there was nothing inside!"
                    play_sound('cancel', 0.9, 0.9)
                    if card then card:juice_up(0.3, 0.2) end
                elseif target.type == 'jackpot' then
                    local roll = pseudorandom('claw_jackpot', 1, 100)
                    if roll == 1 and G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                        sess.won = true
                        sess.outcome = 'obtained'
                        local leg = create_card('Joker', G.jokers, true, nil, nil, nil, nil, 'claw_leg')
                        leg:add_to_deck()
                        G.jokers:emplace(leg)
                        sess.result_msg = "JACKPOT! OBTAINED LEGENDARY JOKER (" .. (leg.ability.name or "Legendary") .. ")!"
                        play_sound('timpani', 1.2, 0.9)
                        if card then card:juice_up(0.8, 0.5) end
                    elseif roll <= 35 then
                        sess.won = true
                        sess.outcome = 'obtained'
                        ease_dollars(20)
                        sess.result_msg = "OBTAINED! You pulled the Golden Crown and won $20 Cash!"
                        play_sound('timpani', 1.2, 0.9)
                        if card then card:juice_up(0.7, 0.4) end
                    elseif roll <= 80 then
                        sess.won = false
                        sess.outcome = 'slipped'
                        sess.result_msg = "SLIPPED! The heavy Golden Crown slipped from the claw's grasp and dropped back!"
                        play_sound('cancel', 1.0, 0.8)
                        if card then card:juice_up(0.3, 0.2) end
                    else
                        sess.won = false
                        sess.outcome = 'empty'
                        sess.result_msg = "EMPTY BOX! You hauled the Golden Crown box up, but it was hollow inside!"
                        play_sound('cancel', 0.9, 0.9)
                        if card then card:juice_up(0.3, 0.2) end
                    end
                else
                    local roll = pseudorandom('claw_grip', 1, 100)
                    if roll <= 65 then
                        sess.won = true
                        sess.outcome = 'obtained'
                        if target.type == 'tarot' then
                            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                                local tcard = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'claw_tarot')
                                tcard:add_to_deck()
                                G.consumeables:emplace(tcard)
                                sess.result_msg = "OBTAINED! You pulled Tarot Card: " .. (tcard.ability.name or "Tarot") .. "!"
                            else
                                ease_dollars(6)
                                sess.result_msg = "OBTAINED! (Consumables full: awarded $6)!"
                            end
                        elseif target.type == 'spectral' then
                            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                                local scard = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'claw_spec')
                                scard:add_to_deck()
                                G.consumeables:emplace(scard)
                                sess.result_msg = "OBTAINED! You pulled Spectral Card: " .. (scard.ability.name or "Spectral") .. "!"
                            else
                                ease_dollars(8)
                                sess.result_msg = "OBTAINED! (Consumables full: awarded $8)!"
                            end
                        elseif target.type == 'planet' then
                            if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                                local pcard = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'claw_planet')
                                pcard:add_to_deck()
                                G.consumeables:emplace(pcard)
                                sess.result_msg = "OBTAINED! You pulled Planet Card: " .. (pcard.ability.name or "Planet") .. "!"
                            else
                                ease_dollars(6)
                                sess.result_msg = "OBTAINED! (Consumables full: awarded $6)!"
                            end
                        elseif target.type == 'joker' then
                            if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                                local jk = create_card('Joker', G.jokers, nil, 1, nil, nil, nil, 'claw_jk')
                                jk:add_to_deck()
                                G.jokers:emplace(jk)
                                sess.result_msg = "OBTAINED! You pulled Joker: " .. (jk.ability.name or "Joker") .. "!"
                            else
                                ease_dollars(8)
                                sess.result_msg = "OBTAINED! (Jokers full: awarded $8)!"
                            end
                        end
                        play_sound('timpani', 1.2, 0.9)
                        if card then card:juice_up(0.7, 0.4) end
                    elseif roll <= 88 then
                        sess.won = false
                        sess.outcome = 'slipped'
                        sess.result_msg = "SLIPPED! The claw lost its grip as it reached the chute!"
                        play_sound('cancel', 1.0, 0.8)
                        if card then card:juice_up(0.3, 0.2) end
                    else
                        sess.won = false
                        sess.outcome = 'empty'
                        sess.result_msg = "EMPTY BOX! You hauled the surprise box up, but there was nothing inside!"
                        play_sound('cancel', 0.9, 0.9)
                        if card then card:juice_up(0.3, 0.2) end
                    end
                end

                if notify_minigame_completed then
                    notify_minigame_completed('claw_machine')
                end

                update_claw_machine_ui()
                return true
            end
        }))
    end

    G.UIDEF.claw_machine_inner_content = function()
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if not session then return { n = G.UIT.ROOT, config = { align = "cm", colour = G.C.CLEAR }, nodes = {} } end

        local crane_pos = session.crane_pos or 4
        local depth = session.drop_depth or 0
        local stage = session.stage or 'aim'

        local make_claw_joker_sprite = function(w, h)
            local jk_atlas = (SMODS and SMODS.Atlases and SMODS.Atlases['reality_warp_jokers']) or (G.ASSET_ATLAS and G.ASSET_ATLAS['reality_warp_jokers'])
            if jk_atlas and Moveable and Sprite then
                local icon_view = Moveable(0, 0, w or 0.65, h or 0.85)
                icon_view.icon_sprite = Sprite(0, 0, w or 0.65, h or 0.85, jk_atlas, { x = 3, y = 11 })
                function icon_view:draw()
                    if self.icon_sprite then
                        self.icon_sprite.T.x = self.T.x
                        self.icon_sprite.T.y = self.T.y
                        self.icon_sprite:draw()
                    end
                    add_to_drawhash(self)
                end
                return { n = G.UIT.O, config = { object = icon_view } }
            end
            return nil
        end

        local title_nodes = {}
        local title_joker = make_claw_joker_sprite(0.60, 0.78)
        if title_joker then
            table.insert(title_nodes, title_joker)
            table.insert(title_nodes, { n = G.UIT.B, config = { w = 0.2, h = 0.5 } })
        end
        table.insert(title_nodes, { n = G.UIT.T, config = { text = "THE CLAW MACHINE", scale = 0.55, colour = G.C.GOLD, shadow = true } })

        local track_nodes = {}
        for i = 1, 7 do
            local is_crane = (i == crane_pos)
            local track_inner = {}

            if is_crane then
                if depth == 0 then
                    local spr = make_claw_joker_sprite(0.48, 0.62)
                    if spr then
                        table.insert(track_inner, { n = G.UIT.R, config = { align = "cm" }, nodes = { spr } })
                    else
                        table.insert(track_inner, { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = "CLAW", scale = 0.24, colour = G.C.GOLD, shadow = true } } } })
                    end
                else
                    table.insert(track_inner, { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = {
                        { n = G.UIT.B, config = { w = 0.10, h = 0.35, colour = G.C.WHITE, r = 0.02, emboss = 0.04 } }
                    } })
                    table.insert(track_inner, { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = "DROP", scale = 0.18, colour = G.C.GOLD, shadow = true } } } })
                end
            else
                table.insert(track_inner, {
                    n = G.UIT.R,
                    config = { align = "cm" },
                    nodes = {
                        {
                            n = G.UIT.B,
                            config = {
                                w = 0.85,
                                h = 0.08,
                                colour = G.C.L_BLACK,
                                r = 0.04
                            }
                        }
                    }
                })
            end

            table.insert(track_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.02,
                    minw = 1.18,
                    minh = 0.85,
                    colour = is_crane and G.C.BLACK or G.C.L_BLACK,
                    emboss = 0.05,
                    r = 0.08,
                    outline = is_crane and 2 or 1,
                    outline_colour = is_crane and G.C.GOLD or G.C.BLACK
                },
                nodes = track_inner
            })
        end

        local pit_nodes = {}
        for i = 1, 7 do
            local p = session.prizes and session.prizes[i]
            local pal = (p and p.palette) or {
                bg = G.C.BLACK,
                border = G.C.L_BLACK,
                slot_bg = G.C.BLACK
            }
            local is_targeted = (i == crane_pos)
            local is_result = (stage == 'result')
            local is_revealed = is_result

            local box_inner = {}

            table.insert(box_inner, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.02 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Box " .. i, scale = 0.24, colour = is_targeted and G.C.GOLD or G.C.UI.TEXT_LIGHT, shadow = is_targeted } }
                }
            })

            if not is_revealed then
                if is_targeted then
                    local target_tag = "TARGET"
                    if stage == 'anchored' then target_tag = "LOCKED"
                    elseif stage == 'pulling' then target_tag = "PULLING" end
                    table.insert(box_inner, {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = { { n = G.UIT.T, config = { text = target_tag, scale = 0.16, colour = G.C.GOLD, shadow = true } } }
                    })
                else
                    table.insert(box_inner, {
                        n = G.UIT.B,
                        config = { w = 0.1, h = 0.16 }
                    })
                end

                table.insert(box_inner, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.03 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "?", scale = 0.65, colour = is_targeted and G.C.GOLD or G.C.WHITE, shadow = true } }
                    }
                })

                table.insert(box_inner, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "PRIZE", scale = 0.18, colour = is_targeted and G.C.GOLD or G.C.UI.TEXT_LIGHT, shadow = is_targeted } }
                    }
                })

                table.insert(box_inner, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.03 },
                    nodes = {
                        { n = G.UIT.T, config = {
                            text = is_targeted and (stage == 'aim' and "READY" or (stage == 'anchored' and "LOCKED" or "HAULING")) or (stage == 'aim' and "SELECT" or "LOCKED"),
                            scale = 0.15,
                            colour = is_targeted and G.C.GOLD or G.C.UI.TEXT_INACTIVE
                        } }
                    }
                })
            else
                local is_empty = (p and p.type == 'empty')
                local tag_txt = is_targeted and (session.won and "OBTAINED" or (session.outcome == 'slipped' and "SLIPPED" or "EMPTY")) or (is_empty and "EMPTY" or "PRIZE")
                local tag_col = is_targeted and (session.won and G.C.GREEN or G.C.RED) or G.C.UI.TEXT_LIGHT

                table.insert(box_inner, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = { { n = G.UIT.T, config = { text = tag_txt, scale = 0.16, colour = tag_col, shadow = is_targeted } } }
                })

                table.insert(box_inner, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = is_empty and "-" or "+", scale = 0.38, colour = is_targeted and (session.won and G.C.GOLD or G.C.WHITE) or G.C.WHITE, shadow = true } }
                    }
                })

                table.insert(box_inner, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = p and p.name or "Box", scale = 0.18, maxw = 1.05, colour = G.C.WHITE, shadow = true } }
                    }
                })

                if p and p.sub and p.sub ~= "" then
                    table.insert(box_inner, {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.01 },
                        nodes = {
                            { n = G.UIT.T, config = { text = p.sub, scale = 0.14, maxw = 1.05, colour = G.C.UI.TEXT_LIGHT } }
                        }
                    })
                end
            end

            table.insert(pit_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.02,
                    button = (stage == 'aim' and 'claw_machine_select_slot' or nil),
                    ref_table = { slot = i },
                    hover = (stage == 'aim')
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            padding = 0.06,
                            minw = 1.18,
                            minh = 2.45,
                            r = 0.10,
                            colour = G.C.BLACK,
                            emboss = 0.06,
                            outline = is_targeted and 2 or 1.2,
                            outline_colour = is_targeted and (is_result and (session.won and G.C.GOLD or G.C.RED) or G.C.GOLD) or G.C.L_BLACK,
                            shadow = true
                        },
                        nodes = box_inner
                    }
                }
            })
        end

        local control_nodes = {}
        if stage == 'aim' then
            table.insert(control_nodes, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    UIBox_button({
                        label = { "< Left" },
                        button = 'claw_machine_aim_left',
                        colour = G.C.BLUE,
                        minw = 1.8,
                        minh = 0.65,
                        scale = 0.36,
                        emboss = 0.08,
                        col = true
                    }),
                    { n = G.UIT.B, config = { w = 0.2, h = 0.6 } },
                    UIBox_button({
                        label = { "ANCHOR CLAW" },
                        button = 'claw_machine_anchor',
                        colour = G.C.GREEN,
                        minw = 3.0,
                        minh = 0.65,
                        scale = 0.38,
                        emboss = 0.08,
                        col = true
                    }),
                    { n = G.UIT.B, config = { w = 0.2, h = 0.6 } },
                    UIBox_button({
                        label = { "Right >" },
                        button = 'claw_machine_aim_right',
                        colour = G.C.BLUE,
                        minw = 1.8,
                        minh = 0.65,
                        scale = 0.36,
                        emboss = 0.08,
                        col = true
                    })
                }
            })
        elseif stage == 'anchored' then
            table.insert(control_nodes, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    UIBox_button({
                        label = { "PULL UP!" },
                        button = 'claw_machine_pull',
                        colour = G.C.GREEN,
                        minw = 3.2,
                        minh = 0.70,
                        scale = 0.42,
                        emboss = 0.08,
                        col = true
                    }),
                    { n = G.UIT.B, config = { w = 0.3, h = 0.6 } },
                    UIBox_button({
                        label = { "Cancel" },
                        button = 'claw_machine_reaim',
                        colour = G.C.ORANGE,
                        minw = 2.4,
                        minh = 0.70,
                        scale = 0.35,
                        emboss = 0.08,
                        col = true
                    })
                }
            })
        elseif stage == 'pulling' then
            table.insert(control_nodes, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.06 },
                nodes = {
                    { n = G.UIT.T, config = { text = "Heaving crane arm upward...", scale = 0.36, colour = G.C.GOLD, shadow = true } }
                }
            })
        elseif stage == 'result' then
            table.insert(control_nodes, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    UIBox_button({
                        label = { "Collect & Continue" },
                        button = 'exit_overlay_menu',
                        colour = G.C.BLUE,
                        minw = 3.6,
                        minh = 0.65,
                        scale = 0.40,
                        emboss = 0.08,
                        col = true
                    })
                }
            })
        end

        return {
            n = G.UIT.ROOT,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.08 },
                    nodes = title_nodes
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.04 },
                    nodes = {
                        { n = G.UIT.T, config = { text = "Position the claw over a prize box, then click 'PULL UP' to haul it!", scale = 0.34, colour = G.C.WHITE, shadow = true } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.08 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                align = "cm",
                                padding = 0.12,
                                r = 0.12,
                                colour = G.C.L_BLACK,
                                emboss = 0.08,
                                outline = 2,
                                outline_colour = G.C.BLACK
                            },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.03 },
                                    nodes = track_nodes
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.04 },
                                    nodes = pit_nodes
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.06 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = session.status_text or "", scale = 0.34, colour = G.C.GOLD, shadow = true } }
                                    }
                                },
                                (stage == 'result' and {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.06 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = session.result_msg or "", scale = 0.38, colour = session.won and G.C.GREEN or G.C.RED, shadow = true } }
                                    }
                                } or { n = G.UIT.R, config = { align = "cm" }, nodes = {} })
                            }
                        }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.04 },
                    nodes = control_nodes
                }
            }
        }
    end

    G.UIDEF.claw_machine_overlay = function()
        local session = G.GAME and G.GAME.reality_warp_claw_session
        if not session then return {} end

        return create_UIBox_generic_options({
            back_func = 'exit_overlay_menu',
            contents = {
                {
                    n = G.UIT.O,
                    config = {
                        id = 'claw_machine_contents',
                        object = UIBox{
                            definition = G.UIDEF.claw_machine_inner_content(),
                            config = { offset = { x = 0, y = 0 }, align = 'cm' }
                        },
                        align = 'cm'
                    }
                }
            }
        })
    end

    G.FUNCS.claw_machine_play = function(e)
        local card = e.config.ref_table
        if not card or not card.ability or not card.ability.extra then return end
        local ex = card.ability.extra
        if G.STATE ~= G.STATES.SELECTING_HAND or ex.played_this_round or card.debuff then return end
        local cost = ex.cost or 2
        local cur_d = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
        if cur_d < cost then return end

        ease_dollars(-cost)
        ex.played_this_round = true
        if e.UIBox then e.UIBox:recalculate(true) end

        local prizes = {
            { id = 1, type = 'tarot', name = "Tarot Card", sub = "Random Tarot", col = G.C.PURPLE, icon = "TAROT" },
            { id = 2, type = 'spectral', name = "Spectral Card", sub = "Rare Spectral", col = { 0.15, 0.65, 0.85, 1 }, icon = "SPECTRAL" },
            { id = 3, type = 'planet', name = "Planet Card", sub = "Hand Upgrade", col = { 0.18, 0.72, 0.52, 1 }, icon = "PLANET" },
            { id = 4, type = 'joker', name = "Mystery Joker", sub = "Random Joker", col = { 0.85, 0.35, 0.25, 1 }, icon = "JOKER" },
            { id = 5, type = 'jackpot', name = "Golden Crown", sub = "1% Leg. / $20", col = G.C.GOLD, icon = "CROWN" },
            { id = 6, type = 'empty', name = "Empty Box", sub = "Nothing Inside", col = { 0.45, 0.45, 0.50, 1 }, icon = "EMPTY" },
            { id = 7, type = 'empty', name = "Empty Box", sub = "Nothing Inside", col = { 0.45, 0.45, 0.50, 1 }, icon = "EMPTY" },
        }

        local capsule_palettes = {
            { bg = { 0.82, 0.15, 0.40, 0.95 }, border = { 1.0, 0.55, 0.75, 1 }, slot_bg = { 0.18, 0.11, 0.15, 0.95 } },  -- Neon Pink
            { bg = { 0.08, 0.55, 0.88, 0.95 }, border = { 0.45, 0.85, 1.0, 1 }, slot_bg = { 0.09, 0.14, 0.20, 0.95 } },  -- Electric Cyan
            { bg = { 0.14, 0.70, 0.32, 0.95 }, border = { 0.50, 0.98, 0.60, 1 }, slot_bg = { 0.10, 0.18, 0.12, 0.95 } },  -- Emerald Green
            { bg = { 0.90, 0.50, 0.08, 0.95 }, border = { 1.0, 0.78, 0.32, 1 }, slot_bg = { 0.20, 0.14, 0.08, 0.95 } },  -- Tangerine Orange
            { bg = { 0.55, 0.18, 0.85, 0.95 }, border = { 0.85, 0.55, 1.0, 1 }, slot_bg = { 0.16, 0.10, 0.22, 0.95 } },  -- Royal Purple
            { bg = { 0.85, 0.18, 0.18, 0.95 }, border = { 1.0, 0.50, 0.45, 1 }, slot_bg = { 0.20, 0.10, 0.10, 0.95 } },  -- Crimson Red
            { bg = { 0.08, 0.70, 0.68, 0.95 }, border = { 0.45, 0.98, 0.95, 1 }, slot_bg = { 0.08, 0.17, 0.18, 0.95 } },  -- Turquoise Teal
            { bg = { 0.82, 0.68, 0.10, 0.95 }, border = { 1.0, 0.92, 0.40, 1 }, slot_bg = { 0.20, 0.18, 0.08, 0.95 } },  -- Golden Yellow
        }

        for i = #prizes, 2, -1 do
            local j = pseudorandom('claw_pos_' .. i, 1, i)
            prizes[i], prizes[j] = prizes[j], prizes[i]
        end

        for i = #capsule_palettes, 2, -1 do
            local j = pseudorandom('claw_pal_' .. i, 1, i)
            capsule_palettes[i], capsule_palettes[j] = capsule_palettes[j], capsule_palettes[i]
        end
        for i = 1, #prizes do
            prizes[i].palette = capsule_palettes[i]
        end

        G.GAME.reality_warp_claw_session = {
            card = card,
            crane_pos = 4,
            drop_depth = 0,
            stage = 'aim',
            prizes = prizes,
            status_text = "Select any surprise box to anchor the claw!",
            result_msg = "",
            won = false,
        }

        play_sound('tarot2', 1.1, 0.8)
        if create_UIBox_generic_options and G.FUNCS.overlay_menu then
            G.FUNCS.overlay_menu{ definition = G.UIDEF.claw_machine_overlay() }
        else
            play_sound('gold_seal', 1.2, 0.9)
            card:juice_up(0.6, 0.4)
        end
    end
end

function is_reality_warp_spectrals_jobs_enabled()
    if G and G.GAME and G.GAME.reality_warp_spectrals_jobs ~= nil then
        return G.GAME.reality_warp_spectrals_jobs
    end
    local cfg = (get_reality_warp_config and get_reality_warp_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    if cfg.new_spectrals_and_jobs ~= nil then
        return cfg.new_spectrals_and_jobs
    end
    return true
end

function is_reality_warp_boss_blinds_enabled()
    if G and G.GAME and G.GAME.reality_warp_boss_blinds ~= nil then
        return G.GAME.reality_warp_boss_blinds
    end
    local cfg = (get_reality_warp_config and get_reality_warp_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    if cfg.new_boss_blinds ~= nil then
        return cfg.new_boss_blinds
    end
    return true
end

function is_reality_warp_fast_animations_enabled()
    local cfg = (get_reality_warp_config and get_reality_warp_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
        or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
        or {}
    return cfg.fast_animations == true
end

if SMODS and SMODS.Blind then
    local orig_blind_in_pool = SMODS.Blind.in_pool
    function SMODS.Blind:in_pool(args)
        if (self.mod and self.mod.id == 'reality_warp') or (self.key and G.reality_warp_BLIND_THEMES and G.reality_warp_BLIND_THEMES[self.key]) then
            if not is_reality_warp_boss_blinds_enabled() then
                return false
            end
        end
        if orig_blind_in_pool then
            return orig_blind_in_pool(self, args)
        end
        return true
    end
end

if Game and Game.init_game_object then
    local orig_game_init_game_object = Game.init_game_object
    function Game:init_game_object(args)
        local ret = orig_game_init_game_object(self, args)
        local cfg = (get_reality_warp_config and get_reality_warp_config())
            or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
            or (SMODS and SMODS.current_mod and SMODS.current_mod.config)
            or {}

        if self.GAME and self.GAME.reality_warp_spectrals_jobs == nil then
            self.GAME.reality_warp_spectrals_jobs = (cfg.new_spectrals_and_jobs ~= false)
        end

        if self.GAME and self.GAME.reality_warp_boss_blinds == nil then
            self.GAME.reality_warp_boss_blinds = (cfg.new_boss_blinds ~= false)
        end

        if cfg.new_runs and self.GAME and self.GAME.pseudorandom and self.GAME.pseudorandom.seed then
            local mod_salt = "_WITCH"
            if not string.find(self.GAME.pseudorandom.seed, mod_salt, 1, true) then
                self.GAME.pseudorandom.seed = self.GAME.pseudorandom.seed .. mod_salt
                if pseudohash then
                    self.GAME.pseudorandom.hashed_seed = pseudohash(self.GAME.pseudorandom.seed)
                    for k, _ in pairs(self.GAME.pseudorandom) do
                        if k ~= 'seed' and k ~= 'hashed_seed' then
                            self.GAME.pseudorandom[k] = pseudohash(k .. self.GAME.pseudorandom.seed)
                        end
                    end
                end
            end
        end

        return ret
    end
end

function apply_reality_warp_intro_bg(force)
    local cfg = (get_reality_warp_config and get_reality_warp_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
        or {}
    if force or cfg.custom_menu_bg ~= false then
        G.C.WARP_BG_BLACK = G.C.WARP_BG_BLACK or HEX('08080a')
        G.C.WARP_BG_RED = G.C.WARP_BG_RED or HEX('b31010')
        if G.SPLASH_BACK then
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                    {name = 'vort_speed', val = 0.4},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'WARP_BG_BLACK'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'WARP_BG_RED'},
                    {name = 'mid_flash', ref_table = {mid_flash = 0}, ref_value = 'mid_flash'},
                    {name = 'vort_offset', val = 0},
                }
            }})
        end
        if ease_background_colour then
            ease_background_colour{
                new_colour = G.C.WARP_BG_BLACK,
                special_colour = G.C.WARP_BG_RED,
                contrast = 2.5
            }
        end
    end
end

function apply_reality_warp_menu_bg(force, change_context)
    local cfg = (get_reality_warp_config and get_reality_warp_config())
        or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
        or {}
    if force or cfg.custom_menu_bg ~= false then
        G.C.WARP_BG_BLACK = G.C.WARP_BG_BLACK or HEX('08080a')
        G.C.WARP_BG_RED = G.C.WARP_BG_RED or HEX('b31010')
        local splash_args = {mid_flash = change_context == 'splash' and 1.6 or 0.}
        if change_context == 'splash' then
            ease_value(splash_args, 'mid_flash', -1.6, nil, nil, nil, 4)
        end
        if G.SPLASH_BACK then
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                    {name = 'vort_speed', val = 0.4},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'WARP_BG_BLACK'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'WARP_BG_RED'},
                    {name = 'mid_flash', ref_table = splash_args, ref_value = 'mid_flash'},
                    {name = 'vort_offset', val = 0},
                }
            }})
        end
        if ease_background_colour then
            ease_background_colour{
                new_colour = G.C.WARP_BG_BLACK,
                special_colour = G.C.WARP_BG_RED,
                contrast = 2.5
            }
        end
    else
        if G.SPLASH_BACK then
            G.SPLASH_BACK:define_draw_steps({{
                shader = 'splash',
                send = {
                    {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                    {name = 'vort_speed', val = 0.4},
                    {name = 'colour_1', ref_table = G.C, ref_value = 'RED'},
                    {name = 'colour_2', ref_table = G.C, ref_value = 'BLUE'},
                    {name = 'mid_flash', ref_table = {mid_flash = 0}, ref_value = 'mid_flash'},
                    {name = 'vort_offset', val = 0},
                }
            }})
        end
        if ease_background_colour then
            ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
        end
    end
end

if Game and Game.splash_screen then
    local orig_splash_screen = Game.splash_screen
    function Game:splash_screen()
        orig_splash_screen(self)
        apply_reality_warp_intro_bg()
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                local mod_jokers = {}
                local mod_enhancements = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Joker' and (string.find(k, 'reality_warp') or string.find(k, 'reality_warp')) then
                        table.insert(mod_jokers, v)
                    elseif v.set == 'Enhanced' and (string.find(k, 'reality_warp') or string.find(k, 'reality_warp')) then
                        table.insert(mod_enhancements, v)
                    end
                end
                local mod_seals = { 'reality_warp_dark_green', 'reality_warp_white', 'reality_warp_silver' }

                make_splash_card = function(args)
                    args = args or {}
                    local angle = math.random() * 2 * 3.14
                    local card_size = (args.scale or 1.5) * (math.random() + 1)
                    local card_pos = args.card_pos or {
                        x = (18 + card_size) * math.sin(angle),
                        y = (18 + card_size) * math.cos(angle)
                    }

                    local card = nil
                    if #mod_jokers > 0 and math.random() < 0.3 then
                        local chosen_joker = pseudorandom_element(mod_jokers)
                        card = Card(
                            card_pos.x + G.ROOM.T.w / 2 - G.CARD_W * card_size / 2,
                            card_pos.y + G.ROOM.T.h / 2 - G.CARD_H * card_size / 2,
                            card_size * G.CARD_W, card_size * G.CARD_H,
                            G.P_CARDS.empty,
                            chosen_joker
                        )
                    else
                        local chosen_enh = (#mod_enhancements > 0 and math.random() < 0.75)
                            and pseudorandom_element(mod_enhancements)
                            or G.P_CENTERS.c_base

                        card = Card(
                            card_pos.x + G.ROOM.T.w / 2 - G.CARD_W * card_size / 2,
                            card_pos.y + G.ROOM.T.h / 2 - G.CARD_H * card_size / 2,
                            card_size * G.CARD_W, card_size * G.CARD_H,
                            pseudorandom_element(G.P_CARDS),
                            chosen_enh
                        )

                        if #mod_seals > 0 and math.random() < 0.4 then
                            card:set_seal(pseudorandom_element(mod_seals), true, true)
                        end

                        if math.random() > 0.85 then
                            card.sprite_facing = 'back'
                            card.facing = 'back'
                        end
                    end

                    if math.random() < 0.2 then
                        local ed = pseudorandom_element({ 'foil', 'holo', 'polychrome' })
                        card:set_edition({ [ed] = true }, true, true)
                    end

                    card.no_shadow = true
                    card.states.hover.can = false
                    card.states.drag.can = false
                    card.vortex = true and not args.no_vortex
                    card.T.r = angle
                    return card, card_pos
                end
                return true
            end
        }))
    end
end

if Game and Game.main_menu then
    local orig_game_main_menu = Game.main_menu
    function Game:main_menu(change_context)
        if botg_purge_orphan_familiars then botg_purge_orphan_familiars() end
        orig_game_main_menu(self, change_context)
        if botg_purge_orphan_familiars then botg_purge_orphan_familiars() end
        apply_reality_warp_menu_bg(nil, change_context)
        spawn_main_menu_secret_joker()
    end
end

function spawn_main_menu_secret_joker()
    if not (G and G.title_top and G.title_top.cards) then return end
    if #G.title_top.cards == 0 then
        if G.E_MANAGER then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                blockable = false,
                func = function()
                    spawn_main_menu_secret_joker()
                    return true
                end
            }))
        end
        return
    end
    if G.title_top.cards[1] and G.title_top.cards[1].is_reality_warp_menu_card then
        create_reality_warp_title_label()
        return
    end

    local scale = 1.30
    local card_w = G.CARD_W * scale
    local card_h = G.CARD_H * scale
    G.title_top.config.card_limit = 2
    G.title_top.card_w = card_w
    G.title_top.card_h = card_h
    G.title_top.T.w = card_w * 1.65
    G.title_top.T.h = card_h

    for i = #G.title_top.cards, 1, -1 do
        G.title_top.cards[i]:remove()
    end
    G.title_top.cards = {}

    local ace_suits = { 'S_A', 'H_A', 'C_A', 'D_A' }
    local chosen_ace = ace_suits[math.random(1, #ace_suits)]
    local card_base = (G.P_CARDS and G.P_CARDS[chosen_ace]) or (G.P_CARDS and G.P_CARDS.S_A) or G.P_CARDS.empty
    local ace_card = Card(
        G.title_top.T.x,
        G.title_top.T.y,
        card_w,
        card_h,
        card_base,
        G.P_CENTERS.c_base
    )
    ace_card.is_reality_warp_menu_card = true
    ace_card.facing = 'front'
    ace_card.sprite_facing = 'front'
    ace_card.no_ui = true
    ace_card.states.visible = true
    ace_card.ambient_tilt = 0.4

    local mod_upgrades = {
        function(c)
            local center = G.P_CENTERS and (G.P_CENTERS['m_reality_warp_diamond'] or G.P_CENTERS['m_diamond'])
            if center then c:set_ability(center) end
        end,
        function(c)
            local center = G.P_CENTERS and (G.P_CENTERS['m_reality_warp_jeweled'] or G.P_CENTERS['m_jeweled'])
            if center then c:set_ability(center) end
        end,
        function(c)
            local center = G.P_CENTERS and (G.P_CENTERS['m_reality_warp_lead'] or G.P_CENTERS['m_lead'])
            if center then c:set_ability(center) end
        end,
        function(c)
            local center = G.P_CENTERS and (G.P_CENTERS['m_reality_warp_investment'] or G.P_CENTERS['m_investment'])
            if center then c:set_ability(center) end
        end,
        function(c)
            local seal_key = (G.P_SEALS and G.P_SEALS['reality_warp_dark_green'] and 'reality_warp_dark_green') or 'dark_green'
            c:set_seal(seal_key, true, true)
        end,
        function(c)
            local seal_key = (G.P_SEALS and G.P_SEALS['reality_warp_white'] and 'reality_warp_white') or 'white'
            c:set_seal(seal_key, true, true)
        end,
        function(c)
            local seal_key = (G.P_SEALS and G.P_SEALS['reality_warp_silver'] and 'reality_warp_silver') or 'silver'
            c:set_seal(seal_key, true, true)
        end,
        function(c)
            c:set_edition('e_reality_warp_blessed', true, true)
        end,
        function(c)
            c:set_edition('e_reality_warp_mosaic', true, true)
        end,
    }
    local chosen_upgrade = mod_upgrades[math.random(1, #mod_upgrades)]
    if chosen_upgrade then
        pcall(chosen_upgrade, ace_card)
    end

    local mod_jokers = {}
    if G.P_CENTERS then
        for k, v in pairs(G.P_CENTERS) do
            if v.set == 'Joker' and (string.find(k, '^j_reality_warp_') or (v.mod and (v.mod.id == 'reality_warp' or v.mod.id == 'Balatro: Reality Warp'))) then
                mod_jokers[#mod_jokers + 1] = v
            end
        end
    end
    if #mod_jokers == 0 then
        local fallback_keys = {
            'j_reality_warp_masterful_joker', 'j_reality_warp_outstanding_joker', 'j_reality_warp_blueberry_joker',
            'j_reality_warp_dj_joker', 'j_reality_warp_esteban', 'j_reality_warp_thiago',
            'j_reality_warp_black_hole_joker', 'j_reality_warp_squele', 'j_reality_warp_bluxdir',
            'j_reality_warp_charles', 'j_reality_warp_mochi', 'j_reality_warp_helin',
            'j_reality_warp_raytracing', 'j_reality_warp_paco', 'j_reality_warp_yairo',
            'j_reality_warp_kyra', 'j_reality_warp_brainprint'
        }
        for _, k in ipairs(fallback_keys) do
            if G.P_CENTERS and G.P_CENTERS[k] then
                mod_jokers[#mod_jokers + 1] = G.P_CENTERS[k]
            end
        end
    end
    local chosen_joker_center = (#mod_jokers > 0 and mod_jokers[math.random(1, #mod_jokers)]) or (G.P_CENTERS and G.P_CENTERS.j_joker)

    local joker_card = Card(
        G.title_top.T.x,
        G.title_top.T.y,
        card_w,
        card_h,
        G.P_CARDS.empty,
        chosen_joker_center
    )
    joker_card.is_reality_warp_menu_card = true
    joker_card.facing = 'front'
    joker_card.sprite_facing = 'front'
    joker_card.no_ui = true
    joker_card.states.visible = true
    joker_card.ambient_tilt = 0.4

    if not G.title_top.reality_warp_hooked then
        G.title_top.reality_warp_hooked = true
        local orig_align = G.title_top.align_cards
        G.title_top.align_cards = function(self)
            orig_align(self)
            if #self.cards >= 2 then
                self.cards[1].T.r = self.cards[1].T.r - 0.05
                self.cards[2].T.r = self.cards[2].T.r + 0.05
            end
        end
    end

    G.title_top:emplace(ace_card)
    G.title_top:emplace(joker_card)
    G.title_top:align_cards()
    if G.title_top.hard_set_cards then
        G.title_top:hard_set_cards()
    end

    if set_screen_positions then
        set_screen_positions()
    end
    create_reality_warp_title_label()
end

function create_reality_warp_title_label()
    if G.reality_warp_TITLE_LABEL then
        G.reality_warp_TITLE_LABEL:remove()
        G.reality_warp_TITLE_LABEL = nil
    end
end

local function get_or_load_title_image()
    if G.reality_warp_TITLE_IMAGE then return G.reality_warp_TITLE_IMAGE end
    local nfs = NFS or (SMODS and SMODS.NFS)
    if nfs then
        local raw_path = (reality_warp_MOD and reality_warp_MOD.path) or (SMODS and SMODS.current_mod and SMODS.current_mod.path) or "Mods/Balatro Reality Warp/"
        local mod_path = (string.sub(raw_path, -1) == '/' or string.sub(raw_path, -1) == '\\') and raw_path or (raw_path .. '/')
        local scale = (G.SETTINGS and G.SETTINGS.GRAPHICS and G.SETTINGS.GRAPHICS.texture_scaling) or 2
        local candidates = {
            mod_path .. "assets/" .. scale .. "x/balatro.png",
            mod_path .. "assets/2x/balatro.png",
            mod_path .. "assets/1x/balatro.png"
        }
        for _, full_path in ipairs(candidates) do
            if nfs.getInfo(full_path) then
                local file_data = nfs.newFileData(full_path)
                if file_data then
                    local img_data = love.image.newImageData(file_data)
                    G.reality_warp_TITLE_IMAGE = love.graphics.newImage(img_data, { mipmaps = true, dpiscale = scale })
                    return G.reality_warp_TITLE_IMAGE
                end
            end
        end
    end
    if G.ASSET_ATLAS and G.ASSET_ATLAS["balatro"] and G.ASSET_ATLAS["balatro"].image then
        return G.ASSET_ATLAS["balatro"].image
    end
    return nil
end

function apply_reality_warp_title_asset()
    local title_img = get_or_load_title_image()
    if not title_img then return end

    if G.ASSET_ATLAS and G.ASSET_ATLAS["balatro"] then
        G.ASSET_ATLAS["balatro"].image = title_img
    end

    if G.SPLASH_LOGO and G.SPLASH_LOGO.atlas and G.SPLASH_LOGO.atlas.image ~= title_img then
        G.SPLASH_LOGO.atlas.image = title_img
        G.SPLASH_LOGO:set_sprite_pos({x = 0, y = 0})
    end
end

if Game and Game.update then
    local orig_game_update = Game.update
    function Game:update(dt)
        orig_game_update(self, dt)
        if G.STAGE == G.STAGES.MAIN_MENU and G.SPLASH_LOGO then
            apply_reality_warp_title_asset()
        end
        if G.reality_warp_TITLE_LABEL and (not G.STAGE or G.STAGE ~= G.STAGES.MAIN_MENU) then
            G.reality_warp_TITLE_LABEL:remove()
            G.reality_warp_TITLE_LABEL = nil
        end
        if G.nursery_tab_active and G.OVERLAY_MENU then
            G.nursery_tick_timer = (G.nursery_tick_timer or 0) + dt
            if G.nursery_tick_timer >= 1.0 then
                G.nursery_tick_timer = G.nursery_tick_timer - 1.0
                if G.FUNCS and G.FUNCS.nursery_tick_cooldowns then
                    G.FUNCS.nursery_tick_cooldowns()
                end
            end
        else
            G.nursery_tab_active = false
            G.nursery_tick_timer = 0
        end
    end
end

SMODS.Atlas {
    key = "balatro",
    path = "balatro.png",
    px = 333,
    py = 216,
    prefix_config = { key = false }
}

if Game and Game.main_menu then
    local orig_game_main_menu = Game.main_menu
    function Game:main_menu(change_context)
        apply_reality_warp_title_asset()
        local res = orig_game_main_menu(self, change_context)
        apply_reality_warp_title_asset()
        return res
    end
end

if set_main_menu_UI then
    local orig_set_main_menu_UI = set_main_menu_UI
    function set_main_menu_UI(base_background)
        orig_set_main_menu_UI(base_background)
        apply_reality_warp_menu_bg()
        apply_reality_warp_title_asset()
        spawn_main_menu_secret_joker()
        create_reality_warp_title_label()
    end
end

G.NURSERY_ROOMS = {
    { key = 'baby_needle', name = 'Baby Needle', room_name = "Weaver's Atelier", boss_name = "The Needle", bg_color = {0.52, 0.18, 0.24, 0.95}, accent_color = {0.95, 0.35, 0.45, 1}, pos = {x=0, y=0},
      quotes = {
          idle = { "Careful with the needles, stitch by stitch!", "Weaving destinies one thread at a time.", "Sharp points, sharper plays!" },
          feed = { "Spicy iron-thread snack! My favorite!", "Crunchy thimble biscuits! Delicious!", "Energy restored to stitch the winning hand!" },
          play = { "Watch me weave through cards at lightning speed!", "Can you dodge my thread barrage?", "Needle dance activated! Whoosh!" },
          sleep = { "Tucked into my pincushion... sweet dreams!", "Folding my silks for bedtime...", "Resting the needles until morning bell..." }
      } },
    { key = 'baby_pillar', name = 'Baby Pillar', room_name = "Ancient Sanctuary", boss_name = "The Pillar", bg_color = {0.48, 0.38, 0.25, 0.95}, accent_color = {0.92, 0.75, 0.38, 1}, pos = {x=1, y=0},
      quotes = {
          idle = { "Standing tall against every curse.", "Unyielding granite, protecting our hand.", "The foundation of our deck is solid." },
          feed = { "Stones may weather, but my appetite is sturdy.", "Crushed marble and mortar crackers! Tasty!", "Granite energy replenished!" },
          play = { "Let's test our defense against the storm!", "Stacking stone blocks as high as the clouds!", "Rock-solid coordination!" },
          sleep = { "Shield mode engaged... resting like stone.", "Deep slumber in the bedrock...", "Dozing off under heavy pillars..." }
      } },
    { key = 'baby_serpent', name = 'Baby Serpent', room_name = "Emerald Jungle Den", boss_name = "The Serpent", bg_color = {0.18, 0.48, 0.26, 0.95}, accent_color = {0.35, 0.92, 0.50, 1}, pos = {x=2, y=0},
      quotes = {
          idle = { "Sssss... greetings, card master.", "Coiled and watchful for the next draw.", "Slithering between the jokers quietly." },
          feed = { "Crispy crickets and sweet nectar! Sssuperb!", "A royal rodent treat! Delicious!", "NOM! My scales are gleaming brighter!" },
          play = { "Catch my tail if you can slip past my coils!", "Slithering around the deck! Tag, you're it!", "Sssurprise attack! Playtime!" },
          sleep = { "Coiled under warm leaves... ssshh...", "Hissing softly into dreamland...", "Curled in a warm loop for a long nap." }
      } },
    { key = 'baby_flint', name = 'Baby Flint', room_name = "Smoldering Forge", boss_name = "The Flint", bg_color = {0.55, 0.28, 0.14, 0.95}, accent_color = {1.0, 0.55, 0.18, 1}, pos = {x=3, y=0},
      quotes = {
          idle = { "Keep the embers burning hot!", "Sparks are ready to ignite a jackpot.", "Glowing forge, unstoppable heat!" },
          feed = { "Coal crunchies! Fueling my inner flame!", "Molten lava drops! Sweet and spicy!", "Burn baby burn! Delicious heat!" },
          play = { "Careful! Sparks fly when we play!", "Watch me juggle blazing embers!", "Hot potato with fireballs!" },
          sleep = { "The embers fade low... resting till dawn.", "Ash blankets keep me warm and cozy.", "Extinguishing for a quick recharge." }
      } },
    { key = 'baby_hook', name = 'Baby Hook', room_name = "Corsair's Bay", boss_name = "The Hook", bg_color = {0.16, 0.38, 0.55, 0.95}, accent_color = {0.30, 0.82, 0.92, 1}, pos = {x=4, y=0},
      quotes = {
          idle = { "Ahoy! Ready to set sail across the blinds!", "Spying treasure on the horizon!", "Anchors aweigh, card matey!" },
          feed = { "Fresh salted fish! A pirate feast!", "Crunchy sea biscuits and sweet grog!", "Yum! Plenty of iron in that mackerel!" },
          play = { "Let's hook up some fresh discards from the deep!", "Swashbuckling practice on the main deck!", "Yo-ho-ho! Catch me if ye can!" },
          sleep = { "Rocked to sleep by the rolling ocean tides...", "Hammock swinging beneath the starry skies.", "Night watch is over... snoozing away." }
      } },
    { key = 'baby_eye', name = 'Baby Eye', room_name = "Astral Observatory", boss_name = "The Eye", bg_color = {0.38, 0.22, 0.56, 0.95}, accent_color = {0.85, 0.40, 0.95, 1}, pos = {x=5, y=0},
      quotes = {
          idle = { "I see all possible hands in the cosmos.", "Gazing into alternate scoring dimensions.", "Nothing escapes my watchful gaze." },
          feed = { "Absorbing stardust and astral berries.", "Galaxy candy! It pops with cosmic flavor!", "Cosmic appetite fully satisfied!" },
          play = { "I spy with my ocular lens... another win!", "Can you dodge my telepathic stare?", "Peeking behind the blind curtain!" },
          sleep = { "Eyelids heavy... meditating among constellations...", "Entering deep trance in the void...", "Resting all three thousand pupils... Zzz..." }
      } },
    { key = 'baby_ox', name = 'Baby Ox', room_name = "Gilded Treasury", boss_name = "The Ox", bg_color = {0.52, 0.42, 0.16, 0.95}, accent_color = {0.98, 0.85, 0.25, 1}, pos = {x=6, y=0},
      quotes = {
          idle = { "Money talks, and our bank is growing!", "Polishing the golden horns for battle.", "Strong as a bull market!" },
          feed = { "Golden oats and shiny coins! Delicious!", "Honey-glazed bullion crunchies! Tasty!", "Munching pure wealth! Power up!" },
          play = { "Charge forward! Nothing halts the bull run!", "Stampede practice through the vault!", "Headbutting high scores into the ceiling!" },
          sleep = { "Resting my horns on stacks of cash...", "Pillow made of freshly minted banknotes.", "Snoring like a slumbering titan... Zzz..." }
      } },
    { key = 'baby_house', name = 'Baby House', room_name = "Cozy Hearth Cottage", boss_name = "The House", bg_color = {0.52, 0.32, 0.22, 0.95}, accent_color = {0.95, 0.55, 0.38, 1}, pos = {x=7, y=0},
      quotes = {
          idle = { "Welcome home! There is always room for cards here.", "Chimney smoke dancing peacefully.", "Warm hearth, warm heart." },
          feed = { "Warm stew and fresh baked bread!", "Buttery cinnamon rolls right from the oven!", "Full belly in a cozy home!" },
          play = { "Expanding the room for even bigger hands!", "Building card forts in the living room!", "Hide and seek behind the bookshelf!" },
          sleep = { "Fire crackling, doors locked. Safe and sound.", "Snug as a bug under a patchwork quilt.", "Good night, sweet cottage dreams." }
      } },
    { key = 'baby_club', name = 'Baby Club', room_name = "Verdant Clubhouse", boss_name = "The Club", bg_color = {0.18, 0.48, 0.24, 0.95}, accent_color = {0.35, 0.90, 0.42, 1}, pos = {x=8, y=0},
      quotes = {
          idle = { "Clubs are always in season!", "Green thumb and strong club hands.", "Rooted deep in good fortune." },
          feed = { "Four-leaf clover biscuits! Pure luck!", "Crispy green sprouts with honey dip!", "NOM NOM! Clover feast complete!" },
          play = { "Club high-five! Knocking out blinds together!", "Swinging club batons in celebration!", "A lucky club roll across the meadow!" },
          sleep = { "Resting peacefully under leafy branches.", "Tucked beneath a soft bed of moss.", "Resting the club till next game." }
      } },
    { key = 'baby_fish', name = 'Baby Fish', room_name = "Coral Aquarium", boss_name = "The Fish", bg_color = {0.16, 0.45, 0.54, 0.95}, accent_color = {0.30, 0.90, 0.95, 1}, pos = {x=9, y=0},
      quotes = {
          idle = { "Blub blub! Swimming in high scores!", "Currents are running fast and clear today.", "Flipping fins in the warm shallows." },
          feed = { "Delicious kelp flakes and water algae!", "Shrimp wafers! My absolute favorite!", "Gulp! Fresh bubbles of ocean flavor!" },
          play = { "Splish splash! Let me draw extra cards from the stream!", "Underwater loop-de-loops!", "Blowing bubble rings for you to pop!" },
          sleep = { "Floating gently in soothing warm bubbles...", "Drifting peaceful among the coral fans...", "Sleeping with one eye open... blub..." }
      } },
    { key = 'baby_window', name = 'Baby Window', room_name = "Prismatic Glass Hall", boss_name = "The Window", bg_color = {0.24, 0.42, 0.62, 0.95}, accent_color = {0.45, 0.85, 0.98, 1}, pos = {x=10, y=0},
      quotes = {
          idle = { "Reflecting victory in every diamond facet.", "Clear vision through any fog.", "Shining crystal clarity." },
          feed = { "Polishing with sweet crystal nectar!", "Sugar prisms! Crisp and sweet!", "Refraction energy topped off!" },
          play = { "Catch the colored rainbows dancing on the floor!", "Splitting light beams into a kaleidoscope!", "Mirror maze challenge! Find me!" },
          sleep = { "Curtains drawn tight. Dimming the light...", "Resting like a quiet stained-glass pane.", "Slumbering in prism reflections... Zzz..." }
      } },
    { key = 'baby_manacle', name = 'Baby Manacle', room_name = "Iron Bastille", boss_name = "The Manacle", bg_color = {0.36, 0.42, 0.50, 0.95}, accent_color = {0.75, 0.85, 0.95, 1}, pos = {x=11, y=0},
      quotes = {
          idle = { "No chain can hold our ambition.", "Links forged in unbreakable trust.", "Reinforced and ready for anything." },
          feed = { "Steel rations! Hard crunch, maximum iron!", "Cobalt bolts dipped in gravy!", "Crunching iron to build unbreakable resolve!" },
          play = { "Breaking limits! Unlocking bigger hand sizes!", "Juggling lockpicks like a master rogue!", "Clink-clank! A metal dance party!" },
          sleep = { "Chains resting silent on the cold floor...", "Locking the gate for naptime.", "Heavy steel resting silent and still... Zzz..." }
      } },
    { key = 'baby_wall', name = 'Baby Wall', room_name = "Fortress Ramparts", boss_name = "The Wall", bg_color = {0.50, 0.28, 0.22, 0.95}, accent_color = {0.90, 0.55, 0.35, 1}, pos = {x=12, y=0},
      quotes = {
          idle = { "Impenetrable defense, brick by brick.", "Shielding our jokers behind thick masonry.", "Unwavering bulwark on the front line." },
          feed = { "Stone cookies and mortar milk!", "Crushed brick snacks with sweet glaze!", "Reinforcing my walls with tasty calcium!" },
          play = { "Watch the Boss Blinds crumble against my wall!", "Building unbreakable card battlements!", "Tower defense drill! None shall pass!" },
          sleep = { "Standing guard even while dozing off...", "Resting against the solid bastion wall.", "Dozing on the watchtower... Zzz..." }
      } },
    { key = 'baby_wheel', name = 'Baby Wheel', room_name = "Carnival Casino", boss_name = "The Wheel", bg_color = {0.48, 0.20, 0.46, 0.95}, accent_color = {0.98, 0.78, 0.20, 1}, pos = {x=13, y=0},
      quotes = {
          idle = { "Step right up! Spin the wheel of fortune!", "Every spin is a fresh opportunity!", "Bright carnival lights, high stakes fun!" },
          feed = { "Lucky cherries and token candies!", "Cotton candy spun into gold threads!", "Sugary festival treats! Delicious!" },
          play = { "Round and round it goes, where it stops nobody knows!", "Spinning dizzy tricks on the circus ring!", "Jackpot celebration! Confetti everywhere!" },
          sleep = { "The carnival slows down... taking a rest spin.", "Ferris wheel lights dimming for the night.", "Quiet midway... resting the reels... Zzz..." }
      } },
    { key = 'baby_arm', name = 'Baby Arm', room_name = "Champion Dojo", boss_name = "The Arm", bg_color = {0.55, 0.20, 0.20, 0.95}, accent_color = {0.98, 0.40, 0.35, 1}, pos = {x=14, y=0},
      quotes = {
          idle = { "Feel the burn! Upgrading every single hand!", "Flexing biceps to crush blind requirements!", "Champion spirit! Never back down!" },
          feed = { "High protein shakes and iron determination!", "Peanut butter dumbbells! Pure power snack!", "Gulp! Muscle fuel fully replenished!" },
          play = { "One more rep! Leveling up our poker hands!", "Shadow boxing with the ante requirements!", "Arm wrestling contest! I bet I win!" },
          sleep = { "Muscle recovery session in progress. Zzz...", "Rest day for the champ!", "Tucking in the biceps for deep sleep." }
      } },
    { key = 'baby_psychic', name = 'Baby Psychic', room_name = "Crystal Sanctuary", boss_name = "The Psychic", bg_color = {0.42, 0.22, 0.60, 0.95}, accent_color = {0.85, 0.48, 0.98, 1}, pos = {x=15, y=0},
      quotes = {
          idle = { "I foresaw your visit three turns ago.", "Your next hand looks remarkably lucky.", "Vibrating at higher psychic frequencies." },
          feed = { "Telekinetic treats straight from the stars.", "Crystal sugar cubes hovering into my mouth!", "Psychic appetite fed with pure telepathy!" },
          play = { "Reading your mind... you want a straight flush!", "Levitating playing cards into the air!", "Guess which card I am thinking of right now!" },
          sleep = { "Entering deep astral sleep trance...", "Projecting consciousness to the dream realm.", "Meditating in psychic serenity... Zzz..." }
      } },
    { key = 'baby_goad', name = 'Baby Goad', room_name = "Midnight Spades Hall", boss_name = "The Goad", bg_color = {0.22, 0.30, 0.58, 0.95}, accent_color = {0.45, 0.68, 0.98, 1}, pos = {x=16, y=0},
      quotes = {
          idle = { "Sharp as a razor spade.", "Shadows dance at my command.", "Piercing through any defense." },
          feed = { "Dark chocolate with a sharp minty kick!", "Blackberry tarts baked with nighttime spices!", "Crisp and sharp! Delicious flavor!" },
          play = { "Sharpening the spikes! Spades hit like thunder!", "Darting through the darkness! Fast strike!", "Spade trickshots! Bullseye every time!" },
          sleep = { "Concealing my sharp edges for a good night's rest...", "Shadow cloak folded neat and tight.", "Resting in midnight tranquility... Zzz..." }
      } },
    { key = 'baby_water', name = 'Baby Water', room_name = "Crystal Springs", boss_name = "The Water", bg_color = {0.18, 0.42, 0.62, 0.95}, accent_color = {0.35, 0.80, 0.98, 1}, pos = {x=17, y=0},
      quotes = {
          idle = { "Flowing freely, washing away bad draws.", "Pure crystal currents keep our mind clear.", "Gentle ripples before the tidal wave." },
          feed = { "Fresh sparkling spring water infused with lotus!", "Dewdrop gummies! Cool and refreshing!", "Rehydrated and sparkling clean!" },
          play = { "Splash attack! Extra discards for everybody!", "Water slide down the score sheet!", "Rippling waves of chips!" },
          sleep = { "Drifting calmly along the river bend...", "Soothed by the gentle waterfall sound.", "Floating peacefully into dream waters... Zzz..." }
      } },
    { key = 'baby_mouth', name = 'Baby Mouth', room_name = "Gourmet Kitchen", boss_name = "The Mouth", bg_color = {0.56, 0.28, 0.32, 0.95}, accent_color = {0.98, 0.50, 0.55, 1}, pos = {x=18, y=0},
      quotes = {
          idle = { "Always hungry for big scoring hands!", "Whistling cheerful tunes while waiting for snacks.", "My tastebuds predict a win!" },
          feed = { "NOM NOM NOM! More snacks, please!", "Giant strawberry cupcake! Down the hatch!", "Delicious! You are the best chef in Balatro!" },
          play = { "Sticking to one hand type? That is my specialty!", "Blowing bubbles of bubblegum!", "Chewing through the blind score easily!" },
          sleep = { "Big yawn... mouth closing for naptime.", "Dreaming of rivers made of maple syrup.", "Snoring softly with a happy full tummy... Zzz..." }
      } },
    { key = 'baby_plant', name = 'Baby Plant', room_name = "Botanical Greenhouse", boss_name = "The Plant", bg_color = {0.20, 0.50, 0.22, 0.95}, accent_color = {0.45, 0.92, 0.38, 1}, pos = {x=19, y=0},
      quotes = {
          idle = { "Photosynthesis and face card power!", "Sprouting fresh leaves toward the sun.", "Roots growing deep and steady." },
          feed = { "Rich compost and plenty of warm sunshine!", "Plant food drops! Sprouting new buds!", "Chlorophyll burst! Leaves turning emerald bright!" },
          play = { "Sprouting fresh vines to support the royalty!", "Vine swinging across the greenhouse roof!", "Leaf flutter dance! Catch the falling leaves!" },
          sleep = { "Curling leaves under the gentle moonlight...", "Closing petals until the morning sun rises.", "Gentle sap flow... peaceful greenhouse slumber." }
      } },
    { key = 'baby_head', name = 'Baby Head', room_name = "Rose Quartz Lounge", boss_name = "The Head", bg_color = {0.58, 0.24, 0.38, 0.95}, accent_color = {0.98, 0.48, 0.68, 1}, pos = {x=20, y=0},
      quotes = {
          idle = { "Play with your heart and you will never lose.", "Heartbeats in sync with every winning flush.", "Pure compassion guides our hand." },
          feed = { "Sweet candied rose petals and red cherries!", "Heart-shaped shortbread with raspberry jam!", "Sweet treats make my heart flutter with joy!" },
          play = { "Hearts beating fast in royal synchronization!", "Juggle hearts without missing a single beat!", "Heart burst celebration! Spread the love!" },
          sleep = { "Dreaming of warm hugs and winning flushes...", "Resting on a soft plush heart pillow.", "Quiet rhythmic heartbeat... sweet dreams... Zzz..." }
      } },
    { key = 'baby_tooth', name = 'Baby Tooth', room_name = "Ivory Spire", boss_name = "The Tooth", bg_color = {0.46, 0.46, 0.50, 0.95}, accent_color = {0.95, 0.95, 0.90, 1}, pos = {x=21, y=0},
      quotes = {
          idle = { "Chomp chomp! Keeping these teeth razor sharp.", "Gleaming ivory smile ready for camera.", "Biting through blind obstacles!" },
          feed = { "Calcium biscuits! Extra crunchy!", "Minty dental chews! Fresh breath guaranteed!", "Crunch crunch! Enamel strengthened to maximum!" },
          play = { "Taking a bite out of the ante requirements!", "Tooth fairy games! Hide under the cup!", "Polishing up for a pearly white show!" },
          sleep = { "Tucked under the pillow for the tooth fairy...", "Resting the jaws after a long day of chomping.", "Good night! Don't forget to brush!" }
      } },
    { key = 'baby_mark', name = 'Baby Mark', room_name = "Shadow Pavilion", boss_name = "The Mark", bg_color = {0.38, 0.20, 0.45, 0.95}, accent_color = {0.85, 0.35, 0.92, 1}, pos = {x=22, y=0},
      quotes = {
          idle = { "The mark is set. Victory is sealed.", "Silent as a shadow on the floor.", "The mark of a true champion." },
          feed = { "Shadow berry dumplings in rich sauce!", "Midnight blackberries! Rich and dark!", "Stealth energy restored to full!" },
          play = { "Hiding in plain sight... face cards strike true!", "Shadow tag! Bet you can't touch my shadow!", "Vanishing trick! Now you see me, now you don't!" },
          sleep = { "Vanishing softly into the midnight mist...", "Shadow veil drawn tight.", "Slumbering within the quiet darkness... Zzz..." }
      } },
    { key = 'baby_heart', name = 'Baby Heart', room_name = "Crimson Heart Palace", boss_name = "Crimson Heart", bg_color = {0.60, 0.16, 0.24, 0.95}, accent_color = {0.98, 0.35, 0.45, 1}, pos = {x=23, y=0},
      quotes = {
          idle = { "My heartbeat shields every Joker you own.", "Crimson warmth flowing through our deck.", "Our cards beat as one." },
          feed = { "Strawberry tarts baked with pure love!", "Rich ruby jelly beans! Sweet devotion!", "Love fuel topped off! Warmth radiating!" },
          play = { "Our bond cannot be broken or debuffed!", "Double beat dance! Synchronized joy!", "Cheering for every hand with all my heart!" },
          sleep = { "Beating softly and steadily into peaceful sleep...", "Crimson glow dims to a gentle nightlight.", "Resting the royal heart... sweet dreams... Zzz..." }
      } },
    { key = 'baby_bell', name = 'Baby Bell', room_name = "Golden Belfry", boss_name = "Cerulean Bell", bg_color = {0.54, 0.40, 0.18, 0.95}, accent_color = {0.98, 0.85, 0.35, 1}, pos = {x=24, y=0},
      quotes = {
          idle = { "Ding-dong! Ringing in another victory!", "Golden chimes keeping tempo with the round.", "Every chime brings good fortune." },
          feed = { "Golden honey syrup! Makes my chime resonate!", "Sweet butter toffee drops! Resonant crunch!", "Yum! Golden chime resonance maximized!" },
          play = { "Listen to the echo! Retrigger all your scored cards!", "Bell carillon solo! Musical mastery!", "Ringing bells of joy! Ding-dong-ding!" },
          sleep = { "Hushed chimes in the evening breeze...", "The belfry falls quiet under twilight.", "Gentle windchime whisper into sleep... Zzz..." }
      } },
    { key = 'baby_acorn', name = 'Baby Acorn', room_name = "Golden Autumn Grove", boss_name = "Amber Acorn", bg_color = {0.52, 0.32, 0.16, 0.95}, accent_color = {0.95, 0.70, 0.28, 1}, pos = {x=25, y=0},
      quotes = {
          idle = { "Small acorn today, mighty oak tomorrow!", "Gathering golden acorns for the journey.", "Sturdy oak spirit inside a tiny shell." },
          feed = { "Roasted hazelnuts and crunchy autumn seeds!", "Maple sugar drops! Sweet autumn harvest!", "Crunchy nut feast! Growing bigger and stronger!" },
          play = { "Rolling around! Giving our best Joker extra energy!", "Acorn bowling through the fallen leaves!", "Catch the falling golden oak leaves!" },
          sleep = { "Curled up cozy inside a hollow oak branch...", "Tucked under warm autumn leaves.", "Slumbering till the morning frost melts... Zzz..." }
      } },
    { key = 'baby_leaf', name = 'Baby Leaf', room_name = "Zen Canopy", boss_name = "Verdant Leaf", bg_color = {0.20, 0.48, 0.28, 0.95}, accent_color = {0.40, 0.90, 0.50, 1}, pos = {x=26, y=0},
      quotes = {
          idle = { "Serene and untainted by any boss curse.", "Breeze flowing through jade foliage.", "Tranquility leads to the highest scores." },
          feed = { "Morning dew drops and crystal sunshine!", "Green tea mochi! Pure serenity!", "Zen nourishment absorbed with gratitude." },
          play = { "Dancing on the breeze, banishing every debuff!", "Leaf spiral whirlwind! Whoosh!", "Floating on gentle wind currents!" },
          sleep = { "Resting gently on a bed of soft moss...", "Floating on a still zen pond in the moonlight.", "Tranquil stillness... peaceful slumber... Zzz..." }
      } },
    { key = 'baby_vessel', name = 'Baby Vessel', room_name = "Void Reliquary", boss_name = "Violet Vessel", bg_color = {0.34, 0.22, 0.52, 0.95}, accent_color = {0.40, 0.88, 0.95, 1}, pos = {x=27, y=0},
      quotes = {
          idle = { "An empty vessel holding infinite power.", "Echoes of ancient victories sealed within.", "Boundless depth, waiting to unlock." },
          feed = { "Essence of twilight and star water!", "Vortex nectar drops! Spilling cosmic delight!", "Empty vessel filled with delicious energy!" },
          play = { "Uncorking the power! Blinds shrink before us!", "Vessel spin trick! Whirling vortex of fun!", "Peeking inside the infinite abyss!" },
          sleep = { "Sealing the lid... quiet slumber in the crypt...", "Resting silent in the astral chamber.", "Quiet void slumber... drifting into dreams... Zzz..." }
      } }
}

G.nursery_room_index = G.nursery_room_index or 1

G.NURSERY_ROOM_BY_KEY = {}
for i, room in ipairs(G.NURSERY_ROOMS) do
    G.NURSERY_ROOM_BY_KEY[room.key] = room
    room.index = i
end

local NURSERY_TEMP_FILE = "witch_nursery_cooldowns.temp"
local nursery_cds_cache = nil

local function load_nursery_cooldowns()
    if nursery_cds_cache then return nursery_cds_cache end
    local cds = {}
    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] then
        local p = G.PROFILES[G.SETTINGS.profile]
        if p.witch_nursery_cds then
            for fam_k, actions in pairs(p.witch_nursery_cds) do
                cds[fam_k] = cds[fam_k] or {}
                for act_k, ready_time in pairs(actions) do
                    cds[fam_k][act_k] = tonumber(ready_time)
                end
            end
        end
    end
    if love.filesystem and love.filesystem.getInfo and love.filesystem.getInfo(NURSERY_TEMP_FILE) then
        local content = love.filesystem.read(NURSERY_TEMP_FILE)
        if content then
            for line in string.gmatch(content .. "\n", "(.-)\n") do
                local fam_k, act_k, ready_time = string.match(line, "([^:]+):([^:]+):(%d+)")
                if fam_k and act_k and ready_time then
                    cds[fam_k] = cds[fam_k] or {}
                    cds[fam_k][act_k] = tonumber(ready_time)
                end
            end
        end
    end
    nursery_cds_cache = cds
    return cds
end

local function save_nursery_cooldowns(cds)
    nursery_cds_cache = cds
    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] then
        G.PROFILES[G.SETTINGS.profile].witch_nursery_cds = cds
        if G.save_settings then G:save_settings() end
    end
    if love.filesystem and love.filesystem.write then
        local lines = {}
        for fam_k, actions in pairs(cds) do
            for act_k, ready_time in pairs(actions) do
                table.insert(lines, string.format("%s:%s:%d", fam_k, act_k, ready_time))
            end
        end
        love.filesystem.write(NURSERY_TEMP_FILE, table.concat(lines, "\n"))
    end
end

local function get_nursery_cooldown(fam_key, action)
    local cds = load_nursery_cooldowns()
    if cds[fam_key] and cds[fam_key][action] then
        local now = os.time()
        local remaining = cds[fam_key][action] - now
        return math.max(0, remaining)
    end
    return 0
end

local function set_nursery_cooldown(fam_key, action, duration)
    local cds = load_nursery_cooldowns()
    cds[fam_key] = cds[fam_key] or {}
    cds[fam_key][action] = os.time() + duration
    save_nursery_cooldowns(cds)
end

function reduce_nursery_cooldowns(amt)
    amt = amt or 30
    local cds = load_nursery_cooldowns()
    local now = os.time()
    for fam_k, actions in pairs(cds) do
        for act_k, ready_time in pairs(actions) do
            if ready_time > now then
                actions[act_k] = math.max(now, ready_time - amt)
            end
        end
    end
    save_nursery_cooldowns(cds)
    if G.FUNCS and G.FUNCS.nursery_update_action_buttons then
        G.FUNCS.nursery_update_action_buttons()
    end
end
G.reduce_nursery_cooldowns = reduce_nursery_cooldowns

function reset_all_nursery_cooldowns()
    local cds = load_nursery_cooldowns()
    for fam_k, actions in pairs(cds) do
        for act_k, _ in pairs(actions) do
            actions[act_k] = 0
        end
    end
    save_nursery_cooldowns(cds)
    if G.FUNCS and G.FUNCS.nursery_update_action_buttons then
        G.FUNCS.nursery_update_action_buttons()
    end
end
G.reset_all_nursery_cooldowns = reset_all_nursery_cooldowns

function is_nursery_fam_discovered(fam)
    if not fam then return false end
    return true
end
G.is_nursery_fam_discovered = is_nursery_fam_discovered

function get_nursery_room_resident(room_idx)
    room_idx = room_idx or (G.nursery_room_index or 1)
    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile then
        local p = G.PROFILES[G.SETTINGS.profile]
        if p and p.witch_nursery_rooms then
            if p.witch_nursery_rooms[room_idx] == false then return nil end
            if p.witch_nursery_rooms[room_idx] then return p.witch_nursery_rooms[room_idx] end
        end
    end
    local natural = G.NURSERY_ROOMS and G.NURSERY_ROOMS[room_idx]
    if natural and is_nursery_fam_discovered(natural) then
        return natural.key
    end
    return nil
end
G.get_nursery_room_resident = get_nursery_room_resident

function set_nursery_room_resident(room_idx, fam_key)
    room_idx = room_idx or (G.nursery_room_index or 1)
    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile then
        local p = G.PROFILES[G.SETTINGS.profile]
        if p then
            p.witch_nursery_rooms = p.witch_nursery_rooms or {}
            p.witch_nursery_rooms[room_idx] = fam_key or false
            if G.save_progress then G:save_progress() end
            if G.save_settings then G:save_settings() end
        end
    end
end
G.set_nursery_room_resident = set_nursery_room_resident

function get_nursery_lead_companion()
    if G.nursery_lead_companion ~= nil then return G.nursery_lead_companion end
    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile then
        local p = G.PROFILES[G.SETTINGS.profile]
        if p then
            if p.witch_lead_companion ~= nil then
                if p.witch_lead_companion == false then return nil end
                G.nursery_lead_companion = p.witch_lead_companion
                return G.nursery_lead_companion
            end
            if p.witch_nursery_selected_fam ~= nil and p.witch_nursery_selected_fam ~= false then
                G.nursery_lead_companion = p.witch_nursery_selected_fam
                return G.nursery_lead_companion
            end
        end
    end
    local r1 = get_nursery_room_resident(1)
    if r1 then return r1 end
    return nil
end
G.get_nursery_lead_companion = get_nursery_lead_companion

function set_nursery_lead_companion(fam_key)
    G.nursery_lead_companion = fam_key
    G.nursery_selected_fam = fam_key
    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile then
        local p = G.PROFILES[G.SETTINGS.profile]
        if p then
            p.witch_lead_companion = fam_key or false
            p.witch_nursery_selected_fam = fam_key or false
            if G.save_progress then G:save_progress() end
            if G.save_settings then G:save_settings() end
        end
    end
end
G.set_nursery_lead_companion = set_nursery_lead_companion

function get_nursery_selected_fam()
    return get_nursery_lead_companion()
end
G.get_nursery_selected_fam = get_nursery_selected_fam

function set_nursery_selected_fam(fam_key)
    set_nursery_lead_companion(fam_key)
end
G.set_nursery_selected_fam = set_nursery_selected_fam

local function get_nursery_dynamic_dialogue(fam, action, room)
    if not fam then return "..." end
    local r_name = (room and room.room_name) or "the nursery"
    if action == 'feed' then
        local quotes = fam.quotes and fam.quotes.feed
        if type(quotes) == 'table' and #quotes > 0 then
            return quotes[math.random(1, #quotes)]
        end
        return "Yum! Delicious treat!"
    elseif action == 'play' then
        local quotes = fam.quotes and fam.quotes.play
        if type(quotes) == 'table' and #quotes > 0 then
            return quotes[math.random(1, #quotes)]
        end
        return "Wheee! Playing with you is the best!"
    elseif action == 'sleep' then
        local quotes = fam.quotes and fam.quotes.sleep
        if type(quotes) == 'table' and #quotes > 0 then
            return quotes[math.random(1, #quotes)]
        end
        return "Zzz... Resting peacefully... Sweet dreams..."
    elseif action == 'present' then
        if room and fam.key == room.key then
            local own_pool = {
                "Home sweet home! Nothing beats my own " .. r_name .. "!",
                "Everything in my " .. r_name .. " is just how I like it!",
                "Welcome to my " .. r_name .. "! Ready for training!",
                "Ah, back in the " .. r_name .. ". Feeling right at home!",
            }
            if fam.quotes and fam.quotes.idle and type(fam.quotes.idle) == 'table' then
                for _, q in ipairs(fam.quotes.idle) do
                    table.insert(own_pool, q)
                end
            end
            return own_pool[math.random(1, #own_pool)]
        else
            local guest_pool = {
                "Visiting the " .. r_name .. "! What an interesting room!",
                "Exploring the " .. r_name .. "! So much to see here!",
                "Hanging out in the " .. r_name .. " with you! Feeling great!",
                "So this is the " .. r_name .. "? I really like it!",
                "Making myself comfortable here in the " .. r_name .. "!",
                "Nice choice of room! The " .. r_name .. " has great vibes!",
            }
            return guest_pool[math.random(1, #guest_pool)]
        end
    end
    return "..."
end

function get_nursery_data(fam_key)
    if not fam_key then return { level = 1, exp = 0, max_exp = 100 } end
    local clean_key = tostring(fam_key):gsub('^c_reality_warp_', ''):gsub('^c_', '')
    if not G.PROFILES or not G.SETTINGS or not G.SETTINGS.profile then
        return { level = 1, exp = 0, max_exp = 100 }
    end
    local p = G.PROFILES[G.SETTINGS.profile]
    p.witch_nursery_data = p.witch_nursery_data or {}
    if not p.witch_nursery_data[clean_key] then
        p.witch_nursery_data[clean_key] = { level = 1, exp = 0, max_exp = 100 }
    end
    return p.witch_nursery_data[clean_key]
end
G.get_nursery_data = get_nursery_data

local function add_nursery_exp(fam_key, amt)
    local data = get_nursery_data(fam_key)
    if data.level >= 5 then
        data.exp = data.max_exp
        return false
    end
    data.exp = data.exp + amt
    local leveled = false
    while data.exp >= data.max_exp and data.level < 5 do
        data.exp = data.exp - data.max_exp
        data.level = data.level + 1
        data.max_exp = data.level * 100
        leveled = true
    end
    if data.level >= 5 then
        data.exp = data.max_exp
        if botg_trigger_mod_achievement then
            botg_trigger_mod_achievement('devoted_guardian')
        end
    end
    if G.save_progress then G:save_progress() end
    if G.save_settings then G:save_settings() end
    return leveled
end
G.add_nursery_exp = add_nursery_exp

local reality_warp_CUSTOM_UNLOCKS = {
    ['countdown_joker'] = true,
    ['reversed_hermit_joker'] = true,
    ['script_joker'] = true,
    ['apprentice_joker'] = true,
    ['outstanding_joker'] = true,
    ['blood_pact_joker'] = true,
    ['shareholder_joker'] = true,
    ['builder_joker'] = true,
    ['runway_joker'] = true,
    ['slot_machine_joker'] = true,
    ['duel_of_value_joker'] = true,
    ['reading_deficiency_joker'] = true,
    ['polarity_inversion'] = true,
    ['mercenary'] = true,
    ['cascade'] = true,
    ['merchant_joker'] = true,
    ['lover_joker'] = true,
    ['blacksmith_joker'] = true,
    ['lucky_one_joker'] = true,
    ['miner_joker'] = true,
    ['joke_joker'] = true,
    ['perfectionism_joker'] = true,
    ['orchestra_director'] = true,
    ['meteorologist'] = true,
    ['catalyst'] = true,
    ['blank_cheque_joker'] = true,
    ['hypnotist'] = true,
    ['black_hole_joker'] = true,
    ['chronos'] = true,
    ['alchemist'] = true,
    ['entomologist'] = true,
    ['mimic'] = true,
    ['ouroboros'] = true,
    ['void_walker'] = true,
    ['supermassive_black_hole'] = true,
    ['genesis'] = true,
    ['tesseract'] = true,
    ['quantum_entanglement'] = true,
    ['world_devourer'] = true,
    ['living_paradox'] = true,
    ['star_chronicler'] = true,
}

local function is_reality_warp_shop_joker(_c)
    if not _c or _c.set ~= 'Joker' then return false end
    if _c.is_secret or _c.rarity == 'Secret' or _c.rarity == 4 then return false end
    local is_wb = (_c.key and string.find(_c.key, 'reality_warp')) or
                  (_c.atlas and (string.find(_c.atlas, 'reality_warp') or string.find(_c.atlas, 'witchbrew'))) or
                  (_c.mod and _c.mod.id == 'reality_warp')
    if not is_wb then return false end

    local raw_key = tostring(_c.key or ''):gsub('^j_reality_warp_', ''):gsub('^j_', '')
    local full_key = 'j_reality_warp_' .. raw_key
    if reality_warp_CUSTOM_UNLOCKS[raw_key] or reality_warp_CUSTOM_UNLOCKS[full_key] or reality_warp_CUSTOM_UNLOCKS[_c.key] then
        return false
    end
    return true
end

function setup_reality_warp_shop_unlocks()
    if not G or not G.P_CENTERS then return end
    for k, v in pairs(G.P_CENTERS) do
        if is_reality_warp_shop_joker(v) then
            v.unlocked = true
            v.reality_warp_shop_unlock = true
            v.unlock = { "Buy this card from the shop", "to view in Collection" }
            v.locked_loc_txt = { "Buy this card from the shop", "to view in Collection" }
        end
    end

    if G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] then
        local p = G.PROFILES[G.SETTINGS.profile]
        if not p.reality_warp_fixed_custom_unlocks_v1 then
            p.reality_warp_fixed_custom_unlocks_v1 = true
            local missing_custom = {
                'blood_pact_joker', 'merchant_joker', 'blacksmith_joker', 'lucky_one_joker',
                'miner_joker', 'joke_joker', 'perfectionism_joker', 'orchestra_director',
                'meteorologist', 'catalyst'
            }
            for _, raw_k in ipairs(missing_custom) do
                local full_k = 'j_reality_warp_' .. raw_k
                if p.unlocked then
                    p.unlocked[full_k] = nil
                    p.unlocked[raw_k] = nil
                end
                if G.P_CENTERS then
                    if G.P_CENTERS[full_k] then
                        G.P_CENTERS[full_k].unlocked = false
                        G.P_CENTERS[full_k].reality_warp_shop_unlock = nil
                    end
                    if G.P_CENTERS[raw_k] then
                        G.P_CENTERS[raw_k].unlocked = false
                        G.P_CENTERS[raw_k].reality_warp_shop_unlock = nil
                    end
                end
            end
            if G.save_progress then G:save_progress() end
            if G.save_settings then G:save_settings() end
        end
    end
end

if not G.reality_warp_fam_ui_hooked and generate_card_ui then
    G.reality_warp_fam_ui_hooked = true
    local orig_generate_card_ui = generate_card_ui
    function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...)
        local ret = orig_generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card, ...)

        if _c and (_c.set == 'Familiar' or (_c.key and string.find(_c.key, 'baby_'))) and ret and ret.main then
            local fam_key = tostring(_c.key or ''):gsub('^c_reality_warp_', ''):gsub('^c_', '')
            local n_data = get_nursery_data(fam_key)
            local lvl = n_data and n_data.level or 1
            local exp = n_data and n_data.exp or 0
            local max_exp = n_data and n_data.max_exp or (lvl * 100)
            local status_str = (lvl >= 5) and " [MAX LEVEL]" or (" (" .. exp .. " / " .. max_exp .. " EXP)")
            ret.main[#ret.main + 1] = {
                {
                    n = G.UIT.T,
                    config = {
                        text = "⭐ Familiar Level: Lv. " .. lvl .. status_str,
                        colour = G.C.GOLD,
                        scale = 0.32,
                        shadow = true
                    }
                }
            }
        end

        if is_reality_warp_shop_joker(_c) and ret and ret.main then
            if card_type == 'Locked' or card_type == 'Undiscovered' or hide_desc then
                local desc_scale = (G.LANG and G.LANG.font and G.LANG.font.DESCSCALE) or 2.8
                ret.main = {
                    {
                        {
                            n = G.UIT.T,
                            config = {
                                text = "Buy this card from the shop to view in Collection",
                                colour = G.C.GOLD,
                                scale = 0.32 * desc_scale,
                                shadow = true
                            }
                        }
                    }
                }
            end
        end

        local is_rw_joker = _c and _c.set == 'Joker' and ((_c.key and string.find(_c.key, 'reality_warp')) or (_c.mod and _c.mod.id == 'reality_warp') or (_c.atlas and string.find(_c.atlas, 'reality_warp')))
        if is_rw_joker and not is_reality_warp_shop_joker(_c) and (card_type == 'Locked' or _c.unlocked == false) and ret and ret.main then
            local raw_k = tostring(_c.key or ''):gsub('^j_reality_warp_', ''):gsub('^j_', '')
            local full_k = 'j_reality_warp_' .. raw_k
            local unl = (_c.loc_txt and _c.loc_txt.unlock) or _c.unlock or (G.localization and G.localization.descriptions and G.localization.descriptions.Joker and (G.localization.descriptions.Joker[full_k] or G.localization.descriptions.Joker[_c.key] or G.localization.descriptions.Joker[raw_k]) and (G.localization.descriptions.Joker[full_k] or G.localization.descriptions.Joker[_c.key] or G.localization.descriptions.Joker[raw_k]).unlock)
            if unl and #unl > 0 then
                local unl_nodes = {}
                for _, line in ipairs(unl) do
                    local parsed_l = (loc_parse_string and loc_parse_string(line)) or { { strings = { line }, colour = G.C.UI.TEXT_DARK or G.C.GREY } }
                    if SMODS and SMODS.localize_box then
                        unl_nodes[#unl_nodes + 1] = SMODS.localize_box(parsed_l, { default_col = G.C.UI.TEXT_DARK or G.C.GREY, scale = 1.0 })
                    else
                        local desc_scale = (G.LANG and G.LANG.font and G.LANG.font.DESCSCALE) or 2.8
                        unl_nodes[#unl_nodes + 1] = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = line,
                                    colour = G.C.UI.TEXT_DARK or G.C.GREY,
                                    scale = 0.32 * desc_scale,
                                    shadow = false
                                }
                            }
                        }
                    end
                end
                ret.main = unl_nodes
            end
        end

        return ret
    end
end

if not G.reality_warp_buy_unlock_hooked and G.FUNCS and G.FUNCS.buy_from_shop then
    G.reality_warp_buy_unlock_hooked = true
    local orig_buy_from_shop = G.FUNCS.buy_from_shop
    G.FUNCS.buy_from_shop = function(e)
        local c1 = e and e.config and e.config.ref_table
        if c1 and c1:is(Card) and c1.config and c1.config.center then
            local center = c1.config.center
            if is_reality_warp_shop_joker(center) then
                if discover_card then discover_card(center) end
                if unlock_card and not center.unlocked then unlock_card(center) end
                c1.discovered = true
            end
        end
        return orig_buy_from_shop(e)
    end
end

if not G.reality_warp_add_to_deck_shop_unlock and Card and Card.add_to_deck then
    G.reality_warp_add_to_deck_shop_unlock = true
    local orig_add_to_deck = Card.add_to_deck
    function Card:add_to_deck(from_debuff)
        if not from_debuff and self.config and self.config.center then
            local center = self.config.center
            if is_reality_warp_shop_joker(center) then
                if discover_card then discover_card(center) end
                if unlock_card and not center.unlocked then unlock_card(center) end
                self.discovered = true
            end
        end
        return orig_add_to_deck(self, from_debuff)
    end
end

SMODS.Atlas {
    key = "reality_warp_nursery_rooms",
    path = "nursery_rooms.png",
    px = 140,
    py = 80
}

local function update_nursery_quote_display(new_quote)
    if not G.OVERLAY_MENU or not new_quote then return end
    local quote_elem = G.OVERLAY_MENU:get_UIE_by_ID('nursery_quote_text')
    if quote_elem then
        quote_elem.config.text = "\"" .. new_quote .. "\""
        if quote_elem.config.text_drawable then
            quote_elem.config.text_drawable:set(quote_elem.config.text)
        end
        if quote_elem.UIBox then
            quote_elem.UIBox:recalculate()
        end
    end
end

local function update_nursery_exp_display(fam_key)
    if not G.OVERLAY_MENU or not fam_key then return end
    local data = get_nursery_data(fam_key)
    if not data then return end
    local exp_elem = G.OVERLAY_MENU:get_UIE_by_ID('nursery_exp_text')
    if exp_elem then
        local exp_str = (data.level >= 5 and "Lv. 5 [MAX LEVEL] - Maximum Power!" or ("Familiar Level: Lv. " .. data.level .. "  ( " .. data.exp .. " / " .. data.max_exp .. " EXP )"))
        exp_elem.config.text = exp_str
        if exp_elem.config.text_drawable then
            exp_elem.config.text_drawable:set(exp_str)
        end
        if exp_elem.UIBox then
            exp_elem.UIBox:recalculate()
        end
    end
    local fill_elem = G.OVERLAY_MENU:get_UIE_by_ID('nursery_exp_fill')
    if fill_elem then
        local bar_w = 5.2
        local fill_ratio = data.level >= 5 and 1.0 or math.min(1.0, math.max(0.04, data.exp / data.max_exp))
        local fill_w = bar_w * fill_ratio
        fill_elem.config.minw = fill_w
        fill_elem.config.w = fill_w
        fill_elem.config.colour = (data.level >= 5 and G.C.GOLD or G.C.GREEN)
        if fill_elem.UIBox then
            fill_elem.UIBox:recalculate()
        end
    end
end

G.UIDEF = G.UIDEF or {}
G.UIDEF.nursery_tab = function(args)
    G.nursery_tab_active = true

    local current_idx = G.nursery_room_index or 1
    if current_idx < 1 then current_idx = 1 end
    if current_idx > #G.NURSERY_ROOMS then current_idx = #G.NURSERY_ROOMS end
    G.nursery_room_index = current_idx

    local current_room = G.NURSERY_ROOMS[current_idx]
    local resident_fam_key = get_nursery_room_resident(current_idx)
    local sel_fam = resident_fam_key and G.NURSERY_ROOM_BY_KEY[resident_fam_key]
    local lead_fam_key = get_nursery_lead_companion()
    local is_lead = (resident_fam_key and lead_fam_key and resident_fam_key == lead_fam_key)
    local is_discovered = sel_fam and is_nursery_fam_discovered(sel_fam)
    local data = sel_fam and get_nursery_data(sel_fam.key) or { level = 1, exp = 0, max_exp = 100 }

    if G.nursery_picker_open then
        local page = G.nursery_picker_page or 1
        if page < 1 then page = 1 end
        if page > 2 then page = 2 end
        G.nursery_picker_page = page

        local start_i = (page - 1) * 14 + 1
        local end_i = math.min(#G.NURSERY_ROOMS, page * 14)

        local row1_nodes = {}
        local row2_nodes = {}

        local fam_atlas = G.ASSET_ATLAS['reality_warp_familiars'] or G.ASSET_ATLAS['reality_warp_reality_warp_familiars']

        for i = start_i, end_i do
            local f = G.NURSERY_ROOMS[i]
            local disc = is_nursery_fam_discovered(f)
            local f_data = get_nursery_data(f.key)

            local icon_view = Moveable(0, 0, 0.70, 0.70)
            icon_view.cards = {}
            icon_view.states.hover.can = false
            icon_view.states.click.can = false
            icon_view.states.collide.can = false
            icon_view.states.drag.can = false
            if disc and fam_atlas then
                icon_view.icon_sprite = Sprite(0, 0, 0.70, 0.70, fam_atlas, f.pos)
                function icon_view:draw()
                    if self.icon_sprite then
                        self.icon_sprite.T.x = self.T.x
                        self.icon_sprite.T.y = self.T.y
                        self.icon_sprite:draw()
                    end
                end
            end

            local card_node = {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.03,
                    r = 0.10,
                    colour = G.C.BLACK,
                    emboss = 0.04,
                    outline = 1.2,
                    outline_colour = disc and G.C.GOLD or G.C.L_BLACK,
                    minw = 1.12,
                    minh = 1.82,
                    button = disc and 'nursery_pick_familiar' or nil,
                    id = f.key,
                    hover = disc
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", minh = 0.72 },
                        nodes = {
                            disc and { n = G.UIT.O, config = { object = icon_view } } or { n = G.UIT.T, config = { text = "LOCKED", scale = 0.18, colour = G.C.UI.TEXT_INACTIVE } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                            { n = G.UIT.T, config = { text = f.name, scale = 0.18, colour = disc and G.C.WHITE or G.C.UI.TEXT_INACTIVE, shadow = disc } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                            { n = G.UIT.T, config = { text = (disc and ("Lv. " .. f_data.level) or "Defeat Boss"), scale = 0.16, colour = disc and G.C.GOLD or G.C.GREY } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            disc and UIBox_button({ id = f.key, label = {"Choose"}, button = 'nursery_pick_familiar', colour = G.C.GREEN, minw = 1.05, minh = 0.32, scale = 0.20, emboss = 0.05, col = true })
                            or { n = G.UIT.T, config = { text = "Undiscovered", scale = 0.14, colour = G.C.UI.TEXT_INACTIVE } }
                        }
                    }
                }
            }

            if #row1_nodes < 7 then
                table.insert(row1_nodes, card_node)
            else
                table.insert(row2_nodes, card_node)
            end
        end

        return {
            n = G.UIT.ROOT,
            config = { align = "cm", padding = 0.06, colour = G.C.CLEAR, minh = 6.2, minw = 8.6 },
            nodes = {
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.08, r = 0.12, colour = G.C.L_BLACK, minw = 8.5, minh = 6.0, emboss = 0.08, outline = 2, outline_colour = G.C.BLACK },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.03 },
                            nodes = {
                                { n = G.UIT.T, config = { text = "COMPANION SELECTION", scale = 0.38, colour = G.C.GOLD, shadow = true } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.02 },
                            nodes = {
                                { n = G.UIT.T, config = { text = "Select a familiar resident for " .. current_room.room_name, scale = 0.22, colour = G.C.UI.TEXT_LIGHT } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.03 },
                            nodes = {
                                UIBox_button({ label = {" < Prev "}, button = 'nursery_picker_prev_page', colour = G.C.BLUE, minw = 1.4, minh = 0.38, scale = 0.24, emboss = 0.06, col = true }),
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", minw = 2.4 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = "Page " .. page .. " / 2", scale = 0.24, colour = G.C.WHITE, shadow = true } }
                                    }
                                },
                                UIBox_button({ label = {" Next > "}, button = 'nursery_picker_next_page', colour = G.C.BLUE, minw = 1.4, minh = 0.38, scale = 0.24, emboss = 0.06, col = true }),
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.04, r = 0.08, colour = G.C.BLACK, emboss = 0.04, minw = 8.2, minh = 4.1 },
                            nodes = {
                                { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = row1_nodes },
                                { n = G.UIT.R, config = { align = "cm", padding = 0.02 }, nodes = row2_nodes }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.04 },
                            nodes = {
                                UIBox_button({ label = {"Back to Room"}, button = 'nursery_close_picker', colour = G.C.RED, minw = 2.0, minh = 0.44, scale = 0.28, emboss = 0.06, col = true })
                            }
                        }
                    }
                }
            }
        }
    end

    local bg_colour = current_room.bg_color or {0.10, 0.10, 0.13, 0.95}

    local lead_badge = is_lead and "  (Lead Companion)" or ""
    local title_text = sel_fam and (sel_fam.name .. "  [Lv. " .. data.level .. "/5]" .. lead_badge .. " in " .. current_room.room_name) or ("Empty Room - " .. current_room.room_name)
    local nav_row = {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.02, minw = 8.2 },
        nodes = {
            UIBox_button({ id = 'nursery_prev_btn', label = {" < "}, button = 'nursery_prev_room', colour = G.C.ORANGE, minw = 0.7, minh = 0.45, scale = 0.32, emboss = 0.06, col = true }),
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 6.4, padding = 0.02 },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                            { n = G.UIT.T, config = { text = title_text, scale = 0.30, colour = (sel_fam and (is_lead and G.C.GOLD or G.C.WHITE) or G.C.GOLD), shadow = true } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                            { n = G.UIT.T, config = { text = ("Room " .. current_idx .. " of " .. #G.NURSERY_ROOMS .. " (Themed for " .. current_room.boss_name .. ")"), scale = 0.19, colour = G.C.UI.TEXT_LIGHT } }
                        }
                    }
                }
            },
            UIBox_button({ id = 'nursery_next_btn', label = {" > "}, button = 'nursery_next_room', colour = G.C.ORANGE, minw = 0.7, minh = 0.45, scale = 0.32, emboss = 0.06, col = true }),
        }
    }

    local manage_row = sel_fam and {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.02 },
        nodes = {
            { n = G.UIT.T, config = { text = "Resident: " .. sel_fam.name .. "  ", scale = 0.24, colour = G.C.GOLD, shadow = true } },
            UIBox_button({ label = {"Switch"}, button = 'nursery_open_picker', colour = G.C.BLUE, minw = 1.2, minh = 0.38, scale = 0.22, emboss = 0.06, col = true }),
            is_lead and UIBox_button({ id = 'nursery_lead_active_btn', label = {"Lead Companion"}, button = 'nursery_toggle_lead', colour = G.C.GOLD, minw = 1.7, minh = 0.38, scale = 0.22, emboss = 0.06, col = true })
            or UIBox_button({ id = 'nursery_take_run_btn', label = {"Take on Run"}, button = 'nursery_set_as_lead', colour = G.C.GREEN, minw = 1.6, minh = 0.38, scale = 0.22, emboss = 0.06, col = true }),
            UIBox_button({ label = {"Empty"}, button = 'nursery_remove_familiar', colour = G.C.RED, minw = 1.1, minh = 0.38, scale = 0.22, emboss = 0.06, col = true }),
        }
    } or {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.02 },
        nodes = {
            { n = G.UIT.T, config = { text = "No familiar living in this room yet!  ", scale = 0.24, colour = G.C.UI.TEXT_LIGHT } },
            UIBox_button({ label = {"+ Assign Resident"}, button = 'nursery_open_picker', colour = G.C.GREEN, minw = 2.0, minh = 0.40, scale = 0.25, emboss = 0.06, col = true }),
        }
    }

    local room_atlas = G.ASSET_ATLAS['reality_warp_nursery_rooms'] or G.ASSET_ATLAS['reality_warp_reality_warp_nursery_rooms']
    local fam_atlas = G.ASSET_ATLAS['reality_warp_familiars'] or G.ASSET_ATLAS['reality_warp_reality_warp_familiars']
    local room_pos = { x = current_idx - 1, y = 0 }

    local room_view = Moveable(0, 0, 5.4, 2.7)
    room_view.cards = {}
    room_view.children = room_view.children or {}
    room_view.states.hover.can = false
    room_view.states.click.can = false
    room_view.states.collide.can = false
    room_view.states.drag.can = false
    if room_atlas then
        room_view.room_sprite = Sprite(0, 0, 5.4, 2.7, room_atlas, room_pos)
    end

    if sel_fam and fam_atlas then
        local fam_view = Moveable(0, 0, 1.3, 1.3)
        fam_view.cards = {}
        fam_view.children = fam_view.children or {}
        fam_view.fam_sprite = Sprite(0, 0, 1.3, 1.3, fam_atlas, sel_fam.pos)
        fam_view.parent_room = room_view
        fam_view.states.click.can = true
        fam_view.states.hover.can = true
        fam_view.states.drag.can = true
        fam_view.states.collide.can = true

        local c_key = 'c_reality_warp_' .. sel_fam.key
        local center = G.P_CENTERS[c_key]

        function fam_view:hover()
            if not self.children.h_popup and center and generate_card_ui and G.UIDEF.card_h_popup then
                local card_mock = {
                    config = { center = center },
                    ability = { name = center.name },
                    debuff = false,
                    area = room_view
                }
                card_mock.ability_UIBox_table = generate_card_ui(center, nil, nil, nil, nil, nil, nil, nil, card_mock)
                local ok, popup_def = pcall(function()
                    return G.UIDEF.card_h_popup(card_mock)
                end)
                if ok and popup_def then
                    self.config = self.config or {}
                    self.config.h_popup = popup_def
                    self.config.h_popup_config = {
                        align = "bm",
                        offset = { x = 0, y = -0.1 },
                        major = self,
                        instance_type = 'POPUP'
                    }
                end
            end
            Node.hover(self)
        end

        function fam_view:stop_hover()
            Node.stop_hover(self)
            if self.config then
                self.config.h_popup = nil
            end
        end

        function fam_view:drag()
            if self.children.h_popup then
                self:stop_hover()
            end
            self.states.drag.is = true
            G.nursery_fam_dragging = true
            if G.CONTROLLER and G.CONTROLLER.cursor_position then
                local cx = G.CONTROLLER.cursor_position.x / (G.TILESCALE * G.TILESIZE)
                local cy = G.CONTROLLER.cursor_position.y / (G.TILESCALE * G.TILESIZE)
                local ox = (self.click_offset and self.click_offset.x) or (self.T.w * 0.5)
                local oy = (self.click_offset and self.click_offset.y) or (self.T.h * 0.5)
                self.T.x = cx - ox
                self.T.y = cy - oy
                if self.parent_room then
                    local min_x = self.parent_room.T.x + 0.1
                    local max_x = self.parent_room.T.x + self.parent_room.T.w - self.T.w - 0.1
                    local min_y = self.parent_room.T.y + 0.1
                    local max_y = self.parent_room.T.y + self.parent_room.T.h - self.T.h - 0.1
                    self.T.x = math.min(max_x, math.max(min_x, self.T.x))
                    self.T.y = math.min(max_y, math.max(min_y, self.T.y))
                end
                self.VT.x = self.T.x
                self.VT.y = self.T.y
            end
        end

        function fam_view:stop_drag()
            Node.stop_drag(self)
            self.states.drag.is = false
            G.nursery_fam_dragging = false
        end

        function fam_view:click()
            play_sound('voice' .. math.random(1, 11), G.SPEEDFACTOR * (math.random() * 0.2 + 1), 0.5)
            self:juice_up(0.4, 0.3)
            local current_room_now = G.NURSERY_ROOMS[G.nursery_room_index or 1]
            local new_quote = get_nursery_dynamic_dialogue(sel_fam, 'present', current_room_now)
            G.nursery_dialogue = new_quote
            if update_nursery_quote_display then
                update_nursery_quote_display(new_quote)
            end
        end

        function fam_view:draw()
            if self.fam_sprite then
                local float_y = (self.states.drag.is) and 0 or (0.04 * math.sin(G.TIMERS.REAL * 3.0))
                self.fam_sprite.T.x = self.T.x
                self.fam_sprite.T.y = self.T.y + float_y
                self.fam_sprite:draw()
            end
            add_to_drawhash(self)
        end

        function fam_view:remove()
            if self.children.h_popup then
                self.children.h_popup:remove()
                self.children.h_popup = nil
            end
            if self.fam_sprite then self.fam_sprite:remove() end
            Moveable.remove(self)
        end

        room_view.fam_view = fam_view
        room_view.children.fam_view = fam_view
    end

    function room_view:draw()
        if self.room_sprite then
            self.room_sprite.T.x = self.T.x
            self.room_sprite.T.y = self.T.y
            self.room_sprite:draw()
        end
        if self.fam_view then
            if not self.fam_view.states.drag.is then
                if not self.fam_offset_x then
                    self.fam_offset_x = (self.T.w - self.fam_view.T.w) * 0.5
                    self.fam_offset_y = self.T.h * 0.35
                end
                self.fam_view.T.x = self.T.x + self.fam_offset_x
                self.fam_view.T.y = self.T.y + self.fam_offset_y
                self.fam_view.VT.x = self.fam_view.T.x
                self.fam_view.VT.y = self.fam_view.T.y
            else
                self.fam_offset_x = self.fam_view.T.x - self.T.x
                self.fam_offset_y = self.fam_view.T.y - self.T.y
            end
            self.fam_view:draw()
        end
        add_to_drawhash(self)
    end

    function room_view:remove()
        if self.room_sprite then self.room_sprite:remove() end
        if self.fam_view then
            self.fam_view:remove()
            self.fam_view = nil
        end
        if self.children and self.children.fam_view then
            self.children.fam_view = nil
        end
        Moveable.remove(self)
    end

    local bar_w = 4.6
    local fill_ratio = data.level >= 5 and 1.0 or math.min(1.0, math.max(0.04, data.exp / data.max_exp))
    local fill_w = bar_w * fill_ratio

    local exp_node = sel_fam and {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.02 },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    { n = G.UIT.T, config = { id = 'nursery_exp_text', text = (data.level >= 5 and "Lv. 5 [MAX LEVEL] - Maximum Power!" or ("Familiar Level: Lv. " .. data.level .. "  ( " .. data.exp .. " / " .. data.max_exp .. " EXP )")), scale = 0.24, colour = G.C.GOLD, shadow = true } }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cl", minw = bar_w, minh = 0.15, colour = G.C.BLACK, r = 0.06, emboss = 0.04, padding = 0.01, outline = 1, outline_colour = G.C.L_BLACK },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { id = 'nursery_exp_fill', align = "cm", minw = fill_w, minh = 0.13, colour = (data.level >= 5 and G.C.GOLD or G.C.BLUE), r = 0.05, emboss = 0.03 },
                        nodes = {}
                    }
                }
            }
        }
    } or nil

    if not G.nursery_dialogue and sel_fam then
        G.nursery_dialogue = get_nursery_dynamic_dialogue(sel_fam, 'present', current_room)
    end
    local current_quote = sel_fam and G.nursery_dialogue or "This room is empty. Tap '+ Assign Resident' to choose a companion!"
    local quote_node = {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.02 },
        nodes = {
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    colour = G.C.JOKER_GREY,
                    r = 0.20,
                    padding = 0.04,
                    minw = 4.6,
                    maxw = 7.0,
                    shadow = true
                },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            colour = G.C.WHITE,
                            r = 0.15,
                            padding = 0.05,
                            minw = 4.4,
                            maxw = 6.8,
                            emboss = 0.03
                        },
                        nodes = {
                            { n = G.UIT.T, config = { id = 'nursery_quote_text', text = current_quote, scale = 0.24, colour = G.C.UI.TEXT_DARK, shadow = false } }
                        }
                    }
                }
            }
        }
    }

    local room_inner = nil
    if sel_fam then
        room_inner = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.02 },
            nodes = {
                quote_node,
                exp_node,
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.O, config = { object = room_view } }
                    }
                }
            }
        }
    else
        room_inner = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.03 },
            nodes = {
                quote_node,
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.O, config = { object = room_view } }
                    }
                },
                {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        UIBox_button({ label = {"+ Choose a Familiar to Move In"}, button = 'nursery_open_picker', colour = G.C.GREEN, minw = 3.6, minh = 0.50, scale = 0.28, emboss = 0.06, col = true })
                    }
                }
            }
        }
    end

    local actions_row = nil
    if sel_fam then
        local cd_feed = get_nursery_cooldown(sel_fam.key, 'feed')
        local cd_play = get_nursery_cooldown(sel_fam.key, 'play')
        local cd_sleep = get_nursery_cooldown(sel_fam.key, 'sleep')

        local feed_label = cd_feed > 0 and ("Feed (" .. cd_feed .. "s)") or "Feed (+35 XP)"
        local play_label = cd_play > 0 and ("Play (" .. cd_play .. "s)") or "Play (+20 XP)"
        local sleep_label = cd_sleep > 0 and ("Sleep (" .. cd_sleep .. "s)") or "Sleep (+60 XP)"

        local feed_col = cd_feed > 0 and G.C.UI.BACKGROUND_INACTIVE or G.C.GREEN
        local play_col = cd_play > 0 and G.C.UI.BACKGROUND_INACTIVE or G.C.BLUE
        local sleep_col = cd_sleep > 0 and G.C.UI.BACKGROUND_INACTIVE or G.C.PURPLE

        actions_row = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.04 },
            nodes = {
                UIBox_button({ id = 'nursery_btn_play', label = {play_label}, button = 'nursery_action_play', colour = play_col, minw = 2.1, minh = 0.48, scale = 0.27, emboss = 0.06, col = true }),
                UIBox_button({ id = 'nursery_btn_feed', label = {feed_label}, button = 'nursery_action_feed', colour = feed_col, minw = 2.1, minh = 0.48, scale = 0.27, emboss = 0.06, col = true }),
                UIBox_button({ id = 'nursery_btn_sleep', label = {sleep_label}, button = 'nursery_action_sleep', colour = sleep_col, minw = 2.1, minh = 0.48, scale = 0.27, emboss = 0.06, col = true }),
            }
        }
    else
        actions_row = {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.04 },
            nodes = {
                UIBox_button({ label = {"Play (Inactive)"}, button = 'nursery_action_disabled', colour = G.C.UI.BACKGROUND_INACTIVE, minw = 2.1, minh = 0.48, scale = 0.27, emboss = 0.06, col = true }),
                UIBox_button({ label = {"Feed (Inactive)"}, button = 'nursery_action_disabled', colour = G.C.UI.BACKGROUND_INACTIVE, minw = 2.1, minh = 0.48, scale = 0.27, emboss = 0.06, col = true }),
                UIBox_button({ label = {"Sleep (Inactive)"}, button = 'nursery_action_disabled', colour = G.C.UI.BACKGROUND_INACTIVE, minw = 2.1, minh = 0.48, scale = 0.27, emboss = 0.06, col = true }),
            }
        }
    end

    return {
        n = G.UIT.ROOT,
        config = { align = "cm", padding = 0.06, colour = G.C.CLEAR, minh = 6.2, minw = 8.6 },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08, r = 0.12, colour = G.C.L_BLACK, minw = 8.5, minh = 6.0, emboss = 0.08, outline = 2, outline_colour = G.C.BLACK },
                nodes = {
                    nav_row,
                    manage_row,
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.06, r = 0.10, colour = bg_colour, minw = 8.2, minh = 4.2, emboss = 0.04, outline = 2, outline_colour = G.C.BLACK },
                        nodes = {
                            room_inner
                        }
                    },
                    actions_row
                }
            }
        }
    }
end

-- ----------------------------------------------------------------------------
-- Safe Guards: CardArea Draw / Remove nil-cards Crash Prevention
-- ----------------------------------------------------------------------------
if CardArea then
    if CardArea.draw and not CardArea.reality_warp_guarded_draw then
        local orig_cardarea_draw = CardArea.draw
        CardArea.draw = function(self, ...)
            if not self or not self.cards then return end
            return orig_cardarea_draw(self, ...)
        end
        CardArea.reality_warp_guarded_draw = true
    end
    if CardArea.remove and not CardArea.reality_warp_guarded_remove then
        local orig_cardarea_remove = CardArea.remove
        CardArea.remove = function(self, ...)
            orig_cardarea_remove(self, ...)
            self.cards = self.cards or {}
        end
        CardArea.reality_warp_guarded_remove = true
    end
    if CardArea.remove_card and not CardArea.reality_warp_guarded_remove_card then
        local orig_cardarea_remove_card = CardArea.remove_card
        CardArea.remove_card = function(self, ...)
            if not self or not self.cards then return end
            return orig_cardarea_remove_card(self, ...)
        end
        CardArea.reality_warp_guarded_remove_card = true
    end
end

G.FUNCS = G.FUNCS or {}

function G.FUNCS.nursery_refresh_page(e)
    local tab_contents = nil
    if G.OVERLAY_MENU then
        tab_contents = G.OVERLAY_MENU:get_UIE_by_ID('tab_contents')
    end
    if not tab_contents and e and e.UIBox then
        local curr = e.UIBox
        while curr do
            if curr.get_UIE_by_ID then
                tab_contents = curr:get_UIE_by_ID('tab_contents')
                if tab_contents then break end
            end
            curr = curr.parent
        end
    end
    if tab_contents and tab_contents.config and tab_contents.config.object then
        tab_contents.config.object:remove()
        tab_contents.config.object = UIBox{
            definition = G.UIDEF.nursery_tab('Nursery'),
            config = { offset = {x=0,y=0}, parent = tab_contents, align = 'cm', type = 'cm' }
        }
        if tab_contents.UIBox then
            tab_contents.UIBox:recalculate()
        end
    elseif G.FUNCS.reality_warp_open_nursery_modal then
        G.FUNCS.reality_warp_open_nursery_modal(e)
    end
end

G.FUNCS.nursery_prev_room = function(e)
    G.nursery_room_index = (G.nursery_room_index or 1) - 1
    if G.nursery_room_index < 1 then
        G.nursery_room_index = #G.NURSERY_ROOMS
    end
    local fam_key = get_nursery_room_resident(G.nursery_room_index)
    local fam = fam_key and G.NURSERY_ROOM_BY_KEY[fam_key]
    local new_room = G.NURSERY_ROOMS[G.nursery_room_index]
    if fam then
        G.nursery_dialogue = get_nursery_dynamic_dialogue(fam, 'present', new_room)
    else
        G.nursery_dialogue = nil
    end
    play_sound('cardSlide1', 0.9, 0.6)
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_next_room = function(e)
    G.nursery_room_index = (G.nursery_room_index or 1) + 1
    if G.nursery_room_index > #G.NURSERY_ROOMS then
        G.nursery_room_index = 1
    end
    local fam_key = get_nursery_room_resident(G.nursery_room_index)
    local fam = fam_key and G.NURSERY_ROOM_BY_KEY[fam_key]
    local new_room = G.NURSERY_ROOMS[G.nursery_room_index]
    if fam then
        G.nursery_dialogue = get_nursery_dynamic_dialogue(fam, 'present', new_room)
    else
        G.nursery_dialogue = nil
    end
    play_sound('cardSlide2', 1.1, 0.6)
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_open_picker = function(e)
    G.nursery_picker_open = true
    play_sound('card1', 1.0, 0.6)
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_close_picker = function(e)
    G.nursery_picker_open = false
    play_sound('cancel', 1.0, 0.7)
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_picker_prev_page = function(e)
    G.nursery_picker_page = (G.nursery_picker_page or 1) - 1
    if G.nursery_picker_page < 1 then G.nursery_picker_page = 2 end
    play_sound('cardSlide1', 0.9, 0.6)
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_picker_next_page = function(e)
    G.nursery_picker_page = (G.nursery_picker_page or 1) + 1
    if G.nursery_picker_page > 2 then G.nursery_picker_page = 1 end
    play_sound('cardSlide2', 1.1, 0.6)
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_pick_familiar = function(e)
    local fam_key = e and (e.config and (e.config.id or e.config.fam_key)) or (e and e.parent and e.parent.config and e.parent.config.id)
    if fam_key then
        local current_idx = G.nursery_room_index or 1
        set_nursery_room_resident(current_idx, fam_key)
        G.nursery_picker_open = false
        local fam = G.NURSERY_ROOM_BY_KEY[fam_key]
        local room = G.NURSERY_ROOMS[current_idx]
        local quote = get_nursery_dynamic_dialogue(fam, 'present', room)
        G.nursery_dialogue = quote
        play_sound('card1', 1.2, 0.8)
        attention_text({ text = quote, scale = 0.45, hold = 1.4, backdrop_colour = G.C.BLUE, align = 'cm', offset = {x = 0, y = -1.5} })
    end
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_remove_familiar = function(e)
    local current_idx = G.nursery_room_index or 1
    local resident_k = get_nursery_room_resident(current_idx)
    set_nursery_room_resident(current_idx, false)
    if resident_k and get_nursery_lead_companion() == resident_k then
        set_nursery_lead_companion(nil)
    end
    G.nursery_dialogue = nil
    play_sound('cancel', 1.0, 0.7)
    attention_text({ text = "Resident returned to resting quarters.", scale = 0.42, hold = 1.2, backdrop_colour = G.C.GREY, align = 'cm', offset = {x = 0, y = -1.5} })
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_set_as_lead = function(e)
    local current_idx = G.nursery_room_index or 1
    local resident_k = get_nursery_room_resident(current_idx)
    if resident_k then
        set_nursery_lead_companion(resident_k)
        play_sound('gold_seal', 1.2, 0.8)
        local fam = G.NURSERY_ROOM_BY_KEY[resident_k]
        local f_name = fam and fam.name or "Familiar"
        attention_text({ text = f_name .. " will accompany your runs!", scale = 0.45, hold = 1.5, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1.5} })
        G.FUNCS.nursery_refresh_page(e)
    end
end

G.FUNCS.nursery_toggle_lead = function(e)
    set_nursery_lead_companion(nil)
    play_sound('cancel', 1.0, 0.7)
    attention_text({ text = "Companion dismissed from runs.", scale = 0.42, hold = 1.2, backdrop_colour = G.C.GREY, align = 'cm', offset = {x = 0, y = -1.5} })
    G.FUNCS.nursery_refresh_page(e)
end

G.FUNCS.nursery_action_disabled = function(e)
    play_sound('cancel', 1.0, 0.7)
    attention_text({ text = "Assign a resident to activate care actions!", scale = 0.42, hold = 1.2, backdrop_colour = G.C.GREY, align = 'cm', offset = {x = 0, y = -1.5} })
end

G.FUNCS.nursery_update_action_buttons = function()
    if not G.OVERLAY_MENU then return end
    local fam_key = get_nursery_room_resident(G.nursery_room_index or 1)
    if not fam_key then return end
    local cd_feed = get_nursery_cooldown(fam_key, 'feed')
    local cd_play = get_nursery_cooldown(fam_key, 'play')
    local cd_sleep = get_nursery_cooldown(fam_key, 'sleep')

    local feed_label = cd_feed > 0 and ("Feed (" .. cd_feed .. "s)") or "Feed (+35 XP)"
    local play_label = cd_play > 0 and ("Play (" .. cd_play .. "s)") or "Play (+20 XP)"
    local sleep_label = cd_sleep > 0 and ("Sleep (" .. cd_sleep .. "s)") or "Sleep (+60 XP)"

    local feed_col = cd_feed > 0 and {0.2, 0.35, 0.25, 0.6} or G.C.GREEN
    local play_col = cd_play > 0 and {0.2, 0.25, 0.4, 0.6} or G.C.BLUE
    local sleep_col = cd_sleep > 0 and {0.3, 0.2, 0.38, 0.6} or G.C.PURPLE

    local function update_btn(btn_id, new_label, new_col)
        local btn = G.OVERLAY_MENU:get_UIE_by_ID(btn_id)
        if not btn then return end
        btn.config.colour = new_col
        local function find_text(node)
            if not node then return nil end
            if node.UIT == G.UIT.T then return node end
            if node.children then
                for _, ch in pairs(node.children) do
                    local t = find_text(ch)
                    if t then return t end
                end
            end
            return nil
        end
        local txt = find_text(btn)
        if txt and txt.config.text ~= new_label then
            txt.config.text = new_label
            if txt.config.text_drawable then
                txt.config.text_drawable:set(new_label)
            end
            if txt.UIBox then
                txt.UIBox:recalculate()
            end
        end
    end

    update_btn('nursery_btn_play', play_label, play_col)
    update_btn('nursery_btn_feed', feed_label, feed_col)
    update_btn('nursery_btn_sleep', sleep_label, sleep_col)
end

G.FUNCS.nursery_action_feed = function(e)
    local fam_key = get_nursery_room_resident(G.nursery_room_index or 1)
    local fam = fam_key and G.NURSERY_ROOM_BY_KEY[fam_key]
    if not fam then return end
    local cd = get_nursery_cooldown(fam.key, 'feed')
    if cd > 0 then
        play_sound('cancel', 1.0, 0.7)
        attention_text({ text = "Feeding is resting! Ready in " .. cd .. "s", scale = 0.45, hold = 1.0, backdrop_colour = G.C.GREY, align = 'cm', offset = {x = 0, y = -1.5} })
        return
    end
    set_nursery_cooldown(fam.key, 'feed', 90)
    local current_room = G.NURSERY_ROOMS[G.nursery_room_index or 1]
    local quote = get_nursery_dynamic_dialogue(fam, 'feed', current_room)
    G.nursery_dialogue = quote
    local leveled = add_nursery_exp(fam.key, 35)
    play_sound('tarot2', 1.3, 0.7)
    play_sound('card1', 1.4, 0.8)
    if leveled then
        play_sound('gold_seal', 1.2, 0.8)
        attention_text({ text = "LEVEL UP! Lv. " .. get_nursery_data(fam.key).level, scale = 0.8, hold = 1.6, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1.5} })
        G.FUNCS.nursery_refresh_page(e)
    else
        attention_text({ text = quote, scale = 0.45, hold = 1.4, backdrop_colour = G.C.GREEN, align = 'cm', offset = {x = 0, y = -1.5} })
        if update_nursery_quote_display then update_nursery_quote_display(quote) end
        if update_nursery_exp_display then update_nursery_exp_display(fam.key) end
        if G.FUNCS.nursery_update_action_buttons then G.FUNCS.nursery_update_action_buttons() end
    end
end

G.FUNCS.nursery_action_play = function(e)
    local fam_key = get_nursery_room_resident(G.nursery_room_index or 1)
    local fam = fam_key and G.NURSERY_ROOM_BY_KEY[fam_key]
    if not fam then return end
    local cd = get_nursery_cooldown(fam.key, 'play')
    if cd > 0 then
        play_sound('cancel', 1.0, 0.7)
        attention_text({ text = "Playtime is resting! Ready in " .. cd .. "s", scale = 0.45, hold = 1.0, backdrop_colour = G.C.GREY, align = 'cm', offset = {x = 0, y = -1.5} })
        return
    end
    set_nursery_cooldown(fam.key, 'play', 45)
    local current_room = G.NURSERY_ROOMS[G.nursery_room_index or 1]
    local quote = get_nursery_dynamic_dialogue(fam, 'play', current_room)
    G.nursery_dialogue = quote
    local leveled = add_nursery_exp(fam.key, 20)
    play_sound('chips1', 1.4, 0.9)
    play_sound('chips2', 1.2, 0.8)
    if leveled then
        play_sound('gold_seal', 1.2, 0.8)
        attention_text({ text = "LEVEL UP! Lv. " .. get_nursery_data(fam.key).level, scale = 0.8, hold = 1.6, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1.5} })
        G.FUNCS.nursery_refresh_page(e)
    else
        attention_text({ text = quote, scale = 0.45, hold = 1.4, backdrop_colour = G.C.BLUE, align = 'cm', offset = {x = 0, y = -1.5} })
        if update_nursery_quote_display then update_nursery_quote_display(quote) end
        if update_nursery_exp_display then update_nursery_exp_display(fam.key) end
        if G.FUNCS.nursery_update_action_buttons then G.FUNCS.nursery_update_action_buttons() end
    end
end

G.FUNCS.nursery_action_sleep = function(e)
    local fam_key = get_nursery_room_resident(G.nursery_room_index or 1)
    local fam = fam_key and G.NURSERY_ROOM_BY_KEY[fam_key]
    if not fam then return end
    local cd = get_nursery_cooldown(fam.key, 'sleep')
    if cd > 0 then
        play_sound('cancel', 1.0, 0.7)
        attention_text({ text = "Deep asleep! Waking up in " .. cd .. "s", scale = 0.45, hold = 1.0, backdrop_colour = G.C.GREY, align = 'cm', offset = {x = 0, y = -1.5} })
        return
    end
    set_nursery_cooldown(fam.key, 'sleep', 180)
    local current_room = G.NURSERY_ROOMS[G.nursery_room_index or 1]
    local quote = get_nursery_dynamic_dialogue(fam, 'sleep', current_room)
    G.nursery_dialogue = quote
    local leveled = add_nursery_exp(fam.key, 60)
    play_sound('foil2', 0.85, 0.6)
    play_sound('tarot1', 0.9, 0.7)
    if leveled then
        play_sound('gold_seal', 1.2, 0.8)
        attention_text({ text = "LEVEL UP! Lv. " .. get_nursery_data(fam.key).level, scale = 0.8, hold = 1.6, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1.5} })
        G.FUNCS.nursery_refresh_page(e)
    else
        attention_text({ text = quote, scale = 0.45, hold = 1.4, backdrop_colour = G.C.PURPLE, align = 'cm', offset = {x = 0, y = -1.5} })
        if update_nursery_quote_display then update_nursery_quote_display(quote) end
        if update_nursery_exp_display then update_nursery_exp_display(fam.key) end
        if G.FUNCS.nursery_update_action_buttons then G.FUNCS.nursery_update_action_buttons() end
    end
end

G.FUNCS.nursery_tick_cooldowns = function()
    if not G.OVERLAY_MENU or G.nursery_picker_open or G.nursery_fam_dragging then return end
    local fam_key = get_nursery_room_resident(G.nursery_room_index or 1)
    if not fam_key then return end
    local cd_feed = get_nursery_cooldown(fam_key, 'feed')
    local cd_play = get_nursery_cooldown(fam_key, 'play')
    local cd_sleep = get_nursery_cooldown(fam_key, 'sleep')
    local has_active = (cd_feed > 0 or cd_play > 0 or cd_sleep > 0)
    if has_active or G.nursery_had_cooldown then
        G.nursery_had_cooldown = has_active
        G.FUNCS.nursery_update_action_buttons()
    end
end
if create_tabs then
    local orig_create_tabs = create_tabs
    function create_tabs(args)
        if setup_reality_warp_shop_unlocks then
            pcall(setup_reality_warp_shop_unlocks)
        end
        if reality_warp_purge_trials_from_challenges then
            pcall(reality_warp_purge_trials_from_challenges)
        end
        if args and args.tabs then
            for i = #args.tabs, 1, -1 do
                local tab = args.tabs[i]
                if tab then
                    local lbl = string.lower(tab.label or '')
                    local targs = string.lower(tostring(tab.tab_definition_function_args or ''))
                    local is_trial = string.find(lbl, 'trial') or string.find(targs, 'trial') or (G.UIDEF and tab.tab_definition_function == G.UIDEF.outsider_trials_tab)
                    local is_nursery = string.find(lbl, 'nursery') or string.find(targs, 'nursery') or (G.UIDEF and tab.tab_definition_function == G.UIDEF.nursery_tab)
                    if is_trial or is_nursery then
                        table.remove(args.tabs, i)
                    end
                end
            end
        end
        return orig_create_tabs(args)
    end
end

if create_UIBox_run_setup then
    local orig_create_UIBox_run_setup = create_UIBox_run_setup
    function create_UIBox_run_setup(...)
        if reality_warp_purge_trials_from_challenges then
            pcall(reality_warp_purge_trials_from_challenges)
        end
        return orig_create_UIBox_run_setup(...)
    end
end

if G.FUNCS and G.FUNCS.setup_run then
    local orig_setup_run = G.FUNCS.setup_run
    G.FUNCS.setup_run = function(e)
        if reality_warp_purge_trials_from_challenges then
            pcall(reality_warp_purge_trials_from_challenges)
        end
        return orig_setup_run(e or { config = {}, UIBox = {} })
    end
end

if setup_reality_warp_shop_unlocks then
    pcall(setup_reality_warp_shop_unlocks)
end

if G and G.STAGE == G.STAGES.MAIN_MENU then
    apply_reality_warp_menu_bg()
    apply_reality_warp_title_asset()
    spawn_main_menu_secret_joker()
    create_reality_warp_title_label()
end


local function has_secret_joker_equipped()
    if not (G and G.jokers and G.jokers.cards) then return false end
    for _, j in ipairs(G.jokers.cards) do
        if not j.debuff and j.config and j.config.center then
            local c = j.config.center
            if c.is_secret or c.is_amalgam or c.rarity == 'Secret' or c.rarity == 'Amalgam' then
                return true
            end
        end
    end
    return false
end

local function is_special_pack_open()
    local is_pack_state = G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.TAROT_PACK or
                          G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.STANDARD_PACK or
                          G.STATE == G.STATES.BUFFOON_PACK or (G.pack_cards and G.pack_cards.cards and #G.pack_cards.cards > 0)
    if is_pack_state and G.booster_pack then
        local k = (G.booster_pack.config and G.booster_pack.config.center and G.booster_pack.config.center.key) or ''
        local kind = (G.booster_pack.ability and G.booster_pack.ability.kind) or ''
        if string.find(k, 'job_pack') or kind == 'Job' or string.find(k, 'potion') or string.find(k, 'witch') or string.find(k, 'secret') then
            return true
        end
    end
    return false
end

local function is_excluded_music_state()
    if not G then return true end
    if (G.STAGE and G.STAGE ~= G.STAGES.RUN) or G.STATE == G.STATES.SPLASH or G.STATE == G.STATES.GAME_OVER then
        return true
    end
    if G.STATE == G.STATES.SHOP or (G.shop and not G.shop.REMOVED) then
        return true
    end
    if G.STATE == G.STATES.TAROT_PACK or (G.booster_pack_sparkles and not G.booster_pack_sparkles.REMOVED) then
        return true
    end
    if G.booster_pack and not G.booster_pack.REMOVED and G.booster_pack.ability then
        local k = G.booster_pack.ability.kind or ''
        local n = G.booster_pack.ability.name or ''
        if k == 'Tarot' or string.find(n, 'Arcana') or string.find(n, 'Tarot') then
            return true
        end
    end
    if G.STATE == G.STATES.PLANET_PACK or (G.booster_pack_meteors and not G.booster_pack_meteors.REMOVED) then
        return true
    end
    if G.booster_pack and not G.booster_pack.REMOVED and G.booster_pack.ability then
        local k = G.booster_pack.ability.kind or ''
        local n = G.booster_pack.ability.name or ''
        if k == 'Planet' or string.find(n, 'Celestial') or string.find(n, 'Planet') then
            return true
        end
    end
    return false
end

local function is_secret_music_enabled()
    local cfg = (get_reality_warp_config and get_reality_warp_config())
    if cfg and (cfg.botg_music == false or cfg.secret_power_theme == false) then
        return false
    end
    return true
end

if SMODS and SMODS.Sound then
    local function should_play_orchestral()
        if not is_secret_music_enabled() then return false end
        return G.GAME and G.GAME.battle_of_gods and true or false
    end

    SMODS.Sound {
        key = "music_bog_packs",
        path = "bog_packs.ogg",
        pitch = 1.0,
        volume = 0.65,
        select_music_track = function(self)
            if not should_play_orchestral() then return nil end
            if (G.STAGE and G.STAGE ~= G.STAGES.RUN) or G.STATE == G.STATES.SPLASH or G.STATE == G.STATES.GAME_OVER then return nil end
            if is_special_pack_open() or
               (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.PLANET_PACK or
                G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.STANDARD_PACK or
                G.STATE == G.STATES.BUFFOON_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) or
               (G.booster_pack and not G.booster_pack.REMOVED) then
                return 40
            end
        end
    }

    SMODS.Sound {
        key = "music_bog_shop",
        path = "bog_shop.ogg",
        pitch = 1.0,
        volume = 0.6,
        select_music_track = function(self)
            if not should_play_orchestral() then return nil end
            if (G.STAGE and G.STAGE ~= G.STAGES.RUN) or G.STATE == G.STATES.SPLASH or G.STATE == G.STATES.GAME_OVER then return nil end
            if G.STATE == G.STATES.SHOP or (G.shop and not G.shop.REMOVED) then
                return 35
            end
        end
    }

    SMODS.Sound {
        key = "music_bog_boss",
        path = "bog_boss.ogg",
        pitch = 1.0,
        volume = 0.7,
        select_music_track = function(self)
            if not should_play_orchestral() then return nil end
            if (G.STAGE and G.STAGE ~= G.STAGES.RUN) or G.STATE == G.STATES.SPLASH or G.STATE == G.STATES.GAME_OVER then return nil end
            local is_showdown = G.GAME and G.GAME.blind and G.GAME.blind.boss and
                (G.GAME.blind.showdown or (G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.showdown))
            if is_showdown then
                return 30
            end
        end
    }

    SMODS.Sound {
        key = "music_bog_normal",
        path = "bog_normal.ogg",
        pitch = 1.0,
        volume = 0.65,
        select_music_track = function(self)
            if not should_play_orchestral() then return nil end
            if (G.STAGE and G.STAGE ~= G.STAGES.RUN) or G.STATE == G.STATES.SPLASH or G.STATE == G.STATES.GAME_OVER then return nil end
            return 25
        end
    }
end

if modulate_sound then
    local orig_modulate_sound = modulate_sound
    function modulate_sound(dt)
        local enabled = not (is_secret_music_enabled and not is_secret_music_enabled())
        local is_custom_music = enabled and (
                          G.GAME and G.GAME.battle_of_gods and not is_excluded_music_state()
        )
        local sound_set = G.SETTINGS and G.SETTINGS.SOUND
        if is_custom_music and sound_set and sound_set.music_volume and sound_set.game_sounds_volume then
            local real_music_vol = sound_set.music_volume
            local game_vol_factor = (sound_set.game_sounds_volume or 100) / 100
            sound_set.music_volume = real_music_vol * game_vol_factor
            orig_modulate_sound(dt)
            sound_set.music_volume = real_music_vol
        else
            orig_modulate_sound(dt)
        end
    end
end

local charles_endgame_quotes = {
    "Every legendary journey starts with a single step! You're making steady, honorable progress.",
    "A solid foundation! Take your time, master the deck's flow, and you will achieve greatness.",
    "Splendid effort! True mastery is forged through patient steps, and you are well on your way.",
    "Impressive resilience! Holding your ground against harsher stakes demonstrates true fortitude.",
    "Look at how far you've climbed! These intermediate trials only prove how formidable you've become.",
    "Each hand played sharpens your mind. You're conquering hurdles that defeat lesser players!",
    "Astonishing! Conquering these brutal stakes demands absolute mastery, and you truly possess it.",
    "Enduring the relentless pressure of high stakes... what a magnificent display of tactical skill!",
    "A heroic battle against insurmountable odds! Win or lose, your performance was legendary.",
    "Hold your head high, friend! Every run adds to your legacy, and the next victory is already calling."
}

local kyra_endgame_quotes = {
    "*Yawn*... Finished already? Whatever, pack your deck so I can enjoy my peace.",
    "A basic stake run... was I supposed to be paying attention or something?",
    "You won? You lost? Honestly, my bubbling kettle demands more respect than this.",
    "Cool story. Are you going to leave now, or are you just going to linger here?",
    "Don't look at me expecting applause. I barely stayed awake watching that.",
    "Another standard attempt in the books. Can I return to my alchemy now?",
    "I've seen freshly brewed homunculi play with more flair. But do as you please.",
    "...Orange Stake? Huh. Fine, I'll admit it: that wasn't completely terrible.",
    "Surviving Gold Stake odds without self-destructing? Color me mildly intrigued.",
    "Tch... I suppose you actually have some genuine talent after all. Don't let it go to your head."
}

local sally_endgame_quotes = {
    "GG! That was such an intense match! Hit restart and let's queue up for another run right now!",
    "No way we're logging off yet! Just one more run, pleaaase, the RNG is about to peak!",
    "You gained massive EXP from that session! Let's hit Rematch and crush the next run!",
    "A true gamer never quits after a close run! It's time for New Game Plus, baby!",
    "That boss blind had insane DPS, but our combo synergy was fire! Run it back immediately!",
    "Gaming is life! Win or lose, that rush is why roguelikes are the best genre ever made!",
    "Quick reload! The RNG gods are definitely saving a god-tier seed for the next attempt!",
    "Insert coin to continue! You can't leave the arcade cabinet now, we're on a hot streak!",
    "Respawn timer is already zero! Boot up a fresh seed and let's set a new personal record!",
    "That was peak competitive gameplay! Grab your controller, let's dive straight back in!"
}

local function get_endgame_character_center(name)
    if not G.P_CENTERS then return nil end
    local candidates = {
        'j_reality_warp_' .. name,
        'j_Witch brew_' .. name,
        'j_' .. name,
        name
    }
    for _, k in ipairs(candidates) do
        if G.P_CENTERS[k] then return G.P_CENTERS[k] end
    end
    for k, v in pairs(G.P_CENTERS) do
        if string.find(string.lower(k), name, 1, true) and v.set == 'Joker' then
            return v
        end
    end
    return nil
end

local function wrap_endgame_text(text, max_chars)
    max_chars = max_chars or 36
    local lines = {}
    local current = ""
    for word in string.gmatch(text, "%S+") do
        if #current == 0 then
            current = word
        elseif #current + 1 + #word <= max_chars then
            current = current .. " " .. word
        else
            table.insert(lines, current)
            current = word
        end
    end
    if #current > 0 then
        table.insert(lines, current)
    end
    return lines
end

local function pick_endgame_quote(char_key, stake)
    stake = stake or 1
    if char_key == 'charles' then
        if stake <= 3 then
            local pool = { charles_endgame_quotes[1], charles_endgame_quotes[2], charles_endgame_quotes[3] }
            return pseudorandom_element(pool, pseudoseed('charles_stake')) or pool[1]
        elseif stake <= 6 then
            local pool = { charles_endgame_quotes[4], charles_endgame_quotes[5], charles_endgame_quotes[6] }
            return pseudorandom_element(pool, pseudoseed('charles_stake')) or pool[1]
        else
            local pool = { charles_endgame_quotes[7], charles_endgame_quotes[8], charles_endgame_quotes[9], charles_endgame_quotes[10] }
            return pseudorandom_element(pool, pseudoseed('charles_stake')) or pool[1]
        end
    elseif char_key == 'kyra' then
        if stake >= 7 then
            local pool = { kyra_endgame_quotes[8], kyra_endgame_quotes[9], kyra_endgame_quotes[10] }
            return pseudorandom_element(pool, pseudoseed('kyra_stake')) or pool[1]
        else
            local pool = { kyra_endgame_quotes[1], kyra_endgame_quotes[2], kyra_endgame_quotes[3], kyra_endgame_quotes[4], kyra_endgame_quotes[5], kyra_endgame_quotes[6], kyra_endgame_quotes[7] }
            return pseudorandom_element(pool, pseudoseed('kyra_stake')) or pool[1]
        end
    else
        return pseudorandom_element(sally_endgame_quotes, pseudoseed('sally_endgame')) or sally_endgame_quotes[1]
    end
end

if G and G.UIDEF and G.UIDEF.speech_bubble then
    local orig_speech_bubble = G.UIDEF.speech_bubble
    function G.UIDEF.speech_bubble(text_key, loc_vars)
        if loc_vars and loc_vars.custom_quip then
            local row = {}
            if loc_vars.char_name then
                row[#row+1] = {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = loc_vars.char_name, scale = 0.32, colour = loc_vars.char_colour or G.C.GOLD, shadow = true } }
                    }
                }
            end
            for _, l in ipairs(loc_vars.lines or {}) do
                row[#row+1] = {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = {
                        { n = G.UIT.T, config = { text = l, scale = 0.35, colour = G.C.UI.TEXT_DARK, shadow = false } }
                    }
                }
            end
            return {
                n = G.UIT.ROOT,
                config = { align = "cm", minh = 1, r = 0.3, padding = 0.07, minw = 1, colour = G.C.JOKER_GREY, shadow = true },
                nodes = {
                    { n = G.UIT.C, config = { align = "cm", minh = 1, r = 0.2, padding = 0.1, minw = 1, colour = G.C.WHITE },
                      nodes = {
                          { n = G.UIT.C, config = { align = "cm", minh = 1, r = 0.2, padding = 0.03, minw = 1, colour = G.C.WHITE },
                            nodes = row }
                      }
                    }
                }
            }
        end
        return orig_speech_bubble(text_key, loc_vars)
    end
end

if Card_Character and Card_Character.add_speech_bubble then
    local orig_add_speech_bubble = Card_Character.add_speech_bubble
    function Card_Character:add_speech_bubble(text_key, align, loc_vars)
        loc_vars = loc_vars or {}
        if loc_vars.quip then
            local chars = {
                { key = 'charles', name = 'Charles', colour = G.C.GOLD },
                { key = 'kyra',    name = 'Kyra',    colour = G.C.PURPLE },
                { key = 'sally',   name = 'Sally',   colour = HEX('e8413e') }
            }
            local chosen = pseudorandom_element(chars, pseudoseed('endgame_joker_char')) or chars[1]
            local center = get_endgame_character_center(chosen.key)
            if center and self.children and self.children.card then
                self.children.card:set_ability(center)
                self.children.card:juice_up(0.6, 0.6)
            end

            local stake = (G.GAME and G.GAME.stake) or 1
            local quote_str = pick_endgame_quote(chosen.key, stake)
            local lines = wrap_endgame_text(quote_str, 36)

            loc_vars.custom_quip = true
            loc_vars.lines = lines
            loc_vars.char_name = chosen.name
            loc_vars.char_colour = chosen.colour
        end
        return orig_add_speech_bubble(self, text_key, align, loc_vars)
    end
end

if Back and Back.trigger_effect then
    local orig_back_trigger_effect = Back.trigger_effect
    function Back:trigger_effect(args)
        local nu_chip, nu_mult = orig_back_trigger_effect(self, args)
        if args and args.context == 'final_scoring_step' and G.GAME and G.GAME.blind and not G.GAME.blind.disabled then
            local bname = G.GAME.blind.name
            local bkey = G.GAME.blind.key or (G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key)

            local is_chronos = (bname == 'Chronos' or bkey == 'chronos' or bkey == 'bl_chronos' or bkey == 'bl_reality_warp_chronos')
            if is_chronos then
                local check_chips = nu_chip or args.chips or 0
                local check_mult = nu_mult or args.mult or 0
                local cur_chips = G.GAME.chips or 0
                local req = (G.GAME.blind and G.GAME.blind.chips) or 0
                if (cur_chips + (check_chips * check_mult)) >= req or (check_chips * check_mult) >= req then
                    nu_chip = mod_chips(math.max(1, math.floor(check_chips * 0.90)))
                    nu_mult = mod_mult(math.max(1, math.floor(check_mult * 0.90)))
                    update_hand_text({delay = 0}, {chips = nu_chip, mult = nu_mult})
                    attention_text({
                        text = 'Time Dilated! X0.90',
                        scale = 1.1,
                        hold = 1.4,
                        major = G.play or G.HUD_blind,
                        backdrop_colour = HEX('6a0dad'),
                        align = 'cm'
                    })
                    play_sound('timpani', 0.8, 0.7)
                end
            end

            local is_guillotine = (bname == 'The Guillotine' or bname == 'guillotine' or bkey == 'guillotine' or bkey == 'bl_guillotine' or bkey == 'bl_reality_warp_guillotine')
            if is_guillotine and pseudorandom('guillotine') < ((G.GAME and G.GAME.probabilities.normal or 1) / 5) then
                nu_chip = mod_chips(0)
                nu_mult = mod_mult(0)
                update_hand_text({delay = 0}, {chips = 0, mult = 0})
                attention_text({
                    text = 'Guillotined! 0 Score!',
                    scale = 1.3,
                    hold = 1.6,
                    major = G.play or G.HUD_blind,
                    backdrop_colour = HEX('6b0f1a'),
                    align = 'cm'
                })
                play_sound('slice1', 0.8, 0.8)
            end

            local is_doppel = (bname == 'The Doppelgänger' or bname == 'doppelganger' or bkey == 'doppelganger' or bkey == 'bl_doppelganger' or bkey == 'bl_reality_warp_doppelganger')
            if is_doppel and G.GAME.doppel_triggered_in_hand then
                G.GAME.doppel_triggered_in_hand = nil
                local check_c = nu_chip or args.chips or 0
                local check_m = nu_mult or args.mult or 0
                nu_chip = mod_chips(math.max(1, math.floor(check_c * 0.25)))
                nu_mult = mod_mult(math.max(1, math.floor(check_m * 0.25)))
                update_hand_text({delay = 0}, {chips = nu_chip, mult = nu_mult})
                attention_text({
                    text = '÷4 Chips & Mult!',
                    scale = 1.1,
                    hold = 1.4,
                    major = G.play or G.HUD_blind,
                    backdrop_colour = HEX('1c2833'),
                    align = 'cm'
                })
                play_sound('chips2', 0.8, 0.7)
            end
        end
        return nu_chip, nu_mult
    end
end

if Card and Card.use_consumeable then
    local orig_use_consumeable_code = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local ret = orig_use_consumeable_code(self, area, copier)
        if G.GAME and G.GAME.blind and (G.GAME.blind.name == 'The Code' or G.GAME.blind.key == 'bl_reality_warp_code' or (G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key == 'bl_reality_warp_code')) and not G.GAME.blind.disabled then
            if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
                local destroyable = {}
                for _, j in ipairs(G.jokers.cards) do
                    if not j.ability or not j.ability.eternal then
                        table.insert(destroyable, j)
                    end
                end
                local chosen_j = (#destroyable > 0) and pseudorandom_element(destroyable, pseudoseed('code_destruct')) or pseudorandom_element(G.jokers.cards, pseudoseed('code_destruct'))
                if chosen_j then
                    chosen_j.destroyed = true
                    chosen_j:start_dissolve()
                end
            end
            if G.GAME.blind.chips then
                G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 1.25)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                if G.HUD_blind then G.HUD_blind:recalculate() end
            end
            attention_text({
                text = 'Code Triggered! X1.25 & Joker Destroyed!',
                scale = 0.9,
                hold = 1.4,
                major = G.play or G.HUD_blind,
                backdrop_colour = HEX('00f0ff'),
                align = 'cm'
            })
            play_sound('slice1', 0.8, 0.7)
        end
        return ret
    end
end

local function cleanup_charles_coliseo_area()
    if G.charles_coliseo_area then
        if G.charles_coliseo_area.cards then
            for _, c in ipairs(G.charles_coliseo_area.cards) do c:remove() end
        end
        G.charles_coliseo_area:remove()
        G.charles_coliseo_area = nil
    end
end

if G.FUNCS then
    G.FUNCS.charles_coliseo_go_to_shop = function(e)
        cleanup_charles_coliseo_area()
        if G.FUNCS.exit_overlay_menu then
            G.FUNCS.exit_overlay_menu()
        end
        if G.OVERLAY_MENU then
            G.OVERLAY_MENU:remove()
            G.OVERLAY_MENU = nil
        end
        if G.blind_prompt_box then
            G.blind_prompt_box:remove()
            G.blind_prompt_box = nil
        end
        if G.blind_select_opts then
            for _, opt in pairs(G.blind_select_opts) do
                if opt and opt.remove then
                    pcall(function() opt:remove() end)
                end
            end
            G.blind_select_opts = nil
        end
        if G.blind_select then
            G.blind_select:remove()
            G.blind_select = nil
        end
        if G.I and G.I.UIBOX then
            for i = #G.I.UIBOX, 1, -1 do
                local uibox = G.I.UIBOX[i]
                if uibox and uibox.get_UIE_by_ID and (uibox:get_UIE_by_ID('prompt_dynatext1') or uibox:get_UIE_by_ID('prompt_dynatext2')) then
                    pcall(function() uibox:remove() end)
                end
            end
        end
        if G.GAME and G.GAME.current_round then
            if not G.GAME.current_round.voucher then
                if SMODS and SMODS.get_next_vouchers then
                    G.GAME.current_round.voucher = SMODS.get_next_vouchers()
                elseif get_next_voucher_key then
                    G.GAME.current_round.voucher = get_next_voucher_key()
                end
            end
        end
        G.STATE = G.STATES.SHOP
        G.STATE_COMPLETE = false
    end

    G.FUNCS.charles_coliseo_continue = function(e)
        cleanup_charles_coliseo_area()
        if G.FUNCS.exit_overlay_menu then
            G.FUNCS.exit_overlay_menu()
        end
        if G.OVERLAY_MENU then
            G.OVERLAY_MENU:remove()
            G.OVERLAY_MENU = nil
        end
    end

    if G.FUNCS.exit_overlay_menu then
        local orig_exit_overlay_menu_charles = G.FUNCS.exit_overlay_menu
        G.FUNCS.exit_overlay_menu = function(...)
            cleanup_charles_coliseo_area()
            return orig_exit_overlay_menu_charles(...)
        end
    end
end

function prompt_charles_coliseo_choice()
    if not (create_UIBox_generic_options and G.FUNCS and G.FUNCS.overlay_menu) then return end
    if G.OVERLAY_MENU then return end

    cleanup_charles_coliseo_area()

    local c_area = CardArea(0, 0, G.CARD_W * 1.15, G.CARD_H * 1.15, {
        card_limit = 1,
        type = 'title',
        highlight_limit = 0
    })
    local c_center = (get_endgame_character_center and get_endgame_character_center('charles')) or (G.P_CENTERS and G.P_CENTERS.j_reality_warp_charles) or (G.P_CENTERS and G.P_CENTERS.j_joker)
    local c_card = Card(0, 0, G.CARD_W * 1.05, G.CARD_H * 1.05, G.P_CARDS.empty, c_center, { bypass_discovery_center = true, bypass_discovery_ui = true })
    c_card.states.hover.can = false
    c_card.states.click.can = false
    c_card.states.drag.can = false
    c_area:emplace(c_card)
    G.charles_coliseo_area = c_area

    for i = 1, 4 do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.12 * i,
            blockable = false,
            blocking = false,
            func = function()
                play_sound('voice' .. math.random(1, 11), 1 + math.random() * 0.2, 0.6)
                if c_card and c_card.juice_up then c_card:juice_up(0.2, 0.2) end
                return true
            end
        }))
    end

    local t = create_UIBox_generic_options({
        no_back = true,
        back_func = 'charles_coliseo_continue',
        contents = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.15 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            { n = G.UIT.O, config = { object = c_area } }
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm", r = 0.25, padding = 0.08, colour = G.C.JOKER_GREY, shadow = true },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cm", r = 0.18, padding = 0.2, minw = 5.2, colour = G.C.WHITE },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", padding = 0.04 },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Charles", scale = 0.52, colour = G.C.GOLD, shadow = true } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", padding = 0.03 },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "\"Welcome to the Colosseum, challenger!\"", scale = 0.38, colour = G.C.UI.TEXT_DARK } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", padding = 0.03 },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Would you like to enter the Shop before the first blind,", scale = 0.35, colour = G.C.UI.TEXT_DARK } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm", padding = 0.03 },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "or charge straight into the arena as you are?", scale = 0.35, colour = G.C.UI.TEXT_DARK } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.2 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            padding = 0.15,
                            minw = 2.8,
                            minh = 0.75,
                            r = 0.15,
                            hover = true,
                            colour = G.C.GOLD,
                            button = 'charles_coliseo_go_to_shop',
                            shadow = true
                        },
                        nodes = {
                            { n = G.UIT.T, config = { text = "🛒 ENTER SHOP", scale = 0.45, colour = G.C.BLACK, shadow = false } }
                        }
                    },
                    { n = G.UIT.B, config = { w = 0.4, h = 0.1 } },
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            padding = 0.15,
                            minw = 2.8,
                            minh = 0.75,
                            r = 0.15,
                            hover = true,
                            colour = G.C.BLUE,
                            button = 'charles_coliseo_continue',
                            shadow = true
                        },
                        nodes = {
                            { n = G.UIT.T, config = { text = "⚔️ CONTINUE", scale = 0.45, colour = G.C.WHITE, shadow = true } }
                        }
                    }
                }
            }
        }
    })
    G.FUNCS.overlay_menu{ definition = t }
end

if Game and Game.update_blind_select then
    local orig_update_blind_select_charles = Game.update_blind_select
    function Game:update_blind_select(dt)
        local was_incomplete = not G.STATE_COMPLETE
        orig_update_blind_select_charles(self, dt)
        if was_incomplete and G.GAME and G.GAME.coliseo_deck and not G.GAME.charles_shop_offered and G.GAME.round_resets and (not G.GAME.round_resets.ante or G.GAME.round_resets.ante == 1) then
            G.GAME.charles_shop_offered = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.6,
                blocking = false,
                func = function()
                    if G.GAME and G.GAME.coliseo_deck and (not G.GAME.round_resets.ante or G.GAME.round_resets.ante == 1) and not G.OVERLAY_MENU then
                        prompt_charles_coliseo_choice()
                    end
                    return true
                end
            }))
        end
    end
end

local orig_card_calculate_seal = Card.calculate_seal
function Card:calculate_seal(context, ...)
    local ret = orig_card_calculate_seal and orig_card_calculate_seal(self, context, ...)
    if context and context.discard then
        for _, k in ipairs({'gardener_job', 'detective_job', 'chef_job', 'archaeologist_job'}) do
            if self.ability and self.ability[k] and SMODS.Stickers and SMODS.Stickers[k] and SMODS.Stickers[k].calculate then
                local o = SMODS.Stickers[k]:calculate(self, { discard = true, other_card = self })
                if o then card_eval_status_text(self, 'extra', nil, nil, nil, o) end
            end
        end
    end
    return ret
end

if SMODS and SMODS.calculate_context then
    local orig_smods_calc_context = SMODS.calculate_context
    function SMODS.calculate_context(context, return_table, ...)
        local ret = orig_smods_calc_context(context, return_table, ...)
        if context and context.first_hand_drawn and G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if c.ability and c.ability.detective_job and SMODS.Stickers and SMODS.Stickers['detective_job'] and SMODS.Stickers['detective_job'].calculate then
                    local o = SMODS.Stickers['detective_job']:calculate(c, context)
                    if o then card_eval_status_text(c, 'extra', nil, nil, nil, o) end
                end
            end
        end
        return ret
    end
end

local orig_evaluate_play = evaluate_play
if orig_evaluate_play then
    evaluate_play = function(...)
        if G.play and G.play.cards then
            for _, c in ipairs(G.play.cards) do
                if c.ability then
                    c.ability.played_this_ante = true
                end
            end
        end
        return orig_evaluate_play(...)
    end
end

local orig_ease_ante = ease_ante
if orig_ease_ante then
    ease_ante = function(mod, ...)
        if G.playing_cards then
            for _, c in ipairs(G.playing_cards) do
                if c.ability then
                    c.ability.played_this_ante = nil
                end
            end
        end
        return orig_ease_ante(mod, ...)
    end
end

if AnimatedSprite then
    local orig_anim_set_sprite_pos = AnimatedSprite.set_sprite_pos
    function AnimatedSprite:set_sprite_pos(sprite_pos)
        local is_witch_blind = self.atlas and (
            self.atlas.name == 'reality_warp_blinds' or self.atlas.key == 'reality_warp_blinds' or
            (self.atlas.name and string.find(self.atlas.name, 'reality_warp_blinds')) or
            (self.atlas.key and string.find(self.atlas.key, 'reality_warp_blinds'))
        )
        local is_witch_fam = self.atlas and (
            self.atlas.name == 'reality_warp_familiars' or self.atlas.key == 'reality_warp_familiars' or
            (self.atlas.name and string.find(self.atlas.name, 'familiars')) or
            (self.atlas.key and string.find(self.atlas.key, 'familiars'))
        )
        if is_witch_blind or is_witch_fam then
            local sp_x = sprite_pos and sprite_pos.x or 0
            local sp_y = sprite_pos and sprite_pos.y or 0
            self.animation = {
                x = sp_x,
                y = sp_y,
                frames = 1,
                current = 0,
                w = self.scale.x,
                h = self.scale.y
            }
            self.current_animation = {
                current = 0,
                frames = 1,
                w = self.scale.x,
                h = self.scale.y,
                frame_index = 0,
                frame_duration = 1
            }
            self.frame_offset = 0
            self.image_dims = self.image_dims or {}
            self.image_dims[1], self.image_dims[2] = self.atlas.image:getDimensions()
            self.sprite = love.graphics.newQuad(
                self.scale.x * sp_x,
                self.scale.y * sp_y,
                self.scale.x,
                self.scale.y,
                self.image_dims[1], self.image_dims[2]
            )
            self.offset_seconds = G.TIMERS.REAL
            return
        end
        return orig_anim_set_sprite_pos(self, sprite_pos)
    end

    local orig_anim_draw_self = AnimatedSprite.draw_self
    function AnimatedSprite:draw_self(...)
        local is_witch_blind = self.atlas and (
            self.atlas.name == 'reality_warp_blinds' or self.atlas.key == 'reality_warp_blinds' or
            (self.atlas.name and string.find(self.atlas.name, 'reality_warp_blinds')) or
            (self.atlas.key and string.find(self.atlas.key, 'reality_warp_blinds'))
        )
        local is_witch_fam = self.atlas and (
            self.atlas.name == 'reality_warp_familiars' or self.atlas.key == 'reality_warp_familiars' or
            (self.atlas.name and string.find(self.atlas.name, 'familiars')) or
            (self.atlas.key and string.find(self.atlas.key, 'familiars'))
        )
        if is_witch_blind or is_witch_fam then
            if not self.states.visible then return end
            if is_witch_fam and self.role and self.role.draw_major then
                local major = self.role.draw_major
                if major.removed then return end
                local is_coll = (major.bypass_discovery_center or major.bypass_discovery_ui) or (major.area and (major.area.config and major.area.config.collection or (major.params and major.params.bypass_discovery_center))) or (G.OVERLAY_MENU ~= nil)
                if not is_coll and G.STAGE == G.STAGES.RUN and (major.area and major.area ~= G.botg_familiars) then
                    return
                end
            end
            prep_draw(self, 1)
            local vw = (self.VT and self.VT.w and self.VT.w > 0) and self.VT.w or 1
            local vh = (self.VT and self.VT.h and self.VT.h > 0) and self.VT.h or 1
            local s = math.max(self.scale.x / vw, self.scale.y / vh)
            if is_witch_fam and G.BOTG_FAMILIAR_CARD_SCALE then
                s = s / G.BOTG_FAMILIAR_CARD_SCALE
            end
            love.graphics.scale(1 / s, 1 / s)
            love.graphics.setColor(G.C.WHITE)
            local draw_x = (vw * s - self.scale.x) / 2
            local draw_y = (vh * s - self.scale.y) / 2
            love.graphics.draw(
                self.atlas.image,
                self.sprite,
                draw_x, draw_y,
                0,
                1, 1
            )
            love.graphics.pop()
            add_to_drawhash(self)
            self:draw_boundingrect()
            return
        end
        return orig_anim_draw_self(self, ...)
    end
end

if Sprite then
    local orig_sprite_draw_self = Sprite.draw_self
    function Sprite:draw_self(overlay, ...)
        local is_witch_blind = self.atlas and (
            self.atlas.name == 'reality_warp_blinds' or self.atlas.key == 'reality_warp_blinds' or
            (self.atlas.name and string.find(self.atlas.name, 'reality_warp_blinds')) or
            (self.atlas.key and string.find(self.atlas.key, 'reality_warp_blinds'))
        )
        local is_witch_fam = self.atlas and (
            self.atlas.name == 'reality_warp_familiars' or self.atlas.key == 'reality_warp_familiars' or
            (self.atlas.name and string.find(self.atlas.name, 'familiars')) or
            (self.atlas.key and string.find(self.atlas.key, 'familiars'))
        )
        if is_witch_blind or is_witch_fam then
            if not self.states.visible then return end
            if is_witch_fam and self.role and self.role.draw_major then
                local major = self.role.draw_major
                if major.removed then return end
                local is_coll = (major.bypass_discovery_center or major.bypass_discovery_ui) or (major.area and (major.area.config and major.area.config.collection or (major.params and major.params.bypass_discovery_center))) or (G.OVERLAY_MENU ~= nil)
                if not is_coll and G.STAGE == G.STAGES.RUN and (major.area and major.area ~= G.botg_familiars) then
                    return
                end
            end
            if self.sprite_pos.x ~= self.sprite_pos_copy.x or self.sprite_pos.y ~= self.sprite_pos_copy.y then
                self:set_sprite_pos(self.sprite_pos)
            end
            prep_draw(self, 1)
            local vw = (self.VT and self.VT.w and self.VT.w > 0) and self.VT.w or 1
            local vh = (self.VT and self.VT.h and self.VT.h > 0) and self.VT.h or 1
            local s = math.max(self.scale.x / vw, self.scale.y / vh)
            if is_witch_fam and G.BOTG_FAMILIAR_CARD_SCALE then
                s = s / G.BOTG_FAMILIAR_CARD_SCALE
            end
            love.graphics.scale(1 / s, 1 / s)
            love.graphics.setColor(overlay or G.BRUTE_OVERLAY or G.C.WHITE)
            local draw_x = (vw * s - self.scale.x) / 2
            local draw_y = (vh * s - self.scale.y) / 2
            love.graphics.draw(
                self.atlas.image,
                self.sprite,
                draw_x, draw_y,
                0,
                1, 1
            )
            love.graphics.pop()
            add_to_drawhash(self)
            self:draw_boundingrect()
            if self.shader_tab then love.graphics.setShader() end
            return
        end
        return orig_sprite_draw_self(self, overlay or G.BRUTE_OVERLAY, ...)
    end
end

if SMODS and SMODS.Scoring_Parameter and SMODS.Scoring_Parameters and not SMODS.Scoring_Parameters.e_mult then
    SMODS.Scoring_Parameter({
        key = 'e_mult',
        default_value = 0,
        colour = G.C.DARK_EDITION,
        calculation_keys = { 'e_mult', 'emult', 'Emult' },
        calc_effect = function(self, effect, scored_card, key, amount, from_edition)
            if not amount or amount <= 1 or not SMODS.Calculation_Controls or not SMODS.Calculation_Controls.mult then
                return
            end
            if effect.card and effect.card ~= scored_card then
                juice_card(effect.card)
            end
            local mult_param = SMODS.Scoring_Parameters.mult
            local cur = mult_param and mult_param.current
            if cur and (type(cur) == 'table' or cur >= 1) then
                local target = type(cur) == 'table' and (cur ^ amount) or math.floor(cur ^ amount)
                mult_param:modify(target - cur)
                if not effect.remove_default_message then
                    card_eval_status_text(
                        effect.message_card or scored_card or effect.card or effect.focus,
                        'extra', nil, nil, nil,
                        {
                            sound = 'multhit2',
                            message = '^' .. tostring(amount) .. ' Mult!',
                            colour = G.C.DARK_EDITION,
                        }
                    )
                end
                return true
            end
        end,
    })
end


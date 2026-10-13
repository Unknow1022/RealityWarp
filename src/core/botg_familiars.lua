SMODS.Atlas {
    key = "reality_warp_familiars",
    path = "familiars.png",
    px = 34,
    py = 34
}

SMODS.ConsumableType {
    key = 'Familiar',
    primary_colour = HEX('8B0000'),
    secondary_colour = HEX('4A0000'),
    loc_txt = {
        name = 'Familiar',
        collection = 'Familiars',
        underscores_single = 'Familiar',
        underscores_plural = 'Familiars'
    },
    shop_rate = 0.0,
    collection_rows = { 7, 7 },
    default = 'c_reality_warp_baby_needle',
    unlocked = true,
    discovered = true,
    create_UIBox_your_collection = function(self)
        local pool = G.P_CENTER_POOLS and G.P_CENTER_POOLS['Familiar'] or {}
        for _, fam in ipairs(pool) do
            fam.unlocked = true
            fam.discovered = true
        end
        local back_f = 'your_collection_other_gameobjects'
        if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('consumable_collection') then
            back_f = 'your_collection_consumables'
        end
        return SMODS.card_collection_UIBox(pool, { 7, 7 }, {
            back_func = back_f,
            modify_card = function(card, center)
                card.params.bypass_discovery_center = true
                card.discovered = true
                card.unlocked = true
                card.debuff = false
            end
        })
    end
}

if G.FUNCS then
    G.FUNCS.botg_empty_familiar_label = function(e)
        e.config.visible = (not G.botg_familiars) or (#G.botg_familiars.cards == 0)
    end

    G.FUNCS.your_collection_familiars = function(e)
        G.SETTINGS.paused = true
        local pool = G.P_CENTER_POOLS and G.P_CENTER_POOLS['Familiar'] or {}
        for _, fam in ipairs(pool) do
            fam.unlocked = true
            fam.discovered = true
        end
        local back_f = 'your_collection_other_gameobjects'
        if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID('consumable_collection') then
            back_f = 'your_collection_consumables'
        end
        G.FUNCS.overlay_menu{
            definition = SMODS.card_collection_UIBox(pool, { 7, 7 }, {
                back_func = back_f,
                modify_card = function(card, center)
                    card.params.bypass_discovery_center = true
                    card.discovered = true
                    card.unlocked = true
                    card.debuff = false
                end
            })
        }
    end
end

G.BOTG_FAMILIAR_SLOT_SIZE = 0.85
G.BOTG_FAMILIAR_SIZE = 0.72
G.BOTG_FAMILIAR_CARD_SCALE = 1.0

function botg_get_familiar_level(fam_key)
    if not fam_key then return 1 end
    if get_nursery_data then
        local nd = get_nursery_data(fam_key)
        if nd and nd.level then return math.max(1, math.min(5, nd.level)) end
    elseif G and G.get_nursery_data then
        local nd = G.get_nursery_data(fam_key)
        if nd and nd.level then return math.max(1, math.min(5, nd.level)) end
    end
    return 1
end

function botg_purge_orphan_familiars()
    if G.I and G.I.CARD then
        for i = #G.I.CARD, 1, -1 do
            local c = G.I.CARD[i]
            if c and (c.area ~= G.botg_familiars) and (
                (c.config and c.config.center and c.config.center.set == 'Familiar') or
                (c.ability and c.ability.set == 'Familiar')
            ) then
                c:remove()
            end
        end
    end
    if G.botg_familiars and G.botg_familiars.cards and #G.botg_familiars.cards > 1 then
        for i = #G.botg_familiars.cards, 2, -1 do
            local c = G.botg_familiars:remove_card(G.botg_familiars.cards[i])
            if c then c:remove() end
        end
    end
    if G.I and G.I.UIBOX then
        for i = #G.I.UIBOX, 1, -1 do
            local ub = G.I.UIBOX[i]
            if ub and (
                (G.botg_familiars and G.botg_familiars.children and ub == G.botg_familiars.children.slot_uibox) or
                (ub.definition and ub.definition.nodes and ub.definition.nodes[1] and ub.definition.nodes[1].nodes and ub.definition.nodes[1].nodes[1] and ub.definition.nodes[1].nodes[1].config and ub.definition.nodes[1].nodes[1].config.func == 'botg_empty_familiar_label')
            ) then
                ub:remove()
            end
        end
    end
    if G.botg_familiars and G.botg_familiars.children and G.botg_familiars.children.slot_uibox then
        if G.botg_familiars.children.slot_uibox.remove then
            G.botg_familiars.children.slot_uibox:remove()
        end
        G.botg_familiars.children.slot_uibox = nil
    end
end

function init_botg_familiars_area()
    botg_purge_orphan_familiars()
    if not G.botg_familiars or G.botg_familiars.REMOVED then
        local w = G.BOTG_FAMILIAR_SLOT_SIZE or 0.85
        local h = G.BOTG_FAMILIAR_SLOT_SIZE or 0.85
        local x = (G.deck and (G.deck.T.x + (G.deck.T.w - w) * 0.5)) or 10
        local y = (G.deck and (G.deck.T.y - h - 0.25)) or 7
        local card_size = G.BOTG_FAMILIAR_SIZE or 0.72
        G.botg_familiars = CardArea(
            x, y,
            w, h,
            { card_limit = 1, type = 'title', highlight_limit = 1, card_w = card_size }
        )

        G.botg_familiars.save = function(self)
            return nil
        end

        G.botg_familiars.load = function(self, cardAreaTable)
            if self.cards then
                for i = #self.cards, 1, -1 do
                    local c = self.cards[i]
                    self:remove_card(c)
                    if c then c:remove() end
                end
            end
            self.cards = {}
            botg_purge_orphan_familiars()
            if G.GAME and G.GAME.botg_current_familiar then
                local clean_k = tostring(G.GAME.botg_current_familiar):gsub('^c_reality_warp_', ''):gsub('^c_', '')
                botg_set_active_familiar('c_reality_warp_' .. clean_k)
            end
        end

        G.botg_familiars.align_cards = function(self)
            for k, card in ipairs(self.cards) do
                if not card.states.drag.is and not card.disable_align then
                    card.T.r = (G.SETTINGS.reduced_motion and 0 or 1) * 0.04 * math.sin(1.8 * G.TIMERS.REAL + card.T.x)
                    card.T.x = self.T.x + (self.T.w - card.T.w) * 0.5
                    local highlight_height = card.highlighted and G.HIGHLIGHT_H or 0
                    card.T.y = self.T.y + (self.T.h - card.T.h) * 0.5 - highlight_height
                    card.T.x = card.T.x + card.shadow_parrallax.x / 30
                end
                card.rank = k
            end
        end

        G.botg_familiars.draw = function(self)
            if not self.states.visible or G.VIEWING_DECK or G.STAGE ~= G.STAGES.RUN then return end

            if self.children and self.children.slot_uibox then
                if self.children.slot_uibox.remove then
                    self.children.slot_uibox:remove()
                end
                self.children.slot_uibox = nil
            end

            -- Only draw subtle slot outline when slot is empty
            if #self.cards == 0 then
                prep_draw(self, 1)
                love.graphics.setShader()
                local r = 0.12 * self.T.w
                love.graphics.setColor(0, 0, 0, 0.4)
                love.graphics.rectangle('fill', 0, 0, self.T.w, self.T.h, r, r)
                love.graphics.setColor(0.18, 0.20, 0.24, 0.6)
                love.graphics.rectangle('fill', 0.02, 0.02, self.T.w - 0.04, self.T.h - 0.04, r * 0.85, r * 0.85)
                love.graphics.pop()
            end

            add_to_drawhash(self)

            local draw_layers = self.ARGS.draw_layers or self.config.draw_layers or {'shadow', 'card'}
            for _, layer in ipairs(draw_layers) do
                for i = 1, #self.cards do
                    local c = self.cards[i]
                    if c ~= G.CONTROLLER.focused.target and G.CONTROLLER.dragging.target ~= c then
                        c:draw(layer)
                    end
                end
            end
        end
    end

    if G.GAME and #G.botg_familiars.cards == 0 then
        local target_fam = G.GAME.botg_current_familiar or (get_nursery_lead_companion and get_nursery_lead_companion()) or (get_nursery_selected_fam and get_nursery_selected_fam())
        if target_fam then
            local clean_k = tostring(target_fam):gsub('^c_reality_warp_', ''):gsub('^c_', '')
            botg_set_active_familiar('c_reality_warp_' .. clean_k)
        end
    end
    botg_purge_orphan_familiars()
end

if set_screen_positions then
    local orig_set_screen_positions = set_screen_positions
    function set_screen_positions()
        orig_set_screen_positions()
        if G.STAGE == G.STAGES.RUN and G.GAME and G.GAME.botg_current_familiar then
            if not G.botg_familiars or #G.botg_familiars.cards == 0 then
                init_botg_familiars_area()
            end
            botg_purge_orphan_familiars()
        end
        if G.botg_familiars and G.deck and G.STAGE == G.STAGES.RUN then
            G.botg_familiars.T.w = G.BOTG_FAMILIAR_SLOT_SIZE or 0.85
            G.botg_familiars.T.h = G.BOTG_FAMILIAR_SLOT_SIZE or 0.85
            G.botg_familiars.T.x = G.deck.T.x + (G.deck.T.w - G.botg_familiars.T.w) * 0.5
            G.botg_familiars.T.y = G.deck.T.y - G.botg_familiars.T.h - 0.25
            G.botg_familiars:hard_set_VT()
            local size = G.BOTG_FAMILIAR_SIZE or 0.72
            for _, card in ipairs(G.botg_familiars.cards) do
                card.T.w = size
                card.T.h = size
                card.VT.w = size
                card.VT.h = size
                if card.children.center then
                    card.children.center.T.w = size
                    card.children.center.T.h = size
                    card.children.center.VT.w = size
                    card.children.center.VT.h = size
                end
                card:hard_set_T(G.botg_familiars.T.x + (G.botg_familiars.T.w - size) * 0.5, G.botg_familiars.T.y + (G.botg_familiars.T.h - size) * 0.5, size, size)
            end
            G.botg_familiars:align_cards()
        end
    end
end

if Game and Game.start_run then
    local orig_game_start_run_fam = Game.start_run
    function Game:start_run(args)
        orig_game_start_run_fam(self, args)
        botg_purge_orphan_familiars()
        G.E_MANAGER:add_event(Event({
            func = function()
                botg_purge_orphan_familiars()
                if G.STAGE == G.STAGES.RUN and G.GAME and G.GAME.botg_current_familiar then
                    init_botg_familiars_area()
                end
                botg_purge_orphan_familiars()
                return true
            end
        }))
    end
end

if Game and Game.update then
    local orig_game_update_fam = Game.update
    function Game:update(dt)
        orig_game_update_fam(self, dt)
        if G.STAGE == G.STAGES.RUN and G.GAME and G.GAME.botg_current_familiar then
            if not G.botg_familiars or #G.botg_familiars.cards == 0 then
                init_botg_familiars_area()
            end
        end
    end
end

function botg_set_active_familiar(fam_key)
    if not G.botg_familiars then return end
    if G.GAME then
        local old_bonus = (G.GAME.botg_current_familiar == 'c_reality_warp_baby_house' or G.GAME.botg_current_familiar == 'c_reality_warp_baby_manacle') and 1 or 0
        local new_bonus = (fam_key == 'c_reality_warp_baby_house' or fam_key == 'c_reality_warp_baby_manacle') and 1 or 0
        local diff = new_bonus - old_bonus
        if diff ~= 0 and G.hand then
            G.hand:change_size(diff)
        end
        G.GAME.botg_current_familiar = fam_key
    end

    while #G.botg_familiars.cards > 0 do
        local c = G.botg_familiars:remove_card(G.botg_familiars.cards[1])
        if c then c:remove() end
    end
    botg_purge_orphan_familiars()

    local card = create_card('Familiar', G.botg_familiars, nil, nil, true, nil, fam_key)
    card.params.bypass_discovery_center = true
    card.discovered = true
    card.unlocked = true
    card.debuff = false
    local size = G.BOTG_FAMILIAR_SIZE or 0.72
    card.T.w = size
    card.T.h = size
    card.VT.w = size
    card.VT.h = size
    if card.children.center then
        card.children.center.T.w = size
        card.children.center.T.h = size
        card.children.center.VT.w = size
        card.children.center.VT.h = size
        card.children.center.scale = { x = 34, y = 34 }
    end
    if card.children.back then
        card.children.back.states.visible = false
    end
    card.no_shadow = true
    card.states.drag.can = false
    card.states.click.can = true
    card.states.hover.can = true
    card.draw = function(self, layer)
        if not self.states.visible then return end
        layer = layer or 'both'
        local r = 0.14 * self.T.w

        if layer == 'shadow' or layer == 'both' then
            prep_draw(self, 1)
            love.graphics.setShader()
            local s_off_x = (self.shadow_parrallax and self.shadow_parrallax.x or 1) * 0.03 + 0.02
            local s_off_y = (self.shadow_parrallax and self.shadow_parrallax.y or 1) * 0.03 + 0.03
            love.graphics.setColor(0, 0, 0, 0.35)
            love.graphics.rectangle('fill', s_off_x, s_off_y, self.T.w, self.T.h, r, r)
            love.graphics.pop()
        end

        if layer == 'card' or layer == 'both' then
            prep_draw(self, 1)
            love.graphics.setShader()

            -- Outer border contour (subtle dark outline)
            love.graphics.setColor(0.32, 0.35, 0.40, 0.9)
            love.graphics.rectangle('fill', 0, 0, self.T.w, self.T.h, r, r)

            -- Silver-grey bevel frame
            love.graphics.setColor(0.78, 0.82, 0.88, 1)
            love.graphics.rectangle('fill', 0.015, 0.015, self.T.w - 0.03, self.T.h - 0.03, r * 0.88, r * 0.88)

            -- Soft 3D bottom bevel shadow
            love.graphics.setColor(0.64, 0.68, 0.75, 1)
            love.graphics.rectangle('fill', 0.015, 0.03, self.T.w - 0.03, self.T.h - 0.045, r * 0.85, r * 0.85)

            -- Crisp clean white tag face
            love.graphics.setColor(0.96, 0.97, 0.99, 1)
            love.graphics.rectangle('fill', 0.03, 0.03, self.T.w - 0.06, self.T.h - 0.065, r * 0.78, r * 0.78)

            love.graphics.pop()

            if self.children.center then
                self.children.center:draw()
            end
        end
    end
    card:hard_set_T(G.botg_familiars.T.x + (G.botg_familiars.T.w - size) * 0.5, G.botg_familiars.T.y + (G.botg_familiars.T.h - size) * 0.5, size, size)
    G.botg_familiars:emplace(card)
    G.botg_familiars:align_cards()
    botg_purge_orphan_familiars()
    card:juice_up(0.6, 0.6)
    play_sound('tarot1', 1.2, 0.8)

    if fam_key == 'c_reality_warp_baby_hook' and G.GAME and G.GAME.current_round then
        G.GAME.current_round.free_rerolls = (G.GAME.current_round.free_rerolls or 0) + 1
        if calculate_reroll_cost then calculate_reroll_cost() end
    end
    if fam_key == 'c_reality_warp_baby_pillar' or fam_key == 'c_reality_warp_baby_leaf' then
        if G.hand and G.hand.cards then for _, c in ipairs(G.hand.cards) do c:set_debuff(false) end end
        if G.play and G.play.cards then for _, c in ipairs(G.play.cards) do c:set_debuff(false) end end
        if G.deck and G.deck.cards then for _, c in ipairs(G.deck.cards) do c:set_debuff(false) end end
    end
    if fam_key == 'c_reality_warp_baby_heart' or fam_key == 'c_reality_warp_baby_leaf' then
        if G.jokers and G.jokers.cards then for _, c in ipairs(G.jokers.cards) do c:set_debuff(false) end end
    end
end

SMODS.Consumable {
    key = 'baby_needle',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 0, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Needle',
        text = {
            "{C:purple}Active (Click):{} Gain {C:blue}+1{} Hand {C:inactive}(Once/round){}",
            "{C:chips}+20{} Chips & {C:mult}+3{} Mult if won in {C:attention}1 hand{}",
            "{C:inactive}(Scales up to +100 / +15 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_pillar',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 1, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Pillar',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Protects all cards in {C:attention}hand{}",
            "and {C:attention}play{} from all {C:attention}Boss debuffs{}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_serpent',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 2, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Serpent',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "After every {C:red}Discard{}, draws",
            "{C:attention}+1{} extra card from deck",
            "{C:inactive}(Scales up to +3 cards at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_flint',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 3, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Flint',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Base Chips and Mult are {X:mult,C:white}X1.1{}.",
            "Scored cards gain {C:chips}+1{} Chip permanently",
            "{C:inactive}(Scales up to X1.5 & +5 Chips at Lv. 5){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_hook',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 4, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Hook',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:red}Discards{} never drop below {C:attention}1{};",
            "grants {C:green}1 free{} Shop reroll",
            "{C:inactive}(Grants +2 rerolls at Lv. 3+ in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_eye',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 5, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Eye',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Playing {C:attention}repeat{} poker hands",
            "triggers {X:mult,C:white}X1.15{} Mult",
            "{C:inactive}(Scales up to X1.75 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_ox',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 6, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Ox',
        text = {
            "{C:purple}Active (Click):{} Gain {C:money}+$1{} {C:inactive}(Once/round){}",
            "Playing {C:attention}most played{} poker hand",
            "grants {C:money}+$1{}",
            "{C:inactive}(Scales up to +$5 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_house',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 7, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby House',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:attention}+1{} Hand Size.",
            "First hand played each round gives {X:mult,C:white}X1.1{} Mult",
            "{C:inactive}(Scales up to X1.5 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_club',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 8, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Club',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored {C:clubs}Clubs{} give {C:chips}+8{} Chips",
            "and {C:mult}+1{} Mult",
            "{C:inactive}(Scales up to +40 / +5 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_fish',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 9, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Fish',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Draws {C:attention}+1{} extra card",
            "after each played hand",
            "{C:inactive}(Scales up to +3 cards at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_window',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 10, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Window',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored {C:diamonds}Diamonds{} grant {C:mult}+1{} Mult",
            "{C:inactive}(Scales up to +5 Mult & +$1 at Lv. 5){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_manacle',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 11, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Manacle',
        text = {
            "{C:purple}Active (Click):{} Draw {C:attention}+1{} card {C:inactive}(Once/round){}",
            "Permanently grants {C:attention}+1{} Hand Size",
            "{C:inactive}(Click draws up to +3 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_wall',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 12, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Wall',
        text = {
            "{C:purple}Active (Click):{} Reduces current Blind",
            "chip requirement by {C:attention}10%{} {C:inactive}(Once/round){}",
            "{C:inactive}(Scales up to 30% at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_wheel',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 13, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Wheel',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:green}1 in 3{} chance for each scored card",
            "to trigger {C:mult}+6{} Mult",
            "{C:inactive}(Scales up to +30 Mult at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_arm',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 14, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Arm',
        text = {
            "{C:purple}Active (Click):{} Upgrade level of last",
            "played poker hand by {C:attention}+1{} {C:inactive}(Once/round){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_psychic',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 15, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Psychic',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Played hands containing {C:attention}5 cards{}",
            "grant {C:chips}+15{} Chips and {C:mult}+2{} Mult",
            "{C:inactive}(Scales up to +95 / +14 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_goad',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 16, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Goad',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored {C:spades}Spades{} give {C:chips}+8{} Chips",
            "and {C:mult}+1{} Mult",
            "{C:inactive}(Scales up to +40 / +5 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_water',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 17, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Water',
        text = {
            "{C:purple}Active (Click):{} Gain {C:red}+1{} Discard {C:inactive}(Once/round){}",
            "Start each round with {C:red}+1{} extra Discard"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_mouth',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 18, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Mouth',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "If only {C:attention}1 hand type{} is played this round,",
            "earn {C:money}+$2{} and {C:mult}+3{} Mult",
            "{C:inactive}(Scales up to +$6 & +15 Mult at Lv. 5){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_plant',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 19, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Plant',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored {C:attention}Face cards{} give {C:chips}+12{} Chips",
            "and {C:mult}+2{} Mult",
            "{C:inactive}(Scales up to +60 / +10 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_head',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 20, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Head',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored {C:hearts}Hearts{} give {C:chips}+8{} Chips",
            "and {C:mult}+1{} Mult",
            "{C:inactive}(Scales up to +40 / +5 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_tooth',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 21, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Tooth',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored cards grant {C:money}+$1{} for",
            "every {C:attention}5 cards{} scored",
            "{C:inactive}(Scales up to every 1 card at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_mark',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 22, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Mark',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "Scored {C:attention}Face cards{} give {X:mult,C:white}X1.1{} Mult",
            "{C:inactive}(Scales up to X1.5 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_heart',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 23, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Heart',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:attention}Jokers{} cannot be debuffed or disabled.",
            "Grants {C:mult}+2{} Mult per Joker owned",
            "{C:inactive}(Scales up to +10 Mult per Joker at Lv. 5){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_bell',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 24, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Bell',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:green}20%{} chance to retrigger scored card",
            "{C:attention}1{} additional time",
            "{C:inactive}(Scales up to 100% chance at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_acorn',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 25, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Acorn',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "{C:green}20%{} chance to retrigger {C:attention}rightmost Joker{}",
            "{C:attention}1{} additional time",
            "{C:inactive}(Scales up to 100% chance at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_leaf',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 26, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Leaf',
        text = {
            "{C:purple}Pocket Mini-Boss Familiar{}",
            "All cards are immune to Boss debuffs.",
            "Selling a Joker grants {C:money}+$3{}",
            "{C:inactive}(Scales up to +$15 at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

SMODS.Consumable {
    key = 'baby_vessel',
    set = 'Familiar',
    atlas = 'reality_warp_familiars',
    pos = { x = 27, y = 0 },
    cost = 10, unlocked = true, discovered = true,
    pixel_size = { w = 34, h = 34 },
    loc_txt = {
        name = 'Baby Vessel',
        text = {
            "{C:purple}Active (Click):{} Reduces current Blind",
            "chip requirement by {C:attention}11%{} {C:inactive}(Once/round){}",
            "{C:inactive}(Scales up to 35% at Lv. 5 in Nursery){}"
        }
    },
    in_pool = function(self) return false end
}

local FAMILIAR_KEYS = {
    'c_reality_warp_baby_needle',
    'c_reality_warp_baby_pillar',
    'c_reality_warp_baby_serpent',
    'c_reality_warp_baby_flint',
    'c_reality_warp_baby_hook',
    'c_reality_warp_baby_eye',
    'c_reality_warp_baby_ox',
    'c_reality_warp_baby_house',
    'c_reality_warp_baby_club',
    'c_reality_warp_baby_fish',
    'c_reality_warp_baby_window',
    'c_reality_warp_baby_manacle',
    'c_reality_warp_baby_wall',
    'c_reality_warp_baby_wheel',
    'c_reality_warp_baby_arm',
    'c_reality_warp_baby_psychic',
    'c_reality_warp_baby_goad',
    'c_reality_warp_baby_water',
    'c_reality_warp_baby_mouth',
    'c_reality_warp_baby_plant',
    'c_reality_warp_baby_head',
    'c_reality_warp_baby_tooth',
    'c_reality_warp_baby_mark',
    'c_reality_warp_baby_heart',
    'c_reality_warp_baby_bell',
    'c_reality_warp_baby_acorn',
    'c_reality_warp_baby_leaf',
    'c_reality_warp_baby_vessel'
}

local FAMILIAR_BOSS_NAMES = {
    ['c_reality_warp_baby_needle'] = "The Needle",
    ['c_reality_warp_baby_pillar'] = "The Pillar",
    ['c_reality_warp_baby_serpent'] = "The Serpent",
    ['c_reality_warp_baby_flint'] = "The Flint",
    ['c_reality_warp_baby_hook'] = "The Hook",
    ['c_reality_warp_baby_eye'] = "The Eye",
    ['c_reality_warp_baby_ox'] = "The Ox",
    ['c_reality_warp_baby_house'] = "The House",
    ['c_reality_warp_baby_club'] = "The Club",
    ['c_reality_warp_baby_fish'] = "The Fish",
    ['c_reality_warp_baby_window'] = "The Window",
    ['c_reality_warp_baby_manacle'] = "The Manacle",
    ['c_reality_warp_baby_wall'] = "The Wall",
    ['c_reality_warp_baby_wheel'] = "The Wheel",
    ['c_reality_warp_baby_arm'] = "The Arm",
    ['c_reality_warp_baby_psychic'] = "The Psychic",
    ['c_reality_warp_baby_goad'] = "The Goad",
    ['c_reality_warp_baby_water'] = "The Water",
    ['c_reality_warp_baby_mouth'] = "The Mouth",
    ['c_reality_warp_baby_plant'] = "The Plant",
    ['c_reality_warp_baby_head'] = "The Head",
    ['c_reality_warp_baby_tooth'] = "The Tooth",
    ['c_reality_warp_baby_mark'] = "The Mark",
    ['c_reality_warp_baby_heart'] = "Crimson Heart",
    ['c_reality_warp_baby_bell'] = "Cerulean Bell",
    ['c_reality_warp_baby_acorn'] = "Amber Acorn",
    ['c_reality_warp_baby_leaf'] = "Verdant Leaf",
    ['c_reality_warp_baby_vessel'] = "Violet Vessel",
}

local function sync_familiar_discovery()
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Familiar'] then
        for _, fam in ipairs(G.P_CENTER_POOLS['Familiar']) do
            fam.unlocked = true
            fam.discovered = true
        end
    end
    if FAMILIAR_KEYS then
        for _, k in ipairs(FAMILIAR_KEYS) do
            local target = (G.P_CENTERS and G.P_CENTERS[k]) or (SMODS and SMODS.Centers and SMODS.Centers[k])
            if target then
                target.unlocked = true
                target.discovered = true
            end
        end
    end
    if G.DISCOVER_TALLIES and G.DISCOVER_TALLIES['familiars'] then
        G.DISCOVER_TALLIES['familiars'] = { tally = 28, of = 28 }
    end
end
sync_familiar_discovery()

if set_discover_tallies then
    local orig_set_tallies = set_discover_tallies
    function set_discover_tallies()
        orig_set_tallies()
        sync_familiar_discovery()
    end
end

function botg_offer_familiar(fam_key)
    fam_key = fam_key or pseudorandom_element(FAMILIAR_KEYS, pseudoseed('botg_fam_' .. (G.GAME and G.GAME.round or 1)))
    init_botg_familiars_area()

    if not G.botg_familiars then return end
    local new_center = G.P_CENTERS and G.P_CENTERS[fam_key]
    if not new_center then return end

    G.botg_pending_familiar = fam_key

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
            local current_fam = G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1]
            local new_name = (new_center.loc_txt and new_center.loc_txt.name) or localize{type = 'name_text', key = fam_key, set = 'Familiar'} or 'Mini-Boss Familiar'
            local new_lines = (new_center.loc_txt and new_center.loc_txt.text) or {}

            local content_node = nil

            if not current_fam then
                local desc_nodes = {}
                for _, line in ipairs(new_lines) do
                    local clean = type(line) == 'string' and line:gsub("{.-}", "") or (type(line) == 'table' and (line.string or line[1]) or tostring(line or ''))
                    table.insert(desc_nodes, {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.03 },
                        nodes = {
                            { n = G.UIT.T, config = { text = clean, scale = 0.36, colour = G.C.WHITE, shadow = true } }
                        }
                    })
                end

                content_node = {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.2, r = 0.2, colour = {0.08, 0.04, 0.12, 0.95}, outline = 2.5, outline_colour = G.C.GOLD },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.1 },
                            nodes = {
                                { n = G.UIT.T, config = { text = "Mini-Boss Companion Found! ", scale = 0.55, colour = G.C.GOLD, shadow = true } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.08 },
                            nodes = {
                                { n = G.UIT.T, config = { text = new_name, scale = 0.5, colour = HEX('9d4edd'), shadow = true } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = {
                                align = "cm",
                                padding = 0.15,
                                r = 0.12,
                                colour = {0.04, 0.02, 0.06, 0.8},
                                outline = 1.2,
                                outline_colour = HEX('5a189a'),
                                minw = 5.2,
                                minh = 1.8
                            },
                            nodes = desc_nodes
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.18 },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = {
                                        align = "cm",
                                        padding = 0.12,
                                        r = 0.12,
                                        colour = HEX('7b2cbf'),
                                        button = "botg_adopt_familiar",
                                        hover = true,
                                        shadow = true,
                                        minw = 2.8
                                    },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = "Adopt Companion", scale = 0.45, colour = G.C.WHITE, shadow = true } }
                                    }
                                }
                            }
                        }
                    }
                }
            else
                local old_key = (current_fam.config and current_fam.config.center and current_fam.config.center.key) or (current_fam.config and current_fam.config.center_key) or ''
                local old_center = G.P_CENTERS and G.P_CENTERS[old_key]
                local old_name = (old_center and old_center.loc_txt and old_center.loc_txt.name) or localize{type = 'name_text', key = old_key, set = 'Familiar'} or 'Current Companion'
                local old_lines = (old_center and old_center.loc_txt and old_center.loc_txt.text) or {}

                local old_desc_nodes = {}
                for _, line in ipairs(old_lines) do
                    local clean = type(line) == 'string' and line:gsub("{.-}", "") or (type(line) == 'table' and (line.string or line[1]) or tostring(line or ''))
                    table.insert(old_desc_nodes, {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = { { n = G.UIT.T, config = { text = clean, scale = 0.32, colour = G.C.WHITE } } }
                    })
                end

                local new_desc_nodes = {}
                for _, line in ipairs(new_lines) do
                    local clean = type(line) == 'string' and line:gsub("{.-}", "") or (type(line) == 'table' and (line.string or line[1]) or tostring(line or ''))
                    table.insert(new_desc_nodes, {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = { { n = G.UIT.T, config = { text = clean, scale = 0.32, colour = G.C.WHITE } } }
                    })
                end

                content_node = {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.2, r = 0.2, colour = {0.08, 0.04, 0.12, 0.95}, outline = 2.5, outline_colour = G.C.GOLD },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.1 },
                            nodes = {
                                { n = G.UIT.T, config = { text = "⚔️ Mini-Boss Encounter: Swap Companion? ⚔️", scale = 0.52, colour = G.C.GOLD, shadow = true } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.12 },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", padding = 0.12, r = 0.12, colour = {0.05, 0.03, 0.08, 0.85}, outline = 1.5, outline_colour = G.C.GREY, minw = 3.6, minh = 2.8 },
                                    nodes = {
                                        { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = { { n = G.UIT.T, config = { text = "CURRENT COMPANION", scale = 0.3, colour = G.C.GREY } } } },
                                        { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = { { n = G.UIT.T, config = { text = old_name, scale = 0.42, colour = G.C.WHITE, shadow = true } } } },
                                        { n = G.UIT.R, config = { align = "cm", padding = 0.06 }, nodes = old_desc_nodes },
                                        { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", padding = 0.06 },
                                            nodes = {
                                                {
                                                    n = G.UIT.C,
                                                    config = { align = "cm", padding = 0.1, r = 0.1, colour = G.C.GREY, button = "botg_keep_familiar", hover = true, shadow = true, minw = 2.2 },
                                                    nodes = { { n = G.UIT.T, config = { text = "Keep Current", scale = 0.38, colour = G.C.WHITE, shadow = true } } }
                                                }
                                            }
                                        }
                                    }
                                },
                                { n = G.UIT.B, config = { w = 0.4, h = 0.1 } },
                                {
                                    n = G.UIT.C,
                                    config = { align = "cm", padding = 0.12, r = 0.12, colour = {0.05, 0.03, 0.08, 0.85}, outline = 1.5, outline_colour = HEX('9d4edd'), minw = 3.6, minh = 2.8 },
                                    nodes = {
                                        { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = { { n = G.UIT.T, config = { text = "NEW DISCOVERY", scale = 0.3, colour = HEX('9d4edd') } } } },
                                        { n = G.UIT.R, config = { align = "cm", padding = 0.04 }, nodes = { { n = G.UIT.T, config = { text = new_name, scale = 0.42, colour = G.C.GOLD, shadow = true } } } },
                                        { n = G.UIT.R, config = { align = "cm", padding = 0.06 }, nodes = new_desc_nodes },
                                        { n = G.UIT.B, config = { w = 0.1, h = 0.1 } },
                                        {
                                            n = G.UIT.R,
                                            config = { align = "cm", padding = 0.06 },
                                            nodes = {
                                                {
                                                    n = G.UIT.C,
                                                    config = { align = "cm", padding = 0.1, r = 0.1, colour = HEX('7b2cbf'), button = "botg_replace_familiar", hover = true, shadow = true, minw = 2.2 },
                                                    nodes = { { n = G.UIT.T, config = { text = "Adopt New", scale = 0.38, colour = G.C.WHITE, shadow = true } } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            end

            G.FUNCS.overlay_menu{
                definition = {
                    n = G.UIT.ROOT,
                    config = { align = "cm", colour = G.C.CLEAR },
                    nodes = { content_node }
                }
            }
            play_sound('tarot1', 1.0, 0.8)
            return true
        end
    }))
end

if G.FUNCS then
    G.FUNCS.botg_adopt_familiar = function(e)
        if G.botg_pending_familiar and G.botg_familiars then
            botg_set_active_familiar(G.botg_pending_familiar)
        end
        G.botg_pending_familiar = nil
        G.FUNCS.exit_overlay_menu()
    end

    G.FUNCS.botg_replace_familiar = function(e)
        if G.botg_pending_familiar and G.botg_familiars then
            while #G.botg_familiars.cards > 0 do
                local c = G.botg_familiars:remove_card(G.botg_familiars.cards[1])
                if c then c:remove() end
            end
            botg_set_active_familiar(G.botg_pending_familiar)
        end
        G.botg_pending_familiar = nil
        G.FUNCS.exit_overlay_menu()
    end

    G.FUNCS.botg_keep_familiar = function(e)
        G.botg_pending_familiar = nil
        G.FUNCS.exit_overlay_menu()
    end
end

function botg_click_familiar(card)
    if not card or not card.config or not card.config.center then return end
    local f_key = card.config.center.key
    if not G.GAME then return end

    local current_round_id = tostring(G.GAME.round or 0) .. '_' .. tostring(G.GAME.round_resets and G.GAME.round_resets.ante or 0)
    G.GAME.botg_fam_used = G.GAME.botg_fam_used or {}
    if G.GAME.botg_fam_used_round ~= current_round_id then
        G.GAME.botg_fam_used = {}
        G.GAME.botg_fam_used_round = current_round_id
    end
    card.debuff = false
    if card.set_debuff then card:set_debuff(false) end

    local fam_level = botg_get_familiar_level(f_key)

    if f_key == 'c_reality_warp_baby_needle' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        G.GAME.botg_fam_used[f_key] = true
        card:juice_up(0.6, 0.6)
        ease_hands_played(1)
        play_sound('gold_seal', 1.2, 0.6)
        attention_text({ text = '+1 Hand! [Baby Needle]', scale = 0.8, hold = 1.2, backdrop_colour = G.C.BLUE, major = card, align = 'tm', offset = {x=0, y=-0.5} })

    elseif f_key == 'c_reality_warp_baby_water' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        G.GAME.botg_fam_used[f_key] = true
        card:juice_up(0.6, 0.6)
        local disc_amt = (fam_level >= 4) and 2 or 1
        ease_discard(disc_amt)
        play_sound('chips2', 1.1, 0.6)
        attention_text({ text = '+' .. disc_amt .. ' Discard! [Baby Water Lv.' .. fam_level .. ']', scale = 0.8, hold = 1.2, backdrop_colour = G.C.RED, major = card, align = 'tm', offset = {x=0, y=-0.5} })

    elseif f_key == 'c_reality_warp_baby_manacle' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        G.GAME.botg_fam_used[f_key] = true
        card:juice_up(0.6, 0.6)
        local cards_amt = (fam_level >= 4) and 3 or ((fam_level >= 2) and 2 or 1)
        for i = 1, cards_amt do
            draw_card(G.deck, G.hand, i * 50, 'up', true)
        end
        play_sound('cardSlide1', 1.0, 0.6)
        attention_text({ text = '+' .. cards_amt .. ' Cards Drawn! [Baby Manacle Lv.' .. fam_level .. ']', scale = 0.7, hold = 1.2, backdrop_colour = G.C.GREY, major = card, align = 'tm', offset = {x=0, y=-0.5} })

    elseif f_key == 'c_reality_warp_baby_ox' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        G.GAME.botg_fam_used[f_key] = true
        card:juice_up(0.6, 0.6)
        ease_dollars(fam_level)
        play_sound('coin3', 1.0, 0.7)
        attention_text({ text = '+$' .. fam_level .. '! [Baby Ox Lv.' .. fam_level .. ']', scale = 0.8, hold = 1.2, backdrop_colour = G.C.MONEY, major = card, align = 'tm', offset = {x=0, y=-0.5} })

    elseif f_key == 'c_reality_warp_baby_wall' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        if G.GAME.blind and G.GAME.blind.chips then
            G.GAME.botg_fam_used[f_key] = true
            card:juice_up(0.6, 0.6)
            local red = 0.05 + 0.05 * fam_level
            G.GAME.blind.chips = math.max(1, math.floor(G.GAME.blind.chips * (1.0 - red)))
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            play_sound('tarot2', 1.2, 0.6)
            attention_text({ text = '-' .. math.floor(red * 100) .. '% Chips! [Baby Wall Lv.' .. fam_level .. ']', scale = 0.8, hold = 1.4, backdrop_colour = HEX('8a59a5'), major = card, align = 'tm', offset = {x=0, y=-0.5} })
        end

    elseif f_key == 'c_reality_warp_baby_vessel' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        if G.GAME.blind and G.GAME.blind.chips then
            G.GAME.botg_fam_used[f_key] = true
            card:juice_up(0.6, 0.6)
            local red = 0.05 + 0.06 * fam_level
            G.GAME.blind.chips = math.max(1, math.floor(G.GAME.blind.chips * (1.0 - red)))
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            play_sound('tarot2', 1.3, 0.6)
            attention_text({ text = '-' .. math.floor(red * 100) .. '% Chips! [Baby Vessel Lv.' .. fam_level .. ']', scale = 0.8, hold = 1.4, backdrop_colour = HEX('8a71e1'), major = card, align = 'tm', offset = {x=0, y=-0.5} })
        end

    elseif f_key == 'c_reality_warp_baby_arm' then
        if G.GAME.botg_fam_used[f_key] then
            attention_text({ text = 'Already Used This Round!', scale = 0.6, hold = 1.0, major = card, align = 'tm', offset = {x=0, y=-0.5} })
            return
        end
        local hand = G.GAME.last_hand_played or (G.GAME.current_round and G.GAME.current_round.most_played_poker_hand) or 'High Card'
        if G.GAME.hands and G.GAME.hands[hand] then
            G.GAME.botg_fam_used[f_key] = true
            card:juice_up(0.6, 0.6)
            level_up_hand(card, hand, nil, 1)
            play_sound('tarot1', 1.0, 0.7)
            attention_text({ text = '+1 Level: ' .. hand .. '! [Baby Arm Lv.' .. fam_level .. ']', scale = 0.7, hold = 1.4, backdrop_colour = HEX('6865f3'), major = card, align = 'tm', offset = {x=0, y=-0.5} })
        end
    else
        card:juice_up(0.4, 0.4)
        play_sound('chips1', 1.3, 0.5)
        local fam_name = (card.config and card.config.center and card.config.center.loc_txt and card.config.center.loc_txt.name) or 'Familiar'
        attention_text({ text = fam_name .. ' is happy! (Lv. ' .. fam_level .. ')', scale = 0.6, hold = 0.9, backdrop_colour = G.C.PURPLE, major = card, align = 'tm', offset = {x=0, y=-0.5} })
    end
end

if Card and Card.click then
    local orig_card_click = Card.click
    function Card:click()
        if self.area and self.area == G.botg_familiars then
            botg_click_familiar(self)
            return
        end
        return orig_card_click(self)
    end
end

local function reset_botg_fam_round_state()
    if G.GAME then
        local current_round_id = tostring(G.GAME.round or 0) .. '_' .. tostring(G.GAME.round_resets and G.GAME.round_resets.ante or 0)
        G.GAME.botg_fam_used = {}
        G.GAME.botg_fam_used_round = current_round_id
        G.GAME.botg_drawing_from_discard = nil
        G.GAME.botg_drawing_from_play = nil
        if G.botg_familiars and G.botg_familiars.cards then
            for _, fam in ipairs(G.botg_familiars.cards) do
                fam:set_debuff(false)
                fam.debuff = false
            end
            if G.botg_familiars.cards[1] then
                local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
                if k == 'c_reality_warp_baby_hook' and G.GAME.current_round then
                    G.GAME.current_round.free_rerolls = (G.GAME.current_round.free_rerolls or 0) + 1
                    if calculate_reroll_cost then calculate_reroll_cost() end
                end
            end
        end
    end
end

if new_round then
    local orig_new_round = new_round
    function new_round()
        orig_new_round()
        reset_botg_fam_round_state()
    end
end

if end_round then
    local orig_end_round = end_round
    function end_round()
        orig_end_round()
        reset_botg_fam_round_state()
    end
end

if Blind and Blind.set_blind then
    local orig_set_blind = Blind.set_blind
    function Blind:set_blind(blind, reset, silent)
        orig_set_blind(self, blind, reset, silent)
        reset_botg_fam_round_state()
    end
end

function reset_round()
    reset_botg_fam_round_state()
end

if SMODS and SMODS.get_card_areas then
    local orig_get_card_areas = SMODS.get_card_areas
    function SMODS.get_card_areas(_type, _context)
        local t = orig_get_card_areas(_type, _context)
        if _type == 'jokers' and G.botg_familiars and G.botg_familiars.cards and #G.botg_familiars.cards > 0 then
            local found = false
            for _, a in ipairs(t) do
                if a == G.botg_familiars then found = true; break end
            end
            if not found then table.insert(t, G.botg_familiars) end
        end
        return t
    end
end

if SMODS and SMODS.optional_features then
    SMODS.optional_features.retrigger_joker = true
end

if Card and Card.calculate_joker then
    local orig_calculate_joker = Card.calculate_joker
    function Card:calculate_joker(context)
        if self.area and self.area == G.botg_familiars then
            return botg_calculate_familiar(self, context)
        end
        return orig_calculate_joker(self, context)
    end
end

function botg_calculate_familiar(self, context)
    if not G.GAME then return end
    local fam = self
    local f_key = fam.config and fam.config.center and fam.config.center.key
    if not f_key then return end

    fam.debuff = false
    local current_round_id = tostring(G.GAME.round or 0) .. '_' .. tostring(G.GAME.round_resets and G.GAME.round_resets.ante or 0)
    if G.GAME.botg_fam_used_round ~= current_round_id then
        G.GAME.botg_fam_used = {}
        G.GAME.botg_fam_used_round = current_round_id
    end

    if context.setting_blind or context.end_of_round then
        G.GAME.botg_fam_used = {}
        G.GAME.botg_fam_used_round = current_round_id
        fam:set_debuff(false)
        fam.debuff = false
    end

    if botg_trigger_mod_achievement then
        botg_trigger_mod_achievement('divine_familiar')
    end

    local fam_level = botg_get_familiar_level(f_key)

    if f_key == 'c_reality_warp_baby_needle' and context.joker_main and G.GAME.current_round.hands_played == 0 then
        local chips = 20 * fam_level
        local mult = 3 * fam_level
        return {
            chips = chips,
            chip_mod = chips,
            mult = mult,
            mult_mod = mult,
            card = self,
            message = '+' .. chips .. ' / +' .. mult .. ' [Baby Needle Lv.' .. fam_level .. ']',
            colour = G.C.GOLD
        }
    end

    if f_key == 'c_reality_warp_baby_flint' then
        if context.joker_main then
            local xm = 1.0 + 0.1 * fam_level
            return {
                x_mult = xm,
                message = 'X' .. xm .. ' Mult [Baby Flint Lv.' .. fam_level .. ']',
                colour = HEX('e56a2f')
            }
        elseif context.individual and context.cardarea == G.play and context.other_card then
            local p_chips = fam_level
            local p_mult = math.floor(fam_level / 2)
            context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + p_chips
            if p_mult > 0 then
                context.other_card.ability.perma_mult = (context.other_card.ability.perma_mult or 0) + p_mult
            end
            return {
                extra = { message = '+' .. p_chips .. (p_mult > 0 and (' / +' .. p_mult) or ''), colour = HEX('e56a2f') },
                card = context.other_card
            }
        end
    end

    if f_key == 'c_reality_warp_baby_hook' and (context.starting_shop or context.ending_shop) then
        if G.GAME.current_round then
            local free_amt = (fam_level >= 4) and 2 or 1
            G.GAME.current_round.free_rerolls = (G.GAME.current_round.free_rerolls or 0) + free_amt
            if calculate_reroll_cost then calculate_reroll_cost() end
        end
        return {
            message = 'Free Reroll! [Baby Hook Lv.' .. fam_level .. ']',
            colour = G.C.GREEN
        }
    end

    if f_key == 'c_reality_warp_baby_eye' and context.joker_main and context.scoring_name then
        if G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].played > 1 then
            local xm = 1.0 + 0.15 * fam_level
            return {
                x_mult = xm,
                message = 'X' .. xm .. ' Mult [Baby Eye Lv.' .. fam_level .. ']',
                colour = G.C.BLUE
            }
        end
    end

    if f_key == 'c_reality_warp_baby_ox' and context.after and context.scoring_name then
        if context.scoring_name == G.GAME.current_round.most_played_poker_hand then
            local cash = fam_level
            return {
                dollars = cash,
                message = '+$' .. cash .. ' [Baby Ox Lv.' .. fam_level .. ']',
                colour = G.C.MONEY
            }
        end
    end

    if f_key == 'c_reality_warp_baby_house' and context.joker_main and G.GAME.current_round.hands_played == 0 then
        local xm = 1.0 + 0.1 * fam_level
        return {
            x_mult = xm,
            message = 'X' .. xm .. ' Mult [Baby House Lv.' .. fam_level .. ']',
            colour = HEX('5186a8')
        }
    end

    if f_key == 'c_reality_warp_baby_club' and context.individual and context.cardarea == G.play and context.other_card then
        if context.other_card:is_suit('Clubs') then
            local chips = 8 * fam_level
            local mult = fam_level
            return {
                chips = chips,
                mult = mult,
                card = context.other_card,
                message = '+' .. chips .. ' / +' .. mult .. ' [Baby Club Lv.' .. fam_level .. ']',
                colour = HEX('b9cb92')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_fish' and context.after then
        G.GAME.botg_drawing_from_play = true
    end

    if f_key == 'c_reality_warp_baby_window' and context.individual and context.cardarea == G.play and context.other_card then
        if context.other_card:is_suit('Diamonds') then
            local mult = fam_level
            local dollars = (fam_level >= 3) and 1 or 0
            return {
                dollars = dollars,
                mult = mult,
                card = context.other_card,
                message = (dollars > 0 and ('+$' .. dollars .. ' / ') or '') .. '+' .. mult .. ' Mult [Baby Window Lv.' .. fam_level .. ']',
                colour = HEX('a9a295')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_wheel' and context.individual and context.cardarea == G.play and context.other_card then
        if pseudorandom('baby_wheel') < (G.GAME.probabilities.normal or 1) / 3 then
            local mult = 6 * fam_level
            return {
                mult = mult,
                card = context.other_card,
                message = '+' .. mult .. ' Mult! [Baby Wheel Lv.' .. fam_level .. ']',
                colour = HEX('50bf7c')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_psychic' and context.joker_main then
        if (context.full_hand and #context.full_hand == 5) or (G.play and G.play.cards and #G.play.cards == 5) then
            local chips = 15 + 20 * (fam_level - 1)
            local mult = 2 + 3 * (fam_level - 1)
            return {
                chips = chips,
                chip_mod = chips,
                mult = mult,
                mult_mod = mult,
                card = self,
                message = '+' .. chips .. ' / +' .. mult .. ' [Baby Psychic Lv.' .. fam_level .. ']',
                colour = HEX('efc03c')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_goad' and context.individual and context.cardarea == G.play and context.other_card then
        if context.other_card:is_suit('Spades') then
            local chips = 8 * fam_level
            local mult = fam_level
            return {
                chips = chips,
                mult = mult,
                card = context.other_card,
                message = '+' .. chips .. ' / +' .. mult .. ' [Baby Goad Lv.' .. fam_level .. ']',
                colour = HEX('b95c96')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_water' and context.setting_blind then
        local disc = (fam_level >= 4) and 2 or 1
        ease_discard(disc)
        return {
            message = '+' .. disc .. ' Discard [Baby Water Lv.' .. fam_level .. ']',
            colour = G.C.RED
        }
    end

    if f_key == 'c_reality_warp_baby_mouth' then
        local mult = 3 * fam_level
        local cash = math.min(6, fam_level + 1)
        if context.joker_main then
            local types_played = 0
            for _, count in pairs(G.GAME.current_round.hands_played_this_round or {}) do
                if count and count > 0 then types_played = types_played + 1 end
            end
            if types_played <= 1 then
                return {
                    mult = mult,
                    mult_mod = mult,
                    card = self,
                    message = '+' .. mult .. ' Mult [Baby Mouth Lv.' .. fam_level .. ']',
                    colour = G.C.MULT
                }
            end
        elseif context.end_of_round and not context.individual and not context.repetition then
            local types_played = 0
            for _, count in pairs(G.GAME.current_round.hands_played_this_round or {}) do
                if count and count > 0 then types_played = types_played + 1 end
            end
            if types_played == 1 then
                return {
                    dollars = cash,
                    card = self,
                    message = '+$' .. cash .. ' Pure Hand! [Baby Mouth Lv.' .. fam_level .. ']',
                    colour = G.C.MONEY
                }
            end
        end
    end

    if f_key == 'c_reality_warp_baby_plant' and context.individual and context.cardarea == G.play and context.other_card then
        if context.other_card:is_face() then
            local chips = 12 * fam_level
            local mult = 2 * fam_level
            return {
                chips = chips,
                mult = mult,
                card = context.other_card,
                message = '+' .. chips .. ' / +' .. mult .. ' [Baby Plant Lv.' .. fam_level .. ']',
                colour = HEX('709284')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_head' and context.individual and context.cardarea == G.play and context.other_card then
        if context.other_card:is_suit('Hearts') then
            local chips = 8 * fam_level
            local mult = fam_level
            return {
                chips = chips,
                mult = mult,
                card = context.other_card,
                message = '+' .. chips .. ' / +' .. mult .. ' [Baby Head Lv.' .. fam_level .. ']',
                colour = HEX('ac9db4')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_tooth' and context.after and context.scoring_hand then
        local freq = math.max(1, 6 - fam_level)
        local money_gain = math.floor(#context.scoring_hand / freq)
        if money_gain > 0 then
            return {
                dollars = money_gain,
                message = '+$' .. money_gain .. ' [Baby Tooth Lv.' .. fam_level .. ']',
                colour = G.C.MONEY
            }
        end
    end

    if f_key == 'c_reality_warp_baby_mark' and context.individual and context.cardarea == G.play and context.other_card then
        if context.other_card:is_face() then
            local xm = 1.0 + 0.1 * fam_level
            return {
                x_mult = xm,
                card = context.other_card,
                message = 'X' .. xm .. ' [Baby Mark Lv.' .. fam_level .. ']',
                colour = HEX('6a3847')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_heart' and context.joker_main then
        local j_count = (G.jokers and G.jokers.cards and #G.jokers.cards) or 0
        local bonus_m = j_count * (2 * fam_level)
        if bonus_m > 0 then
            return {
                mult = bonus_m,
                mult_mod = bonus_m,
                card = self,
                message = '+' .. bonus_m .. ' Mult [Baby Heart Lv.' .. fam_level .. ']',
                colour = HEX('ac3232')
            }
        end
    end

    if f_key == 'c_reality_warp_baby_bell' and context.repetition and context.cardarea == G.play then
        local chance = 0.2 * fam_level
        if pseudorandom('baby_bell') < chance then
            return {
                message = 'Again! [Baby Bell Lv.' .. fam_level .. ']',
                repetitions = 1,
                card = context.other_card
            }
        end
    end

    if f_key == 'c_reality_warp_baby_acorn' and (context.retrigger_joker_check or context.retrigger_joker) and G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
        if context.other_card == G.jokers.cards[#G.jokers.cards] then
            local chance = 0.2 * fam_level
            if pseudorandom('baby_acorn') < chance then
                return {
                    message = 'Again! [Baby Acorn Lv.' .. fam_level .. ']',
                    repetitions = 1,
                    card = context.other_card or self
                }
            end
        end
    end
end

if Blind and Blind.debuff_card then
    local orig_debuff_card = Blind.debuff_card
    function Blind:debuff_card(card, from_blind)
        if card and (card.area == G.botg_familiars or (card.ability and card.ability.set == 'Familiar')) then
            card:set_debuff(false)
            card.debuff = false
            return
        end
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
            if (k == 'c_reality_warp_baby_pillar' or k == 'c_reality_warp_baby_leaf') and card and card.ability and card.ability.set ~= 'Joker' then
                card:set_debuff(false)
                return
            end
            if (k == 'c_reality_warp_baby_heart' or k == 'c_reality_warp_baby_leaf') and card and card.ability and card.ability.set == 'Joker' then
                card:set_debuff(false)
                return
            end
        end
        return orig_debuff_card(self, card, from_blind)
    end
end

if Card and Card.set_debuff then
    local orig_card_set_debuff = Card.set_debuff
    function Card:set_debuff(should_debuff)
        if self.area and self.area == G.botg_familiars then
            self.debuff = false
            return orig_card_set_debuff(self, false)
        end
        if self.ability and self.ability.set == 'Familiar' then
            self.debuff = false
            return orig_card_set_debuff(self, false)
        end
        if should_debuff and G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
            if (k == 'c_reality_warp_baby_pillar' or k == 'c_reality_warp_baby_leaf') and self.ability and self.ability.set ~= 'Joker' then
                return orig_card_set_debuff(self, false)
            end
            if (k == 'c_reality_warp_baby_heart' or k == 'c_reality_warp_baby_leaf') and self.ability and self.ability.set == 'Joker' then
                return orig_card_set_debuff(self, false)
            end
        end
        return orig_card_set_debuff(self, should_debuff)
    end
end

if G.FUNCS and G.FUNCS.discard_cards_from_highlighted then
    local orig_discard = G.FUNCS.discard_cards_from_highlighted
    G.FUNCS.discard_cards_from_highlighted = function(e, hook)
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
            if k == 'c_reality_warp_baby_serpent' and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 and (G.GAME.current_round and G.GAME.current_round.discards_left or 0) > 0 then
                G.GAME.botg_drawing_from_discard = true
            end
        end
        orig_discard(e, hook)
    end
end

if G.FUNCS and G.FUNCS.draw_from_deck_to_hand then
    local orig_draw = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
            local fam_level = botg_get_familiar_level(k)
            local extra = (fam_level >= 4) and 3 or ((fam_level >= 2) and 2 or 1)

            if G.deck and G.deck.cards and G.hand and G.hand.config and G.hand.cards then
                if k == 'c_reality_warp_baby_serpent' and G.GAME.botg_drawing_from_discard then
                    G.GAME.botg_drawing_from_discard = nil
                    G.botg_familiars.cards[1]:juice_up(0.3, 0.3)
                    e = (e or math.min(#G.deck.cards, G.hand.config.card_limit - #G.hand.cards)) + extra
                    e = math.min(#G.deck.cards, e)
                elseif k == 'c_reality_warp_baby_fish' and G.GAME.botg_drawing_from_play then
                    G.GAME.botg_drawing_from_play = nil
                    G.botg_familiars.cards[1]:juice_up(0.3, 0.3)
                    e = (e or math.min(#G.deck.cards, G.hand.config.card_limit - #G.hand.cards)) + extra
                    e = math.min(#G.deck.cards, e)
                end
            end
        end
        orig_draw(e)
    end
end

if ease_discard then
    local orig_ease_discard = ease_discard
    function ease_discard(mod, instant, reset)
        orig_ease_discard(mod, instant, reset)
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
            if k == 'c_reality_warp_baby_hook' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        if G.GAME.current_round and (G.GAME.current_round.discards_left or 0) < 1 then
                            G.GAME.current_round.discards_left = 1
                            if G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
                                G.botg_familiars.cards[1]:juice_up(0.3, 0.3)
                            end
                        end
                        return true
                    end
                }))
            end
        end
    end
end

if Card and Card.sell_card then
    local orig_sell = Card.sell_card
    function Card:sell_card()
        orig_sell(self)
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] then
            local k = G.botg_familiars.cards[1].config and G.botg_familiars.cards[1].config.center and G.botg_familiars.cards[1].config.center.key
            if k == 'c_reality_warp_baby_leaf' and self.ability and self.ability.set == 'Joker' then
                local fam_level = botg_get_familiar_level(k)
                local cash = 3 * fam_level
                ease_dollars(cash)
                G.botg_familiars.cards[1]:juice_up(0.4, 0.4)
                attention_text({ text = '+$' .. cash .. ' Bounty! [Baby Leaf Lv.' .. fam_level .. ']', scale = 0.7, hold = 1.2, major = G.botg_familiars.cards[1], align = 'tm', offset = {x=0, y=-0.5} })
            end
        end
    end
end

function Card:add_companion_speech_bubble(quote)
    if self.children.speech_bubble then
        self.children.speech_bubble:remove()
        self.children.speech_bubble = nil
    end
    local align = nil
    if self.T.x + self.T.w / 2 > G.ROOM.T.w / 2 then align = "cl" end
    self.config.speech_bubble_align = { align = align or "cr", offset = { x = align and -0.15 or 0.15, y = -0.1 }, parent = self }

    local bubble_def = {
        n = G.UIT.ROOT,
        config = { align = "cm", minh = 0.8, r = 0.25, padding = 0.05, minw = 1.0, colour = G.C.JOKER_GREY, shadow = true },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "cm", minh = 0.8, r = 0.18, padding = 0.08, minw = 1.0, colour = G.C.WHITE, emboss = 0.04 },
                nodes = {
                    { n = G.UIT.T, config = { text = quote, scale = 0.28, colour = G.C.UI.TEXT_DARK, shadow = false } }
                }
            }
        }
    }
    self.children.speech_bubble = UIBox{
        definition = bubble_def,
        config = self.config.speech_bubble_align
    }
    self.children.speech_bubble:set_role{ role_type = "Minor", xy_bond = "Strong", r_bond = "Weak", major = self }
    local bubble = self.children.speech_bubble
    local hold_time = (G.SETTINGS.GAMESPEED * 3.5) or 3.5
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = hold_time,
        blockable = false,
        blocking = false,
        func = function()
            if self.children.speech_bubble == bubble then
                self.children.speech_bubble:remove()
                self.children.speech_bubble = nil
            end
            return true
        end
    }))
end

if Card and Card.draw then
    local orig_card_draw = Card.draw
    function Card:draw(layer)
        orig_card_draw(self, layer)
        if self.children and self.children.speech_bubble and self.children.speech_bubble.draw then
            self.children.speech_bubble:draw()
        end
    end
end

if Card and Card.click then
    local orig_card_click = Card.click
    function Card:click()
        orig_card_click(self)
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] == self then
            self:juice_up(0.4, 0.4)
            play_sound("voice" .. math.random(1, 11), G.SPEEDFACTOR * (math.random() * 0.2 + 1), 0.5)
            local fam_key = self.config and self.config.center and self.config.center.key
            local clean_k = tostring(fam_key):gsub('^c_reality_warp_', ''):gsub('^c_', '')
            local fam_def = G.NURSERY_ROOM_BY_KEY and G.NURSERY_ROOM_BY_KEY[clean_k]
            local current_room = (fam_def and fam_def.favored_room and G.NURSERY_ROOMS[fam_def.favored_room]) or (G.NURSERY_ROOMS and G.NURSERY_ROOMS[1])
            local quote = (fam_def and get_nursery_dynamic_dialogue and get_nursery_dynamic_dialogue(fam_def, 'present', current_room)) or "Ready for action!"
            self:add_companion_speech_bubble(quote)
        end
    end
end

if Controller and Controller.update then
    local orig_controller_update = Controller.update
    function Controller:update(dt)
        orig_controller_update(self, dt)
        if G.GAME and G.botg_familiars and G.botg_familiars.cards and G.botg_familiars.cards[1] and self.cursor_hover and self.cursor_hover.target and self.cursor_hover.target == G.botg_familiars.cards[1] then
            local fam_card = G.botg_familiars.cards[1]
            if not G.GAME.partner_pet_dist or not G.GAME.partner_pet_dist_T then
                G.GAME.partner_pet_dist = 0
                G.GAME.partner_pet_dist_T = { x = self.cursor_position.x, y = self.cursor_position.y }
            else
                G.GAME.partner_pet_dist = G.GAME.partner_pet_dist + Vector_Dist(G.GAME.partner_pet_dist_T, { x = self.cursor_position.x, y = self.cursor_position.y })
                G.GAME.partner_pet_dist_T = { x = self.cursor_position.x, y = self.cursor_position.y }
                if G.GAME.partner_pet_dist > 350 and not G.GAME.partner_pet_deal then
                    G.GAME.partner_pet_deal = true
                    fam_card:juice_up(0.5, 0.5)
                    play_sound("voice" .. math.random(1, 11), G.SPEEDFACTOR * (math.random() * 0.2 + 1), 0.5)
                    local fam_key = fam_card.config and fam_card.config.center and fam_card.config.center.key
                    local clean_k = tostring(fam_key):gsub('^c_reality_warp_', ''):gsub('^c_', '')
                    local fam_def = G.NURSERY_ROOM_BY_KEY and G.NURSERY_ROOM_BY_KEY[clean_k]
                    local quote = (fam_def and get_nursery_dynamic_dialogue and get_nursery_dynamic_dialogue(fam_def, 'pet')) or "Purr... happy to travel with you!"
                    fam_card:add_companion_speech_bubble(quote)
                    if not G.GAME.pet_exp_granted_this_round then
                        G.GAME.pet_exp_granted_this_round = true
                        if add_nursery_exp then add_nursery_exp(clean_k, 5) end
                    end
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.GAME.partner_pet_dist = 0
                            G.GAME.partner_pet_deal = nil
                            return true
                        end
                    }))
                end
            end
        elseif (not self.cursor_hover or not self.cursor_hover.target or (G.botg_familiars and G.botg_familiars.cards and self.cursor_hover.target ~= G.botg_familiars.cards[1])) and (G.GAME and (G.GAME.partner_pet_dist or G.GAME.partner_pet_dist_T)) then
            G.GAME.partner_pet_dist = nil
            G.GAME.partner_pet_dist_T = nil
        end
    end
end

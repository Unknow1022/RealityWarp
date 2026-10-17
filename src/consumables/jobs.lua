
SMODS.ConsumableType {
    key = 'Job',
    primary_colour = HEX('ffffff'),
    secondary_colour = HEX('52525c'),
    loc_txt = {
        name = 'Job',
        collection = 'Job Cards',
        underscores_single = 'Job Card',
        underscores_plural = 'Job Cards'
    },
    shop_rate = 0.0,
    collection_rows = { 2, 7 },
    default = 'c_reality_warp_miner_job'
}

local JOB_CARD_KEYS = {
    'c_reality_warp_miner_job',
    'c_reality_warp_gardener_job',
    'c_reality_warp_banker_job',
    'c_reality_warp_surgeon_job',
    'c_reality_warp_alchemist_job',
    'c_reality_warp_butcher_job',
    'c_reality_warp_detective_job',
    'c_reality_warp_chef_job',
    'c_reality_warp_archaeologist_job',
    'c_reality_warp_jeweler_job',
    'c_reality_warp_apothecary_job',
    'c_reality_warp_bounty_hunter_job',
    'c_reality_warp_croupier_job'
}

local function create_job_card_for_pack(key_append)
    local card_obj = nil
    if create_card then
        card_obj = create_card('Job', G.pack_cards, nil, nil, true, false, nil, key_append or 'job_pack')
    end
    if (not card_obj or not card_obj.config) and SMODS and SMODS.create_card then
        card_obj = SMODS.create_card({ set = 'Job', area = G.pack_cards, skip_materialize = true, key_append = key_append or 'job_pack' })
    end
    if not card_obj or not card_obj.config then
        local valid_keys = {}
        for _, k in ipairs(JOB_CARD_KEYS) do
            if G.P_CENTERS and G.P_CENTERS[k] then
                table.insert(valid_keys, k)
            end
        end
        local chosen_key = (#valid_keys > 0) and pseudorandom_element(valid_keys, pseudoseed(key_append or 'job_pack_valid')) or pseudorandom_element(JOB_CARD_KEYS, pseudoseed(key_append or 'job_pack_fallback'))
        local center = (G.P_CENTERS and G.P_CENTERS[chosen_key]) or (G.P_CENTERS and G.P_CENTERS[string.gsub(chosen_key, 'c_reality_warp_', 'c_')])
        if center then
            card_obj = Card(G.pack_cards.T.x + G.pack_cards.T.w/2, G.pack_cards.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center, {bypass_discovery_center = true, bypass_discovery_ui = true})
        end
    end
    return card_obj
end

SMODS.Atlas {
    key = "job_stickers",
    path = "job_stickers.png",
    px = 71,
    py = 95
}

local ALL_JOB_STICKERS = {
    'gardener_job',
    'detective_job',
    'chef_job',
    'archaeologist_job',
    'miner_job',
    'jeweler_job',
    'apothecary_job',
    'bounty_hunter_job',
    'croupier_job'
}

local function clear_card_jobs(card)
    if card and card.ability then
        for _, k in ipairs(ALL_JOB_STICKERS) do
            if card.ability[k] and SMODS.Stickers and SMODS.Stickers[k] then
                SMODS.Stickers[k]:apply(card, false)
            end
            card.ability[k] = nil
        end
    end
end


SMODS.Sticker {
    key = "detective_job",
    atlas = "job_stickers",
    pos = { x = 1, y = 0 },
    badge_colour = HEX('2980b9'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Detective',
        label = 'Detective',
        text = {
            "On opening hand of the round,",
            "reveals the next 3 drawn cards and",
            "gives them {C:gold}Gold Seal{} or {C:blue}Blue Seal{}"
        }
    },
    calculate = function(self, card, context)
        if context.first_hand_drawn and card.area == G.hand then
            if G.deck and G.deck.cards and #G.deck.cards > 0 then
                local count = math.min(3, #G.deck.cards)
                local seals = { 'Gold', 'Blue' }
                local start_msg = 'Investigating Deck!'
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = start_msg, colour = HEX('2980b9') })
                for i = 1, count do
                    local top_c = G.deck.cards[#G.deck.cards - (i - 1)]
                    if top_c then
                        local chosen_seal = pseudorandom_element(seals, pseudoseed('detective_seal'))
                        top_c:set_seal(chosen_seal, true)
                        top_c:juice_up(0.4, 0.4)
                        local rank_str = (top_c.base and top_c.base.value) or 'Card'
                        local suit_str = (top_c.base and top_c.base.suit) or ''
                        local seal_name = chosen_seal == 'Gold' and 'Gold' or 'Blue'
                        local of_str = ' of '
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            func = function()
                                play_sound('tarot1', 1 + 0.1 * i)
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = rank_str .. of_str .. suit_str .. ' (' .. seal_name .. ')',
                                    colour = chosen_seal == 'Gold' and G.C.GOLD or G.C.BLUE
                                })
                                return true
                            end
                        }))
                    end
                end
                return {
                    message = 'Clues Discovered!',
                    colour = HEX('2980b9'),
                    card = card
                }
            end
        end
    end
}

SMODS.Sticker {
    key = "chef_job",
    atlas = "job_stickers",
    pos = { x = 2, y = 0 },
    badge_colour = HEX('e67e22'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Chef',
        label = 'Chef',
        text = {
            "When scoring face cards (J, Q, K),",
            "converts all other scored cards",
            "into {C:mult}Mult Cards{}"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play and card:is_face() then
            local converted = 0
            if context.scoring_hand then
                for _, other_c in ipairs(context.scoring_hand) do
                    if other_c ~= card and other_c.config and other_c.config.center ~= G.P_CENTERS.m_mult then
                        other_c:set_ability(G.P_CENTERS.m_mult)
                        other_c:juice_up(0.5, 0.5)
                        converted = converted + 1
                    end
                end
            end
            if converted > 0 then
                play_sound('tarot1')
                return {
                    message = 'Seasoned!',
                    colour = HEX('e67e22'),
                    card = card
                }
            end
        end
    end
}




SMODS.Sticker {
    key = "bounty_hunter_job",
    atlas = "job_stickers",
    pos = { x = 2, y = 1 },
    badge_colour = HEX('c0392b'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Bounty Hunter',
        label = 'Bounty Hunter',
        text = {
            "Each round, a random rank becomes the {C:red}Wanted Target{}.",
            "Scoring this card alongside the target",
            "awards {C:money}+$7{} and {X:mult,C:white}X1.5{} Mult",
            "{C:inactive}(Current Wanted Target: {C:attention}#1#{}{C:inactive}){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { (G.GAME and G.GAME.wanted_target_rank) or 'None' } }
    end,
    calculate = function(self, card, context)
        if context.first_hand_drawn and card.area == G.hand then
            local ranks = { '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace' }
            G.GAME.wanted_target_rank = pseudorandom_element(ranks, pseudoseed('bounty_target'))
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = 'Wanted: ' .. tostring(G.GAME.wanted_target_rank) .. '!',
                colour = HEX('c0392b')
            })
        end

        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local target_rank = G.GAME.wanted_target_rank
            if target_rank and context.scoring_hand then
                local has_target = false
                for _, sc in ipairs(context.scoring_hand) do
                    local val = sc.base and sc.base.value
                    if val == target_rank or (sc.get_id and sc:get_id() == target_rank) then
                        has_target = true
                        break
                    end
                end

                if has_target then
                    ease_dollars(7)
                    return {
                        x_mult = 1.5,
                        message = 'Bounty Claimed! +$7',
                        colour = G.C.GOLD,
                        card = card
                    }
                end
            end
        end
    end
}


SMODS.Atlas {
    key = "c_jobs",
    path = "c_jobs.png",
    px = 71,
    py = 95
}

SMODS.Consumable {
    key = 'miner_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'The Miner',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:dark_edition}Shiny Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_diamond_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_diamond_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Shiny Card!',
            colour = HEX('1b4d2e')
        })
    end
}

SMODS.Consumable {
    key = 'gardener_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'The Gardener',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Sprout Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_sprout_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_sprout_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Sprout Card!',
            colour = HEX('27ae60')
        })
    end
}

SMODS.Consumable {
    key = 'banker_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'The Banker',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into an {C:attention}Investment Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_investment_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'gold_seal',
            apply = function(c)
                local center = get_investment_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Investment Card!',
            colour = G.C.MONEY
        })
    end
}

SMODS.Consumable {
    key = 'surgeon_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'The Surgeon',
        text = {
            "Destroys the {C:attention}1st selected card{} and",
            "transfers all its bonus Chips, Enhancement,",
            "Seal, and Edition to the {C:attention}2nd selected card{}"
        }
    },
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 2
    end,
    use = function(self, card, area, copier)
        local donor = G.hand.highlighted[1]
        local recipient = G.hand.highlighted[2]

        reality_warp_flip_apply({
            card = card,
            targets = recipient,
            sound = 'tarot1',
            apply = function(rec)
                local donor_bonus = (donor.ability and donor.ability.perma_bonus) or 0
                rec.ability = rec.ability or {}
                rec.ability.perma_bonus = (rec.ability.perma_bonus or 0) + donor_bonus

                if donor.config and donor.config.center and donor.config.center ~= G.P_CENTERS.c_base then
                    rec:set_ability(donor.config.center)
                end

                if donor.seal then
                    rec:set_seal(donor.seal, nil, true)
                end

                if donor.edition then
                    rec:set_edition(donor.edition, true)
                end


            end,
            message = 'Transplanted!',
            colour = G.C.RED,
            unhighlight = false
        })
        SMODS.destroy_cards(donor)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

SMODS.Consumable {
    key = 'alchemist_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 4, y = 0 },
    loc_txt = {
        name = 'The Alchemist',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Lead Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_lead_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            apply = function(c)
                local center = get_lead_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Lead Card!',
            colour = G.C.GREY
        })
    end
}

SMODS.Consumable {
    key = 'butcher_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 0, y = 1 },
    loc_txt = {
        name = 'The Butcher',
        text = {
            "Destroys {C:attention}1 selected card{} (Rank 3+)",
            "and creates {C:attention}2 cards{} dividing its rank",
            "{C:inactive}(if odd, one card has {C:attention}+1{C:inactive} rank){}",
            "with random {C:attention}Steel{}, {C:attention}Glass{}, {C:attention}Wild{}, or {C:attention}Lucky{} enhancements"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
            info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
            info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
            info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        if G.hand and G.hand.highlighted and #G.hand.highlighted == 1 then
            local id = G.hand.highlighted[1]:get_id()
            return id and id >= 3
        end
        return false
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        local original_suit = target.base and target.base.suit or 'Spades'
        local suit_prefix = string.sub(original_suit, 1, 1)
        local id = target:get_id() or 4
        local rank_strings = { [2]='2', [3]='3', [4]='4', [5]='5', [6]='6', [7]='7', [8]='8', [9]='9', [10]='10', [11]='J', [12]='Q', [13]='K', [14]='A' }
        local r1_num = math.max(2, math.floor(id / 2))
        local r2_num = math.max(2, (id % 2 == 0) and math.floor(id / 2) or (math.floor(id / 2) + 1))
        local rank_1_str = rank_strings[r1_num] or '2'
        local rank_2_str = rank_strings[r2_num] or '3'

        if G.hand then G.hand:unhighlight_all() end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                if card then card:juice_up(0.4, 0.6) end
                return true
            end
        }))
        SMODS.destroy_cards(target)

        local enhancements = { G.P_CENTERS.m_steel, G.P_CENTERS.m_glass, G.P_CENTERS.m_wild, G.P_CENTERS.m_lucky }
        for i = 1, 2 do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.25,
                func = function()
                    play_sound('tarot1')
                    local chosen_enh = pseudorandom_element(enhancements, pseudoseed('butcher_enh_' .. i))
                    local current_rank_str = (i == 1) and rank_1_str or rank_2_str
                    local new_card = create_playing_card({
                        front = G.P_CARDS[suit_prefix .. '_' .. current_rank_str] or G.P_CARDS['S_2'],
                        center = chosen_enh
                    }, G.hand, nil, i ~= 1, {G.C.SECONDARY_SET.Enhanced})
                    new_card:juice_up(0.4, 0.4)
                    return true
                end
            }))
        end
    end
}

SMODS.Consumable {
    key = 'detective_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'The Detective',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Clue Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_clue_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_clue_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Clue Card!',
            colour = HEX('2980b9')
        })
    end
}

SMODS.Consumable {
    key = 'chef_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 2, y = 1 },
    loc_txt = {
        name = 'The Chef',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into an {C:attention}Oil Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_oil_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_oil_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Oil Card!',
            colour = HEX('e67e22')
        })
    end
}

SMODS.Consumable {
    key = 'archaeologist_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 3, y = 1 },
    loc_txt = {
        name = 'The Archaeologist',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Fossil Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_fossil_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_fossil_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Fossil Card!',
            colour = HEX('d35400')
        })
    end
}

SMODS.Consumable {
    key = 'jeweler_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 4, y = 1 },
    loc_txt = {
        name = 'The Jeweler',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Jeweled Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_jeweled_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'gold_seal',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_jeweled_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Jeweled Card!',
            colour = HEX('1abc9c')
        })
    end
}

SMODS.Consumable {
    key = 'apothecary_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 0, y = 2 },
    loc_txt = {
        name = 'The Apothecary',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Tonic Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_tonic_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_tonic_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Tonic Card!',
            colour = HEX('27ae60')
        })
    end
}

SMODS.Consumable {
    key = 'bounty_hunter_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'The Bounty Hunter',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Bounty Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_bounty_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_bounty_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Bounty Card!',
            colour = HEX('c0392b')
        })
    end
}

SMODS.Consumable {
    key = 'croupier_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 2, y = 2 },
    loc_txt = {
        name = 'The Croupier',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Roulette Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_roulette_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_reality_warp_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        reality_warp_flip_apply({
            card = card,
            targets = target,
            sound = 'tarot1',
            apply = function(c)
                clear_card_jobs(c)
                local center = get_roulette_enhancement_center()
                c:set_ability(center)
            end,
            message = 'Roulette Card!',
            colour = HEX('8e44ad')
        })
    end
}

SMODS.Atlas {
    key = "c_packs",
    path = "packs.png",
    px = 71,
    py = 95
}
SMODS.Booster {
    key = 'job_pack_1',
    atlas = 'c_packs',
    pos = { x = 0, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    weight = 1.0,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_reality_warp_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 3
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}

SMODS.Booster {
    key = 'job_pack_2',
    atlas = 'c_packs',
    pos = { x = 1, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    weight = 1.0,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_reality_warp_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 3
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}

SMODS.Booster {
    key = 'job_pack_3',
    atlas = 'c_packs',
    pos = { x = 2, y = 0 },
    config = { extra = 5, choose = 1 },
    cost = 6,
    weight = 0.5,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_reality_warp_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Jumbo Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 5
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('jumbo_job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}

SMODS.Booster {
    key = 'job_pack_4',
    atlas = 'c_packs',
    pos = { x = 3, y = 0 },
    config = { extra = 5, choose = 2 },
    cost = 8,
    weight = 0.25,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_reality_warp_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Mega Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 2
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 5
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('mega_job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}



SMODS.Joker {
    key = 'doctor_jo_joker',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Doctor Jo.',
        text = {
            "Cures a random {C:attention}Debuffed{} or",
            "{C:attention}Perishable{} Joker, then",
            "{C:red,E:2}self-destructs{}."
        }
    },
    config = { extra = {} },
    rarity = 3,
    pos = { x = 0, y = 3 },
    cost = 8,
    blueprint_compat = false,
    calculate = function(self, card, context)
        if (context.setting_blind or context.starting_shop or context.end_of_round or (context.after and not context.blueprint)) and not context.blueprint and not card.getting_sliced then
            local candidates = {}
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and not j.getting_sliced and not j.dissolving then
                        local is_debuffed = j.debuff or (j.ability and j.ability.debuff)
                        local is_perishable = j.perishable or (j.ability and (j.ability.perishable or j.ability.perish_tally or j.ability.perished))
                        if is_debuffed or is_perishable then
                            table.insert(candidates, j)
                        end
                    end
                end
            end

            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('doctor_jo_cure'))
                if target then
                    if target.debuff then
                        target.debuff = false
                        target.debuffed_by_blind = nil
                        if target.set_debuff then target:set_debuff(false) end
                    end
                    if target.ability then
                        target.ability.debuff = false
                    end
                    if target.set_perishable then target:set_perishable(false) end
                    target.perishable = nil
                    if target.ability then
                        target.ability.perishable = nil
                        target.ability.perish_tally = nil
                        target.ability.perished = nil
                    end
                    target:juice_up(0.6, 0.6)
                    card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Cured!', colour = G.C.GREEN })

                    card.getting_sliced = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            play_sound('tarot1')
                            card:start_dissolve()
                            return true
                        end
                    }))
                    return {
                        message = 'Miracle Cure!',
                        colour = G.C.RED
                    }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'symmetrical_joker',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Symmetrical Joker',
        text = {
            "{X:mult,C:white}X#1#{} Mult if played {C:attention}Four or Five of a Kind{}",
            "shares the same suit across all scoring cards"
        }
    },
    config = { extra = { xmult = 4.0 } },
    rarity = 3,
    pos = { x = 1, y = 3 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.scoring_hand and context.poker_hands then
            local is_poker = (context.poker_hands['Four of a Kind'] and next(context.poker_hands['Four of a Kind'])) or
                             (context.poker_hands['Five of a Kind'] and next(context.poker_hands['Five of a Kind'])) or
                             (context.poker_hands['Flush Five'] and next(context.poker_hands['Flush Five']))
            if is_poker then
                local first_suit = context.scoring_hand[1] and context.scoring_hand[1].base and context.scoring_hand[1].base.suit
                local same_suit = true
                for _, pcard in ipairs(context.scoring_hand) do
                    if not pcard.base or pcard.base.suit ~= first_suit then
                        same_suit = false
                        break
                    end
                end
                if same_suit then
                    return {
                        Xmult = card.ability.extra.xmult
                    }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'balance_joker',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Balance',
        text = {
            "Creates {C:spectral}#1# Spectral cards{} if played",
            "{C:attention}Four of a Kind{} has all cards of the same suit",
            "{C:inactive}(Must have room){}"
        }
    },
    config = { extra = { cards_needed = 4, spectral_count = 2 } },
    rarity = 3,
    pos = { x = 2, y = 3 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local count = (card and card.ability and card.ability.extra and card.ability.extra.spectral_count) or 2
        return { vars = { count } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and context.poker_hands and context.poker_hands['Four of a Kind'] and next(context.poker_hands['Four of a Kind']) then
            if context.scoring_hand and #context.scoring_hand == 4 then
                local same_suit = false
                local suits = {'Hearts', 'Diamonds', 'Spades', 'Clubs'}
                for _, suit in ipairs(suits) do
                    local matches_all = true
                    for _, pcard in ipairs(context.scoring_hand) do
                        if not pcard:is_suit(suit) then
                            matches_all = false
                            break
                        end
                    end
                    if matches_all then
                        same_suit = true
                        break
                    end
                end

                if same_suit then
                    local count = (card.ability and card.ability.extra and card.ability.extra.spectral_count) or 1
                    local free_slots = math.max(0, G.consumeables.config.card_limit - (#G.consumeables.cards + (G.GAME.consumeable_buffer or 0)))
                    local to_create = math.min(count, free_slots)
                    if to_create > 0 then
                        G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + to_create
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                for i = 1, to_create do
                                    SMODS.add_card { set = 'Spectral', key_append = 'balance' }
                                end
                                G.GAME.consumeable_buffer = 0
                                return true
                            end
                        }))
                        return {
                            message = 'Balance!',
                            colour = G.C.SECONDARY_SET.Spectral
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'merchant_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Merchant',
        text = {
            "+1 card slot, +1 voucher, +1 pack, and 25% discount in shop.",
            "Lose {C:money}$#1#{} upon leaving shop"
        },
        unlock = {
            "Enter a shop with at least {C:money}$50{}",
            "and leave with {C:money}$10{} or less"
        }
    },
    config = { extra = { cost_per_shop = 5 } },
    rarity = 3,
    pos = { x = 3, y = 3 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cost_per_shop } }
    end,
    check_for_unlock = function(self, args)
        if args.type == 'leave_shop' or args.type == 'ending_shop' then
            local entered = (to_number and to_number(G.GAME and G.GAME.entered_shop_dollars)) or tonumber(G.GAME and G.GAME.entered_shop_dollars) or 0
            local current = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
            if G.GAME and G.GAME.entered_shop_dollars and entered >= 50 and current <= 10 then
                return true
            end
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.shop.joker_max = (G.GAME.shop.joker_max or 2) + 1
        G.GAME.modifiers.extra_vouchers = (G.GAME.modifiers.extra_vouchers or 0) + 1
        G.GAME.modifiers.extra_packs = (G.GAME.modifiers.extra_packs or 0) + 1
        G.GAME.discount_percent = (G.GAME.discount_percent or 0) + 25
        G.GAME.merchant_rare_boost = (G.GAME.merchant_rare_boost or 0) + 1
        if G.shop_jokers and (G.STATE == G.STATES.SHOP or (G.shop and not G.shop.REMOVED)) then
            G.shop_jokers.config.card_limit = G.GAME.shop.joker_max
            G.shop_jokers.T.w = G.shop_jokers.config.card_limit * 1.02 * G.CARD_W
            if G.shop_jokers.align_cards then G.shop_jokers:align_cards() end
            if G.shop and G.shop.recalculate then G.shop:recalculate() end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.shop.joker_max = math.max(1, (G.GAME.shop.joker_max or 3) - 1)
        G.GAME.modifiers.extra_vouchers = math.max(0, (G.GAME.modifiers.extra_vouchers or 0) - 1)
        G.GAME.modifiers.extra_packs = math.max(0, (G.GAME.modifiers.extra_packs or 0) - 1)
        G.GAME.discount_percent = math.max(0, (G.GAME.discount_percent or 0) - 25)
        G.GAME.merchant_rare_boost = math.max(0, (G.GAME.merchant_rare_boost or 0) - 1)
        if G.shop_jokers and (G.STATE == G.STATES.SHOP or (G.shop and not G.shop.REMOVED)) then
            G.shop_jokers.config.card_limit = G.GAME.shop.joker_max
            G.shop_jokers.T.w = G.shop_jokers.config.card_limit * 1.02 * G.CARD_W
            if G.shop_jokers.align_cards then G.shop_jokers:align_cards() end
            if G.shop and G.shop.recalculate then G.shop:recalculate() end
        end
    end,
    calculate = function(self, card, context)
        if context.ending_shop then
            ease_dollars(-card.ability.extra.cost_per_shop)
            return {
                message = '-$' .. card.ability.extra.cost_per_shop,
                colour = G.C.MONEY
            }
        end
    end
}

SMODS.Joker {
    key = 'lover_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Lover',
        text = {
            "Bonds 2 cards as {C:attention}Soulmates{}: drawing one draws partner.",
            "Scoring both gives {X:mult,C:white}X#1#{} Mult, {C:money}+$#2#{}, and permanent {C:chips}+#3#{} Chips.",
            "Scored {C:hearts}Hearts{} give {C:mult}+#4#{} Mult",
            "{C:inactive}(Soulmates: #5# and #6#){}"
        },
        unlock = {
            "Play a {C:attention}Flush{} of all 4 suits",
            "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
            "in a single run"
        }
    },
    config = { extra = { xmult = 3.0, dollars = 6, perma_chips = 10, heart_mult = 10 } },
    rarity = 3,
    pos = { x = 4, y = 3 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local sm1, sm2 = get_or_pick_soulmates()
        local sm1_str = format_soulmate_card_name(sm1)
        local sm2_str = format_soulmate_card_name(sm2)
        return { vars = { ex.xmult, ex.dollars, ex.perma_chips, ex.heart_mult, sm1_str, sm2_str } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    add_to_deck = function(self, card, from_debuff)
        get_or_pick_soulmates()
    end,
    calculate = function(self, card, context)
        if (context.setting_blind or context.first_hand_drawn) and not context.blueprint then
            get_or_pick_soulmates()
        end

        if (context.first_hand_drawn or context.before) and not context.blueprint then
            local in_hand = {}
            local in_deck = {}
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.ability and c.ability.is_soulmate then table.insert(in_hand, c) end
                end
            end
            if #in_hand == 1 and G.deck and G.deck.cards then
                for _, c in ipairs(G.deck.cards) do
                    if c.ability and c.ability.is_soulmate then table.insert(in_deck, c) end
                end
                if #in_deck >= 1 then
                    local partner = in_deck[1]
                    draw_card(G.deck, G.hand, 1, 'up', nil, partner)
                    return {
                        message = 'Soulmates Reunited!',
                        colour = G.C.HEARTS
                    }
                end
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Hearts') then
                return {
                    mult = card.ability.extra.heart_mult,
                    card = card
                }
            end
        end

        if context.joker_main and context.scoring_hand then
            local soulmates_scored = {}
            for _, sc in ipairs(context.scoring_hand) do
                if sc.ability and sc.ability.is_soulmate then
                    table.insert(soulmates_scored, sc)
                end
            end
            if #soulmates_scored >= 2 then
                if not context.blueprint then
                    for _, sm in ipairs(soulmates_scored) do
                        sm.ability = sm.ability or {}
                        sm.ability.perma_bonus = (sm.ability.perma_bonus or 0) + card.ability.extra.perma_chips
                    end
                end
                return {
                    Xmult = card.ability.extra.xmult,
                    dollars = card.ability.extra.dollars,
                    message = 'TRUE LOVE! X' .. card.ability.extra.xmult,
                    colour = G.C.HEARTS
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'blacksmith_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Blacksmith',
        text = {
            "Played cards add {C:attention}+#1#{} Heat to the forge.",
            "At {C:attention}#2# Heat{}, strikes the anvil: {C:green}#4# in #5#{} chance",
            "to apply a {C:attention}Silver Seal{} or {C:attention}Steel Card{} enhancement",
            "to the highest scored card and cools to 0 {C:inactive}(Current: #3#/#2# Heat){}"
        },
        unlock = {
            "Play a {C:attention}Flush{} of all 4 suits",
            "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
            "in a single run"
        }
    },
    config = { extra = { temp = 0, heat_per_card = 10, max_temp = 100 } },
    rarity = 3,
    pos = { x = 5, y = 3 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        if info_queue then
            local silver_seal = (G.P_SEALS and (G.P_SEALS['reality_warp_silver'] or G.P_SEALS['silver'])) or { set = 'Seal', key = 'silver' }
            info_queue[#info_queue + 1] = silver_seal
            info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
        end
        local current_temp = ex.temp or 0
        local max_temp = ex.max_temp or 100
        local heat_per_card = ex.heat_per_card or 10
        local num, den = SMODS.get_probability_vars(card, 1, 2, 'blacksmith_reward')
        return { vars = { heat_per_card, max_temp, current_temp, num, den } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    calculate = function(self, card, context)
        if context.before and not context.blueprint and context.scoring_hand and #context.scoring_hand > 0 then
            local heat_gain = (card.ability and card.ability.extra and card.ability.extra.heat_per_card) or 10
            local total_gain = #context.scoring_hand * heat_gain
            card.ability.extra.temp = (card.ability.extra.temp or 0) + total_gain
            return {
                message = '+' .. total_gain .. ' Heat!',
                colour = G.C.ORANGE,
                card = card
            }
        end

        if context.joker_main and not context.blueprint then
            local current_temp = (card.ability and card.ability.extra and card.ability.extra.temp) or 0
            local max_temp = (card.ability and card.ability.extra and card.ability.extra.max_temp) or 100

            if current_temp >= max_temp and context.scoring_hand and #context.scoring_hand >= 1 then
                local highest_card = context.scoring_hand[1]
                local highest_rank = -1
                for _, sc in ipairs(context.scoring_hand) do
                    local r = sc:get_id() or 0
                    if r > highest_rank then
                        highest_rank = r
                        highest_card = sc
                    end
                end

                if highest_card then
                    play_sound('gold_seal')
                    card.ability.extra.temp = 0
                    if G.GAME then
                        G.GAME.blacksmith_forges = (G.GAME.blacksmith_forges or 0) + 1
                        if G.GAME.blacksmith_forges >= 10 and botg_trigger_mod_achievement then
                            botg_trigger_mod_achievement('master_artificer')
                        end
                    end
                    local is_seal = SMODS.pseudorandom_probability(card, 'blacksmith_reward', 1, 2)
                    if is_seal then
                        local silver_key = (G.P_SEALS and (G.P_SEALS['reality_warp_silver'] and 'reality_warp_silver' or G.P_SEALS['Witch brew_silver'] and 'Witch brew_silver' or G.P_SEALS['silver'] and 'silver')) or 'reality_warp_silver'
                        highest_card:set_seal(silver_key, nil, true)
                        highest_card:juice_up(0.8, 0.8)
                        return {
                            message = 'Silver Seal Forged!',
                            colour = HEX('bdc3c7')
                        }
                    else
                        highest_card:set_ability(G.P_CENTERS.m_steel)
                        highest_card:juice_up(0.8, 0.8)
                        return {
                            message = 'Steel Card Forged!',
                            colour = G.C.GREY
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'lucky_one_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Lucky One',
        text = {
            "Every {C:attention}5{} scored {C:clubs}Clubs{}, the next",
            "{C:green}probability{} is guaranteed {C:green}(1 in 1){}.",
            "{C:inactive}(#2#/5 Clubs, #3# - Resets at end of round){}",
            "Gains {X:mult,C:white}+X#1#{} Mult when any probability succeeds",
            "{C:inactive}(Currently {X:mult,C:white}X#4#{C:inactive} Mult){}"
        },
        unlock = {
            "Play a {C:attention}Flush{} of all 4 suits",
            "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
            "in a single run"
        }
    },
    config = { extra = { xmult = 1.5, xmult_gain = 0.1, clubs_scored = 0, clubs_needed = 5, guaranteed = false } },
    rarity = 3,
    pos = { x = 6, y = 3 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local status = (ex and ex.guaranteed) and "Guaranteed!" or "Pending"
        return { vars = { ex.xmult_gain or 0.1, ex.clubs_scored or 0, status, ex.xmult or 1.5 } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    calculate = function(self, card, context)
        card.ability.extra = card.ability.extra or {}

        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card:is_suit('Clubs') then
                card.ability.extra.clubs_scored = (card.ability.extra.clubs_scored or 0) + 1
                if card.ability.extra.clubs_scored >= (card.ability.extra.clubs_needed or 5) then
                    card.ability.extra.clubs_scored = 0
                    card.ability.extra.guaranteed = true
                    if G.GAME then G.GAME.lucky_one_guaranteed = true end
                    return {
                        message = 'Guaranteed Next!',
                        colour = G.C.GREEN,
                        card = card
                    }
                else
                    return {
                        message = 'Club ' .. card.ability.extra.clubs_scored .. '/5',
                        colour = G.C.CLUBS,
                        card = card
                    }
                end
            end
        end

        if context.individual and context.other_card and context.other_card.lucky_trigger and not context.blueprint then
            card.ability.extra.xmult = (card.ability.extra.xmult or 1.5) + (card.ability.extra.xmult_gain or 0.1)
            return {
                extra = { focus = card, message = '+X' .. (card.ability.extra.xmult_gain or 0.1) .. ' Mult!', colour = G.C.MULT },
                card = card
            }
        end

        if context.joker_main then
            return {
                Xmult = card.ability.extra.xmult or 1.5
            }
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.clubs_scored = 0
            card.ability.extra.guaranteed = false
            if G.GAME then G.GAME.lucky_one_guaranteed = false end
        end
    end
}

SMODS.Joker {
    key = 'miner_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Miner',
        text = {
            "Scored {C:diamonds}Diamonds{} dig {C:attention}+#1#m{} deeper {C:inactive}(Max 1000m, Current: #2#m){}:",
            "{C:inactive}<200m:{} {C:chips}+50{} Chips | {C:inactive}200m+:{} {C:money}+$3{} | {C:inactive}400m+:{} {X:mult,C:white}X1.5{} Mult",
            "{C:inactive}600m+:{} {X:mult,C:white}X2{} Mult & Retrigger | {C:inactive}800m+:{} {X:mult,C:white}X2.5{} Mult & {C:spectral}Spectral{}",
            "{C:attention}1000m (Max):{} Triggers {C:attention}ALL{} effects simultaneously!"
        },
        unlock = {
            "Play a {C:attention}Flush{} of all 4 suits",
            "{C:inactive}(Hearts, Spades, Clubs, Diamonds){}",
            "in a single run"
        }
    },
    config = { extra = { depth = 0, depth_per_card = 2, max_depth = 1000 } },
    rarity = 3,
    pos = { x = 0, y = 4 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local d = ex.depth or 0
        return { vars = { ex.depth_per_card or 2, d } }
    end,
    check_for_unlock = check_all_suits_flushed_unlock,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') and (card.ability.extra.depth or 0) >= 600 then
                return {
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.individual and context.cardarea == G.play then
            if context.other_card:is_suit('Diamonds') then
                if not context.blueprint and not context.repetition then
                    card.ability.extra.depth = math.min(1000, (card.ability.extra.depth or 0) + (card.ability.extra.depth_per_card or 2))
                end
                local d = card.ability.extra.depth or 0
                if d >= 1000 then
                    return {
                        chips = 100,
                        dollars = 5,
                        x_mult = 3,
                        card = card
                    }
                elseif d >= 800 then
                    return {
                        x_mult = 2.5,
                        card = card
                    }
                elseif d >= 600 then
                    return {
                        x_mult = 2.0,
                        card = card
                    }
                elseif d >= 400 then
                    return {
                        x_mult = 1.5,
                        card = card
                    }
                elseif d >= 200 then
                    return {
                        dollars = 3,
                        card = card
                    }
                else
                    return {
                        chips = 50,
                        card = card
                    }
                end
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if (card.ability.extra.depth or 0) >= 800 then
                if #G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = (G.GAME.consumeable_buffer or 0) + 1
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            local sc = SMODS.add_card { set = 'Spectral', key_append = 'miner_core' }
                            G.GAME.consumeable_buffer = 0
                            if sc then sc:juice_up(0.6, 0.6) end
                            return true
                        end
                    }))
                    return {
                        message = 'Core Gem Extracted!',
                        colour = G.C.SECONDARY_SET.Spectral
                    }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'joke_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Joke Joker?',
        text = {
            "Does nothing... or does it?"
        },
        unlock = {
            "Redeem the {C:attention}Blank Voucher{}",
            "a total of {C:attention}2 times{}"
        }
    },
    config = { extra = {} },
    rarity = 3,
    pos = { x = 1, y = 4 },
    cost = 8,
    blueprint_compat = false,
    check_for_unlock = function(self, args)
        local count = (G.PROFILES and G.SETTINGS and G.SETTINGS.profile and G.PROFILES[G.SETTINGS.profile] and G.PROFILES[G.SETTINGS.profile].blank_vouchers_bought) or 0
        if count >= 2 then
            return true
        end
    end,
    calculate = function(self, card, context)
        if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_blank'] then
            G.GAME.used_vouchers['v_blank'] = nil
            G.GAME.used_vouchers['v_antimatter'] = true
            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
            return {
                message = 'Antimatter!',
                colour = G.C.SECONDARY_SET.Voucher
            }
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if G.GAME and G.GAME.used_vouchers and G.GAME.used_vouchers['v_blank'] then
            G.GAME.used_vouchers['v_blank'] = nil
            G.GAME.used_vouchers['v_antimatter'] = true
            G.jokers.config.card_limit = G.jokers.config.card_limit + 1
        end
    end
}

SMODS.Joker {
    key = 'perfectionism_joker',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Perfectionism',
        text = {
            "Defeating Big or Boss Blind adds {C:dark_edition}Polychrome{}",
            "to a random Joker {C:inactive}({C:green}#1# in #2#{C:inactive} chance for Negative){}"
        },
        unlock = {
            "Have {C:attention}5 Jokers{} with an",
            "{C:dark_edition}Edition{} at the same time"
        }
    },
    config = { extra = { odds = 5 } },
    rarity = 3,
    pos = { x = 2, y = 4 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, (card and card.ability and card.ability.extra and card.ability.extra.odds) or 5, 'perfectionism_neg')
        return { vars = { num, den } }
    end,
    check_for_unlock = function(self, args)
        if G.jokers and G.jokers.cards then
            local count = 0
            for _, j in ipairs(G.jokers.cards) do
                if j.edition then
                    count = count + 1
                end
            end
            if count >= 5 then
                return true
            end
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and not context.individual and not context.repetition then
            local is_big_or_boss = false
            if G.GAME and G.GAME.blind then
                if G.GAME.blind.boss or G.GAME.blind.name == 'Big Blind' or G.GAME.blind.key == 'b_big' or (G.GAME.blind.get_type and G.GAME.blind:get_type() == 'Big') then
                    is_big_or_boss = true
                end
            end

            if is_big_or_boss then
                local candidates = {}
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        local is_self = (j == card) or (context.blueprint_card and j == context.blueprint_card)
                        if not is_self and not (j.edition and j.edition.negative) then
                            table.insert(candidates, j)
                        end
                    end
                end

                if #candidates > 0 then
                    local uneditioned = {}
                    for _, j in ipairs(candidates) do
                        if not j.edition then
                            table.insert(uneditioned, j)
                        end
                    end

                    local target = nil
                    if #uneditioned > 0 then
                        target = pseudorandom_element(uneditioned, 'perfectionism_target')
                    else
                        target = pseudorandom_element(candidates, 'perfectionism_target')
                    end

                    if target then
                        local chosen_edition = 'e_polychrome'
                        local is_neg = SMODS.pseudorandom_probability(card, 'perfectionism_neg', 1, card.ability.extra.odds or 5)
                        if is_neg then
                            chosen_edition = 'e_negative'
                        end

                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:set_edition(chosen_edition, true)
                                target:juice_up(0.5, 0.5)
                                return true
                            end
                        }))

                        local chosen_msg = is_neg and "Negative!" or pseudorandom_element({"Perfected!", "Refined!"}, 'perfectionism_msg')

                        return {
                            message = chosen_msg,
                            colour = G.C.DARK_EDITION
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'reaper_joker',
    atlas = 'reality_warp_jokers',
    pos = { x = 3, y = 4 },
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    config = { extra = { used_this_round = false } },
    loc_txt = {
        name = 'Parca',
        text = {
            "Sever the thread of fate during round play:",
            "Sacrifices {C:attention}1 Hand{} to instantly cut",
            "{C:attention}30%{} off the Blind's remaining requirement",
            "{C:inactive}(Usable once per round, currently {C:attention}#1#{C:inactive}){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local status = ex.used_this_round and "Used" or "Ready"
        return { vars = { status } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            card.ability.extra.used_this_round = false
        end

        if context.before and not context.blueprint and not card.ability.extra.used_this_round then
            if G.GAME and G.GAME.blind and G.GAME.blind.chips and G.GAME.current_round.hands_left > 1 then
                card.ability.extra.used_this_round = true
                local cut = math.floor(G.GAME.blind.chips * 0.30)
                G.GAME.blind.chips = math.max(1, G.GAME.blind.chips - cut)
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                ease_hands_played(-1)
                play_sound('slice1')

                return {
                    message = 'Fate Severed! -30% Blind',
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'infostealer_joker',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Infostealer Joker',
        text = {
            "{C:eternal}Always Eternal{}.",
            "Costs {C:money}$#2#{} upon leaving shop to gain {X:mult,C:white}+X#3#{} Mult.",
            "If unable to pay, loses {X:mult,C:white}-X#3#{} Mult",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{} Mult){}"
        }
    },
    config = { extra = { xmult = 1.0, cost = 10, xmult_change = 0.5 } },
    rarity = 3,
    pos = { x = 4, y = 4 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local xmult = (card and card.ability and card.ability.extra and card.ability.extra.xmult) or 1.0
        local cost = (card and card.ability and card.ability.extra and card.ability.extra.cost) or 10
        local change = (card and card.ability and card.ability.extra and card.ability.extra.xmult_change) or 0.5
        return { vars = { xmult, cost, change } }
    end,
    add_to_deck = function(self, card, from_debuff)
        card:set_eternal(true)
        if card.ability then card.ability.eternal = true end
    end,
    calculate = function(self, card, context)
        if context.ending_shop and not context.blueprint then
            card.ability.extra = card.ability.extra or {}
            local cost = card.ability.extra.cost or 10
            local change = card.ability.extra.xmult_change or 0.5
            local current_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0

            if current_dollars >= cost then
                ease_dollars(-cost)
                card.ability.extra.xmult = (card.ability.extra.xmult or 1.0) + change
                return {
                    message = '+X' .. change .. ' Mult',
                    colour = G.C.XMULT
                }
            else
                card.ability.extra.xmult = math.max(1.0, (card.ability.extra.xmult or 1.0) - change)
                return {
                    message = '-X' .. change .. ' Mult',
                    colour = G.C.RED
                }
            end
        end

        if context.joker_main and card.ability.extra and card.ability.extra.xmult and card.ability.extra.xmult > 1 then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'oversaturated_joker',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Oversaturated',
        text = {
            "If played hand contains only {C:attention}1 card{},",
            "adds a missing {C:gold}Seal{}, then {C:dark_edition}Edition{},",
            "then {C:enhanced}Enhancement{} on each trigger or retrigger.",
            "{C:inactive}(Stops once all 3 traits are applied){}"
        }
    },
    config = { extra = {} },
    rarity = 3,
    pos = { x = 5, y = 4 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            local play_count = (context.full_hand and #context.full_hand) or (context.scoring_hand and #context.scoring_hand) or (G.play and G.play.cards and #G.play.cards) or 0
            if play_count == 1 then
                local pcard = context.other_card
                local has_seal = (pcard.seal ~= nil and pcard.seal ~= false)
                local has_edition = (pcard.edition ~= nil and pcard.edition ~= false)
                local has_enh = (pcard.config and pcard.config.center and pcard.config.center ~= G.P_CENTERS.c_base) or (pcard.ability and pcard.ability.effect and pcard.ability.effect ~= 'Base')

                if not has_seal then
                    local seals = { 'Gold', 'Blue', 'Red', 'Purple' }
                    if G.P_SEALS and G.P_SEALS['reality_warp_dark_green'] then table.insert(seals, 'reality_warp_dark_green') end
                    if G.P_SEALS and G.P_SEALS['reality_warp_silver'] then table.insert(seals, 'reality_warp_silver') end
                    if G.P_SEALS and G.P_SEALS['reality_warp_white'] then table.insert(seals, 'reality_warp_white') end
                    local chosen_seal = pseudorandom_element(seals, pseudoseed('sobresaturado_seal'))
                    pcard:set_seal(chosen_seal, nil, true)
                    pcard.seal = chosen_seal
                    card:juice_up(0.3, 0.3)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            play_sound('gold_seal')
                            pcard:juice_up(0.4, 0.4)
                            return true
                        end
                    }))
                    card_eval_status_text(pcard, 'extra', nil, nil, nil, { message = 'Sealed!', colour = G.C.GOLD })
                elseif not has_edition then
                    local eds = { { foil = true }, { holo = true }, { polychrome = true } }
                    local chosen_ed = pseudorandom_element(eds, pseudoseed('sobresaturado_ed'))
                    pcard:set_edition(chosen_ed, true)
                    card:juice_up(0.3, 0.3)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            play_sound('polychrome1')
                            pcard:juice_up(0.4, 0.4)
                            return true
                        end
                    }))
                    card_eval_status_text(pcard, 'extra', nil, nil, nil, { message = 'Polished!', colour = G.C.DARK_EDITION })
                elseif not has_enh then
                    local enhs = { G.P_CENTERS.m_bonus, G.P_CENTERS.m_mult, G.P_CENTERS.m_wild, G.P_CENTERS.m_glass, G.P_CENTERS.m_steel, G.P_CENTERS.m_stone, G.P_CENTERS.m_gold, G.P_CENTERS.m_lucky }
                    local chosen_enh = pseudorandom_element(enhs, pseudoseed('sobresaturado_enh'))
                    pcard:set_ability(chosen_enh)
                    card:juice_up(0.3, 0.3)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            play_sound('tarot1')
                            pcard:juice_up(0.4, 0.4)
                            return true
                        end
                    }))
                    card_eval_status_text(pcard, 'extra', nil, nil, nil, { message = 'Enhanced!', colour = G.C.SECONDARY_SET.Enhanced })
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'radiation',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Radiation',
        text = {
            "Gives {X:mult,C:white}X#1#{} Mult.",
            "At end of round, {C:green}#2# in #3#{} chance",
            "per hand played to {C:red}debuff{} a random Joker"
        }
    },
    config = { extra = { xmult = 3.0, odds = 5 } },
    rarity = 3,
    pos = { x = 0, y = 5 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local num, den = SMODS.get_probability_vars(card, 1, ex.odds or 5, 'radiation_debuff')
        return { vars = { ex.xmult or 3.0, num, den } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3.0,
                card = card
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local hands_played = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_played) or 1
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
            if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
                for i = 1, hands_played do
                    if SMODS.pseudorandom_probability(card, 'radiation_debuff', 1, odds) then
                        local candidates = {}
                        for _, j in ipairs(G.jokers.cards) do
                            if not j.debuff then
                                table.insert(candidates, j)
                            end
                        end
                        local target = (#candidates > 0) and pseudorandom_element(candidates, pseudoseed('radiation_target')) or pseudorandom_element(G.jokers.cards, pseudoseed('radiation_target_all'))
                        if target then
                            target:set_debuff(true)
                            target:juice_up(0.5, 0.5)
                            card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Irradiated!', colour = G.C.RED })
                        end
                    end
                end
            end
        end
    end
}


SMODS.Joker {
    key = 'orchestra_director',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Orchestra Director',
        text = {
            "{C:green}#1# in #2#{} chance a random Joker in",
            "the shop appears for {C:money}free{}",
            "{C:inactive}(Each shop visit rolls once){}"
        },
        unlock = {
            "Own {C:attention}5 Jokers{} at the same time"
        }
    },
    config = { extra = { odds = 4 } },
    rarity = 2,
    pos = { x = 1, y = 9 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or 4
        local num, den = SMODS.get_probability_vars(card, 1, odds, 'orchestra_director')
        return { vars = { num, den } }
    end,
    check_for_unlock = function(self, args)
        local n = G.jokers and G.jokers.cards and #G.jokers.cards or 0
        return n >= 5
    end,
    calculate = function(self, card, context)
        if (context.starting_shop or context.open_shop) and not context.blueprint then
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 4
            if SMODS.pseudorandom_probability(card, 'orchestra_director', 1, odds) then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        if G.shop_jokers and G.shop_jokers.cards and #G.shop_jokers.cards > 0 then
                            local free_card = pseudorandom_element(G.shop_jokers.cards, pseudoseed('director_free'))
                            if free_card then
                                free_card.cost = 0
                                free_card:juice_up(0.5, 0.5)
                                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Free Joker!', colour = G.C.MONEY })
                            end
                        end
                        return true
                    end
                }))
            end
        end
    end
}

local function get_weather_hud_config(w)
    if w == 'Storm' then
        return "Storm (+0.5X / -1 Hand)", HEX('c0392b')
    elseif w == 'Sun' then
        return "Sun (-0.5X / +1 Hand)", HEX('f39c12')
    elseif w == 'Fog' then
        return "Fog (Cards Face Down)", HEX('7f8c8d')
    elseif w == 'Hail' then
        return "Hail (Debuff)", HEX('2980b9')
    else
        return "Clear (X3 Mult)", HEX('27ae60')
    end
end

local function create_meteorologist_hud(cur_weather)
    if not (G.consumeables and G.consumeables.T) then return end
    if G.HUD_meteorologist and not G.HUD_meteorologist.REMOVED then
        G.HUD_meteorologist:remove()
        G.HUD_meteorologist = nil
    end

    local text_str, col = get_weather_hud_config(cur_weather)
    local t = {
        n = G.UIT.ROOT,
        config = { align = "cm", padding = 0, colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    id = 'meteorologist_weather_hud',
                    align = "cm",
                    minh = 0.38,
                    minw = 1.45,
                    padding = 0.05,
                    r = 0.1,
                    colour = col,
                    shadow = true
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm", maxw = 2.4 },
                        nodes = {
                            { n = G.UIT.T, config = { text = text_str, scale = 0.30, colour = G.C.UI.TEXT_LIGHT, shadow = true } }
                        }
                    }
                }
            }
        }
    }

    G.HUD_meteorologist = UIBox{
        definition = t,
        config = {
            align = "bm",
            offset = { x = 0, y = 0.65 },
            major = G.consumeables,
            bond = 'Weak'
        }
    }
    G.HUD_meteorologist._last_weather = cur_weather
end

if Game and Game.update then
    local orig_game_update_met = Game.update
    function Game:update(dt)
        orig_game_update_met(self, dt)
        if G.STAGE == G.STAGES.RUN and G.consumeables then
            local met_jokers = (find_joker and find_joker('meteorologist')) or (SMODS and SMODS.find_card and SMODS.find_card('j_reality_warp_meteorologist')) or {}
            if #met_jokers > 0 then
                local cur_w = (met_jokers[1].ability and met_jokers[1].ability.extra and met_jokers[1].ability.extra.weather) or ''
                if not G.HUD_meteorologist or G.HUD_meteorologist.REMOVED or G.HUD_meteorologist._last_weather ~= cur_w then
                    create_meteorologist_hud(cur_w)
                end
            elseif G.HUD_meteorologist then
                G.HUD_meteorologist:remove()
                G.HUD_meteorologist = nil
            end
        elseif G.HUD_meteorologist then
            G.HUD_meteorologist:remove()
            G.HUD_meteorologist = nil
        end
    end
end

SMODS.Joker {
    key = 'meteorologist',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Meteorologist',
        text = {
            "{X:mult,C:white}X#1#{} Mult. Each blind starts with a random {C:attention}Weather{}:",
            "{C:attention}Storm{} (+0.5X Mult, -1 hand), {C:attention}Sun{} (-0.5X Mult, +1 hand),",
            "{C:attention}Fog{} (draws card face down), {C:attention}Hail{} (debuffs random card).",
            "{C:inactive}(Current: {C:attention}#2#{C:inactive}){}"
        },
        unlock = {
            "Defeat a blind under",
            "each of the 4 weather effects"
        }
    },
    config = { extra = { xmult = 3, weather = '', weathers_seen = {} } },
    rarity = 3,
    pos = { x = 2, y = 9 },
    cost = 8,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        local w = (ex.weather and ex.weather ~= '' and ex.weather) or 'Clear'
        return { vars = { ex.xmult or 3, w } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.reality_warp_weathers_seen then
            local count = 0
            for _ in pairs(G.GAME.reality_warp_weathers_seen) do count = count + 1 end
            return count >= 4
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local weathers = { 'Storm', 'Sun', 'Fog', 'Hail' }
            local w = pseudorandom_element(weathers, pseudoseed('meteorologist_'..tostring(G.GAME.round or 0)))
            card.ability.extra.weather = w
            if create_meteorologist_hud then create_meteorologist_hud(w) end
            G.GAME.reality_warp_weathers_seen = G.GAME.reality_warp_weathers_seen or {}
            G.GAME.reality_warp_weathers_seen[w] = true

            if w == 'Storm' then
                ease_hands_played(-1)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Storm! -1 Hand', colour = G.C.RED })
            elseif w == 'Sun' then
                ease_hands_played(1)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Sun! +1 Hand', colour = G.C.GOLD })
            elseif w == 'Fog' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.8,
                    func = function()
                        if G.hand and G.hand.cards and #G.hand.cards > 0 then
                            local target = pseudorandom_element(G.hand.cards, pseudoseed('fog_hide'))
                            if target then
                                target.facing = 'back'
                                target.sprite_facing = 'back'
                                target:juice_up(0.3, 0.3)
                            end
                        end
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Fog! Cards Hidden', colour = G.C.GREY })
            elseif w == 'Hail' then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.8,
                    func = function()
                        if G.hand and G.hand.cards and #G.hand.cards > 0 then
                            local target = pseudorandom_element(G.hand.cards, pseudoseed('hail_debuff'))
                            if target then
                                target.debuff = true
                                target:juice_up(0.3, 0.3)
                            end
                        end
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Hail! Debuff!', colour = G.C.RED })
            end
        end

        if context.joker_main and not context.blueprint then
            local w = card.ability.extra.weather or ''
            local base_xmult = 3
            if w == 'Storm' then
                return { x_mult = base_xmult + 0.5, card = card }
            elseif w == 'Sun' then
                return { x_mult = base_xmult - 0.5, card = card }
            else
                return { x_mult = base_xmult, card = card }
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.weather = ''
            if create_meteorologist_hud then create_meteorologist_hud('') end
        end
    end
}

SMODS.Joker {
    key = 'mad_clockmaker',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Mad Clockmaker',
        text = {
            "Gives {C:mult}+#1#{} Mult for each",
            "remaining {C:attention}discard{}",
            "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { mult_per_discard = 14 } },
    rarity = 1,
    pos = { x = 3, y = 9 },
    cost = 5,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local rate = (card and card.ability and card.ability.extra and card.ability.extra.mult_per_discard) or 14
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        return { vars = { rate, discards * rate } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local discards_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
            if discards_left > 0 then
                local mult_val = discards_left * ((card.ability and card.ability.extra and card.ability.extra.mult_per_discard) or 14)
                return {
                    mult = mult_val,
                    card = card,
                    message = '+' .. mult_val .. ' Mult'
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'catalyst',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Catalyst',
        text = {
            "{C:green}#1# in #2#{} chance to retrigger a",
            "random {C:attention}Joker{} and grant",
            "{X:mult,C:white}X#3#{} Mult if activated",
            "{C:inactive}(Retriggered: #4#){}"
        },
        unlock = {
            "Have a Joker with {C:mult}X3{} or",
            "higher base x_mult"
        }
    },
    config = { extra = { odds = 3, x_mult = 5, target_name = 'None' } },
    rarity = 3,
    pos = { x = 4, y = 9 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local num, den = SMODS.get_probability_vars(card, 1, ex.odds or 3, 'catalyst')
        return { vars = { num, den, ex.x_mult or 5, ex.target_name or 'None' } }
    end,
    check_for_unlock = function(self, args)
        if G.jokers and G.jokers.cards then
            for _, jk in ipairs(G.jokers.cards) do
                local xm = jk.ability and jk.ability.x_mult or 0
                if xm >= 3 then return true end
            end
        end
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 3
            if SMODS.pseudorandom_probability(card, 'catalyst', 1, odds) then
                local others = {}
                if G.jokers and G.jokers.cards then
                    for _, jk in ipairs(G.jokers.cards) do
                        if jk ~= card and is_joker_copiable(jk) then others[#others + 1] = jk end
                    end
                end
                local xm = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 5
                if #others > 0 then
                    local target = pseudorandom_element(others, pseudoseed('catalyst_target'))
                    card.ability.extra.target_name = target.config and target.config.center and target.config.center.name or 'Joker'
                    target:juice_up(0.5, 0.5)
                    local ret = SMODS.blueprint_effect(card, target, context)
                    if ret and type(ret) == 'table' then
                        local merged = {}
                        for k, v in pairs(ret) do merged[k] = v end
                        local base_xm = merged.x_mult or merged.Xmult or 1
                        merged.x_mult = base_xm * xm
                        merged.card = card
                        merged.message = 'Catalyzed! X' .. xm
                        return merged
                    end
                    return {
                        x_mult = xm,
                        card = card,
                        message = 'Catalyzed! X' .. xm
                    }
                else
                    card.ability.extra.target_name = 'None'
                end
            end
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.target_name = 'None'
        end
    end
}

SMODS.Joker {
    key = 'graffiti_artist',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Graffiti Artist',
        text = {
            "Each hand played, a random deck card",
            "gets {C:attention}Mult{} or {C:attention}Wild{} enhancement.",
            "Gives {X:mult,C:white}X#1#{} Mult each hand"
        }
    },
    config = { extra = { x_mult = 1.5 } },
    rarity = 2,
    pos = { x = 5, y = 9 },
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { (card and card.ability and card.ability.extra and card.ability.extra.x_mult) or 1.5 } }
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local candidates = {}
            if G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    local cur = c.config and c.config.center and c.config.center.key
                    if not cur or cur == '' or cur == 'c_base' then candidates[#candidates + 1] = c end
                end
            end
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('graffiti_artist_'..tostring(G.GAME.round or 0)))
                local enhs = { G.P_CENTERS.m_mult, G.P_CENTERS.m_wild }
                local enh = pseudorandom_element(enhs, pseudoseed('graffiti_artist_enh'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after', delay = 0.2,
                    func = function()
                        if G.P_CENTERS[enh and enh.key or ''] then
                            target:set_ability(enh)
                        else
                            target:set_ability(enhs[1])
                        end
                        target:juice_up(0.4, 0.4)
                        return true
                    end
                }))
            end
        end

        if context.cardarea == G.jokers and context.joker_main then
            return {
                x_mult = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 1.5,
                card = card
            }
        end
    end
}

SMODS.Joker {
    key = 'hypnotist',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Hypnotist',
        text = {
            "Boss Blind has {C:green}#1# in #2#{} chance to",
            "be {C:attention}hypnotized{}: its debuff effect is",
            "{C:attention}completely disabled{}"
        },
        unlock = {
            "Defeat {C:attention}3 different{}",
            "Boss Blind types"
        }
    },
    config = { extra = { odds = 3, hypnotized = false, bosses_defeated = {}, boss_count = 0 } },
    rarity = 2,
    pos = { x = 6, y = 9 },
    cost = 6,
    blueprint_compat = false,
    loc_vars = function(self, info_queue, card)
        local odds = (card and card.ability and card.ability.extra and card.ability.extra.odds) or 3
        local num, den = SMODS.get_probability_vars(card, 1, odds, 'hypnotist')
        return { vars = { num, den } }
    end,
    check_for_unlock = function(self, args)
        if G.GAME and G.GAME.reality_warp_bosses_slain_types then
            local cnt = 0
            for _ in pairs(G.GAME.reality_warp_bosses_slain_types) do cnt = cnt + 1 end
            if cnt >= 3 then return true end
        end
        if G.GAME and (G.GAME.reality_warp_bosses_slain or 0) >= 3 then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.hypnotized = false
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 3
                if SMODS.pseudorandom_probability(card, 'hypnotist', 1, odds) then
                    card.ability.extra.hypnotized = true
                    if G.GAME.blind.disable then
                        G.GAME.blind:disable()
                    end
                    for _, c in ipairs(G.playing_cards or {}) do
                        c.debuff = false
                    end
                    return { message = 'Hypnotized! Disabled', colour = G.C.PURPLE, card = card }
                end
            end
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                local key = G.GAME.blind.key or ''
                if key ~= '' and not card.ability.extra.bosses_defeated[key] then
                    card.ability.extra.bosses_defeated[key] = true
                    card.ability.extra.boss_count = (card.ability.extra.boss_count or 0) + 1
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'potion_brewer',
    atlas = 'reality_warp_jokers',
    pos = { x = 0, y = 10 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    config = { extra = { chips_per_use = 20, chips = 0 } },
    loc_txt = {
        name = 'Potion Brewer',
        text = {
            "Using any consumable permanently",
            "grants {C:chips}+#1#{} Chips",
            "{C:inactive}(Currently {C:chips}+#2#{} Chips){}",
            "After defeating each {C:attention}Boss Blind{},",
            "automatically brews a random",
            "{C:attention}Potion{} into open slot."
        }
    },
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.chips_per_use or 20, ex.chips or 0 } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local ex = card.ability.extra
            ex.chips = (ex.chips or 0) + (ex.chips_per_use or 20)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = '+' .. (ex.chips_per_use or 20) .. ' Chips!',
                colour = G.C.CHIPS
            })
        end

        if context.joker_main and (card.ability.extra.chips or 0) > 0 then
            return {
                chips = card.ability.extra.chips,
                card = card
            }
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                    local new_potion = (create_potion_card_safe and create_potion_card_safe(G.consumeables, 'brewer'))
                        or SMODS.add_card { set = 'Spectral', key_append = 'brewer_pot' }
                    play_sound('tarot1')
                    return {
                        message = 'Brewed Potion!',
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
}

SMODS.Atlas {
    key = "insect_stickers",
    path = "insect_stickers.png",
    px = 71,
    py = 95
}

local function draw_insect_sticker_bottom_right(self, card, layer)
    local sprite = G.shared_stickers[self.key]
    if sprite then
        sprite.role.draw_major = card
        sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, nil, nil, 0, 0.48 * card.T.h)
        sprite:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, nil, nil, 0, 0.48 * card.T.h)
    end
end

SMODS.Sticker {
    key = "insect_beetle",
    atlas = "insect_stickers",
    pos = { x = 0, y = 0 },
    badge_colour = HEX('8b5a2b'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    draw = draw_insect_sticker_bottom_right,
    loc_txt = {
        name = 'Beetle',
        label = 'Beetle',
        text = {
            "{C:chips}+40{} Chips when scored"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            return { chips = 40, card = card }
        end
    end
}

SMODS.Sticker {
    key = "insect_butterfly",
    atlas = "insect_stickers",
    pos = { x = 1, y = 0 },
    badge_colour = HEX('9b59b6'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    draw = draw_insect_sticker_bottom_right,
    loc_txt = {
        name = 'Butterfly',
        label = 'Butterfly',
        text = {
            "{C:attention}Retrigger{} this card",
            "{C:attention}1{} additional time"
        }
    },
    calculate = function(self, card, context)
        if context.repetition and (not context.cardarea or context.cardarea == G.play) then
            return { repetitions = 1, message = localize('k_again_ex'), card = card }
        end
    end
}

SMODS.Sticker {
    key = "insect_firefly",
    atlas = "insect_stickers",
    pos = { x = 2, y = 0 },
    badge_colour = HEX('e67e22'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    draw = draw_insect_sticker_bottom_right,
    loc_txt = {
        name = 'Firefly',
        label = 'Firefly',
        text = {
            "{C:mult}+10{} Mult when scored"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            return { mult = 10, card = card }
        end
    end
}

SMODS.Sticker {
    key = "insect_spider",
    atlas = "insect_stickers",
    pos = { x = 3, y = 0 },
    badge_colour = HEX('34495e'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    draw = draw_insect_sticker_bottom_right,
    loc_txt = {
        name = 'Spider',
        label = 'Spider',
        text = {
            "{C:chips}+15{} Chips for each scored card",
            "sharing this card's suit"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local suit = card.base and card.base.suit
            local bonus = 0
            if context.scoring_hand then
                for _, sc in ipairs(context.scoring_hand) do
                    if sc ~= card and sc.base and sc.base.suit == suit then
                        bonus = bonus + 15
                    end
                end
            end
            if bonus > 0 then return { chips = bonus, card = card } end
        end
    end
}

SMODS.Joker {
    key = 'entomologist',
    atlas = 'reality_warp_jokers',
    unlocked = false,
    loc_txt = {
        name = 'Entomologist',
        text = {
            "Each hand played, a scored card gets",
            "a random {C:attention}Insect Sticker{}:",
            "{C:attention}Beetle{}: {C:chips}+40{} Chips | {C:attention}Firefly{}: {C:mult}+10{} Mult",
            "{C:attention}Butterfly{}: {C:attention}retrigger 1x{} | {C:attention}Spider{}: {C:chips}+15{} Chips"
        },
        unlock = {
            "Defeat {C:attention}10 blinds{}",
            "in a single run"
        }
    },
    config = { extra = { blinds_beaten = 0 } },
    rarity = 3,
    pos = { x = 1, y = 10 },
    cost = 9,
    blueprint_compat = false,
    check_for_unlock = function(self, args)
        if (args and args.type == 'entomologist') or (G.GAME and (G.GAME.reality_warp_blinds_defeated or 0) >= 10) then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.blinds_beaten = (card.ability.extra.blinds_beaten or 0) + 1
        end

        if context.after and not context.blueprint then
            local insects = { 'beetle', 'butterfly', 'firefly', 'spider' }
            local insect = pseudorandom_element(insects, pseudoseed('entomologist_'..tostring(G.GAME.round or 0)))
            local candidates = (context.scoring_hand and #context.scoring_hand > 0 and context.scoring_hand) or (G.hand and G.hand.cards and #G.hand.cards > 0 and G.hand.cards) or G.playing_cards or {}
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('entomologist_card'))
                for _, ins in ipairs({'insect_beetle', 'insect_butterfly', 'insect_firefly', 'insect_spider'}) do
                    if target.ability and target.ability[ins] and SMODS.Stickers and SMODS.Stickers[ins] then
                        SMODS.Stickers[ins]:apply(target, false)
                    end
                end
                local sticker_key = 'insect_' .. insect
                if SMODS.Stickers and SMODS.Stickers[sticker_key] then
                    SMODS.Stickers[sticker_key]:apply(target, true)
                end
                target.reality_warp_insect = insect
                target:juice_up(0.4, 0.4)
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = insect:gsub("^%l", string.upper)..'!', colour = G.C.PURPLE })
            end
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            local insect = c and c.reality_warp_insect
            local has_sticker = c and c.ability and (c.ability.insect_beetle or c.ability.insect_butterfly or c.ability.insect_firefly or c.ability.insect_spider)
            if not has_sticker then
                if insect == 'beetle' then
                    return { chips = 40, card = card }
                elseif insect == 'firefly' then
                    return { mult = 10, card = card }
                elseif insect == 'spider' then
                    local suit = c.base and c.base.suit
                    local bonus = 0
                    if context.scoring_hand then
                        for _, sc in ipairs(context.scoring_hand) do
                            if sc ~= c and sc.base and sc.base.suit == suit then
                                bonus = bonus + 15
                            end
                        end
                    end
                    if bonus > 0 then return { chips = bonus, card = card } end
                end
            end
        end

        if context.repetition and context.cardarea == G.play and not context.blueprint then
            local c = context.other_card
            if c and c.reality_warp_insect == 'butterfly' and not (c.ability and c.ability.insect_butterfly) then
                return { repetitions = 1, card = card }
            end
        end
    end
}

SMODS.Joker {
    key = 'ethernet',
    atlas = 'reality_warp_jokers',
    loc_txt = {
        name = 'Ethernet Cable',
        text = {
            "Click {C:attention}Wire{} once per round during hand selection to",
            "solve a network puzzle: connect all wire pairs across the grid.",
            "Fully routing the board grants {C:mult}+#1#{} Mult permanently!",
            "{C:inactive}(Currently: {C:mult}+#2#{} Mult){}"
        }
    },
    config = { extra = { mult_gain = 10, current_mult = 0, played_this_round = false } },
    rarity = 3,
    pos = { x = 4, y = 10 },
    cost = 8,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.mult_gain or 10, ex.current_mult or 0 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and (card.ability.extra.current_mult or 0) > 0 then
            return {
                mult_mod = card.ability.extra.current_mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.current_mult } }
            }
        end
        if (context.end_of_round or context.skip_blind or context.setting_blind) and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.played_this_round = false
            card.ability.extra.saved_puzzle = nil
        end
    end
}

local ETHERNET_PAIR_COLORS = {
    { 0.18, 0.65, 0.98, 1 }, -- 1: Blue / Cyan
    { 0.98, 0.55, 0.12, 1 }, -- 2: Amber / Orange
    { 0.22, 0.85, 0.42, 1 }, -- 3: Emerald Green
    { 0.88, 0.25, 0.82, 1 }, -- 4: Magenta / Pink
    { 0.95, 0.88, 0.18, 1 }, -- 5: Electric Yellow
    { 0.55, 0.40, 0.98, 1 }, -- 6: Royal Violet
    { 0.92, 0.22, 0.22, 1 }, -- 7: Bright Crimson
    { 0.12, 0.82, 0.80, 1 }, -- 8: Turquoise / Aqua
    { 0.70, 0.92, 0.20, 1 }, -- 9: Lime Chartreuse
    { 0.98, 0.48, 0.60, 1 }, -- 10: Rose Coral
}

local function generate_ethernet_puzzle(card, forced_size, forced_pairs)
    local S = forced_size or 5
    if S < 5 then S = 5 end
    if S > 8 then S = 8 end

    local min_p = 4
    local max_limit = math.min(10, math.floor((S * S) / 2))
    local max_p = math.max(4, max_limit)
    local P = forced_pairs or math.random(min_p, math.min(max_p, S == 5 and 6 or (S == 6 and 8 or 10)))
    if P < 4 then P = 4 end
    if P > 10 then P = 10 end
    if P > max_limit then P = max_limit end

    local pairs_data = {}
    local grid_endpoints = {}
    local bridges = {}
    local obstacles = {}

    local flip_h = math.random() > 0.5
    local flip_v = math.random() > 0.5
    local transpose = math.random() > 0.5

    local snake = {}
    for r = 1, S do
        local row_cells = {}
        for c = 1, S do
            local pr = r
            local pc = (r % 2 == 1) and c or (S - c + 1)
            if flip_v then pr = S - pr + 1 end
            if flip_h then pc = S - pc + 1 end
            if transpose then
                table.insert(row_cells, { r = pc, c = pr })
            else
                table.insert(row_cells, { r = pr, c = pc })
            end
        end
        for _, cell in ipairs(row_cells) do
            table.insert(snake, cell)
        end
    end

    local total_cells = S * S
    local lengths = {}
    for i = 1, P do lengths[i] = 2 end
    local remaining = total_cells - (P * 2)
    while remaining > 0 do
        local idx = math.random(1, P)
        lengths[idx] = lengths[idx] + 1
        remaining = remaining - 1
    end

    local cell_idx = 1
    for p = 1, P do
        local len = lengths[p]
        local path_cells = {}
        for k = 1, len do
            table.insert(path_cells, snake[cell_idx])
            cell_idx = cell_idx + 1
        end

        local a_pos = path_cells[1]
        local b_pos = path_cells[#path_cells]
        local a_label = "A" .. p
        local b_label = "B" .. p

        grid_endpoints[a_pos.r .. "_" .. a_pos.c] = { pair_id = p, type = 'A', label = a_label }
        grid_endpoints[b_pos.r .. "_" .. b_pos.c] = { pair_id = p, type = 'B', label = b_label }

        table.insert(pairs_data, {
            id = p,
            a = a_pos,
            b = b_pos,
            a_label = a_label,
            b_label = b_label,
            colour = ETHERNET_PAIR_COLORS[((p - 1) % #ETHERNET_PAIR_COLORS) + 1]
        })
    end

    local raw_reward = math.floor(12 + (S - 5) * 4 + (P - 4) * 3)
    local reward = math.min(50, math.max(15, raw_reward))

    local wire_paths = {}
    for _, pr in ipairs(pairs_data) do
        wire_paths[pr.id] = { { r = pr.a.r, c = pr.a.c } }
    end

    return {
        card = card,
        size = S,
        num_pairs = #pairs_data,
        pairs = pairs_data,
        grid_endpoints = grid_endpoints,
        bridges = bridges,
        obstacles = obstacles,
        wire_paths = wire_paths,
        active_pair = 1,
        completed_pairs = {},
        completed = false,
        failed = false,
        reward = reward,
        message = "Connect all " .. #pairs_data .. " cables! 100% of grid cells must be covered."
    }
end

local function ethernet_cell_in_path(state, r, c)
    local occupants = {}
    local is_head_map = {}
    for p_id, path in pairs(state.wire_paths) do
        for idx, node in ipairs(path) do
            if node.r == r and node.c == c then
                table.insert(occupants, p_id)
                if idx == #path then
                    is_head_map[p_id] = true
                end
            end
        end
    end
    return occupants, is_head_map
end

local _opening_ethernet_menu = false
local function open_ethernet_dots_menu()
    if _opening_ethernet_menu then return end
    if not (create_UIBox_generic_options and G.FUNCS and G.FUNCS.overlay_menu and G.ETHERNET_MINIGAME) then return end
    if type(G.OVERLAY_MENU) == 'boolean' then return end

    _opening_ethernet_menu = true
    local state = G.ETHERNET_MINIGAME
    local is_over = state.completed or state.failed
    local S = state.size or 5

    local cell_dim = (S <= 5 and 0.85) or (S == 6 and 0.72) or (S == 7 and 0.62) or (S == 8 and 0.54) or (S == 9 and 0.46) or 0.41
    local font_sz = (S <= 5 and 0.35) or (S == 6 and 0.28) or (S == 7 and 0.24) or (S == 8 and 0.20) or (S == 9 and 0.17) or 0.14

    local grid_rows = {}
    for r = 1, S do
        local col_nodes = {}
        for c = 1, S do
            local key = r .. "_" .. c
            local ep = state.grid_endpoints[key]
            local is_obs = state.obstacles and state.obstacles[key]
            local is_bridge = state.bridges and state.bridges[key]
            local occupants, is_head_map = ethernet_cell_in_path(state, r, c)

            local bg_colour = { 0.13, 0.14, 0.18, 0.95 }
            local border_colour = G.C.UI.BACKGROUND_INACTIVE
            local text_str = "·"
            local text_colour = { 0.35, 0.38, 0.45, 0.5 }
            local is_interactive = not is_over and not is_obs

            if is_obs then
                bg_colour = { 0.22, 0.08, 0.08, 0.95 }
                border_colour = { 0.65, 0.20, 0.20, 0.8 }
                text_str = "✕"
                text_colour = { 0.75, 0.25, 0.25, 0.9 }
            elseif ep then
                local pair = state.pairs[ep.pair_id]
                text_str = ep.label
                text_colour = G.C.WHITE
                if ep.type == 'A' or state.completed_pairs[ep.pair_id] then
                    bg_colour = pair.colour
                    border_colour = G.C.WHITE
                else
                    bg_colour = { 0.18, 0.20, 0.25, 0.95 }
                    border_colour = pair.colour
                    text_colour = pair.colour
                end
            elseif is_bridge then
                if #occupants == 0 then
                    bg_colour = { 0.16, 0.18, 0.24, 0.95 }
                    border_colour = { 0.70, 0.75, 0.85, 0.9 }
                    text_str = "╬"
                    text_colour = { 0.70, 0.75, 0.85, 0.9 }
                elseif #occupants == 1 then
                    local pair = state.pairs[occupants[1]]
                    bg_colour = pair.colour
                    border_colour = G.C.WHITE
                    text_str = "╬"
                    text_colour = G.C.WHITE
                else
                    local p2 = state.pairs[occupants[2]]
                    bg_colour = p2.colour
                    border_colour = G.C.GOLD
                    text_str = "╬"
                    text_colour = G.C.WHITE
                end
            elseif #occupants > 0 then
                local pid = occupants[1]
                local pair = state.pairs[pid]
                bg_colour = pair.colour
                border_colour = is_head_map[pid] and G.C.WHITE or pair.colour
                text_str = is_head_map[pid] and "●" or "■"
                text_colour = G.C.WHITE
            end

            table.insert(col_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.015,
                    minw = cell_dim,
                    minh = cell_dim,
                    r = 0.12,
                    hover = is_interactive,
                    colour = bg_colour,
                    outline = 0.02,
                    outline_colour = border_colour,
                    button = is_interactive and 'ethernet_cell_click' or nil,
                    ref_table = { r = r, c = c, key = key },
                    shadow = true
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = text_str,
                            scale = font_sz,
                            colour = text_colour,
                            shadow = true
                        }
                    }
                }
            })
        end
        table.insert(grid_rows, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.015 },
            nodes = col_nodes
        })
    end

    local selector_rows = {}
    if state.num_pairs > 1 and not is_over then
        local current_row = {}
        for _, p in ipairs(state.pairs) do
            local is_active = (state.active_pair == p.id)
            local is_done = state.completed_pairs[p.id]
            table.insert(current_row, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.04,
                    minw = (state.num_pairs > 5) and 0.95 or 1.15,
                    minh = 0.35,
                    r = 0.1,
                    hover = not is_done,
                    colour = is_done and G.C.UI.BACKGROUND_INACTIVE or (is_active and p.colour or { 0.22, 0.22, 0.28, 0.9 }),
                    outline = is_active and 0.025 or nil,
                    outline_colour = G.C.WHITE,
                    button = not is_done and 'ethernet_select_pair' or nil,
                    ref_table = { pair_id = p.id },
                    shadow = true
                },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = p.a_label .. "-" .. p.b_label .. (is_done and " ✓" or ""),
                            scale = (state.num_pairs > 5) and 0.24 or 0.28,
                            colour = G.C.WHITE,
                            shadow = true
                        }
                    }
                }
            })
            table.insert(current_row, { n = G.UIT.B, config = { w = 0.04, h = 0.1 } })

            if #current_row >= 10 then -- 5 buttons + 5 spacers
                table.insert(selector_rows, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.02 },
                    nodes = current_row
                })
                current_row = {}
            end
        end
        if #current_row > 0 then
            table.insert(selector_rows, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.02 },
                nodes = current_row
            })
        end
    end

    local status_colour = state.completed and G.C.GREEN or (state.failed and G.C.RED or G.C.GOLD)
    local diff_label = tostring(S) .. "x" .. tostring(S)
    local reward_str = "Reward: +" .. tostring(state.reward or 20) .. " Mult"

    local total_cells = S * S
    local covered_cells = 0
    for cr = 1, S do
        for cc = 1, S do
            local occ = ethernet_cell_in_path(state, cr, cc)
            if occ and #occ > 0 then
                covered_cells = covered_cells + 1
            end
        end
    end

    local contents = {
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.04 },
            nodes = {
                { n = G.UIT.T, config = { text = "ETHERNET ROUTER", scale = 0.55, colour = G.C.BLUE, shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.03 },
            nodes = {
                { n = G.UIT.T, config = { text = "Connect all A to B pairs. 100% of grid tiles must be covered!", scale = 0.35, colour = G.C.WHITE, shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.03 },
            nodes = {
                { n = G.UIT.T, config = { text = "Grid: " .. diff_label .. " | Cables: " .. tostring(state.num_pairs) .. " | Coverage: " .. covered_cells .. "/" .. total_cells .. " (100% Needed)", scale = 0.34, colour = G.C.CYAN, shadow = true } },
                { n = G.UIT.B, config = { w = 0.3, h = 0.1 } },
                { n = G.UIT.T, config = { text = reward_str, scale = 0.38, colour = G.C.MULT, shadow = true } }
            }
        },
        {
            n = G.UIT.R, config = { align = "cm", padding = 0.03 },
            nodes = {
                { n = G.UIT.T, config = { text = state.message or "", scale = 0.36, colour = status_colour, shadow = true } }
            }
        }
    }

    if #selector_rows > 0 then
        for _, s_row in ipairs(selector_rows) do
            table.insert(contents, s_row)
        end
    end

    table.insert(contents, {
        n = G.UIT.R, config = { align = "cm", padding = 0.05, colour = G.C.L_BLACK, r = 0.15, outline = 0.03, outline_colour = G.C.BLUE },
        nodes = {
            {
                n = G.UIT.C, config = { align = "cm", padding = 0.02 },
                nodes = grid_rows
            }
        }
    })

    if not is_over then
        table.insert(contents, {
            n = G.UIT.R, config = { align = "cm", padding = 0.05 },
            nodes = {
                {
                    n = G.UIT.C, config = {
                        align = "cm", padding = 0.06, minw = 1.8, minh = 0.42, r = 0.1,
                        hover = true, colour = G.C.ORANGE, button = 'ethernet_reset_wire', shadow = true
                    },
                    nodes = {
                        { n = G.UIT.T, config = { text = "RESET CABLE", scale = 0.30, colour = G.C.WHITE, shadow = true } }
                    }
                },
                { n = G.UIT.B, config = { w = 0.25, h = 0.1 } },
                {
                    n = G.UIT.C, config = {
                        align = "cm", padding = 0.06, minw = 1.8, minh = 0.42, r = 0.1,
                        hover = true, colour = G.C.PURPLE, button = 'ethernet_refresh_panel', shadow = true
                    },
                    nodes = {
                        { n = G.UIT.T, config = { text = "REFRESH PANEL", scale = 0.30, colour = G.C.WHITE, shadow = true } }
                    }
                }
            }
        })
    else
        local win_btn_text = state.completed and ("CONNECTED (+" .. state.reward .. " MULT) - CLOSE") or "FAILED - CLOSE"
        table.insert(contents, {
            n = G.UIT.R, config = { align = "cm", padding = 0.05 },
            nodes = {
                {
                    n = G.UIT.C, config = {
                        align = "cm", padding = 0.08, minw = 3.2, minh = 0.52, r = 0.1,
                        hover = true, colour = state.completed and G.C.GREEN or G.C.RED, button = 'exit_overlay_menu', shadow = true
                    },
                    nodes = {
                        { n = G.UIT.T, config = { text = win_btn_text, scale = 0.35, colour = G.C.WHITE, shadow = true } }
                    }
                }
            }
        })
    end

    local t = create_UIBox_generic_options({
        back_func = 'exit_overlay_menu',
        back_label = is_over and "Exit" or "Cancel",
        contents = contents,
        no_esc = false
    })

    G.NO_MOD_CURSOR_STACK = true
    G.FUNCS.overlay_menu{
        definition = t,
        config = { offset = { x = 0, y = 0 }, no_esc = false }
    }
    G.NO_MOD_CURSOR_STACK = nil
    _opening_ethernet_menu = false
end

local function ethernet_step_to_cell(r, c)
    local state = G.ETHERNET_MINIGAME
    if not state or state.completed or state.failed then return false end

    local key = r .. "_" .. c
    if state.obstacles and state.obstacles[key] then
        play_sound('cancel', 0.9, 0.3)
        return false
    end

    local p = state.active_pair
    if not p then return false end

    local ep = state.grid_endpoints[key]
    if ep and (ep.type == 'A' or ep.type == 'B') and ep.pair_id ~= p then
        if not state.completed_pairs[ep.pair_id] then
            state.active_pair = ep.pair_id
            play_sound('button', 1.0, 0.4)
            return true
        end
        return false
    end

    local pair = state.pairs[p]
    if not pair then return false end

    if r == pair.a.r and c == pair.a.c then
        state.wire_paths[p] = { { r = pair.a.r, c = pair.a.c } }
        state.completed_pairs[p] = false
        play_sound('button', 1.0, 0.3)
        return true
    end

    if state.completed_pairs[p] then return false end

    local path = state.wire_paths[p]
    if not path or #path == 0 then
        state.wire_paths[p] = { { r = pair.a.r, c = pair.a.c } }
        path = state.wire_paths[p]
    end

    local head = path[#path]
    if not head then return false end

    if head.r == r and head.c == c then
        return false
    end

    if #path > 1 and path[#path - 1].r == r and path[#path - 1].c == c then
        table.remove(path)
        play_sound('button', 0.9, 0.3)
        return true
    end

    local dist = math.abs(r - head.r) + math.abs(c - head.c)
    if dist ~= 1 then
        return false
    end

    local occupants = ethernet_cell_in_path(state, r, c)
    local is_bridge = state.bridges and state.bridges[key]

    if is_bridge then
        local already_in = false
        for _, occ_pid in ipairs(occupants) do
            if occ_pid == p then already_in = true break end
        end
        if already_in or #occupants >= 2 then
            play_sound('cancel', 1.0, 0.4)
            return false
        end
    else
        for _, occ_pid in ipairs(occupants) do
            if occ_pid ~= p then
                play_sound('cancel', 1.0, 0.4)
                return false
            end
        end
        for _, node in ipairs(path) do
            if node.r == r and node.c == c then
                return false
            end
        end
    end

    table.insert(path, { r = r, c = c })

    if r == pair.b.r and c == pair.b.c then
        state.completed_pairs[p] = true
        play_sound('tarot1', 1.1, 0.6)

        local all_pairs_done = true
        for _, check_p in ipairs(state.pairs) do
            if not state.completed_pairs[check_p.id] then
                all_pairs_done = false
                break
            end
        end

        local total_cells = state.size * state.size
        local covered_cells = 0
        for cr = 1, state.size do
            for cc = 1, state.size do
                local occ = ethernet_cell_in_path(state, cr, cc)
                if occ and #occ > 0 then
                    covered_cells = covered_cells + 1
                end
            end
        end

        local is_100_percent = (covered_cells == total_cells)

        if all_pairs_done and is_100_percent then
            state.completed = true
            state.message = "100% GRID ROUTED! (+" .. state.reward .. " MULT)"
            play_sound('timpani', 1.1, 0.85)
            play_sound('tarot2', 1.2, 0.7)
            local card = state.card
            if card and card.ability and card.ability.extra then
                card.ability.extra.current_mult = (card.ability.extra.current_mult or 0) + state.reward
                card.ability.extra.played_this_round = true
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = '+' .. tostring(state.reward) .. ' Mult',
                    colour = G.C.MULT
                })
            end
            if notify_minigame_completed then
                notify_minigame_completed('ethernet')
            end
        elseif all_pairs_done and not is_100_percent then
            state.message = "All cables linked, but " .. (total_cells - covered_cells) .. " cells empty! 100% needed."
            play_sound('cancel', 0.9, 0.4)
        else
            state.message = "Cable " .. p .. " connected! (" .. covered_cells .. "/" .. total_cells .. " cells)"
            for _, check_p in ipairs(state.pairs) do
                if not state.completed_pairs[check_p.id] then
                    state.active_pair = check_p.id
                    break
                end
            end
        end
    else
        play_sound('button', 1.0 + (#path * 0.05), 0.35)
    end

    return true
end

if G and G.FUNCS then
    G.FUNCS.can_ethernet_play = function(e)
        local card = e.config.ref_table
        local ex = card and card.ability and card.ability.extra
        local can_play = card and not card.debuff
           and ex and not ex.played_this_round
           and G.STATE == G.STATES.SELECTING_HAND
        if can_play then
            e.config.colour = G.C.BLUE
            e.config.button = 'ethernet_open_minigame'
        else
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    end

    G.FUNCS.ethernet_open_minigame = function(e)
        local card = (e and e.config and e.config.ref_table)
        if not card and G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if card_has_key(j, 'ethernet') then
                    card = j
                    break
                end
            end
        end
        if not card or not card.ability or not card.ability.extra then return end
        if card.ability.extra.played_this_round or card.debuff or G.STATE ~= G.STATES.SELECTING_HAND then return end
        card.ability.extra.played_this_round = true
        if e and e.UIBox then e.UIBox:recalculate(true) end

        if not card.ability.extra.saved_puzzle or card.ability.extra.saved_puzzle.completed or card.ability.extra.saved_puzzle.failed then
            G.ETHERNET_MINIGAME = generate_ethernet_puzzle(card, 5, 4)
            card.ability.extra.saved_puzzle = G.ETHERNET_MINIGAME
        else
            G.ETHERNET_MINIGAME = card.ability.extra.saved_puzzle
            G.ETHERNET_MINIGAME.card = card
        end

        open_ethernet_dots_menu()
    end

    G.FUNCS.ethernet_cell_click = function(e)
        local ref = e and e.config and e.config.ref_table
        if not ref then return end
        if ethernet_step_to_cell(ref.r, ref.c) then
            open_ethernet_dots_menu()
        end
    end

    G.FUNCS.ethernet_select_pair = function(e)
        local ref = e and e.config and e.config.ref_table
        if not ref or not G.ETHERNET_MINIGAME then return end
        G.ETHERNET_MINIGAME.active_pair = ref.pair_id
        play_sound('button', 1.0, 0.4)
        open_ethernet_dots_menu()
    end

    G.FUNCS.ethernet_reset_wire = function(e)
        if not G.ETHERNET_MINIGAME then return end
        local state = G.ETHERNET_MINIGAME
        local p = state.active_pair
        if p and state.pairs and state.pairs[p] then
            if state.completed_pairs then state.completed_pairs[p] = nil end
            state.wire_paths[p] = { { r = state.pairs[p].a.r, c = state.pairs[p].a.c } }
            state.message = "Reset cable for wire #" .. p .. "."
            play_sound('cancel', 0.9, 0.4)
            open_ethernet_dots_menu()
        elseif state.pairs then
            for k, pair in ipairs(state.pairs) do
                if state.completed_pairs then state.completed_pairs[k] = nil end
                state.wire_paths[k] = { { r = pair.a.r, c = pair.a.c } }
            end
            state.message = "All cables reset."
            play_sound('cancel', 0.9, 0.4)
            open_ethernet_dots_menu()
        end
    end

    G.FUNCS.ethernet_refresh_panel = function(e)
        if not G.ETHERNET_MINIGAME then return end
        local card = G.ETHERNET_MINIGAME.card
        local next_s = math.random(5, 7)
        local next_p = math.random(4, math.min(10, next_s == 5 and 6 or (next_s == 6 and 8 or 10)))

        G.ETHERNET_MINIGAME = generate_ethernet_puzzle(card, next_s, next_p)
        if card and card.ability and card.ability.extra then
            card.ability.extra.saved_puzzle = G.ETHERNET_MINIGAME
        end
        play_sound('tarot2', 1.2, 0.5)
        open_ethernet_dots_menu()
    end
end

if Controller and not Controller._orig_ethernet_update then
    Controller._orig_ethernet_update = Controller.update
    Controller.update = function(self, dt)
        Controller._orig_ethernet_update(self, dt)
        if G.ETHERNET_MINIGAME and not G.ETHERNET_MINIGAME.completed and G.OVERLAY_MENU and love.mouse and love.mouse.isDown and love.mouse.isDown(1) then
            local target = self.hovering and self.hovering.target
            if target and target.config and target.config.button == 'ethernet_cell_click' and target.config.ref_table then
                local ref = target.config.ref_table
                if G.ETHERNET_MINIGAME.last_drag_key ~= ref.key then
                    G.ETHERNET_MINIGAME.last_drag_key = ref.key
                    if ethernet_step_to_cell(ref.r, ref.c) then
                        open_ethernet_dots_menu()
                    end
                end
            end
        elseif G.ETHERNET_MINIGAME then
            G.ETHERNET_MINIGAME.last_drag_key = nil
        end
    end
end

if G and G.UIDEF and G.UIDEF.use_and_sell_buttons then
    local orig_ethernet_use_and_sell = G.UIDEF.use_and_sell_buttons
    G.UIDEF.use_and_sell_buttons = function(card)
        local base_background = orig_ethernet_use_and_sell(card)
        if not card or card.area ~= G.jokers or G.STATE == G.STATES.TUTORIAL then
            return base_background
        end
        if not base_background or not base_background.nodes or not base_background.nodes[1] or not base_background.nodes[1].nodes then
            return base_background
        end

        if card_has_key(card, 'ethernet') then
            local is_played = card.ability and card.ability.extra and card.ability.extra.played_this_round
            local can_play = not is_played and not card.debuff and (G.STATE == G.STATES.SELECTING_HAND)
            local btn_txt = (G.STATE ~= G.STATES.SELECTING_HAND and "In Round Only") or (is_played and "Played" or "PLAY")
            local play_btn_node = {
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
                                    colour = can_play and G.C.BLUE or G.C.UI.BACKGROUND_INACTIVE,
                                    one_press = true,
                                    button = can_play and 'ethernet_open_minigame' or nil,
                                    func = 'can_ethernet_play'
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
            }
            table.insert(base_background.nodes[1].nodes, play_btn_node)
        end

        return base_background
    end
end

SMODS.Joker {
    key = 'russian_dice',
    atlas = 'reality_warp_jokers',
    pos = { x = 1, y = 11 },
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    config = { extra = { chamber = 1, bullet = 6, safe_rounds = 0 } },
    loc_txt = {
        name = 'Russian Roulette',
        text = {
            "Grants {X:mult,C:white}X3.5{} Mult.",
            "Each played hand rotates cylinder by 1 {C:inactive}(#1#/6){}.",
            "If the live round fires: {C:red}card self-destructs{},",
            "and restricts remaining hands to {C:attention}1{} this round"
        }
    },
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.chamber or 1 } }
    end,
    calculate = function(self, card, context)
        local ex = card.ability.extra
        if not ex.bullet then
            ex.bullet = pseudorandom('roulette_bullet', 1, 6)
        end

        if context.joker_main then
            return {
                Xmult = 3.5,
                card = card
            }
        end

        if context.after and not context.blueprint then
            ex.chamber = (ex.chamber % 6) + 1
            if ex.chamber == ex.bullet then
                play_sound('explosion_release1')
                if G.GAME and G.GAME.current_round then
                    G.GAME.current_round.hands_left = 1
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:start_dissolve()
                        return true
                    end
                }))
                return {
                    message = 'BANG! Misfire!',
                    colour = G.C.RED,
                    card = card
                }
            else
                play_sound('button', 1.2)
                return {
                    message = 'Click! Chamber ' .. ex.chamber .. '/6',
                    colour = G.C.GREY,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'pachinko',
    atlas = 'reality_warp_jokers',
    pos = { x = 0, y = 11 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    config = { extra = { chips = 0, mult = 0, x_mult = 1.0, played_this_round = false } },
    loc_txt = {
        name = 'Pachinko Machine',
        text = {
            "Click {C:attention}Play{} once per round during hand selection",
            "to drop a steel ball bouncing across pins into {C:attention}1 of 5 pockets{}.",
            "Pockets award permanent {C:chips}+Chips{}, {C:mult}+Mult{},",
            "or {X:mult,C:white}XMult{} that accumulate across rounds!",
            "{C:inactive}(Currently: {C:chips}+#1#{} Chips, {C:mult}+#2#{} Mult, {X:mult,C:white}X#3#{} Mult){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.chips or 0, ex.mult or 0, string.format('%.2f', ex.x_mult or 1.0) } }
    end,
    calculate = function(self, card, context)
        local ex = card.ability.extra
        if context.joker_main then
            local ret = {}
            if ex.chips and ex.chips > 0 then ret.chips = ex.chips end
            if ex.mult and ex.mult > 0 then ret.mult = ex.mult end
            if ex.x_mult and ex.x_mult > 1.0 then ret.Xmult = ex.x_mult end
            if ret.chips or ret.mult or ret.Xmult then
                ret.card = card
                ret.message = (ret.Xmult and ('X' .. string.format('%.2f', ret.Xmult) .. ' Mult') or (ret.mult and ('+' .. ret.mult .. ' Mult') or ('+' .. ret.chips .. ' Chips')))
                return ret
            end
        end

        if (context.end_of_round or context.setting_blind) and not context.blueprint then
            ex.played_this_round = false
        end
    end
}

SMODS.Joker {
    key = 'echo_chamber',
    atlas = 'reality_warp_jokers',
    pos = { x = 1, y = 12 },
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    config = { extra = {} },
    loc_txt = {
        name = 'Echo Chamber',
        text = {
            "{C:green}1 in 2{} chance to retrigger scored card.",
            "Can retrigger {C:attention}infinitely{} as long",
            "as the chance succeeds.",
            "{C:inactive}(Probability is not affected by dice){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local reps = 0
            while pseudorandom('echo_chamber') < 0.5 and reps < 50 do
                reps = reps + 1
            end
            if reps > 0 then
                play_sound('tarot2', 1.2)
                return {
                    message = 'Echo! (x' .. reps .. ')',
                    repetitions = reps,
                    card = card
                }
            else
                local has_dice = false
                if G.jokers and G.jokers.cards then
                    for _, j in ipairs(G.jokers.cards) do
                        local k = (j.config and j.config.center and j.config.center.key) or (j.config and j.config.center_key)
                        if k == 'j_oops' or (j.ability and j.ability.name == 'Oops! All 6s') then
                            has_dice = true
                            break
                        end
                    end
                end
                if has_dice then
                    local taunts = {
                        ":P",
                        "XD",
                        "LOL",
                        "Nope!",
                        "In Your dreams!",
                        "Nuh uh!",
                        "Bleh!",
                        "You idiot!"
                    }
                    local taunt = pseudorandom_element(taunts, pseudoseed('echo_taunt_' .. tostring(G.GAME.round or 1) .. '_' .. tostring(math.random(1, 100000))))
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = taunt, colour = G.C.RED })
                    card:juice_up(0.3, 0.3)
                    play_sound('cancel', 0.9, 0.8)
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'maestro',
    atlas = 'reality_warp_jokers',
    pos = { x = 1, y = 5 },
    rarity = 3,
    cost = 8,
    blueprint_compat = false,
    loc_txt = {
        name = 'Maestro',
        text = {
            "Defeating a {C:attention}Boss Blind{} creates",
            "a random {C:attention}Common{} to {C:rare}Rare{} Joker",
            "with the {C:dark_edition}Ghost{} effect",
            "{C:inactive}(Ghosts do not occupy Joker slots){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_reality_warp_ghost or G.P_CENTERS.e_ghost
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local rarity_roll = pseudorandom('maestro_rarity', 1, 100)
                        local rarity = 1
                        if rarity_roll > 70 then
                            rarity = 3
                        elseif rarity_roll > 35 then
                            rarity = 2
                        else
                            rarity = 1
                        end

                        local new_joker = create_card('Joker', G.jokers, nil, rarity, nil, nil, nil, 'maestro')
                        new_joker:set_edition('e_reality_warp_ghost', true)
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        card:juice_up(0.6, 0.4)
                        play_sound('tarot1')
                        return true
                    end
                }))
                return {
                    message = 'Ghost Summoned!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}

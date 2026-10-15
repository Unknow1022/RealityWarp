
if not JokerDisplay then return end

local jd_def = JokerDisplay.Definitions

local function format_short_card(c)
    if not c or not c.base then return "?" end
    local val = c.base.value or '?'
    local short_val = (val == '10' and '10') or string.sub(tostring(val), 1, 1)
    local suit_sym = (c.base.suit == 'Hearts' and 'H') or
                     (c.base.suit == 'Diamonds' and 'D') or
                     (c.base.suit == 'Spades' and 'S') or
                     (c.base.suit == 'Clubs' and 'C') or ''
    return short_val .. suit_sym
end

local function has_charles_and_mochi_jd()
    return (type(has_charles_and_mochi) == 'function' and has_charles_and_mochi()) or false
end

jd_def["j_reality_warp_masterful_joker"] = {
    text = {
        { text = "+1 Tarot" }
    },
    text_config = { colour = G.C.PURPLE },
    reminder_text = {
        { text = "(4 of a Kind)" }
    },
    calc_function = function(card)
        local text, poker_hands = JokerDisplay.evaluate_hand()
        local is_four = (poker_hands and poker_hands['Four of a Kind'] and next(poker_hands['Four of a Kind']))
        card.joker_display_values.active = (text ~= 'Unknown' and is_four)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.PURPLE or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_outstanding_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "retrigger_str" }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "card_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local triggers = JokerDisplay.calculate_joker_triggers(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand and #scoring_hand > 0 then
            local highest_rank = -1
            local highest_card = nil
            for _, c in ipairs(scoring_hand) do
                local r = (c.get_id and c:get_id()) or (c.base and c.base.id) or 0
                if r > highest_rank then
                    highest_rank = r
                    highest_card = c
                end
            end
            if highest_card then
                card.joker_display_values.retrigger_str = (1 * triggers) .. "x"
                card.joker_display_values.card_str = format_short_card(highest_card)
                card.joker_display_values.active = true
            else
                card.joker_display_values.retrigger_str = (1 * triggers) .. "x"
                card.joker_display_values.card_str = "-"
                card.joker_display_values.active = false
            end
        else
            card.joker_display_values.retrigger_str = (1 * triggers) .. "x"
            card.joker_display_values.card_str = "-"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand or #scoring_hand == 0 then return 0 end
        if not JokerDisplay.in_scoring(playing_card, scoring_hand) then return 0 end
        local highest_rank = -1
        local highest_card = nil
        for _, c in ipairs(scoring_hand) do
            local r = (c.get_id and c:get_id()) or (c.base and c.base.id) or 0
            if r > highest_rank then
                highest_rank = r
                highest_card = c
            end
        end
        if playing_card == highest_card then
            return 1 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

jd_def["j_reality_warp_blueberry_joker"] = {
    text = {
        { text = "+1 Hand", colour = G.C.BLUE }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rounds_left" },
        { text = ")" }
    },
    calc_function = function(card)
        local r = (card.ability and card.ability.extra and card.ability.extra.rounds_left) or 3
        card.joker_display_values.rounds_left = r .. "/3"
    end
}

jd_def["j_reality_warp_dj_joker"] = {
    text = {
        { text = "Remix", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local used = card.ability and card.ability.extra and card.ability.extra.used
        card.joker_display_values.rem = used and "0/1" or "1/1"
        card.joker_display_values.active = not used
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Enhanced or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_disenador_joker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MONEY },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local dollars = 0
        local wild_count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if is_wild_card(c) then
                    local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    dollars = dollars + (card.ability.extra.dollars or 1) * triggers
                    wild_count = wild_count + 1
                end
            end
        end
        card.joker_display_values.dollars = dollars
        card.joker_display_values.rem = wild_count .. " Wild"
    end
}

jd_def["j_reality_warp_tts_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "mult" },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    calc_function = function(card)
        local letter_counts = {
            ['2'] = 3, ['3'] = 5, ['4'] = 4, ['5'] = 4, ['6'] = 3,
            ['7'] = 5, ['8'] = 5, ['9'] = 4, ['10'] = 3,
            ['Jack'] = 4, ['Queen'] = 5, ['King'] = 4, ['Ace'] = 3
        }
        local total_chips = 0
        local total_mult = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local val = c.base and c.base.value
                local l = letter_counts[val] or 4
                local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                total_chips = total_chips + (l * (card.ability.extra.chips_per_letter or 4)) * triggers
                total_mult = total_mult + (l * (card.ability.extra.mult_per_letter or 1)) * triggers
            end
        end
        card.joker_display_values.chips = total_chips
        card.joker_display_values.mult = total_mult
    end
}

jd_def["j_reality_warp_joker_descartador"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        card.joker_display_values.chips = ex.chips or 0
        card.joker_display_values.mult = ex.mult or 0
        card.joker_display_values.discards = discards .. " disc."
    end
}

jd_def["j_reality_warp_shareholder_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "reminder_str" }
    },
    calc_function = function(card)
        local price = (card.ability and card.ability.extra and card.ability.extra.current_price) or 5
        card.joker_display_values.mult = price * 2
        local is_boss = G.GAME and G.GAME.blind and G.GAME.blind.boss
        if is_boss then
            card.joker_display_values.reminder_str = "(Cash Out: +$" .. price .. ")"
            card.joker_display_values.active = true
        else
            card.joker_display_values.reminder_str = "(+$" .. price .. ")"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.MONEY
        end
    end
}

jd_def["j_reality_warp_builder_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand and #scoring_hand >= 2 then
            local is_ascending = true
            for i = 1, #scoring_hand - 1 do
                local cur_id = scoring_hand[i]:get_id() or 0
                local next_id = scoring_hand[i + 1]:get_id() or 0
                if cur_id >= next_id then
                    is_ascending = false
                    break
                end
            end
            if is_ascending then
                card.joker_display_values.x_mult = 1 + (#scoring_hand * (card.ability.extra.xmult_per_card or 0.5))
                card.joker_display_values.rem = #scoring_hand .. " cards"
                card.joker_display_values.active = true
            else
                card.joker_display_values.x_mult = 1
                card.joker_display_values.rem = "0"
                card.joker_display_values.active = false
            end
        else
            card.joker_display_values.x_mult = 1
            card.joker_display_values.rem = "0"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_banquet_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "held_count" },
        { text = "/7)" }
    },
    calc_function = function(card)
        local in_hand = (G.hand and G.hand.cards and #G.hand.cards) or 0
        local highlighted = (G.hand and G.hand.highlighted and #G.hand.highlighted) or 0
        local held = math.max(0, in_hand - highlighted)
        local thresh = (card.ability and card.ability.extra and card.ability.extra.hand_threshold) or 7
        card.joker_display_values.held_count = held
        if held >= thresh then
            card.joker_display_values.x_mult = card.ability.extra.xmult or 2.5
            card.joker_display_values.active = true
        else
            card.joker_display_values.x_mult = 1
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_appraiser_joker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" }
    },
    text_config = { colour = G.C.MONEY },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "count" },
        { text = ")" }
    },
    calc_function = function(card)
        local count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if pcard.edition and (pcard.edition.foil or pcard.edition.holo or pcard.edition.polychrome) then
                    count = count + 1
                end
            end
        end
        local per = (card.ability and card.ability.extra and card.ability.extra.dollars_per_edition) or 1
        card.joker_display_values.count = count
        card.joker_display_values.dollars = count * per
    end
}

jd_def["j_reality_warp_runway_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+X0.1/Enh)" }
    },
    calc_function = function(card)
        local xmult = (card.ability and card.ability.extra and card.ability.extra.xmult) or 1
        card.joker_display_values.x_mult = xmult
    end
}

jd_def["j_reality_warp_slot_machine_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "score_text" }
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "sub_text" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        if ex.last_spin and #ex.last_spin == 3 then
            local r1, r2, r3 = ex.last_spin[1], ex.last_spin[2], ex.last_spin[3]
            local spin_str = "[ " .. tostring(r1) .. " | " .. tostring(r2) .. " | " .. tostring(r3) .. " ]"
            if r1 == '7' and r2 == '7' and r3 == '7' then
                card.joker_display_values.score_text = "X" .. (ex.jackpot_xmult or 4) .. " / +$" .. (ex.jackpot_cash or 35)
            elseif r1 == r2 and r2 == r3 then
                card.joker_display_values.score_text = "X" .. (ex.triple_xmult or 2.5) .. " / +$" .. (ex.triple_cash or 12)
            elseif r1 == r2 or r2 == r3 or r1 == r3 then
                card.joker_display_values.score_text = "+" .. (ex.pair_mult or 15) .. " / +$" .. (ex.pair_cash or 3)
            else
                card.joker_display_values.score_text = "No Match"
            end
            card.joker_display_values.sub_text = spin_str
        else
            local has_lucky = false
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' and scoring_hand then
                for _, sc in ipairs(scoring_hand) do
                    if sc.ability and (sc.ability.name == 'Lucky Card' or sc.ability.effect == 'Lucky Card') then
                        has_lucky = true
                        break
                    end
                end
            end
            card.joker_display_values.score_text = has_lucky and "[ 7 | ? | ? ]" or "[ ? | ? | ? ]"
            card.joker_display_values.sub_text = ex.bet_placed and "Bet $5" or "Bet"
        end
    end
}

jd_def["j_reality_warp_duel_of_value_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
        local is_two_pair = (poker_hands and poker_hands['Two Pair'] and next(poker_hands['Two Pair']))
        if text ~= 'Unknown' and is_two_pair and scoring_hand and #scoring_hand == 4 then
            local evens, odds = 0, 0
            for _, c in ipairs(scoring_hand) do
                local id = c:get_id() or 0
                if id > 0 then
                    if id == 14 or id % 2 ~= 0 then odds = odds + 1 else evens = evens + 1 end
                end
            end
            if evens == 2 and odds == 2 then
                card.joker_display_values.x_mult = card.ability.extra.xmult or 3.0
                card.joker_display_values.rem = "2/2"
                card.joker_display_values.active = true
                return
            end
        end
        card.joker_display_values.x_mult = 1.0
        card.joker_display_values.rem = "0/2"
        card.joker_display_values.active = false
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_falta_de_lectura_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    calc_function = function(card)
        local other_jokers = false
        if G.jokers and G.jokers.cards then
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and not j.debuff and (not j.ability or j.ability.name ~= 'Reading Deficiency') then
                    other_jokers = true
                    break
                end
            end
        end
        if not other_jokers then
            card.joker_display_values.x_mult = card.ability.extra.xmult or 5.0
            card.joker_display_values.active = true
        else
            card.joker_display_values.x_mult = 1.0
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_chameleon_joker"] = {
    text = {
        { text = "Copy Blind Tag", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(50% 2x)" }
    }
}

jd_def["j_reality_warp_motorized_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT }
}
jd_def["j_reality_warp_motorizado_joker"] = jd_def["j_reality_warp_motorized_joker"]

jd_def["j_reality_warp_hired_joker"] = {
    text = {
        { text = "Job Card", colour = HEX('5c1e11') }
    },
    reminder_text = {
        { text = "(1/3)" }
    }
}
jd_def["j_reality_warp_contratado_joker"] = jd_def["j_reality_warp_hired_joker"]

jd_def["j_reality_warp_seal_of_approval_joker"] = {
    text = {
        { text = "+Seal", colour = G.C.GOLD }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand and #scoring_hand == 1 then
            card.joker_display_values.rem = "1/1"
            card.joker_display_values.active = true
        else
            card.joker_display_values.rem = "0/1"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_reality_warp_sello_aprobacion_joker"] = jd_def["j_reality_warp_seal_of_approval_joker"]

jd_def["j_reality_warp_paint_puddle_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.ability.extra", ref_value = "suit" },
        { text = ")" }
    },
    calc_function = function(card)
        local suit = (card.ability and card.ability.extra and card.ability.extra.suit) or 'Hearts'
        local total_mult = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                if is_wild_card(c) then
                    total_mult = total_mult + (card.ability.extra.mult_wild or 15) * triggers
                elseif c:is_suit(suit) then
                    total_mult = total_mult + (card.ability.extra.mult_suit or 7) * triggers
                end
            end
        end
        card.joker_display_values.mult = total_mult
    end
}
jd_def["j_reality_warp_charco_pintura_joker"] = jd_def["j_reality_warp_paint_puddle_joker"]

jd_def["j_reality_warp_injured_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "prob_text" }
    },
    text_config = { colour = G.C.GREEN },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "rem_text" }
    },
    calc_function = function(card)
        local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        card.joker_display_values.prob_text = "" .. prob .. " in " .. odds
        card.joker_display_values.rem_text = "(End of round)"
    end
}
jd_def["j_reality_warp_lesionado_joker"] = jd_def["j_reality_warp_injured_joker"]

jd_def["j_reality_warp_extended_hand"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(<=4 cards)" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
        card.joker_display_values.active = (ex.xmult and ex.xmult > 1.0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_reality_warp_mano_extendida"] = jd_def["j_reality_warp_extended_hand"]

jd_def["j_reality_warp_bonfire"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Face Discard)" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
        card.joker_display_values.active = (ex.xmult and ex.xmult > 1.0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_reality_warp_hoguera"] = jd_def["j_reality_warp_bonfire"]

jd_def["j_reality_warp_doctor_jo_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "status" }
    },
    text_config = { colour = G.C.BLUE },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local hands_left = (G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left) or 0
        local used = card.ability and card.ability.extra and card.ability.extra.defibrillator_used
        if used then
            card.joker_display_values.status = "Used"
            card.joker_display_values.rem = "0/1"
        elseif hands_left <= 1 then
            card.joker_display_values.status = "+1 Hand"
            card.joker_display_values.rem = "Ready"
        else
            card.joker_display_values.status = "+1 Hand"
            card.joker_display_values.rem = "Final hand"
        end
    end
}

jd_def["j_reality_warp_symmetrical_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Flush 4+)" }
    },
    calc_function = function(card)
        local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
        local is_poker = poker_hands and ((poker_hands['Four of a Kind'] and next(poker_hands['Four of a Kind'])) or
                                          (poker_hands['Five of a Kind'] and next(poker_hands['Five of a Kind'])) or
                                          (poker_hands['Flush Five'] and next(poker_hands['Flush Five'])))
        if text ~= 'Unknown' and is_poker and scoring_hand and #scoring_hand >= 4 then
            local first_suit = scoring_hand[1] and scoring_hand[1].base and scoring_hand[1].base.suit
            local same = true
            for _, c in ipairs(scoring_hand) do
                if not c.base or c.base.suit ~= first_suit then
                    same = false
                    break
                end
            end
            if same then
                card.joker_display_values.x_mult = card.ability.extra.xmult or 4.0
                card.joker_display_values.active = true
                return
            end
        end
        card.joker_display_values.x_mult = 1.0
        card.joker_display_values.active = false
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_balance_joker"] = {
    text = {
        { text = "+2 Spectrals", colour = G.C.SECONDARY_SET.Spectral }
    },
    reminder_text = {
        { text = "(Flush 4)" }
    },
    calc_function = function(card)
        local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
        local is_four = poker_hands and poker_hands['Four of a Kind'] and next(poker_hands['Four of a Kind'])
        if text ~= 'Unknown' and is_four and scoring_hand and #scoring_hand == 4 then
            local first_suit = scoring_hand[1] and scoring_hand[1].base and scoring_hand[1].base.suit
            local same = true
            for _, c in ipairs(scoring_hand) do
                if not c.base or c.base.suit ~= first_suit then
                    same = false
                    break
                end
            end
            if same then
                card.joker_display_values.active = true
                return
            end
        end
        card.joker_display_values.active = false
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Spectral or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_merchant_joker"] = {
    text = {
        { text = "-$" },
        { ref_table = "card.ability.extra", ref_value = "cost_per_shop" }
    },
    text_config = { colour = G.C.RED }
}

jd_def["j_reality_warp_lover_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "main_text" }
    },
    text_config = { colour = G.C.HEARTS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local sm1, sm2 = (type(get_or_pick_soulmates) == 'function' and get_or_pick_soulmates()) or nil, nil
        local s1 = format_short_card(sm1)
        local s2 = format_short_card(sm2)
        local has_sm1, has_sm2 = false, false
        local heart_count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c == sm1 then has_sm1 = true end
                if c == sm2 then has_sm2 = true end
                if c:is_suit('Hearts') then
                    heart_count = heart_count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end

        if has_sm1 and has_sm2 then
            card.joker_display_values.main_text = "X3 Mult +$6"
            card.joker_display_values.rem = s1 .. " & " .. s2
            card.joker_display_values.active = true
        elseif heart_count > 0 then
            card.joker_display_values.main_text = "+" .. (heart_count * 10) .. " Mult"
            card.joker_display_values.rem = s1 .. " & " .. s2
            card.joker_display_values.active = true
        else
            card.joker_display_values.main_text = "X3 +$6"
            card.joker_display_values.rem = s1 .. " & " .. s2
            card.joker_display_values.active = false
        end
    end
}

jd_def["j_reality_warp_blacksmith_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "heat_status" }
    },
    text_config = { colour = G.C.ORANGE },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local cur = (card.ability and card.ability.extra and card.ability.extra.temp) or 0
        local max_t = (card.ability and card.ability.extra and card.ability.extra.max_temp) or 100
        local per_card = (card.ability and card.ability.extra and card.ability.extra.heat_per_card) or 10
        local projected = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            projected = #scoring_hand * per_card
        end
        local total = cur + projected
        if total >= max_t then
            card.joker_display_values.heat_status = "READY!"
            card.joker_display_values.rem = max_t .. "/" .. max_t
            card.joker_display_values.active = true
        else
            card.joker_display_values.heat_status = cur .. "/" .. max_t
            card.joker_display_values.rem = projected > 0 and ("+" .. projected) or ("+" .. per_card .. "/card")
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.ORANGE
        end
    end
}

jd_def["j_reality_warp_lucky_one_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "clubs_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra
        local clubs = (ex and ex.clubs_scored) or 0
        local is_guar = (ex and ex.guaranteed) or (G.GAME and G.GAME.lucky_one_guaranteed)
        card.joker_display_values.x_mult = (ex and ex.xmult) or 1.5
        card.joker_display_values.clubs_str = is_guar and "Guaranteed!" or (clubs .. "/5 ♣")
        card.joker_display_values.active = is_guar
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = G.C.XMULT
        end
        if reminder_text and reminder_text.children and reminder_text.children[2] then
            reminder_text.children[2].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.CLUBS
        end
    end
}

jd_def["j_reality_warp_miner_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "bonus_str" }
    },
    text_config = { colour = G.C.DIAMONDS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "depth_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local d = (card.ability and card.ability.extra and card.ability.extra.depth) or 0
        card.joker_display_values.depth_str = d .. "/1000m"
        if d >= 1000 then
            card.joker_display_values.bonus_str = "Max: ALL Tiers!"
            card.joker_display_values.active = true
        elseif d >= 800 then
            card.joker_display_values.bonus_str = "X2.5 + Spectral"
            card.joker_display_values.active = true
        elseif d >= 600 then
            card.joker_display_values.bonus_str = "X2 + Retrigger"
            card.joker_display_values.active = true
        elseif d >= 400 then
            card.joker_display_values.bonus_str = "X1.5 Mult"
            card.joker_display_values.active = true
        elseif d >= 200 then
            card.joker_display_values.bonus_str = "+$3"
            card.joker_display_values.active = true
        else
            card.joker_display_values.bonus_str = "+50 Chips"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.CHIPS
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        local d = (joker_card.ability and joker_card.ability.extra and joker_card.ability.extra.depth) or 0
        if d >= 600 and playing_card:is_suit('Diamonds') and JokerDisplay.in_scoring(playing_card, scoring_hand) then
            return 1 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

jd_def["j_reality_warp_joke_joker"] = {
    text = {
        { text = "+1 Slot", colour = G.C.SECONDARY_SET.Voucher }
    }
}

jd_def["j_reality_warp_perfectionism_joker"] = {
    text = {
        { text = "+Polychrome", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local is_big_or_boss = false
        if G.GAME and G.GAME.blind then
            if G.GAME.blind.boss or G.GAME.blind.name == 'Big Blind' or G.GAME.blind.key == 'b_big' or (G.GAME.blind.get_type and G.GAME.blind:get_type() == 'Big') then
                is_big_or_boss = true
            end
        end
        card.joker_display_values.rem = is_big_or_boss and "Active" or "Inactive"
        card.joker_display_values.active = is_big_or_boss
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.DARK_EDITION or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_reaper_joker"] = {
    text = {
        { text = "-30% Blind", colour = G.C.RED }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        local used = card.ability and card.ability.extra and card.ability.extra.used_this_round
        card.joker_display_values.rem = used and "Used" or "Ready"
        card.joker_display_values.active = not used
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.RED or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_reality_warp_parca_joker"] = jd_def["j_reality_warp_reaper_joker"]
jd_def["j_reality_warp_parca"] = jd_def["j_reality_warp_reaper_joker"]

jd_def["j_reality_warp_potion_brewer"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "chips", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS }
}

jd_def["j_reality_warp_infostealer_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            }
        }
    }
}

jd_def["j_reality_warp_oversaturated_joker"] = {
    text = {
        { text = "+Enh / Seal / Ed", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "rem" },
        { text = ")" }
    },
    calc_function = function(card)
        card.joker_display_values.rem = "1 card"
        card.joker_display_values.active = true
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Enhanced or G.C.UI.TEXT_INACTIVE
        end
    end
}
jd_def["j_reality_warp_sobresaturado_joker"] = jd_def["j_reality_warp_oversaturated_joker"]

jd_def["j_reality_warp_radiation"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "xmult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "debuff_risk" },
        { text = ")" }
    },
    calc_function = function(card)
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        local odds = (card.ability and card.ability.extra and card.ability.extra.odds) or 5
        card.joker_display_values.debuff_risk = "" .. prob .. " in " .. odds .. " debuff"
    end
}
jd_def["j_reality_warp_radiacion"] = jd_def["j_reality_warp_radiation"]

jd_def["j_reality_warp_esteban"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(♠ / ♣)" }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c:is_suit('Spades') or c:is_suit('Clubs') then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        local per = (card.ability and card.ability.extra and card.ability.extra.xmult) or 2.5
        card.joker_display_values.x_mult = count > 0 and (per ^ count) or 1.0
        card.joker_display_values.active = (count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_thiago"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Per 20 Chips)" }
    },
    calc_function = function(card)
        local current_chips = (hand_chips and hand_chips > 0 and hand_chips) or 0
        if current_chips == 0 then
            local text, _, scoring_hand = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' and G.GAME and G.GAME.hands and G.GAME.hands[text] then
                current_chips = G.GAME.hands[text].chips or 0
                if scoring_hand then
                    for _, c in ipairs(scoring_hand) do
                        current_chips = current_chips + (c.base and c.base.nominal or 0)
                    end
                end
            end
        end
        local req = (card.ability and card.ability.extra and card.ability.extra.chips_per_xmult) or 20
        local x = math.floor(current_chips / req)
        card.joker_display_values.x_mult = math.max(1, x)
        card.joker_display_values.active = (x > 1)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_black_hole_joker"] = {
    text = {
        {
            border_nodes = {
                { text = "^" },
                { ref_table = "card.ability.extra", ref_value = "pow" }
            },
            border_colour = G.C.DARK_EDITION
        }
    }
}

jd_def["j_reality_warp_squele"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" },
        { text = " " },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(♥)" }
    },
    calc_function = function(card)
        local hearts = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c:is_suit('Hearts') then
                    hearts = hearts + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.mult = hearts * (card.ability.extra.mult or 10)
        card.joker_display_values.x_mult = hearts > 0 and ((card.ability.extra.xmult or 1.5) ^ hearts) or 1.0
        card.joker_display_values.active = (hearts > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[4] then
            text.children[4].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_bluxdir"] = {
    text = {
        { text = "+1 Level", colour = G.C.ATTENTION }
    },
    reminder_text = {
        { text = "(Discard)" }
    }
}

jd_def["j_reality_warp_charles"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        },
        { text = " +$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.MONEY, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(♠ / ♥)" }
    },
    calc_function = function(card)
        local has_mochi = has_charles_and_mochi_jd()
        local suit_count = 0
        local card_count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            card_count = #scoring_hand
            for _, c in ipairs(scoring_hand) do
                local triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                if c:is_suit('Spades') or c:is_suit('Hearts') then
                    suit_count = suit_count + triggers
                end
            end
        end
        local dollars_per = (card.ability.extra.dollars or 5) * (has_mochi and 2 or 1)
        card.joker_display_values.dollars = card_count * dollars_per
        card.joker_display_values.x_mult = suit_count > 0 and ((card.ability.extra.xmult or 2) ^ suit_count) or 1.0
        card.joker_display_values.active = (suit_count > 0 or card_count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        if has_charles_and_mochi_jd() and JokerDisplay.in_scoring(playing_card, scoring_hand) then
            return 1 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

jd_def["j_reality_warp_mochi"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "wild_count" },
        { text = " Wild)" }
    },
    calc_function = function(card)
        local wild_count = 0
        if G.playing_cards then
            for _, pcard in ipairs(G.playing_cards) do
                if is_wild_card(pcard) then wild_count = wild_count + 1 end
            end
        end
        local gain = (card.ability and card.ability.extra and card.ability.extra.xmult_gain) or 0.25
        card.joker_display_values.wild_count = wild_count
        card.joker_display_values.x_mult = 1.0 + (wild_count * gain)
    end
}

jd_def["j_reality_warp_helin"] = {
    text = {
        {
            border_nodes = {
                { text = "^" },
                { ref_table = "card.ability.extra", ref_value = "power" }
            },
            border_colour = G.C.DARK_EDITION
        }
    },
    reminder_text = {
        { text = "(End of Scoring)" }
    }
}

jd_def["j_reality_warp_raytracing"] = {
    text = {
        { text = "+2 Spectrals", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(Negative)" }
    }
}

jd_def["j_reality_warp_paco"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards" },
        { text = " Discards)" }
    },
    calc_function = function(card)
        local discards = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local per = (card.ability and card.ability.extra and card.ability.extra.xmult_per_discard) or 2
        card.joker_display_values.discards = discards
        card.joker_display_values.x_mult = math.max(1, discards * per)
        card.joker_display_values.active = (discards > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_yairo"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.MULT
        },
        { text = " " },
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_chips", retrigger_type = "exp" }
            },
            border_colour = G.C.CHIPS
        }
    },
    reminder_text = {
        { text = "(6 & 7)" }
    },
    calc_function = function(card)
        local count = 0
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local id = (c.get_id and c:get_id()) or (c.base and c.base.id)
                local val = c.base and c.base.value
                if id == 6 or id == 7 or val == '6' or val == '7' then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        local mult_per = (card.ability and card.ability.extra and card.ability.extra.xmult) or 3
        local chips_per = (card.ability and card.ability.extra and card.ability.extra.xchips) or 1.5
        card.joker_display_values.x_mult = count > 0 and (mult_per ^ count) or 1.0
        card.joker_display_values.x_chips = count > 0 and (chips_per ^ count) or 1.0
        card.joker_display_values.active = (count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.MULT or G.C.UI.TEXT_INACTIVE
        end
        if text and text.children and text.children[3] then
            text.children[3].config.colour = card.joker_display_values.active and G.C.CHIPS or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_kyra"] = {
    text = {
        { text = "Brew Potion", colour = G.C.GREEN }
    },
    reminder_text = {
        { text = "($2)" }
    },
    calc_function = function(card)
        local cur_dollars = (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0
        local has_room = G.consumeables and (#G.consumeables.cards + (G.GAME.consumeable_buffer or 0) < G.consumeables.config.card_limit)
        card.joker_display_values.active = (cur_dollars >= 2 and has_room)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_discard_accumulator"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "discards_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 0
        card.joker_display_values.mult = ex.mult or 0
        local disc = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        card.joker_display_values.discards_str = disc .. " disc."
    end
}


jd_def["j_reality_warp_puppet_joker"] = {
    text = {
        { text = "Puppet Active", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(Blind Start)" }
    }
}

jd_def["j_reality_warp_amnesia_joker"] = {
    text = {
        { text = "Amnesia", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(Level Swap)" }
    }
}

jd_def["j_reality_warp_photographer_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Snap 1st)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.mult = ex.mult or 10
    end
}

jd_def["j_reality_warp_countdown_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "count_str" }
    },
    reminder_text = {
        { text = "(Countdown)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local cnt = ex.counter or 10
        card.joker_display_values.count_str = cnt .. "/10"
        card.joker_display_values.active = (cnt == 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.RED or G.C.FILTER
        end
    end
}

jd_def["j_reality_warp_smuggler_joker"] = {
    text = {
        { text = "+1 Enhance", colour = G.C.GREEN }
    },
    reminder_text = {
        { text = "(Blind Start)" }
    }
}

jd_def["j_reality_warp_sheet_music_joker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" },
        { text = " / +" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(Straight / Str. Flush)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 80
        card.joker_display_values.mult = ex.mult or 40
    end
}

jd_def["j_reality_warp_blood_pact_joker"] = {
    text = {
        { text = "+1 Edition", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(-$2 / Blind)", colour = G.C.RED }
    }
}

jd_def["j_reality_warp_saboteur_joker"] = {
    text = {
        { text = "Debt " },
        { ref_table = "card.joker_display_values", ref_value = "debt_str" }
    },
    reminder_text = {
        { text = "(Multi-Hand)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.debt_str = "$" .. (ex.debt or 0)
    end
}

jd_def["j_reality_warp_boomerang_joker"] = {
    text = {
        { text = "Boomerang", colour = G.C.BLUE }
    },
    reminder_text = {
        { text = "(Returns Cards)" }
    }
}

jd_def["j_reality_warp_spy_joker"] = {
    text = {
        { text = "Spy 3 Cards", colour = G.C.SECONDARY_SET.Enhanced }
    },
    reminder_text = {
        { text = "(Blind Start)" }
    }
}

jd_def["j_reality_warp_apprentice_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "cast_str" }
    },
    reminder_text = {
        { text = "(Right Joker)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.cast_str = (ex.count or 0) .. " Casts"
    end
}

jd_def["j_reality_warp_upgrade_roulette_joker"] = {
    text = {
        { text = "Roulette Upgrade", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(Round End)" }
    }
}

jd_def["j_reality_warp_reversed_hermit_joker"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "dollars" }
    },
    text_config = { colour = G.C.MONEY },
    reminder_text = {
        { text = "(Remaining Discards)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local disc = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local rate = ex.dollars_per_discard or 2
        card.joker_display_values.dollars = disc * rate
    end
}

jd_def["j_reality_warp_script_joker"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "step_str" }
    },
    reminder_text = {
        { text = "(Script: +$12)", colour = G.C.MONEY }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local prog = ex.progress or 0
        local script = ex.script or {}
        if ex.completed then
            card.joker_display_values.step_str = "Complete! (+$12)"
        elseif prog < 3 and script[prog + 1] then
            card.joker_display_values.step_str = (prog) .. "/3: " .. tostring(script[prog + 1])
        else
            card.joker_display_values.step_str = (prog) .. "/3 Script"
        end
    end
}

jd_def["j_reality_warp_reading_deficiency_joker"] = jd_def["j_reality_warp_falta_de_lectura_joker"] or {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Solo Joker)" }
    },
    calc_function = function(card)
        local count = (G.jokers and G.jokers.cards and #G.jokers.cards) or 1
        card.joker_display_values.x_mult = (count == 1) and 5.0 or 1.0
        card.joker_display_values.active = (count == 1)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}


jd_def["j_reality_warp_temporal_rift"] = {
    text = {
        { text = "Rewind Defeat", colour = G.C.ORANGE }
    },
    reminder_text = {
        { text = "(Single Use)" }
    }
}

jd_def["j_reality_warp_polarity_inversion"] = {
    text = {
        { text = "+10 Mult Invert", colour = G.C.MULT }
    },
    reminder_text = {
        { text = "(Debuffed Cards)" }
    }
}

jd_def["j_reality_warp_inheritance"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Inheritance)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.mult = ex.mult or 2
    end
}

jd_def["j_reality_warp_ecosystem"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "eco_str" }
    },
    reminder_text = {
        { text = "(Dom X1.5 / Rare +80)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local dom = ex.dominant and ex.dominant ~= '' and ex.dominant or '?'
        local rare = ex.rarest and ex.rarest ~= '' and ex.rarest or '?'
        card.joker_display_values.eco_str = dom .. " / " .. rare
    end
}

jd_def["j_reality_warp_auctioneer"] = {
    text = {
        { text = "Auction", colour = G.C.GOLD }
    },
    reminder_text = {
        { text = "(5 Bidders, 1 in 5 Chance)" }
    }
}

jd_def["j_reality_warp_parasitic"] = {
    text = {
        { text = "X1.75 Host Joker", colour = G.C.XMULT }
    },
    reminder_text = {
        { text = "(Migrates 3 Rnds)" }
    }
}

jd_def["j_reality_warp_mercenary"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "contract_str" }
    },
    reminder_text = {
        { text = "(Complete Contracts)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local contracts = ex.contracts or {}
        if #contracts > 0 and contracts[1] then
            card.joker_display_values.contract_str = "Contract: " .. tostring(contracts[1].name or 'Active')
        else
            card.joker_display_values.contract_str = "No Contracts"
        end
    end
}

jd_def["j_reality_warp_cascade"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" }
    },
    text_config = { colour = G.C.CHIPS },
    reminder_text = {
        { text = "(First Hand of Blind)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.stored_chips or 0
    end
}


jd_def["j_reality_warp_orchestra_director"] = {
    text = {
        { text = "Free Shop Joker", colour = G.C.MONEY }
    },
    reminder_text = {
        { text = "(1 in 4 Chance)" }
    }
}

jd_def["j_reality_warp_meteorologist"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "weather_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local w = ex.weather or 'None'
        local xm = 3.0
        if w == 'Storm' then xm = 3.5
        elseif w == 'Sun' then xm = 2.5 end
        card.joker_display_values.x_mult = xm
        card.joker_display_values.weather_str = (w ~= '' and w) or "Weather"
    end
}

jd_def["j_reality_warp_mad_clockmaker"] = {
    text = {
        { text = "+" },
        { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { text = "(Remaining Discards)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local disc = (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left) or 0
        local mult_per = ex.mult_per_discard or 14
        card.joker_display_values.mult = disc * mult_per
    end
}

jd_def["j_reality_warp_catalyst"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "odds" },
        { text = " Retrigger)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.x_mult or 2.5
        local prob = (G.GAME and G.GAME.probabilities.normal) or 1
        card.joker_display_values.odds = "" .. prob .. "/" .. (ex.odds or 3)
    end
}

jd_def["j_reality_warp_graffiti_artist"] = {
    text = {
        { text = "X1.5", colour = G.C.XMULT }
    },
    reminder_text = {
        { text = "(Paints Card)" }
    }
}

jd_def["j_reality_warp_hypnotist"] = {
    text = {
        { text = "Disable Boss Blind", colour = G.C.PURPLE }
    },
    reminder_text = {
        { text = "(1 in 3 Chance)" }
    }
}

jd_def["j_reality_warp_hand_alchemist"] = jd_def["j_reality_warp_potion_brewer"]

jd_def["j_reality_warp_entomologist"] = {
    text = {
        { text = "Insect Tokens", colour = G.C.GREEN }
    },
    reminder_text = {
        { text = "(Tokens on Cards)" }
    }
}

jd_def["j_reality_warp_world_devourer"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "blinds_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1
        card.joker_display_values.blinds_str = (ex.blinds_defeated or 0) .. " Blinds"
    end
}

jd_def["j_reality_warp_living_paradox"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "next_str", colour = G.C.DARK_EDITION }
    },
    reminder_text = {
        { text = "(Next Boss Negative)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local name = "Random"
        if ex.next_joker and G.P_CENTERS and G.P_CENTERS[ex.next_joker] then
            local center = G.P_CENTERS[ex.next_joker]
            name = (localize and localize{type = 'name_text', key = center.key, set = 'Joker'}) or center.name or ex.next_joker
        end
        card.joker_display_values.next_str = name
    end
}

jd_def["j_reality_warp_star_chronicler"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult" }
            }
        }
    },
    reminder_text = {
        { text = "(Planets & Black Holes)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local planet_count = 0
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
            for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                if p.discovered then planet_count = planet_count + 1 end
            end
        end
        local base_xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
        local total_xm = base_xm * (ex.black_hole_mult or 1)
        card.joker_display_values.x_mult = string.format('%.1f', total_xm)
    end
}

jd_def["j_reality_warp_astra"] = {
    text = {
        { text = "2X Planets", colour = G.C.SECONDARY_SET.Planet }
    },
    reminder_text = {
        { text = "(Black Hole +3)" }
    }
}

jd_def["j_reality_warp_marie"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Enhanced Cards)" }
    },
    calc_function = function(card)
        local text, _, scoring_hand = JokerDisplay.evaluate_hand()
        local count = 0
        if text ~= 'Unknown' and scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local c_enh = (c.config and c.config.center and c.config.center ~= G.P_CENTERS.c_base and c.config.center.set == 'Enhanced') or (c.ability and c.ability.set == 'Enhanced')
                if c_enh then
                    local base_triggers = JokerDisplay.calculate_card_triggers(c, scoring_hand)
                    local has_seal = (c.seal ~= nil and c.seal ~= '')
                    local has_ed = (c.edition ~= nil and not c.edition.base)
                    local extra_reps = (has_seal and 1 or 0) + (has_ed and 1 or 0)
                    count = count + base_triggers + extra_reps
                end
            end
        end
        local ex = card.ability and card.ability.extra or {}
        local mult_per = ex.x_mult or 2
        card.joker_display_values.x_mult = count > 0 and (mult_per ^ count) or 1.0
        card.joker_display_values.active = count > 0
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        if not JokerDisplay.in_scoring(playing_card, scoring_hand) then return 0 end
        local has_seal = (playing_card.seal ~= nil and playing_card.seal ~= '')
        local has_ed = (playing_card.edition ~= nil and not playing_card.edition.base)
        local reps = (has_seal and 1 or 0) + (has_ed and 1 or 0)
        return reps * JokerDisplay.calculate_joker_triggers(joker_card)
    end
}

jd_def["j_reality_warp_callie"] = {
    text = {
        { text = "Random Upgrade", colour = G.C.GOLD }
    },
    reminder_text = {
        { text = "(1x per card)" }
    }
}

jd_def["j_reality_warp_sally"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "trivia_status" }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "reward_str" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local cur_q = ex.current_question
        local reward = cur_q and cur_q.reward or 5
        if ex.question_answered then
            card.joker_display_values.trivia_status = "Answered!"
            card.joker_display_values.reward_str = "(Next Blind)"
        else
            card.joker_display_values.trivia_status = "Trivia Pending"
            card.joker_display_values.reward_str = "(Reward: +$" .. tostring(reward) .. ")"
        end
    end
}

jd_def["j_reality_warp_brainprint"] = {
    text = {
        { text = "Copies Left & Right", colour = G.C.BLUE }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "copy_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local left_name = "None"
        local right_name = "None"
        if G.jokers and G.jokers.cards then
            local my_idx = nil
            for idx, j in ipairs(G.jokers.cards) do
                if j == card then my_idx = idx; break end
            end
            if my_idx then
                local lj = (my_idx > 1) and G.jokers.cards[my_idx - 1]
                local rj = (my_idx < #G.jokers.cards) and G.jokers.cards[my_idx + 1]
                if lj and lj.config and lj.config.center then
                    left_name = (localize and localize{type = 'name_text', key = lj.config.center.key, set = 'Joker'}) or lj.ability.name or "Left"
                end
                if rj and rj.config and rj.config.center then
                    right_name = (localize and localize{type = 'name_text', key = rj.config.center.key, set = 'Joker'}) or rj.ability.name or "Right"
                end
            end
        end
        card.joker_display_values.copy_str = left_name .. " + " .. right_name
    end
}

jd_def["j_reality_warp_vampiric_midas"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Gold Drain)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
    end
}

jd_def["j_reality_warp_certified_programming"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+2 Cards w/ Seal)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
    end
}

jd_def["j_reality_warp_galactic_traveler"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Free Planets)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.xmult or 1.0
    end
}

jd_def["j_reality_warp_colorful_street"] = {
    text = {
        { text = "4-Card Straights & Flushes", colour = G.C.ATTENTION }
    },
    reminder_text = {
        { text = "(Shortcut + Smeared)" }
    }
}

jd_def["j_reality_warp_mime_king"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Held Kings 2X, Reps +2)" }
    },
    calc_function = function(card)
        local count = 0
        if G.hand and G.hand.cards then
            for _, c in ipairs(G.hand.cards) do
                if not c.highlighted then
                    local id = (c.get_id and c:get_id()) or (c.base and c.base.id)
                    if id == 13 then
                        count = count + 3
                    end
                end
            end
        end
        local ex = card.ability and card.ability.extra or {}
        local mult_per = ex.x_mult or 2
        card.joker_display_values.x_mult = count > 0 and (mult_per ^ count) or 1.0
        card.joker_display_values.active = count > 0
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if not held_in_hand then return 0 end
        return 2 * JokerDisplay.calculate_joker_triggers(joker_card)
    end
}

jd_def["j_reality_warp_photo_album"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT
        }
    },
    reminder_text = {
        { text = "(1st Card +3, Face +1)" }
    },
    calc_function = function(card)
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        local has_face = false
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c.is_face and c:is_face() then
                    has_face = true
                    break
                end
            end
        end
        local xm = (card.ability and card.ability.extra and card.ability.extra.x_mult) or 2.5
        card.joker_display_values.x_mult = has_face and xm or 1.0
        card.joker_display_values.active = has_face
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        local reps = 0
        if playing_card == scoring_hand[1] then
            reps = reps + 3
        end
        if playing_card.is_face and playing_card:is_face() then
            reps = reps + 1
        end
        return reps * JokerDisplay.calculate_joker_triggers(joker_card)
    end
}

jd_def["j_reality_warp_pirate_egg"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+$" },
        { ref_table = "card.joker_display_values", ref_value = "val" },
        { text = " Value)" }
    },
    reminder_text_config = { colour = G.C.MONEY },
    calc_function = function(card)
        local total_sell = 0
        if G.jokers and G.jokers.cards then
            for _, jk in ipairs(G.jokers.cards) do
                total_sell = total_sell + (jk.sell_cost or 1)
            end
        end
        local xm = 1 + total_sell * 0.1
        card.joker_display_values.x_mult = string.format('%.1f', xm)
        card.joker_display_values.val = card.sell_cost or 1
    end
}

jd_def["j_reality_warp_reinforced_boots"] = {
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "chips" },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(Per $1)" }
    },
    calc_function = function(card)
        local dollars = math.max(0, (to_number and to_number(G.GAME and G.GAME.dollars)) or tonumber(G.GAME and G.GAME.dollars) or 0)
        card.joker_display_values.chips = dollars * 5
        card.joker_display_values.mult = dollars * 10
    end
}

jd_def["j_reality_warp_wee_comedian"] = {
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "chips" },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(Fibonacci + 2s)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 0
        local fib_mult = 0
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local id = c:get_id()
                if id == 14 or id == 2 or id == 3 or id == 5 or id == 8 then
                    fib_mult = fib_mult + 16 * JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.mult = fib_mult
    end,
    retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
        if held_in_hand or not scoring_hand then return 0 end
        if playing_card:get_id() == 2 and JokerDisplay.in_scoring(playing_card, scoring_hand) then
            return 2 * JokerDisplay.calculate_joker_triggers(joker_card)
        end
        return 0
    end
}

jd_def["j_reality_warp_golden_lucky_cat"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(+2 Probabilities)" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        card.joker_display_values.x_mult = ex.x_mult or 1.0
    end
}

jd_def["j_reality_warp_unrecognizable_antique"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            },
            border_colour = G.C.XMULT
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "group_str" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = card.ability and card.ability.extra or {}
        local group = ex.suit_group or "Red"
        card.joker_display_values.group_str = (group == 'Red') and "♥ / ♦" or "♠ / ♣"
        local count = 0
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                local match = false
                if group == 'Red' then
                    match = c:is_suit('Hearts') or c:is_suit('Diamonds')
                else
                    match = c:is_suit('Spades') or c:is_suit('Clubs')
                end
                if match then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.x_mult = count > 0 and (2 ^ count) or 1.0
        card.joker_display_values.active = (count > 0)
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.XMULT or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_macabre_emoji"] = {
    text = {
        { text = "+", colour = G.C.CHIPS },
        { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS, retrigger_type = "chips" },
        { text = " +", colour = G.C.MULT },
        { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT, retrigger_type = "mult" }
    },
    reminder_text = {
        { text = "(Face Cards)" }
    },
    calc_function = function(card)
        local count = 0
        local _, _, scoring_hand = JokerDisplay.evaluate_hand()
        if scoring_hand then
            for _, c in ipairs(scoring_hand) do
                if c.is_face and c:is_face() then
                    count = count + JokerDisplay.calculate_card_triggers(c, scoring_hand)
                end
            end
        end
        card.joker_display_values.chips = count * 100
        card.joker_display_values.mult = count * 20
        card.joker_display_values.active = count > 0
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children then
            local col = card.joker_display_values.active and G.C.CHIPS or G.C.UI.TEXT_INACTIVE
            local mcol = card.joker_display_values.active and G.C.MULT or G.C.UI.TEXT_INACTIVE
            if text.children[1] then text.children[1].config.colour = col end
            if text.children[2] then text.children[2].config.colour = col end
            if text.children[3] then text.children[3].config.colour = mcol end
            if text.children[4] then text.children[4].config.colour = mcol end
        end
    end
}

jd_def["j_reality_warp_incremental"] = {
    text = {
        { text = "+" },
        { ref_table = "card.ability.extra", ref_value = "mult", retrigger_type = "mult" }
    },
    text_config = { colour = G.C.MULT },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "next_str" }
    },
    calc_function = function(card)
        local rank_names = { [2]='2', [3]='3', [4]='4', [5]='5', [6]='6', [7]='7', [8]='8', [9]='9', [10]='10', [11]='J', [12]='Q', [13]='K', [14]='A' }
        local nr = (card.ability and card.ability.extra and card.ability.extra.next_rank) or 14
        card.joker_display_values.next_str = "(Next: " .. (rank_names[nr] or 'A') .. ")"
    end
}

jd_def["j_reality_warp_scripter"] = {
    text = {
        { ref_table = "card.joker_display_values", ref_value = "status_text" }
    },
    reminder_text = {
        { text = "(Random Seal)" }
    },
    calc_function = function(card)
        local text, _, _ = JokerDisplay.evaluate_hand()
        if text == 'Flush House' then
            card.joker_display_values.status_text = "Active!"
            card.joker_display_values.active = true
        else
            card.joker_display_values.status_text = "Flush House"
            card.joker_display_values.active = false
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] then
            text.children[1].config.colour = card.joker_display_values.active and G.C.PURPLE or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_ethernet"] = {
    text = {
        {
            border_nodes = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
            }
        }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "status" }
    },
    calc_function = function(card)
        local ex = card.ability.extra or {}
        card.joker_display_values.mult = ex.current_mult or 0
        card.joker_display_values.status = ex.played_this_round and "(Played)" or "(Ready: +10)"
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            local ex = card.ability.extra or {}
            reminder_text.children[1].config.colour = ex.played_this_round and G.C.UI.TEXT_INACTIVE or G.C.BLUE
        end
    end
}

jd_def["j_reality_warp_creepy_shadow"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(Destroys Joker)" }
    }
}

jd_def["j_reality_warp_marina"] = {
    text = {
        { text = "+3 Retriggers", colour = G.C.GREEN }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "reminder_str" }
    },
    calc_function = function(card)
        local t_name = (card.ability and card.ability.extra and card.ability.extra.hacked_target_name) or "Random"
        card.joker_display_values.reminder_str = "(" .. t_name .. ")"
    end
}

jd_def["j_reality_warp_perla"] = {
    text = {
        { text = "+$" },
        { ref_table = "card.joker_display_values", ref_value = "interest" }
    },
    text_config = { colour = G.C.GOLD },
    reminder_text = {
        { text = "(No Interest Cap)" }
    },
    calc_function = function(card)
        local dollars = (G.GAME and G.GAME.dollars) or 0
        local rate = (G.GAME and G.GAME.interest_amount) or 1
        local interest = math.max(0, math.floor(dollars / 5) * rate)
        card.joker_display_values.interest = interest
    end
}

jd_def["j_reality_warp_espectro_del_balance"] = {
    text = {
        { text = "=" },
        { ref_table = "card.joker_display_values", ref_value = "balanced_val" }
    },
    text_config = { colour = G.C.PURPLE },
    reminder_text = {
        { text = "(Chips = Mult)" }
    },
    calc_function = function(card)
        local chips = (hand_chips and hand_chips > 0 and hand_chips) or 0
        local m = (mult and mult > 0 and mult) or 0
        if chips == 0 and m == 0 then
            local text, _, _ = JokerDisplay.evaluate_hand()
            if text ~= 'Unknown' and G.GAME and G.GAME.hands and G.GAME.hands[text] then
                chips = G.GAME.hands[text].chips or 0
                m = G.GAME.hands[text].mult or 0
            end
        end
        local total = chips + m
        card.joker_display_values.balanced_val = math.floor(total / 2)
    end
}

local cross_aliases = {
    ['espectro_del_balance'] = 'balance_spectre',
    ['balance_spectre'] = 'espectro_del_balance',
    ['disenador_joker'] = 'designer_joker',
    ['designer_joker'] = 'disenador_joker',
    ['falta_de_lectura_joker'] = 'reading_deficiency_joker',
    ['reading_deficiency_joker'] = 'falta_de_lectura_joker',
    ['duelo_de_valores_joker'] = 'duel_of_value_joker',
    ['duel_of_value_joker'] = 'duelo_de_valores_joker',
    ['midas_vampirico'] = 'vampiric_midas',
    ['vampiric_midas'] = 'midas_vampirico',
    ['programacion_certificacion'] = 'certified_programming',
    ['certified_programming'] = 'programacion_certificacion',
    ['viajero_galactico'] = 'galactic_traveler',
    ['galactic_traveler'] = 'viajero_galactico',
    ['calle_colorida'] = 'colorful_street',
    ['colorful_street'] = 'calle_colorida',
    ['rey_de_mimos'] = 'mime_king',
    ['mime_king'] = 'rey_de_mimos',
    ['album_de_fotos'] = 'photo_album',
    ['photo_album'] = 'album_de_fotos',
    ['huevo_pirata'] = 'pirate_egg',
    ['pirate_egg'] = 'huevo_pirata',
    ['botas_reforzadas'] = 'reinforced_boots',
    ['reinforced_boots'] = 'botas_reforzadas',
    ['gato_dorado_suerte'] = 'golden_lucky_cat',
    ['golden_lucky_cat'] = 'gato_dorado_suerte',
    ['antiguedad_irreconocible'] = 'unrecognizable_antique',
    ['unrecognizable_antique'] = 'antiguedad_irreconocible',
    ['emoji_macabro'] = 'macabre_emoji',
    ['macabre_emoji'] = 'emoji_macabro',
}

jd_def["j_reality_warp_pachinko"] = {
    text = {
        {
            border_nodes = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "chips", retrigger_type = "chips" }
            }
        },
        {
            border_nodes = {
                { text = " +" },
                { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
            }
        },
        {
            border_nodes = {
                { text = " X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "status" }
    },
    calc_function = function(card)
        local ex = card.ability.extra or {}
        card.joker_display_values.chips = ex.chips or 0
        card.joker_display_values.mult = ex.mult or 0
        card.joker_display_values.x_mult = string.format("%.2f", ex.x_mult or 1.0)
        card.joker_display_values.status = ex.played_this_round and "(Played)" or "(Ready)"
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            local ex = card.ability.extra or {}
            reminder_text.children[1].config.colour = ex.played_this_round and G.C.UI.TEXT_INACTIVE or G.C.GREEN
        end
    end
}

jd_def["j_reality_warp_shell_game"] = {
    text = {
        {
            border_nodes = {
                { text = "+" },
                { ref_table = "card.joker_display_values", ref_value = "mult", retrigger_type = "mult" }
            }
        }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "status" }
    },
    calc_function = function(card)
        local ex = card.ability.extra or {}
        card.joker_display_values.mult = ex.mult or 12
        card.joker_display_values.status = ex.played_this_round and "(Played)" or "(Ready: Acorn)"
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            local ex = card.ability.extra or {}
            reminder_text.children[1].config.colour = ex.played_this_round and G.C.UI.TEXT_INACTIVE or G.C.ORANGE
        end
    end
}

jd_def["j_reality_warp_claw_machine"] = {
    text = {
        { text = "Claw: $2" }
    },
    text_config = { colour = G.C.ORANGE },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "status" }
    },
    calc_function = function(card)
        local ex = card.ability.extra or {}
        card.joker_display_values.status = ex.played_this_round and "(Played)" or "(Ready: Surprise)"
    end,
    style_function = function(card, text, reminder_text, extra)
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            local ex = card.ability.extra or {}
            reminder_text.children[1].config.colour = ex.played_this_round and G.C.UI.TEXT_INACTIVE or G.C.GREEN
        end
    end
}

jd_def["j_reality_warp_top_fuel_dragster"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "timing_status" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        local t = ex.timer or 20
        if ex.perfect_launch == true then
            card.joker_display_values.x_mult = ex.x_mult_perfect or 10
            card.joker_display_values.timing_status = "(PERFECT!)"
        elseif ex.perfect_launch == false then
            card.joker_display_values.x_mult = ex.x_mult_normal or 3
            card.joker_display_values.timing_status = "(Late/Early)"
        elseif ex.active then
            if t > 0.05 then
                card.joker_display_values.x_mult = ex.x_mult_normal or 3
                card.joker_display_values.timing_status = string.format("(%.1fs)", math.max(0, t))
            elseif t >= -0.10 then
                card.joker_display_values.x_mult = ex.x_mult_perfect or 10
                card.joker_display_values.timing_status = "(LAUNCH!)"
            else
                card.joker_display_values.x_mult = ex.x_mult_normal or 3
                card.joker_display_values.timing_status = string.format("(Late: +%.1fs)", math.abs(t))
            end
        else
            card.joker_display_values.x_mult = ex.x_mult_normal or 3
            card.joker_display_values.timing_status = "(Ready: 20s)"
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] and text.children[1].children and text.children[1].children[2] then
            local is_perfect = (card.joker_display_values.x_mult or 3) >= 10
            text.children[1].children[2].config.colour = is_perfect and G.C.GREEN or G.C.MULT
        end
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            local is_launch = card.joker_display_values.timing_status == "(LAUNCH!)" or card.joker_display_values.timing_status == "(PERFECT!)"
            reminder_text.children[1].config.colour = is_launch and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end
}

jd_def["j_reality_warp_top_fuel_funny_car"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_chips", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { ref_table = "card.joker_display_values", ref_value = "timing_status" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        local t = ex.timer or 20
        if ex.perfect_launch == true then
            card.joker_display_values.x_chips = ex.x_chips_perfect or 10
            card.joker_display_values.timing_status = "(PERFECT!)"
        elseif ex.perfect_launch == false then
            card.joker_display_values.x_chips = ex.x_chips_normal or 4
            card.joker_display_values.timing_status = "(Late/Early)"
        elseif ex.active then
            if t > 0.05 then
                card.joker_display_values.x_chips = ex.x_chips_normal or 4
                card.joker_display_values.timing_status = string.format("(%.1fs)", math.max(0, t))
            elseif t >= -0.10 then
                card.joker_display_values.x_chips = ex.x_chips_perfect or 10
                card.joker_display_values.timing_status = "(LAUNCH!)"
            else
                card.joker_display_values.x_chips = ex.x_chips_normal or 4
                card.joker_display_values.timing_status = string.format("(Late: +%.1fs)", math.abs(t))
            end
        else
            card.joker_display_values.x_chips = ex.x_chips_normal or 4
            card.joker_display_values.timing_status = "(Ready: 20s)"
        end
    end,
    style_function = function(card, text, reminder_text, extra)
        if text and text.children and text.children[1] and text.children[1].children and text.children[1].children[2] then
            local is_perfect = (card.joker_display_values.x_chips or 4) >= 10
            text.children[1].children[2].config.colour = is_perfect and G.C.GREEN or G.C.CHIPS
        end
        if reminder_text and reminder_text.children and reminder_text.children[1] then
            local is_launch = card.joker_display_values.timing_status == "(LAUNCH!)" or card.joker_display_values.timing_status == "(PERFECT!)"
            reminder_text.children[1].config.colour = is_launch and G.C.GREEN or G.C.UI.TEXT_INACTIVE
        end
    end
}


jd_def["j_reality_warp_mew_mew"] = {
    text = {
        {
            border_nodes = {
                { text = "X" },
                { ref_table = "card.joker_display_values", ref_value = "x_mult", retrigger_type = "exp" }
            }
        }
    },
    reminder_text = {
        { text = "(" },
        { ref_table = "card.joker_display_values", ref_value = "target_hand" },
        { text = ")" }
    },
    calc_function = function(card)
        local ex = (card.ability and card.ability.extra) or {}
        card.joker_display_values.x_mult = ex.xmult or 1.5
        card.joker_display_values.target_hand = tostring(ex.target_hand or 'Pair')
    end
}

jd_def["j_reality_warp_astral_calamity"] = jd_def["j_reality_warp_astra"]

jd_def["j_reality_warp_mad_ghost"] = {
    reminder_text = {
        { text = "(Companion)" }
    }
}

jd_def["j_reality_warp_maestro"] = {
    text = {
        { text = "+1 Ghost Joker" }
    },
    text_config = { colour = G.C.DARK_EDITION },
    reminder_text = {
        { text = "(On Boss Blind)" }
    }
}

local new_entries = {}
for k, v in pairs(jd_def) do
    if string.sub(k, 1, 15) == "j_reality_warp_" then
        local raw = string.sub(k, 16)
        new_entries["j_" .. raw] = v
        new_entries["j_reality_warp_" .. raw] = v
        new_entries[raw] = v
        if cross_aliases[raw] then
            local target = cross_aliases[raw]
            new_entries["j_reality_warp_" .. target] = v
            new_entries["j_reality_warp_" .. target] = v
            new_entries["j_" .. target] = v
            new_entries[target] = v
        end
    end
end
for k, v in pairs(new_entries) do
    if not jd_def[k] then
        jd_def[k] = v
    end
end


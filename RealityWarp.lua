--[[
    Balatro: Reality Warp
    Version: 1.0.0
    Author: Unknow102
    Framework: Steamodded (SMODS)

    "Reality warps around the cards. Step into the rift."
--]]

reality_warp_MOD = SMODS.current_mod
if reality_warp_MOD then
    reality_warp_MOD.name = "Balatro: Reality Warp"
    reality_warp_MOD.display_name = "Balatro: Reality Warp"
    reality_warp_MOD.badge_name = "Reality Warp"

    G.C.reality_warp_BADGE_COL = G.C.reality_warp_BADGE_COL or { 0, 0, 0, 1 }
    G.C.reality_warp_TEXT_COL = G.C.reality_warp_TEXT_COL or { 1, 1, 1, 1 }
    reality_warp_MOD.badge_colour = G.C.reality_warp_BADGE_COL
    reality_warp_MOD.badge_text_colour = G.C.reality_warp_TEXT_COL

    reality_warp_MOD.custom_collection_tabs = function()
        local pool = (G.P_CENTER_POOLS and G.P_CENTER_POOLS['Familiar']) or {}
        local count = #pool > 0 and #pool or 28
        return {
            UIBox_button({
                button = "your_collection_familiars",
                label = {localize("b_familiar_cards") or "Familiars"},
                count = { tally = count, of = count },
                minw = 5,
                id = "your_collection_familiars",
                colour = HEX('8B0000')
            })
        }
    end
end

local files = {
    -- Core & Engine Hooks
    "src/core/blind_identity.lua",
    "src/core/blind_encounters.lua",
    "src/core/blind_effects.lua",
    "src/core/blind_targets.lua",
    "src/core/joker_effects.lua",
    "src/core/draw_rules.lua",
    "src/core/edition_rules.lua",
    "src/core/utils.lua",
    "src/core/localization.lua",
    "src/core/battle_of_gods.lua",
    "src/core/botg_possession.lua",
    "src/core/botg_familiars.lua",
    "src/core/botg_combat.lua",
    "src/core/probability_rules.lua",
    "src/core/black_market.lua",
    "src/core/cauldron_synthesis.lua",
    "src/core/other_modes.lua",
    "src/core/apagon.lua",

    -- Jokers
    "src/jokers/common.lua",
    "src/jokers/uncommon.lua",
    "src/jokers/rare.lua",
    "src/jokers/legendary.lua",
    "src/jokers/secret.lua",


    -- Consumables, Enhancements & Seals
    "src/consumables/spectrals.lua",
    "src/consumables/enhancements.lua",
    "src/consumables/jobs.lua",
    "src/consumables/potions.lua",


    -- Blinds, Decks, Vouchers & Tags
    "src/blinds/boss_blinds.lua",
    "src/blinds/fused_blinds.lua",
    "src/decks/decks.lua",
    "src/vouchers/vouchers.lua",
    "src/tags/tags.lua",
    "src/stakes/stakes.lua",

    -- Mod Compatibility
    "src/compat/jokerdisplay.lua",
    "src/compat/cardsleeves.lua",

    -- Challenges
    "src/challenges/challenges.lua",
    "src/challenges/outsider_trials.lua"
}

for _, file in ipairs(files) do
    assert(SMODS.load_file(file))()
end

if alias_all_reality_warp_centers then
    alias_all_reality_warp_centers()
end
                                                        
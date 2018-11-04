local _, iterator = nil, nil
-- Spec and Class Abilities
    local backstab = 53
    local blind = 2094
    local cheap_shot = 1833
    local cloak_of_shadows = 31224
    local crimson_vial = 185311
    local distract = 1725
    local evasion = 5277
    local eviscerate = 196819
    local feint = 1966
    local kick = 1766
    local kidney_shot = 408
    local nightblade = 195452
    local pick_lock = 1804
    local pick_pocket = 921
    local sap = 0
    local shadow_blades = 121471
    local shadow_dance = 185313
    local shadow_dance_buff = 185422
    local shadowstep = 36554
    local shadowstrike = 185438
    local shroud_of_concealment = 114018
    local shuriken_storm = 197835
    local shuriken_toss = 114014
    local sprint = 2983
    local stealth = 1784
    local symbols_of_death = 212283
    local tricks_of_the_trade = 0
    local vanish = 1856
    local vanish_buff = 11327
    local shadows_grasp = 206760
    local shuriken_combo = 245640

-- Talents
    local find_weakness = 91021
    local gloomblade = 122 -- (or talent 19235?)
    local marked_for_death = 137619 -- (or talent 19241?)
    local marked_for_death_debuff = 137619
    local cheat_death = -math.huge
    local shot_in_the_dark = 257506
    local prey_on_the_weak = 255909
    local alacrity = 193538
    local master_of_shadows = 196980
    local secret_technique = 280719 -- (or talent 23183?)
    local shuriken_tornado = 277925 -- (or talent 21188?)

-- Azerite Power Spell IDs
    local blade_in_the_shadows = 279754
    local footpad = 274695
    local nights_vengeance = 273424
    local perforate = 277720
    local sharpened_blades = 272916
    local shrouded_mantle = 280200

local precombat, actions, build, cds, finish, stealth_cds, stealthed
local stealth_threshold, shd_threshold = 0, 0

G1NM.ROGUE = G1NM.ROGUE or {}
G1NM.ROGUE.settingsTable = G1NM.ROGUE.settingsTable or {
    name = "ROGUE Settings",
    order = 2,
    type = "group",
    childGroups = "tab",
    hidden = function() return G1NMData[G1NM.playerFullName].class ~= "ROGUE" end,
    args = {
        -- queueList = {
        --     order = 0,
        --     name = "Queue List:",
        --     type = "description",
        -- },
        generalSettings = {
            name = "ROGUE General Settings",
            order = 1,
            -- hidden = true,
            type = "group",
            args = {
                -- OoC Stuff
                OoCOptions = {
                    name = "Out of Combat Options",
                    order = 0,
                    type = "description",
                    fontSize = "large",
                },
                AutoStealth = {
                    name = "Auto Stealth",
                    disabled = true,
                    desc = "Auto Stealth X Seconds after Combat Ends. Type -1 in the box to disable.",
                    order = 1,
                    type = "range",
                    min = -1,
                    max = 60,
                    softMin = 0,
                    softMax = 5,
                    step = 1,
                    get = function(i, v) return G1NMData[G1NM.playerFullName].rogueAutoStealth end,
                    set = function(i, v) G1NM.saveSetting("rogueAutoStealth", v) end,
                },
                AutoPull = {
                    name = "Auto Pull From Stealth and Melee Range",
                    disabled = true,
                    desc = "Use Garrote, Ambush, and Shadowstrike from Stealth",
                    order = 2,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].rogueAutoPull end,
                    set = function(i, v) G1NM.saveSetting("rogueAutoPull", v) end,
                },
                AutoPickPocket = {
                    name = "Auto Pick Pocket",
                    disabled = true,
                    desc = "Pick Pocket mobs automatically",
                    order = 3,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].rogueAutoPickPocket end,
                    set = function(i, v) G1NM.saveSetting("rogueAutoPickPocket", v) end,
                },
                SapPickPocket = {
                    name = "Sap after Pick Pocket",
                    disabled = true,
                    desc = "Sap mobs after you pick pocket them",
                    order = 4,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].rogueAutoPickPocketSap end,
                    set = function(i, v) G1NM.saveSetting("rogueAutoPickPocketSap", v) end,
                },
                CombatOptions = {
                    name = "\nCombat Options",
                    order = 100,
                    type = "description",
                    fontSize = "large",
                },
                TricksOfTheTrade = {
                    name = "Auto Tricks of the Trade",
                    disabled = true,
                    desc = "In dungeons will be used on tank automatically, in raids and PvP will be used on your focus target.",
                    order = 101,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].rogueAutoTricksTrade end,
                    set = function(i, v) G1NM.saveSetting("rogueAutoTricksTrade", v) end,
                },
                MarkedForDeathMode = {
                    name = "Marked for Death Adds Only",
                    disabled = true,
                    desc = "Only use Marked for Death on non-bosses.",
                    order = 102,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].rogueMFDAddsOnly end,
                    set = function(i, v) G1NM.saveSetting("rogueMFDAddsOnly", v) end,
                },
                QueueSystem = {
                    name = "\nQueue System",
                    order = 200,
                    type = "description",
                    fontSize = "large",
                },
                Blind = {
                    name = "Blind",
                    order = 201,
                    disabled = true,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].queue2094 end,
                    set = function(i, v) G1NM.saveSetting("queue2094", v) end
                },
                CheapShot = {
                    name = "Cheap Shot",
                    order = 202,
                    disabled = true,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].queue1833 end,
                    set = function(i, v) G1NM.saveSetting("queue1833", v) end
                },
                CrimsonVial = {
                    name = "Crimson Vial",
                    order = 203,
                    disabled = true,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].queue185311 end,
                    set = function(i, v) G1NM.saveSetting("queue185311", v) end
                },
                Feint = {
                    name = "Feint",
                    order = 204,
                    disabled = true,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].queue1966 end,
                    set = function(i, v) G1NM.saveSetting("queue1966", v) end
                },
                KidneyShot = {
                    name = "Kidney Shot",
                    order = 205,
                    disabled = true,
                    type = "toggle",
                    get = function(i, v) return G1NMData[G1NM.playerFullName].queue408 end,
                    set = function(i, v) G1NM.saveSetting("queue408", v) end
                },
            },
        },
        assassSettings = {
            name = "Assassination Settings",
            order = 2,
            hidden = true,
            type = "group",
            args = {},
        },
        outlawSettings = {
            name = "Outlaw Settings",
            order = 3,
            hidden = true,
            type = "group",
            args = {},
        },
        subtletySettings = {
            name = "Subtlety  Settings",
            order = 4,
            type = "group",
            args = {},
        },
    }
}

G1NM.ROGUE.settingsTable.args.subtletySettings.args = {
    CombatOptions = {
        name = "Combat Options",
        fontSize = "large",
        order = 0,
        type = "description"
    },
    Opener = {
        name = "Opener",
        type = "toggle",
        disabled = true,
        order = 1,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyOpener end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyOpener", v) end
    },
    NightBladeMax = {
        name = "Nightblade Maximum Targets",
        desc = "Maximum amount of mobs to put nightblade on. (Target will always bypass this)",
        disabled = true,
        type = "range",
        min = 1,
        max = 10,
        softMin = 1,
        softMax = 10,
        step = 1,
        order = 2,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyNightbladeMaxTargets end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyNightbladeMaxTargets", v) end,
    },
    NightBladeMin = {
        name = "Nightblade Minimum HP (100ks)",
        desc = "Minimum amount of MaxHP for to use nightblade on a mob",
        disabled = true,
        type = "range",
        min = 1,
        max = 10000,
        softMin = 1,
        softMax = 10000,
        step = 1,
        order = 3,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyNightbladeMinHP end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyNightbladeMinHP", v) end,
    },
    SymbolsCDs = {
        name = "Symbols CDs Toggle",
        desc = "Tie Symbols of Death to CDs Toggle",
        disabled = true,
        type = "toggle",
        order = 4,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletySymbolsCDs end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletySymbolsCDs", v) end,
    },
    DanceCDs = {
        name = "Dance CDs Toggle",
        desc = "Tie Shadow Dance to CDs Toggle",
        disabled = true,
        type = "toggle",
        order = 5,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyDanceCDs end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyDanceCDs", v) end,
    },
    OptimizeShadowTechniques = {
        name = "Optimize Shadow Techniques",
        disabled = true,
        type = "toggle",
        order = 1.1,
        get = function(i, v) return G1NMData[G1NM.playerFullName].rogueSubtletyOptimizeTechniques end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyOptimizeTechniques", v) end,
    },
    AllToggles = {
        name = "\nAll Toggles\nYou turn these off at your own risk.",
        type = "description",
        fontSize = "large",
    },
    Fireblood = {
        name = "Fireblood",
        disabled = true,
        type = "toggle",
        order = 101,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyFireblood end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyFireblood", v) end,
    },
    LightsJudgment = {
        name = "Light's Judgment",
        disabled = true,
        type = "toggle",
        order = 102,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyLightsJudgment end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyLightsJudgment", v) end,
    },
    Shadowmeld = {
        name = "Shadowmeld",
        disabled = true,
        type = "toggle",
        order = 103,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyShadowmeld end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyShadowmeld", v) end,
    },
    ArcaneTorrent = {
        name = "Arcane Torrent",
        disabled = true,
        type = "toggle",
        order = 104,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyArcaneTorrent end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyArcaneTorrent", v) end,
    },
    RocketBarrage = {
        name = "Rocket Barrage",
        disabled = true,
        type = "toggle",
        order = 105,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyRocketBarrage end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyRocketBarrage", v) end,
    },
    AncestralCall = {
        name = "Ancestral Call",
        disabled = true,
        type = "toggle",
        order = 106,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyAncestralCall end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyAncestralCall", v) end,
    },
    ArcanePulse = {
        name = "Arcane Pulse",
        disabled = true,
        type = "toggle",
        order = 107,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyArcanePulse end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyArcanePulse", v) end,
    },
    BloodFury = {
        name = "Blood Fury",
        disabled = true,
        type = "toggle",
        order = 108,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyBloodFury end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyBloodFury", v) end,
    },
    Berserking = {
        name = "Berserking",
        disabled = true,
        type = "toggle",
        order = 109,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyBerserking end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyBerserking", v) end,
    },
    MydasTalisman = {
        name = "My'das Talisman",
        disabled = true,
        type = "toggle",
        order = 110,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyMydasTalisman end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyMydasTalisman", v) end,
    },
    InventoryItemUse = {
        name = "Generic Item Use",
        disabled = true,
        type = "toggle",
        order = 111,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyInventoryItemUse end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyInventoryItemUse", v) end,
    },
    ShadowDance = {
        name = "Shadow Dance",
        disabled = true,
        type = "toggle",
        order = 112,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyShadowDance end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyShadowDance", v) end,
    },
    SymbolsOfDeath = {
        name = "Symbols of Death",
        disabled = true,
        type = "toggle",
        order = 113,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletySymbolsOfDeath end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletySymbolsOfDeath", v) end,
    },
    ShurikenToss = {
        name = "Shuriken Toss",
        disabled = true,
        type = "toggle",
        order = 114,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyShurikenToss end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyShurikenToss", v) end,
    },
    Vanish = {
        name = "Vanish",
        disabled = true,
        type = "toggle",
        order = 115,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyVanish end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyVanish", v) end,
    },
    ShadowBlades = {
        name = "Shadow Blades",
        disabled = true,
        type = "toggle",
        order = 116,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyShadowBlades end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyShadowBlades", v) end,
    },
    MarkedForDeath = {
        name = "Marked for Death",
        disabled = true,
        type = "toggle",
        order = 117,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyMarkedForDeath end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyMarkedForDeath", v) end,
    },
    SecretTechnique = {
        name = "Secret Technique",
        disabled = true,
        type = "toggle",
        order = 118,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletySecretTechnique end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletySecretTechnique", v) end,
    },
    ShurikenTornado = {
        name = "Shuriken Tornado",
        disabled = true,
        type = "toggle",
        order = 119,
        get = function() return G1NMData[G1NM.playerFullName].rogueSubtletyShurikenTornado end,
        set = function(i, v) G1NM.saveSetting("rogueSubtletyShurikenTornado", v) end,
    },
}

local subCO
local function waitForShadowDanceBuff()
    local iteration = 0
    while (not G1NM.isStealthed("player", "all")) do
        iteration = iteration + 1
        if not G1NM.spellCDIsntReady(185438) then G1NM.cast(_, shadow_dance) end
        coroutine.yield()
    end
    while (G1NM.lastCast ~= shadowstrike and G1NM.lastCast ~= shuriken_storm) do
        iteration = iteration + 1
        if not G1NM.aoe or G1NM.playerCount(10, _, 2, "<=") or not G1NM.talent32 and G1NM.azeritePowerRank(240) >= 3 and G1NM.playerCount(10, _, 3, "==") then G1NM.cast(_, shadowstrike) elseif G1NM.aoe and G1NM.playerCount(10, _, 3, ">=") then G1NM.cast(_, shuriken_storm) end
        coroutine.yield()
    end
end

-- ooc mfd
-- ooc sb

precombat = function()
    -- actions.precombat+=/stealth
    -- actions.precombat+=/marked_for_death,precombat_seconds=15
    -- actions.precombat+=/shadow_blades,precombat_seconds=1
    -- actions.precombat+=/potion
end

function G1NM.ROGUE3()
    if type(subCO) == "thread" and coroutine.status(subCO) ~= "dead" then
        coroutine.resume(subCO)
        return
    end
    if UnitAffectingCombat("player") then
        -- G1NM.multiDoT(nightblade)
        if G1NM.validAnimal() then
            cds()
            if G1NM.isStealthed(_, "all") then stealthed() return end
            if G1NM.spellCanAttack(nightblade) and G1NM.getTTD() > 6 and G1NM.auraRemaining("target", nightblade, G1NM.globalCD(), "PLAYER") and G1NM.cp() >= 4 - (GetTime()-G1NM.combatStartTime < 10 and 1 or 0)*2 then G1NM.cast(_, nightblade) return end
            stealth_threshold = 25 + (G1NM.talent31 and 1 or 0)*35 + (G1NM.talent71 and 1 or 0)*25 + (G1NM.talent23 and 1 or 0)*20 + (G1NM.talent62 and 1 or 0)*10 + 15*(G1NM.aoe and G1NM.playerCount(10, _, 3, ">=") and 1 or 0)
            if G1NM.pp("deficit") <= stealth_threshold and G1NM.cp("deficit") >= 4 then stealth_cds() end
            if G1NM.pp("deficit") <= stealth_threshold and G1NM.talent61 and G1NM.talent72 and G1NM.spellIsReady(secret_technique) then stealth_cds() end
            if G1NM.pp("deficit") <= stealth_threshold and G1NM.talent61 and not G1NM.talent72 and G1NM.aoe and G1NM.playerCount(10, _, 2, ">=") and (not G1NM.talent73 or G1NM.spellCDIsntReady(shuriken_tornado)) then stealth_cds() end
            if G1NM.cp("deficit") <= 1 or G1NM.getTTD() <= 1 and G1NM.getTTD() ~= -math.huge and G1NM.cp() >= 3 then finish() end
            if G1NM.aoe and G1NM.playerCount(10, _, 4, "==", _) and G1NM.cp() >= 4 then finish() end
            if G1NM.pp("deficit") <= stealth_threshold then build() end
            if G1NM.cds and G1NMData[G1NM.playerFullName].race == "BloodElf" and G1NM.spellIsReady(25046) and G1NM.pp("deficit") >= 15 + GetPowerRegen() then G1NM.cast(_, 25046) return end
            -- actions+=/arcane_pulse
            -- actions+=/lights_judgment
        end
    else
        if G1NM.getSetting("rogueAutoStealth") ~= -1 and G1NM.spellIsReady(stealth) and not IsStealthed() and (GetTime()-G1NM.combatEndTime) > G1NM.getSetting("rogueAutoStealth") then G1NM.cast(_, stealth) return end
        if G1NM.getSetting("rogueAutoPull") and IsStealthed() and G1NM.spellCanAttack(shadowstrike) and G1NM.distanceBetween("target") <= 5 then G1NM.cast(_, shadowstrike) return end
    end
end

build = function()
    if G1NM.spellCanAttack(shuriken_toss) and not G1NM.talent21 and (not G1NM.talent61 or G1NM.spellCDDuration(symbols_of_death) > 10) and G1NM.auraStacks("player", sharpened_blades, 29) and (not G1NM.aoe or G1NM.playerCount(10, _, (3*G1NM.azeritePowerRank(124)), "<=")) then G1NM.cast(_, shuriken_toss) return end
    if G1NM.aoe and G1NM.spellIsReady(shuriken_storm) and G1NM.playerCount(10, _, 2, ">=") then G1NM.cast(_, shuriken_storm, _, _, _, _, _) return end
    if G1NM.talent13 and G1NM.spellCanAttack(gloomblade) then G1NM.cast(_, gloomblade) return end
    if not G1NM.talent13 and G1NM.spellCanAttack(backstab) then if type(subCO) == "thread" and coroutine.status(subCO) ~= "dead" then return end; G1NM.cast(_, backstab) return end
end

cds = function()
    -- cds -> add_action( potion_action );
    -- std::string potion_action = "potion,if=buff.bloodlust.react|buff.symbols_of_death.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=10)";
    --actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.symbols_of_death.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=10)

    -- cds -> add_action( "use_item,name=mydas_talisman", "Use on cooldown." );

    -- for ( size_t i = 0; i < items.size(); i++ ) cds -> add_action( "use_item,name=" + items[i].name_str + ",if=buff.symbols_of_death.up|target.time_to_die<20", "Falling back to default item usage: Use with Symbols of Death." );
    
    -- for ( size_t i = 0; i < racial_actions.size(); i++ )
    -- {
    --   if ( racial_actions[i] == "lights_judgment" || racial_actions[i] == "arcane_torrent" )
    --     continue; // Manually added
    --   else
    --     cds -> add_action( racial_actions[i] + ",if=buff.symbols_of_death.up" );
    -- }
    --actions.cds+=/blood_fury,if=buff.symbols_of_death.up
    --actions.cds+=/berserking,if=buff.symbols_of_death.up
    --actions.cds+=/fireblood,if=buff.symbols_of_death.up
    --actions.cds+=/ancestral_call,if=buff.symbols_of_death.up
    
    if G1NM.spellIsReady(shadow_dance) and not G1NM.aura("player", shadow_dance_buff) and G1NM.aura("player", shuriken_tornado) and G1NM.auraRemaining("player", shuriken_tornado, 3.5) then subCO = coroutine.create(waitForShadowDanceBuff)--[[; G1NM.cast(_, shadow_dance)]] return end
    if G1NM.spellIsReady(symbols_of_death) and G1NM.aura("player", shuriken_tornado) and G1NM.auraRemaining("player", shuriken_tornado, 3.5) then G1NM.cast(_, symbols_of_death) return end
    if G1NM.spellIsReady(symbols_of_death) and G1NM.aura("target", nightblade, "PLAYER") and (not G1NM.talent73 or G1NM.talent23 or not G1NM.aoe or G1NM.playerCount(10, _, 3, "<") or G1NM.spellCDIsntReady(shuriken_tornado)) then G1NM.cast(_, symbols_of_death) return end
    
    -- cds -> add_talent( this, "Marked for Death", "target_if=min:target.time_to_die,if=raid_event.adds.up&(target.time_to_die<combo_points.deficit|!stealthed.all&combo_points.deficit>=cp_max_spend)", "If adds are up, snipe the one with lowest TTD. Use when dying faster than CP deficit or not stealthed without any CP." );
    -- cds -> add_talent( this, "Marked for Death", "if=raid_event.adds.in>30-raid_event.adds.duration&!stealthed.all&combo_points.deficit>=cp_max_spend", "If no adds will die within the next 30s, use MfD on boss without any CP and no stealth." );

    if G1NM.cds and G1NM.spellIsReady(shadow_blades) and G1NM.cp("deficit") >= 2 + (G1NM.isStealthed("player", "all") and 1 or 0) then G1NM.cast(_, shadow_blades) return end
    if G1NM.talent73 and G1NM.spellIsReady(shuriken_tornado) and G1NM.aoe and G1NM.playerCount(10, _, 3, ">=") and not G1NM.talent23 and G1NM.aura("target", nightblade, "PLAYER") and not G1NM.isStealthed("player", "all") and G1NM.spellIsReady(symbols_of_death) and GetSpellCharges(shadow_dance) >= 1 then G1NM.cast(_, shuriken_tornado) return end
    if G1NM.talent73 and G1NM.spellIsReady(shuriken_tornado) and G1NM.aoe and G1NM.playerCount(10, _, 3, ">=") and G1NM.talent23 and G1NM.aura("target", nightblade, "PLAYER") and G1NM.aura("player", symbols_of_death) then G1NM.cast(_, shuriken_tornado) return end
    if G1NM.spellIsReady(shadow_dance) and not G1NM.aura("player", shadow_dance_buff) and G1NM.getTTD() <= 5 + (G1NM.talent22 and 1 or 0) and G1NM.getTTD() ~= -math.huge --[[and not raid_event.adds.up]] then subCO = coroutine.create(waitForShadowDanceBuff)--[[; G1NM.cast(_, shadow_dance)]] return end
end

finish = function()
    if G1NM.spellCanAttack(eviscerate) and G1NM.talent23 and G1NM.aura("player", nights_vengeance) and G1NM.aoe and G1NM.playerCount(10, _, (2 + 3*(G1NM.talent72 and 1 or 0)), ">=") then G1NM.cast(_, eviscerate, _, _, _, _, _) return end
    if G1NM.spellCanAttack(nightblade, "target") and (not G1NM.talent61 or not G1NM.aura("player", shadow_dance_buff)) and G1NM.getTTD() - G1NM.buffRemaining("target", nightblade, "PLAYER") > 6 and G1NM.auraRemaining("target", nightblade, (2*G1NM.simCSpellHaste()*2), "PLAYER") and (not G1NM.aoe or G1NM.playerCount(10, _, 4, "<") or not G1NM.aura("player", symbols_of_death)) then G1NM.cast(_, nightblade) return end
    if G1NM.aoe and G1NM.spellIsReady(nightblade) and G1NM.playerCount(10, _, 2, ">=") and (G1NM.talent72 or G1NM.azeritePowerLearned(175) or G1NM.playerCount(10, _, 5, "<=")) and not G1NM.aura("player", shadow_dance_buff) then
        for i = 1, #G1NM.targetAnimals do
            iterator = G1NM.targetAnimals[i]
            if not UnitIsUnit(iterator, "target") and G1NM.spellCanAttack(nightblade, iterator) and G1NM.getTTD(iterator) >= (5 + (2*G1NM.cp())) and G1NM.auraRemaining(iterator, nightblade, (6+2*G1NM.cp())*.3, "PLAYER") then G1NM.cast(iterator, nightblade) return end
        end
    end
    if G1NM.spellCanAttack(nightblade) and G1NM.auraRemaining("target", nightblade, G1NM.spellCDDuration(symbols_of_death)+10, "PLAYER") and G1NM.spellCDDuration(symbols_of_death) <= 5 and G1NM.getTTD() - G1NM.buffRemaining("target", nightblade, "PLAYER") > G1NM.spellCDDuration(symbols_of_death) + 5 then G1NM.cast(_, nightblade) return end
    if G1NM.talent72 and G1NM.spellCanAttack(secret_technique, _, _, _) and G1NM.aura("player", symbols_of_death) and (not G1NM.talent61 or G1NM.aura("player", shadow_dance_buff)) then G1NM.cast(_, secret_technique, _, _, _, _, _) return end
    if G1NM.aoe and G1NM.talent72 and G1NM.spellCanAttack(secret_technique, _, _, _) and G1NM.targetCount("target", 10, _, (2 + (G1NM.talent61 and 1 or 0) + (G1NM.talent21 and 1 or 0)), ">=") then G1NM.cast(_, secret_technique, _, _, _, _, _) return end
    if G1NM.spellCanAttack(eviscerate) then G1NM.cast(_, eviscerate) return end
end

stealth_cds = function()

    shd_threshold = G1NM.fracCalc(shadow_dance) >= 1.75
    if G1NM.cds and G1NM.spellIsReady(vanish) and G1NM.stealthAggroCheck() and not shd_threshold and G1NM.auraRemaining("target", find_weakness, 1, "PLAYER") and G1NM.cp("deficit") > 1 then G1NM.cast(_, vanish) return end
    -- stealth_cds -> add_action( "pool_resource,for_next=1,extra_amount=40", "Pool for Shadowmeld + Shadowstrike unless we are about to cap on Dance charges. Only when Find Weakness is about to run out." );
    -- stealth_cds -> add_action( "shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1&combo_points.deficit>1" );
    if G1NM.spellIsReady(shadow_dance) and (not G1NM.talent61 or not G1NM.auraRemaining("target", nightblade, (5 + (G1NM.talent22 and 1 or 0)), "PLAYER")) and (shd_threshold or not G1NM.auraRemaining("player", symbols_of_death, 1.2) or G1NM.aoe and G1NM.playerCount(10, _, 4, ">=") and G1NM.spellCDDuration(symbols_of_death) > 10) then subCO = coroutine.create(waitForShadowDanceBuff)--[[; G1NM.cast(_, shadow_dance)]] return end
    if G1NM.spellIsReady(shadow_dance) and G1NM.getTTD() < G1NM.spellCDDuration(symbols_of_death) and G1NM.getTTD() ~= -math.huge and G1NM.animalIsBoss() --[[and !raid_event.adds.up]] then subCO = coroutine.create(waitForShadowDanceBuff)--[[; G1NM.cast(_, shadow_dance)]] return end
end

stealthed = function()
    if G1NM.spellCanAttack(shadowstrike) and G1NM.aura("player", stealth) then G1NM.cast(_, shadowstrike) return end
    if G1NM.cp("deficit") <= 1 - (G1NM.talent32 and G1NM.aura("player", vanish_buff) and 1 or 0) then finish() end
    if G1NM.spellCanAttack(shuriken_toss, _, _, _) and G1NM.auraStacks("player", sharpened_blades, 29) and (not G1NM.talent12 or G1NM.aura("target", find_weakness, "PLAYER")) then G1NM.cast(_, shuriken_toss, _, _, _, _, _) return end
    if G1NM.aoe and G1NM.spellIsReady(shadowstrike) and G1NM.talent72 and G1NM.talent12 and G1NM.playerCount(10, _, 2, "==") then
        for i = 1, #G1NM.targetAnimals do
            iterator = G1NM.targetAnimals[i]
            if G1NM.spellCanAttack(shadowstrike, iterator) and G1NM.auraRemaining(iterator, find_weakness, 1, "PLAYER") and G1NM.getTTD(iterator) - G1NM.buffRemaining(iterator, find_weakness, "PLAYER") > 6 then G1NM.cast(iterator, shadowstrike) return end
        end
    end
    if G1NM.aoe and G1NM.spellCanAttack(shadowstrike) and not G1NM.talent32 and G1NM.azeritePowerRank(240) >= 3 and G1NM.playerCount(10, _, 3, "==") then G1NM.cast(_, shadowstrike) return end
    if G1NM.aoe and G1NM.spellIsReady(shuriken_storm) and G1NM.playerCount(10, _, 3, ">=") then G1NM.cast(_, shuriken_storm, _, _, _, _, _) return end
    if G1NM.spellCanAttack(shadowstrike) then G1NM.cast(_, shadowstrike) return end
end

local pickPocketTable = {"Aberration", "Beast", "Demon", "Dragonkin", "Elemental", "Giant", "Humanoid", "Mechanical", "Uncategorized", "Undead", }
local blacklist = {}
local pickPocketing = false
local function autoPickPocket()
    pickPocketing = true
    -- print("pick pocketing")
    local timeNow = 0
    while (true) do
        if debugprofilestop() - timeNow > 100 then
            while (G1NM.spellCDDuration(pick_pocket) > 0 or UnitMovementFlag("player", MovementFlag.Falling)) do coroutine.yield() end
            timeNow = debugprofilestop()
            for i = 1, GetObjectCount() do
                iterator = GetObjectWithIndex(i)
                if UnitCanAttack("player", iterator) and not UnitIsDead(iterator) and G1NM.spellCanAttack(pick_pocket, iterator) and G1NM.distanceBetween(iterator) < 6 and not blacklist[ObjectGUID(iterator)] and tContains(pickPocketTable, UnitCreatureType(iterator)) then
                    G1NM.cast(iterator, pick_pocket)
                    blacklist[ObjectGUID(iterator)] = true
                end
            end
            --         if castable(ids.pick_pocket, goodName) and player.distance(goodName) < 6 and not blacklist[goodName.guid] and tContains(pickPocketTable, UnitCreatureType(unitID)) then
            --             local movingTable = gx.getMovingTable()
            --             gx.printd("stopping movement")
            --             gx.stopMoving(movingTable)
            --             gx.printd("casting pp")
            --             cast(ids.pick_pocket, goodName)
            --             if UnitMovementFlag("player", MovementFlag.Falling) then break end
            --             local delay = debugprofilestop()
            --             while (debugprofilestop() - delay < 250) do coroutine.yield("CONTINUE"); gx.printd("waiting delay") end
            --             if config("gSub", "sap_pick_pocket") then cast(ids.sap, goodName) gx.printd("Sapping after Pick Pocket") end
            --             gx.printd("moving again")
            --             gx.startMoving(movingTable)
            --             gx.printd("done pping")
            --             blacklist[goodName.guid] = true
            --             break
            --         end
            -- if gx.queueSize() > 0 or player.time > 0 or not config("gSub", "autoPick") then pickPocketing = false return end
        end
        coroutine.yield("CONTINUE")
    end
end
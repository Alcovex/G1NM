local _ = nil

BINDING_HEADER_G1NM_General = "General Keybinds"

-- G1NM.categoryButtonNumber = nil

local defaultSettings, setDefaultSettings, nukeIDs, nukeSettings, setDefaultIDs -- declare settings functions
local createOptionsTable -- declare ace creation function
local generalSettingsTable -- declare general settings group
local keybindsSettingsTable -- declare key bindings settings group
local configSettingsTable -- declare config settings group
local configSettingsRandomization -- declare randomization settings subgroup
local configSettingsInterrupts -- declare interrupts settings subgroup
local rebuildInterruptList, addMob, delMob, addInterrupt, delInterrupt -- declare interrupts functions
local configSettingsOM -- declare object manager settings subgroup
local humansOM, animalsOM -- declare object manager settings subsubgroups
local animalIDs, setAnimalIDs, getAnimalIDs, animalIDsDescription -- declare object manager settings
local animalAuras, setAnimalAuras, getAnimalAuras, animalAurasDescription -- declare object manager settings
local animalTypes, setAnimalTypes, getAnimalTypes, animalTypesDescription -- declare object manager settings
local setHealingListDescription, getHealingListDescription, healingListDescription
local configSettingsIDs -- declare ids settings subgroup
local bossIDList, dummiesIDList, skipLoSList -- declare ids settings subsubgroups
local bossListDescription, dummyListDescription, skipLoSListDescription, setBossList, getBossList, setDummyList, getDummyList, setSkipLoSList, getSkipLoSList -- declare ids settings functions
local debugSettingsTable -- declare debug settings group

function G1NM.GetAddonName(ignoreColor)
    if ignoreColor then return G1NM.AddonName:match("%u%l+") end
    return G1NM.AddonName
end

defaultSettings = {
    -- General
        ["interrupt"] = false,
        ["thok"] = false,
        ["los"] = false,
        ["taunt"] = false,
        ["cced"] = false,
        ["humans"] = true,
        ["animals"] = true,
        ["objectManagerMode"] = 1,
        ["monitorScale"] = 1,
        ["queueSystem"] = true,
        ["potion"] = false,

    -- ROGUE
        ["rogueAutoStealth"] = 2,
        ["rogueAutoTricksTrade"] = true,
        ["queue2094"] = true,
        ["queue185311"] = true,
        ["queue1966"] = true,
        ["queue408"] = true,
        ["rogueSubtletyNightbladeMaxTargets"] = 10,
        ["rogueSubtletyNightbladeMinHP"] = 1,
        ["rogueSubtletyFireblood"] = true,
        ["rogueSubtletyLightsJudgment"] = true,
        ["rogueSubtletyShadowmeld"] = true,
        ["rogueSubtletyAncestralCall"] = true,
        ["rogueSubtletyArcanePulse"] = true,
        ["rogueSubtletyBloodFury"] = true,
        ["rogueSubtletyBerserking"] = true,
        ["rogueSubtletyMydasTalisman"] = true,
        ["rogueSubtletyInventoryItemUse"] = true,
        ["rogueSubtletyShadowDance"] = true,
        ["rogueSubtletySymbolsOfDeath"] = true,
        ["rogueSubtletyShurikenToss"] = true,
        ["rogueSubtletyVanish"] = true,
        ["rogueSubtletyShadowBlades"] = true,
        ["rogueSubtletyMarkedForDeath"] = true,
        ["rogueSubtletySecretTechnique"] = true,
        ["rogueSubtletyShurikenTornado"] = true,

    -- DEATHKNIGHT
        -- ["BoSRP"] = 70,
        -- ["BoSAvailableRunes"] = 2,
        -- ["BoSAddRunes"] = .75,
        -- ["FDKsindragosasFury"] = true,
        -- ["FDKopener"] = false,
        -- ["BoSLowRP"] = 30,
        -- ["FDKbosCDs"] = true,

    -- DEMONHUNTER
        -- ["animationCancelDuration"] = 1,
        -- ["havocEyeBeamCount"] = 2,
        -- ["havocFuryOfTheIllidariCount"] = 2,
        -- ["havocFelRushDamage"] = true,

    -- DRUID
        -- ["balanceMoonfireCap"] = 5,

    -- MONK
        -- ["wwOpener"] = true,

    -- PRIEST
        -- ["discPriestStyle"] = 1,
        -- ["atonementStacksAoEBurst"] = 5,
        -- ["dotSpreadCap"] = 5,
        -- ["mindbenderManaPercent"] = 70,
        -- ["painSuppressionEmergency"] = 15,
        -- ["burnAtonementPhase"] = false,
        -- ["atonementBurnDuration"] = 0,

        -- ["discPauseKeys"] = {Shift = false, Control = false, Alt = false},
        -- ["discAoEBurstKeys"] = {Shift = false, Control = false, Alt = false},

        -- ["pleaPartyPercent"] = 3,
        -- ["shadowMendPartyTankPercent"] = 2.5,
        -- ["shadowMendPartyNonTankPercent"] = 2.5,
        -- ["powerRadiancePartyPercent"] = 50,
        -- ["haloPartyPercent"] = 5,
        -- ["lightsWrathPartyPercent"] = 5,
        -- ["lightsWrathPartyAtonement"] = 2,

        -- ["pleaRaidPercent"] = 3,
        -- ["shadowMendRaidTankPercent"] = 2.5,
        -- ["shadowMendRaidNonTankPercent"] = 2.5,
        -- ["powerRadianceRaidPercent"] = 40,
        -- ["haloRaidPercent"] = 5,
        -- ["lightsWrathRaidPercent"] = 10,
        -- ["lightsWrathRaidAtonement"] = 10,

    -- Config
        ["chaosMin"]   = -20,
        ["chaosMax"]   =  40,
        ["castMin"]    =  10,
        ["castMax"]    =  25,
        ["channelMin"] =  85,
        ["channelMax"] =  95,
        ["healingListMode"] = 2,

    -- Render
        ["renderPlayer"] = true,
        ["renderPlayersPets"] = true,
        ["renderHarmPlayers"] = true,
        ["renderHarmPlayersPets"] = true,
        ["renderHelpPlayers"] = true,
        ["renderHelpPlayersPets"] = true,
        ["renderHarmMobs"] = true,
        ["renderHelpMobs"] = true,

    -- Debug
        ["log"] = false,
        ["collectInfo"] = false,
        ["dummyTTDMode"] = 3,
}

local nuke
G1NM.CO.setDefaultSettings = coroutine.create(function()
    while (true) do
        if nuke then
            local class = G1NMData[G1NM.playerFullName].class
            table.wipe(G1NMData[G1NM.playerFullName])
            G1NM.saveSetting("garbageSave", true)
            G1NMData[G1NM.playerFullName].class = class
        end
        for k,v in pairs(defaultSettings) do
            if G1NMData[G1NM.playerFullName][k] == nil then G1NMData[G1NM.playerFullName][k] = v end
        end
        if not G1NMData.logFile then G1NMData.logFile = GetHackDirectory().."\G1NMLog.json" end
        G1NM.saveSetting("garbageSave", true)
        coroutine.yield()
    end
end)
G1NM.CO.nukeSettings = coroutine.wrap(function()
    while (true) do
        nuke = true
        coroutine.resume(G1NM.CO.setDefaultSettings, true)
        nuke = false
        coroutine.yield()
    end
end)
coroutine.resume(G1NM.CO.setDefaultSettings)

setDefaultIDs = function()
    G1NMData.bossIDList = {
        -- The Emerald Nightmare
            102672, -- Nythendra
            106087, -- Elerethe Renferal
            100497, -- Ursoc

        -- The Nighthold
            102263, -- Skopyron
            104415, -- Chronomatic Anomaly
            104288, -- Trilliax
            104881, -- Spellblade Aluriel
            103685, -- Tichondrius
            104528, -- High Botanist Tel'arn
            109041, -- Naturalist Tel'arn
            109038, -- Solarist Tel'arn
            101002, -- Krosus
            103758, -- Star Augur Etraeus
            106643, -- Grand Magistrix Elisande
            104154, -- Gul'dan
    }

    G1NMData.dummiesIDList = {
        -- DAMAGE
            31146, -- Raider's Training Dummy
            46647, -- Training Dummy
            92164, -- Training Dummy
            92165, -- Dungeoneer's Training Dummy
            92166, -- Raider's Training Dummy
            100440, -- Training Bag
            100441, -- Dungeoneer's Training Bag
            100451, -- Raider's Training Bag
            107202, -- Reanimated Monstrosity
            109096, -- Normal Tank Dummy
            113674, -- Imprisoned Centurion
            113676, -- Imprisoned Weaver
            113687, -- Imprisoned Imp
            113966, -- Dungeoneer's Training Dummy
            126712, -- Training Dummy
            126781, -- Training Dummy
            127019, -- Training Dummy
            131983, -- Raider's Training Dummy
            131985, -- Dungeoneer's Training Dummy
            131989, -- Training Dummy
            131997, -- Training Dummy
            132976, -- Morale Booster
            134324, -- Training Dummy
            138048, -- Training Dummy
            143119, -- Gnoll Target Dummy
            143509, -- Training Dummy
            144077, -- Morale Booster
            144081, -- Training Dummy
            144082, -- Training Dummy
            144085, -- Training Dummy
            144086, -- Raider's Training Dummy

        -- TANKING
            92168, -- Dungeoneer's Training Dummy
            113647, -- Imprisoned Eradicator
            113673, -- Imprisoned Executioner
            113964, -- Raider's Training Dummy
            131990, -- Raider's Training Dummy
            131992, -- Dungeoneer's Training Dummy
            144078, -- Dungeoneer's Training Dummy
    }

    G1NMData.skipLoSIDList = {
        -- 86644, -- Ore Crate from Oregorger boss
        76585, -- Ragewing
        77182, -- Oregorger
        77692, -- Kromog
        96759, -- Helya
        98696, -- Illysanna Ravencrest (Black Rook Hold)
    }

    G1NMData.animalTypesToIgnore = {
        "Critter",
        "Critter nil",
        "Wild Pet",
        "Pet",
        "Totem",
        -- "Not specified",
        -- Creature in the shadows xavius trash is this type
    }
    G1NMData.animalIDsToIgnore = {
        99803, -- Destructor Tentacle Fake
        99800, -- Grasping Tentacle Fake
        101814, -- Grasping Tentacle Fake
        101584, -- Grasping Tentacle Fake
        100361, -- Grasping Tentacle Fake
    }
    G1NMData.animalAuraIDsToIgnore = {
        209915, -- Stuff of Nightmares (Eye of Il'gynoth)
        232156, -- Spectral Service (Coggleston)
    }

    G1NMData.interruptTable = {
        -- Legacy
            -- Legion Dungeons
                -- [1041] = { -- Halls of Valor
                --     ["ZoneName"] = "Halls of Valor",
                --     [95842]  = {198595 --[[= {type = "cast", verify = "Thunderous Bolt"}]]}, -- Valarjar Thundercaller
                --     [95834]  = { -- Valarjar Mystic
                --         198931 --[[= {type = "cast", verify = "Healing Light"}]],
                --         215433 --[[= {type = "cast", verify = "Holy Radiance"}]],
                --     },
                --     [96664]  = { -- Valarjar Runecarver
                --         198962--[[ = {type = "cast", verify = "Shattered Rune"}]],
                --         198959--[[ = {type = "cast", verify = "Etch"}]],
                --     },
                --     [97197]  = {192563--[[ = {type = "cast", verify = "Cleansing Flames"}]]}, -- Valarjar Purifier
                --     [97202]  = {192288--[[ = {type = "cast", verify = "Searing Light"}]]}, -- Olmyr the Enlightened
                --     [95843]  = {199726--[[ = {type = "cast", verify = "Unruly Yell"}]]}, -- King Haldor
                --     [97083]  = {199726--[[ = {type = "cast", verify = "Unruly Yell"}]]}, -- King Ranulf
                --     [97084]  = {199726--[[ = {type = "cast", verify = "Unruly Yell"}]]}, -- King Tor
                --     [97081]  = {199726--[[ = {type = "cast", verify = "Unruly Yell"}]]}, -- King Bjorn
                --     [102019] = {198750--[[ = {type = "cast", verify = "Surge"}]]}, -- Stormforged Obliterator
                -- },
                -- [1042] = { -- Maw of Souls
                --     ["ZoneName"] = "Maw of Souls",
                --     [99188]  = {"Soul Siphon"--[[ = {type = "channel", verify = "Soul Siphon"}]]}, -- Waterlogged Soul Guard, 194657
                --     [97365]  = {199514--[[ = {type = "cast", verify = "Torrent of Souls"}]]}, -- Seacursed Mistmender
                --     -- [id]    = {[id] = {type = "cast", verify = ""}}, -- Seacursed Mistmaiden
                --     [97097]  = {198405--[[ = {type = "cast", verify = "Bone Chilling Scream"}]]}, -- Helarjar Champion
                --     [98693]  = {194266--[[ = {type = "cast", verify = "Void Snap"}]]}, -- Shackled Servitor
                --     [99033]  = {199589--[[ = {type = "cast", verify = "Whirlpool of Souls"}]]}, -- Helarjar Mistcaller
                --     [99307]  = {195293--[[ = {type = "cast", verify = "Debilitating Shout"}]]}, -- Skjal
                --     [99447]  = {198407--[[ = {type = "cast", verify = "Necrotic Bolt"}]]}, -- Skeletal Sorcerer
                --     [96759]  = {198495--[[ = {type = "cast", verify = "Torrent"}]]}, -- Helya
                -- },
                -- [1045] = { -- Vault of the Wardens
                --     ["ZoneName"] = "Vault of the Wardens",
                --     [96587]  = {193069--[[ = {type = "cast", verify = "Nightmares"}]]}, -- Felsworn Infestor
                --     [99198]  = {191823--[[ = {type = "cast", verify = "Furious Blast"}]]}, -- Tirathon Saltheril
                --     [107101] = {212541--[[ = {type = "cast", verify = "Scorch"}]]}, -- Fel Fury
                --     [98963]  = {194675--[[ = {type = "cast", verify = "Fireblast"}]]}, -- Blazing Imp
                --     [102583] = {202661--[[ = {type = "cast", verify = "Inferno Blast"}]]}, -- Fel Scorcher
                --     [96015]  = {200905--[[ = {type = "cast", verify = "Sap Soul"}]]}, -- Inquisitor Tormentorum
                --     [99657]  = {201488--[[ = {type = "cast", verify = "Frightening Shout"}]]}, -- Deranged Mindflayer
                --     [99233]  = {195332--[[ = {type = "cast", verify = "Sear"}]]}, -- Ember
                -- },
                -- [1046] = { -- Eye of Azshara
                --     ["ZoneName"] = "Eye of Azshara",
                --     [111638] = { -- Hatecoil Stormweaver
                --         218532--[[ = {type = "cast", verify = "Arc Lightning"}]],
                --         "Storm"--[[ = {type = "channel", verify = "Storm"}]],
                --     },
                --     [111632] = {195129--[[ = {type = "cast", verify = "Thundering Stomp"}]]}, -- Hatecoil Crusher
                --     [111636] = {195046--[[ = {type = "cast", verify = "Rejuvenating Waters"}]]}, -- Hatecoil Oracle
                --     [97269]  = {197502--[[ = {type = "cast", verify = "Restoration"}]]}, -- Hatecoil Crestrider
                --     [97171]  = {196027--[[ = {type = "cast", verify = "Aqua Spout"}]]}, -- Hatecoil Arcanist
                --     [95947]  = {196175--[[ = {type = "cast", verify = "Armorshell"}]]}, -- Mak'rana Hardshell
                --     [97259]  = {192003--[[ = {type = "cast", verify = "Blazing Nova"}]]}, -- Blazing Hydra Spawn
                --     [91808]  = {"Rampage"--[[ = {type = "channel", verify = "Rampage"}]]}, -- Serpentrix
                --     [97260]  = {192005--[[ = {type = "cast", verify = "Arcane Blast"}]]}, -- Arcane Hydra Spawn
                -- },
                -- [1065] = { -- Neltharion's Lair
                --     ["ZoneName"] = "Neltharion's Lair",
                --     [91006]  = {202181--[[ = {type = "cast", verify = "Stone Gaze"}]]}, -- Rockback Gnasher
                --     [102232] = {193585--[[ = {type = "cast", verify = "Bound"}]]}, -- Rockbound Trapper
                -- },
                -- [1066] = { -- Assault on Violet Hold
                --     ["ZoneName"] = "Assault on Violet Hold",
                --     [102337] = {"Shield of Eyes"--[[ = {type = "channel", verify = "Shield of Eyes"}]]}, -- Portal Guardian - Inquisitor
                --     [102336] = { -- Portal Keeper - Dreadlord
                --         204901--[[ = {type = "cast", verify = "Carrion Swarm"}]],
                --         204947--[[ = {type = "cast", verify = "Vampiric Cleave"}]],
                --     },
                --     [102302] = {"Fel Destruction"--[[ = {type = "channel", verify = "Fel Destruction"}]]}, -- Portal Keeper - Felguard
                --     [102372] = {"Drain Essence"--[[ = {type = "channel", verify = "Drain Essence"}]]}, -- Felhound Mage Slayer
                --     [102380] = {205121--[[ = {type = "cast", verify = "Chaos Bolt"}]]}, -- Shadow Council Warlock
                --     [112738] = {224453--[[ = {type = "cast", verify = "Lob Poison"}]]}, -- Acolyte of Sael'orn
                --     [112733] = {224460--[[ = {type = "cast", verify = "Venom Nova"}]]}, -- Venomhide shadowspinner
                --     [102103] = {201369--[[ = {type = "cast", verify = "Rocket Chicken Rocket"}]]}, -- Thorium Rocket Chicken
                --     [102618] = {201146--[[ = {type = "cast", verify = "Hysteria"}]]}, -- Mindflayer Kaahrj
                --     [102282] = {204963--[[ = {type = "cast", verify = "Shadow Bolt Volley"}]]}, -- Lord Malgath
                -- },
                -- [1067] = { -- Darkheart Thicket
                --     ["ZoneName"] = "Darkheart Thicket",
                --     [95771]  = {200658--[[ = {type = "cast", verify = "Star Shower"}]]}, -- Dreadsoul Ruiner
                --     [95769]  = {200630--[[ = {type = "cast", verify = "Unnerving Screech"}]]}, -- Mindshattered Screecher
                --     [101991] = {"Tormenting Eye"--[[ = {type = "channel", verify = "Tormenting Eye"}]]}, -- Nightmare Dweller
                --     [100527] = {201399--[[ = {type = "cast", verify = "Dread Inferno"}]]}, -- Dreadfire Imp
                -- },
                -- [1079] = { -- The Arcway
                --     ["ZoneName"] = "The Arcway",
                --     [105952] = {"Siphon Essence"--[[ = {type = "channel", verify = "Siphon Essence"}]]}, -- Withered Manawraith
                --     [113699] = {226269--[[ = {type = "cast", verify = "Torment"}]]}, -- Forgotten Spirit
                --     [105915] = {211007--[[ = {type = "cast", verify = "Eye of the Vortex"}]]}, -- Nightborne Reclaimer
                --     [105617] = { -- Eredar Chaosbringer
                --         211757--[[ = {type = "cast", verify = "Portal: Argus"}]],
                --         226285--[[ = {type = "cast", verify = "Demonic Ascension"}]],
                --     },
                --     [98756]  = {226206--[[ = {type = "cast", verify = "Arcane Reconstitution"}]]}, -- Arcane Anomaly
                --     [106059] = { -- Warp Shade
                --         211115--[[ = {type = "cast", verify = "Phase Breach"}]],
                --         226206--[[ = {type = "cast", verify = "Arcane Reconstitution"}]],
                --     },
                --     [98203]  = {"Overcharge Mana"--[[ = {type = "channel", verify = "Overcharge Mana"}]]}, -- Ivanyr
                --     [98208]  = {203176--[[ = {type = "cast", verify = "Accelerating Blast"}]]}, -- Advisor Vandros
                --     [111057] = {221285--[[ = {type = "cast", verify = "Plague Bolt"}]]}, -- The Rat King
                -- },
                -- [1081] = { -- Black Rook Hold
                --     ["ZoneName"] = "Black Rook Hold",
                --     [98370]  = {225573--[[ = {type = "cast", verify = "Dark Mending"}]]}, -- Ghostly Councilor
                --     [98521]  = {196883--[[ = {type = "cast", verify = "Spirit Blast"}]]}, -- Lord Etheldrin Ravencrest
                --     [98280]  = {200248--[[ = {type = "cast", verify = "Arcane Blitz"}]]}, -- Risen Arcanist
                --     [102788] = {227913--[[ = {type = "cast", verify = "Felfrenzy"}]]}, -- Felspite Dominator
                -- },
                -- [1087] = { -- Court of Stars
                --     ["ZoneName"] = "Court of Stars",
                --     [104251] = {210261--[[ = {type = "cast", verify = "Sound Alaram"}]]}, -- Duskwatch Sentry
                --     [104918] = {215204--[[ = {type = "cast", verify = "Hinder"}]]}, -- Vigilant Duskwatch
                --     [105704] = {209485--[[ = {type = "cast", verify = "Drain Magic"}]]}, -- Arcane Manifestation
                --     [104247] = {209404--[[ = {type = "cast", verify = "Seal Magic"}]]}, -- Duskwatch Arcanist
                --     [104270] = { -- Guardian Construct
                --         209413--[[ = {type = "cast", verify = "Suppress"}]],
                --         225100--[[ = {type = "cast", verify = "Charging Station"}]],
                --     },
                --     [105715] = {211299--[[ = {type = "cast", verify = "Searing Glare"}]]}, -- Watchful Inquisitor
                --     [104300] = {211470--[[ = {type = "cast", verify = "Bewitch"}]]}, -- Shadow Mistress
                --     [104295] = {"Drifting Embers"--[[ = {type = "channel", verify = "Drifting Embers"}]]}, -- Blazing Imp
                --     [104217] = {208165--[[ = {type = "cast", verify = "Withering Soul"}]]}, -- Talixae Flamewreath
                --     [112668] = {"Drifting Embers"--[[ = {type = "channel", verify = "Drifting Embers"}]]}, -- Infernal Imp
                -- },
                -- [1115] = { -- Karazhan
                --     ["ZoneName"] = "Karazhan",
                --     [114626] = {228254--[[228255?]]--[[ = {type = "cast", verify = "Soul Leech"}]]}, -- Forlorn Spirit
                --     [114627] = {228239--[[ = {type = "cast", verify = "Terrifying Wail"}]]}, -- Shrieking Terror
                --     [114329] = {228025--[[ = {type = "cast", verify = "Heat Wave"}]]}, -- Luminore
                --     [114552] = {228019--[[ = {type = "cast", verify = "Leftovers"}]]}, -- Mrs. Cauldrons
                --     [114328] = {227987--[[ = {type = "cast", verify = "Dinner Bell!"}]]}, -- Coggleston
                --     [114266] = {227420--[[ = {type = "cast", verify = "Bubble Blast"}]]}, -- Shoreline Tidespeaker
                --     [114251] = {227341--[[ = {type = "cast", verify = "Flashy Bolt"}]]}, -- Galindre
                --     [114526] = {227917--[[ = {type = "cast", verify = "Poetry Slam"}]]}, -- Ghostly Understudy
                --     [116549] = {232115--[[ = {type = "cast", verify = "Firelands Portal"}]]}, -- Backup Singers
                --     [114629] = {228280--[[ = {type = "cast", verify = "Oath of Fealty"}]]}, -- Spectral Retainer
                --     [114634] = {228277--[[ = {type = "cast", verify = "Shackles of Servitude"}]]}, -- Undying Servants
                --     [114792] = {226316--[[ = {type = "cast", verify = "Shadow Bolt Volley"}]]}, -- Virtuous Lady
                --     [114796] = {228625--[[ = {type = "cast", verify = "Banshee Wail"}]]}, -- Wholesome Hostess
                --     [113971] = { -- Maiden of Virtue
                --         227823--[[ = {type = "cast", verify = "Holy Wrath"}]],
                --         227800--[[ = {type = "cast", verify = "Holy Shock"}]],
                --     },
                --     [115440] = {227545--[[ = {type = "cast", verify = "Mana Drain"}]]}, -- Baroness Dorothea Millstipe
                --     [ 17007] = {227616--[[ = {type = "cast", verify = "Empowered Arms"}]]}, -- Lady Keira Berrybuck
                --     [ 19872] = {227542--[[ = {type = "cast", verify = "Smite"}]]}, -- Lady Catriona Von'Indi
                --     [114803] = {228606--[[ = {type = "cast", verify = "Healing Touch"}]]}, -- Spectral Stable Hand
                --     [114895] = {229307--[[ = {type = "cast", verify = "Reverberating Shadows"}]]}, -- Nightbane
                --     [115488] = { 36247--[[ = {type = "cast", verify = "Fel Fireball"}]]}, -- Infused Pyromancer
                --     [114350] = { -- Shade of Medivh
                --         -- [227628] = {type = "cast", verify = "Piercing Missiles"},
                --         "Piercing Missiles"--[[ = {type = "channel", verify = "Piercing Missiles"}]],
                --     },
                --     [115419] = {229714--[[ = {type = "cast", verify = "Consume Magic"}]]}, -- Ancient Tome
                --     [114790] = { -- Viz'aduum the Watcher
                --         --[[[229083] = {type = "cast", verify = "Burning Blast"},
                --         [230084] = {type = "channel", verify = "Stabilize Rift"},]]
                --         "Stabilize Rift"--[[ = {type = "channel", verify = "Stabilize Rift"}]],
                --     },
                -- },

            -- Legion Raids
                -- [1094] = { -- The Emerald Nightmare
                --     ["ZoneName"] = "The Emerald Nightmare",
                --     [111004] = {221059--[[ = {type = "cast", verify = "Wave of Decay"}]]}, -- Gelatinized Decay
                --     -- [id] = {[205070] = {type = "cast", verify = "Spread Infestation"}}, -- Player MC'ed Mythic Nythendra
                --     [111331] = { -- Lurking Horror This needs to be both a cast and a channel
                --         222793--[[ = {type = "cast", verify = "Torturous Leer"}]],
                --         "Torturous Leer"--[[222824]]--[[ = {type = "channel", verify = "Torturous Leer"}]],
                --     },
                --     [105322] = {208697--[[ = {type = "cast", verify = "Mind Flay"}]]}, -- Deathglare Tentacle
                --     [112153] = {223392--[[ = {type = "cast", verify = "Dread Wrath Volley"}]]}, -- Dire Shaman
                --     [113088] = { -- Corrupted Feeler
                --         225042--[[ = {type = "cast", verify = "Corrupt"}]],
                --         "Corrupt"--[[225042]]--[[ = {type = "channel", verify = "Corrupt"}]],
                --     },
                --     [112290] = {223565--[[ = {type = "cast", verify = "Screech"}]]}, -- Horrid Eagle
                --     [113089] = {"Raining Filth"--[[225079]]--[[ = {type = "channel", verify = "Raining Filth"}]]}, -- Defiled Keeper
                --     [103691] = {205300--[[ = {type = "cast", verify = "Corruption"}]]}, -- Essence of Corruption
                --     [112261] = { -- Dreadsoul Corruptor
                --         223038--[[ = {type = "cast", verify = "Erupting Terror"}]],
                --         223590--[[ = {type = "cast", verify = "Darkfall"}]],
                --     },
                --     [112260] = {222939--[[ = {type = "cast", verify = "Shadow Volley"}]]}, -- Dreadsoul Defiler
                --     [105495] = {211368--[[ = {type = "cast", verify = "Twisted Touch of Life"}]]}, -- Twisted Sister
                --     -- [id] = {[id] = {type = "cast", verify = "Mind Flay"}}, -- Shriveled Eyestalk
                -- },
                -- [1114] = { -- Trial of Valor
                --     ["ZoneName"] = "Trial of Valor",
                --     [116335] = {228854--[[ = {type = "cast", verify = "Mist Infusion"}]]}, -- Helarjar Mistwatcher
                -- },
                -- [1088] = { -- The Nighthold
                    -- ["ZoneName"] = "The Nighthold",
                    -- [113128] = {225410--[[ = {type = "cast", verify = "Withering Volley"}]]}, -- Withered Skulker
                    -- [104676] = {207228--[[ = {type = "cast", verify = "Warp Nightwell"}]]}, -- Waning Time Particle
                    -- [113512] = {214181--[[ = {type = "cast", verify = "Slop Burst"}]]}, -- Putrid Sludge
                    -- [113307] = {"Mass Siphon"--[[225412]] --[[= {type = "channel", verify = "Mass Siphon"}]]}, -- Chronowraith
                    -- [112665] = {224568--[[ = {type = "cast", verify = "Mass Suppress"}]]}, -- Nighthold Protector
                    -- [112676] = { -- Nobleborn Warpcaster
                    --     224515--[[ = {type = "cast", verify = "Warped Blast"}]],
                    --     224488--[[ = {type = "cast", verify = "Reverse Wounds"}]],
                    -- },
                    -- [112603] = { -- Terrace Grove-Tender
                    --     225047--[[ = {type = "cast", verify = "Shrink"}]],
                    --     225043--[[ = {type = "cast", verify = "Grow"}]],
                    --     -- [225052] = {type = "cast", verify = "Prune"},
                    -- },
                    -- [107285] = {213281--[[ = {type = "cast", verify = "Pyroblast"}]]}, -- Fiery Enchantment
                    -- [111303] = {225809--[[ = {type = "cast", verify = "Time Reversal"}]]}, -- Nightborne Sage
                    -- [111225] = {221464--[[ = {type = "cast", verify = "Chaotic Energies"}]]}, -- Chaos Mage Beleron
                    -- [104262] = {209017--[[ = {type = "cast", verify = "Felblast"}]]}, -- Burning Ember
                    -- [113012] = { -- Felsworn Chaos-Mage
                    --     224943--[[ = {type = "cast", verify = "Eradication"}]],
                    --     224944--[[ = {type = "cast", verify = "Will of the Legion"}]],
                    -- },
                    -- [111170] = { -- Astral Farseer
                    --     226231--[[ = {type = "cast", verify = "Faint Hope"}]],
                    --     221577--[[ = {type = "cast", verify = "Arcane Burst"}]],
                    -- },
                    -- [105299] = { -- Recursive Elemental
                    --     221864--[[ = {type = "cast", verify = "Blast"}]],
                    --     209620--[[ = {type = "cast", verify = "Recursion"}]],
                    -- },
                    -- [105301] = { -- Expedient Elemental
                    --     209568--[[ = {type = "cast", verify = "Exothermic Release"}]],
                    --     209617--[[ = {type = "cast", verify = "Expedite"}]],
                    -- },
                    -- [110965] = { -- Elisande
                    --     209971--[[ = {type = "cast", verify = "Ablative Pulse"}]],
                    -- },
                -- },
            

        -- Proving Grounds
            [480] = {
                ["ZoneName"] = "Proving Grounds",
            },
            -- [1015] = {
            --     ["ZoneName"] = "who the fuck cares",
            --     [92450] = {
            --         180392,
            --         183227,
            --     },
            -- },

        -- BfA Dungeons
            [934] = {
                ["ZoneName"] = "Atal'Dazar",
            },
            [935] = {
                ["ZoneName"] = "Atal'Dazar: Sacrificial Pits",
            },
            [936] = {
                ["ZoneName"] = "Freehold",
            },
            [1004] = {
                ["ZoneName"] = "Kings' Rest"
            },
            [1039] = {
                ["ZoneName"] = "Shrine of the Storm",
            },
            [1040] = {
                ["ZoneName"] = "Shrine of the Storm: Storm's End",
            },
            [1162] = {
                ["ZoneName"] = "Siege of Boralus",
            },
            [1038] = {
                ["ZoneName"] = "Temple of Sethraliss",
            },
            [1043] = {
                ["ZoneName"] = "Temple of Sethraliss: Atrium of Sethraliss",
            },
            [1010] = {
                ["ZoneName"] = "The MOTHERLODE!!",
            },
            [1042] = {
                ["ZoneName"] = "The Underrot: Ruin's Descent",
            },
            [974] = {
                ["ZoneName"] = "Tol Dagor",
            },
            [975] = {
                ["ZoneName"] = "Tol Dagor: The Drain",
            },
            [976] = {
                ["ZoneName"] = "Tol Dagor: The Brig",
            },
            [977] = {
                ["ZoneName"] = "Tol Dagor: Detention Block",
            },
            [978] = {
                ["ZoneName"] = "Tol Dagor: Officer Quarters",
            },
            [979] = {
                ["ZoneName"] = "Tol Dagor: Overseer's Redoubt",
            },
            [980] = {
                ["ZoneName"] = "Tol Dagor: Overseer's Summit",
            },
            [1015] = {
                ["ZoneName"] = "Waycrest Manor: The Grand Foyer"
            },
            [1016] = {
                ["ZoneName"] = "Waycrest Manor: Upstairs"
            },
            [1017] = {
                ["ZoneName"] = "Waycrest Manor: The Cellar"
            },
            [1018] = {
                ["ZoneName"] = "Waycrest Manor: Catacombs"
            },

        -- BfA Raids
            [1148] = {
                ["ZoneName"] = "Uldir: Ruin's Descent",
            },
            [1149] = {
                ["ZoneName"] = "Uldir: Hall of Sanitation",
            },
            [1150] = {
                ["ZoneName"] = "Uldir: Ring of Containment",
            },
            [1151] = {
                ["ZoneName"] = "Uldir: Archives of Eternity",
            },
            [1152] = {
                ["ZoneName"] = "Uldir: Plague Vault",
            },
            [1153] = {
                ["ZoneName"] = "Uldir: Gallery of Failures",
            },
            [1154] = {
                ["ZoneName"] = "Uldir: The Oblivion Door",
            },
            [1155] = {
                ["ZoneName"] = "Uldir: The Festering Core",
            },
        }

    G1NMData[G1NM.playerFullName].healingWhiteList = {
    }
    G1NMData[G1NM.playerFullName].healingBlackList = {
    }

    G1NM.saveSetting("garbageSave", true)
    if setBossList then setBossList() end
    if setDummyList then setDummyList() end
    if setSkipLoSList then setSkipLoSList() end
    if setAnimalTypes then setAnimalTypes() end
    if setAnimalIDs then setAnimalIDs() end
    if setAnimalAuras then setAnimalAuras() end
    if rebuildInterruptList then rebuildInterruptList() end
end
if not G1NMData.bossIDList or not G1NMData.dummiesIDList or not G1NMData.skipLoSIDList or not G1NMData.animalTypesToIgnore or not G1NMData.animalIDsToIgnore or not G1NMData.animalAuraIDsToIgnore or not G1NMData.interruptTable or not G1NMData[G1NM.playerFullName].healingWhiteList or not G1NMData[G1NM.playerFullName].healingBlackList then setDefaultIDs(); print(G1NM.AddonName..": Setting Default IDs due to first start up.") end

if not G1NMData.playerNames then G1NMData.playerNames = {
}
end

function G1NM.getZoneInterruptsFromName(name)
    for k,v in pairs(G1NMData.interruptTable) do
        if v.ZoneName == name then return k end
    end
end

if not G1NMData.spellNames then G1NMData.spellNames = {
    ["209915"] = "Stuff of Nightmares",
    ["232156"] = "Spectral Service",
}
end

if not G1NMData.mobNames then G1NMData.mobNames = {
    -- [id] = "Player MC'ed Mythic Nythendra",
    -- [id] = "Seacursed Mistmaiden",
    -- [id] = "Shriveled Eyestalk",
    ["17007"] = "Lady Keira Berrybuck",
    ["19872"] = "Lady Catriona Von'Indi",
    ["31146"] = "Raider's Training Dummy",
    ["46647"] = "Training Dummy",
    ["76585"] = "Ragewing",
    ["77182"] = "Oregorger",
    ["77692"] = "Kromog",
    ["91006"] = "Rockback Gnasher",
    ["91808"] = "Serpentrix",
    ["92164"] = "Training Dummy",
    ["92165"] = "Dungeoneer's Training Dummy",
    ["92166"] = "Raider's Training Dummy",
    ["92168"] = "Dungeoneer's Training Dummy",
    ["95769"] = "Mindshattered Screecher",
    ["95771"] = "Dreadsoul Ruiner",
    ["95834"] = "Valarjar Mystic",
    ["95842"] = "Valarjar Thundercaller",
    ["95843"] = "King Haldor",
    ["95947"] = "Mak'rana Hardshell",
    ["96015"] = "Inquisitor Tormentorum",
    ["96587"] = "Felsworn Infestor",
    ["96664"] = "Valarjar Runecarver",
    ["96759"] = "Helya",
    ["97081"] = "King Bjorn",
    ["97083"] = "King Ranulf",
    ["97084"] = "King Tor",
    ["97097"] = "Helarjar Champion",
    ["97171"] = "Hatecoil Arcanist",
    ["97197"] = "Valarjar Purifier",
    ["97202"] = "Olmyr the Enlightened",
    ["97259"] = "Blazing Hydra Spawn",
    ["97260"] = "Arcane Hydra Spawn",
    ["97269"] = "Hatecoil Crestrider",
    ["97365"] = "Seacursed Mistmender",
    ["98203"] = "Ivanyr",
    ["98208"] = "Advisor Vandros",
    ["98280"] = "Risen Arcanist",
    ["98370"] = "Ghostly Councilor",
    ["98521"] = "Lord Etheldrin Ravencrest",
    ["98693"] = "Shackled Servitor",
    ["98696"] = "Illysanna Ravencrest (Black Rook Hold)",
    ["98756"] = "Arcane Anomaly",
    ["98963"] = "Blazing Imp",
    ["99033"] = "Helarjar Mistcaller",
    ["99188"] = "Waterlogged Soul Guard",
    ["99198"] = "Tirathon Saltheril",
    ["99233"] = "Ember",
    ["99307"] = "Skjal",
    ["99447"] = "Skeletal Sorcerer",
    ["99657"] = "Deranged Mindflayer",
    ["99800"] = "Grasping Tentacle Fake",
    ["99803"] = "Destructor Tentacle Fake",
    ["100361"] = "Grasping Tentacle Fake",
    ["100440"] = "Training Bag",
    ["100441"] = "Dungeoneer's Training Bag",
    ["100451"] = "Raider's Training Bag",
    ["100497"] = "Ursoc",
    ["100527"] = "Dreadfire Imp",
    ["101002"] = "Krosus",
    ["101584"] = "Grasping Tentacle Fake",
    ["101814"] = "Grasping Tentacle Fake",
    ["101991"] = "Nightmare Dweller",
    ["102019"] = "Stormforged Obliterator",
    ["102103"] = "Thorium Rocket Chicken",
    ["102232"] = "Rockbound Trapper",
    ["102263"] = "Skopyron",
    ["102282"] = "Lord Malgath",
    ["102302"] = "Portal Keeper - Felguard",
    ["102336"] = "Portal Keeper - Dreadlord",
    ["102337"] = "Portal Guardian - Inquisitor",
    ["102372"] = "Felhound Mage Slayer",
    ["102380"] = "Shadow Council Warlock",
    ["102583"] = "Fel Scorcher",
    ["102618"] = "Mindflayer Kaahrj",
    ["102672"] = "Nythendra",
    ["102788"] = "Felspite Dominator",
    ["103685"] = "Tichondrius",
    ["103691"] = "Essence of Corruption",
    ["103758"] = "Star Augur Etraeus",
    ["104154"] = "Gul'dan",
    ["104217"] = "Talixae Flamewreath",
    ["104247"] = "Duskwatch Arcanist",
    ["104251"] = "Duskwatch Sentry",
    ["104262"] = "Burning Ember",
    ["104270"] = "Guardian Construct",
    ["104288"] = "Trilliax",
    ["104295"] = "Blazing Imp",
    ["104300"] = "Shadow Mistress",
    ["104415"] = "Chronomatic Anomaly",
    ["104528"] = "High Botanist Tel'arn",
    ["104676"] = "Waning Time Particle",
    ["104881"] = "Spellblade Aluriel",
    ["104918"] = "Vigilant Duskwatch",
    ["105299"] = "Recursive Elemental",
    ["105301"] = "Expedient Elemental",
    ["105322"] = "Deathglare Tentacle",
    ["105495"] = "Twisted Sister",
    ["105617"] = "Eredar Chaosbringer",
    ["105704"] = "Arcane Manifestation",
    ["105715"] = "Watchful Inquisitor",
    ["105915"] = "Nightborne Reclaimer",
    ["105952"] = "Withered Manawraith",
    ["106059"] = "Warp Shade",
    ["106087"] = "Elerethe Renferal",
    ["106643"] = "Grand Magistrix Elisande",
    ["107101"] = "Fel Fury",
    ["107202"] = "Reanimated Monstrosity",
    ["107285"] = "Fiery Enchantment",
    ["109038"] = "Solarist Tel'arn",
    ["109041"] = "Naturalist Tel'arn",
    ["109096"] = "Normal Tank Dummy",
    ["110965"] = "Elisande",
    ["111004"] = "Gelatinized Decay",
    ["111057"] = "The Rat King",
    ["111170"] = "Astral Farseer",
    ["111225"] = "Chaos Mage Beleron",
    ["111303"] = "Nightborne Sage",
    ["111331"] = "Lurking Horror",
    ["111632"] = "Hatecoil Crusher",
    ["111636"] = "Hatecoil Oracle",
    ["111638"] = "Hatecoil Stormweaver",
    ["112153"] = "Dire Shaman",
    ["112260"] = "Dreadsoul Defiler",
    ["112261"] = "Dreadsoul Corruptor",
    ["112290"] = "Horrid Eagle",
    ["112603"] = "Terrace Grove-Tender",
    ["112665"] = "Nighthold Protector",
    ["112668"] = "Infernal Imp",
    ["112676"] = "Nobleborn Warpcaster",
    ["112733"] = "Venomhide shadowspinner",
    ["112738"] = "Acolyte of Sael'orn",
    ["113012"] = "Felsworn Chaos-Mage",
    ["113088"] = "Corrupted Feeler",
    ["113089"] = "Defiled Keeper",
    ["113128"] = "Withered Skulker",
    ["113307"] = "Chronowraith",
    ["113512"] = "Putrid Sludge",
    ["113647"] = "Imprisoned Eradicator",
    ["113673"] = "Imprisoned Executioner",
    ["113674"] = "Imprisoned Centurion",
    ["113676"] = "Imprisoned Weaver",
    ["113687"] = "Imprisoned Imp",
    ["113699"] = "Forgotten Spirit",
    ["113964"] = "Raider's Training Dummy",
    ["113966"] = "Dungeoneer's Training Dummy",
    ["113971"] = "Maiden of Virtue",
    ["114251"] = "Galindre",
    ["114266"] = "Shoreline Tidespeaker",
    ["114328"] = "Coggleston",
    ["114329"] = "Luminore",
    ["114350"] = "Shade of Medivh",
    ["114526"] = "Ghostly Understudy",
    ["114552"] = "Mrs. Cauldrons",
    ["114626"] = "Forlorn Spirit",
    ["114627"] = "Shrieking Terror",
    ["114629"] = "Spectral Retainer",
    ["114634"] = "Undying Servants",
    ["114790"] = "Viz'aduum the Watcher",
    ["114792"] = "Virtuous Lady",
    ["114796"] = "Wholesome Hostess",
    ["114803"] = "Spectral Stable Hand",
    ["114895"] = "Nightbane",
    ["115419"] = "Ancient Tome",
    ["115440"] = "Baroness Dorothea Millstipe",
    ["115488"] = "Infused Pyromancer",
    ["116335"] = "Helarjar Mistwatcher",
    ["116549"] = "Backup Singers",
    ["126712"] = "Training Dummy",
    ["126781"] = "Training Dummy",
    ["127019"] = "Training Dummy",
    ["131983"] = "Raider's Training Dummy",
    ["131985"] = "Dungeoneer's Training Dummy",
    ["131989"] = "Training Dummy",
    ["131990"] = "Raider's Training Dummy",
    ["131992"] = "Dungeoneer's Training Dummy",
    ["131997"] = "Training Dummy",
    ["132976"] = "Morale Booster",
    ["134324"] = "Training Dummy",
    ["138048"] = "Training Dummy",
    ["143119"] = "Gnoll Target Dummy",
    ["143509"] = "Training Dummy",
    ["144077"] = "Morale Booster",
    ["144078"] = "Dungeoneer's Training Dummy",
    ["144081"] = "Training Dummy",
    ["144082"] = "Training Dummy",
    ["144085"] = "Training Dummy",
    ["144086"] = "Raider's Training Dummy",
}
end
function G1NM.mobNameFromID(id)
    return G1NMData.mobNames[id]
end
function G1NM.addToMobNamesTable(id, name)
    G1NMData.mobNames[id] = name
end
function G1NM.delFromMobNamesTable(id, name)
    G1NMData.mobNames[id] = nil
end

-- if not G1NMData[G1NM.playerFullName].reloadOnce then G1NM.saveSetting("reloadOnce", true) C_Timer.After(0, ReloadUI()) return end

-- Ace Stuff
    generalSettingsTable = {
        order = 1,
        name = "General Settings",
        type = "group",
        args = {
            Newline1 = {
                order = 1,
                type = "header",
                name = "Toggles",
            },
            interrupt = {
                order = 1.1,
                type = "toggle",
                name = "Interrupt",
                desc = "Use interrupt?",
                descStyle = "inline",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].interrupt end,
                set = function(i, v) G1NM.saveSetting("interrupt", v) end
            },
            ThokThrottle = {
                order = 1.2,
                type = "toggle",
                name = "Thok",
                desc = "Use stop casting? (Not 100% success rate.)",
                descStyle = "inline",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].thok end,
                set = function(i,v) G1NM.saveSetting("thok", v) end
            },
            LOS = {
                order = 1.3,
                type = "toggle",
                name = "LoS",
                descStyle = "inline",
                get = function() return G1NMData[G1NM.playerFullName].los end,
                set = function(i,v) G1NM.saveSetting("los", v) end
            },
            Queue = {
                order = 1.31,
                type = "toggle",
                name = "Queue System",
                get = function() return G1NMData[G1NM.playerFullName].queueSystem end,
                set = function(i,v) G1NM.saveSetting("queueSystem", v) end,
            },
            TauntTrainer = {
                order = 1.4,
                type = "toggle",
                name = "Taunt",
                desc = "Use taunt?\n(Set other tank as focus.)",
                descStyle = "inline",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].taunt end,
                set = function(i,v) G1NM.saveSetting("taunt", v) end
            },
            CC = {
                order = 1.5,
                type = "toggle",
                name = "Check CC?",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].cced end,
                set = function(i,v) G1NM.saveSetting("cced", v) end
            },
            potion = {
                order = 1.6,
                type = "toggle",
                name = "Use DPS Potion",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].potionUse end,
                set = function(i,v) G1NM.saveSetting("potionUse", v) end,
            },
            Newline2 = {
                order = 2,
                type = "header",
                name = "Misc"
            },
            DAMAGING = {
                order = 2.1,
                type = "toggle",
                name = "Animals",
                disabled = true,
                -- hidden = function() return true end,
                get = function() return G1NMData[G1NM.playerFullName].animals end,
                set = function(i,v) G1NM.saveSetting("animals", v) end
            },
            Healing = {
                order = 2.2,
                type = "toggle",
                name = "Humans",
                disabled = true,
                -- hidden = function() return true end,
                get = function() return G1NMData[G1NM.playerFullName].humans end,
                set = function(i,v) G1NM.saveSetting("humans", v) end
            },
            TargetAcquisition = {
                order = 2.3,
                type = "select",
                name = "Mobs and Friendlies Acquisition",
                values = {"Object Manager", "Nameplates"},
                get = function() return G1NMData[G1NM.playerFullName].objectManagerMode end,
                set = function(i,v) G1NM.saveSetting("objectManagerMode", v) end,
            },
            monitorScale = {
                order = 2.4,
                type = "range",
                name = "Monitor Scale",
                softMin = .5,
                softMax = 2.5,
                get = function() return G1NMData[G1NM.playerFullName].monitorScale end,
                set = function(i,v) G1NM.saveSetting("monitorScale", v) G1NM.monitorScale(v) end,
            },
            Newline3 = {
                order = 9999999,
                name = "\n\n\n\n\n\n\n\n\n\n",
                type = "description",
            },
            SetDefaultSettings = {
                order = 10000000,
                type = "execute",
                name = "Set Default Settings",
                func = G1NM.CO.nukeSettings,
            },
            SetDefaultIDs = {
                order = 10000001,
                type = "execute",
                name = "Set Default IDs",
                func = setDefaultIDs,
            },
        },
    }

    -- keybindsSettingsTable = {
        -- name = "Key Bindings",
        -- type = "group",
        -- order = 1.1,
        -- args = {
        --     toggleRotation = {
        --         name = "Toggle Rotation Run",
        --         order = 1.1,
        --         type = "keybinding",
        --         get = function() return G1NMData[G1NM.playerFullName].toggleRun end,
        --         set = function(i,v) G1NMData[G1NM.playerFullName].toggleRun = v end,
        --     },
        --     -- toggleAoE = {},
        --     -- toggleCDs = {},
        --     -- openSettings = {},
        -- },
    -- }

    configSettingsRandomization = {
        name = "Randomization Settings",
        order = 1,
        type = "group",
        -- inline = true,
        args = {
            chaosMin = {
                order = 1.1,
                type = "range",
                name = "Lower Randomization Bound",
                disabled = true,
                softMin = -40,
                softMax = 0,
                hidden = true,
                get = function() return G1NMData[G1NM.playerFullName].chaosMin end,
                set = function(i,v) G1NM.saveSetting("chaosMin", v) end
            },
            chaosMax = {
                order = 1.2,
                type = "range",
                name = "Upper Randomization Bound",
                disabled = true,
                softMin = 0,
                softMax = 80,
                hidden = true,
                get = function() return G1NMData[G1NM.playerFullName].chaosMax end,
                set = function(i,v) G1NM.saveSetting("chaosMax", v) end
            },
            castMin = {
                order = 1.3,
                type = "range",
                name = "Interrupt at Min Cast %",
                disabled = true,
                min = 0,
                softMax = 20,
                get = function() return G1NMData[G1NM.playerFullName].castMin end,
                set = function(i,v) G1NM.saveSetting("castMin", v) end
            },
            castMax = {
                order = 1.4,
                type = "range",
                name = "Interrupt at Max Cast %",
                disabled = true,
                softMin = 20,
                max = 100,
                get = function() return G1NMData[G1NM.playerFullName].castMax end,
                set = function(i,v) G1NM.saveSetting("castMax", v) end
            },
            channelMin = {
                order = 1.5,
                type = "range",
                name = "Interrupt at Min Channel %",
                disabled = true,
                min = 0,
                softMax = 85,
                get = function() return G1NMData[G1NM.playerFullName].channelMin end,
                set = function(i,v) G1NM.saveSetting("channelMin", v) end
            },
            channelMax = {
                order = 1.6,
                type = "range",
                name = "Interrupt at Max Channel %",
                disabled = true,
                softMin = 85,
                max = 100,
                get = function() return G1NMData[G1NM.playerFullName].channelMax end,
                set = function(i,v) G1NM.saveSetting("channelMax", v) end
            },
        },
    }

    addMob = function(self, value)
        local mobID, name
        mobID = string.match(value, "%d+")
        mobID = mobID
        name = string.gsub(string.match(value, ", .+"), ", ", "")

        if not G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][mobID] then
            G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][mobID] = {}
            G1NM.addToMobNamesTable(mobID, name)
             G1NMACR:GetOptionsTable("G1NM_Settings", "cmd", "fukyoself-1.0").args.Config.args.interrupts.args[self[3]].args[mobID] = {
                name = name,
                type = "group",
                args = {
                    interruptSpells = {
                        name = "Interrupt Nothing\n",
                        order = 1,
                        type = "description",
                    },
                    addSpell = {
                        name = "Add Interrupt",
                        type = "input",
                        order = math.huge,
                        set = addInterrupt,
                    },
                    delSpell = {
                        name = "Del Interrupt",
                        type = "input",
                        order = math.huge,
                        set = delInterrupt,
                    },
                    printID = {
                        name = "Print Mob ID",
                        type = "execute",
                        order = math.huge,
                        func = function() print(mobID) end,
                    },
                }
            }
             G1NMACR:NotifyChange("G1NM_Settings")
            G1NM.saveSetting("garbageSave", true)
        end
    end

    delMob = function(self, value)
        if G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][value] then
            G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][value] = nil
            G1NM.delFromMobNamesTable(value)
             G1NMACR:GetOptionsTable("G1NM_Settings", "cmd", "fukyoself-1.0").args.Config.args.interrupts.args[self[3]].args[value] = nil
             G1NMACR:NotifyChange("G1NM_Settings")
            G1NM.saveSetting("garbageSave", true)
        end
    end

    addInterrupt =  function(self, value)
        value = tostring(value) or value
        if not tContains(G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][self[4]], value) then
            table.insert(G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][self[4]], value)
            local string =  G1NMACR:GetOptionsTable("G1NM_Settings", "cmd", "fukyoself-1.0").args.Config.args.interrupts.args[self[3]].args[self[4]].args.interruptSpells.name
            if string == "Interrupt Nothing\n" then string = "" end
             G1NMACR:GetOptionsTable("G1NM_Settings", "cmd", "fukyoself-1.0").args.Config.args.interrupts.args[self[3]].args[self[4]].args.interruptSpells.name = string.."Interrupt "..value.."\n"
             G1NMACR:NotifyChange("G1NM_Settings")
            G1NM.saveSetting("garbageSave", true)
        end
    end

    delInterrupt = function(self, value)
        value = tostring(value) or value
        if tContains(G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][self[4]], value) then
            for k,v in ipairs(G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][self[4]]) do
                if v == value then G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(self[3])][self[4]][k] = nil break end
            end
            local stringText =  G1NMACR:GetOptionsTable("G1NM_Settings", "cmd", "fukyoself-1.0").args.Config.args.interrupts.args[self[3]].args[self[4]].args.interruptSpells.name
            stringText = string.gsub(stringText, "Interrupt "..value.."\n", "")
            stringText = stringText == "" and "Interrupt Nothing\n" or stringText
             G1NMACR:GetOptionsTable("G1NM_Settings", "cmd", "fukyoself-1.0").args.Config.args.interrupts.args[self[3]].args[self[4]].args.interruptSpells.name = stringText
             G1NMACR:NotifyChange("G1NM_Settings")
            G1NM.saveSetting("garbageSave", true)
        end
    end

    configSettingsInterrupts = {
        name = "Interrupts List",
        order = 2,
        type = "group",
        childGroups = "select",
        args = {},
    }

    rebuildInterruptList = function()
        local zoneList = {}
        for k,v in pairs(G1NMData.interruptTable) do
            table.insert(zoneList, v.ZoneName)
        end
        table.sort(zoneList)
        for i = 1, #zoneList do
            configSettingsInterrupts.args[zoneList[i]] = {
                name = zoneList[i],
                order = i,
                type = "group",
                args = {}
            }
            local secondIterationCounter = 0
            for k,v in pairs(G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(zoneList[i])]) do
                if k == "ZoneName" then
                    configSettingsInterrupts.args[zoneList[i]].args.addMob = {
                        name = "Add Mob",
                        desc = "Enter as \"ID, Name\"",
                        type = "input",
                        order = 0,
                        pattern = "%d+, .+",
                        usage = "Input should be in the format of \"digit(s), name\". Foe Example: \"000, abc\"",
                        set = addMob,
                    }
                    configSettingsInterrupts.args[zoneList[i]].args.delMob = {
                        name = "Delete Mob",
                        desc = "Enter as \"ID\"",
                        type = "input",
                        order = 0,
                        pattern = "^%d+$",
                        usage = "Input should be in the format of \"digit(s)\". Foe Example: \"000\"",
                        set = delMob,
                    }
                else
                    secondIterationCounter = secondIterationCounter + 1
                    configSettingsInterrupts.args[zoneList[i]].args[k] = {
                        name = G1NM.mobNameFromID(k),
                        order = secondIterationCounter,
                        type = "group",
                        args = {
                            addSpell = {
                                name = "Add Interrupt",
                                type = "input",
                                order = math.huge,
                                set = addInterrupt,
                            },
                            delSpell = {
                                name = "Del Interrupt",
                                type = "input",
                                order = math.huge,
                                set = delInterrupt,
                            },
                            printID = {
                                name = "Print Mob ID",
                                type = "execute",
                                order = math.huge,
                                func = function() print(k) end,
                            }
                        }
                    }
                    local string = ""
                    for r,c in ipairs(G1NMData.interruptTable[G1NM.getZoneInterruptsFromName(zoneList[i])][k]) do
                        string = string.."Interrupt "..c.."\n"
                    end
                    configSettingsInterrupts.args[zoneList[i]].args[k].args["interruptSpells"] = {
                        name = string,
                        order = 1,
                        type = "description"
                    }
                end
            end
        end
    end
    rebuildInterruptList()

    animalIDsDescription = "Mob IDs to Ignore:\n\n"
    setAnimalIDs = function()
        local string = "Mob IDs to Ignore:\n\n"
        for i = 1, #G1NMData.animalIDsToIgnore do
            string = string..""..G1NMData.animalIDsToIgnore[i]..", -- "..(G1NMData.mobNames[tostring(G1NMData.animalIDsToIgnore[i])] and G1NMData.mobNames[tostring(G1NMData.animalIDsToIgnore[i])].."\n" or "\n")
        end
        animalIDsDescription = string
    end
    setAnimalIDs()

    getAnimalIDs = function() return animalIDsDescription end

    animalIDs = {
        name = "Mob IDs to Ignore",
        type = "group",
        order = 1,
        args = {
            addBoss = {
                name = "ID to add",
                desc = "Enter as \"ID, Name\"",
                type = "input",
                order = 1,
                pattern = "%d+, .+",
                usage = "Input should be in the format of \"digits, name\". For example: \"000, abc\"",
                set = function(i, v) local id = string.match(v, "%d+") id = tonumber(id) local name = string.gsub(string.match(v, ", .+"), ", ", "") if id and not tContains(G1NMData.animalIDsToIgnore, id) then table.insert(G1NMData.animalIDsToIgnore, id) G1NMData.mobNames[""..id] = name end setAnimalIDs(); G1NM.saveSetting("garbageSave", true) end,
            },
            delBoss = {
                name = "ID to delete",
                desc = "Enter ID",
                type = "input",
                order = 2,
                pattern = "^%d+$",
                usage = "Input only the id.",
                set = function(i,v) local id = tonumber(v) if id and tContains(G1NMData.animalIDsToIgnore, id) then for i = #G1NMData.animalIDsToIgnore, 1, -1 do if G1NMData.animalIDsToIgnore[i] == id then table.remove(G1NMData.animalIDsToIgnore, i) G1NMData.mobNames[""..id] = nil break end end end setAnimalIDs() G1NM.saveSetting("garbageSave", true) end,
            },
            addCurBoss = {
                name = "Add Current Target",
                type = "execute",
                order = 3,
                func = function() if not UnitExists("target") then print("No target to add.") return end local id = ObjectID("target"); if not tContains(G1NMData.animalIDsToIgnore, id) then table.insert(G1NMData.animalIDsToIgnore, id); G1NMData.mobNames[""..id] = UnitName("target") end setAnimalIDs(); G1NM.saveSetting("garbageSave", true) end,
            },
            delCurBoss = {
                name = "Delete Current Target",
                type = "execute",
                order = 4,
                func = function() if not UnitExists("target") then print("No target to delete.") return end local id = ObjectID("target"); if tContains(G1NMData.animalIDsToIgnore, id) then for i = #G1NMData.animalIDsToIgnore, 1, -1 do if G1NMData.animalIDsToIgnore[i] == id then table.remove(G1NMData.animalIDsToIgnore, i); G1NMData.mobNames[""..id] = nil break end end; end setAnimalIDs(); G1NM.saveSetting("garbageSave", true) end,
            },
            bossList = {
                name = getAnimalIDs,
                type = "description",
            },
        }
    }

    animalAurasDescription = "Mob Aura IDs to Ignore:\n\n"
    setAnimalAuras = function()
        local string = "Mob Aura IDs to Ignore:\n\n"
        for i = 1, #G1NMData.animalAuraIDsToIgnore do
            string = string..""..G1NMData.animalAuraIDsToIgnore[i]..", -- "..(G1NMData.spellNames[tostring(G1NMData.animalAuraIDsToIgnore[i])] and G1NMData.spellNames[tostring(G1NMData.animalAuraIDsToIgnore[i])].."\n" or "\n")
        end
        animalAurasDescription = string
    end
    setAnimalAuras()
    getAnimalAuras = function() return animalAurasDescription end

    animalAuras = {
        name = "Mob Aura IDs to Ignore",
        type = "group",
        order = 2,
        args = {
            addBoss = {
                name = "Aura ID to add",
                desc = "Enter as \"ID, Name\"",
                type = "input",
                order = 1,
                pattern = "%d+, .+",
                usage = "Input should be in the format of \"digits, name\". For example: \"000, abc\"",
                set = function(i, v) local id = string.match(v, "%d+") id = tonumber(id) local name = string.gsub(string.match(v, ", .+"), ", ", "") if id and not tContains(G1NMData.animalAuraIDsToIgnore, id) then table.insert(G1NMData.animalAuraIDsToIgnore, id) G1NMData.spellNames[""..id] = name end setAnimalAuras() G1NM.saveSetting("garbageSave", true) end,
            },
            delBoss = {
                name = "Aura ID to delete",
                desc = "Enter ID",
                type = "input",
                order = 2,
                pattern = "^%d+$",
                usage = "Input only the id.",
                set = function(i,v) local id = tonumber(v) if id and tContains(G1NMData.animalAuraIDsToIgnore, id) then for i = #G1NMData.animalAuraIDsToIgnore, 1, -1 do if G1NMData.animalAuraIDsToIgnore[i] == id then table.remove(G1NMData.animalAuraIDsToIgnore, i) G1NMData.spellNames[""..id] = nil break end end end setAnimalAuras() G1NM.saveSetting("garbageSave", true) end,
            },
            bossList = {
                name = getAnimalAuras,
                type = "description",
            },
        }
    }

    animalTypesDescription = "DON'T TOUCH THIS IF YOU DON'T KNOW WHAT YOU'RE DOING!\n\"Not specified\" has had a bad and good history, I recommend blocking the mob ID instead of this type\nMob Types To Ignore:\n\n"

    setAnimalTypes = function()
        local string = "DON'T TOUCH THIS IF YOU DON'T KNOW WHAT YOU'RE DOING!\n"
        string = string.."\"Not specified\" has had a bad and good history, I recommend blocking the mob ID instead of this type\nMob Types To Ignore:\n\n"
        for i = 1, #G1NMData.animalTypesToIgnore do
            string = string..""..G1NMData.animalTypesToIgnore[i].."\n"
        end
        animalTypesDescription = string
    end
    setAnimalTypes()

    getAnimalTypes = function() return animalTypesDescription end

    animalTypes = {
        name = "Mob Types to Ignore",
        type = "group",
        order = 3,
        args = {
            addBoss = {
                name = "Type to add",
                -- desc = "Enter as \"ID, Name\"",
                type = "input",
                order = 1,
                -- pattern = "%d+, .+",
                -- usage = "Input should be in the format of \"digits, name\". For example: \"000, abc\"",
                set = function(i, v) if not tContains(G1NMData.animalTypesToIgnore, v) then table.insert(G1NMData.animalTypesToIgnore, v) end setAnimalTypes() G1NM.saveSetting("garbageSave", true) end,
            },
            delBoss = {
                name = "Boss ID to delete",
                -- desc = "Enter ID",
                type = "input",
                order = 2,
                -- pattern = "^%d+$",
                -- usage = "Input only the id.",
                set = function(i,v) if tContains(G1NMData.animalTypesToIgnore, v) then for i = #G1NMData.animalTypesToIgnore, 1, -1 do if G1NMData.animalTypesToIgnore[i] == v then table.remove(G1NMData.animalTypesToIgnore, i) break end end end setAnimalTypes() G1NM.saveSetting("garbageSave", true) end,
            },
            bossList = {
                name = getAnimalTypes,
                type = "description",
            },
        }
    }

    healingListDescription = ""
    setHealingListDescription = function()
        local healMode = G1NMData[G1NM.playerFullName].healingListMode == 1 and "white" or "black" 
        local string = (healMode == "white" and "Only " or "Not ").."healing these people:\n"
        for i = 1, #G1NMData[G1NM.playerFullName][healMode == "white" and "healingWhiteList" or "healingBlackList"] do
            string = string..""..(G1NMData.playerNames[G1NMData[G1NM.playerFullName][healMode == "white" and "healingWhiteList" or "healingBlackList"][i]] or "NO NAME").."\n"
        end
        healingListDescription = string
    end
    setHealingListDescription()

    getHealingListDescription = function() return healingListDescription end

    humansOM = {
        name = "Player Settings",
        type = "group",
        order = 2,
        childGroups = "tab",
        hidden = function() return false end,
        args = {
            healingListMode = {
                name = "Black/White list",
                order = 1,
                type = "group",
                args = {
                    ListMode = {
                        name = "Whitelist or Blacklist Certain Group Members",
                        order = 1,
                        type = "select",
                        values = {"Whitelist", "Blacklist"},
                        width = "double",
                        get = function() return G1NMData[G1NM.playerFullName].healingListMode end,
                        set = function(i,v) G1NM.saveSetting("healingListMode", v); setHealingListDescription() end,
                    },
                    AddTarget = {
                        name = "Add Current Target to List",
                        order = 2,
                        type = "execute",
                        func = function() if not UnitExists("target") then return end if not tContains(G1NMData[G1NM.playerFullName][G1NMData[G1NM.playerFullName].healingListMode == 1 and "healingWhiteList" or "healingBlackList"], UnitGUID("target")) then table.insert(G1NMData[G1NM.playerFullName][G1NMData[G1NM.playerFullName].healingListMode == 1 and "healingWhiteList" or "healingBlackList"], UnitGUID("target")); G1NMData.playerNames[UnitGUID("target")] = UnitName("target") end; G1NM.saveSetting("garbageSave", true); setHealingListDescription() end,
                    },
                    DelTarget = {
                        name = "Delete Current Target from List",
                        order = 3,
                        type = "execute",
                        func = function() if not UnitExists("target") then return end if tContains(G1NMData[G1NM.playerFullName][G1NMData[G1NM.playerFullName].healingListMode == 1 and "healingWhiteList" or "healingBlackList"], UnitGUID("target")) then for i = #G1NMData[G1NM.playerFullName][G1NMData[G1NM.playerFullName].healingListMode == 1 and "healingWhiteList" or "healingBlackList"], 1, -1 do if G1NMData[G1NM.playerFullName][G1NMData[G1NM.playerFullName].healingListMode == 1 and "healingWhiteList" or "healingBlackList"][i] == UnitGUID("target") then table.remove(G1NMData[G1NM.playerFullName][G1NMData[G1NM.playerFullName].healingListMode == 1 and "healingWhiteList" or "healingBlackList"], i) end end end; G1NM.saveSetting("garbageSave", true); setHealingListDescription() end,
                    },
                    ListDescription = {
                        name = getHealingListDescription,
                        type = "description",
                    },
                },
            },
            DispelEngine = {
                name = "Dispel Engine",
                order = 2,
                type = "group",
                args = {}
            },
        }
    }
    animalsOM = {
        name = "Mob Settings",
        type = "group",
        order = 1,
        childGroups = "select",
        disabled = false,
        hidden = function() return false end,
        args = {
            typesToIgnore = animalTypes,
            aurasToIgnore = animalAuras,
            idsToIgnore = animalIDs,
        },
    }

    configSettingsOM = {
        name = "OM Settings",
        type = "group",
        order = 3,
        childGroups = "select",
        -- disabled = true,
        hidden = function() return false end,
        args = {
            healing = humansOM,
            dps = animalsOM,
        },
    }

    bossListDescription = "Boss List:\n\n"

    getBossList = function()
        return bossListDescription
    end

    setBossList = function()
        local string = "Boss List:\n\n"
        for i = 1, #G1NMData.bossIDList do
            string = string..""..G1NMData.bossIDList[i]..", -- "..(G1NMData.mobNames[""..G1NMData.bossIDList[i]] and G1NMData.mobNames[""..G1NMData.bossIDList[i]].."\n" or "\n")
        end
        bossListDescription = string
    end
    setBossList()

    bossIDList = {
        name = "Boss IDs",
        type = "group",
        order = 2,
        hidden = function() return false end,
        args = {
            addBoss = {
                name = "Boss ID to add",
                desc = "Enter as \"ID, Name\"",
                type = "input",
                order = 1,
                pattern = "%d+, .+",
                usage = "Input should be in the format of \"digits, name\". For example: \"000, abc\"",
                set = function(i, v) local id = string.match(v, "%d+") id = tonumber(id) local name = string.gsub(string.match(v, ", .+"), ", ", "") if id and not tContains(G1NMData.bossIDList, id) then table.insert(G1NMData.bossIDList, id) G1NMData.mobNames[""..id] = name end setBossList() G1NM.saveSetting("garbageSave", true) end,
            },
            delBoss = {
                name = "Boss ID to delete",
                desc = "Enter ID",
                type = "input",
                order = 2,
                pattern = "^%d+$",
                usage = "Input only the id.",
                set = function(i,v) local id = tonumber(v) if id and tContains(G1NMData.bossIDList, id) then for i = #G1NMData.bossIDList, 1, -1 do if G1NMData.bossIDList[i] == id then table.remove(G1NMData.bossIDList, i) G1NMData.mobNames[""..id] = nil break end end end setBossList() G1NM.saveSetting("garbageSave", true) end,
            },
            addCurrentBossTarget = {
                name = "Add Current Target to Boss IDs",
                type = "execute",
                order = 3,
                func = function(i, v) if not UnitExists("target") then return end local id = ObjectID("target") local name = UnitName("target") if id and not tContains(G1NMData.bossIDList, id) then table.insert(G1NMData.bossIDList, id) G1NMData.mobNames[""..id] = name end setBossList() G1NM.saveSetting("garbageSave", true) end,
            },
            delCurrentBossTarget = {
                name = "Delete Current Target from Boss IDsoss ID to delete",
                type = "execute",
                order = 4,
                func = function(i,v) if not UnitExists("target") then return end local id = ObjectID("target") if id and tContains(G1NMData.bossIDList, id) then for i = #G1NMData.bossIDList, 1, -1 do if G1NMData.bossIDList[i] == id then table.remove(G1NMData.bossIDList, i) G1NMData.mobNames[""..id] = nil break end end end setBossList() G1NM.saveSetting("garbageSave", true) end,
            },
            bossList = {
                name = getBossList,
                type = "description",
            },
        },
    }

    dummyListDescription = "Dummy List:\n\n"

    getDummyList = function()
        return dummyListDescription
    end

    setDummyList = function()
        local string = "Dummy List:\n\n"
        for i = 1, #G1NMData.dummiesIDList do
            string = string..""..G1NMData.dummiesIDList[i]..", -- "..(G1NMData.mobNames[""..G1NMData.dummiesIDList[i]] and G1NMData.mobNames[""..G1NMData.dummiesIDList[i]].."\n" or "\n")
        end
        dummyListDescription = string
    end
    setDummyList()

    dummiesIDList = {
        name = "Dummy IDs",
        type = "group",
        order = 3,
        -- childGroups = "",
        hidden = function() return false end,
        args = {
            addBoss = {
                name = "Dummy ID to add",
                desc = "Enter as \"ID, Name\"",
                type = "input",
                order = 1,
                pattern = "%d+, .+",
                usage = "Input should be in the format of \"digits, name\". For example: \"000, abc\"",
                set = function(i, v) local id = string.match(v, "%d+") id = tonumber(id) local name = string.gsub(string.match(v, ", .+"), ", ", "") if id and not tContains(G1NMData.dummiesIDList, id) then table.insert(G1NMData.dummiesIDList, id) G1NMData.mobNames[""..id] = name end setDummyList() G1NM.saveSetting("garbageSave", true) end,
            },
            delBoss = {
                name = "Dummy ID to delete",
                desc = "Enter ID",
                type = "input",
                order = 2,
                pattern = "^%d+$",
                usage = "Input only the id.",
                set = function(i,v) local id = tonumber(v) if id and tContains(G1NMData.dummiesIDList, id) then for i = #G1NMData.dummiesIDList, 1, -1 do if G1NMData.dummiesIDList[i] == id then table.remove(G1NMData.dummiesIDList, i) G1NMData.mobNames[""..id] = nil break end end end setDummyList() G1NM.saveSetting("garbageSave", true) end,
            },
            addCurrentBoss = {
                name = "Add Current Target to Dummy IDs",
                type = "execute",
                order = 3,
                func = function(i, v) if not UnitExists("target") then return end; local id = ObjectID("target") local name = UnitName("target") if id and not tContains(G1NMData.dummiesIDList, id) then table.insert(G1NMData.dummiesIDList, id) G1NMData.mobNames[""..id] = name end setDummyList() G1NM.saveSetting("garbageSave", true) end,
            },
            delCurrentBoss = {
                name = "Delete Current Target from Dummy IDs",
                type = "execute",
                order = 4,
                func = function(i,v) if not UnitExists("target") then return end; local id = ObjectID("target") if id and tContains(G1NMData.dummiesIDList, id) then for i = #G1NMData.dummiesIDList, 1, -1 do if G1NMData.dummiesIDList[i] == id then table.remove(G1NMData.dummiesIDList, i) G1NMData.mobNames[""..id] = nil break end end end setDummyList() G1NM.saveSetting("garbageSave", true) end,
            },
            bossList = {
                name = getDummyList,
                type = "description",
            },
        },
    }

    skipLoSListDescription = "Skip LoS of these mobs:\n\n"

    getSkipLoSList = function()
        return skipLoSListDescription
    end

    setSkipLoSList = function()
        local string = "Skip LoS of these mobs:\n\n"
        for i = 1, #G1NMData.skipLoSIDList do
            string = string..""..G1NMData.skipLoSIDList[i]..", -- "..(G1NMData.mobNames[""..G1NMData.skipLoSIDList[i]] and G1NMData.mobNames[""..G1NMData.skipLoSIDList[i]].."\n" or "\n")
        end
        skipLoSListDescription = string
    end
    setSkipLoSList()

    skipLoSList = {
        name = "Skip LoS IDs",
        type = "group",
        order = 4,
        -- childGroups = "",
        hidden = function() return false end,
        args = {
            addBoss = {
                name = "ID to add",
                desc = "Enter as \"ID, Name\"",
                type = "input",
                order = 1,
                pattern = "%d+, .+",
                usage = "Input should be in the format of \"digits, name\". For example: \"000, abc\"",
                set = function(i, v) local id = string.match(v, "%d+") id = tonumber(id) local name = string.gsub(string.match(v, ", .+"), ", ", "") if id and not tContains(G1NMData.skipLoSIDList, id) then table.insert(G1NMData.skipLoSIDList, id) G1NMData.mobNames[""..id] = name end setSkipLoSList() G1NM.saveSetting("garbageSave", true) end,
            },
            delBoss = {
                name = "ID to delete",
                desc = "Enter ID",
                type = "input",
                order = 2,
                pattern = "^%d+$",
                usage = "Input only the id.",
                set = function(i,v) local id = tonumber(v) if id and tContains(G1NMData.skipLoSIDList, id) then for i = #G1NMData.skipLoSIDList, 1, -1 do if G1NMData.skipLoSIDList[i] == id then table.remove(G1NMData.skipLoSIDList, i) G1NMData.mobNames[""..id] = nil break end end end setSkipLoSList() G1NM.saveSetting("garbageSave", true) end,
            },
            addCurrentBoss = {
                name = "Add Current Target's ID",
                type = "execute",
                order = 3,
                func = function(i, v) if not UnitExists("target") then return end; local id = ObjectID("target"); local name = UnitName("target") if id and not tContains(G1NMData.skipLoSIDList, id) then table.insert(G1NMData.skipLoSIDList, id) G1NMData.mobNames[""..id] = name end setSkipLoSList() G1NM.saveSetting("garbageSave", true) end,
            },
            delCurrentBoss = {
                name = "Delete Current Target's ID",
                type = "execute",
                order = 4,
                func = function(i,v) if not UnitExists("target") then return end; local id = ObjectID("target"); if id and tContains(G1NMData.skipLoSIDList, id) then for i = #G1NMData.skipLoSIDList, 1, -1 do if G1NMData.skipLoSIDList[i] == id then table.remove(G1NMData.skipLoSIDList, i) G1NMData.mobNames[""..id] = nil break end end end setSkipLoSList() G1NM.saveSetting("garbageSave", true) end,
            },
            bossList = {
                name = getSkipLoSList,
                type = "description",
            },
        },
    }

    configSettingsIDs = {
        name = "IDs Settings",
        type = "group",
        order = 4,
        childGroups = "select",
        -- disabled = true,
        hidden = function() return false end,
        args = {
            skipLoS = skipLoSList,
            bosses = bossIDList,
            dummies = dummiesIDList,
        },
    }

    configSettingsTable = {
        name = "Config Settings",
        type = "group",
        order = 3,
        hidden = function() return false end,
        childGroups = "tab",
        args = {
            randomization = configSettingsRandomization,
            om = configSettingsOM,
            ids = configSettingsIDs,
            interrupts = configSettingsInterrupts,
        },
    }

    renderSettingsTable = {
        name = "WoW Render Settings",
        type = "group",
        order = 4,
        hidden = function() return false end,
        args = {
            Player = {
                order = 1,
                type = "toggle",
                name = "Player",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderPlayer end,
                set = function(i,v) G1NM.saveSetting("renderPlayer", v) end
            },
            PlayersPets = {
                order = 2,
                type = "toggle",
                name = "Player's Pets",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderPlayersPets end,
                set = function(i,v) G1NM.saveSetting("renderPlayersPets", v) end
            },
            HarmPlayers = {
                order = 3,
                type = "toggle",
                name = "Enemy Players",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderHarmPlayers end,
                set = function(i,v) G1NM.saveSetting("renderHarmPlayers", v) end
            },
            HarmPlayersPets = {
                order = 4,
                type = "toggle",
                name = "Enemy Players' Pets",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderHarmPlayersPets end,
                set = function(i,v) G1NM.saveSetting("renderHarmPlayersPets", v) end
            },
            HelpPlayers = {
                order = 5,
                type = "toggle",
                name = "Friendly Players",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderHelpPlayers end,
                set = function(i,v) G1NM.saveSetting("renderHelpPlayers", v) end
            },
            HelpPlayersPets = {
                order = 6,
                type = "toggle",
                name = "Friendly Players' Pets",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderHelpPlayersPets end,
                set = function(i,v) G1NM.saveSetting("renderHelpPlayersPets", v) end
            },
            HarmMobs = {
                order = 7,
                type = "toggle",
                name = "Enemy Mobs",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderHarmMobs end,
                set = function(i,v) G1NM.saveSetting("renderHarmMobs", v) end
            },
            HelpMobs = {
                order = 8,
                type = "toggle",
                name = "Friendly Mobs",
                disabled = true,
                get = function() return G1NMData[G1NM.playerFullName].renderHelpMobs end,
                set = function(i,v) G1NM.saveSetting("renderHelpMobs", v) end
            },
        }
    }

    debugSettingsTable = {
        name = "Debug Settings",
        type = "group",
        order = math.huge,
        hidden = function() return false end,
        args = {
            Log = {
                order = 1.3,
                type = "toggle",
                name = "Log",
                get = function() return G1NMData[G1NM.playerFullName].log end,
                set = function(i,v) G1NM.saveSetting("log", v) end
            },
            collectInfo = {
                order = 1.2,
                type = "toggle",
                name = "Info Collection",
                get = function() return G1NMData[G1NM.playerFullName].collectInfo end,
                set = function(i,v) G1NM.saveSetting("collectInfo", v) end,
            },
            Dummy = {
                order = 1.1,
                type = "select",
                name = "Dummy TTD",
                values = {"Mixed Mode", "Execute", "Healthy"},
                get = function() return G1NMData[G1NM.playerFullName].dummyTTDMode or 1 end,
                set = function(i,v) G1NM.saveSetting("dummyTTDMode", v) end
            },
            logFile = {
                order = 1.4,
                type = "input",
                name = "Log File Path",
                get = function() return G1NMData.logFile end,
                set = function(i,v) G1NMData.logFile = v; G1NM.saveSetting("garbageSave", true) end,
            },
            ClearLogFile = {
                order = 1.5,
                type = "execute",
                name = "Clear Log File",
                func = function() WriteFile(G1NMData.logFile, "") end
            }
        }
    }

    createOptionsTable = function()
        -- if not G1AC then return end
        local options = {
            type = "group",
            name = (G1NM.GetAddonName().." Settings"),
            args = {
                General = generalSettingsTable,
                -- -- KeyBindings = keybindsSettingsTable,
                Rogue = G1NM.ROGUE.settingsTable,
                -- DeathKnight = G1NM.DEATHKNIGHT.settingsTable,
                -- DemonHunter = G1NM.DEMONHUNTER.settingsTable,
                -- Druid = G1NM.DRUID.settingsTable,
                -- Monk = G1NM.MONK.settingsTable,
                -- Priest = G1NM.PRIEST.settingsTable,
                -- Hunter = G1NM.HUNTER.settingsTable,
                Config = configSettingsTable,
                Render = renderSettingsTable,
                Debug = debugSettingsTable,
            }
        }
        G1NMACR:RegisterOptionsTable("G1NM_Settings", options)
    end
    local function openOptions()
         G1NMACD:Open("G1NM_Settings")
    end
    local function openGameMenuFrame()
        GameMenuFrame:Show()
    end
    function G1NM.SetAddonName(string)
        if PlayerFrame.name:IsVisible() then PlayerFrame.name:Hide() end
        local flagKeybindings = false
        local flagOptionsTable = false
        if not G1NM.categoryButtonNumber then
            if not KeyBindingFrame or not KeyBindingFrame:IsVisible() then
                flagKeybindings = true
                if not GameMenuButtonKeybindings then GameMenuFrame:Show() end
                GameMenuButtonKeybindings:Click()
            end
            for i = 1, 1000 do
                if not _G["KeyBindingFrameCategoryListButton"..i] then break end
                if _G["KeyBindingFrameCategoryListButton"..i]:GetText() == G1NM.GetAddonName() or _G["KeyBindingFrameCategoryListButton"..i]:GetText() == "G1NM " then G1NM.categoryButtonNumber = i break end
            end
        end
        G1NM.AddonName = type(string) == "string" and string or G1NM.AddonName
        if GameMenuFrame:IsVisible() then HideUIPanel(GameMenuFrame) C_Timer.After(0, openGameMenuFrame) end
        if not IsAddOnLoaded("ConsolePortUI_Menu") then GameMenuFrame["G1NM"]:SetText(G1NM.GetAddonName()) end
        if AceGUI30TreeButton1 and AceGUI30TreeButton1:IsVisible() then
             G1NMACD:Close("G1NM_Settings")
            C_Timer.After(0, openOptions)
            -- flagOptionsTable = true
        end
        createOptionsTable()
        -- C_Timer.After(0, createOptionsTable)
        if flagOptionsTable then
            C_Timer.After(0, openOptions)
        end
        _G["KeyBindingFrameCategoryListButton"..G1NM.categoryButtonNumber]:SetText(G1NM.AddonName)
        if flagKeybindings then HideUIPanel(KeyBindingFrame); HideUIPanel(GameMenuFrame) end
    end

local relativeTo
local function FixHeight()
    -- if relativeTo ~= "GameMenuButtonAddons" then
    --     local function SetModifiedBackdrop(self)
    --         --[[GameMenuButtonAddons_Trampoline]]self:SetBackdropBorderColor(unpack(ElvUI[1]["media"].rgbvaluecolor))
    --     end

    --     local function SetOriginalBackdrop(self)
    --         --[[GameMenuButtonAddons_Trampoline]]self:SetBackdropBorderColor(unpack(ElvUI[1]["media"].bordercolor))
    --     end

    --     local function HandleButton(f, strip)
    --         assert(f, "doesn't exist!")
    --         if f.Left then f.Left:SetAlpha(0) end
    --         if f.Middle then f.Middle:SetAlpha(0) end
    --         if f.Right then f.Right:SetAlpha(0) end
    --         if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
    --         if f.RightSeparator then f.RightSeparator:SetAlpha(0) end

    --         if f.SetNormalTexture then f:SetNormalTexture("") end

    --         if f.SetHighlightTexture then f:SetHighlightTexture("") end

    --         if f.SetPushedTexture then f:SetPushedTexture("") end

    --         if f.SetDisabledTexture then f:SetDisabledTexture("") end

    --         if strip then f:StripTextures() end

    --         f:SetTemplate("Default", true)
    --         f:HookScript("OnEnter", SetModifiedBackdrop)
    --         f:HookScript("OnLeave", SetOriginalBackdrop)
    --     end

    --     HandleButton(GameMenuFrame["G1NM"])
    -- end
    -- if relativeTo == "GameMenuButtonAddons" then
        GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight()*(relativeTo == "GameMenuButtonAddons" and 1 or 1.125))
        local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
        if relTo ~= GameMenuFrame["G1NM"] then
            GameMenuFrame["G1NM"]:ClearAllPoints()
            GameMenuFrame["G1NM"]:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
            GameMenuButtonLogout:ClearAllPoints()
            -- GameMenuButtonLogout:SetPoint("TOPLEFT", GameMenuFrame.G1NM, "BOTTOMLEFT", 0, offY)
            GameMenuButtonLogout:SetPoint("TOPLEFT", (relativeTo == "GameMenuButtonAddons" and GameMenuFrame.G1NM or GameMenuFrame.ElvUI), "BOTTOMLEFT", 0, (relativeTo == "GameMenuButtonAddons" and -16 or -32)--[[offY*(relativeTo == "GameMenuButtonAddons" and 1 or 1.5)]])
        end
    -- end
end

if not IsAddOnLoaded("ConsolePort")--[[ and not IsAddOnLoaded("ElvUI")]] then
    local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
    GameMenuButton:SetText(G1NM.GetAddonName())
    GameMenuButton:SetScript("OnClick", function()
        G1NM.Toggle("o")
        HideUIPanel(GameMenuFrame)
    end)
    GameMenuFrame["G1NM"] = GameMenuButton

    relativeTo = IsAddOnLoaded("ElvUI") and GameMenuFrame.ElvUI or "GameMenuButtonAddons"
    GameMenuButton:SetSize(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
    GameMenuButton:SetPoint("TOPLEFT", (relativeTo == "GameMenuButtonAddons" and GameMenuButtonAddons or GameMenuFrame.ElvUI), "BOTTOMLEFT", 0, -1)
    hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', FixHeight)
-- elseif not IsAddOnLoaded("ConsolePort") and IsAddOnLoaded("ElvUI") then
    -- local GameMenuButton = CreateFrame("Button", nil, GameMenuFrame, "GameMenuButtonTemplate")
    -- GameMenuButton:SetText(G1NM.GetAddonName())
    -- GameMenuButton:SetScript("OnClick", function()
    --     G1NM.Toggle("o")
    --     HideUIPanel(GameMenuFrame)
    -- end)
    -- GameMenuFrame["G1NM"] = GameMenuButton

    -- relativeTo = "GameMenuButtonAddons_Trampoline"
    -- GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
    -- GameMenuButtonAddons_Trampoline = GameMenuButtonAddons
    -- GameMenuButtonAddons = GameMenuFrame["G1NM"]
    -- GameMenuButton:SetPoint("TOPLEFT", GameMenuButtonAddons_Trampoline, "BOTTOMLEFT", 0, -1)

    if relativeTo == GameMenuFrame.ElvUI then
        local function SetModifiedBackdrop()
            -- GameMenuButtonAddons_Trampoline:SetBackdropBorderColor(unpack(ElvUI[1]["media"].rgbvaluecolor))
        end

        local function SetOriginalBackdrop()
            -- GameMenuButtonAddons_Trampoline:SetBackdropBorderColor(unpack(ElvUI[1]["media"].bordercolor))
        end

        local function HandleButton(f, strip)
            assert(f, "doesn't exist!")
            if f.Left then f.Left:SetAlpha(0) end
            if f.Middle then f.Middle:SetAlpha(0) end
            if f.Right then f.Right:SetAlpha(0) end
            if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
            if f.RightSeparator then f.RightSeparator:SetAlpha(0) end

            if f.SetNormalTexture then f:SetNormalTexture("") end

            if f.SetHighlightTexture then f:SetHighlightTexture("") end

            if f.SetPushedTexture then f:SetPushedTexture("") end

            if f.SetDisabledTexture then f:SetDisabledTexture("") end

            if strip then f:StripTextures() end

            f:SetTemplate("Default", true)
            f:HookScript("OnEnter", SetModifiedBackdrop)
            f:HookScript("OnLeave", SetOriginalBackdrop)
        end

        HandleButton(GameMenuFrame.G1NM)
    end
end

function G1NM.setTalentRemove()
    -- local hide
    -- if not PlayerTalentFrame then ToggleTalentFrame() hide = true end
    -- local frame
    -- local function rightClickRemove(self, button, down)
    --     if button == "RightButton" then
    --         for r = 1, 7 do
    --             for c = 1, 3 do
    --                 frame = _G["PlayerTalentFrameTalentsTalentRow"..r.."Talent"..c]
    --                 if frame and frame:IsVisible() and frame:IsMouseOver() then RemoveTalent(GetTalentInfo(r, c, 1)) RemoveTalent(GetTalentInfo(r, c, 1)) end
    --             end
    --         end
    --     end
    -- end

    -- for r = 1, 7 do
    --     for c = 1, 3 do
    --         frame = _G["PlayerTalentFrameTalentsTalentRow"..r.."Talent"..c]
    --         if frame then frame:SetScript("PostClick", rightClickRemove) end
    --     end
    -- end
    -- if hide then HideUIPanel(PlayerTalentFrame) end
end
print("G1NM: #1 Config UI LOADED SUCCESSFULLY")
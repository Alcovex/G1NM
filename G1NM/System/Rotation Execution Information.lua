local _ = nil
local setColorAndName

function G1NM.createMainFrame()
    G1NMData[G1NM.playerFullName].class = select(2, UnitClass("player"))
    G1NMData[G1NM.playerFullName].race = select(2, UnitRace("player"))
    G1NM.currentSpec = G1NM.currentSpec or GetSpecialization()
    if not G1NM.cacheTalentsQueued then C_Timer.After(3, G1NM.cacheTalents); G1NM.cacheTalentsQueued = true end
    if not G1NM.cacheGearQueued then C_Timer.After(3, G1NM.cacheGear); G1NM.cacheGearQueued = true end

    G1NM.monitorAnimationToggle("off")
    G1NM.BNCur = select(2, BNGetInfo())
    -- G1NM.setTalentRemove()
    G1NM.SetAddonName()

    G1NM.animalsSize = 0
    G1NM.humansSize = 0
    G1NM.targetAnimals = {}
    G1NM.targetHumans = {}
    G1NM.TTDM, G1NM.TTD = {}, {}
    G1NM.combatStartTime = math.huge
    G1NM.createRotationEventFrame()


    CreateFrame("Frame", "G1NMMainFrame", nil)
    G1NMMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    G1NMMainFrame:RegisterEvent("LOADING_SCREEN_DISABLED")

    G1NMMainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    G1NMMainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
    G1NMMainFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

    G1NMMainFrame:SetScript("OnEvent", G1NM.respondMainFrame)
    G1NMMainFrame:SetScript("OnUpdate", G1NM.updateMainFrame)
end

function G1NM.respondMainFrame(self, originalEvent, ...)
    if originalEvent == "PLAYER_ENTERING_WORLD" then
        -- G1NMData[G1NM.playerFullName].class = select(2, UnitClass("player"))
        -- G1NM.currentSpec = G1NM.currentSpec or GetSpecialization()
        -- if not G1NM.cacheTalentsQueued then C_Timer.After(3, G1NM.cacheTalents); G1NM.cacheTalentsQueued = true end
        -- if not G1NM.cacheGearQueued then C_Timer.After(3, G1NM.cacheGear); G1NM.cacheGearQueued = true end

        -- G1NM.allowFrames = false
        -- G1NM.monitorAnimationToggle("off")
        -- G1NM.BNCur = select(2, BNGetInfo())
        -- G1NM.setTalentRemove()
        -- G1NM.SetAddonName()
    elseif originalEvent == "LOADING_SCREEN_DISABLED" then
        -- G1NM.allowFrames = true
        -- G1NM.allowRun  = false
        -- G1NM.monitorAnimationToggle("off")

        -- G1NM.animalsSize = 0
        -- G1NM.humansSize = 0
        -- G1NM.targetAnimals = {}
        -- G1NM.targetHumans = {}
        -- G1NM.TTDM, G1NM.TTD = {}, {}

        -- G1NM.combatStartTime = math.huge

        -- G1NM.createRotationEventFrame()
    elseif originalEvent == "PLAYER_SPECIALIZATION_CHANGED" then
        G1NM.currentSpec = GetSpecialization()
        C_Timer.After(0, setColorAndName)
        if not G1NM.cacheTalentsQueued then C_Timer.After(3, G1NM.cacheTalents); G1NM.cacheTalentsQueued = true end
    elseif originalEvent == "PLAYER_TALENT_UPDATE" then
        if not G1NM.cacheTalentsQueued then C_Timer.After(3, G1NM.cacheTalents); G1NM.cacheTalentsQueued = true end
    elseif originalEvent == "PLAYER_EQUIPMENT_CHANGED" then
        if not G1NM.cacheGearQueued then C_Timer.After(3, G1NM.cacheGear); G1NM.cacheGearQueued = true end
    end
end

G1NM.cacheTalentsQueued = false
function G1NM.cacheTalents()
    for r = 1, 7 do
        for c = 1, 3 do
            G1NM["talent"..r..c] = select(4, GetTalentInfo(r, c, 1))
        end
    end
    G1NM.cacheTalentsQueued = false
end

local gearCheck = {
    -- Back = 0,
    -- Chest = 0,
    -- -- Feet = 0,
    -- -- Finger0 = 0,
    -- -- Finger1 = 0,
    -- Hands = 0,
    -- Head = 0,
    -- Legs = 0,
    -- -- MainHand = 0,
    -- -- Neck = 0,
    -- -- SecondaryHand = 0,
    -- -- Shirt = 0,
    -- Shoulder = 0,
    -- -- Trinket0 = 0,
    -- -- Trinket1 = 0,
    -- -- Waist = 0,
    -- -- Wrist = 0,
}
local gearSets = {
    -- DEATHKNIGHT_SET = {
    --     ["tier19"] = {Chest = 138349, Hands = 138352, Head = 138355, Legs = 138358, Shoulder = 138361, Back = 138364,},
    --     ["tier20"] = {Chest = 147121, Hands = 147123, Head = 147124, Legs = 147125, Shoulder = 147126, Back = 147122,},
    -- },
    -- DEMONHUNTER_SET = {
    --     ["tier19"] = {Chest = 138376, Hands = 138377, Head = 138378, Legs = 138379, Shoulder = 138380, Back = 138375,},
    --     ["tier20"] = {Chest = 147127, Hands = 147129, Head = 147130, Legs = 147131, Shoulder = 147132, Back = 147128,},
    -- },
    -- DRUID_SET = {
    --     ["tier19"] = {Chest = 138324, Hands = 138327, Head = 138330, Legs = 138333, Shoulder = 138336, Back = 138366,},
    --     ["tier20"] = {Chest = 147133, Hands = 147135, Head = 147136, Legs = 147137, Shoulder = 147138, Back = 147134,},
    -- },
    -- HUNTER_SET = {
    --     ["tier19"] = {Chest = 138339, Hands = 138340, Head = 138342, Legs = 138344, Shoulder = 138347, Back = 138368,},
    --     ["tier20"] = {Chest = 147139, Hands = 147141, Head = 147142, Legs = 147143, Shoulder = 147144, Back = 147140,},
    -- },
    -- MAGE_SET = {
    --     ["tier19"] = {Chest = 138318, Hands = 138309, Head = 138312, Legs = 138315, Shoulder = 138321, Back = 138365,},
    --     ["tier20"] = {Chest = 147149, Hands = 147146, Head = 147147, Legs = 147148, Shoulder = 147150, Back = 147145,},
    -- },
    -- MONK_SET = {
    --     ["tier19"] = {Chest = 138325, Hands = 138328, Head = 138331, Legs = 138334, Shoulder = 138337, Back = 138367,},
    --     ["tier20"] = {Chest = 147151, Hands = 147153, Head = 147154, Legs = 147155, Shoulder = 147156, Back = 147152,},
    -- },
    -- PALADIN_SET = {
    --     ["tier19"] = {Chest = 138350, Hands = 138353, Head = 138356, Legs = 138359, Shoulder = 138362, Back = 138369,},
    --     ["tier20"] = {Chest = 147157, Hands = 147159, Head = 147160, Legs = 147161, Shoulder = 147162, Back = 147158,},
    -- },
    -- PRIEST_SET = {
    --     ["tier19"] = {Chest = 138319, Hands = 138310, Head = 138313, Legs = 138316, Shoulder = 138322, Back = 138370,},
    --     ["tier20"] = {Chest = 147167, Hands = 147164, Head = 147165, Legs = 147166, Shoulder = 147168, Back = 147163,},
    -- },
    -- ROGUE_SET = {
    --     ["tier19"] = {Chest = 138326, Hands = 138329, Head = 138332, Legs = 138335, Shoulder = 138338, Back = 138371,},
    --     ["tier20"] = {Chest = 147169, Hands = 147171, Head = 147172, Legs = 147173, Shoulder = 147174, Back = 147170,},
    -- },
    -- SHAMAN_SET = {
    --     ["tier19"] = {Chest = 138346, Hands = 138341, Head = 138343, Legs = 138345, Shoulder = 138348, Back = 138372,},
    --     ["tier20"] = {Chest = 147175, Hands = 147177, Head = 147178, Legs = 147179, Shoulder = 147180, Back = 147176,},
    -- },
    -- WARLOCK_SET = {
    --     ["tier19"] = {Chest = 138320, Hands = 138311, Head = 138314, Legs = 138317, Shoulder = 138323, Back = 138373,},
    --     ["tier20"] = {Chest = 147185, Hands = 147182, Head = 147183, Legs = 147184, Shoulder = 147186, Back = 147181,},
    -- },
    -- WARRIOR_SET = {
    --     ["tier19"] = {Chest = 138351, Hands = 138354, Head = 138357, Legs = 138360, Shoulder = 138363, Back = 138374,},
    --     ["tier20"] = {Chest = 147187, Hands = 147189, Head = 147190, Legs = 147191, Shoulder = 147192, Back = 147188,},
    -- },
}
local gear = {
    Ammo = 0,
    Back = 0,
    Chest = 0,
    Feet = 0,
    Finger0 = 0,
    Finger1 = 0,
    Hands = 0,
    Head = 0,
    Legs = 0,
    MainHand = 0,
    Neck = 0,
    SecondaryHand = 0,
    Shirt = 0,
    Shoulder = 0,
    Tabard = 0,
    Trinket0 = 0,
    Trinket1 = 0,
    Waist = 0,
    Wrist = 0,
}
G1NM.cacheGearQueued = false
function G1NM.cacheGear()
    -- for k,v in pairs(gear) do
    --    gear[k] = GetInventoryItemID("player", GetInventorySlotInfo(k.."Slot")) or 0
    -- end
    -- G1NM.equippedGear = gear
    
    -- if G1NM[G1NMData[G1NM.playerFullName].class] then
    --     local count
    --     for k,v in pairs(gearSets[G1NMData[G1NM.playerFullName].class.."_SET"]) do
    --         count = 0
    --         for i,d in pairs(gearCheck) do
    --             if G1NM.equippedGear[i] == v[i] then count = count + 1 end
    --         end
    --         G1NM[G1NMData[G1NM.playerFullName].class][k] = count
    --     end
    -- end

    -- if HasArtifactEquipped() then
    --     if not G1NM.artifactWeapon[gear.MainHand] then G1NM.artifactWeapon[gear.MainHand] = {weaponPerks = {}} end
    --     local closeAfter = false
    --     if not ArtifactFrame or not ArtifactFrame:IsShown() then
    --         closeAfter = true
    --         SocketInventoryItem(16)
    --     end

    --     local item_id = C_ArtifactUI.GetArtifactInfo()
    --     if not item_id or item_id == 0 then if ArtifactFrame:IsShown() and closeAfter then HideUIPanel(ArtifactFrame) return end end
    --     local powers = C_ArtifactUI.GetPowers()
    --     if not powers then G1NM.cacheGear() return end

    --     local spellID, perkCost, perkCurrentRank, perkMaxRank, perkBonusRanks, x, y, prereqsMet, isStart, isGoldMedal, isFinal
    --     for i = 1, #powers do
    --         local power_id = powers[i]
    --         local powerInfo = C_ArtifactUI.GetPowerInfo(power_id)
    --         G1NM.artifactWeapon[gear.MainHand].weaponPerks[powerInfo.spellID] = {
    --             -- cost = powerInfo.cost,
    --             currentRank = powerInfo.currentRank,
    --             maxRank = powerInfo.maxRank,
    --             bonusRanks = powerInfo.bonusRanks,
    --         }
    --     end
    --     if ArtifactFrame:IsShown() and closeAfter then HideUIPanel(ArtifactFrame) end
    -- end
    -- G1NM.cacheGearQueued = false
end

local colorAddonTable = {
    ["|cffff8000Animals"] = "ffff8000",
    ["Animals"] = "ffff8000",

    ["|cff00ff80Humans"] = "ff00ff80",
    ["Humans"] = "ff00ff80",

    ["|cff8000ffAliens"] = "ff8000ff",
    ["Aliens"] = "ff8000ff",
}
local addonNameTable = {
    ["DEATHKNIGHT1"] = "Aliens",
    ["DEATHKNIGHT2"] = "Animals",
    ["DEATHKNIGHT3"] = "Animals",
    ["DEMONHUNTER1"] = "Animals",
    ["DEMONHUNTER2"] = "Aliens",
    ["DRUID1"]       = "Animals",
    ["DRUID2"]       = "Animals",
    ["DRUID3"]       = "Aliens",
    ["DRUID4"]       = "Humans",
    ["HUNTER1"]      = "Animals",
    ["HUNTER2"]      = "Animals",
    ["HUNTER3"]      = "Animals",
    ["MAGE1"]        = "Animals",
    ["MAGE2"]        = "Animals",
    ["MAGE3"]        = "Animals",
    ["MONK1"]        = "Aliens",
    ["MONK2"]        = "Humans",
    ["MONK3"]        = "Animals",
    ["PALADIN1"]     = "Humans",
    ["PALADIN2"]     = "Aliens",
    ["PALADIN3"]     = "Animals",
    ["PRIEST1"]      = "Humans",
    ["PRIEST2"]      = "Humans",
    ["PRIEST3"]      = "Animals",
    ["ROGUE1"]       = "Animals",
    ["ROGUE2"]       = "Animals",
    ["ROGUE3"]       = "Animals",
    ["SHAMAN1"]      = "Animals",
    ["SHAMAN2"]      = "Animals",
    ["SHAMAN3"]      = "Humans",
    ["WARLOCK1"]     = "Animals",
    ["WARLOCK2"]     = "Animals",
    ["WARLOCK3"]     = "Animals",
    ["WARRIOR1"]     = "Animals",
    ["WARRIOR2"]     = "Animals",
    ["WARRIOR3"]     = "Aliens",
}
setColorAndName = function()
    if G1NM.AddonName ~= ("|c"..colorAddonTable[addonNameTable[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]]..addonNameTable[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]) then G1NM.SetAddonName("|c"..colorAddonTable[addonNameTable[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]]..addonNameTable[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]) end
end

local executeSpecs = {71, 72, 254, 258}
local executeCrossCheck = {}
-- TODO: set flagZone back to false somewhere
local flagZone = false
local inspectSet = 0
local elapsedTime = 0
local collectIteration = 0
function G1NM.updateMainFrame(self, elapsed)
    -- if G1NM.BNReq() and G1NM.BNCur and G1NM.BNCur ~= G1NM.BNReq() then C_Timer.After(5, G1NM.verificationFailed) return end
    -- if not G1NM.BNCur then G1NM.BNCur = select(2, BNGetInfo()) return end
    if G1NM.AddonName == "G1NM" then G1NM.SetAddonName("|c"..colorAddonTable[addonNameTable[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]]..addonNameTable[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]) end
    if G1NM.categoryButtonNumber and _G["KeyBindingFrameCategoryListButton"..G1NM.categoryButtonNumber]:GetText() == "G1 " then G1NM.SetAddonName(G1NM.AddonName) end
    if G1NM.allowRun then
        -- if not G1NM.ranOnce then
        --     if not G1NM.engineVersion then
        --         print(G1NM.AddonName..": Developer is a noob and didn't look at the orders properly or something wrong happened.")
        --     else
        --         -- DownloadURL("raw.githubusercontent.com", "/g1zstar/G1Version/master/Version.txt", true, G1NM.checkUpdate, G1NM.revisionCheckFailed)
        --     end
        --     G1NM.ranOnce = true
        -- end
        
        G1NM.randomNumberGenerator = math.random(G1NMData[G1NM.playerFullName].chaosMin, G1NMData[G1NM.playerFullName].chaosMax)*.001

        if G1NM.currentSpec and G1NM[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec] then
            -- if not G1NM["checked"..G1NMData[G1NM.playerFullName].class..G1NM.currentSpec.."Version"] then
            --     if G1NM.downloadedVersions[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec] then
            --         if G1NM.downloadedVersions[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec] > G1NM[G1NMData[G1NM.playerFullName].class][G1NM.currentSpec.."Version"] then print(G1NM.AddonName..": Rotation Update Available for "..(G1NMData[G1NM.playerFullName].class..G1NM.currentSpec)..". Latest Version: "..G1NM.downloadedVersions[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]..", Current Version: "..G1NM[G1NMData[G1NM.playerFullName].class][G1NM.currentSpec.."Version"]) end
            --         G1NM["checked"..G1NMData[G1NM.playerFullName].class..G1NM.currentSpec.."Version"] = true
            --     end
            -- end
            G1NM.iterationNumber = G1NM.iterationNumber + 1
            G1NM[G1NMData[G1NM.playerFullName].class..G1NM.currentSpec]()
        else
            print(G1NM.AddonName..": No idea how to "..(G1NM.AddonName == "Animals" and "slay with" or G1NM.AddonName == "Aliens" and "contain mobs with" or G1NM.AddonName == "Humans" and "heal with" or "run").." this combination.\n"..G1NMData[G1NM.playerFullName].class..G1NM.currentSpec)
            G1NM.allowRun = false
            G1NM.monitorAnimationToggle("off")
        end
    end

    if G1NMData[G1NM.playerFullName].collectInfo then
        G1NM.interruptFunction(nil, nil, true)
        G1NM.bossCollection()
        G1NM.dummyCollection()
        if G1NM.collectionTable.iteration > collectIteration then
            collectIteration = G1NM.collectionTable.iteration
            WriteFile("F:\\Downloads\\Compressed\\BrowsersRUs\\G1NMInfoCollection.json", json.encode(G1NM.collectionTable, {indent=true}))
        end
    end

    -- if not G1NM.allowFrames then return end

    if not G1NMData[G1NM.playerFullName].animals and G1NM.animalsSize > 0 then table.wipe(G1NM.targetAnimals) end
    if not G1NMData[G1NM.playerFullName].humans and G1NM.humansSize > 0 then table.wipe(G1NM.targetHumans) end

    local zone = C_Map.GetBestMapForUnit("player")
    for i = 351, 366 do
        if zone == i then flagZone = true end
    end
    for i = 794, 797 do
        if zone == i then flagZone = true end
    end
    for i = 809, 822 do
        if zone == i then flagZone = true end
    end

    G1NM.animalsSize = #G1NM.targetAnimals
    G1NM.humansSize = #G1NM.targetHumans

    elapsedTime = elapsedTime + elapsed

    if G1NMData[G1NM.playerFullName].objectManagerMode == 2 then -- Nameplates
        --[[relevant CVars
            nameplateMaxDistance = 0-100 default 60
            nameplateShowAll = 01 whether to show or not
            nameplateShowEnemies = 01
            nameplateShowFriends = 01
        ]]
        -- if elapsedTime >= 1 or not flagZone then
            elapsedTime = 0

            local unitPlaceholder = nil
            for i = 1, math.huge do
                if _G["NamePlate"..i] then
                    if _G["NamePlate"..i].UnitFrame.unitExists then
                        unitPlaceholder = ObjectPointer(_G["NamePlate"..i].UnitFrame.unit)
                        if ObjectIsUnit(unitPlaceholder)
                        and UnitIsVisible(unitPlaceholder)
                        and (not G1NMData[G1NM.playerFullName].animals or not tContains(G1NM.targetAnimals, unitPlaceholder))
                        then
                            if not ObjectIsPlayer(unitPlaceholder) then -- mobs
                                if G1NMData[G1NM.playerFullName].animals and not UnitInParty(unitPlaceholder) and G1NM.health(unitPlaceholder) > 0 and UnitCanAttack("player", unitPlaceholder) then -- hostile mobs
                                    if UnitName(unitPlaceholder) ~= UNKNOWNOBJECT and not tContains(G1NMData.animalTypesToIgnore, UnitCreatureType(unitPlaceholder)) and G1NM.animalsAuraBlacklist(unitPlaceholder) and G1NM.animalsIDBlacklist(unitPlaceholder) then
                                        G1NM.targetAnimals[G1NM.animalsSize+1] = unitPlaceholder
                                        G1NM.animalsSize = G1NM.animalsSize + 1
                                    end
                                end
                            end
                        end
                    end
                else
                    break
                end
            end
        -- end

        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if not G1NMData[G1NM.playerFullName].animals or not ObjectExists(unitPlaceholder) or UnitIsDeadOrGhost(unitPlaceholder) or not UnitCanAttack("player", unitPlaceholder) or not G1NM.animalsAuraBlacklist(unitPlaceholder) then _G["removeTargetAnimals"..i] = true end
        end
        for i = G1NM.animalsSize, 1, -1 do
            if _G["removeTargetAnimals"..i] then
                table.remove(G1NM.targetAnimals, i)
                _G["removeTargetAnimals"..i] = false
            end
        end

        for i = 1, G1NM.humansSize do
            unitPlaceholder = G1NM.targetHumans[i].player
            if not G1NMData[G1NM.playerFullName].humans or not ObjectExists(unitPlaceholder) or UnitName(unitPlaceholder) == "Unknown" or (not UnitInParty(unitPlaceholder) and not UnitIsUnit("player", unitPlaceholder)) then _G["removeTargetHumans"..i] = true end
        end
        for i = G1NM.humansSize, 1, -1 do
            if _G["removeTargetHumans"..i] then
                table.remove(G1NM.targetHumans, i)
                _G["removeTargetHumans"..i] = false
            end
        end

        G1NM.animalsSize = #G1NM.targetAnimals
        G1NM.humansSize = #G1NM.targetHumans

        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and (UnitAffectingCombat(unitPlaceholder) or tContains(G1NMData.dummiesIDList, ObjectID(unitPlaceholder))) then
                G1NM.TTDF(unitPlaceholder)
            end
        end

        for k,v in pairs(G1NM.TTD) do if not ObjectExists(k) or UnitIsDeadOrGhost(k) == 0 or not G1NM.animalsAuraBlacklist(k) then G1NM.TTD[k] = nil end end
    elseif not G1NMData[G1NM.playerFullName].objectManagerMode or G1NMData[G1NM.playerFullName].objectManagerMode == 1 then
        if elapsedTime >= 1 or zone ~= 1115 then
            elapsedTime = 0

            local unitPlaceholder = nil
            for i = 1, ObjectCount() do
                unitPlaceholder = ObjectWithIndex(i)
                if ObjectIsUnit(unitPlaceholder)
                and UnitIsVisible(unitPlaceholder)
                and (not G1NMData[G1NM.playerFullName].animals or not tContains(G1NM.targetAnimals, unitPlaceholder))
                then
                    if not ObjectIsPlayer(unitPlaceholder) then -- mobs
                        if G1NMData[G1NM.playerFullName].animals and not UnitInParty(unitPlaceholder) and G1NM.health(unitPlaceholder) > 0 and UnitCanAttack("player", unitPlaceholder) then -- hostile mobs
                            if UnitName(unitPlaceholder) ~= UNKNOWNOBJECT and not tContains(G1NMData.animalTypesToIgnore, UnitCreatureType(unitPlaceholder)) and G1NM.animalsAuraBlacklist(unitPlaceholder) and G1NM.animalsIDBlacklist(unitPlaceholder) then
                                G1NM.targetAnimals[G1NM.animalsSize+1] = unitPlaceholder
                                G1NM.animalsSize = G1NM.animalsSize + 1
                            end
                        end
                    end
                end
            end
        end

        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if not G1NMData[G1NM.playerFullName].animals or not ObjectExists(unitPlaceholder) or UnitIsDeadOrGhost(unitPlaceholder) or not UnitCanAttack("player", unitPlaceholder) or not G1NM.animalsAuraBlacklist(unitPlaceholder) then _G["removeTargetAnimals"..i] = true end
        end
        for i = G1NM.animalsSize, 1, -1 do
            if _G["removeTargetAnimals"..i] then
                table.remove(G1NM.targetAnimals, i)
                _G["removeTargetAnimals"..i] = false
            end
        end

        if G1NMData[G1NM.playerFullName].humans then
            if IsInRaid() then
                for i = 1, 40 do
                    if ObjectExists("raid"..i) and UnitExists("raid"..i) and UnitName("raid"..i) ~= UNKNOWNOBJECT then
                        if G1NM.humanNotDuplicate(ObjectPointer("raid"..i)) then
                            G1NM.targetHumans[G1NM.humansSize+1] = {player = ObjectPointer("raid"..i), role = UnitGroupRolesAssigned("raid"..i), execute = false}
                            G1NM.humansSize = G1NM.humansSize + 1
                        end
                    end
                end
            else
                for i = 1, 4 do
                    if ObjectExists("party"..i) and UnitExists("party"..i) and UnitName("party"..i) ~= UNKNOWNOBJECT then
                        if G1NM.humanNotDuplicate(ObjectPointer("party"..i)) then
                            G1NM.targetHumans[G1NM.humansSize+1] = {player = ObjectPointer("party"..i), role = UnitGroupRolesAssigned("party"..i), execute = false}
                            G1NM.humansSize = G1NM.humansSize + 1
                        end
                    end
                end
                if G1NM.humanNotDuplicate(ObjectPointer("player")) then
                    G1NM.targetHumans[G1NM.humansSize+1] = {player = ObjectPointer("player"), role = UnitGroupRolesAssigned("player"), execute = false}
                    G1NM.humansSize = G1NM.humansSize + 1
                end
            end
        end

        for i = 1, G1NM.humansSize do
            unitPlaceholder = G1NM.targetHumans[i].player
            if not G1NMData[G1NM.playerFullName].humans or not ObjectExists(unitPlaceholder) or UnitName(unitPlaceholder) == "Unknown" or (not UnitInParty(unitPlaceholder) and not UnitIsUnit("player", unitPlaceholder)) then _G["removeTargetHumans"..i] = true end
        end
        for i = G1NM.humansSize, 1, -1 do
            if _G["removeTargetHumans"..i] then
                table.remove(G1NM.targetHumans, i)
                _G["removeTargetHumans"..i] = false
            end
        end

        if inspectSet == 0 then
            for i = 1, G1NM.humansSize do
                if not G1NM.targetHumans or not G1NM.targetHumans[i] then break end
                unitPlaceholder = G1NM.targetHumans[i].player
                if ObjectIsPlayer(unitPlaceholder) and (not executeCrossCheck[i] or executeCrossCheck[i] ~= UnitName(unitPlaceholder)) then NotifyInspect(unitPlaceholder) inspectSet = i break end
            end
        else
            if not G1NM.targetHumans or not G1NM.targetHumans[inspectSet] or not G1NM.targetHumans[inspectSet].player then inspectSet = 0 return end
            if GetInspectSpecialization(G1NM.targetHumans[inspectSet].player) ~= 0 then
                if tContains(executeSpecs, GetInspectSpecialization(G1NM.targetHumans[inspectSet].player)) then
                    G1NM.targetHumans[inspectSet].execute = true
                else
                    G1NM.targetHumans[inspectSet].execute = false
                end
                executeCrossCheck[inspectSet] = UnitName(G1NM.targetHumans[inspectSet].player)
                inspectSet = 0
            end
        end

        G1NM.animalsSize = #G1NM.targetAnimals
        G1NM.humansSize = #G1NM.targetHumans

        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and (UnitAffectingCombat(unitPlaceholder) or tContains(G1NMData.dummiesIDList, ObjectID(unitPlaceholder))) then
                G1NM.TTDF(unitPlaceholder)
            end
        end

        for k,v in pairs(G1NM.TTD) do if not ObjectExists(k) or UnitIsDeadOrGhost(k) == 0 or not G1NM.animalsAuraBlacklist(k) then G1NM.TTD[k] = nil end end
    end
end

-- local versionIdentifierTable = {
--     ["DEATHKNIGHT1"] = "BDK",
--     ["DEATHKNIGHT2"] = "FDK",
--     ["DEATHKNIGHT3"] = "UDK",
--     ["DEMONHUNTER1"] = "HDH",
--     ["DEMONHUNTER2"] = "VDH",
--     ["DRUID1"]       = "BDR",
--     ["DRUID2"]       = "FDR",
--     ["DRUID3"]       = "GDR",
--     ["DRUID4"]       = "RDR",
--     ["HUNTER1"]      = "BH",
--     ["HUNTER2"]      = "MH",
--     ["HUNTER3"]      = "SH",
--     ["MAGE1"]        = "AMG",
--     ["MAGE2"]        = "FIMG",
--     ["MAGE3"]        = "FRMG",
--     ["MONK1"]        = "BMK",
--     ["MONK2"]        = "MMK",
--     ["MONK3"]        = "WMK",
--     ["PALADIN1"]     = "HPD",
--     ["PALADIN2"]     = "PPD",
--     ["PALADIN3"]     = "RPD",
--     ["PRIEST1"]      = "DPR",
--     ["PRIEST2"]      = "HPR",
--     ["PRIEST3"]      = "SPR",
--     ["ROGUE1"]       = "AR",
--     ["ROGUE2"]       = "OR",
--     ["ROGUE3"]       = "SR",
--     ["SHAMAN1"]      = "ELS",
--     ["SHAMAN2"]      = "EHS",
--     ["SHAMAN3"]      = "RS",
--     ["WARLOCK1"]     = "AWL",
--     ["WARLOCK2"]     = "DMWL",
--     ["WARLOCK3"]     = "DSWL",
--     ["WARRIOR1"]     = "AWR",
--     ["WARRIOR2"]     = "FWR",
--     ["WARRIOR3"]     = "PWR",
-- }

-- G1NM.downloadedVersions = {}

function G1NM.checkUpdate(revision)
    -- local engineVersion
    -- engineVersion = string.match(revision, "\n=%d*%.*%d+")
    -- engineVersion = string.gsub(engineVersion, "[%a=]", "")

    -- local versionNumber
    -- for k,v in pairs(versionIdentifierTable) do
    --     versionNumber = string.match(revision, v.."=%d*%.*%d+")
    --     versionNumber = string.gsub(versionNumber, "[%a=]", "")
    --     G1NM.downloadedVersions[k] = tonumber(versionNumber)
    -- end

    -- if G1NM.engineVersion < tonumber(engineVersion) then print(G1NM.AddonName..": Engine Update Available. Latest Version: "..engineVersion..", Current Version: "..G1NM.engineVersion) return end
end

-- function G1NM.revisionCheckFailed()
--     print(G1NM.AddonName..": Could not check for updates.")
-- end

function G1NM.createRotationEventFrame()
    CreateFrame("Frame", "rotationEventFrame", G1NMMainFrame)
    -- rotationEventFrame:RegisterEvent("COMBAT_LOG_EVENT")
    rotationEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    rotationEventFrame:RegisterEvent("PLAYER_DEAD")
    rotationEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    rotationEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    rotationEventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
    rotationEventFrame:RegisterEvent("UNIT_AURA")
    rotationEventFrame:RegisterEvent("UNIT_ATTACK_SPEED")
    rotationEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
    rotationEventFrame:SetScript("OnEvent", G1NM.respondRotationEventFrame)
end

local lineIDCastStartResponded, lineIDCastStopResponded, lineIDCastSucceededResponded, lineIDCastFailed
function G1NM.respondRotationEventFrame(self, registeredEvent, ...)
    -- if not G1NM.allowFrames then return end
    if registeredEvent == "PLAYER_DEAD" then
    elseif registeredEvent == "PLAYER_REGEN_DISABLED" then
        G1NM.combatStartTime = GetTime()
        if not G1NM.cacheTalentsQueued then C_Timer.After(1, G1NM.cacheTalents); G1NM.cacheTalentsQueued = true end
        if not G1NM.cacheGearQueued then C_Timer.After(1, G1NM.cacheGear); G1NM.cacheGearQueued = true end
        -- G1NM.updateRolesForHealing()
        -- G1NM.setTanksForHealing()
    elseif registeredEvent == "PLAYER_REGEN_ENABLED" then
        G1NM.combatEndTime = GetTime()
        G1NM.throttleRunSpecial = 0
        G1NM.throttleRun = 0
        -- G1NM.MONK.openerCount = 0
        -- G1NM.DEATHKNIGHT.openerCount = 0
    elseif registeredEvent == "UNIT_SPELLCAST_START" then
        local unitID, __, __, lineID, spellID = ...
        if lineID == lineIDCastStartResponded then return else lineIDCastStartResponded = lineID end
        if not UnitIsUnit(unitID, "player") then return end
        G1NM.throttleRun = 1

        if G1NMData[G1NM.playerFullName].class == "PRIEST" then
            if spellID == 34914 then -- Vampiric Touch
                G1NM.throttleRunSpecial = 1
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "WARLOCK" then
            if spellID == 30108 then -- Unstable Affliction
                G1NM.throttleRunSpecial = 1
                return
            end
            if spellID == 193396 then -- Demonic Empowerement
                G1NM.throttleRunSpecial = 1
                return
            end
            if spellID == 105174 then -- Hand of Gul'dan
                G1NM.throttleRunSpecial = 0
                return
            end
        end
    elseif registeredEvent == "UNIT_SPELLCAST_CHANNEL_START" then
        local unitID, __, __, lineID, spellID = ...
        if not UnitIsUnit(unitID, "player") then return end
        G1NM.throttleRun = 1

        if G1NMData[G1NM.playerFullName].class == "PRIEST" then
            if spellID == 15407 then -- Mind Flay
                G1NM.PRIEST.ticksSince = 0
                return
            end
        end
    elseif registeredEvent == "UNIT_SPELLCAST_STOP" then
        local unitID, __, __, lineID, spellID = ...
        if lineID == lineIDCastStopResponded then return else lineIDCastStopResponded = lineID end
        if not UnitIsUnit(unitID, "player") then return end
        G1NM.throttleRun = 0

        if G1NMData[G1NM.playerFullName].class == "DRUID" then
            if spellID == 190984 or spellID == 194153 then -- Solar Wrath Lunar Strike unthrottle
                G1NM.throttleRunSpecial = 0
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "PRIEST" then
            if spellID == 34914 and G1NM.lastCast ~= spellID then -- Vampiric Touch
                G1NM.throttleRunSpecial = 0
                return
            end
        end
    elseif registeredEvent == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unitID, __, __, __, spellID = ...
        if not UnitIsUnit(unitID, "player") then return end
        G1NM.throttleRun = 0
    elseif registeredEvent == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitID, lineID, spellID = ...
        if lineID == lineIDCastSucceededResponded then return else lineIDCastSucceededResponded = lineID end
        if UnitExists("pet") and UnitIsUnit(unitID, "pet") and not tContains(G1NM.lastCastBlacklist, spellID) then
            G1NM.petFourthCast = G1NM.petThirdCast
            G1NM.petThirdCast  = G1NM.petSecondCast
            G1NM.petSecondCast = G1NM.petLastCast
            G1NM.petLastCast   = spellID
            return
        end
        if not UnitIsUnit(unitID, "player") then return end
        G1NM.throttleRun = 0
        if not tContains(G1NM.lastCastBlacklist, spellID) then
            G1NM.fourthCast = G1NM.thirdCast
            G1NM.thirdCast = G1NM.secondCast
            G1NM.secondCast = G1NM.lastCast
            G1NM.lastCast = spellID
        end
        if spellID == G1NM.nextGCD then G1NM.nextGCD = 0 end

        if G1NMData[G1NM.playerFullName].class == "DEATHKNIGHT" then
            if G1NM.currentSpec == 2 and G1NMData[G1NM.playerFullName].FDKopener and G1NM.DEATHKNIGHT.openerCount ~= math.huge then
                if spellID == 49184 or spellID == 49020 and (G1NM.DEATHKNIGHT.openerCount == 2 or G1NM.DEATHKNIGHT.openerCount == 3) or spellID == 57330 or spellID == 207127 then
                    G1NM.DEATHKNIGHT.openerCount = G1NM.DEATHKNIGHT.openerCount + 1
                    return
                end
            end
        end

        if G1NMData[G1NM.playerFullName].class == "DRUID" then
            if G1NM.currentSpec == 4 then
                if G1NM.talent51 and spellID == 774 and G1NM.aura("player", 114108) then
                    G1NM.DRUID.saveSoTF = ObjectPointer(unitID)
                end
            end
        end

        if G1NMData[G1NM.playerFullName].class == "MAGE" then
            if G1NM.currentSpec == 2 then -- FIRE MAGE
                if G1NM.throttleRunSpecial == 11366 and spellID == 11366 then G1NM.throttleRunSpecial = 0 return end
                if G1NM.throttleRunSpecial == 108853 and spellID == 108853 then G1NM.throttleRunSpecial = 0 return end
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "MONK" and G1NM.currentSpec == 3 and tContains(G1NM.MONK.hitComboTable, spellID) then -- todo: improve this so that it supports different types (gcd vs off gcd) and adapt this as a systemwide tool not just for WW Monk.
            -- // This is an ongoing check; so theoretically it can trigger 2 times from 4 unique CS spells in a row
            -- // If a spell is used and it is one of the last 3 combo stirke saved, it will not trigger the buff
            -- // IE: Energizing Elixir -> Strike of the Windlord -> Fists of Fury -> Tiger Palm (trigger) -> Blackout Kick (trigger) -> Tiger Palm -> Rising Sun Kick (trigger)
            -- // The triggering CAN reset if the player casts the same ability two times in a row.
            -- // IE: Energizing Elixir -> Blackout Kick -> Blackout Kick -> Rising Sun Kick -> Blackout Kick -> Tiger Palm (trigger)
            G1NM.MONK.fourthCast = G1NM.MONK.thirdCast
            G1NM.MONK.thirdCast = G1NM.MONK.secondCast
            G1NM.MONK.secondCast = G1NM.MONK.lastCast
            G1NM.MONK.lastCast = spellID
            return
        end

        if G1NMData[G1NM.playerFullName].class == "ROGUE" then
            if spellID == 200806 then -- Exsanguinate
                if G1NM.aura("target", 1943, "", "PLAYER") then
                    G1NM.ROGUE.ruptureExsanguinated = ObjectPointer("target")
                end
                if G1NM.aura("target", 703, "", "PLAYER") then
                    G1NM.ROGUE.garroteExsanguinated = ObjectPointer("target")
                end
                return
            end
        end
    elseif registeredEvent == "UNIT_SPELLCAST_FAILED" or registeredEvent == "UNIT_SPELLCAST_FAILED_QUIET" then
        local unitID, __, __, lineID, spellID = ...
        if lineID == lineIDCastFailed then return else lineIDCastFailed = lineID end
        if not UnitIsUnit(unitID, "player") then return end
        G1NM.throttleRun = 0
        -- G1NM.logToFile(spellName..": Unthrottling "..failedType)

        if G1NMData[G1NM.playerFullName].class == "DEATHKNIGHT" then
            if G1NMData[G1NM.playerFullName].queueSystem and (spellID == 190778 or spellID == 49998) then -- Queue up Sindragosa's Fury
                if G1NM.spellCDDuration(spellID) <= G1NM.globalCD() and G1NM.debugTable["ogSpell"] ~= spellID then G1NM.nextGCD = spellID return end
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "DEMONHUNTER" then
            if G1NMData[G1NM.playerFullName].queueSystem and (spellID == 179057 --[[or spellID == 191427]]) then -- Queue up Chaos Nova
                if G1NM.spellCDDuration(spellID) <= G1NM.globalCD() and G1NM.debugTable["ogSpell"] ~= spellID then G1NM.nextGCD = spellID return end
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "DRUID" then
            if spellID == 190984 or spellID == 194153 then -- Solar Wrath Lunar Strike unthrottle
                G1NM.throttleRunSpecial = 0
                return
            end

            if G1NMData[G1NM.playerFullName].queueSystem and (spellID == 145205 or spellID == 102280 or spellID == 205636) then -- Queue Effloresence Displacer Beast Force of Nature
                if G1NM.spellCDDuration(spellID) <= G1NM.globalCD() and G1NM.debugTable["ogSpell"] ~= spellID then G1NM.nextGCD = spellID return end
            end
        end

        if G1NMData[G1NM.playerFullName].class == "MONK" then
            if G1NMData[G1NM.playerFullName].queueSystem and (spellID == 119381) then -- Queue up Leg Sweep
                if G1NM.spellCDDuration(spellID) <= G1NM.globalCD() and G1NM.debugTable["ogSpell"] ~= spellID then G1NM.nextGCD = spellID return end
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "PRIEST" then
            if spellID == 34914 then -- Vampiric Touch
                G1NM.throttleRunSpecial = 0
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "WARLOCK" then
            if spellID == 30108 then -- Unstable Affliction
                G1NM.throttleRunSpecial = 0
                return
            end
            if spellID == 193396 then -- Demonic Empowerement
                G1NM.throttleRunSpecial = 0
                return
            end
            if spellID == 105174 then -- Hand of Gul'dan
                G1NM.throttleRunSpecial = 0
                return
            end
        end
    elseif registeredEvent == "UNIT_AURA" then
        local unitID = ...

        if G1NMData[G1NM.playerFullName].class == "DRUID" then
            if G1NM.currentSpec == 1 then -- BALANCE DRUID
                if not UnitIsUnit(unitID, "player") then return end
                if G1NM.debugTable.ogSpell == 190984 then -- Solar Wrath
                    if G1NM.throttleRunSpecial == 3 then
                        if not G1NM.auraStacks("player", 164545, 3) then G1NM.throttleRunSpecial = 0 end
                    elseif G1NM.throttleRunSpecial == 2 then
                        if not G1NM.auraStacks("player", 164545, 2) then G1NM.throttleRunSpecial = 0 end
                    elseif G1NM.throttleRunSpecial == 1 then
                        if not G1NM.aura("player", 164545) then G1NM.throttleRunSpecial = 0 end
                    end
                    -- if not G1NM.auraStacks("player", 164545, G1NM.throttleRunSpecial) then G1NM.throttleRunSpecial = 0 end
                end
                if G1NM.debugTable.ogSpell == 194153 then -- Lunar Strike
                    if G1NM.throttleRunSpecial == 5 then
                        G1NM.throttleRunSpecial = 0
                    elseif G1NM.throttleRunSpecial == 3 then
                        if not G1NM.auraStacks("player", 164547, 3) then G1NM.throttleRunSpecial = 0 end
                    elseif G1NM.throttleRunSpecial == 1 then
                        if not G1NM.aura("player", 164547) then G1NM.throttleRunSpecial = 0 end
                    end
                    -- if not G1NM.auraStacks("player", 164547, G1NM.throttleRunSpecial) then G1NM.throttleRunSpecial = 0 end
                end
            end
            if G1NM.currentSpec == 4 then -- RESTORATION DRUID
                if G1NM.DRUID.saveSoTF and UnitIsUnit(unitID, G1NM.DRUID.saveSoTF) then
                    local string = G1NM.DRUID.retrieveLatestRejuvenationGermination(unitID)
                    if not G1NM.DRUID.SotFTable[G1NM.DRUID.saveSoTF] then G1NM.DRUID.SotFTable[G1NM.DRUID.saveSoTF] = {} end
                    G1NM.DRUID.SotFTable[G1NM.DRUID.saveSoTF][string] = 1
                    G1NM.DRUID.saveSoTF = nil
                elseif G1NM.lastCast == 774 then
                    local string = G1NM.DRUID.retrieveLatestRejuvenationGermination(unitID)
                    -- if G1NM.auraRemaining(unitID, (string == "rejuvenation" and 774 or 155777), 11, "", "PLAYER") then return end
                    if not G1NM.DRUID.SotFTable[ObjectPointer(unitID)] then G1NM.DRUID.SotFTable[ObjectPointer(unitID)] = {} end
                    G1NM.DRUID.SotFTable[ObjectPointer(unitID)][string] = 0
                else
                end
            end
            return
        end

        if G1NMData[G1NM.playerFullName].class == "PRIEST" then
            if G1NM.currentSpec == 3 then -- SHADOW PRIEST
                if G1NM.throttleRunSpecial > 0 and G1NM.aura(unitID, 34914, "", "PLAYER") then G1NM.throttleRunSpecial = 0 return end
                return
            end
        end

        if G1NMData[G1NM.playerFullName].class == "WARLOCK" then
            if G1NM.currentSpec == 1 then -- AFFLICTION WARLOCK
                if G1NM.throttleRunSpecial > 0 and (G1NM.aura(unitID, 233490, "", "PLAYER") or G1NM.aura(unitID, 233496, "", "PLAYER") or G1NM.aura(unitID, 233497, "", "PLAYER") or G1NM.aura(unitID, 233498, "", "PLAYER") or G1NM.aura(unitID, 233499, "", "PLAYER")) then G1NM.throttleRunSpecial = 0 return end
                return
            end
            if spellID == 193396 then -- Demonic Empowerement
                if G1NM.throttleRunSpecial > 0 and G1NM.aura(unitID, 193396, "", "PLAYER") then G1NM.throttleRunSpecial = 0 return end
                return
            end
        end
    elseif registeredEvent == "UNIT_ATTACK_SPEED" then
        if ... == "player" then
            -- G1NM.WARRIOR.attackSpeed = UnitAttackSpeed("player")
            -- if G1NM.WARRIOR.debug then
            --     print("player attack speed changed")
            -- end
        end
    elseif registeredEvent == "UNIT_POWER_UPDATE" then
        local unitID, powerType = ...
        if not UnitIsUnit(unitID, "player") then return end
        
        if G1NMData[G1NM.playerFullName].class == "DRUID" then
            if G1NM.currentSpec == 1 then
                if G1NM.debugTable.ogSpell == 190984 and G1NM.throttleRunSpecial == 202770 then G1NM.throttleRunSpecial = 0 end
                return
            end
        end
    elseif registeredEvent == "COMBAT_LOG_EVENT_UNFILTERED" then
        local timeNow = GetTime()
        local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, failedType = CombatLogGetCurrentEventInfo()

        if G1NMData[G1NM.playerFullName].class == "PRIEST" then
            if G1NM.currentSpec == 3 then -- SHADOW
                G1NM.PRIEST.voidformTotalStacks = G1NM.PRIEST.voidformTotalStacks or 0;
                G1NM.PRIEST.voidformPreviousStackTime = G1NM.PRIEST.voidformPreviousStackTime or 0;
                G1NM.PRIEST.voidformDrainStacks = G1NM.PRIEST.voidformDrainStacks or 0;
                G1NM.PRIEST.voidformVoidTorrentStacks = G1NM.PRIEST.voidformVoidTorrentStacks or 0;
                G1NM.PRIEST.voidformDispersionStacks = G1NM.PRIEST.voidformDispersionStacks or 0;
                
                if G1NM.PRIEST.voidformTotalStacks >= 100 then
                    if (timeNow - G1NM.PRIEST.voidformPreviousStackTime) >= 1 then
                        G1NM.PRIEST.voidformPreviousStackTime = timeNow;
                        G1NM.PRIEST.voidformTotalStacks = G1NM.PRIEST.voidformTotalStacks + 1;
                
                        if G1NM.PRIEST.voidformVoidTorrentStart == nil and G1NM.PRIEST.voidformDispersionStart == nil then
                            G1NM.PRIEST.voidformDrainStacks = G1NM.PRIEST.voidformDrainStacks + 1;
                        elseif G1NM.PRIEST.voidformVoidTorrentStart ~= nil then
                            G1NM.PRIEST.voidformVoidTorrentStacks = G1NM.PRIEST.voidformVoidTorrentStacks + 1;
                        else
                            G1NM.PRIEST.voidformDispersionStacks = G1NM.PRIEST.voidformDispersionStacks + 1;
                        end
                    end
                end

                if sourceGUID == UnitGUID("player") then
                    if spellid == 194249 then
                        if type == "SPELL_AURA_APPLIED" then -- Entered Voidform
                            G1NM.PRIEST.voidformPreviousStackTime = timeNow;
                            G1NM.PRIEST.voidformVoidTorrentStart = nil;
                            G1NM.PRIEST.voidformDispersionStart = nil;
                            G1NM.PRIEST.voidformDrainStacks = 1;
                            G1NM.PRIEST.voidformStartTime = timeNow;
                            G1NM.PRIEST.voidformTotalStacks = 1;
                            G1NM.PRIEST.voidformVoidTorrentStacks = 0;
                            G1NM.PRIEST.voidformDispersionStacks = 0;
                        elseif type == "SPELL_AURA_APPLIED_DOSE" then -- New Voidform Stack
                            G1NM.PRIEST.voidformPreviousStackTime = timeNow;
                            G1NM.PRIEST.voidformTotalStacks = G1NM.PRIEST.voidformTotalStacks + 1;
                
                            if G1NM.PRIEST.voidformVoidTorrentStart == nil and G1NM.PRIEST.voidformDispersionStart == nil then
                                G1NM.PRIEST.voidformDrainStacks = G1NM.PRIEST.voidformDrainStacks + 1;
                            elseif G1NM.PRIEST.voidformVoidTorrentStart ~= nil then
                                G1NM.PRIEST.voidformVoidTorrentStacks = G1NM.PRIEST.voidformVoidTorrentStacks + 1;
                            else
                                G1NM.PRIEST.voidformDispersionStacks = G1NM.PRIEST.voidformDispersionStacks + 1;
                            end
                        elseif type == "SPELL_AURA_REMOVED" then -- Exited Voidform
                            G1NM.PRIEST.voidformVoidTorrentStart = nil;
                            G1NM.PRIEST.voidformDispersionStart = nil;
                            G1NM.PRIEST.voidformDrainStacks = 0;
                            G1NM.PRIEST.voidformStartTime = nil;
                            G1NM.PRIEST.voidformTotalStacks = 0;
                            G1NM.PRIEST.voidformVoidTorrentStacks = 0;
                            G1NM.PRIEST.voidformDispersionStacks = 0;
                        end
                    elseif spellid == 205065 then
                        if type == "SPELL_AURA_APPLIED" then -- Started channeling Void Torrent
                            G1NM.PRIEST.voidformVoidTorrentStart = timeNow;
                        elseif type == "SPELL_AURA_REMOVED" and G1NM.PRIEST.voidformVoidTorrentStart ~= nil then -- Stopped channeling Void Torrent
                            G1NM.PRIEST.voidformVoidTorrentStart = nil;
                        end
                    elseif spellid == 47585 then
                        if type == "SPELL_AURA_APPLIED" then -- Started channeling Dispersion
                            G1NM.PRIEST.voidformDispersionStart = timeNow;
                        elseif type == "SPELL_AURA_REMOVED" and G1NM.PRIEST.voidformDispersionStart ~= nil then -- Stopped channeling Dispersion
                            G1NM.PRIEST.voidformDispersionStart = nil;
                        end
                    elseif spellid == 212570 then
                        if type == "SPELL_AURA_APPLIED" then -- Gain Surrender to Madness
                            G1NM.PRIEST.voidformS2MActivated = true;
                            G1NM.PRIEST.voidformS2MStart = timeNow;
                        end
                    end
                elseif destGUID == UnitGUID("player") and (type == "UNIT_DIED" or type == "UNIT_DESTROYED" or type == "SPELL_INSTAKILL") and G1NM.PRIEST.voidformS2MActivated == true then
                    G1NM.PRIEST.voidformS2MActivated = false;
                    G1NM.PRIEST.voidformS2MStart = nil;
                    G1NM.PRIEST.voidformVoidTorrentStart = nil;
                    G1NM.PRIEST.voidformDispersionStart = nil;
                    G1NM.PRIEST.voidformDrainStacks = 0;
                    G1NM.PRIEST.voidformStartTime = nil;
                    G1NM.PRIEST.voidformTotalStacks = 0;
                    G1NM.PRIEST.voidformVoidTorrentStacks = 0;
                    G1NM.PRIEST.voidformDispersionStacks = 0;
                end
            end
        end

        -- if tContains(G1NM.animalsThatInterrupt, sourceName) then
        --  if event == "SPELL_CAST_START" then
        --  elseif event == "SPELL_CAST_FAILED" then
        --  end
        --  return
        -- end

        if event == "UNIT_DIED" then
            return
        end

        if (event == "SWING_MISSED" or event == "SPELL_MISSED") and destGUID == UnitGUID("player") and spellID == "PARRY" then
            --[[
                a) If the next swing is scheduled to occur in more than 60% of the player's swing speed, the scheduling will be shortened by 40% of the player's swing speed.
                b) If the next swing is scheduled to occur within 60% and 20% of the player's swing speed, the next swing will be re-scheduled to occur in 20% of the player's swing speed.
                c) If the next swing is scheduled to occur in less than 20% of the swing speed, the scheduling is unchanged.
            ]]
            
            -- local timeLeft = G1NM.WARRIOR.nextSwing - timeNow
            -- if G1NM.WARRIOR.debug then
            --     print("player parried, time left: "..timeLeft)
            -- end
            
            -- if timeLeft > 0.6 * G1NM.WARRIOR.attackSpeed then
            
            --     G1NM.WARRIOR.swingTimer = G1NM.WARRIOR.swingTimer - 0.4 * G1NM.WARRIOR.attackSpeed
            --     G1NM.WARRIOR.nextSwing = G1NM.WARRIOR.nextSwing - 0.4 * G1NM.WARRIOR.attackSpeed
            --     if G1NM.WARRIOR.debug then
            --         print("parry haste type a")
            --     end
            
            -- elseif timeLeft > 0.2 * G1NM.WARRIOR.attackSpeed then
            
            --     local oldSchedule = G1NM.WARRIOR.nextSwing
            --     G1NM.WARRIOR.nextSwing = timeNow + 0.2 * G1NM.WARRIOR.attackSpeed
            --     G1NM.WARRIOR.swingTimer = G1NM.WARRIOR.swingTimer - (oldSchedule - G1NM.WARRIOR.nextSwing)
            --     if G1NM.WARRIOR.debug then
            --         print("parry haste type b")
            --     end
            
            -- else
            
            --     if G1NM.WARRIOR.debug then
            --         print("parry haste type c")
            --     end
            
            -- end
        end

        if sourceName ~= UnitName("player") then return end
        G1NM.waitForCombatLog = false

        if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then
            if G1NMData[G1NM.playerFullName].class == "PRIEST" then
                if spellID == 194384 then
                    G1NM.setWaitForAura(false)
                    return
                end
            end
        elseif event == "SPELL_AURA_APPLIED_DOSE" then -- Never seen this before. it's used for buffs that gain stacks without refreshing duration aka void form (mongoose bite?)
        elseif event == "SPELL_AURA_REMOVED" then
        elseif event == "SPELL_DAMAGE" then -- projectile unthrottles would go in here
            if G1NMData[G1NM.playerFullName].class == "DEMONHUNTER" then
                if spellID == 192611 then
                    G1NM.DEMONHUNTER.castFelRush = false
                    StopMoving()
                    return
                end
                if spellID == 198813 then -- Vengeful Retreat
                    G1NM.DEMONHUNTER.castVengefulRetreat = false
                    return
                end
            end
        elseif event == "SPELL_PERIODIC_DAMAGE" then
            if G1NM.interruptNextTick and G1NM.interruptNextTick == spellName then -- Interrupt Channeling On Tick
                SpellStopCasting()
                G1NM.interruptNextTick = nil
                print("interrupted channel")
                return
            end

            if G1NMData[G1NM.playerFullName].class == "PRIEST" then
                if G1NM.currentSpec == 3 then -- SHADOW
                    if spellID == 15407 then G1NM.PRIEST.ticksSince = G1NM.PRIEST.ticksSince + 1 return end
                end
            end

            return
        elseif event == "SWING_DAMAGE" then
            if sourceGUID == UnitGUID("player") then
                -- G1NM.WARRIOR.lastSwing = timeNow
                -- G1NM.WARRIOR.nextSwing = timeNow + G1NM.WARRIOR.attackSpeed
                -- G1NM.WARRIOR.swingTimer = G1NM.WARRIOR.attackSpeed
                -- if G1NM.WARRIOR.debug then
                --     print("player hit, reset swing timer")
                -- end
            end
        end
    end
end
print("G1NM: #3 Rotation Execution LOADED SUCCESSFULLY")
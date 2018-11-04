local function initiateStartup()
    while (not EWT) do print("EWT NOT LOADED") coroutine.yield() end

    local _ = nil
    G1NMAC, G1NMACD, G1NMACR = LibStub:GetLibrary("AceConfig-3.0"), LibStub:GetLibrary("AceConfigDialog-3.0"), LibStub:GetLibrary("AceConfigRegistry-3.0")
    G1NM = {}
    G1NM.AddonName = "G1NM"
    G1NM.CO = {}
    G1NM.playerFullName = UnitFullName("player")..string.gsub(GetRealmName(), " ", "")

    local ewtPath = GetHackDirectory()
    local wowPath = GetWoWDirectory().."\\Interface\\Addons\\G1NM\\"

    if #GetDirectoryFiles(ewtPath.."\\G1NMData.json") == 0 or not json.decode(ReadFile(ewtPath.."\\G1NMData.json")) then
        print(G1NM.AddonName..": Creating settings file. Non-existent or corrupt");
        WriteFile(ewtPath.."\\G1NMData.json", "")
        G1NMData = {}
        G1NMData[G1NM.playerFullName] = {}
    else
        G1NMData = json.decode(ReadFile(ewtPath.."\\G1NMData.json"))
        if not G1NMData[G1NM.playerFullName] then G1NMData[G1NM.playerFullName] = {} end
    end

    if #GetDirectoryFiles(ewtPath.."\\G1NMLog.json") == 0 then WriteFile(ewtPath.."\\G1NMLog.json", "") end
    if #GetDirectoryFiles(ewtPath.."\\G1NMInfoCollection.json") == 0 then WriteFile(ewtPath.."\\G1NMInfoCollection.json", "") end

    function G1NM.saveSetting(i, v)
        if i ~= "garbageSave" then print("Saving setting, "..tostring(i)..", with value, "..tostring(v)..".") end
        G1NMData[G1NM.playerFullName][i] = v
        WriteFile(ewtPath.."G1NMData.json", json.encode(G1NMData, {indent=true}))
    end
    G1NM.saveSetting("garbageSave", true)

    function G1NM.getSetting(i)
        return G1NMData[G1NM.playerFullName][i]
    end

    G1NM.debugTable = {}
    G1NM.collectionTable = {}
    G1NM.collectionTable.iteration = 0
    G1NM.collectionTable.spellCasts = {}
    G1NM.collectionTable.bossMobs = {}
    G1NM.collectionTable.dummyMobs = {}

    G1NM.throttleRun = 0
    G1NM.throttleRunSpecial = 0
    -- G1NM.waitForCombatLog = false
    G1NM.iterationNumber = 0
    G1NM.combatStartTime = 0
    G1NM.combatEndTime = 0
    -- G1NM.toggleLog = true
    G1NM.thokThrottle = 0
    G1NM.nextGCD = 0
    G1NM.lastCast = 0
    G1NM.petLastCast = 0
    G1NM.secondCast = 0
    G1NM.petsecondCast = 0
    G1NM.thirdCast = 0
    G1NM.petthirdCast = 0
    G1NM.fourthCast = 0
    G1NM.petfourthCast = 0

    G1NM.lastCastBlacklist = {
        228597,
        7268,
        84721,
        47666,
        166646,
        148187,
    }

    for r = 1, 7 do
        for c = 1, 3 do
            G1NM["talent"..r..c] = false
        end
    end
    -- TODO: Special Variables like throttles, logs, casts, petcasts, blacklist for casts

    LoadFile(wowPath.."System\\Config UI.lua")
    LoadFile(wowPath.."System\\Rotation Control Monitor.lua")
    LoadFile(wowPath.."System\\Rotation Execution Information.lua")
    LoadFile(wowPath.."System\\Unit Information.lua")
    LoadFile(wowPath.."System\\Rotation Check Functions.lua")
    LoadFile(wowPath.."System\\Version Trial Verification.lua"--[[, "#6 N/A LOADED SUCCESSFULLY"]])

    local count = 0
    for k,v in pairs(GetDirectoryFiles(wowPath.."Rotations\\*")) do
        LoadFile(wowPath.."Rotations\\"..v--[[, v.." Rotation Loaded"]])
        count = count + 1
    end
    print(tostring(count).." rotations loaded.")

    while (not G1NM.createMainFrame) do coroutine.yield() end
    G1NM.createMainFrame()

    print(G1NM.AddonName..": Finished Loading")
end

local startupCO = coroutine.create(initiateStartup)

local dummyFrame = CreateFrame("Frame")
local elapsedFrames = 0
local function checkValidStartup(self, elapsed)
    elapsedFrames = elapsedFrames + 1
    if elapsedFrames < 2 then return end
    elapsedFrames = 0
    if not G1NM then
        local state, err = coroutine.resume(startupCO)
        if not state then print(err) end
    else
        dummyFrame:SetScript("OnUpdate", nil)
    end
end

dummyFrame:SetScript("OnUpdate", checkValidStartup)
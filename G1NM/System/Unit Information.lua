local _ = nil

function G1NM.animalsAuraBlacklist(object)
    local auraToCheck = nil
    for i = 1, #G1NMData.animalAuraIDsToIgnore do
        auraToCheck = G1NMData.animalAuraIDsToIgnore[i]
        if G1NM.aura(object, auraToCheck) then return false end
    end
    return true
end

function G1NM.animalsIDBlacklist(object)
    return not tContains(G1NMData.animalIDsToIgnore)
end

function G1NM.humansAuraBlacklist(object) -- todo: implement this in config
    local auraToCheck = nil
    --[[for i = 1, #G1NM.humansAurasToIgnore do
        auraToCheck = G1NM.humansAurasToIgnore[i]
        if G1NM.aura(object, auraToCheck) then return false end
    end]]
    return true
end

function G1NM.logToFile(message)
    local file = ReadFile(G1NMData.logFile)
    if not file then return end
    local debugStack = string.gsub(debugstack(2, 100, 100), 'Interface\\AddOns\\G1NM\\.-(%w+)%.lua', "file: %1, line")
    debugStack = string.gsub(debugStack, "\n", ", ")
    WriteFile(G1NMData.logFile, file..",\n{\n\t"..message.."\n\t\"time\":"..GetTime()..",\n\t\"Line Number\": "..debugStack.."\n}")
end

function G1NM.humanNotDuplicate(unitPassed)
    local unit
    for i = 1, G1NM.humansSize do
        unit = G1NM.targetHumans[i].player
        if unit == unitPassed then return false end
    end
    return true
end

do -- Sort Function
    function G1NM.sortAnimalsByLowestTTD()
        table.sort(G1NM.targetAnimals, function(a,b)
            return G1NM.getTTD(a) < G1NM.getTTD(b)
        end)
    end

    function G1NM.sortAnimalsByHighestTTD()
        table.sort(G1NM.targetAnimals, function(a,b)
            if G1NM.getTTD(a) == math.huge then return false elseif G1NM.getTTD(b) == math.huge then return true end
            return G1NM.getTTD(a) > G1NM.getTTD(b)
        end)
    end

    function G1NM.sortHumansByRole()
        table.sort(G1NM.targetHumans, function(a,b)
            return (a.Role == "TANK" and true or a.Role == "HEALER" and b.Role ~= "TANK" and true or a.Role == "DAMAGER" and b.Role ~= "TANK" and b.Role ~= "HEALER" and true or a.Role == b.Role and G1NM.health(a.player, _, true) < G1NM.health(b.player, _, true) or false)
        end)
    end

    function G1NM.sortHumansByTank()
        table.sort(G1NM.targetHumans, function(a,b)
            if UnitIsDeadOrGhost(a.player) then return false elseif UnitIsDeadOrGhost(b.player) then return true end
            if a.Role == "TANK" and b.Role ~= "TANK" then return true elseif b.Role == "TANK" and a.Role ~= "TANK" then return false end
            return G1NM.health(a.player, _, _, true) > G1NM.health(b.player, _, _, true)
        end)
    end

    function G1NM.sortHumansByHealthPercentAscending()
        table.sort(G1NM.targetHumans, function(a,b)
            if UnitIsDeadOrGhost(a.player) then return false elseif UnitIsDeadOrGhost(b.player) then return true end
            return G1NM.health(a.player, _, true) < G1NM.health(b.player, _, true)
        end)
    end

    function G1NM.sortHumansByHealthDeficitDescending()
        table.sort(G1NM.targetHumans, function(a, b)
            if UnitIsDeadOrGhost(a.player) then return false elseif UnitIsDeadOrGhost(b.player) then return true end
            return G1NM.health(a.player, _, _, "deficit") > G1NM.health(b.player, _, _, "deficit")
        end)
    end

    function G1NM.organizeTanksByGreatestHealthDeficit()
        G1NM.setTanksForHealing()
        local count = 0
        local lowest = {}
        for i = 1, math.huge do
            if G1NM["tank"..i] then
                if UnitExists(G1NM["tank"..i]) then count = count + 1 end
            else
                break
            end
        end
        local set = 0
        for i = 1, math.huge do
            local greatestHealthDeficit = 0
            local temp
            if set == count then
                for i = 1, count do
                    G1NM["tank"..i] = lowest[i]
                end
                break
            end
            for i = 1, count do
                if UnitExists(G1NM["tank"..i]) and G1NM.health(G1NM["tank"..i], _, _, "deficit") > greatestHealthDeficit then
                    greatestHealthDeficit = G1NM.health(G1NM["tank"..i], _, _, "deficit")
                    temp = G1NM["tank"..i]
                end
            end
            for i = 1, 10 do
                if not lowest[i] then
                    for i = 1, math.huge do
                        if G1NM["tank"..i] == temp then
                            G1NM["tank"..i] = nil
                            break
                        end
                    end
                    lowest[i] = temp; set = set + 1
                    break
                end
            end
        end
    end
end

do -- Healing Shit
    local rotationUnitIterator, role

    function G1NM.updateRolesForHealing()
        for i = 1, G1NM.humansSize do
            rotationUnitIterator = G1NM.targetHumans[i]
            rotationUnitIterator.role = UnitName(rotationUnitIterator.player) == "Oto the Protector" and "TANK" or UnitGroupRolesAssigned(rotationUnitIterator.player) == rotationUnitIterator.role and rotationUnitIterator.role or UnitGroupRolesAssigned(rotationUnitIterator.player)
        end
    end

    function G1NM.setTanksForHealing()
        G1NM.updateRolesForHealing()
        local count = 1
        for i = 1, G1NM.humansSize do
            rotationUnitIterator = G1NM.targetHumans[i]
            if rotationUnitIterator.role == "TANK" then G1NM["tank"..count] = rotationUnitIterator.player end
        end
    end
end

function G1NM.logAnimalsToFile()
    local unit
    for i = 1, G1NM.animalsSize do
        unit = G1NM.targetAnimals[i]
        G1NM.logToFile(
            UnitName(unit)..":\n\t"..UnitCreatureType(unit).."\n\t"..tostring(UnitIsVisible(unit)).."\n\t"..tostring(G1NM.animalIsTappedByPlayer(unit))
        )
    end
end

-- ripped from CommanderSirow of the wowace forums
function G1NM.TTDF(unit) -- keep updated: see if this can be optimized
    -- Setup trigger (once)
    if not nMaxSamples then
        -- User variables
        nMaxSamples = 15             -- Max number of samples
        nScanThrottle = 0.25             -- Time between samples
    end

    -- Training Dummy alternate between 4 and 200 for cooldowns
    if tContains(G1NMData.dummiesIDList, ObjectID(unit)) then
        if not G1NMData[G1NM.playerFullName].dummyTTDMode or G1NMData[G1NM.playerFullName].dummyTTDMode == 1 then
            if (not G1NM.TTD[unit] or G1NM.TTD[unit] == 200) then G1NM.TTD[unit] = 4 return else G1NM.TTD[unit] = 200 return end
        elseif G1NMData[G1NM.playerFullName].dummyTTDMode == 2 then
            G1NM.TTD[unit] = 4
            return
        else
            G1NM.TTD[unit] = 200
            return
        end
    end

    if not ObjectExists(unit) or not UnitExists(unit) or G1NM.health(unit) == 0 then G1NM.TTD[unit] = -1 return end

    -- Query current time (throttle updating over time)
    local nTime = GetTime()
    if not G1NM.TTDM[unit] or nTime - G1NM.TTDM[unit].nLastScan >= nScanThrottle then
        -- Current data
        local data = G1NM.health(unit)

        if not G1NM.TTDM[unit] then G1NM.TTDM[unit] = {start = nTime, index = 1, maxvalue = G1NM.health(unit, max)/2, values = {}, nLastScan = nTime, estimate = nil} end

        -- Remember current time
        G1NM.TTDM[unit].nLastScan = nTime

        if G1NM.TTDM[unit].index > nMaxSamples then G1NM.TTDM[unit].index = 1 end
        -- Save new data (Use relative values to prevent "overflow")
        G1NM.TTDM[unit].values[G1NM.TTDM[unit].index] = {dmg = data - G1NM.TTDM[unit].maxvalue, time = nTime - G1NM.TTDM[unit].start}

        if #G1NM.TTDM[unit].values >= 2 then
            -- Estimation variables
            local SS_xy, SS_xx, x_M, y_M = 0, 0, 0, 0

            -- Calc pre-solution values
            for i = 1, #G1NM.TTDM[unit].values do
                z = G1NM.TTDM[unit].values[i]
                -- Calc mean value
                x_M = x_M + z.time / #G1NM.TTDM[unit].values
                y_M = y_M + z.dmg / #G1NM.TTDM[unit].values

                -- Calc sum of squares
                SS_xx = SS_xx + z.time * z.time
                SS_xy = SS_xy + z.time * z.dmg
            end
            -- for i = 1, #G1NM.TTDM[unit].values do
            --     -- Calc mean value
            --     x_M = x_M + G1NM.TTDM[unit].values[i].time / #G1NM.TTDM[unit].values
            --     y_M = y_M + G1NM.TTDM[unit].values[i].dmg / #G1NM.TTDM[unit].values

            --     -- Calc sum of squares
            --     SS_xx = SS_xx + G1NM.TTDM[unit].values[i].time * G1NM.TTDM[unit].values[i].time
            --     SS_xy = SS_xy + G1NM.TTDM[unit].values[i].time * G1NM.TTDM[unit].values[i].dmg
            -- end

            -- Few last addition to mean value / sum of squares
            SS_xx = SS_xx - #G1NM.TTDM[unit].values * x_M * x_M
            SS_xy = SS_xy - #G1NM.TTDM[unit].values * x_M * y_M

            -- Results
            local a_0, a_1, x = 0, 0, 0

            -- Calc a_0, a_1 of linear interpolation (data_y = a_1 * data_x + a_0)
            a_1 = SS_xy / SS_xx
            a_0 = y_M - a_1 * x_M

            -- Find zero-point (Switch back to absolute values)
            a_0 = a_0 + G1NM.TTDM[unit].maxvalue
            x = - (a_0 / a_1)

            -- Valid/Usable solution
            if a_1 and a_1 < 1 and a_0 and a_0 > 0 and x and x > 0 then
                G1NM.TTDM[unit].estimate = x + G1NM.TTDM[unit].start
                -- Fallback
            else
                G1NM.TTDM[unit].estimate = nil
            end

            -- Not enough data
        else
            G1NM.TTDM[unit].estimate = nil
        end
        G1NM.TTDM[unit].index = G1NM.TTDM[unit].index + 1 -- enable
    end

    if not G1NM.TTDM[unit].estimate then
        G1NM.TTD[unit] = math.huge
    elseif nTime > G1NM.TTDM[unit].estimate then
        G1NM.TTD[unit] = -1
    else
        G1NM.TTD[unit] = G1NM.TTDM[unit].estimate-nTime
    end
end
-- ripped from CommanderSirow of the wowace forums

local iterator, collectID

local function spellNotInInterruptList(zone, unitID, spellID)
    if not G1NM.collectionTable.spellCasts[spellID] then
        return not G1NMData.interruptTable[zone] or not G1NMData.interruptTable[zone][unitID] or not G1NMData.interruptTable[zone][unitID][spellID]
    else
        return false
    end
end

function G1NM.interruptFunction(target, interruptID, collect)
    if not collect then
        if not target then target = "target" end
        if not ObjectExists(target) or not UnitExists(target) or not UnitCastingInfo(target) and not UnitChannelInfo(target) then return end
    end
    
    local zone = C_Map.GetBestMapForUnit("player")
    local unitID, spellID, spellName, spellBegin, spellEnd = tostring(ObjectID(target)), nil, nil, nil, nil
    if not collect and (not zone or unitID == "nil") then return end

    if G1NMData[G1NM.playerFullName].collectInfo then
        for i = 1, --[[GetObjectCount()]]G1NM.animalsSize do
            iterator = --[[GetObjectWithIndex(i)]]G1NM.targetAnimals[i]
            collectID = ObjectField(iterator, 0x1920, Types.UInt)
            if UnitCastingInfo(iterator) and collectID ~= 0 and not select(8, UnitCastingInfo(iterator)) and spellNotInInterruptList(zone, ObjectID(iterator), collectID) then
                G1NM.collectionTable.spellCasts[collectID] = {zoneID = zone, mobID = ObjectID(iterator), mobName = ObjectIsPlayer(iterator) and "player" or UnitName(iterator), spellID = collectID, spellName = GetSpellInfo(collectID), type = "cast"}
                G1NM.collectionTable.iteration = G1NM.collectionTable.iteration + 1
            end
            collectID = ObjectField(iterator, 0x1950, Types.UInt)
            if UnitChannelInfo(iterator) and collectID ~= 0 and not select(7, UnitChannelInfo(iterator)) and spellNotInInterruptList(zone, ObjectID(iterator), collectID) then
                G1NM.collectionTable.spellCasts[collectID] = {zoneID = zone, mobID = ObjectID(iterator), mobName = ObjectIsPlayer(iterator) and "player" or UnitName(iterator), spellID = collectID, spellName = GetSpellInfo(collectID), type = "channel"}
                G1NM.collectionTable.iteration = G1NM.collectionTable.iteration + 1
            end
        end
    end

    if not interruptID or not G1NMData.interruptTable[zone][unitID] then return end

    if UnitCastingInfo(target) and not select(9, UnitCastingInfo(target)) then
        spellID, spellName = tostring(select(10, UnitCastingInfo(target))), UnitCastingInfo(target)
        spellBegin         = select(5, UnitCastingInfo(target))*.001
        spellEnd           = select(6, UnitCastingInfo(target))*.001
        for k,v in pairs(G1NMData.interruptTable[zone][unitID]) do
            if v == spellID then
                if v.type ~= "cast" or v.verify ~= spellName then interruptTable[zone][unitID][spellID] = {type = "cast", verify = spellName} end
                if math.random(G1NMData[G1NM.playerFullName].castMin, G1NMData[G1NM.playerFullName].castMax)*.01 < ((GetTime()-spellBegin)/(spellEnd-spellBegin)) then G1NM.cast(target, interruptID, _, _, _, _, "Interrupting") return end
            end
        end
    elseif UnitChannelInfo(target) and not select(8, UnitChannelInfo(target)) then
        spellID    = UnitChannelInfo(target)
        spellBegin = select(5, UnitChannelInfo(target))*.001
        spellEnd   = select(6, UnitChannelInfo(target))*.001
        for k,v in pairs(G1NMData.interruptTable[zone][unitID]) do
            if v == spellID then
                if v.type ~= "channel" or v.verify ~= spellID then interruptTable[zone][unitID][spellID] = {type = "channel", verify = spellID} end
                if math.random(G1NMData[G1NM.playerFullName].channelMin, G1NMData[G1NM.playerFullName].channelMax)*.01 > ((spellEnd-GetTime())/(spellEnd-spellBegin)) then G1NM.cast(target, interruptID, _, _, _, _, "Interrupting") return end
            end
        end
    end
end

function G1NM.dumpInterruptCollection()
    print("Dumping Interrupts")
    for k,v in pairs(interruptTable) do
        print("Zone: "..k)
        if type(v) == "table" then
            for r,c in pairs(interruptTable[k]) do
                print("Mob: "..r)
                for z, x in pairs(interruptTable[k][r]) do
                    print("Spell: "..z)
                end
            end
        end
    end
end

function G1NM.bossCollection()
    local zone = C_Map.GetBestMapForUnit("player")
    if not zone then return end

    for i = 1, math.huge do
        if UnitExists("boss"..i) then
            if not G1NM.animalIsBoss("boss"..i) and not G1NM.collectionTable.bossMobs[ObjectID("boss"..i)] then
                G1NM.collectionTable.bossMobs[ObjectID("boss"..i)] = {zoneID = zone, mobID = ObjectID("boss"..i), mobName = UnitName("boss"..i), type = "boss unit id"}
                G1NM.collectionTable.iteration = G1NM.collectionTable.iteration + 1
            end
            for i = 1, G1NM.animalsSize do
                iterator = G1NM.targetAnimals[i]
                if not G1NM.animalIsBoss(iterator) and UnitAffectingCombat(iterator) and not G1NM.collectionTable.bossMobs[ObjectID(iterator)] then
                    G1NM.collectionTable.bossMobs[ObjectID(iterator)] = {zoneID = zone, mobID = ObjectID(iterator), mobName = UnitName(iterator), type = "aggro while boss unit id exists"}
                    G1NM.collectionTable.iteration = G1NM.collectionTable.iteration + 1
                end
            end
        else
            break
        end
    end
end

function G1NM.dummyCollection()
    local zone = C_Map.GetBestMapForUnit("player")
    if not zone then return end

    for i = 1, GetObjectCount() do
        iterator = GetObjectWithIndex(i)
        if ObjectIsUnit(iterator) and not ObjectIsPlayer(iterator) and not G1NM.collectionTable.dummyMobs[ObjectID(iterator)] and not G1NM.animalIsBoss(iterator) and (G1NM.health(iterator, true) == 1 or string.match(UnitName(iterator), "umm") or string.match(UnitName(iterator), "raining")) then
            G1NM.collectionTable.dummyMobs[ObjectID(iterator)] = {zoneID = zone, mobID = ObjectID(iterator), mobName = UnitName(iterator), type = "possible Training Dummy"}
        end
    end
end

function G1NM.dumpBossCollection()
    for k,v in pairs(bossTable) do
        print(k,v)
        if type(bossTable[k]) == "table" then
            for i,d in pairs(bossTable[k]) do
                print(i,d)
            end
        end
    end
end
print("G1NM: #4 Unit Information LOADED SUCCESSFULLY")
local _ = nil

do -- Combat Check Functions
    function G1NM.validAnimal(unit)
        if not unit then unit = "target" end
        if ObjectExists(unit)
        and UnitExists(unit)
        and UnitIsVisible(unit)
        and UnitCanAttack("player", unit)
        and (G1NM.health(unit) > 1 or tContains(G1NMData.dummiesIDList, ObjectID(unit)))
        -- and UnitName(unit)
        -- and G1NM.animalsAuraBlacklist(unit)
        -- and G1NM.animalsIDBlacklist(unit)
        -- and (not G1NMData[G1NM.playerFullName].cced or not G1NM.unitIsCCed(unit))
        then
            return true
        else
            return false
        end
    end

    function G1NM.animalIsTappedByPlayer(mob)
        if not ObjectExists(mob) then return false end
        if UnitExists("target") and UnitIsUnit("target", mob) then return true end    -- if user is manually targeting mob return true
        if UnitAffectingCombat(mob) and UnitTarget(mob) then                            -- if mob is targetting a party member return true
            local mobTarget = UnitTarget(mob)
            mobTarget = UnitCreator(mobTarget) or mobTarget
            if UnitIsUnit("player", mobTarget) or UnitInParty(mobTarget) then return true end
        end
        return false
    end

    function G1NM.stealthAggroCheck(target)
        if not target then target = "target" end
        if GetNumGroupMembers() < 2 and UnitTarget(target) and UnitIsUnit(UnitTarget(target), "player") then return false end -- If we don't have party members and the mob is targetting us assume it'll reset
        if select(2, GetInstanceInfo()) ~= "none" and GetNumGroupMembers() > 1 then return true end -- if we're in some type of instance and we have party members assume it won't reset
        local isTanking, status, scaledPercent, rawPercent, threatValue
        if GetNumGroupMembers() <= 5 then -- assume 5 members in our group or less = party
            for i = 1, 4 do -- if anyone in our group as threat on mob, safe to disappear
                if UnitExists("party"..i) then
                    isTanking, __, scaledPercent = UnitDetailedThreatSituation(("party"..i), target)
                    if isTanking or scaledPercent and scaledPercent > 0 then return true end
                end
            end
        elseif GetNumGroupMembers() > 5 then
            for i = 1, 40 do -- if anyone in our group as threat on mob, safe to disappear
                if UnitExists("raid"..i) then
                    isTanking, __, scaledPercent = UnitDetailedThreatSituation(("raid"..i), target)
                    if isTanking or scaledPercent and scaledPercent > 0 then return true end
                end
            end
        end
    end
end

do -- Unit Functions
    function G1NM.isCAOCH(unit)
        if not unit then unit = "player" end
        return ObjectExists(unit) and (G1NM.isCA(unit) or G1NM.isCH(unit))
    end

    function G1NM.isCA(unit)
        if not unit then unit = "player" end
        if ObjectExists(unit) and UnitCastingInfo(unit) then return true else return false end
    end

    function G1NM.isCH(unit)
        if not unit then unit = "player" end
        if ObjectExists(unit) and UnitChannelInfo(unit) then return true else return false end
    end

    function G1NM.distanceBetween(target, base)
        if not target then target = "target" end
        if not base   then base   = "player" end
        if not ObjectExists(target) or not ObjectExists(base) then return math.huge end
        local X1, Y1, Z1 = ObjectPosition(target)
        local X2, Y2, Z2 = ObjectPosition(base)
        return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
    end

    local losFlags = bit.bor(0x10, 0x100, 0x1)
    function G1NM.los(guid, other, increase)
        other = other or "player"
        if not ObjectExists(guid) then return false end
        if tContains(G1NMData.skipLoSIDList, ObjectID(guid)) or tContains(G1NMData.skipLoSIDList, ObjectID(other)) then return true end
        local X1, Y1, Z1 = ObjectPosition(guid)
        local X2, Y2, Z2 = ObjectPosition(other)
        return not TraceLine(X1, Y1, Z1  + (increase or 2.35), X2, Y2, Z2 + (increase or 2.35), losFlags);
    end

    function G1NM.animalIsBoss(unit)
        unit = unit or "target"
        if tContains(G1NMData.dummiesIDList, ObjectID(unit)) or tContains(G1NMData.bossIDList, ObjectID(unit)) then return true end
        return false
    end

    function G1NM.getTTD(guid)
        if not guid then guid = "target" end
        return ObjectExists(guid) and G1NM.TTD[ObjectPointer(guid)] or -math.huge
    end

    function G1NM.isStealthed(unit, mode)
        if not unit then unit = "player" end
        if mode == "rogue" then
            if IsStealthed() or G1NM.aura("player", 115192--[[subterfuge]]) or G1NM.aura("player", 185422--[[shadow_dance.buff]]) then return true end
        elseif mode == "all" then
            if IsStealthed() or G1NM.aura("player", 115192--[[subterfuge]]) or G1NM.aura("player", 185422--[[shadow_dance.buff]]) or G1NM.aura("player", 58984--[[shadowmeld]]) then return true end
        elseif mode == "nonDance" then
            if IsStealthed() or G1NM.aura("player", 115192--[[subterfuge]]) or G1NM.aura("player", 58984--[[shadowmeld]]) then return true end
        end
        return false
    end
end

do -- Spell Functions
    function G1NM.spellCDDuration(spell)
        if spell == 0 then return math.huge end
        local start, duration = GetSpellCooldown(spell)
        return start == 0 and 0 or start + duration - GetTime()
    end

    function G1NM.chargeCD(spell)
        if GetSpellCharges(spell) == select(2, GetSpellCharges(spell)) then return 0 end
        return select(4, GetSpellCharges(spell))-(GetTime()-select(3, GetSpellCharges(spell)))
    end

    function G1NM.castTime(spell)
        return (select(4, GetSpellInfo(spell))*0.001)
    end

    function G1NM.executeTime(spell)
        if spell == 0 then return math.huge end
        return math.max(G1NM.castTime(spell), G1NM.globalCD())
    end

    local spellNotKnown = {}
    local spellKnownTransformTable = {
        [106830] = 106832,
        [ 77758] = 106832,
    }
    function G1NM.spellIsReady(spell, execute)
        if type(spell) ~= "string" and type(spell) ~= "number" or spell == "" or spell == 0 then return false end
        local spellTransform = spellKnownTransformTable[spell] or spell
        if not (type(spellTransform) == "number" and GetSpellInfo(GetSpellInfo(spellTransform)) or type(spellTransform) == "string" and GetSpellLink(spellTransform) or IsSpellKnown(spellTransform)) then
            if not spellNotKnown[spellTransform] then
                spellNotKnown[spellTransform] = true
                G1NM.logToFile("Spell not known: "..spellTransform.." Please Verify.")
            end
            return false
        end
        -- if (type(spell) == "number" and GetSpellInfo(GetSpellInfo(spell)) or type(spell) == "string" and GetSpellLink(spell) or IsSpellKnown(spell) or spell == 77758 --[[or UnitLevel("player") == 100]]) -- thrash bear
        -- [[and]] --[[if]]if (G1NM.spellCDDuration(spell) <= select(4, GetNetStats())*.001+G1NM.randomNumberGenerator)
        if G1NM.spellCDDuration(spell) <= tonumber(GetCVar("SpellQueueWindow"))*.001--+G1NM.randomNumberGenerator
        and G1NM.spellIsUsable(spell, execute)
        and (not G1NMData[G1NM.playerFullName].thok or G1NM.thokThrottle < GetTime() or select(4, GetSpellInfo(spell)) <= 0 or G1NM.thokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001)) -- bottom aurar are ice floes , Kil'jaedens cunning, spiritwalker's grace
        and (UnitMovementFlags("player") == 0 or select(4, GetSpellInfo(spell)) <= 0 or spell == 77767 or spell == 56641 or spell == aimed_shot or spell == 2948 or not G1NM.auraRemaining("player", 108839, (select(4, GetSpellInfo(spell))*0.001)) or not G1NM.auraRemaining("player", 79206, (select(4, GetSpellInfo(spell))*0.001)))
        -- Ice Floes, SpiritWalker's Grace
        then
            return true
        else
            return false
        end
    end

    function G1NM.spellCDIsntReady(spell)
        return G1NM.spellCDDuration(spell) > tonumber(GetCVar("SpellQueueWindow"))*.001--+G1NM.randomNumberGenerator
    end

    function G1NM.spellCanAttack(spell, unit, casting, execute)
        if not unit then unit = "target" end
        if string.sub(unit, 1, 6) == "Player" then unit = ObjectPointer("player") end
        if not ObjectExists(unit) or not UnitExists(unit) then return false end
        if G1NM.spellIsReady(spell, execute)
        -- and UnitCanAttack("player", unit)
        and (G1NM.inRange(spell, unit) or UnitName(unit) == "Al'Akir") -- fixme: inrange needs an overhaul in the distant future, example Al'Akir @framework @notimportant
        and (not G1NM.isCAOCH("player") --[[or UnitCastingInfo("player") and (select(6, UnitCastingInfo("player"))/1000-GetTime()) <= select(4, GetNetStats())*.001+G1NM.randomNumberGenerator ]]or casting--[[ and UnitChannelInfo("player") ~= GetSpellInfo(spell) and UnitCastingInfo("player") ~= GetSpellInfo(spell)]])
        and (not G1NMData[G1NM.playerFullName].thok or G1NM.thokThrottle < GetTime() or G1NM.thokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001))
        and (not G1NMData[G1NM.playerFullName].los or G1NM.los(unit))
        and (not G1NMData[G1NM.playerFullName].cced or not G1NM.unitIsCCed(unit))
        then
            return true
        else
            return false
        end
    end

    function G1NM.spellIsUsable(spell, execute)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if (isUsable or execute) and not notEnoughMana then
            return true
        else
            return false
        end
    end

    function G1NM.poolCheck(spell)
        local isUsable, notEnoughMana = IsUsableSpell(spell)
        if G1NM.spellCDDuration(spell) <= 0
        and not isUsable
        and notEnoughMana
        then
            return true
        else
            return false
        end
    end

    local spellOutranged = {}
    function G1NM.inRange(spell, unit)
        if not unit then unit = "target" end
        local spellToString

        if tonumber(spell) then spellToString = GetSpellInfo(spell) end

        if ObjectExists(unit) and UnitExists(unit) and G1NM.health(unit) > 0 then
            local inRange = IsSpellInRange(spellToString, unit)

            if inRange ~= 0 then
                return true
            elseif inRange == 0 then
                if not spellOutranged[spell] then
                    spellOutranged[spell] = true
                    G1NM.logToFile("Spell out of Range: "..spell.." Please Verify.")
                end
                return false
            -- elseif (tContains(G1NM.SpellData.SpellNameRange, spellToString) or tContains(G1NM.SpellData.SpellNameRange, "MM"..spellToString)) then
                --     for i = 1, #G1NM.SpellData.SpellNameRange do
                    --         if G1NM.SpellData.SpellNameRange[i] == spellToString then
                        --             return G1NM.distanceBetween(unit) <= G1NM.SpellData.SpellRange[i]
                    --         elseif G1NM.SpellData.SpellNameRange[i] == "MM"..spellToString then
                        --             return G1NM.distanceBetween(unit) <= (G1NM.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100))
                    --         end
                --     end
            -- elseif FindSpellBookSlotBySpellID(spell) then
                --     return IsSpellInRange(FindSpellBookSlotBySpellID(spell), "spell", unit) == 1
            else
                for i = 1, 200 do
                    if GetSpellBookItemName(i, "spell") == spellToString then
                        if IsSpellInRange(i, "spell", unit) ~= 0 then
                            return true
                        else
                            if not spellOutranged[spell] then
                                spellOutranged[spell] = true
                                G1NM.logToFile("Spell out of Range: "..spell.." Please Verify.")
                            end
                            return false
                        end
                    end
                end
                if not spellOutranged[spell] then
                    spellOutranged[spell] = true
                    G1NM.logToFile("Spell has no range: "..spell.." Please Verify and add Custom.")
                end
            end
        end
    end

    function G1NM.fracCalc(spell)
        local spellFrac = 0
        local cur, max, start, duration = GetSpellCharges(spell)

        if cur then
            if cur >= 1 then spellFrac = spellFrac + cur end
            if spellFrac == max then return spellFrac end
            spellFrac = spellFrac + (GetTime()-start)/duration
            return spellFrac
        else
            return print("Tried to calculate fraction of a non charge based skill")
        end
    end
end

do -- Resources Functions
    function G1NM.health(guid, max, percent, deficit) -- returns the units max health if max is true, percentage remaining if percent is true and max is false, deficit if deficit is true, or current health
        if not guid then guid = "target" end
        if deficit then
            return UnitHealthMax(guid)-UnitHealth(guid)
        elseif percent then
            return UnitHealth(guid)/UnitHealthMax(guid)*100
        elseif max then
            return UnitHealthMax(guid)
        else
            return UnitHealth(guid)
        end
    end

    function G1NM.pm() return UnitPower("player")/UnitPowerMax("player")*100 end -- return percentage of mana or default power

    function G1NM.pp(mode) -- Returns Primary Resources, modes are max or deficit or tomax otherwise current, Excluding Chi and Combo Points Use G1NM.CP(mode)
        local vPower = nil
        if G1NMData[G1NM.playerFullName].class == "WARRIOR" then vPower = 1 end -- Rage
        if G1NMData[G1NM.playerFullName].class == "PALADIN" and G1NM.currentSpec == 3 then vPower = 9 end -- Holy Power
        if G1NMData[G1NM.playerFullName].class == "HUNTER" then vPower = 2 end -- Focus
        if G1NMData[G1NM.playerFullName].class == "ROGUE" then vPower = 3 end -- Energy Use G1NM.CP() for Combo Points
        if G1NMData[G1NM.playerFullName].class == "PRIEST" and G1NM.currentSpec == 3 then vPower = 13 end -- Insanity
        if G1NMData[G1NM.playerFullName].class == "SHAMAN" and G1NM.currentSpec ~= 3 then vPower = 11 end -- Maelstrom
        if G1NMData[G1NM.playerFullName].class == "MAGE" and G1NM.currentSpec == 1 then vPower = 16 end -- Arcane Charges
        if G1NMData[G1NM.playerFullName].class == "WARLOCK" then vPower = 7 end -- Soul Shards
        if G1NMData[G1NM.playerFullName].class == "MONK" and G1NM.currentSpec == 1 then vPower = 3 end -- Energy
        if G1NMData[G1NM.playerFullName].class == "MONK" and G1NM.currentSpec == 3 then vPower = 3 end -- Energy
        if G1NMData[G1NM.playerFullName].class == "DRUID" and G1NM.currentSpec == 1 then vPower = 8 end -- Astral Power
        if G1NMData[G1NM.playerFullName].class == "DRUID" and G1NM.currentSpec == 2 then vPower = 3 end -- Energy Use G1NM.CP() for Combo Points
        if G1NMData[G1NM.playerFullName].class == "DRUID" and G1NM.currentSpec == 3 then vPower = 1 end -- Rage
        if G1NMData[G1NM.playerFullName].class == "DEMONHUNTER" and G1NM.currentSpec == 1 then vPower = 17 end -- Fury
        if G1NMData[G1NM.playerFullName].class == "DEMONHUNTER" and G1NM.currentSpec == 2 then vPower = 18 end -- Pain
        if G1NMData[G1NM.playerFullName].class == "DEATHKNIGHT" then vPower = 6 end -- Runic Power
        if not vPower then vPower = 0 end
        if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) elseif mode == "tomax" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower))/GetPowerRegen() else return UnitPower("player", vPower) end
    end

    function G1NM.cp(mode) -- Returns Chi and Combo Points, modes are max or deficit otherwise current, for Primary Resources Use G1NM.PP(mode)
        local vPower = (G1NMData[G1NM.playerFullName].class == "MONK" and 12 or G1NMData[G1NM.playerFullName].class == "ROGUE" and 4)
        if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) else return UnitPower("player", vPower) end
    end

    function G1NM.globalCD()
        -- TODO: check this = [Cat Form] druids, and monks, whose abilities mostly have one second global cooldowns.
        if G1NMData[G1NM.playerFullName].class == "ROGUE" or G1NMData[G1NM.playerFullName].class..G1NM.currentSpec == "MONK3" then return 1 end
        return math.max((1.5/(1+GetHaste()*.01)), 0.75)
    end

    --[[
        DoTs whose interval don't scale off haste?
        Barbed Shot
        Lacerate (Hunter and Druid)
        Rake
        Hemorrhage
        Crimson Tempest
        Rend
        Soul Reaper?

        Deep Wounds
        Thrash
        Frost Fever
        Garrote
        Nightblade
        Rip
        Rupture
    ]]
    function G1NM.simCSpellHaste()
        return 1/(1+GetHaste()*.01)
    end
end

do -- Aura Functions
    local auraTable = {}
    local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3

    -- You can do an explicit filter for the below functions but I only recommend using "PLAYER" or "RAID" for your purposes. If for whatever reason you need to explicitly find only buff or debuff you can use "HELPFUL" or "HARMFUL"
    function G1NM.aura(guid, buff, filter) -- Example G1NM.aura("target", 1234, "PLAYER") filter isn't required.
        if type(guid) == "string" and string.sub(guid, 1, 6) == "Player" then guid = "player" end
        if not ObjectExists(guid) or not UnitExists(guid) then return false end

        if buff == 0 or buff == "" then return false end
        local buffName, buffTypeNumber
        if type(buff) == "number" then
            buffName = GetSpellInfo(buff)
            buffTypeNumber = true
        end

        local index = 0
        repeat
            index = index + 1
            name, _, _, _, _, _, _, _, _, spellID = UnitAura(guid, index, filter)
            if name and (buffTypeNumber and spellID == buff or not buffTypeNumber and name == buff) then return UnitAura(guid, index, filter) end
        until (not UnitAura(guid, index, filter))
        if not filter or not string.match(filter, "FUL") then
            index = 0
            filter = filter and filter.."|HARMFUL" or "HARMFUL"
            repeat
                index = index + 1
                name, _, _, _, _, _, _, _, _, spellID = UnitAura(guid, index, filter)
                if name and (buffTypeNumber and spellID == buff or not buffTypeNumber and name == buff) then return UnitAura(guid, index, filter) end
            until (not UnitAura(guid, index, filter))
        end
    end

    function G1NM.auraRemaining(unit, buff, time, filter) -- ... is the same as above, this checks for <= the time argument. if you want greater than, than do "not G1NM.auraRemaining", this will return true if the aura isn't there
        if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) then
            local name, _, _, _, _, expires = G1NM.aura(unit, buff, filter)
            if not name then
                return true
            elseif expires == 0 then
                return false
            elseif (expires-GetTime()) <= time then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    function G1NM.buffRemaining(unit, buff, filter) -- returns the remaining time on an aura
        if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) then
            local name, _, _, _, _, expires = G1NM.aura(unit, buff, filter)
            if not name then
                return 0
            elseif expires == 0 then
                return math.huge
            else
                return expires-GetTime()
            end
        else
            return -math.huge
        end
    end

    function G1NM.auraStacks(unit, buff, stacks, filter) -- ... is the same as above, this checks for >= stacks argument, if you want less than, than do "not G1NM.auraStacks", this will return false if the aura isn't there
        if buff == "" or buff == 0 then return false end
        if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
        if ObjectExists(unit) and UnitExists(unit) then
            local name, _, count = G1NM.aura(unit, buff, filter)
            if not name then return false end
            if count >= stacks then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    function G1NM.bloodlust(remaining)
        if remaining then
            return ((G1NM.aura("player", 80353) and not G1NM.auraRemaining("player", 80353, remaining))
            or (G1NM.aura("player", 2825) and not G1NM.auraRemaining("player", 2825, remaining))
            or (G1NM.aura("player", 32182) and not G1NM.auraRemaining("player", 32182, remaining))
            or (G1NM.aura("player", 90355) and not G1NM.auraRemaining("player", 90355, remaining))
            or (G1NM.aura("player", 160452) and not G1NM.auraRemaining("player", 160452, remaining))
            or (G1NM.aura("player", 146555) and not G1NM.auraRemaining("player", 146555, remaining))
            or (G1NM.aura("player", 178207) and not G1NM.auraRemaining("player", 178207, remaining)))
        end
        if G1NM.aura("player", 80353) or G1NM.aura("player", 2825) or G1NM.aura("player", 32182) or G1NM.aura("player", 90355) or G1NM.aura("player", 160452) or G1NM.aura("player", 146555) or G1NM.aura("player", 178207) then
            return true
        else
            return false
        end
    end
end

do -- AoE Functions
    function G1NM.playerCount(yards, tapped, goal, mode, goal2)
        local GMobCount = 0
        local unitPlaceholder = nil

        if mode == "==" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount == goal
        elseif mode == "<=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount <= goal
        elseif mode == "<" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return false end
            end
            return GMobCount < goal
        elseif mode == ">=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return true end
            end
            return false
        elseif mode == ">" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            return false
        elseif mode == "~=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            return GMobCount < goal
        elseif mode == "inclusive" then
            local higherGoal = math.max(goal, goal2)
            local lowerGoal = math.min(goal, goal2)
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > higherGoal then return false end
            end
            if GMobCount < lowerGoal then return false end
            return true
        elseif mode == "exclusive" then
            local higherGoal = math.max(goal, goal2)
            local lowerGoal = math.min(goal, goal2)
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= higherGoal then return false end
            end
            if GMobCount <= lowerGoal then return false end
            return true
        end
        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        return GMobCount
    end

    function G1NM.targetCount(target, yards, tapped, goal, mode, goal2)
        if not target then target = "target" end
        if not ObjectExists(target) or not UnitExists(target) or UnitHealth(target) == 0 then return 0 end

        local GMobCount = 0
        local unitPlaceholder = nil

        if mode == "==" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount == goal
        elseif mode == "<=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount <= goal
        elseif mode == "<" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return false end
            end
            return GMobCount < goal
        elseif mode == ">=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return true end
            end
            return false
        elseif mode == ">" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            return false
        elseif mode == "~=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            if GMobCount < goal then return true end
            return false
        elseif mode == "inclusive" then
            local higherGoal = math.max(goal, goal2)
            local lowerGoal = math.min(goal, goal2)
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > higherGoal then return false end
            end
            if GMobCount < lowerGoal then return false end
            return true
        end
        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder, target) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end
        --[[if GMobCount == 0 then return 1 else ]]return GMobCount
    end

    function G1NM.unitCount(target, yards, tapped, goal, mode, goal2)
        if not target then target = "pet" end
        if not ObjectExists(target) or not UnitExists(target) or UnitHealth(target) == 0 then return 0 end

        local GMobCount = 0
        local unitPlaceholder = nil

        if mode == "==" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount == goal
        elseif mode == "<=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return false end
            end
            return GMobCount <= goal
        elseif mode == "<" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return false end
            end
            return GMobCount < goal
        elseif mode == ">=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount >= goal then return true end
            end
            return false
        elseif mode == ">" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            return false
        elseif mode == "~=" then
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > goal then return true end
            end
            if GMobCount < goal then return true end
            return false
        elseif mode == "inclusive" then
            local higherGoal = math.max(goal, goal2)
            local lowerGoal = math.min(goal, goal2)
            for i = 1, G1NM.animalsSize do
                unitPlaceholder = G1NM.targetAnimals[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(target, unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
                if GMobCount > higherGoal then return false end
            end
            if GMobCount < lowerGoal then return false end
            return true
        end
        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and G1NM.distanceBetween(unitPlaceholder, "target") <= yards+UnitCombatReach(unitPlaceholder) and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or not tapped) then
                GMobCount = GMobCount + 1
            end
        end

        if GMobCount == 0 then return 1 else return GMobCount end
    end

    function G1NM.pullAllies(reach)
        if G1NM.humansSize == 0 then return {} end
        local unitPlaceholder = nil
        local units = {}
        local unitsSize = 0
        for i = 1, G1NM.humansSize do
            unitPlaceholder = G1NM.targetHumans[i].player
            if ObjectExists(unitPlaceholder) then
                if G1NM.distanceBetween(unitPlaceholder) <= reach then
                    units[unitsSize+1] = unitPlaceholder
                    unitsSize = unitsSize + 1
                end
            end
        end
        return units
    end

    function G1NM.smartAoEFriendly(reach, size, tableX)
        local units = G1NM.pullAllies(reach)
        local win = 0
        local winners = {}
        for __, enemy in ipairs(units) do
            local preliminary = {} -- new
            local neighbors = 0
            for __, neighbor in ipairs(units) do
                if G1NM.distanceBetween(enemy, neighbor) <= size then
                    table.insert(preliminary, neighbor)
                    neighbors = neighbors + 1
                end
            end
            if neighbors >= win and neighbors > 0 then
                winners = preliminary
                -- table.insert(winners, enemy)
                win = neighbors
            end
        end
        if tableX then return winners end
        return G1NM.avgPosObjects(winners)
    end

    function G1NM.pullEnemies(reach, tapped, combatreach) -- gets enemies in an AoE
        if G1NM.animalsSize == 0 then return {} end
        local unitPlaceholder = nil
        local units = {}
        local unitsSize = 0
        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                if G1NM.distanceBetween(unitPlaceholder) <= reach+(combatreach and UnitCombatReach(unitPlaceholder) or 0) and (not tapped or G1NM.animalIsTappedByPlayer(unitPlaceholder) or tContains(G1NMData.dummiesIDList, ObjectID(unitPlaceholder))) then
                    units[unitsSize+1] = unitPlaceholder
                    unitsSize = unitsSize + 1
                end
            end
        end
        return units
    end

    function G1NM.smartAoE(reach, size, tapped, tableX) -- smart aoe placement
        local units = G1NM.pullEnemies(reach, tapped)
        local win = 0
        local winners = {}
        for __, enemy in ipairs(units) do
            local preliminary = {} -- new
            local neighbors = 0
            for __, neighbor in ipairs(units) do
                if G1NM.distanceBetween(enemy, neighbor) <= size then
                    table.insert(preliminary, neighbor) -- new
                    neighbors = neighbors + 1
                end
            end
            if neighbors >= win and neighbors > 0 then
                winners = preliminary
                -- table.insert(winners, enemy)
                win = neighbors
            end
        end
        if tableX then return winners end
        return G1NM.avgPosObjects(winners)
    end

    function G1NM.avgPosObjects(table)
        local Total = #table;
        local X, Y, Z = 0, 0, 0;

        if Total == 0 then return nil, nil, nil end

        for Key, ThisObject in pairs(table) do
            if ThisObject then
                local ThisX, ThisY, ThisZ = ObjectPosition(ThisObject);
                if ThisX and ThisY then
                    X = X + ThisX;
                    Y = Y + ThisY;
                    Z = Z + ThisZ;
                end
            end
        end

        X = X / Total;
        Y = Y / Total;
        Z = Z / Total;
        return X, Y, Z;
    end

    function G1NM.dotCached(obj, table)
        local table1, table2 = "t"..table, "tNoObject"..table
        if tContains(G1NM[table1], obj) or tContains(G1NM[table2], obj) then return false else return true end
    end

    function G1NM.multiDoT(spell, range)
        local unitPlaceholder = nil
        local name = ""
        local spellName = GetSpellInfo(spell)
        local spelltable = string.gsub(spellName, "[%s:]", "")

        if not G1NM["tNoObject"..spelltable] then G1NM["tNoObject"..spelltable] = {} end
        if not G1NM["t"..spelltable] then G1NM["t"..spelltable] = {} end

        for i = #G1NM["tNoObject"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = G1NM["tNoObject"..spelltable][i]
            if not tContains(G1NM.targetAnimals, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not G1NM.validAnimal(unitPlaceholder) or range and type(range) == "number" and range < G1NM.distanceBetween(obj) then
                table.remove(G1NM["tNoObject"..spelltable], i) -- preliminaries
            else -- check for aura
                local name = G1NM.aura(unitPlaceholder, spell, "", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if name then table.remove(G1NM["tNoObject"..spelltable], i) end -- aura is there
            end
        end
        for i = #G1NM["t"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = G1NM["t"..spelltable][i]
            if not tContains(G1NM.targetAnimals, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not G1NM.validAnimal(unitPlaceholder)  or range and type(range) == "number" and range < G1NM.distanceBetween(unitPlaceholder) then table.remove(G1NM["t"..spelltable], i) -- preliminaries
            else
                name = ""
                name = G1NM.aura(unitPlaceholder, spell, "", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if not name then table.remove(G1NM["t"..spelltable], i) end -- aura is not there
            end
        end

        for i = 1, G1NM.animalsSize do
            unitPlaceholder = G1NM.targetAnimals[i]
            if ObjectExists(unitPlaceholder) then
                unitPlaceholder = G1NM.targetAnimals[i]
                if G1NM.dotCached(unitPlaceholder, spelltable)
                and (G1NM.animalIsTappedByPlayer(unitPlaceholder) or tContains(G1NMData.dummiesIDList, ObjectID(unitPlaceholder)))
                and (not range or type(range) == "number" and range >= G1NM.distanceBetween(unitPlaceholder)+UnitCombatReach(unitPlaceholder)) then
                    name = ""
                    name = G1NM.aura(unitPlaceholder, spell, "", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                    if name then table.insert(G1NM["t"..spelltable], unitPlaceholder) end
                    if not name and UnitCanAttack("player", unitPlaceholder) --[[and G1NM.los(unitPlaceholder)]] then table.insert(G1NM["tNoObject"..spelltable], unitPlaceholder) end
                end
            end
        end
    end

    function G1NM.multiHoT(spell, range)
        local unitPlaceholder = nil
        local name = ""
        local spellName = GetSpellInfo(spell)
        local spelltable = string.gsub(spellName, "[%s:]", "")

        if not G1NM["tNoObject"..spelltable] then G1NM["tNoObject"..spelltable] = {} end
        if not G1NM["t"..spelltable] then G1NM["t"..spelltable] = {} end

        for i = #G1NM["tNoObject"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = G1NM["tNoObject"..spelltable][i]
            if not tContains(G1NM.targetHumans, unitPlaceholder) or not ObjectExists(unitPlaceholder) or range and range < G1NM.distanceBetween(obj) then
                table.remove(G1NM["tNoObject"..spelltable], i) -- preliminaries
            else -- check for aura
                local name = G1NM.aura(unitPlaceholder, spell, "", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if name then table.remove(G1NM["tNoObject"..spelltable], i) end -- aura is there
            end
        end
        for i = #G1NM["t"..spelltable], 1, -1 do -- delete don't belong
            unitPlaceholder = G1NM["t"..spelltable][i]
            if not tContains(G1NM.targetHumans, unitPlaceholder) or not ObjectExists(unitPlaceholder) or range and range < G1NM.distanceBetween(unitPlaceholder) then table.remove(G1NM["t"..spelltable], i) -- preliminaries
            else
                name = ""
                name = G1NM.aura(unitPlaceholder, spell, "", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                if not name then table.remove(G1NM["t"..spelltable], i) end -- aura is not there
            end
        end

        for i = 1, G1NM.humansSize do
            unitPlaceholder = G1NM.targetHumans[i].player
            if ObjectExists(unitPlaceholder) then
                if G1NM.dotCached(unitPlaceholder, spelltable)
                and (not range or range >= G1NM.distanceBetween(unitPlaceholder)+UnitCombatReach(unitPlaceholder)) then
                    name = ""
                    name = G1NM.aura(unitPlaceholder, spell, "", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Lunar", "PLAYER") or G1NM.aura(unitPlaceholder, spell, "Solar", "PLAYER")
                    if name then table.insert(G1NM["t"..spelltable], unitPlaceholder) end
                    if not name --[[and G1NM.los(unitPlaceholder)]] then table.insert(G1NM["tNoObject"..spelltable], unitPlaceholder) end
                end
            end
        end
    end

    function G1NM.debugDotCache(spell)
        local spelltable = string.gsub(spell, "[%s:]", "")
        if not spelltable then return false end

        local unitPlaceholder = nil

        if not G1NM["t"..spelltable] then print("Dot Cache was never ran for this spell.") return false end
        if #G1NM["t"..spelltable] == 0 then
            print("No active dots up for this spell.")
        else
            for k,v in ipairs(G1NM["t"..spelltable]) do
                print("Active DoT", UnitName(v), G1NM.getTTD(v))
            end
        end

        if #G1NM["tNoObject"..spelltable] == 0 then
            print("No inactive dots up for this spell.")
        else
            for k,v in ipairs(G1NM["tNoObject"..spelltable]) do
                print(UnitName(v), G1NM.getTTD(v))
            end
        end
    end
end

do -- Cast Functions
    local file, tempStr = "", ""
    function G1NM.cast(guid, name, x, y, z, interrupt, reason)
        --if G1NM.waitForCombatLog then return end
        -- local name = Name
        -- if type(Name) == "number" then Name = GetSpellInfo(Name) end

        --if UnitChannelInfo("player") then
        --    local spell = UnitChannelInfo("player")

        --    if type(interrupt) == "string" and interrupt ~= "SpellToInterrupt" then
        --        if interrupt == "chain" and spell == Name then G1NM.logToFile("Going to Chain.") end
        --        if spell == interrupt then SpellStopCasting() end
        --        if interrupt == "nextTick" then
        --            G1NM.interruptNextTick = spell
        --            return
        --        end
        --        if ("nextTick "..spell) == interrupt then
        --            G1NM.interruptNextTick = string.gsub(interrupt, "nextTick ", "")
        --            return
        --        end
        --    elseif type(interrupt) == "table" then
        --        if tContains(interrupt, spell) then SpellStopCasting() end
        --    elseif interrupt == "all" then
        --        SpellStopCasting()
        --    elseif type(interrupt) == "number" then
        --        if name == interrupt then SpellStopCasting() end
        --    elseif interrupt ~= "SpellToInterrupt" and interrupt ~= nil then
        --        return
        --    end
        --elseif UnitCastingInfo("player") then
        --    local spell = UnitCastingInfo("player")
        --    if type(interrupt) == "string" and interrupt ~= "SpellToInterrupt" then
        --        if spell == interrupt then SpellStopCasting() end
        --    elseif type(interrupt) == "table" then
        --        if tContains(interrupt, spell) then SpellStopCasting() end
        --    elseif interrupt == "all" then
        --        SpellStopCasting()
        --    elseif type(interrupt) == "number" then
        --        if name == interrupt then SpellStopCasting() end
        --    elseif interrupt ~= "SpellToInterrupt" and interrupt ~= nil then
        --        return
        --    end
        --end

        if not guid then guid = "target" end
        if UnitGUID("player") == guid then guid = "player" end

        CastSpellByID(name, guid)
        -- CastSpellByName(Name, guid)

        if IsAoEPending() then
            if x and y and z then
                CastAtPosition(x + math.random(-0.01, 0.01), y + math.random(-0.01, 0.01), z + math.random(-0.01, 0.01))
            else
                rotationXC, rotationYC, rotationZC = ObjectPosition(guid)
                CastAtPosition(rotationXC + math.random(-0.01, 0.01), rotationYC + math.random(-0.01, 0.01), rotationZC + math.random(-0.01, 0.01))
            end
            if IsAoEPending() then
                CancelPendingSpell()
                return
            end
        end
        -- debug stuff
        G1NM.debugTable["debugStack"] = string.gsub(debugstack(2, 100, 100), 'Interface\\AddOns\\G1\\.-(%w+)%.lua', "file: %1, line")
        G1NM.debugTable["pointer"] = guid or "N/A"
        if G1NM.debugTable["pointer"] ~= "N/A" then G1NM.debugTable["nameOfTarget"] = UnitName(guid) else G1NM.debugTable["nameOfTarget"] = "N/A" end
        G1NM.debugTable["ogSpell"] = name
        G1NM.debugTable["Spell"] = Name
        G1NM.debugTable["x"] = x or "N/A"
        G1NM.debugTable["y"] = y or "N/A"
        G1NM.debugTable["z"] = z or "N/A"
        G1NM.debugTable["interrupt"] = interrupt or "N/A"
        G1NM.debugTable["RotationCacheCounter"] = rotationCacheCounter
        G1NM.debugTable["timeSinceLast"] = G1NM.debugTable["time"] and (GetTime() - G1NM.debugTable["time"]) or 0
        G1NM.debugTable["time"] = GetTime()
        G1NM.debugTable["reason"] = reason or "N/A"
        if G1NMData[G1NM.playerFullName].log then
            file = ReadFile(G1NMData.logFile)
            if file then
                tempStr = json.encode(G1NM.debugTable, {indent=true})
                WriteFile(G1NMData.logFile, file..",\n"..tempStr)
            end
        end
        G1NM.interruptNextTick = nil
        G1NM.toggleLog = true
        return true
    end
end

do -- Gear, Artifact, Azerite Functions
    function G1NM.getTraitCurrentRank(artifact, perk)
        if not G1NM.equippedGear then return 0 end
        if G1NM.equippedGear.MainHand ~= artifact or not G1NM.artifactWeapon[G1NM.equippedGear.MainHand].weaponPerks[perk] then return 0 end
        return G1NM.artifactWeapon[G1NM.equippedGear.MainHand].weaponPerks[perk].currentRank
    end

    function G1NM.azeritePowerLearned(powerID)
        local isSelected        
        for _, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
            isSelected = C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID)
            if isSelected then return true end
        end
        return false
    end

    function G1NM.azeritePowerRank(powerID)
        local rank = 0
        for _, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
            rank = rank + (C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) and 1 or 0)
        end
        return rank
    end

    function G1NM.useInventoryItem(slot, itemID)
        if select(3, GetInventoryItemCooldown("player", slot)) == 1 and GetInventoryItemCooldown("player", slot) == 0 then
            if itemID and GetInventoryItemID("player", slot) ~= itemID then return end
            UseInventoryItem(slot)
        end
    end

    function G1NM.useRings()
        if select(3, GetInventoryItemCooldown("player", 11)) == 1 and GetInventoryItemCooldown("player", 11) == 0 then UseInventoryItem(11) end
        if select(3, GetInventoryItemCooldown("player", 12)) == 1 and GetInventoryItemCooldown("player", 12) == 0 then UseInventoryItem(12) end
    end

    function G1NM.useTrinkets()
        if select(3, GetInventoryItemCooldown("player", 13)) == 1 and GetInventoryItemCooldown("player", 13) == 0 then UseInventoryItem(13) end
        if select(3, GetInventoryItemCooldown("player", 14)) == 1 and GetInventoryItemCooldown("player", 14) == 0 then UseInventoryItem(14) end
    end
end

do -- Encounter Functions
    --     local zoneTable = {
    --         [1041] = { -- Halls of Valor
    --             ["Hymdall"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --             },
    --             ["Hyrja"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --             },
    --             ["Fenryr"] = {
    --                 desired_targets = 1,
    --                 adds = "heroic",
    --                 adds_count = 3,
    --             },
    --             ["God-King Skovald"] = {
    --                 desired_targets = 1,
    --                 adds = "heroic",
    --                 adds_count = 6,
    --             },
    --             ["Odyn"] = {
    --                 desired_targets = 1,
    --                 adds = "heroic",
    --                 adds_count = 1,
    --             },
    --         },
    --         [1042] = { -- Maw of Souls
    --             ["Ymiron, the Fallen King"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --             },
    --             ["Harbaron"] = {
    --                 desired_targets = 1,
    --                 adds = 2,
    --                 adds1_count = 3, -- Fragment
    --                 adds2_count = 1, -- Shackled Servitor
    --             },
    --             ["Helya"] = {
    --                 desired_targets = 1,
    --                 adds = false, -- ? should we think of phase 1 as adds?
    --             },
    --         },
    --         [1045] = { -- Vault of the Wardens
    --             ["Tirathon Saltheril"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --             },
    --             ["Inquisitor Tormentorum"] = {
    --                 desired_targets = 1,
    --                 adds = true,
    --                 adds_count = 3,
    --             },
    --             ["Ash'golm"] = {
    --                 desired_targets = 1,
    --                 adds = false, -- embers are a bit hard to account for
    --             },
    --             ["Glazer"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --             },
    --             ["Cordana Felsong"] = {
    --                 desired_targets = 1,
    --                 adds = false, -- she is invulnerable whenever there is an add so no adds effectively
    --             },
    --         },
    --         [1046] = { -- Eye of Azshara
    --             ["Warlord Parjesh"] = {
    --                 desired_targets = 1,
    --                 adds = true,
    --                 adds_count = 2,
    --             },
    --             ["Lady Hatecoil"] = {
    --                 desired_targets = 1,
    --                 adds = true,
    --                 adds_count = 5, -- Saltsea Globules how many? believe it's one per player
    --             },
    --             ["King Deepbeard"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --                 adds_count = 0,
    --             },
    --             ["Serpentrix"] = {
    --                 desired_targets = 1,
    --                 adds = false, -- Heads are too spread apart to serve as adds
    --                 adds_count = 0,
    --             },
    --             ["Wrath of Azshara"] = {
    --                 desired_targets = 1,
    --                 adds = false,
    --                 adds_count = 0,
    --             },
    --         },
    --         [1065] = { -- Neltharion's Lair
    --             ["Rokmora"] = {
    --                 desired_targets = 1,
    --                 adds = false, -- ignore skitters
    --                 adds_count = 0,
    --             },
    --             ["Ularogg Cragshaper"] = {
    --                 desired_targets = 1,
    --                 adds = false, -- treat idols as adds?
    --                 adds_count = 0,
    --             },
    --             ["Naraxas"] = {
    --                 desired_targets = 1,
    --                 adds = true,
    --                 adds_count = 2, -- ?
    --             },
    --             ["Dargrul the Underking"] = {
    --                 desired_targets = 1,
    --                 adds = true,
    --                 adds_count = 1,
    --             },
    --         },
    --         [1066] = { -- Assault on Violet Hold
    --         },
    --         [1067] = { -- Darkheart Thicket
    --         },
    --         [1079] = { -- The Arcway
    --         },
    --         [1081] = { -- Black Rook Hold
    --         },
    --         [1087] = { -- Court of Stars
    --         },

    --         [1088] = { -- The Nighthold
    --         },
    --         [1094] = { -- The Emerald Nightmare
    --         },
    --     }

    -- function

    -- function G1NM.nonExecutePlayers()
    --     local execute, nonexecute = 0, 0
    --     local obj
    --     for i = 1, G1NM.humansSize do
    --         obj = G1NM.targetHumans[i]
    --         if obj.execute then execute = execute + 1 else nonexecute = nonexecute + 1 end
    --     end
    --     return (nonexecute+execute ~= 0 and nonexecute/(nonexecute+execute) or 0)
    -- end
end

do -- Tooltip Functions
    local stringPlaceholderOne, stringPlaceholderTwo
    local spellName, spellID
    local captureNumber = 0

    local function CreateHealingTooltip()
        G1NM.healingTooltip = CreateFrame("GameTooltip", "G1HealingTooltip", nil, "GameTooltipTemplate")
        G1HealingTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end

    local matchNumber = {
        [18562]  = 1, -- Swiftmend
        [8936]   = 1, -- Regrowth

        [116694] = 1, -- Effuse
        [124682] = 1, -- Enveloping Mist
        [191837] = 5, -- Essence Font
        [115310] = 2, -- Revival
        [205406] = 1, -- Sheilun's Gift
        [116670] = 2, -- Vivify
        [117907] = 1, -- Mastery: Gust of Mists
        [199640] = 3, -- Celestial Breath
        [123986] = 3, -- Chi Burst
        [124081] = 3, -- Zen Pulse
        [197945] = 1, -- Mistwalk
        [196725] = 1, -- Refreshing Jade Wind

        [19750]  = 1, -- Flash of Light
        [82326]  = 1, -- Holy Light
        [20473]  = 2, -- Holy Shock
        [85222]  = 3, -- Light of Dawn
        [183998] = 1, -- Light of the Martyr
        [223306] = 2, -- Bestow Faith
        [114158] = 6, -- Light's Hammer
        [114165] = 5, -- Holy Prism

        [200829] = 1, -- Plea
        [194509] = 2, -- Power Word: Radiance
        [186263] = 1, -- Shadow Mend
        [152118] = 2, -- Clarity of Will
        [110744] = 2, -- Divine Star
        [120517] = 2, -- Halo
        [204065] = 3, -- Shadow Covenant
        [207946] = 2, -- Light's Wrath
    }

    function G1NM.healingAmount(spell)
        if not matchNumber[spell] then print("FUCK! YOU IDIOT!", spell, GetSpellInfo(spell)) end
        stringPlaceholderOne = ""
        if GetCVar("SpellTooltip_DisplayAvgValues") ~= "1" then SetCVar("SpellTooltip_DisplayAvgValues", 1) end
        if type(spell) == "number" then spellID = spell; spellName = GetSpellInfo(spell) elseif spell == nil then print(G1NM.AddonName..": You passed nil to healingAmount()") return 0 elseif type(spell) == "string" then print(G1NM.AddonName..": Don't pass a string to healingAmount()") return 0 end
        captureNumber = 0
        for capture in string.gmatch(GetSpellDescription(spell), "%d+%p*%d*%p*%d*%p*%d*") do
            captureNumber = captureNumber + 1
            if captureNumber == matchNumber[spellID] then stringPlaceholderOne = capture break end
        end
        stringPlaceholderOne = string.gsub(stringPlaceholderOne, "%D", "")
        return tonumber(stringPlaceholderOne)
    end

    local matchNumberDMG = {
        [120517] = 3, -- Halo
        [207946] = 2, -- Light's Wrath
    }

    function G1NM.damageAmount(spell)
        if GetCVar("SpellTooltip_DisplayAvgValues") ~= "1" then SetCVar("SpellTooltip_DisplayAvgValues", 1) end
        if type(spell) == "number" then spellID = spell; spellName = GetSpellInfo(spell) elseif spell == nil then print("\n"..G1NM.AddonName..": You passed nil to healingAmount()\n") return 0 elseif type(spell) == "string" then print("\n"..G1NM.AddonName..": Don't pass a string to healingAmount()\n") return 0 end
        captureNumber = 0
        for capture in string.gmatch(GetSpellDescription(spell), "%d+%p*%d*%p*%d*%p*%d*") do
            captureNumber = captureNumber + 1
            if captureNumber == matchNumberDMG[spellID] then stringPlaceholderOne = capture break end
        end
        stringPlaceholderOne = string.gsub(stringPlaceholderOne, "%D", "")
        return tonumber(stringPlaceholderOne)
    end
end
print("G1NM: #5 Rotation Check Functions LOADED SUCCESSFULLY")
local _ = nil

function G1NM.Toggle(command)
    command = command:lower()

    if command == "aoe" then G1NM.toggleAoE()            return true end
    if command == "cds" then G1NM.toggleCDs()            return true end
    -- if command == "d"   then G1NM.runDebug()             return true end
    if command == "i"   then G1NM.toggleInterrupt()      return true end
    if command == "o"   then G1NMACD:Open("G1NM_Settings") return true end
    if command == "t"   then G1NM.toggleRun()            return true end
end

function G1NM.runDebug()
    -- TODO: figure out runDebug purpose
end

function G1NM.toggleRun()
    -- TODO: Figure out waitForCombatLog purpose
    -- G1NM.waitForCombatLog = false
    G1NM.allowRun = not G1NM.allowRun
    G1NM.monitorAnimationToggle(G1NM.allowRun and "on" or "off")
    print(G1NM.GetAddonName()..": "..(G1NM.allowRun and "On" or "Off"))
end

function G1NM.toggleAoE()
    G1NM.aoe = not G1NM.aoe
    print(G1NM.GetAddonName()..": AoE now "..(G1NM.aoe and "on" or "off")..".")
end

function G1NM.toggleCDs()
    G1NM.cds = not G1NM.cds
    print(G1NM.GetAddonName()..": CDs now "..(G1NM.cds and "on" or "off")..".")
end

function G1NM.toggleInterrupt()
    G1NMData[G1NM.playerFullName].interrupt = not G1NMData[G1NM.playerFullName].interrupt
    print(G1NM.GetAddonName()..": Interrupt now "..(G1NMData[G1NM.playerFullName].interrupt and "on" or "off")..".")
    G1NM.saveSetting("interrupt", G1NMData[G1NM.playerFullName].interrupt)
end

function G1NM.createMonitorFrame()
    if not G1NMMonitorParentFrame then
        CreateFrame("Frame", "G1NMMonitorParentFrame", UIParent)
        G1NMMonitorParentFrame:SetFrameStrata("MEDIUM")
        G1NMMonitorParentFrame:SetWidth("64")
        G1NMMonitorParentFrame:SetHeight("64")

        if G1NMData[G1NM.playerFullName].monitorX and G1NMData[G1NM.playerFullName].monitorY then
            G1NMMonitorParentFrame:ClearAllPoints()
            G1NMMonitorParentFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", G1NMData[G1NM.playerFullName].monitorX, G1NMData[G1NM.playerFullName].monitorY)
        else
            G1NMMonitorParentFrame:ClearAllPoints()
            G1NMMonitorParentFrame:SetPoint("CENTER")
        end

        G1NMMonitorParentFrame:CreateTexture("G1NMMonitorTexture")
        G1NMMonitorTexture:SetTexture("Interface\\Addons\\G1NM\\Textures\\G1NMMonitor.tga")
        G1NMMonitorTexture:SetAllPoints(G1NMMonitorParentFrame)

        G1NMMonitorParentFrame:CreateTexture("G1NMAoEOnTexture")
        G1NMMonitorParentFrame:CreateTexture("G1NMAoEOffTexture")
        G1NMAoEOnTexture:SetTexture("Interface\\Addons\\G1NM\\Textures\\eyes.tga")
        G1NMAoEOffTexture:SetTexture("Interface\\Addons\\G1NM\\Textures\\no.tga")

        G1NMAoEOnTexture:SetPoint("RIGHT", -10, 3)
        G1NMAoEOnTexture:SetSize(20, 20)
        G1NMAoEOffTexture:SetPoint("RIGHT", -10, 3)
        G1NMAoEOffTexture:SetSize(20, 20)

        G1NMMonitorParentFrame:CreateTexture("G1NMCDsOnTexture")
        G1NMMonitorParentFrame:CreateTexture("G1NMCDsOffTexture")
        G1NMCDsOnTexture:SetTexture("Interface\\Addons\\G1NM\\Textures\\eyes.tga")
        G1NMCDsOffTexture:SetTexture("Interface\\Addons\\G1NM\\Textures\\no.tga")

        G1NMCDsOnTexture:SetPoint("BOTTOMRIGHT", -10, 4)
        G1NMCDsOnTexture:SetSize(20, 20)
        G1NMCDsOffTexture:SetPoint("BOTTOMRIGHT", -10, 4)
        G1NMCDsOffTexture:SetSize(20, 20)

        G1NMMonitorParentFrame:SetMovable(1)
        G1NMMonitorParentFrame:EnableMouse(true)
        G1NMMonitorParentFrame:RegisterForDrag("LeftButton")
    end
    
    G1NMMonitorParentFrame:SetScript("OnMouseDown", function() if G1NMAoEOffTexture:IsMouseOver() then G1NM.toggleAoE() elseif G1NMCDsOffTexture:IsMouseOver() then G1NM.toggleCDs() end end)
    G1NMMonitorParentFrame:SetScript("OnDragStart", G1NMMonitorParentFrame.StartMoving)
    G1NMMonitorParentFrame:SetScript("OnDragStop", function(self) G1NMData[G1NM.playerFullName].monitorX, G1NMData[G1NM.playerFullName].monitorY = self:GetRect(); G1NM.saveSetting("garbageSave", true) G1NMMonitorParentFrame:StopMovingOrSizing() end)
    G1NMAoEOnTexture:Hide()
    G1NMCDsOnTexture:Hide()
    G1NM.monitorAnimationToggle("off")
end

function G1NM.monitorAnimation(self, elapsed)
    if G1NM.aoe then
        if not G1NMAoEOnTexture:IsVisible() or G1NMAoEOffTexture:IsVisible() then
            G1NMAoEOnTexture:Show()
            G1NMAoEOffTexture:Hide()
        end
        AnimateTexCoords(G1NMAoEOnTexture, 512, 256, 64, 64, 29, elapsed, 0.029)
    elseif G1NMAoEOnTexture:IsVisible() or not G1NMAoEOffTexture:IsVisible() then
        G1NMAoEOffTexture:Show()
        G1NMAoEOnTexture:Hide()
    end
    if G1NM.cds then
        if not G1NMCDsOnTexture:IsVisible() or G1NMCDsOffTexture:IsVisible() then
            G1NMCDsOnTexture:Show()
            G1NMCDsOffTexture:Hide()
        end
        AnimateTexCoords(G1NMCDsOnTexture, 512, 256, 64, 64, 29, elapsed, 0.029)
    elseif G1NMCDsOnTexture:IsVisible() or not G1NMCDsOffTexture:IsVisible() then
        G1NMCDsOnTexture:Hide()
        G1NMCDsOffTexture:Show()
    end
end

function G1NM.monitorAnimationToggle(argument)
    if not G1NMMonitorParentFrame then G1NM.createMonitorFrame() G1NM.monitorScale(G1NMData[G1NM.playerFullName].monitorScale or 1) end
    if argument == "off" then
        G1NMMonitorParentFrame:SetScript("OnUpdate", nil)
        G1NMMonitorParentFrame:Hide()
    end
    if argument == "on" then
        G1NMMonitorParentFrame:SetScript("OnUpdate", G1NM.monitorAnimation)
        G1NMMonitorParentFrame:Show()
    end
end

function G1NM.monitorScale(multiple)
    G1NMMonitorParentFrame:SetSize(64*multiple, 64*multiple)
    G1NMCDsOnTexture:SetSize(20*multiple, 20*multiple)
    G1NMCDsOffTexture:SetSize(20*multiple, 20*multiple)
    G1NMAoEOnTexture:SetSize(20*multiple, 20*multiple)
    G1NMAoEOffTexture:SetSize(20*multiple, 20*multiple)
end
print("G1NM: #2 Rotation Monitor LOADED SUCCESSFULLY")
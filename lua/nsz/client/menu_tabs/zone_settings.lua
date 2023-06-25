local downloadPanel -- Moved to this scope so it can be access in a net.receive
local parentPanel

-- nsz.gui.AddTab({
--     identifier = "zonesettings",
--     CreateContent = function(parent)
--         parentPanel = parent
--         downloadPanel = vgui.Create("DPanel", parent)
--         downloadPanel:Dock(FILL)
--         function downloadPanel:Paint(w, h)
--             draw.SimpleText("Requesting zone settings from server...", "nsz_between", w/2, h/2 - 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

--             nsz.DrawCircle(w/2, h/2 + 20, 18, 20, 360, 0, Color(100, 100, 100))
--             nsz.DrawCircle(w/2, h/2 + 20, 16, 20, 360, 0, Color(50, 50, 50))
--             nsz.DrawCircle(w/2, h/2 + 20, 16, 8, 135, (CurTime() * 300) % 360, Color(255, 255, 255))
--             nsz.DrawCircle(w/2, h/2 + 20, 14, 20, 360, 0, Color(100, 100, 100))
--         end

--         net.Start("nsz_request_zone_settings")
--         net.SendToServer()
--     end
-- })

-- nsz.settingTypes = {
--     BOOL           =  1, CHECKBOX = 1,
--     FLOAT          =  2, NUMBER   = 2,
--     INT            =  3,
--     STRING         =  4, TEXT     = 4,
--     SLIDER         =  5,
--     HEADER         =  6,
--     SUBTITLE       =  7,
--     LABEL          =  8,
--     DIVIDER        =  9,
--     COMBO          = 10,
--     COLOR          = 11,
--     VECTOR         = 12,
--     ANGLE          = 13,
--     MUTLIPLECHOICE = 14,
--     MATSELECT      = 15 -- Material List, aka browser of ingame materials
-- }

local function zoneConfigFunction(parent, zone, settings, config)
    for index, options in ipairs(config) do 
        local boundingBox = parent:Add("DPanel")
        boundingBox:Dock(TOP)
        boundingBox:DockMargin(0, 0, 0, 4)
        boundingBox:DockPadding(4, 4, 4, 4)
        function boundingBox:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 50))
        end
        local height = 4

        local titleText
        local helpText
        if isstring(options.label) then 
            titleText = options.label
        elseif options.identifier then
            titleText = nsz.language.GetPhraseIfExists("zones." .. zone.identifier .. ".settings." .. options.identifier .. ".label")         
        end
        if isstring(options.help) then 
            helpText = options.help
        elseif options.identifier then
            helpText = nsz.language.GetPhraseIfExists("zones." .. zone.identifier .. ".settings." .. options.identifier .. ".help")         
        end

        local title, text
        if isstring(titleText) then 
            title = vgui.Create("NSZLabel", boundingBox)
            title:SetFont("nsz_large")
            title:SetText(titleText)
            title:Dock(TOP)
            -- title:SizeToContents()
            -- height = height + title:GetTall() + 4
        end
        if isstring(helpText) then 
            text = vgui.Create("NSZLabel", boundingBox)
            text:SetText(helpText)
            text:Dock(TOP)
            text:DockMargin(0, 4, 0, 0)
            -- text:SizeToContents()
            -- height = height + text:GetTall() + 4
        end

        if options.typeOfSetting == nsz.settingTypes.BOOL then 
            -- local checkbox = boundingBox:Add("DCheckBox")
        end

        timer.Simple(0.01, function()
            if IsValid(title) then height = height + title:GetTall() + 4 end
            if IsValid(text)  then height = height + text:GetTall()  + 4 end
            boundingBox:SetTall(height)
        end)
    end
end

net.Receive("nsz_zone_settings", function()
    if IsValid(downloadPanel) then downloadPanel:Remove() end 
    if not net.ReadBool() then 
        local noAccess = parentPanel:Add("DPanel")
        noAccess:Dock(FILL)
        function noAccess:Paint(w, h)
            draw.SimpleText("You don't have access to zone settings.", "nsz_between", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        return
    end

    local zoneSettings = net.ReadTable()
    local zoneConfig   = net.ReadTable()

    local zonesTabMenu = parentPanel:Add("NSZTabMenu")
    zonesTabMenu:Dock(FILL)
    zonesTabMenu:UseVerticalTabs(true)
    zonesTabMenu:SetTabWidth(ScrW()/12)
    zonesTabMenu:SetColor(Color(0, 0, 0, 50))
    zonesTabMenu.scrollPanel:GetCanvas():DockPadding(4, 0, 0, 0)

    local zones = table.GetKeys(zoneConfig)
    for i, zoneIdentifier in ipairs(zones) do 
        local zone = nsz.zonetypes[zoneIdentifier]

        local tab = zonesTabMenu:AddTab(nsz.language.GetPhrase("zones." .. zoneIdentifier .. ".title"), function (parent) zoneConfigFunction(parent, zone, zoneSettings[zoneIdentifier], zoneConfig[zoneIdentifier]) end) 
        tab:SetUnselectedColor(Color(zone.color.r, zone.color.g, zone.color.b, 15))
        tab:SetSelectedColor(Color(zone.color.r, zone.color.g, zone.color.b, 60))
    end
end)
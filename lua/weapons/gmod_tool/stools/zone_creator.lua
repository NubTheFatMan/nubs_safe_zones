TOOL.Category = "Nub's Safe Zones"
TOOL.Name = "Zone Creator"
TOOL.Description = "Create different types of zones for your players."

if CLIENT then 
    TOOL.Information = {
        {name = "info"},
        {name = "left"},
        {name = "reload"}
    }
end

function TOOL:Deploy(forceDeploy)
    if CLIENT and (IsFirstTimePredicted() and not forceDeploy) then 
        if LocalPlayer() ~= self.Owner then return end

        if not istable(nsz.currentZone) then 
            nsz.currentZone = {type = "", points = {}}
        end
        if not istable(nsz.currentZone.points) then
            nsz.currentZone.points = {}
        end
        if not isstring(nsz.currentZone.identifier) then 
            nsz.currentZone.identifier = ""
        end
        language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point1"))
    end
end

function TOOL:LeftClick()
    if not istable(nsz.currentZone) then self:Deploy(true) end
    if CLIENT and LocalPlayer() == self.Owner and IsFirstTimePredicted() then 
        if not istable(nsz.zonetypes[nsz.currentZone.identifier]) then 
            return chat.AddText(nsz.language.GetPhrase("error.invalidzonetype"))
        end

        if not istable(nsz.currentZone.points) then
            nsz.currentZone.points = {}
        end

        local dist = 4294967295 -- 2^32 -1 to account for starting at 0 instead of 1
        if isvector(nsz.currentZone.points[1]) and not input.IsKeyDown(KEY_LALT) then
            dist = 100
        end

        -- I know :LeftClick() provides a trace, but I want to control the distance.
        local trace = self.Owner:GetEyeTrace()
        trace.start = self.Owner:GetShootPos()
        trace.endpos = trace.start + self.Owner:GetAimVector() * dist
        trace.filter = self.Owner
        local trace = util.TraceLine(trace)

        if isvector(trace.HitPos) then
            table.insert(nsz.currentZone.points, trace.HitPos)

            if #nsz.currentZone.points == 2 then
                chat.AddText(nsz.language.GetPhrase("tool.sending"))
                net.Start("nsz_upload")
                    net.WriteTable(nsz.currentZone)
                net.SendToServer()
                nsz.currentZone.points = {}
                language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point1"))
            else
                chat.AddText(nsz.language.GetPhrase("tool.point1set"))
                language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point2"))
            end
        else -- This should never happen, as a trace will always return the HitPos even if it didn't hit anything
            chat.AddText(nsz.language.GetPhrase("error.invalidpoint"))
        end
    end
end

function TOOL:Reload()
    if not istable(nsz.currentZone) then self:Deploy(true) end
    if CLIENT and LocalPlayer() == self.Owner and IsFirstTimePredicted() then 
        nsz.currentZone.points = {}
        chat.AddText(nsz.language.GetPhrase("tool.reset"))
        language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point1"))
    end
end

function TOOL.BuildCPanel(panel)
    panel:Clear()
    panel:Help(nsz.language.GetPhrase("tool.spawnmenu.description"))

    local comboBox = vgui.Create("DComboBox")
    for zonetype, _ in pairs(nsz.zonetypes) do 
        comboBox:AddChoice(nsz.language.GetPhrase("zones." .. zonetype .. ".title"), zonetype)
    end
    function comboBox:OnSelect(_, _, value)
        if not istable(nsz.currentZone) then TOOL:Deploy(true) end
        nsz.currentZone.identifier = value
        language.Add("tool.zone_creator.0", nsz.language.GetPhrase("tool.placing") .. nsz.language.GetPhrase("zones." .. value .. ".title"))
    end

    local refreshZones = vgui.Create("DButton")
    refreshZones:SetText(nsz.language.GetPhrase("tool.spawnmenu.refreshzones"))
    function refreshZones:DoClick()
        comboBox:Clear()
        for zonetype, _ in pairs(nsz.zonetypes) do 
            comboBox:AddChoice(nsz.language.GetPhrase("zones." .. zonetype .. ".title"), zonetype)
        end
    end

    panel:AddItem(comboBox)
    panel:AddItem(refreshZones)
end
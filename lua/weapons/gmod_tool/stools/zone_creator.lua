TOOL.Category = "Zone Management"
TOOL.Name = "Zone Creator"
TOOL.Description = "Create different types of zones for your players."

if CLIENT then 
    TOOL.Information = {
        {name = "info"},
        {name = "left"},
        {name = "reload"}
    }

    language.Add("tool.zone_creator.name", TOOL.Name)
    language.Add("tool.zone_creator.desc", TOOL.Description)
    language.Add("tool.zone_creator.0", "Placing zone: [unset]")
    language.Add("tool.zone_creator.left", "Place zone corner. Hold left alt to place where you're aiming instead of in front of you.")
    language.Add("tool.zone_creator.reload", "Cancel zone placement.")
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
        if not isstring(nsz.currentZone.type) then 
            nsz.currentZone.type = ""
        end
    end
end

function TOOL:LeftClick()
    if not istable(nsz.currentZone) then self:Deploy(true) end
    if CLIENT and LocalPlayer() == self.Owner and IsFirstTimePredicted() then 
        if not istable(nsz.zonetypes[nsz.currentZone.type]) then 
            return chat.AddText("NSZ Error: Invalid zone type selected. Please select a zone from the spawn menu.")
        end

        if not istable(nsz.currentZone.points) then
            nsz.currentZone.points = {}
        end

        local dist = 100000000
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
				chat.AddText("NSZ: Creating zone..")
				net.Start("nsz_upload")
					net.WriteTable(nsz.currentZone)
				net.SendToServer()
				nsz.currentZone.points = {}
			else
				chat.AddText("NSZ: Point 1 set, please click elsewhere for the second point!")
			end
		else -- This should never happen, as a trace will always return the HitPos even if it didn't hit anything
			chat.AddText("NSZ Error: Invalid point (unable to locate where you're aiming)!")
		end
    end
end

function TOOL:Reload()
    if not istable(nsz.currentZone) then self:Deploy(true) end
    if CLIENT and LocalPlayer() == self.Owner and IsFirstTimePredicted() then 
        nsz.currentZone.points = {}
        chat.AddText("NSZ: Reset current zone.")
    end
end

function TOOL.BuildCPanel(panel)
    -- panel:AddControl("Header", {Text = "Zone Creator", Description = "Place different zones for your players."})
    panel:Help("Place different zones for your players. Select a zone type below to place it!")

    local comboBox = vgui.Create("DComboBox")
    for zonetype, _ in pairs(nsz.zonetypes) do 
        comboBox:AddChoice(zonetype)
    end
    function comboBox:OnSelect(index, value)
        if not istable(nsz.currentZone) then TOOL:Deploy(true) end
        nsz.currentZone.type = value
        language.Add("tool.zone_creator.0", "Placing zone: " .. value)
    end

    local refreshZones = vgui.Create("DButton")
    refreshZones:SetText("Refresh Zones")
    function refreshZones:DoClick()
        comboBox:Clear()
        for zonetype, _ in pairs(nsz.zonetypes) do 
            comboBox:AddChoice(zonetype)
        end
    end

    panel:AddItem(comboBox)
    panel:AddItem(refreshZones)
end
-- Fonts
surface.CreateFont("nsz_large", {
    size = 24,
    weight = 500,
    antialias = true
})
surface.CreateFont("nsz_between", {
    size = 20,
    weight = 500,
    antialias = true
})
surface.CreateFont("nsz_normal", {
    size = 16,
    weight = 500,
    antialias = true
})

local time = 0
local scanCount = 0
local usedVector = 0
local usedAABB = 0
local usedSAT = 0
local ticks = 0
net.Receive("nsz_prop_check", function()
    if GetConVar("nsz_show_zones"):GetInt() <= 0 then return end

    time = net.ReadFloat()
    scanCount = net.ReadString()
    usedVector = net.ReadUInt(16)
    usedAABB = net.ReadUInt(16)
    usedSAT = net.ReadUInt(16)
    ticks = net.ReadUInt(8)
end)

nsz.previewAllZones = false

-- Rendering the display
local icons = {}
local font_large = "nsz_large"
local font_normal = "nsz_normal"
hook.Add("HUDPaint", "nsz_show_in_zone", function()
    -- This is text that shows on screen for the debug
    if GetConVar("nsz_show_zones"):GetInt() > 0 then
        if isnumber(time) then
            local texts = {
                nsz.language.GetPhrase("hud.debug.averagecheck"),
                nsz.language.GetPhrase("hud.debug.vectorscans"),
                nsz.language.GetPhrase("hud.debug.aabbscans"),
                nsz.language.GetPhrase("hud.debug.satscans")
            }
            
            local matchTable = {
                ["$averagetime"] = tostring(math.Round(time * 1000, 2)),
                ["$scans"]       = scanCount,
                ["$ticks"]       = ticks,
                ["$vectorscans"] = usedVector,
                ["$aabbscans"]   = usedAABB,
                ["$satscans"]    = usedSAT
            }
            for i, text in ipairs(texts) do 
                local modifiedText = string.gsub(text, "$%a+", matchTable)
                draw.SimpleText(modifiedText, font_large, 6, 6 + (i - 1) * 24, Color(0, 0, 0))
                draw.SimpleText(modifiedText, font_large, 4, 4 + (i - 1) * 24, Color(255, 255, 255))
            end
        end
    end

    if GetConVar("nsz_show_display"):GetInt() > 0 and not IsValid(nsz.gui.offsetEditor) then
        local zones = {}
        if nsz.previewAllZones and nsz.gui.IsOpen() then 
            local zoneIdentifiers = table.GetKeys(nsz.zonetypes)
            for i = 1, nsz.clientSettings.visibleZones do 
                local index = ((i - 1) % #zoneIdentifiers) + 1
                table.insert(zones, zoneIdentifiers[index])
            end
        else 
            for id, zone in pairs(nsz.zonetypes) do
                if icons[zone.identifier] == nil then icons[zone.identifier] = Material(zone.icon) end
                if not isstring(zone.identifier) then continue end
                if LocalPlayer():GetNWBool("nsz_in_zone_" .. zone.identifier) and not table.HasValue(zones, zone.identifier) then table.insert(zones, zone.identifier) end
                if #zones >= nsz.clientSettings.visibleZones then break end
            end
        end

        if #zones > 0 then
            local w = 52 -- The icon takes up 40 px. The rest is padding
            local h = 48

            local debugEnabled = GetConVar("nsz_show_zones"):GetInt() > 0

            local titles = {}
            surface.SetFont(font_large)
            for i, zone in ipairs(zones) do
                local title
                if isstring(nsz.zonetypes[zone].title) then title = nsz.zonetypes[zone].title 
                else title = nsz.language.GetPhrase("zones." .. zone .. ".title") end
                local wid = surface.GetTextSize(title)
                table.insert(titles, wid)
            end
            titles = math.max(unpack(titles))

            local idWidth = 0
            if debugEnabled then 
                -- surface.SetFont(font_large)
                local debugs = {}
                for i, zone in ipairs(zones) do
                    local text = "[" .. tostring(LocalPlayer():GetNWInt("nsz_zone_index_" .. zone)) .. "]"
                    local width = surface.GetTextSize(text)
                    table.insert(debugs, width)
                end
                idWidth = math.max(unpack(debugs)) + 4
                w = w + idWidth
                -- w = w + width
            end

            local subtitles = {}
            surface.SetFont(font_normal)
            for i, zone in ipairs(zones) do
                local subtitle
                if isstring(nsz.zonetypes[zone].subtitle) then subtitle = nsz.zonetypes[zone].subtitle 
                else subtitle = nsz.language.GetPhrase("zones." .. zone .. ".subtitle") end
                local wid = surface.GetTextSize(subtitle)
                table.insert(subtitles, wid)
            end
            subtitles = math.max(unpack(subtitles))

            local txtw = math.max(titles, subtitles)
            w = w + txtw

            local offset = nsz.clientSettings.dockOffset
            local dock = nsz.clientSettings.dockPosition - 1
            local totalHeight = (#zones * h) + ((#zones - 1) * 4)

            local x = ((ScrW() - w) * (dock % 3) / 2) + offset[1]
            local y = ((ScrH() - totalHeight) * math.floor(dock / 3) / 2) + offset[2]

            for i, zoneType in ipairs(zones) do
                local zone = nsz.zonetypes[zoneType]
                if nsz.clientSettings.background.color.a < 255 and nsz.clientSettings.background.blur then 
                    nsz.blurFunction(x, y, w, h, nsz.clientSettings.background.blurStrength)
                end
                draw.RoundedBox(0, x, y, w, h, nsz.clientSettings.background.color)

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(icons[zone.identifier])
                surface.DrawTexturedRect(x + 4, y + 4, h - 8, h - 8)

                local title
                if isstring(nsz.zonetypes[zoneType].title) then title = nsz.zonetypes[zoneType].title 
                else title = nsz.language.GetPhrase("zones." .. zoneType .. ".title") end

                local subtitle
                if isstring(nsz.zonetypes[zoneType].subtitle) then subtitle = nsz.zonetypes[zoneType].subtitle 
                else subtitle = nsz.language.GetPhrase("zones." .. zoneType .. ".subtitle") end
                if debugEnabled then 
                    -- surface.SetFont(font_large)
                    local text = "[" .. tostring(LocalPlayer():GetNWInt("nsz_zone_index_" .. zoneType)) .. "]"
                    -- local width = surface.GetTextSize(text)
                    -- draw.RoundedBox(0, x + w, y, width + 8, h, nsz.clientSettings.background.color)
                    draw.Text({
                        text = text,
                        font = font_large,
                        pos = {x + w - 4, y + 4},
                        xalign = TEXT_ALIGN_RIGHT,
                        color = zone.color
                    })
                end
                draw.Text({
                    text = title,
                    font = font_large,
                    pos = {x + w - txtw/2 - 4 - idWidth, y + 4},
                    xalign = TEXT_ALIGN_CENTER,
                    color = zone.color
                })
                draw.Text({
                    text = subtitle,
                    font = font_normal,
                    pos = {x + w - txtw/2 - 4 - idWidth, y + 30},
                    xalign = TEXT_ALIGN_CENTER,
                    color = Color(255, 255, 255)
                })
                y = y + h + 4
            end
        end
    end
end)

-- Rendering the zones
hook.Add("PostDrawOpaqueRenderables", "nsz_render_zones", function()
    if GetConVar("nsz_show_zones"):GetInt() > 0 then
        for i, zone in ipairs(nsz.zones) do
            if not istable(zone.points) then continue end
            local p1, p2 = zone.points[1], zone.points[2]
            if not (isvector(p1) or isvector(p2)) then continue end

            local center = (p1 + p2)/2
            local min = Vector(
                math.abs(p1[1] - center[1]),
                math.abs(p1[2] - center[2]),
                math.abs(p1[3] - center[3])
            )
            local max = Vector(
                math.abs(p2[1] - center[1]),
                math.abs(p2[2] - center[2]),
                math.abs(p2[3] - center[3])
            )

            local zoneData = nsz.zonetypes[zone.identifier] or nsz.NULL_ZONE
            local white = Color(255, 255, 255)
            
            -- Wireframe box
            local ang = Angle(0, 0, 0)
            render.DrawWireframeBox(center, ang, -min, max, zoneData.color)

            -- Colored box with the wireframe as a visible edge
            render.SetColorMaterial()
            render.DrawBox(center, ang, -min, max, Color(zoneData.color.r, zoneData.color.g, zoneData.color.b, 15))

            if istable(zone.corners) then
                for x, p in ipairs(zone.corners) do
                    render.DrawWireframeSphere(p, 1, 10, 10, zoneData.color)
                end
            end

            local dist = 500
            if LocalPlayer():GetPos():DistToSqr(center) > (dist * dist) then continue end

            local tr = {}
            tr.start = LocalPlayer():GetShootPos()
            tr.endpos = center
            tr.filter = LocalPlayer()
            local trace = util.TraceLine(tr)

            local angle = EyeAngles()
            if trace.HitWorld or trace.HitNonWorld then
                angle = trace.HitNormal:Angle()
                angle:RotateAroundAxis(angle:Up(), 90)
            else
                angle:RotateAroundAxis(angle:Up(), -90)
            end
            angle:RotateAroundAxis(angle:Forward(), 90)

            cam.Start3D2D(trace.HitPos, angle, 0.25)
                local text = nsz.language.GetPhrase("zones.index") .. tostring(i)
                local title = isstring(zoneData.title) and zoneData.title or nsz.language.GetPhrase("zones." .. zoneData.identifier .. ".title")
                local subtitle = isstring(zoneData.subtitle) and zoneData.subtitle or nsz.language.GetPhrase("zones." .. zoneData.identifier .. ".subtitle")

                local font = "nsz_large"
                local subfont = "nsz_normal"

                local totalWidth, totalHeight = 8, 8

                surface.SetFont(font)
                local zoneIDWidth, zoneIDHeight = surface.GetTextSize(text)
                local titleWidth, titleHeight = surface.GetTextSize(title)

                surface.SetFont(subfont)
                local subtextWidth, subtextHeight = surface.GetTextSize(subtitle)

                local zonetypeWidth, zonetypeHeight = 0, 0
                local idText
                if zoneData == nsz.NULL_ZONE then 
                    idText = "\"" .. tostring(zone.identifier or zone.type) .. "\""
                    zonetypeWidth, zonetypeHeight = surface.GetTextSize(idText)
                end

                totalWidth = totalWidth + math.max(zoneIDWidth, titleWidth, subtextWidth, zonetypeWidth)
                totalHeight = totalHeight + zoneIDHeight + titleHeight + subtextHeight + zonetypeHeight
                local x, y = -totalWidth/2, -totalHeight/2

                surface.SetDrawColor(62, 62, 62)
                surface.DrawRect(x, y, totalWidth, totalHeight)
                draw.SimpleText(text, font, 0, y + 4, white, TEXT_ALIGN_CENTER)
                draw.SimpleText(title, font, 0, y + 4 + zoneIDHeight, zoneData.color, TEXT_ALIGN_CENTER)
                draw.SimpleText(subtitle, subfont, 0, y + 4 + zoneIDHeight + titleHeight, white, TEXT_ALIGN_CENTER)
                
                if isstring(idText) then
                    draw.SimpleText(idText, subfont, 0, y + 4 + zoneIDHeight + titleHeight + subtextHeight, white, TEXT_ALIGN_CENTER)
                end
            cam.End3D2D()
        end
    end

    if not IsValid(LocalPlayer():GetActiveWeapon()) or not LocalPlayer():GetTool() then return end
    local class = LocalPlayer():GetActiveWeapon():GetClass()
    local tool = LocalPlayer():GetTool().Mode
    if class == "gmod_tool" and tool == "zone_creator" and istable(nsz.currentZone) then
        local zone = table.Copy(nsz.currentZone)
        if not istable(zone.points) then return end
        if not isvector(zone.points[1]) then return end

        local dist = 100
        if input.IsKeyDown(KEY_LALT) then dist = 100000000 end

        local tr = {}
        tr.start = LocalPlayer():GetShootPos()
        tr.endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * dist
        tr.filter = LocalPlayer()
        local trace = util.TraceLine(tr)

        if not isvector(trace.HitPos) then return end

        local center = (zone.points[1] + trace.HitPos)/2
        local min = Vector(
            math.abs(zone.points[1][1] - center[1]),
            math.abs(zone.points[1][2] - center[2]),
            math.abs(zone.points[1][3] - center[3])
        )
        local max = Vector(
            math.abs(trace.HitPos[1] - center[1]),
            math.abs(trace.HitPos[2] - center[2]),
            math.abs(trace.HitPos[3] - center[3])
        )

        local col = Color(255, 255, 255)
        local ang = Angle(0, 0, 0)
        if istable(nsz.zonetypes) and istable(nsz.zonetypes[zone.identifier]) then
            if IsColor(nsz.zonetypes[zone.identifier].color) then
                col = nsz.zonetypes[zone.identifier].color
            end
        end
        render.DrawWireframeBox(center, ang, -min, max, col)

        render.SetColorMaterial()
        render.DrawBox(center, ang, -min, max, Color(col.r, col.g, col.b, 15))
    end
end)

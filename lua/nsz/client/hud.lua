-- Fonts
surface.CreateFont("nsz_large", {
    size = 24,
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
net.Receive("nsz_prop_check", function()
    time = net.ReadFloat()
    scanCount = net.ReadString()
end)

-- Rendering the display
local icons = {}
local font_large = "nsz_large"
local font_normal = "nsz_normal"
hook.Add("HUDPaint", "nsz_show_in_zone", function()
    -- This is text that shows on screen for the debug
    if GetConVar("nsz_show_zones"):GetInt() > 0 then
        if isnumber(time) then
            local text = "NSZ: Average check duration: " .. tostring(math.Round(time * 1000, 2)) .. " ms (" .. scanCount .. " possible scans)"
            draw.Text({ -- This is a backdrop, creates a shade to the text
                text = text,
                pos = {6, 6},
                font = font_large,
                color = Color(0, 0, 0)
            })
            draw.Text({
                text = text,
                pos = {4, 4},
                font = font_large,
                color = Color(255, 255, 255)
            })
        end
    end

    if GetConVar("nsz_show_display"):GetInt() > 0 then
        local zones = {}
        for id, zone in pairs(nsz.zonetypes) do
            if icons[zone.type] == nil then icons[zone.type] = Material(zone.icon) end
            if not isstring(zone.type) then continue end
            if LocalPlayer():GetNWBool("nsz_in_zone_" .. zone.type) and not table.HasValue(zones, zone.type) then table.insert(zones, zone.type) end
        end

        if #zones > 0 then
            local w = 52 -- The icon takes up 40 px. The rest is padding
            local h = 48

            local titles = {}
            surface.SetFont(font_large)
            for i, zone in ipairs(zones) do
                if not isstring(nsz.zonetypes[zone].title) then continue end
                local wid = surface.GetTextSize(nsz.zonetypes[zone].title)
                table.insert(titles, wid)
            end
            titles = math.max(unpack(titles))

            local subtitles = {}
            surface.SetFont(font_normal)
            for i, zone in ipairs(zones) do
                if not isstring(nsz.zonetypes[zone].subtitle) then continue end
                local wid = surface.GetTextSize(nsz.zonetypes[zone].subtitle)
                table.insert(subtitles, wid)
            end
            subtitles = math.max(unpack(subtitles))

            local txtw = math.max(titles, subtitles)
            w = w + txtw

            local x = ScrW()/2 - w/2
            local y = 4

            for i, zone in ipairs(zones) do
                draw.RoundedBox(0, x, y, w, h, Color(100, 100, 100))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(icons[nsz.zonetypes[zone].type])
                surface.DrawTexturedRect(x + 4, y + 4, h - 8, h - 8)

                draw.Text({
                    text = nsz.zonetypes[zone].title,
                    font = font_large,
                    pos = {x + w - txtw/2 - 4, y + 4},
                    xalign = TEXT_ALIGN_CENTER,
                    color = nsz.zonetypes[zone].color
                })
                draw.Text({
                    text = nsz.zonetypes[zone].subtitle,
                    font = font_normal,
                    pos = {x + w - txtw/2 - 4, y + 30},
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

            local col = Color(255, 255, 255)
            if istable(nsz.zonetypes[zone.type]) then
                local z = table.Copy(nsz.zonetypes[zone.type])
                if IsColor(z.color) then
                    col = z.color
                end
            end
            -- Wireframe box
            local ang = Angle(0, 0, 0)
            render.DrawWireframeBox(center, ang, -min, max, col)

            -- Colored box with the wireframe as a visible edge
            render.SetColorMaterial()
            render.DrawBox(center, ang, -min, max, Color(col.r, col.g, col.b, 15))

            if istable(zone.corners) then
                for x, p in ipairs(zone.corners) do
                    render.DrawWireframeSphere(p, 1, 10, 10, col)
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
                local text = "Zone " .. tostring(i)
                local font = "nsz_large"

                surface.SetFont(font)
                local tW, tH = surface.GetTextSize(text)

                local pad = 5

                surface.SetDrawColor(100, 100, 100, 255)
                surface.DrawRect(-tW / 2 - pad, -pad, tW + pad * 2, tH + pad * 2)

                draw.SimpleText(text, font, -tW / 2, 0, col)
            cam.End3D2D()
        end
    end

    if not IsValid(LocalPlayer():GetActiveWeapon()) then return end
    local class = LocalPlayer():GetActiveWeapon():GetClass()
    if class == "zone_creator" and istable(nsz.currentZone) then
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
        if istable(nsz.zonetypes) and istable(nsz.zonetypes[zone.type]) then
            if IsColor(nsz.zonetypes[zone.type].color) then
                col = nsz.zonetypes[zone.type].color
            end
        end
        render.DrawWireframeBox(center, ang, -min, max, col)

        render.SetColorMaterial()
        render.DrawBox(center, ang, -min, max, Color(col.r, col.g, col.b, 15))
    end
end)

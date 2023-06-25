-- This file is responsible for the initialization of the spawn zone

-- The following table houses this mod. It's recommended you don't touch this
-- if you don't know what you're doing.
nsz = nsz or {}
nsz.currentZone = nsz.currentZone or {}
nsz.zonetypes   = nsz.zonetypes   or {}
nsz.zones       = nsz.zones       or {}

nsz.clientSettings = nsz.clientSettings or {}
nsz.defaultClientSettings = nsz.defaultClientSettings or {
    visibleZones = 3,
    dockPosition = 4,
    dockOffset = {4, 0},
    background = {
        color = Color(0, 0, 0, 150),
        blur = true,
        blurStrength = 2
    },
    language = "English",
    secrethehe = false
}

local saveFile = "nubs_safe_zones_config.txt"
function nsz.SaveClientSettings()
    file.Write(saveFile, util.TableToJSON(nsz.clientSettings))
end

if file.Exists(saveFile, "DATA") then 
    nsz.clientSettings = util.JSONToTable(file.Read(saveFile, "DATA"))
else 
    nsz.clientSettings = table.Copy(nsz.defaultClientSettings)
    nsz.SaveClientSettings()
end

function nsz.ShiftColor(color, shift)
    return Color(color.r + shift, color.g + shift, color.b + shift, color.a)
end

function nsz.ApplyLanguageToTool()
    language.Add("tool.zone_creator.name", nsz.language.GetPhrase("tool.name"))
    language.Add("tool.zone_creator.desc", nsz.language.GetPhrase("tool.description"))
    -- language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick"))
    language.Add("tool.zone_creator.reload", nsz.language.GetPhrase("tool.reload"))
    
    if istable(nsz.currentZone) and isstring(nsz.currentZone.identifier) and istable(nsz.zonetypes[nsz.currentZone.identifier]) then 
        language.Add("tool.zone_creator.0", nsz.language.GetPhrase("tool.placing") .. nsz.language.GetPhrase("zones." .. nsz.currentZone.identifier .. ".title"))
        if #nsz.currentZone.points == 1 then 
            language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point2"))
        else
            language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point1"))
        end
    else 
        language.Add("tool.zone_creator.left", nsz.language.GetPhrase("tool.leftclick.point1"))
        language.Add("tool.zone_creator.0", nsz.language.GetPhrase("tool.placing") .. nsz.language.GetPhrase("tool.select"))
    end
end

-- Function copied from gmod wiki `surface.DrawPoly` and then modified to support wedges
function nsz.DrawCircle(x, y, radius, seg, arc, angOffset, col)
    local cir = {}

    draw.NoTexture()
    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360) * (arc/360) - math.rad(angOffset)
        table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
    end
    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

    surface.SetDrawColor(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
    surface.DrawPoly(cir)
end

-- Loading this mod
include("nsz/client/concmds.lua")
include("nsz/client/hud.lua")
include("nsz/client/language.lua")

include("nsz/client/menu.lua")
include("nsz/client/menu_tabs/client_settings.lua")
include("nsz/client/menu_tabs/zone_settings.lua")

include("nsz/client/vgui/button.lua")
include("nsz/client/vgui/combobox.lua")
include("nsz/client/vgui/label.lua")
include("nsz/client/vgui/tab_menu.lua")

include("nsz/shared/registration.lua")
include("nsz/shared/default_zones.lua")

nsz.ApplyLanguageToTool()
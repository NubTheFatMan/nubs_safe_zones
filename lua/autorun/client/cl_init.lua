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
    language = "English"
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

-- Loading this mod
include("nsz/client/concmds.lua")
include("nsz/client/hud.lua")
include("nsz/client/language.lua")

include("nsz/client/menu.lua")
include("nsz/client/menu_tabs/client_settings.lua")
include("nsz/client/menu_tabs/zone_settings.lua")

include("nsz/client/vgui/button.lua")
include("nsz/client/vgui/tab_menu.lua")

include("nsz/shared/registration.lua")
include("nsz/shared/default_zones.lua")
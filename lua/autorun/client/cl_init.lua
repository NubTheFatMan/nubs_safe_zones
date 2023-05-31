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
    }
}

-- Used in the event that a previously registered zone is no longer registered
nsz.NULL_ZONE = {
    title = "Invalid Zone",
    subtitle = "This zone is no longer available (removed?)",
    type = NULL,
    icon = "https://i.redd.it/jft9hnt9a6p81.png",
    color = Color(255, 255, 255),
    vars = {}
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

-- Used for animating, mainly in menu tabs
-- Function is from https://easings.net/, modified by combining easeInOutCubic down to easeInOutCirc
function nsz.EaseInOut(value, exponent)
    if value < 0.5 then 
        return (2 ^ (exponent - 1)) * (value ^ exponent)
    else 
        return 1 - ((-2 * value + 2) ^ exponent) / 2
    end
end

function nsz.ShiftColor(color, shift)
    return Color(color.r + shift, color.g + shift, color.b + shift, color.a)
end

-- Loading this mod
include("nsz/client/concmds.lua")
include("nsz/client/hud.lua")

include("nsz/client/menu.lua")
include("nsz/client/menu_tabs/client_settings.lua")
include("nsz/client/menu_tabs/server_settings.lua")

include("nsz/client/vgui/button.lua")
include("nsz/client/vgui/tab_menu.lua")

-- include("nsz/zones/safe.lua")
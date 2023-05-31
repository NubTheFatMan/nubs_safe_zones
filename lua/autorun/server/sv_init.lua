-- This file is responsible for the initialization of the spawn zone

-- The following table houses this mod. It's recommended you don't touch this
-- if you don't know what you're doing.
nsz           = nsz           or {}
nsz.zones     = nsz.zones     or {}
nsz.zonetypes = nsz.zonetypes or {}

-- Loading this mod
include("nsz/server/concmds.lua")
include("nsz/server/data.lua")
include("nsz/server/detection.lua")
include("nsz/server/registration.lua")

include("nsz/server/default_zones.lua")

-- Make the client download the client files
AddCSLuaFile("nsz/client/concmds.lua")
AddCSLuaFile("nsz/client/hud.lua")

AddCSLuaFile("nsz/client/menu.lua")
AddCSLuaFile("nsz/client/menu_tabs/client_settings.lua")
AddCSLuaFile("nsz/client/menu_tabs/server_settings.lua")

AddCSLuaFile("nsz/client/vgui/button.lua")
AddCSLuaFile("nsz/client/vgui/tab_menu.lua")

-- Register the materials for the client to use on the hud
resource.AddFile("materials/nsz/nsz.png")
resource.AddFile("materials/nsz/no_build_zone.png")

-- Send sounds to client
resource.AddFile("sound/nsz/clickdown.ogg")
resource.AddFile("sound/nsz/clickup.ogg")

MsgN("Nub's Safe Zone's fully loaded!")
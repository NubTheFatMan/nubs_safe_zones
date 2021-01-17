-- This file is responsible for the initialization of the spawn zone

-- The following table houses this mod. It's recommended you don't touch this
-- if you don't know what you're doing.
nsz = nsz or {}
nsz.currentZone = nsz.currentZone or {}
nsz.zonetypes   = nsz.zonetypes   or {}
nsz.zones       = nsz.zones       or {}

-- Loading this mod
include("nsz/client/concmds.lua")
include("nsz/client/hud.lua")

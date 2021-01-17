-- This file is responsible for the initialization of the spawn zone

-- The following table houses this mod. It's recommended you don't touch this
-- if you don't know what you're doing.
nsz           = nsz           or {}
nsz.zones     = nsz.zones     or {}
nsz.zonetypes = nsz.zonetypes or {}

-- This is used in the version checker (see EOF)
nsz.version = nsz.version or "1-20.4.17"

-- Loading this mod
include("nsz/server/concmds.lua")
include("nsz/server/data.lua")
include("nsz/server/detection.lua")
include("nsz/server/protection.lua")
include("nsz/server/registration.lua")

-- Make the client download the client files
AddCSLuaFile("nsz/client/concmds.lua")
AddCSLuaFile("nsz/client/hud.lua")

-- Register the materials for the client to use on the hud
resource.AddFile("materials/nsz/nsz.png")
resource.AddFile("materials/nsz/no_build_zone.png")

MsgN("Nub's Safe Zone's fully loaded! Version: " .. nsz.version)

-- Checking for updates
hook.Add("Initialize", "nsz_check_for_update", function()
    MsgN("Retrieving latest version of Nub's Safe Zone...")
    http.Fetch("http://nubstoys.xyz/gmod/mods/nubs_safe_zone/version.txt",
    function(body, size, headers, code) -- Successful retrieval
        body = string.Trim(body) -- Sometimes the body will have an extra empty space
        if nsz.version ~= body then
            nsz.needs_update = true -- This bool is used when a player first spawns, see EOF nsz/server/data.lua
            MsgN("Nub's Safe Zones needs an update!")
            MsgN("Running " .. nsz.version)
            MsgN("Latest: " .. body)
        else
            MsgN("Nub's Safe Zones is up to date!")
        end
    end,
    function(err) -- Invalid retrieval
        MsgN("Unable to retrieve Nub's Safe Zone's version.")
    end
    )
end)

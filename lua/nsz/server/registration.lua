-- This file is responsible for custom zone types

-- Default variables for a zone
nsz.defaultVars = {
    build = false,
    nodamage = false
}

-- This function registers a zone
-- nsz:RegisterZone(title, subtitle, type, icon, color, variables)
--     * string title: The title of the zone (to display on the HUD)
--     * string subtitle: The subtitle of the zone (to display on the HUD)
--     * string type: The zone ID, used for permissions and whatnot
--     string icon="materials/nsz/nsz.png": The icon to show on the HUD
--     Color color=Color(255, 255, 255): The color of the zone (for debug rendering)
--     table variables=nsz.defaultVars: The default variables of the zone, but can be managed by their admin mod
--
--     This will register a zone for the server
function nsz:RegisterZone(title, subtitle, typ, icon, color, vars)
    if not isstring(title) then error("nsz:RegisterZone: Bad argument #1: String expected for title, got " .. type(title)) return end
    if not isstring(subtitle) then error("nsz:RegisterZone: Bad argument #2: String expected for subtitle, got " .. type(subtitle)) return end
    if not isstring(typ) then error("nsz:RegisterZone: Bad argument #3: String expected for zone type, got " .. type(typ)) return end

    if not isstring(icon) and CLIENT then icon = "materials/nsz/nsz.png" end
    if not IsColor(color) then color = Color(255, 255, 255) end

    if not istable(vars) then vars = table.Copy(nsz.defaultVars) end

    local v = table.Merge(table.Copy(nsz.defaultVars), vars)

    nsz.zonetypes[typ] = {
        title = title,
        subtitle = subtitle,
        type = typ,
        icon = icon,
        color = color,
        vars = v
    }

    MsgN("NSZ: Zone type registered: " .. typ)

    -- ULX support
    if ULib ~= nil then
        for var, val in pairs(v) do
            if not isbool(val) then return end
            ULib.ucl.registerAccess("nsz_" .. typ .. " " .. var, val and {"user"} or {}, "", "Nub's Safe Zones")
        end
    end

    nsz:SendZones()
end

-- Default zones
nsz:RegisterZone("Safe Zone", "You are protected from all harm", "safe", "materials/nsz/nsz.png", Color(62, 255, 62), {nodamage = true, build = true})
nsz:RegisterZone("Spawn Zone", "No building or killing here", "spawn", "materials/nsz/nsz.png", Color(255, 255, 62), {nodamage = true})
nsz:RegisterZone("No Build Zone", "You cannot build here", "nobuild", "materials/nsz/no_build_zone.png", Color(255, 62, 62), {})

-- Allow the weapon to be used (ULX support)
if ULib ~= nil then
    ULib.ucl.registerAccess("nsz_create_zones", {"superadmin"}, "Users with this permission can create zones.", "Nub's Safe Zones")
end

local function canSpawn(ply)
    if ULib ~= nil then
        local can = ULib.ucl.query(ply, "nsz_create_zones")
        if can == nil then return false end
        return can
    end
    return ply:IsSuperAdmin() -- Default behavior is to only let super admins to use the weapon
end

-- Don't let them spawn the gun if they don't have the perms to it. If they
-- glitch it in via the duplicator, the server still won't let them manage zones
-- so you don't have to worry about that.
hook.Add("PlayerSpawnSWEP", "nsz_block_giving_tool", function(ply, wep)
    if wep == "zone_creator" then
        if not canSpawn(ply) then return false end
    end
end)
hook.Add("PlayerGiveSWEP", "nsz_block_giving_tool", function(ply, wep)
    if wep == "zone_creator" then
        if not canSpawn(ply) then return false end
    end
end)

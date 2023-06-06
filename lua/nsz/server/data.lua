-- Networking string for saving a new zone
util.AddNetworkString("nsz_upload") -- Used when a player uploads coords to be a safezone
util.AddNetworkString("nsz_download") -- Sends zones to the player so they can view the safezones with `nsz_toggle_zones`

-- Create the data files
if not file.Exists("nubs_safe_zone", "DATA") then
    file.CreateDir("nubs_safe_zone")
    file.CreateDir("nubs_safe_zone/zones")

    -- To any other modders looking through here, I already generated a zone
    -- layout for a popular darkrp map, downtown v4c v2. That's what this
    -- mess is
    file.Write("nubs_safe_zone/zones/rp_downtown_v4c_v2.txt", '[{"points":["[1340.9375 -364.0313 -195.9688]","[-318.9375 -2090.9688 175.9688]"],"corners":["[-318.9375 -2090.9688 175.9688]","[1340.9375 -2090.9688 175.9688]","[-318.9375 -364.0313 175.9688]","[1340.9375 -364.0313 175.9688]","[-318.9375 -2090.9688 -195.9688]","[1340.9375 -2090.9688 -195.9688]","[-318.9375 -364.0313 -195.9688]","[1340.9375 -364.0313 -195.9688]"],"type":"spawn"},{"points":["[-118.9375 -2090.9688 -203.9688]","[1341 -694.0313 -195.9688]"],"corners":["[1341 -694.0313 -195.9688]","[-118.9375 -694.0313 -195.9688]","[1341 -2090.9688 -195.9688]","[-118.9375 -2090.9688 -195.9688]","[1341 -694.0313 -203.9688]","[-118.9375 -694.0313 -203.9688]","[1341 -2090.9688 -203.9688]","[-118.9375 -2090.9688 -203.9688]"],"type":"spawn"},{"points":["[-163.9688 -2090.9375 -195.9375]","[-672.875 -2975.9063 -17.0313]"],"corners":["[-672.875 -2975.9063 -17.0313]","[-163.9688 -2975.9063 -17.0313]","[-672.875 -2090.9375 -17.0313]","[-163.9688 -2090.9375 -17.0313]","[-672.875 -2975.9063 -195.9375]","[-163.9688 -2975.9063 -195.9375]","[-672.875 -2090.9375 -195.9375]","[-163.9688 -2090.9375 -195.9375]"],"type":"spawn"},{"points":["[-318.9688 -1999.9688 -195.9375]","[-703.125 -2431.9688 -13.3438]"],"corners":["[-703.125 -2431.9688 -13.3438]","[-318.9688 -2431.9688 -13.3438]","[-703.125 -1999.9688 -13.3438]","[-318.9688 -1999.9688 -13.3438]","[-703.125 -2431.9688 -195.9375]","[-318.9688 -2431.9688 -195.9375]","[-703.125 -1999.9688 -195.9375]","[-318.9688 -1999.9688 -195.9375]"],"type":"spawn"},{"points":["[697.0625 -11.0625 -74.4688]","[1238.4063 -364.0313 -195.9688]"],"corners":["[1238.4063 -364.0313 -195.9688]","[697.0625 -364.0313 -195.9688]","[1238.4063 -11.0625 -195.9688]","[697.0625 -11.0625 -195.9688]","[1238.4063 -364.0313 -74.4688]","[697.0625 -364.0313 -74.4688]","[1238.4063 -11.0625 -74.4688]","[697.0625 -11.0625 -74.4688]"],"type":"spawn"},{"points":["[1341 -694.0313 -203.9375]","[2249.3125 -1058.9688 84.5625]"],"corners":["[2249.3125 -1058.9688 84.5625]","[1341 -1058.9688 84.5625]","[2249.3125 -694.0313 84.5625]","[1341 -694.0313 84.5625]","[2249.3125 -1058.9688 -203.9375]","[1341 -1058.9688 -203.9375]","[2249.3125 -694.0313 -203.9375]","[1341 -694.0313 -203.9375]"],"type":"nobuild"},{"points":["[256.875 -2091 -203.9688]","[-118.5313 -4619.3438 151.75]"],"corners":["[-118.5313 -4619.3438 151.75]","[256.875 -4619.3438 151.75]","[-118.5313 -2091 151.75]","[256.875 -2091 151.75]","[-118.5313 -4619.3438 -203.9688]","[256.875 -4619.3438 -203.9688]","[-118.5313 -2091 -203.9688]","[256.875 -2091 -203.9688]"],"type":"nobuild"},{"points":["[-703.1563 -2305.0313 -195.5625]","[-1122.7188 -2431.9688 191.4688]"],"corners":["[-1122.7188 -2431.9688 191.4688]","[-703.1563 -2431.9688 191.4688]","[-1122.7188 -2305.0313 191.4688]","[-703.1563 -2305.0313 191.4688]","[-1122.7188 -2431.9688 -195.5625]","[-703.1563 -2431.9688 -195.5625]","[-1122.7188 -2305.0313 -195.5625]","[-703.1563 -2305.0313 -195.5625]"],"type":"nobuild"}]')
end

-- As the name implies, it saves all the zones on the map
function nsz:SaveZones()
    if not istable(nsz.zones) then return end

    file.Write("nubs_safe_zone/zones/" .. game.GetMap() .. ".txt", util.TableToJSON(nsz.zones))
end

-- This sends all the zones to everybody, or the player specified in the first argument
-- nsz:SendZones(Player ply)
--     Player ply - the player to send the zones to. Leave blank to send to all.
function nsz:SendZones(ply)
    net.Start("nsz_download")
        net.WriteTable(nsz.zones or {})
        net.WriteTable(nsz.zonetypes or {})
        net.WriteTable(nsz.zoneSettings or {})
    if IsValid(ply) and ply.IsPlayer and ply:IsPlayer() then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

-- Auto refresh zones to the client every minute
-- timer.Create("nsz_refresh", 60, 0, function()
--     nsz:SendZones()
-- end)
hook.Add("PlayerInitialSpawn", "nsz_send_zones", function(ply)
    nsz:SendZones(ply)
end)

-- Loading data
local zones = file.Read("nubs_safe_zone/zones/" .. game.GetMap() .. ".txt")
if zones then
    nsz.zones = util.JSONToTable(zones) or {}

    -- legacy identifier key was `type`. This brings it up to speed
    local renamed = false
    for i, zone in ipairs(nsz.zones) do 
        if not isstring(zone.identifier) and isstring(zone.type) then 
            zone.identifier = zone.type
            renamed = true
        end
    end
    if renamed then nsz:SaveZones() end
else
    nsz.zones = nsz.zones or {}
end

-- Zone settings
local settings = file.Read("nubs_safe_zone/zonesettings.txt")
if settings then 
    nsz.zoneSettings = util.JSONToTable(settings) or {}
else
    nsz.zoneSettings = {}
end
function nsz.SaveZoneSettings()
    file.Write("nubs_safe_zone/zonesettings.txt", util.TableToJSON(nsz.zoneSettings))
end

-- Allow the weapon to be used (ULX support)
if ULib ~= nil then
    ULib.ucl.registerAccess("Create Zones", "superadmin", "Users with this permission can create and delete zones.", "Nub's Safe Zones")
    ULib.ucl.registerAccess("Manage Zone Settings", "superadmin", "These users can change settings in the Zone Settings tab.", "Nub's Safe Zones")
end

-- Player creating a zone
net.Receive("nsz_upload", function(len, ply)
    local zone = net.ReadTable()

    -- First check if they have permission
    local can = ply:IsSuperAdmin() -- Default behavior is to let superadmins manage zones
    if ULib ~= nil then
        can = ULib.ucl.query(ply, "Create Zones")
    end

    if not can then
        ply:ChatPrint("NSZ Error: You don't have permission to create zones.")
        return
    end

    if not isstring(zone.identifier) then -- They didn't send a string for the zone type
        ply:ChatPrint("NSZ Error: You need a type of zone.")
        return
    end

    if not istable(zone.points) then -- They didn't send valid corners for the zone
        ply:ChatPrint("NSZ Error: You need two positions for a zone.")
        return
    end

    -- The corners of the zone aren't Vectors
    if not isvector(zone.points[1]) or not isvector(zone.points[2]) then
        ply:ChatPrint("NSZ Error: You need two positions for a zone.")
        return
    end


    -- Corners are used for detection, points are used for rendering
    zone.corners = {}
    local c = (zone.points[1] + zone.points[2]) / 2
    local s = (zone.points[2] - zone.points[1]) / 2

    table.insert(zone.corners, Vector(c[1] + s[1], c[2] + s[2], c[3] + s[3]))
    table.insert(zone.corners, Vector(c[1] - s[1], c[2] + s[2], c[3] + s[3]))
    table.insert(zone.corners, Vector(c[1] + s[1], c[2] - s[2], c[3] + s[3]))
    table.insert(zone.corners, Vector(c[1] - s[1], c[2] - s[2], c[3] + s[3]))
    table.insert(zone.corners, Vector(c[1] + s[1], c[2] + s[2], c[3] - s[3]))
    table.insert(zone.corners, Vector(c[1] - s[1], c[2] + s[2], c[3] - s[3]))
    table.insert(zone.corners, Vector(c[1] + s[1], c[2] - s[2], c[3] - s[3]))
    table.insert(zone.corners, Vector(c[1] - s[1], c[2] - s[2], c[3] - s[3]))

    table.insert(nsz.zones, zone)
    ply:ChatPrint("NSZ: Success!")
    nsz:SendZones()
    nsz:SaveZones()
end)
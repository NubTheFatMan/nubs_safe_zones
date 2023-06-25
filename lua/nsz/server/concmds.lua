-- This network string is used for the clientside delete safe zone
util.AddNetworkString("nsz_delete")

net.Receive("nsz_delete", function(len, ply)
    if not IsValid(ply) then 
        return MsgN("You must be on the server to run this command.")
    end

    local str = net.ReadString()
    if ULib ~= nil then
        if not ULib.ucl.query(ply, "Create Zones") then ply:ChatPrint("NSZ Error: You don't have permission to delete a zone.") return end
    else
        if not ply:IsSuperAdmin() then ply:ChatPrint("NSZ Error: You must be a superadmin to delete a zone.") return end
    end

    if #nsz.zones == 0 then ply:ChatPrint("NSZ Error: There are no zones to delete on this map.") return end

    local args = string.Explode(" +", str, true)
    if #args == 0 then
        ply:ChatPrint("NSZ: Error You need at least one argument.")
        return
    end

    args[1] = string.lower(args[1])
    if args[1] == "all" then
        local deleted = #nsz.zones
        nsz.zones = {}
        nsz:SendZones()
        nsz:SaveZones()

        ply:ChatPrint("NSZ: Removed " .. deleted .. " zones.")
    else
        local zone = tonumber(args[1])
        if isnumber(zone) then
            if not istable(nsz.zones[zone]) then ply:ChatPrint("NSZ Error: This zone doesn't exist.") return end

            table.remove(nsz.zones, zone)
            nsz:SaveZones()
            nsz:SendZones()

            ply:ChatPrint("NSZ: Removed zone " .. tostring(zone) .. ".")
        else
            local typ = args[1]

            local deleted = 0
            for i = #nsz.zones, 1, -1 do
                if nsz.zones[i].identifier == typ then
                    deleted = deleted + 1
                    table.remove(nsz.zones, i)
                end
            end
            nsz:SaveZones()
            nsz:SendZones()

            ply:ChatPrint("NSZ: Removed " .. deleted .. " " .. typ .. " zones.")
        end
    end

    if #nsz.zones == 0 then 
        for player, zones in pairs(nsz.truePlayerCache) do 
            for zoneIdentifier, _ in pairs(zones) do 
                player:SetNWBool("nsz_in_zone_" .. zoneIdentifier, false)
                hook.Run("NSZExit", zoneIdentifier, player, false)
            end
        end
        nsz.playerCache = {}
        nsz.truePlayerCache = {}

        for entityIndex, zones in pairs(nsz.trueEntityCache) do 
            local entity = ents.GetByIndex(entityIndex)
            if IsValid(entity) then 
                for zoneIdentifier, _ in pairs(zones) do 
                    hook.Run("NSZExit", zoneIdentifier, entity, false)
                end
            end
        end
        nsz.entityCache = {}
        nsz.trueEntityCache = {}
    end
end)

-- Convar for prop checking
if not ConVarExists("nsz_prop_checks_per_tick") then
    CreateConVar("nsz_prop_checks_per_tick", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How many props to check per server tick. Higher number = more lag, but quicker detection.", 1)
end

-- Convar for sensitivity
if not ConVarExists("nsz_aabb_v_sat_sensitivity") then
    CreateConVar("nsz_aabb_v_sat_sensitivity", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The angle of which determines weather or not to use AABB vs SAT detection. 0 = always use SAT (slow, but accurate), 90 = always use AABB (fast, but has false positives)", 0, 90)
end

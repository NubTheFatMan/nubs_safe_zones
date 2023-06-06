-- This file is responsible for checking if players are in a safe zone
-- and running the NSZEnter and NSZLeave hooks

-- Following functions were copied from wiremod's expression 2 functions
local function cross(v1, v2)
    return Vector(
		v1[2] * v2[3] - v1[3] * v2[2],
		v1[3] * v2[1] - v1[1] * v2[3],
		v1[1] * v2[2] - v1[2] * v2[1]
	)
end
local function dot(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end

-- Debugging
local times = {}
local checked = 0
local scans = 0
local usedVector = 0
local usedAABB = 0
local usedSAT = 0
util.AddNetworkString("nsz_prop_check") -- Used in the client cvar "nsz_show_zones", debug of the time it took to scan entities

timer.Create("nsz_check_times", 0.5, 0, function()
    -- Find the average time it took to scan
    local av = 0
    for i, t in ipairs(times) do
        av = av + t
    end
    av = av / #times

    -- Send the average to the client as well as how many scans it did
    net.Start("nsz_prop_check", true)
        net.WriteFloat(av)
        net.WriteString(tostring(checked) .. "/" .. tostring(scans))
        net.WriteUInt(usedVector, 16)
        net.WriteUInt(usedAABB, 16)
        net.WriteUInt(usedSAT, 16)
    net.Broadcast()

    -- Reset the times and scans count
    times = {}
    checked = 0
    scans = 0
    usedVector = 0
    usedAABB = 0
    usedSAT = 0
end)

-- This function returns what zones something is located in
-- nsz:InZone(ent, filter)
--     * Vector/Entity/Player ent: What to check
--         Vector: checks if this point is located in a zone
--         Entity/Player: Checks if the entity is in the zone by factoring its hitbox
--
--     string/table filter: Zones to include in the scan
--         string: Only checks if ent is in this zone
--         table: Checks if ent is in any of these zones
--
--     Returns: A table of zones that it is in.
function nsz:InZone(ent, filter)
    if not (isentity(ent) or isvector(ent)) then return end

    if not istable(nsz.zones) then return false end -- Somehow the zones table was removed or never registered
    if #nsz.zones == 0 then return false end -- No zones exist, so it can't be in a zone

    local zones = {}
    local indexes = {}

    for i, zone in ipairs(nsz.zones) do
        -- No need to check this zone if it's already in a zone of this type
        if table.HasValue(zones, zone.identifier) then continue end

        if not istable(zone.points) then continue end -- Somehow the two defining corners don't exist
        if not (isvector(zone.points[1]) or isvector(zone.points[2])) then continue end -- Invalid points
        local p1, p2 = zone.points[1], zone.points[2]

        if isstring(filter) then
            if zone.identifier ~= filter then continue end
        elseif istable(filer) and table.IsSequential(filter) then
            if not table.HasValue(filter, zone.identifier) then continue end
        end

        if isvector(ent) then
            checked = checked + 1
            usedVector = usedVector + 1
            if ent:WithinAABox(p1, p2) then
                if not table.HasValue(zones, zone.identifier) then 
                    table.insert(zones, zone.identifier) 
                    table.insert(indexes, i) 
                end
            end
            continue
        end

        if isentity(ent) then
            checked = checked + 1
            usedVector = usedVector + 1
            if ent:GetPos():WithinAABox(p1, p2) or ent:LocalToWorld(ent:OBBCenter()):WithinAABox(p1, p2) then
                if not table.HasValue(zones, zone.identifier) then 
                    table.insert(zones, zone.identifier) 
                    table.insert(indexes, i) 
                end
                continue
            end

            local zoneCenter = (p1 + p2) / 2
            local sqrDist = zoneCenter:DistToSqr(ent:LocalToWorld(ent:OBBCenter()))
            local maxDist = (p2 - zoneCenter + (ent:OBBMaxs() - ent:OBBCenter())):LengthSqr()
            if sqrDist > maxDist then continue end

            -- All detection code beyond this point was made with the help of a friend

            local threshold = GetConVar("nsz_aabb_v_sat_sensitivity"):GetInt()
            local ang = ent:GetAngles()
            local useAABB = true
            for i = 1, 3 do
                if(math.abs(((ang[i] + 45) % 90) - 45) > threshold) then
                    useAABB = false
                    break
                end
            end

            if useAABB then -- AABB detection
                usedAABB = usedAABB + 1
                local min, max = ent:WorldSpaceAABB()
                local inzone = {}

                for i = 1, 3 do
                    inzone[i] =                       (min[i] < p1[i] and max[i] > p2[i])     -- Enveloping the zone
                    if not inzone[i] then inzone[i] = (min[i] < p2[i] and max[i] > p2[i]) end -- Touching the zone
                    if not inzone[i] then inzone[i] = (min[i] > p1[i] and max[i] < p2[i]) end -- Enveloped in the zone
                    if not inzone[i] then inzone[i] = (min[i] < p1[i] and max[i] > p1[i]) end -- Touching the zone
                end

                if inzone[1] and inzone[2] and inzone[3] then
                    if not table.HasValue(zones, zone.identifier) then 
                        table.insert(zones, zone.identifier) 
                        table.insert(indexes, i) 
                    end
                    continue
                end
            else -- SAT (Separating Axis Theorem) detection
                usedSAT = usedSAT + 1
                if not istable(ent.nsz_scan) then
                    ent.nsz_scan = {corners = {}}

                    local c = ent:OBBCenter() -- Center of the end
                    local s = (ent:OBBMaxs() - ent:OBBMins()) / 2 -- Size of the ent
                    ent.nsz_scan.corners[1] = ent:LocalToWorld(Vector(c[1] + s[1], c[2] + s[2], c[3] + s[3]))
                    ent.nsz_scan.corners[2] = ent:LocalToWorld(Vector(c[1] - s[1], c[2] + s[2], c[3] + s[3]))
                    ent.nsz_scan.corners[3] = ent:LocalToWorld(Vector(c[1] + s[1], c[2] - s[2], c[3] + s[3]))
                    ent.nsz_scan.corners[4] = ent:LocalToWorld(Vector(c[1] - s[1], c[2] - s[2], c[3] + s[3]))
                    ent.nsz_scan.corners[5] = ent:LocalToWorld(Vector(c[1] + s[1], c[2] + s[2], c[3] - s[3]))
                    ent.nsz_scan.corners[6] = ent:LocalToWorld(Vector(c[1] - s[1], c[2] + s[2], c[3] - s[3]))
                    ent.nsz_scan.corners[7] = ent:LocalToWorld(Vector(c[1] + s[1], c[2] - s[2], c[3] - s[3]))
                    ent.nsz_scan.corners[8] = ent:LocalToWorld(Vector(c[1] - s[1], c[2] - s[2], c[3] - s[3]))

                    -- This is used for SAT (Separating Axis Theorem) detection
                    ent.nsz_scan.axes = {
                        -- Normals
                        Vector(1, 0, 0), Vector(0, 1, 0), Vector(0, 0, 1),
                        ent:GetForward(), ent:GetRight(), ent:GetUp(),
                        -- Crosses
                        cross(ent:GetForward(), Vector(1, 0, 0)), cross(ent:GetRight(), Vector(1, 0, 0)), cross(ent:GetUp(), Vector(1, 0, 0)),
                        cross(ent:GetForward(), Vector(0, 1, 0)), cross(ent:GetRight(), Vector(0, 1, 0)), cross(ent:GetUp(), Vector(0, 1, 0)),
                        cross(ent:GetForward(), Vector(0, 0, 1)), cross(ent:GetRight(), Vector(0, 0, 1)), cross(ent:GetUp(), Vector(0, 0, 1))
                    }
                end

                local inzone = true

                local corners = ent.nsz_scan.corners
                local axes = ent.nsz_scan.axes

                for x = 1, #axes do
                    local minA = math.huge
                    local maxA = -math.huge
                    local minB = math.huge
                    local maxB = -math.huge

                    for y = 1, 8 do
                        local p = dot(corners[y], axes[x])
                        minA = math.min(minA, p)
                        maxA = math.max(maxA, p)

                        p = dot(zone.corners[y], axes[x])
                        minB = math.min(minB, p)
                        maxB = math.max(maxB, p)
                    end

                    if maxA < minB then
                        inzone = false
                        break
                    end

                    if minA > maxB then
                        inzone = false
                        break
                    end
                end

                if inzone and not table.HasValue(zones, zone.identifier) then
                    table.insert(zones, zone.identifier)
                    table.insert(indexes, i)
                end
            end

            -- ent.nsz_scan = nil -- Remove the scan data since we want to refresh it next check.
        end
    end

    return zones, indexes
end

local function assignEnt(ent, ply)
    ent.nsz_zones = {}
    ent.nsz_collision = ent:GetCollisionGroup()
    ent.nsz_mat = ent:GetMaterial()

    if CPPI then return end -- This is only if no PP exists
    ent:SetNWEntity("nsz_owner", ply)
end

-- This hook sets the owner of an entity
hook.Add("PlayerSpawnedNPC", "nsz_apply_owner", function(ply, ent)
    assignEnt(ent, ply)
end)
hook.Add("PlayerSpawnedProp", "nsz_apply_owner", function(ply, model, ent)
    assignEnt(ent, ply)
end)
hook.Add("PlayerSpawnedRagdoll", "nsz_apply_owner", function(ply, model, ent)
    assignEnt(ent, ply)
end)
hook.Add("PlayerSpawnedSENT", "nsz_apply_owner", function(ply, ent)
    assignEnt(ent, ply)
end)
hook.Add("PlayerSpawnedSWEP", "nsz_apply_owner", function(ply, ent)
    assignEnt(ent, ply)
end)
hook.Add("PlayerSpawnedVehicle", "nsz_apply_owner", function(ply, ent)
    assignEnt(ent, ply)
end)

local index = 0
local entities

-- Difference between both caches is one is always true if in the zone, 
-- the other can kick the player out and not fire NSZEnter again until they leave.
nsz.playerCache = nsz.playerCache or {}
nsz.truePlayerCache = nsz.truePlayerCache or {}
nsz.entityCache = nsz.entityCache or {}
nsz.trueEntityCache = nsz.trueEntityCache or {}

hook.Add("Think", "nsz_check", function()
    -- We don't want to loop anything if there are no zones
    if #nsz.zones == 0 then return end

    local start = SysTime()

    -- Player zone detection
    for i, ply in ipairs(player.GetAll()) do
        scans = scans + 1
        if not istable(nsz.playerCache[ply]) then 
            nsz.playerCache[ply] = {} 
            nsz.truePlayerCache[ply] = {} 
        end

        -- Check if a player isn't moving (probably not needed tbh, over-optimization)
        local pos = {ply:GetPos()}
        if ply.nsz_lastPos == pos then continue end
        ply.nsz_lastPos = pos

        -- Check if they are in any zone and run if they're not in the cache
        local zones, indexes = nsz:InZone(ply)
        for id, info in pairs(nsz.zonetypes) do -- Loop through all the regisered zones
            if not istable(info) then continue end -- Invalid zone somewhow

            if table.HasValue(zones, info.identifier) and not nsz.playerCache[ply][info.identifier] and not nsz.truePlayerCache[ply][info.identifier] then
                -- Return true to block from entering a zone
                local blockFromEntering = hook.Run("NSZRequestEnter", info.identifier, ply)
                if not isbool(blockFromEntering) then blockFromEntering = false end

                if blockFromEntering then 
                    hook.Run("NSZEntryDenied", info.identifier, ply)
                else
                    nsz.playerCache[ply][info.identifier] = SysTime()
                    ply:SetNWBool("nsz_in_zone_" .. info.identifier, true)
                    ply:SetNWInt("nsz_zone_index_" .. info.identifier, indexes[table.KeyFromValue(zones, info.identifier)] or -1)
                    hook.Run("NSZEntered", info.identifier, ply)
                end
                nsz.truePlayerCache[ply][info.identifier] = true
            elseif not table.HasValue(zones, info.identifier) and nsz.playerCache[ply][info.identifier] then
                hook.Run("NSZExit", info.identifier, ply, false)

                ply:SetNWBool("nsz_in_zone_" .. info.identifier, false)
                nsz.playerCache[ply][info.identifier] = nil
                nsz.truePlayerCache[ply][info.identifier] = nil
            elseif not table.HasValue(zones, info.identifier) and nsz.truePlayerCache[ply][info.identifier] then
                nsz.truePlayerCache[ply][info.identifier] = nil
            end
        end
    end

    -- Entity zone detection
    local ind = 0
    local maxInd = GetConVar("nsz_prop_checks_per_tick"):GetInt()

    if not istable(entities) then entities = ents.GetAll() end

    if index >= #entities then index = 0 entities = ents.GetAll() end
    while index < #entities and ind < maxInd do
        ind = ind + 1
        index = index + 1
        scans = scans + 1

        local ent = entities[index]
        if IsValid(ent) and not ent:IsPlayer() then
            -- We don't need to check an entity if it doesn't even have a
            -- phyisical object, or if it's sleeping. Moving the prop would wake it
            local phys = ent:GetPhysicsObject()
            if not IsValid(phys) then continue end

            -- local owner = ent.nsz_owner
            local owner = nsz:GetEntityOwner(ent)

            -- Completely skip this prop if there is no owner
            if IsValid(owner) and owner:IsPlayer() then
                -- Custom sleep detection: normal method doesn't always work for dupes
                if not istable(ent.nsz_cache) then
                    ent.nsz_cache = {
                        pos = {ent:GetPos()},
                        ang = {ent:GetAngles()},
                        size = {ent:GetCollisionBounds()}
                    }
                end

                local pos = {ent:GetPos()}
                local ang = {ent:GetAngles()}
                local size = {ent:GetCollisionBounds()}

                -- Entity was changed
                local cache = ent.nsz_cache
                if pos == cache.pos and ang == cache.ang and size == cache.size then continue end

                cache.pos = pos
                cache.ang = ang
                cache.size = size

                -- Exit if normal asleep
                if phys:IsAsleep() then continue end

                local entityIndex = ent:EntIndex()
                if not istable(nsz.entityCache[entityIndex]) then 
                    nsz.entityCache[entityIndex] = {} 
                    nsz.trueEntityCache[entityIndex] = {} 
                end

                local zones = nsz:InZone(ent)
                for id, info in pairs(nsz.zonetypes) do
                    if not istable(info) then continue end -- Somehow an invalid zone type

                    if table.HasValue(zones, info.identifier) and not nsz.entityCache[entityIndex][info.identifier] and not nsz.trueEntityCache[entityIndex][info.identifier] then
                        local blockFromEntering = hook.Run("NSZRequestEnter", info.identifier, ent)
                        if not isbool(blockFromEntering) then blockFromEntering = false end

                        if blockFromEntering then 
                            hook.Run("NSZEntryDenied", info.identifier, ent)
                        else
                            nsz.entityCache[entityIndex][info.identifier] = SysTime()
                            hook.Run("NSZEntered", info.identifier, ent)
                        end
                        nsz.trueEntityCache[entityIndex][info.identifier] = true
                    elseif not table.HasValue(zones, info.identifier) and nsz.entityCache[entityIndex][info.identifier] then
                        hook.Run("NSZExit", info.identifier, ent, false)
                        hook.Run("EntityZoneLeave", ent, info.identifier)

                        nsz.entityCache[entityIndex][info.identifier] = nil
                        nsz.trueEntityCache[entityIndex][info.identifier] = nil
                    elseif not table.HasValue(zones, info.identifier) and nsz.trueEntityCache[entityIndex][info.identifier] then 
                        nsz.trueEntityCache[entityIndex][info.identifier] = nil
                    end
                end
            end
        end

        if index >= #entities then
            index = 0
            entities = ents.GetAll()
        end
    end

    local fin = SysTime()
    table.insert(times, fin - start)

    -- Loop through the player cache and run associated hooks
    local zones = {}
    for player, zoneTypes in pairs(nsz.playerCache) do 
        for zone, enterTime in pairs(zoneTypes) do 
            if not istable(zones[zone]) then zones[zone] = {players = {}, entities = {}} end
            zones[zone].players[player] = SysTime() - enterTime
        end
    end
    for entityIndex, zoneTypes in pairs(nsz.entityCache) do 
        local ent = ents.GetByIndex(entityIndex)
        if not IsValid(ent) then 
            nsz.entityCache[entityIndex] = nil
            nsz.trueEntityCache[entityIndex] = nil
            continue
        end

        for zone, enterTime in pairs(zoneTypes) do 
            if not istable(zones[zone]) then zones[zone] = {players = {}, entities = {}} end
            zones[zone].entities[ent] = SysTime() - enterTime
        end
    end

    for zoneType, zoneData in pairs(zones) do 
        hook.Run("NSZThink", zoneType, zoneData.players, zoneData.entities)
    end
end)

function nsz:GetEntityOwner(entity)
    if not IsValid(entity) then return NULL end
    if CPPI and entity.CPPIGetOwner then 
        return entity:CPPIGetOwner()
    else 
        return entity:GetNWEntity("nsz_owner", NULL)
    end
end

-- Returns the original, modifiable cache for an entity/player. Be careful if you do modify it,
-- you could break something
function nsz:GetZonesTable(ent)
    if IsEntity(ent) then 
        local cache
        if ent:IsPlayer() then cache = nsz.playerCache[ent]
        else cache = nsz.entityCache[ent:EntIndex()] end

        if istable(cache) then return cache end
    end
    return {}
end

-- Returns a sequential table of all zones a player/entity is in
function nsz:GetZones(ent)
    if IsEntity(ent) then 
        local cache = nsz:GetZonesTable(ent)
        return table.GetKeys(cache)
    end
    return {}
end

-- Checks if a player or entity is in a specified zone (string or table of strings)
function nsz:InZoneCache(ent, zoneFilter)
    if IsEntity(ent) then 
        local zones = nsz:GetZones(ent)
        if isstring(zoneFilter) then 
            return table.HasValue(zones, zoneFilter)
        elseif istable(zoneFilter) then 
            for i, zone in ipairs(zoneFilter) do 
                if table.HasValue(zones, zone) then return true end
            end
        end
    end
    return false
end

-- Removes a player/entity from a zone(s) and fires hook "NSZExit"
-- "NSZRequestEnter" won't fire again until they leave the zone and try re-entering.
function nsz:KickFromZone(ent, zoneFilter)
    if IsEntity(ent) then 
        local zonesTable = nsz:GetZonesTable(ent)
        
        if isstring(zoneFilter) then 
            if istable(zonesTable[zoneFilter]) then 
                zonesTable[zoneFilter] = nil
                hook.Run("NSZExit", zoneFilter, true)
            end
        elseif istable(zoneFilter) then  
            for i, zone in ipairs(zoneFilter) do 
                if istable(zoneTable[zone]) then 
                    zonesTable[zone] = nil
                    hook.Run("NSZExit", zone, true)
                end
            end
        end
    end
end

hook.Add("EntityRemoved", "NSZ Cleanup Cache", function(entity)
    local index = entity:EntIndex()
    if nsz.entityCache[index] then nsz.entityCache[index] = nil end
    if nsz.trueEntityCache[index] then nsz.trueEntityCache[index] = nil end
end)
hook.Add("PlayerDisconnected", "NSZ Cleanup Cache", function(player)
    if nsz.playerCache[player] then nsz.playerCache[player] = nil end
    if nsz.truePlayerCache[player] then nsz.truePlayerCache[player] = nil end
end)
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
    net.Broadcast()

    -- Reset the times and scans count
    times = {}
    checked = 0
    scans = 0
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

    for i, zone in ipairs(nsz.zones) do
        -- No need to check this zone if it's already in a zone of this type
        if table.HasValue(zones, zone.type) then continue end

        if not istable(zone.points) then continue end -- Somehow the two defining corners don't exist
        if not (isvector(zone.points[1]) or isvector(zone.points[2])) then continue end -- Invalid points
        local p1, p2 = zone.points[1], zone.points[2]

        if isstring(filter) then
            if zone.type ~= typ then continue end
        elseif istable(filer) and table.IsSequential(filter) then
            if not table.HasValue(filter, zone.type) then continue end
        end

        if isvector(ent) then
            if ent:WithinAABox(p1, p2) then
                if not table.HasValue(zones, zone.type) then table.insert(zones, zone.type) end
            end
            continue
        end

        if isentity(ent) then
            if ent:GetPos():WithinAABox(p1, p2) or ent:LocalToWorld(ent:OBBCenter()):WithinAABox(p1, p2) then
                if not table.HasValue(zones, zone.type) then table.insert(zones, zone.type) end
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
                local min, max = ent:WorldSpaceAABB()
                local inzone = {}

                for i = 1, 3 do
                    inzone[i] =                       (min[i] < p1[i] and max[i] > p2[i])     -- Enveloping the zone
                    if not inzone[i] then inzone[i] = (min[i] < p2[i] and max[i] > p2[i]) end -- Touching the zone
                    if not inzone[i] then inzone[i] = (min[i] > p1[i] and max[i] < p2[i]) end -- Enveloped in the zone
                    if not inzone[i] then inzone[i] = (min[i] < p1[i] and max[i] > p1[i]) end -- Touching the zone
                end

                if inzone[1] and inzone[2] and inzone[3] then
                    if not table.HasValue(zones, zone.type) then table.insert(zones, zone.type) end
                    continue
                end
            else -- SAT (Separating Axis Theorem) detection
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

                if inzone and not table.HasValue(zones, zone.type) then
                    table.insert(zones, zone.type)
                end
            end

            ent.nsz_scan = nil -- Remove the scan data since we want to refresh it next check.
        end
    end

    return zones
end

nsz.cache = {}
hook.Add("Think", "nsz_hooks", function()
    -- We don't want to loop anything if no zone exists
    if #nsz.zones == 0 then return end

    -- Used for nsz_show_zones debug
    local start = SysTime()

    -- Loop through all the players
    for i, ply in ipairs(player.GetAll()) do
        scans = scans + 1
        if not istable(nsz.cache[ply:SteamID()]) then nsz.cache[ply:SteamID()] = {} end

        -- Check if a player isn't moving (probably not needed tbh, over-optimization)
        local pos = {ply:GetPos()}
        if ply.nsz_lastPos == pos then continue end
        ply.nsz_lastPos = pos

        checked = checked + 1
        -- Check if they are in any zone and run if they're not in the cache
        local zones = nsz:InZone(ply)
        for id, info in pairs(nsz.zonetypes) do -- Loop through all the regisered zones
            if not istable(info) then continue end -- Invalid zone somewhow

            if table.HasValue(zones, info.type) and not nsz.cache[ply:SteamID()][info.type] then
                -- This is the hook you use to change the behavior of entering
                -- zones. Return true to allow, false to disallow
                local allow = hook.Run("EntityZoneEnter", ply, info.type)
                if isbool(allow) then
                    ply:SetNWBool("nsz_in_zone_" .. info.type, allow)
                else
                    ply:SetNWBool("nsz_in_zone_" .. info.type, true)
                end

                nsz.cache[ply:SteamID()][info.type] = true
            elseif not table.HasValue(zones, info.type) and nsz.cache[ply:SteamID()][info.type] then
                hook.Run("EntityZoneLeave", ply, info.type)

                ply:SetNWBool("nsz_in_zone_" .. info.type, false)
                nsz.cache[ply:SteamID()][info.type] = nil
            end
        end
    end

    local fin = SysTime()
    table.insert(times, fin - start)
end)

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
-- This hook handles props (for no building)
hook.Add("Think", "nsz_anti_props", function()
    -- We don't want to loop anything if there are no zones
    if #nsz.zones == 0 then return end

    local start = SysTime()

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
            local owner
            if CPPI and ent.CPPIGetOwner then
                owner = ent:CPPIGetOwner()
            else
                owner = ent:GetNWEntity("nsz_owner")
            end

            -- Completely skip this prop if there is no owner
            if IsValid(owner) and owner:IsPlayer() then
                -- If it's ghosted, we want to make sure that it remains ghosted
                if istable(ent.nsz_zones) then
                    local z = ent.nsz_zones
                    for zone, _ in pairs(z) do
                        if not istable(nsz.zonetypes[zone]) then continue end
                        local info = nsz.zonetypes[zone]

                        local ghost
                        if ULib ~= nil then
                            ghost = true
                            if ULib.ucl.query(owner, "nsz_" .. info.type .. " build") then ghost = false end
                        else
                            ghost = not owner:IsAdmin() -- Default behavior is to let admins build
                        end

                        if ghost then
                            if ent:GetCollisionGroup() ~= COLLISION_GROUP_WORLD then
                                ent.nsz_collision = ent:GetCollisionGroup()
                                ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
                            end

                            if ent:GetMaterial() ~= "models/props_lab/Tank_Glass001" then
                                ent.nsz_mat = ent:GetMaterial()
                                ent:SetMaterial("models/props_lab/Tank_Glass001")
                            end
                        end
                    end
                end

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

                if not istable(ent.nsz_zones) then ent.nsz_zones = {} end
                if not isnumber(ent.nsz_collision) then ent.nsz_collision = ent:GetCollisionGroup() end
                if not isstring(ent.nsz_mat) then ent.nsz_mat = ent:GetMaterial() end

                checked = checked + 1
                local zones = nsz:InZone(ent)
                for id, info in pairs(nsz.zonetypes) do
                    if not istable(info) then continue end -- Somehow an invalid zone type

                    if table.HasValue(zones, info.type) and not ent.nsz_zones[info.type] then
                        local allowed = hook.Run("EntityZoneEnter", ent, info.type) -- Return true to ghost it
                        local ghost
                        if isbool(allowed) then
                            ghost = allowed
                        else
                            if ULib ~= nil then
                                ghost = true
                                if ULib.ucl.query(owner, "nsz_" .. info.type .. " build") then ghost = false end
                            else
                                ghost = not owner:IsAdmin() -- Default behavior is to let admins build
                            end
                        end

                        if ghost then
                            ent.nsz_zones[info.type] = true
                            if ent:GetCollisionGroup() ~= COLLISION_GROUP_WORLD then
                                ent.nsz_collision = ent:GetCollisionGroup()
                                ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
                            end

                            if ent:GetMaterial() ~= "models/props_lab/Tank_Glass001" then
                                ent.nsz_mat = ent:GetMaterial()
                                ent:SetMaterial("models/props_lab/Tank_Glass001")
                            end
                        end
                    elseif not table.HasValue(zones, info.type) and ent.nsz_zones[info.type] then
                        hook.Run("EntityZoneLeave", ent, info.type)

                        ent.nsz_zones[info.type] = nil
                        ent:SetCollisionGroup(ent.nsz_collision)
                        ent:SetMaterial(ent.nsz_mat)
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
end)

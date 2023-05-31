nsz:RegisterZone("Safe Zone", "You are protected from all harm", "safe", "materials/nsz/nsz.png", Color(62, 255, 62))
nsz:RegisterZone("Spawn Zone", "No building or killing here", "spawn", "materials/nsz/nsz.png", Color(255, 255, 62))
nsz:RegisterZone("No Build Zone", "You cannot build here", "nobuild", "materials/nsz/no_build_zone.png", Color(255, 62, 62))

-- ULX support
if ULib ~= nil then 
    ULib.ucl.registerAccess("Safe Zone - No Damage", "user", "No damage received in safe zones.", "Nub's Safe Zones")
    ULib.ucl.registerAccess("No Build Zone - Allow Building", "admin", "Allow building in no build zones.", "Nub's Safe Zones")
    ULib.ucl.registerAccess("Spawn Zone - No Damage", "user", "No damage received in spawn zones.", "Nub's Safe Zones")
    ULib.ucl.registerAccess("Spawn Zone - Allow Building", "admin", "Allow building in spawn zones.", "Nub's Safe Zones")
end

hook.Add("NSZRequestEnter", "Allow into default zones", function(zoneType, entity)
    -- print("requesting", zoneType, entity)
    local inSafe    = zoneType == "safe"
    local inSpawn   = zoneType == "spawn"
    local inNobuild = zoneType == "nobuild"

    if (inSafe or inSpawn) and entity:IsPlayer() then
        if ULib == nil then return end
        if inSafe and not ULib.ucl.query(entity, "Safe Zone - No Damage") then return true end
        if not ULib.ucl.query(entity, "Spawn Zone - No Damage") then return true end
    end
    
    if (inSpawn or inNobuild) and not entity:IsPlayer() then 
        local owner = nsz:GetEntityOwner(entity)
        if not IsValid(owner) then return end

        if ULib == nil then if owner:IsAdmin() then return true else return end end
        
        if inSpawn and ULib.ucl.query(owner, "Spawn Zone - Allow Building") then return true end
        if ULib.ucl.query(owner, "No Build Zone - Allow Building") then return true end
    end
end)

-- Block all damage (for safe and spawn zones)
hook.Add("EntityTakeDamage", "nsz_prevent_damage_safe_and_spawn_zone", function(victim, damage)
    local attacker = damage:GetAttacker()
    
    -- Attacker is in a zone
    if IsValid(attacker) and attacker:IsPlayer() then
        if nsz:InZoneCache(attacker, {"safe", "spawn"}) then
            return true
        end
    end

    -- Attacker is still in the zone, but shooting a weapon
    if IsValid(attacker) and attacker.IsWeapon and attacker:IsWeapon() then
        attacker = attacker.Owner
        if isentity(attacker) and attacker:IsPlayer() then
            if nsz:InZoneCache(attacker, {"safe", "spawn"}) then
                return true
            end
        end
    end

    -- The player themself is in the zone
    if victim:IsPlayer() then
        if nsz:InZoneCache(victim, {"safe", "spawn"}) then
            return true
        end
    end
end)

hook.Add("NSZEntered", "No Building Initial Ghosting", function(zoneType, entity)
    if entity:IsPlayer() then return end
    if zoneType ~= "spawn" and zoneType ~= "nobuild" then return end

    if entity.nsz_initialCollisionGroup == nil then entity.nsz_initialCollisionGroup = entity:GetCollisionGroup() end
    entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
end)
hook.Add("NSZExit", "No Building Unghosting", function(zoneType, entity)
    if entity:IsPlayer() then return end
    if zoneType ~= "spawn" and zoneType ~= "nobuild" then return end

    if entity.nsz_initialCollisionGroup ~= nil then 
        entity:SetCollisionGroup(entity.nsz_initialCollisionGroup)
    end
end)

hook.Add("NSZThink", "No Building Keep Ghosted", function(zoneType, players, entities)
    if zoneType ~= "spawn" and zoneType ~= "nobuild" then return end

    for entity, elapsedTimeInZone in pairs(entities) do 
        if entity:GetCollisionGroup() ~= COLLISION_GROUP_WORLD then 
            entity.nsz_initialCollisionGroup = entity:GetCollisionGroup()
            entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
        end
    end
end)
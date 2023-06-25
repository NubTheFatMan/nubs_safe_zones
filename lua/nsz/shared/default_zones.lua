nsz:RegisterZone({
    identifier = "safe",
    icon = "materials/nsz/nsz.png",
    color = Color(62, 255, 62),
    settings = {
        {
            identifier = "protectWithGod",
            typeOfSetting = nsz.settingTypes.BOOL,
            defaultValue = false
        }
    }
})
nsz:RegisterZone({
    identifier = "spawn",
    icon = "materials/nsz/nsz.png",
    color = Color(255, 255, 62),
    settings = {
        {
            identifier = "protectWithGod",
            typeOfSetting = nsz.settingTypes.BOOL,
            defaultValue = false
        }, 
        {
            identifier = "allowReentry",
            typeOfSetting = nsz.settingTypes.BOOL,
            defaultValue = true
        }
    }
})
nsz:RegisterZone({
    identifier = "nobuild",
    icon = "materials/nsz/no_build_zone.png",
    color = Color(255, 62, 62),
    settings = {
        {
            identifier = "shouldSetMaterial",
            typeOfSetting = nsz.settingTypes.BOOL,
            defaultValue = false
        },
        {
            identifier = "material",
            typeOfSetting = nsz.settingTypes.MATSELECT
        },
        {
            typeOfSetting = nsz.settingTypes.DIVIDER
        },
        {
            identifier = "shouldSetColor",
            typeOfSetting = nsz.settingTypes.BOOL,
            defaultValue = false
        },
        {
            identifier = "color",
            typeOfSetting = nsz.settingTypes.COLOR,
            defaultValue = Color(255, 255, 255)
        }
    }
})

nsz:RegisterZone({
    identifier = "healing",
    icon = "materials/nsz/nsz.png",
    color = Color(62, 96, 255),
    settings = {
        {
            identifier = "healingAmount",
            typeOfSetting = nsz.settingTypes.SLIDER,
            defaultValue = 2,
            decimals = 0,
            minimumValue = 1, maximumValue = 100
        },
        {
            identifier = "healingRate",
            typeOfSetting = nsz.settingTypes.FLOAT,
            defaultValue = 3
        }
    }
})

if CLIENT then 
    nsz.language.SetActiveLanguage("English")
    nsz.language.Add("zones.safe.title",                         "Safe Zone")
    nsz.language.Add("zones.safe.subtitle",                      "You are protected from all harm.")
    nsz.language.Add("zones.safe.settings.protectWithGod.label", "Protect players with god mode")
    nsz.language.Add("zones.safe.settings.protectWithGod.help",  "Enables godmode in safe zones. No damage can be taken whatsoever. If disabled, damage is reduced to 0 from others while allowing them to hurt themselves (i. e. jumping off a ledge). This will conflict with god commands.")
    
    nsz.language.Add("zones.spawn.title",                         "Spawn Zone")
    nsz.language.Add("zones.spawn.subtitle",                      "No building or killing here.")
    nsz.language.Add("zones.spawn.settings.protectWithGod.label", "Protect players with god mode")
    nsz.language.Add("zones.spawn.settings.protectWithGod.help",  "Enables godmode in spawn zones. No damage can be taken whatsoever. If disabled, damage is reduced to 0 from others while allowing them to hurt themselves (i. e. jumping off a ledge). This will conflict with god commands.")
    nsz.language.Add("zones.spawn.settings.allowReentry.label",   "Allow re-entry after exiting") 
    nsz.language.Add("zones.spawn.settings.allowReentry.help",    "Only allows the player to enter the zone once until they die") 

    nsz.language.Add("zones.nobuild.title",                            "No Build Zone")
    nsz.language.Add("zones.nobuild.subtitle",                         "No building here.")
    nsz.language.Add("zones.nobuild.settings.shouldSetMaterial.label", "Should the entity's material be changed?")
    nsz.language.Add("zones.nobuild.settings.setMaterial.label",       "Material to be applied:")
    nsz.language.Add("zones.nobuild.settings.shouldSetColor.label",    "Should the entity's color be changed?")
    nsz.language.Add("zones.nobuild.settings.setColor.label",          "Color to be applied:")

    nsz.language.Add("zones.healing.title",    "Health Zone")
    nsz.language.Add("zones.healing.subtitle", "You regenerate health here.")
end

if SERVER then 
    -- ULX support
    if ULib ~= nil then 
        ULib.ucl.registerAccess("Safe Zone - No Damage", "user", "No damage received in safe zones.", "Nub's Safe Zones")
        ULib.ucl.registerAccess("No Build Zone - Allow Building", "admin", "Allow building in no build zones.", "Nub's Safe Zones")
        ULib.ucl.registerAccess("Spawn Zone - No Damage", "user", "No damage received in spawn zones.", "Nub's Safe Zones")
        ULib.ucl.registerAccess("Spawn Zone - Allow Building", "admin", "Allow building in spawn zones.", "Nub's Safe Zones")
    end

    hook.Add("NSZRequestEnter", "Allow into default zones", function(zoneType, entity)
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

            if ULib == nil then 
                if owner:IsAdmin() then 
                    return true 
                else 
                    return 
                end 
            end
            
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
end
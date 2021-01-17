-- This file is responsible for making sure no damage is done in safe zones.

local function checkSafe(ply, zone)
    if not istable(nsz.zonetypes[zone]) then return false end
    if ULib == nil then return true end -- Default behavior is to keep people safe

    local info = nsz.zonetypes[zone]
    return ULib.ucl.query(ply, "nsz_" .. info.type .. " nodamage")
end

-- Block all damage
hook.Add("EntityTakeDamage", "nsz_prevent_damage", function(targ, dmg)
    local attacker = dmg:GetAttacker()

    -- Attacker himself is in a zone
    if IsValid(attacker) and attacker:IsPlayer() then
        if istable(nsz.cache[attacker:SteamID()]) then
            for zone, _ in pairs(nsz.cache[attacker:SteamID()]) do
                if checkSafe(attacker, zone) then return true end
            end
        end
    end

    -- Attacker is still in the zone, but shooting a weapon
    if IsValid(attacker) and attacker.IsWeapon and attacker:IsWeapon() then
        attacker = attacker.Owner
        if isentity(attacker) and attacker:IsPlayer() then
            if istable(nsz.cache[attacker:SteamID()]) then
                for zone, _ in pairs(nsz.cache[attacker:SteamID()]) do
                    if checkSafe(attacker, zone) then return true end
                end
            end
        end
    end

    -- The player themself is in the zone
    if targ:IsPlayer() then
        if istable(nsz.cache[targ:SteamID()]) then
            for zone, _ in pairs(nsz.cache[targ:SteamID()]) do
                if checkSafe(targ, zone) then return true end
            end
        end
    end
end)

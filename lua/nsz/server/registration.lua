-- This file is responsible for custom zone types

-- This function registers a zone
-- nsz:RegisterZone(title, subtitle, type, icon, color, variables)
--     * string title: The title of the zone (to display on the HUD)
--     * string subtitle: The subtitle of the zone (to display on the HUD)
--     * string type: The zone ID, used for permissions and whatnot
--     string icon="materials/nsz/nsz.png": The icon to show on the HUD
--     Color color=Color(255, 255, 255): The color of the zone title (and for debug rendering)
--
--     This will register a zone for the server
function nsz:RegisterZone(title, subtitle, typ, icon, color)
    if not isstring(title) then error("nsz:RegisterZone: Bad argument #1: String expected for title, got " .. type(title)) return end
    if not isstring(subtitle) then error("nsz:RegisterZone: Bad argument #2: String expected for subtitle, got " .. type(subtitle)) return end
    if not isstring(typ) then error("nsz:RegisterZone: Bad argument #3: String expected for zone type, got " .. type(typ)) return end

    if not isstring(icon) and CLIENT then icon = "materials/nsz/nsz.png" end
    if not IsColor(color) then color = Color(255, 255, 255) end

    nsz.zonetypes[typ] = {
        title = title,
        subtitle = subtitle,
        type = typ,
        icon = icon,
        color = color
    }

    MsgN("NSZ: Zone type registered: " .. typ)
end

-- Allow the weapon to be used (ULX support)
if ULib ~= nil then
    ULib.ucl.registerAccess("Create Zones", {"superadmin"}, "Users with this permission can create zones.", "Nub's Safe Zones")
end
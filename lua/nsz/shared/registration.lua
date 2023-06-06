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
function nsz:RegisterZone(identifier, title, subtitle, icon, color)
    if istable(identifier) then 
        if not isstring(identifier.identifier) then error("Expected identifier to be a string, got " .. type(identifier.identifier)) end
        if identifier.identifier == "null" then error("\"null\" is a reserved zone identifier.") end

        local zone = table.Copy(identifier)
        if not isstring(zone.icon) then zone.icon = "materials/nsz/nsz.png" end
        if not IsColor(zone.color) then zone.color = Color(255, 255, 255) end

        if istable(zone.settings) and SERVER then 
            if not istable(nsz.zoneSettings[zone.identifier]) then nsz.zoneSettings[zone.identifier] = {} end
            local actualSetting = nsz.zoneSettings[zone.identifier]

            for ID, setting in pairs(zone.settings) do 
                if actualSetting[ID] ~= nil then continue end -- This code is just supposed to assign a default value if it doesn't already have data
                
                if setting.defaultValue ~= nil then 
                    actualSetting[ID] = setting.defaultValue
                else 
                    if not isnumber(setting.typeOfSetting) then error("Bad setting \"" .. ID .. "\": Expected a number, got " .. type(setting.typeOfSetting)) end
                    if setting.typeOfSetting == nsz.settingTypes.BOOL then 
                        actualSetting[ID] = false
                    elseif setting.typeOfSetting == nsz.settingTypes.FLOAT or setting.typeOfSetting == nsz.settingTypes.INT or setting.typeOfSetting == nsz.settingTypes.SLIDER then 
                        local minimum, maximum = isnumber(setting.minimumValue), isnumber(setting.maximumValue)
                        if minimum and maximum then 
                            actualSetting[ID] = (setting.minimumValue + maximumValue) / 2
                            if setting.typeOfSetting == nsz.settingTypes.INT then actualSetting[ID] = math.Round(actualSetting[ID]) end
                        elseif minimum then actualSetting[ID] = setting.minimumValue
                        elseif maximum then actualSetting[ID] = maximumValue
                        else actualSetting[ID] = 0 end
                    elseif setting.typeOfSetting == nsz.settingTypes.STRING then 
                        actualSetting[ID] = ""
                    elseif setting.typeOfSetting == nsz.settingTypes.COLOR then 
                        actualSetting[ID] = Color(255, 255, 255)
                    elseif setting.typeOfSetting == nsz.settingTypes.VECTOR then 
                        actualSetting[ID] = Vector(0, 0, 0)
                    elseif setting.typeOfSetting == nsz.settingTypes.ANGLE then 
                        actualSetting[ID] = Angle(0, 0, 0)
                    end
                end
            end
            nsz.SaveZoneSettings()
        end

        nsz.zonetypes[zone.identifier] = zone
        MsgN("NSZ: Registered zone \"" .. zone.identifier .. "\"")
    else 
        if not isstring(identifier) then error("Bad argument #1: String expected for zone type, got " .. type(identifier)) return end
        if identifier == "null" then error("Bad argument #1: \"null\" is a reserved zone identifier.") end

        if not isstring(icon) and CLIENT then icon = "materials/nsz/nsz.png" end
        if not IsColor(color) then color = Color(255, 255, 255) end

        nsz.zonetypes[identifier] = {
            title = title,
            subtitle = subtitle,
            identifier = identifier,
            icon = icon,
            color = color
        }

        MsgN("NSZ: Registered zone \"" .. identifier .. "\"")
    end
end

if CLIENT then 
    nsz.zoneSettings = nsz.zoneSettings or {}
end

nsz.settingTypes = {
    BOOL = 1, 
    FLOAT = 2,
    INT = 3,
    STRING = 4,
    SLIDER = 5,
    HEADER = 6,
    SUBTITLE = 7,
    LABEL = 8,
    DIVIDER = 9,
    COMBO = 10,
    COLOR = 11,
    VECTOR = 12,
    ANGLE = 13,
    MUTLIPLECHOICE = 14
}

-- Used in the event that a previously registered zone is no longer registered
nsz.NULL_ZONE = {
    identifier = "null",
    icon = "https://i.redd.it/jft9hnt9a6p81.png",
    color = Color(150, 150, 150)
}
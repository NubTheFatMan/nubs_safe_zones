-- My only language is english, however more languages can be added by 
-- replacing `English` with your language name and then registering the language with [undefined function]

nsz.language = nsz.language or {
    Phrases = {},
    Languages = {},
    ActiveLanguage = "English",
    RegisterLanguage = true
}

function nsz.language.Add(identifier, value)
    if not isstring(identifier) then error("Bad argument #1: Expected a string, got " .. type(identifier)) end
    if not isstring(value)      then error("Bad argument #2: Expected a string, got " .. type(value))      end

    local language = nsz.language.ActiveLanguage

    if not istable(nsz.language.Phrases[identifier]) then nsz.language.Phrases[identifier] = {} end
    nsz.language.Phrases[identifier][language] = value

    if nsz.language.RegisterLanguage then 
        if not table.HasValue(nsz.language.Languages, language) then 
            table.insert(nsz.language.Languages, language)
        end
    end
end

function nsz.language.GetPhraseIfExists(identifier)
    if not isstring(identifier) then error("Bad argument #1: Expected a string, got " .. type(identifier)) end

    local phrase = nsz.language.Phrases[identifier]
    if istable(phrase) then 
        local text = phrase[nsz.clientSettings.language]
        if isstring(text) then 
            return text
        end
    end
end

function nsz.language.GetPhrase(identifier)
    if not isstring(identifier) then error("Bad argument #1: Expected a string, got " .. type(identifier)) end
    return nsz.language.GetPhraseIfExists(identifier) or identifier
end
function nsz.language.GetPhraseOverride(identifier, languageOverride)
    if not isstring(identifier) then error("Bad argument #1: Expected a string, got " .. type(identifier)) end
    if not isstring(languageOverride) then error("Bad argument #2: Expected a string, got " .. type(languageOverride)) end

    local phrase = nsz.language.Phrases[identifier]
    if istable(phrase) then 
        if isstring(phrase[languageOverride]) then
            return phrase[languageOverride]
        end
    end
    return identifier
end

function nsz.language.SetActiveLanguage(language, register)
    if not isstring(language) then error("Bad argument #1: Expected a string, got " .. type(language)) end
    if not isbool(register) then register = true end

    nsz.language.ActiveLanguage = language
    nsz.language.RegisterLanguage = register
end

-- By default, it's already English, so this line is unnecessary
-- I have it here so you can see how to add your own language
nsz.language.SetActiveLanguage("English")

nsz.language.Add("menu.title",   "Safe Zones Interface")
nsz.language.Add("menu.close",   "Close")
nsz.language.Add("menu.credits", "Credits")

nsz.language.Add("tab.select", "Please select a tab.")

nsz.language.Add("tab.clientsettings", "Client Settings")
nsz.language.Add("tab.zonesettings",   "Zone Settings")

nsz.language.Add("menu.clientsettings.languagepick",       "Select a language:")
nsz.language.Add("menu.clientsettings.enable",             "Enable HUD")
nsz.language.Add("menu.clientsettings.preview",            "Show All Zones (preview)")
nsz.language.Add("menu.clientsettings.maxzones",           "## Zones on HUD:")
nsz.language.Add("menu.clientsettings.maxzonesentry",      "# zones")
nsz.language.Add("menu.clientsettings.dockpos",            "Dock Position:")
nsz.language.Add("menu.clientsettings.dockoffset",         "Dock Offset:")
nsz.language.Add("menu.clientsettings.resetoffset",        "Reset Offset:")
nsz.language.Add("menu.clientsettings.dragndrop",          "Edit by dragging and dropping")
nsz.language.Add("menu.clientsettings.dragedit.cancel",    "Cancel")
nsz.language.Add("menu.clientsettings.dragedit.accept",    "Accept")
nsz.language.Add("menu.clientsettings.dragedit.holdshift", "Hold LShift + click to set dock origin pos")
nsz.language.Add("menu.clientsettings.indicatorbg",        "Indicator Background")
nsz.language.Add("menu.clientsettings.blurbg",             "Blur background (if A < 255)")
nsz.language.Add("menu.clientsettings.blurstrength",       "Blur strength")
nsz.language.Add("menu.clientsettings.reset",              "Reset to Default")
nsz.language.Add("menu.clientsettings.save",               "Save Settings")
nsz.language.Add("menu.clientsettings.saved",              "Saved!")

nsz.language.Add("zones.null.title",    "Invalid Zone")
nsz.language.Add("zones.null.subtitle", "This zone type no longer exists (removed?)")
nsz.language.Add("zones.index",         "Zone ") -- Appends the zone # after this text, ie "Zone 3"

-- For the following 4 phrases, here the replacing values:
--   $averagetime - A float in milliseconds that is the average amount of time for the server to scan entities. Example: 0.12
--   $scans       - A fraction representing how many times `nsz:InZone()` was used vs how many times it could have been used. Example: 84/305
--   $ticks       - How many server ticks have passed since the values in these replacement variables were refreshed. Example: 7
--   $vectorscans - How many times the server checked if an entity was in a zone with just its Vector position. Example: 74
--   $aabbscans   - How many times the server checked if an entity was in a zone using its Axis Aligned Bounding Box (AABB). Example: 6
--   $satscans    - How many times the server checked if an entity was in a zone using Separating Axis Theorem (SAT). Example: 4
nsz.language.Add("hud.debug.averagecheck", "NSZ: Average check duration: $averagetime ms ($scans possible scans) over $ticks ticks")
nsz.language.Add("hud.debug.vectorscans",  "Vector scans (early exit optimization): $vectorscans")
nsz.language.Add("hud.debug.aabbscans",    "AABB scans: $aabbscans")
nsz.language.Add("hud.debug.satscans",     "SAT scans: $satscans")

nsz.language.Add("tool.name",                   "Zone Creator")
nsz.language.Add("tool.description",            "Create different types of zones for your players.")
nsz.language.Add("tool.placing",                "Placing zone: ") -- Concats "tool.select" right after it, or "zones.[zoneidentifier].title"
nsz.language.Add("tool.select",                 "[no set zone]")
nsz.language.Add("tool.leftclick.point1",       "Place the first zone corner where you are aiming.")
nsz.language.Add("tool.leftclick.point2",       "Place the second zone corner. Hold LAlt to place where you're aiming instead of right in front of you.")
nsz.language.Add("tool.reload",                 "Cancel zone placement.")
nsz.language.Add("tool.reset",                  "Reset current zone.")
nsz.language.Add("tool.point1set",              "Point 1 set, please click elsewhere to set the second point.")
nsz.language.Add("tool.sending",                "Creating zone...")
nsz.language.Add("tool.success",                "Success!")
nsz.language.Add("tool.spawnmenu.description",  "Place different zones for your players. Select a zone type below to place it!")
nsz.language.Add("tool.spawnmenu.refreshzones", "Refresh Zones")

nsz.language.Add("error.invalidzonetype",           "Invalid zone type selected. Please select a zone from the spawn menu.")
nsz.language.Add("error.invalidpoint",              "Invalid point (unable to locate where you're aiming (how??))") -- This should never be seen, however exists just in case
nsz.language.Add("error.nopermission.managezones",  "You don't have permission to create or delete zones.")
nsz.language.Add("error.nopermission.zonesettings", "You don't have permission to edit zone settings.")
nsz.language.Add("error.invalidpositions",          "You need two positions for a zone.")

nsz.language.Add("dev.nub.name",          "NubTheFatMan")
nsz.language.Add("dev.nub.contributions", "Main developer of the mod. Wrote all the code and created most of the icons.")
nsz.language.Add("dev.nub.link.steam",    "https://steamcommunity.com/profiles/76561198142667790") -- Would put a vanity URL but it'd become invalid if I ever changed it
nsz.language.Add("dev.nub.link.github",   "https://github.com/NubTheFatMan")

nsz.language.Add("dev.slime.name",          "Slime_Cubed")
nsz.language.Add("dev.slime.contributions", "Helped with the AABB vs SAT detection logic. Created the \"No Build Zone\" icon.")
nsz.language.Add("dev.slime.link.steam",    "https://steamcommunity.com/profiles/76561198120496479") -- Would put a vanity URL but it'd become invalid if it ever changes
nsz.language.Add("dev.slime.link.github",   "https://github.com/SlimeCubed")

nsz.language.Add("dev.buttontext.steam",  "Steam Profile Link")
nsz.language.Add("dev.buttontext.github", "GitHub Profile Link")
nsz.language.Add("dev.secret",            "Enable/Disable a secret language :)")

-- Second argument is false so it doesn't show up in the language combo box >:)
-- This language is activated by a secret found elsewhere
-- It's probably offensive, whatever that means :moyai:
nsz.language.SetActiveLanguage("Forbidden", false)

nsz.language.Add("menu.title",   "wife left me :(")
nsz.language.Add("menu.close",   "kys")
nsz.language.Add("menu.credits", "meth dealers")

nsz.language.Add("tab.clientsettings", "neat")
nsz.language.Add("tab.zonesettings",   "admin aboos")

nsz.language.Add("menu.clientsettings.languagepick",       "slang:")
nsz.language.Add("menu.clientsettings.enable",             "do da ting")
nsz.language.Add("menu.clientsettings.preview",            "see da ting")
nsz.language.Add("menu.clientsettings.maxzones",           "## times i fucked ya mum")
nsz.language.Add("menu.clientsettings.maxzonesentry",      "# sex")
nsz.language.Add("menu.clientsettings.dockpos",            "cock position:")
nsz.language.Add("menu.clientsettings.dockoffset",         "B==D offset:")
nsz.language.Add("menu.clientsettings.resetoffset",        "reset pp:")
nsz.language.Add("menu.clientsettings.dragndrop",          "drag em by the balls")
nsz.language.Add("menu.clientsettings.dragedit.cancel",    "forgor")
nsz.language.Add("menu.clientsettings.dragedit.accept",    "rember")
nsz.language.Add("menu.clientsettings.dragedit.holdshift", "Hold LShift + click to move cock")
nsz.language.Add("menu.clientsettings.indicatorbg",        "skin color")
nsz.language.Add("menu.clientsettings.blurbg",             "touching grass?")
nsz.language.Add("menu.clientsettings.blurstrength",       "grass height")
nsz.language.Add("menu.clientsettings.reset",              "rm -rf")
nsz.language.Add("menu.clientsettings.save",               "keep yourself safe")
nsz.language.Add("menu.clientsettings.saved",              "this is a cry for help")

nsz.language.Add("zones.null.title",    "bad zone")
nsz.language.Add("zones.null.subtitle", "RIP zone :(")

nsz.language.Add("hud.debug.averagecheck", "$averagetime $scans $ticks")
nsz.language.Add("hud.debug.vectorscans",  "$vectorscans")
nsz.language.Add("hud.debug.aabbscans",    "$aabbscans")
nsz.language.Add("hud.debug.satscans",     "$satscans")

nsz.language.Add("tool.name",                   "my crew is big and it keeps getting bigga")
nsz.language.Add("tool.description",            "thats cause jesus christ is my ni-[twitter has threatened to release my location if I complete this verse]")
nsz.language.Add("tool.placing",                "Rappin' for Jesus - ")
nsz.language.Add("tool.select",                 "[hey dumbass pick a zone]")
nsz.language.Add("tool.leftclick.point1",       "magical stuff")
nsz.language.Add("tool.leftclick.point2",       "magical stuff: the sequel")
nsz.language.Add("tool.reload",                 "Champions of Norrath is a great game")
nsz.language.Add("tool.reset",                  "wowww bruh you really wasted MY time >:(")
nsz.language.Add("tool.point1set",              "you should delete your browser history")
nsz.language.Add("tool.sending",                "im telling god")
nsz.language.Add("tool.success",                "god will smite you")
nsz.language.Add("tool.spawnmenu.description",  "something idk, pick from the box below i guess")
nsz.language.Add("tool.spawnmenu.refreshzones", "face my demons")

nsz.language.Add("error.invalidzonetype",           "you forgor a zone")
nsz.language.Add("error.invalidpoint",              "you fucking idiot how did you do this") -- This should never be seen, however exists just in case
nsz.language.Add("error.nopermission.managezones",  "aww poor baby don't have permission")
nsz.language.Add("error.nopermission.zonesettings", "im out of ideas for this shitshow of a language pack")
nsz.language.Add("error.invalidpositions",          "smoke weed every day")

nsz.language.SetActiveLanguage("English")
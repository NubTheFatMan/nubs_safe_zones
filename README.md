# Nubs-Safe-Zones
Safe Zone mod for Garry's Mod. This was developed a while ago, but I never actually put it on GitHub until now. Originally inspired by the now unsupported [Safe Zone](https://www.gmodstore.com/market/view/safe-zone-protect-your-players-now-with-a-zone-creator) mod from the GMod Store, I decided to recreate it. Here's how this version is better:
* The original didn't have any saving. You would have open a specific file and paste Lua code. It was nice enough to generate this lua code, but was an unnecessary step. This also required a server restart. With this mod, you just have to select the tool, click two points, and you were done.
* This is mostly programmer friendly. You can register your own type, change the behavior of what happens in a zone, or just disallow people as being in the zone (such as a permission system) When an entity (prop or player) enters a zone, it calls certain hooks.
* This mod factors in the hitbox. The original only factored a props position, which would lead to bugs where a prop was still inside the zone but it's position was not. This means that a large prop could still be used to push players outside of the zone. 
* This mod ghosts any props brought into a zone. The original would delete them without warning.
* This mod is optimized in which large prop counts won't cause lag. The original scanned every prop in the world every tick, while this limits how many it will scan per tick.
# Client Console Commands
* `nsz_show_zones (0|1)` - Shows a debug of all the current zones and how long it took to scan props during every tick.
* `nsz_show_display (0|1)` - Shows or hides the "you are in zone" indicator.
* `nsz_delete <zone ID>` - Deletes a zone by ID. SuperAdmin only be default, however has ULX permission support. You can get a zone ID by using the console command `nsz_show_zones`
* `nsz_gui` - Opens the GUI for the mod. Will eventually be moved to an umbrella command, `nsz` with argument `gui`.
# Server Console Commands and Variables
* `nsz_prop_checks_per_tick <# props>` - How many props to check per server tick. Higher number = more lag, but faster detection. Default is 50.
* `nsz_aabb_v_sat_sensitivity <sensitivity>` - Range of 0 to 90. This is the angle which determines whether to use AABB (Axis Aligned Bounding Box) detection or SAT (Separating Axis Theorem) detection. 0 = always use SAT (slow but accurate), 90 = always use AABB (fast with false positives). Default is 10.
# Bugs
Please note that I'm not currently working on this mod anymore, so no plans on fixing these are coming any time soon.
1. If two zones of the same type are next to each other, and you drag a prop through the line between them, the prop will flicker out and back into the zone.
2. If all zones are removed, any entities in a zone will remain marked in the zones they were in until another zone is created.

# Completed Features
These are features that were in Upcoming Changes listed below, however have been completed and moved to this list.
* Client settings are now available. Mainly you can just change where the zone indicator appears on screen and what it looks like.
* Moved from `Weapons > Other` to the toolbar to the right of the spawn menu. Removed the weapon version.
* Completely overhauled zones. Before, prop ghosting and preventing damage was baked into the mod. Now I've reworked the "API" if you will. Now the default zones are equal to any other addon for this mod, with some changes: 
    * Hooks "EntityZoneEnter" and "EntityZoneLeave" were removed. 
    * New hooks:
        Hook Name | Arguments | Description
        --------- | --------- | ----------
        NSZRequestEnter | string zoneIdentifier, Entity/Player ent | Fires when something tries to enter a zone. Return `true` to block it from entering.
        NSZEntryDenied | string zoneIdentifer, Entity/Player ent | Fires when the NSZRequestEnter hook had a return value of `true`
        NSZEntered | string zoneIdentifier, Entity/Player ent | Fires when something successfully enters a zone.
        NSZExit | string zoneIdentifier, Entity/Player ent | Fires when something exits a zone.
        NSZThink | string zoneIdentifier, table players, table entities | Fires with standard "Think", however provides tables formatted as `players[Player ply] = number elapsedTimeInZone`. Same goes for entities.
    * New functions:
        Function | Description | Return value
        -------- | ----------- | ----
        `nsz:GetEntityOwner(Entity ent)` | Tries to use `CPPI` (which every server should have) to get a player. Falls back to "[Spawned](https://wiki.facepunch.com/gmod/~search:PlayerSpawned)" hooks. | Returns a `Player` or `NULL`.
        `nsz:GetZones(Entity/Player ent)` | Checks the cache for the `ent` and returns all that they are in. | Returns a `sequential table` of all zones the `ent` is in.
        `nsz:InZoneCache(Entity/Player ent, string/table zoneFilter)` | Checks the cache for the `ent`. | Returns a `boolean` of whether or not the `ent` is in the `zoneFilter`.
        `nsz:KickFromZone(Entity/Player ent, string/table zoneFilter)` | Kicks the ent from any of the supplied zones in `zoneFilter`. | Returns `nil`
        (Internal) `nsz:GetZonesTable(Entity/Player ent)` | Gets the modifiable cache table for the `ent`. | Returns a `table` formatted as `table[zoneIdentifer] = timeEnteredZone`.


# Upcoming Changes
I'm planning on revisiting this in the near future and making a few changes. Once these changes are made, I'll update it on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2553024572).
* Address the bugs mentioned above.
* Add an alternative method for getting a zone ID for instances where the player can't get to the center to see it.
* In the `nsz:RegisterZone()` function, I want to add support for the first argument to just be a table with all the parameters in no particular order thanks to indexing.
* Add a variable for no pvp zones that will allow a player back into a zone if they haven't died since they left.
* Expand on `nsz_show_zones` debug GUI to give more information. Mainly how many props used AABB vs SAT detection.
* Add language support.
* Add a zone preview and even placing multiple zones before uploading to the server.
* I'd like to figure out a way to optimize nearby/intersecting zones by merging them with the feature above. This may be cut.
* For the steam workshop, figure out why the materials aren't sending to the client if the server isn't using this github repo.
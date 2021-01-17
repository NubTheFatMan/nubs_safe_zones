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
# Server Console Commands and Variables
* `nsz_prop_checks_per_tick <# props>` - How many props to check per server tick. Higher number = more lag, but faster detection
* `nsz_aabb_v_sat_sensitivity <sensitivity>` - Range of 0 to 90. This is the angle which determines whether to use AABB (Axis Aligned Bounding Box) detection or SAT (Separating Axis Theorem) detection. 0 = always use SAT (slow but accurate), 90 = always use AABB (fast with false positives)

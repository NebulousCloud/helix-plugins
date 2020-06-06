
local PLUGIN = PLUGIN

PLUGIN.name = "Better Crafting"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Adds a better crafting solution to helix."
PLUGIN.license = [[
Copyright 2020 wowm0d
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
]]
PLUGIN.readme = [[
Adds a better crafting solution to helix.
---
> The better crafting plugin is a fully featured and robust crafting system.
Recipes are put into the /recipes/ folder and crafting stations are put into the /stations/ folder.

When creating recipes you can add hooks to before and after any action, example:
```lua
RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "You need to be near a workbench."
end)
```
This will check for a unique crafting station within range called workbench - this hook is called after every other check inside OnCanCraft is made, if you want to hook this before OnCanCraft you would use PreHook instead of PostHook. This hooking feature allows you to literally do anything within your recipes. Available hooks are `"OnCanCraft", "OnCanSee", "OnCraft"` they all have the recipeTable and client as arguments.
Recipe Format:
```lua
RECIPE.name = "RecipeName"
RECIPE.description = "HoverDescription"
RECIPE.model = "UIDisplayModel"
RECIPE.category = "UICraftingCategory"
RECIPE.requirements = {
	["item_uniqueID"] = 1,
	["item_uniqueID"] = 2 -- number is amount required
}
RECIPE.results = {
	["item_uniqueID"] = 1,
	["item_uniqueID"] = {1, 2, 5}, -- table of amounts to choose from
	["item_uniqueID"] = {["min"] = 1, ["max"] = 10} -- table of min and max value
}
RECIPE.tools = {"item_uniqueID", "item_uniqueID"}
RECIPE.flag = "F" -- flag to restrict visibility and a requirement
```
Station Format:
```lua
STATION.name = "HoverName"
STATION.description = "HoverDescription"
STATION.model = "WorldModel"
```

## Preview
![Menu](https://i.imgur.com/UxzQ3kz.png)
If you like this plugin and want to see more consider getting me a coffee. https://ko-fi.com/wowm0d

Support for this plugin can be found here: https://discord.gg/mntpDMU
]]

ix.util.Include("cl_hooks.lua", "client")
ix.util.Include("sh_hooks.lua", "shared")

ix.util.Include("meta/sh_recipe.lua", "shared")
ix.util.Include("meta/sh_station.lua", "shared")

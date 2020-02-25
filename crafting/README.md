# Crafting
Crafting is a custom built from the ground up plugin designed for the Helix Framework, made by Alex Grist & Impulse for Garry's Mod.

## Credits
ZeMysticalTaco - Creation of the Plugin

Steam: www.steamcommunity.com/id/lemastersigh

# Documentation
To use the Crafting plugin, simply drag and drop into your schema's plugins folder, and open up the 'sh_plugin.lua' file to add recipes.

To add new items, either add the item normally using files or use the 'sh_items.lua' file, the default set of items are a very miniscule amount and may have little use for your purposes.

## Dependencies
This plugin depends on the netstream2 library, but does not come with it. If you experience errors, that is what you should try installing first.

## Schemas
This plugin SHOULD work for any Schema, if there are any innate compatibilities with any other Schema's it's down to the Schema author or you to fix them.

## Item Structure
```
ITEMS.refined_metal = {
	["name"] = "Refined Metal", --The name of the item.
	["model"] = "models/props_c17/canisterchunk02a.mdl", --The model of the item.
	["description"] = "A small chunk of refined metal, useless unless combined with other items.", --The description of the item.
	["width"] = 1, --The width of the item in your inventory.
	["height"] = 1, --The height of the item in your inventory.
	["chance"] = 10 --How many tickets the item will receive in the Item Spawner plugin, also released by me.
}
```

## Tools
Tools are like items however they will not be taken when using the recipe.
```
ITEMS.normal_screwdriver = {
	["name"] = "Screwdriver",
	["model"] = "models/props_c17/TrapPropeller_Lever.mdl",
	["description"] = "A full fledged screwdriver.",
	["width"] = 2,
	["height"] = 1,
	["chance"] = 20,
	["tool"] = true --This is what indicates the item as a tool.
}
```

## Recipe Structure
```
	["metal_downgrade_refined"] = {
		["name"] = "Breakdown: Refined Metal", -- The name of the recipe, I generally like to use the naming convention of 'type:item' since there is limited space.
		["model"] = "models/props_c17/canisterchunk02a.mdl", -- The model of the re cipe.
		["desc"] = "Break down Refined Metal into Reclaimed Metal.", --The description of the recipe.
		["requirements"] = {["refined_metal"] = 1, ["scrap_hammer"] = 1}, --Requirements of the item, the UNIQUE ID of the item goes here, not the NAME, the Unique ID will most likely be what the file is called, for instance sh_refined_metal.lua OR if you added it through the file, what you titled your entry, so if you titled it ITEMS.refined_metal it will be 'refined_metal'.
		["results"] = {["reclaimed_metal"] = 2}, --The results of the item.
		["category"] = "Metal Breakdown", --Future use, the category of the item.
	},
```

## Blueprints
Recipes have an optional argument called 'blueprint' which specifies if the player needs to learn it first. There are two 'charMeta' handles that allow you to give or remove a blueprint from a player, it's up to you to decide on how you want to give or remove a blueprint from someone.
	```char:RemoveBlueprint(blueprint)
	char:GiveBlueprint(blueprint)```

```
	["metal_downgrade_refined"] = {
		["name"] = "Breakdown: Refined Metal", -- The name of the recipe, I generally like to use the naming convention of 'type:item' since there is limited space.
		["model"] = "models/props_c17/canisterchunk02a.mdl", -- The model of the re cipe.
		["desc"] = "Break down Refined Metal into Reclaimed Metal.", --The description of the recipe.
		["requirements"] = {["refined_metal"] = 1, ["scrap_hammer"] = 1}, --Requirements of the item, the UNIQUE ID of the item goes here, not the NAME, the Unique ID will most likely be what the file is called, for instance sh_refined_metal.lua OR if you added it through the file, what you titled your entry, so if you titled it ITEMS.refined_metal it will be 'refined_metal'.
		["results"] = {["reclaimed_metal"] = 2}, --The results of the item.
		["category"] = "Metal Breakdown", --Future use, the category of the item.
		["blueprint"] = "refined_metal_downgrade" --This is what identifies it as needing a blueprint, the blueprint does not have to be unique and you can assign multiple items to a blueprint.
	},
```
## Attributes
The plugin comes with two attributes that are added automatically, Engineering and Gunsmithing, you can ALSO make a recipe REQUIRE attributes. Recipes will gradually increment engineering when crafted by default.

```
	["metal_upgrade_reclaimed"] = {
		["name"] = "Metal: Reclaimed Metal",
		["model"] = "models/props_c17/oildrumchunk01d.mdl",
		["desc"] = "Break down Refined Metal into Reclaimed Metal.",
		["requirements"] = {["scrap_metal"] = 3},
		["results"] = {["reclaimed_metal"] = 1},
		["category"] = "Metal Upgrade",
		["skill"] = {["eng"] = 1, ["guns"] = 5} --This is what identifies it as requiring attributes, use the ATTRIBUTE UNIQUE ID, which will be the name of the FILE, if it's sh_eng.lua then the ID is 'eng'.
	}
```

## Gunsmithing
Geared a little towards more traditional serious roleplay, Gunsmithing is an optional attribute you can add to an item, a recipe with the 'guns' indentation will increment gunsmithing as well.
```
	["metal_upgrade_reclaimed"] = {
		["name"] = "Metal: Reclaimed Metal",
		["model"] = "models/props_c17/oildrumchunk01d.mdl",
		["desc"] = "Break down Refined Metal into Reclaimed Metal.",
		["requirements"] = {["scrap_metal"] = 3},
		["results"] = {["reclaimed_metal"] = 1},
		["category"] = "Metal Upgrade",
		["guns"] = true --This is what identifies it as being a gunsmithing skill.
	}
```

There are future updates planned for this plugin to include support for entities and to include support for category based UI.
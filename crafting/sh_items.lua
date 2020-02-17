//To add a new item or remove an item, this is the file to do it.

local ITEMS = {}

ITEMS.scrap_metal = {
	["name"] = "Scrap Metal",
	["model"] = "models/props_debris/metal_panelchunk02d.mdl",
	["description"] = "A small chunk of scrap metal, useless unless combined with other items.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 75 --This is used for the 'item spawner plugin' this defines how many 'tickets' the item gets to spawn.
}

ITEMS.reclaimed_metal = {
	["name"] = "Reclaimed Metal",
	["model"] = "models/props_c17/oildrumchunk01d.mdl",
	["description"] = "A small chunk of reclaimed metal, useless unless combined with other items.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 25
}


ITEMS.refined_metal = {
	["name"] = "Refined Metal",
	["model"] = "models/props_c17/canisterchunk02a.mdl",
	["description"] = "A small chunk of refined metal, useless unless combined with other items.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 10
}

ITEMS.scrap_electronics = {
	["name"] = "Scrap Electronics",
	["model"] = "models/props_lab/reciever01c.mdl",
	["description"] = "A small assorted set of Electronics, useless unless broken down into individual components or combined with other items.",
	["width"] = 2,
	["height"] = 1,
	["chance"] = 45
}

ITEMS.refined_electronics = {
	["name"] = "Refined Electronics",
	["model"] = "models/props_lab/reciever01b.mdl",
	["description"] = "A small assorted set of Electronics, it's been refined to perfection.",
	["width"] = 2,
	["height"] = 1,
	["chance"] = 3
}

ITEMS.empty_carton_of_milk = {
	["name"] = "Empty Carton of Milk",
	["model"] = "models/props_junk/garbage_milkcarton002a.mdl",
	["description"] = "An empty carton of milk.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 60
}

ITEMS.empty_can = {
	["name"] = "Empty Can",
	["model"] = "models/props_junk/garbage_metalcan001a.mdl",
	["description"] = "An empty can.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 80
}

ITEMS.empty_glass_bottle = {
	["name"] = "Empty Glass Bottle",
	["model"] = "models/props_junk/garbage_glassbottle003a.mdl",
	["description"] = "An empty glass bottle.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 80
}

ITEMS.empty_paint_can = {
	["name"] = "Empty Paint Can",
	["model"] = "models/props_junk/metal_paintcan001b.mdl",
	["description"] = "An empty paint can.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 80
}

ITEMS.junk_newspaper = {
	["name"] = "Junk Newspaper",
	["model"] = "models/props_junk/garbage_newspaper001a.mdl",
	["description"] = "An old issue of the City Times, dated a couple years ago.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 80
}

ITEMS.empty_jar = {
	["name"] = "Empty Jar",
	["model"] = "models/props_lab/jar01b.mdl",
	["description"] = "An empty jar, looks like there was once some vitamin supplement inside.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 80
}

ITEMS.cardboard_scraps = {
	["name"] = "Cardboard Scraps",
	["model"] = "models/props_junk/garbage_carboard002a.mdl",
	["description"] = "Some scraps of cardboard.",
	["width"] = 2,
	["height"] = 1,
	["chance"] = 80
}

ITEMS.locker_door = {
	["name"] = "Locker Door",
	["model"] = "models/props_lab/lockerdoorleft.mdl",
	["description"] = "A simple locker door.",
	["width"] = 1,
	["height"] = 4,
	["chance"] = 1
}

ITEMS.cloth_scrap = {
	["name"] = "Cloth Scrap",
	["model"] = "models/props_debris/concrete_chunk04a.mdl",
	["description"] = "A set of scrap cloth.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 90
}

ITEMS.sewn_cloth = {
	["name"] = "Sewn Cloth",
	["model"] = "models/props_debris/concrete_chunk04a.mdl",
	["description"] = "A sewn set of cloth, useful for crafting clothing.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 10
}

ITEMS.battered_scrap = {
	["name"] = "Battered Scrap",
	["model"] = "models/props_debris/metal_panelchunk02d.mdl",
	["description"] = "A lower tier set of metal, useful to put together with scrap.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 85
}

ITEMS.burned_metal = {
	["name"] = "Charred Metal",
	["model"] = "models/props_debris/rebar001a_32.mdl",
	["description"] = "A useless chunk of burnt metal, flimsy and practically worthless.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 85
}

ITEMS.empty_ammo_box = {
	["name"] = "Empty Ammunition Case",
	["model"] = "models/Items/BoxSRounds.mdl",
	["description"] = "An empty box of used ammunition.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 75
}

ITEMS.bullet_casings = {
	["name"] = "Bullet Casings",
	["model"] = "models/Items/357ammobox.mdl",
	["description"] = "A set of bullet casings, used up",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 85
}

ITEMS.gunpowder = {
	["name"] = "Gunpowder",
	["model"] = "models/props_lab/box01a.mdl",
	["description"] = "Black powder as it's commonly called, gunpowder is one of the primary ingredients of weaponry.",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 45
}

ITEMS.scrap_screwdriver = {
	["name"] = "Scrap Screwdriver",
	["model"] = "models/props_c17/TrapPropeller_Lever.mdl",
	["description"] = "A screwdriver fashioned from scrap metal",
	["width"] = 1,
	["height"] = 1,
	["chance"] = 10
}

ITEMS.plank = {
	["name"] = "Plank",
	["model"] = "models/props_debris/wood_board06a.mdl",
	["description"] = "A wooden plank.",
	["width"] = 1,
	["height"] = 3,
	["chance"] = 80
}

ITEMS.wood_piece = {
	["name"] = "Wooden Piece",
	["model"] = "models/props_debris/wood_chunk02d.mdl",
	["description"] = "A piece of wood.",
	["width"] = 1,
	["height"] = 3,
	["chance"] = 80
}

ITEMS.scrap_hammer = {
	["name"] = "Scrap Hammer",
	["model"] = "models/props_interiors/pot02a.mdl",
	["description"] = "A weak scrap hammer devised of several tools.",
	["width"] = 1,
	["height"] = 2,
	["chance"] = 80
}

ITEMS.normal_screwdriver = {
	["name"] = "Screwdriver",
	["model"] = "models/props_c17/TrapPropeller_Lever.mdl",
	["description"] = "A full fledged screwdriver.",
	["width"] = 2,
	["height"] = 1,
	["chance"] = 20,
	["tool"] = true
}


for k, v in pairs(ITEMS) do
	local ITEM = ix.item.Register(k, nil, false, nil, true)
	ITEM.name = v.name
	ITEM.model = v.model
	ITEM.description = v.description
	ITEM.category = "Crafting"
	ITEM.width = v.width or 1
	ITEM.height = v.height or 1
	ITEM.chance = v.chance or 0
	ITEM.isTool = v.tool or false
end
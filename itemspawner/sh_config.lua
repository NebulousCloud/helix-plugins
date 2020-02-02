
local PLUGIN = PLUGIN

-- Item Spawner Toggle [On/Off]
ix.config.Add("spawnerActive", true, "Toggle the item spawner.", nil, {
	category = "Item Spawner"
})

-- Item Minimum Respawn
ix.config.Add("spawnerOffsetTime", 60, "The range of item spawns around the timer.", nil, {
	category = "Item Spawner",
	data = { min = 0, max = 999 }
})

-- Item Minimum Respawn
ix.config.Add("spawnerRespawnTime", 600, "Time for an item to spawn at any position.", nil, {
	category = "Item Spawner",
	data = { min = 1, max = 999 }
})

ix.config.Add("spawnerRareItemChance", 10, "Percentage chance of spawning a rare item.", nil, {
	category = "Item Spawner",
	data = { min = 0, max = 100 }
})

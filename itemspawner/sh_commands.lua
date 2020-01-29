
local PLUGIN = PLUGIN

ix.command.Add("ItemSpawnerAdd", {
	description = "@cmdItemSpawnerAdd",
	arguments = {
		ix.type.string
	},
	OnCheckAccess = function(self, client)
		return ix.config.Get("spawnerActive", false) and client:IsSuperAdmin()
	end,
	OnRun = function(self, client, title)

		local location = client:GetEyeTrace().HitPos
		location.z = location.z + 10

		local complete = PLUGIN:AddSpawner(client, location, title)

		return complete and "success" or "error"
	end
})

ix.command.Add("ItemSpawnerRemove", {
	description = "@cmdItemSpawnerRemove",
	arguments = {
		ix.type.string
	},
	OnCheckAccess = function(self, client)
		return ix.config.Get("spawnerActive", false) and client:IsSuperAdmin()
	end,
	OnRun = function(self, client, title)
		PLUGIN:RemoveSpawner(client, title)
	end
})

ix.command.Add("ItemSpawnerList", {
	description = "@cmdItemSpawnerList",
	superAdminOnly = true,
	OnRun = function(self, client, title)
		if (#PLUGIN.spawner.positions == 0) then
			return "@cmdNoSpawnPoints"
		end
		net.Start("ixItemSpawnerManager")
			net.WriteTable(PLUGIN.spawner.positions)
		net.Send(client)
	end
})

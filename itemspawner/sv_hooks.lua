
local PLUGIN = PLUGIN

util.AddNetworkString("ixItemSpawnerManager")
util.AddNetworkString("ixItemSpawnerDelete")
util.AddNetworkString("ixItemSpawnerEdit")
util.AddNetworkString("ixItemSpawnerGoto")
util.AddNetworkString("ixItemSpawnerSpawn")
util.AddNetworkString("ixItemSpawnerChanges")

function PLUGIN:LoadData()
	PLUGIN.spawner = self:GetData() or {}
end

function PLUGIN:SaveData()
	self:SetData(PLUGIN.spawner)
end

function PLUGIN:ForceSpawn(client, spawner)
	if !(client:IsSuperAdmin()) then return end
	spawner.lastSpawned = os.time()
	local rareChance = math.random(100)
	if (rareChance > tonumber(spawner.rarity)) then
		ix.item.Spawn(table.Random(PLUGIN.items.common), spawner.position)
	else
		ix.item.Spawn(table.Random(PLUGIN.items.rare), spawner.position)
	end
end

net.Receive("ixItemSpawnerDelete", function(length, client)
	if !(client:IsSuperAdmin()) then return end

	local item = net.ReadString()
	PLUGIN:RemoveSpawner(client, item)
end)

net.Receive("ixItemSpawnerGoto", function(length, client)
	if !(client:IsSuperAdmin()) then return end

	local position = net.ReadVector()
	client:SetPos(position)
end)

net.Receive("ixItemSpawnerSpawn", function(length, client)
	local item = net.ReadTable()
	PLUGIN:ForceSpawn(client, item)
end)

net.Receive("ixItemSpawnerChanges", function(length, client)
	if !(client:IsSuperAdmin()) then return end

	local changes = net.ReadTable()

	for k, v in ipairs(PLUGIN.spawner.positions) do
		if (v.ID == changes[1]) then
			v.title = changes[2]
			v.delay = math.Clamp(changes[3], 1, 10000)
			v.rarity  = math.Clamp(changes[4] 0, 100)
		end
	end

end)

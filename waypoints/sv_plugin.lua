
local PLUGIN = PLUGIN

PLUGIN.waypoints = {}

util.AddNetworkString("SetupWaypoints")
util.AddNetworkString("UpdateWaypoint")

function PLUGIN:GetPlayers()
	local players = {}

	for _, client in ipairs(player.GetAll()) do
		local faction = ix.faction.Get(client:Team())

		if (faction and faction.canSeeWaypoints) then
			players[#players + 1] = client
		end
	end

	return players
end

function PLUGIN:RemoveWaypoints()
	self.waypoints = {}

	net.Start("SetupWaypoints")
		net.WriteBool(false)
	net.Send(self:GetPlayers())
end

function PLUGIN:UpdateWaypoint(index, newValue)
	if (newValue == nil) then
		table.remove(self.waypoints, index)

		net.Start("SetupWaypoints")
			net.WriteBool(true)
			net.WriteTable(self.waypoints)
		net.Send(self:GetPlayers())
	else
		self.waypoints[index] = newValue

		net.Start("UpdateWaypoint")
			net.WriteTable({index, newValue})
		net.Send(self:GetPlayers())
	end
end

function PLUGIN:AddWaypoint(waypoint)
	local index = table.insert(self.waypoints, waypoint)

	net.Start("UpdateWaypoint")
		net.WriteTable({index, waypoint})
	net.Send(self:GetPlayers())
end

PLUGIN.colors = {
	["white"] = Color(255, 255, 255),
	["blue"] = Color(0, 114, 188),
	["purple"] = Color(102, 51, 153),
	["red"] = Color(255, 0, 0),
	["maroon"] = Color(103, 0, 42),
	["orange"] = Color(255, 122, 0),
	["yellow"] = Color(255, 222, 0),
	["green"] = Color(38, 106, 46),
	["black"] = Color(0, 0, 0),
	["grey"] = Color(81, 81, 81),
	["gray"] = Color(81, 81, 81),
}

function PLUGIN:GetWaypointColor(colorName)
	return self.colors[colorName]
end

function PLUGIN:ListColors()
	local colors = {}

	for k, v in pairs(self.colors) do
		colors[#colors + 1] = k
	end

	return table.concat(colors, ", ")
end

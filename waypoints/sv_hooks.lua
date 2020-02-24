
local PLUGIN = PLUGIN

PLUGIN.waypointThink = 0

function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	local faction = ix.faction.Get(character:GetFaction())

	if (faction.canSeeWaypoints) then
		net.Start("SetupWaypoints")
			net.WriteBool(true)
			net.WriteTable(self.waypoints)
		net.Send(client)
	else
		net.Start("SetupWaypoints")
			net.WriteBool(false)
		net.Send(client)
	end
end

function PLUGIN:Think()
	local curTime = CurTime()

	if (self.waypointThink < curTime) then
		self.waypointThink = curTime + 60

		local toRemove = {}

		for k, waypoint in pairs(self.waypoints) do
			if (waypoint.time < curTime) then
				table.insert(toRemove, k)
			end
		end

		if (#toRemove > 0) then
			table.sort(toRemove)

			for i = #toRemove, 1, -1 do
				table.remove(self.waypoints, toRemove[i])
			end

			net.Start("SetupWaypoints")
				net.WriteBool(true)
				net.WriteTable(self.waypoints)
			net.Send(self:GetPlayers())
		end
	end
end

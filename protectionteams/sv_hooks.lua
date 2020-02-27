
local PLUGIN = PLUGIN

function PLUGIN:Tick()
	local curTime = CurTime()

	if (!self.tick or self.tick < curTime) then
		self.tick = curTime + 30

		for index, teamTbl in pairs(self.teams) do
			if (table.IsEmpty(teamTbl["members"])) then
				self:DeleteTeam(index)
			end
		end
	end
end

function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
	if (character:IsCombine()) then
		net.Start("ixPTSync")
			net.WriteBool(true)
			net.WriteTable(self.teams)
		net.Send(client)
	else
		if (client.curTeam) then
			self:LeaveTeam(client)
		end

		net.Start("ixPTSync")
			net.WriteBool(false)
		net.Send(client)
	end
end

function PLUGIN:PlayerDisconnected(client)
	if (client.curTeam) then
		self:LeaveTeam(client)
	end
end

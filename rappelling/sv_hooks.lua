
local PLUGIN = PLUGIN

function PLUGIN:OnPlayerObserve(client, state)
	if (client.rappelling) then
		self:EndRappel(client)
	end
end

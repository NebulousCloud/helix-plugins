
local PLUGIN = PLUGIN

function PLUGIN:CharacterLoaded(character)
	local client = character:GetPlayer()

	if (IsValid(client)) then
		local uniqueID = "ixAntiAFK"..client:SteamID64()

		timer.Create(uniqueID, ix.config.Get("afkTime"), 0, function()
			if (IsValid(client) and client:GetCharacter()) then
				PLUGIN:Update(client)
			else
				timer.Remove(uniqueID)
			end
		end)
	end
end

function PLUGIN:CanPlayerEarnSalary(client, faction)
	if (client.isAFK) then
		return false
	end
end

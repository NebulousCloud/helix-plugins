
local PLUGIN = PLUGIN

function PLUGIN:GetPlayerDeathSound(client)
	if (client:Team() == FACTION_OTA) then
		local sound = "NPC_CombineS.ElectrocuteScream"

		for k, v in ipairs(player.GetAll()) do
			if (v:IsCombine()) then
				v:EmitSound(sound)
			end
		end

		return sound
	end
end

function PLUGIN:GetPlayerPainSound(client)
	if (client:Team() == FACTION_OTA) then
		return "npc/combine_soldier/pain"..math.random(1, 3)..".wav";
	end
end

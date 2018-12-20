
local PLUGIN = PLUGIN

PLUGIN.name = "Localized damage"
PLUGIN.author = "Subleader"
PLUGIN.description = "Damage are different depending on which limb is being hurt."

ix.config.Add("localizedDamage", true, "Activate the Localized Damage.", nil, {
	category = "Localized damage"
})

ix.config.Add("legBreakDuration", 10, "Set the time that a leg remains broken.", nil, {
	data = {min = 0, max = 300, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("HeadScaleDamage", 3, "How much should head damage be scaled by?", nil, {
	data = {min = 0, max = 10, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("ArmsScaleDamage", 0.4, "How much should arms damage be scaled by?", nil, {
	data = {min = 0, max = 10, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("LegsScaleDamage", 0.5, "How much should legs damage be scaled by?", nil, {
	data = {min = 0, max = 10, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("StomachScaleDamage", 0.8, "How much should stomach damage be scaled by?", nil, {
	data = {min = 0, max = 10, decimals = 1},
	category = "Localized damage"
})

local function LegBreak(client, duration)
	local runSpeed = client:GetRunSpeed()
	local walkSpeed = client:GetWalkSpeed()

	if (!client.ixLegshot) then
		client.ixLegshot = true
		client:SetRunSpeed(runSpeed / 3)
		client:SetWalkSpeed(walkSpeed / 3)

		timer.Simple(duration, function()
			client:SetRunSpeed(runSpeed)
			client:SetWalkSpeed(walkSpeed)
			client.ixLegshot = false
		end)
	end
end

function PLUGIN:ScalePlayerDamage(client, hitgroup, dmginfo)
	if (ix.config.Get("localizedDamage")) then
		if (hitgroup == HITGROUP_STOMACH) then
			dmginfo:ScaleDamage(ix.config.Get("StomachScaleDamage", 0.8))
		elseif ((hitgroup == HITGROUP_LEFTARM) or (hitgroup == HITGROUP_RIGHTARM)) then
			dmginfo:ScaleDamage(ix.config.Get("ArmsScaleDamage", 0.4))
		end

		if (client:GetNetVar("resistance")) then -- This is for another plugin I will upload when I have time
			if (hitgroup == HITGROUP_HEAD) then
				dmginfo:ScaleDamage(ix.config.Get("HeadScaleDamage", 3) / 2)
			elseif ((hitgroup == HITGROUP_LEFTLEG) or (hitgroup == HITGROUP_RIGHTLEG)) then
				dmginfo:ScaleDamage(ix.config.Get("LegsScaleDamage", 0.5))
				LegBreak(client, ix.config.Get("legBreakDuration", 10) / 3)
			end
		elseif (hitgroup == HITGROUP_HEAD) then
			dmginfo:ScaleDamage(ix.config.Get("HeadScaleDamage", 3))
		elseif ((hitgroup == HITGROUP_LEFTLEG) or (hitgroup == HITGROUP_RIGHTLEG)) then
			dmginfo:ScaleDamage(ix.config.Get("LegsScaleDamage", 0.5))
			LegBreak(client, ix.config.Get("legBreakDuration", 10))
		end
	end
end

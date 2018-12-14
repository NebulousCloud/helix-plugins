local PLUGIN = PLUGIN
PLUGIN.name = "Localized damage"
PLUGIN.author = "Subleader"
PLUGIN.description = "Damage are different depending on which limb is being hurt."

ix.config.Add("localizedDamage", true, "Activate the Localized Damage.", nil, {
	category = "Localized damage"
})

ix.config.Add("legBreakDuration", 10, "Set the time that a leg remains broken.", nil, {
	data = {min = 0, max = 300.0, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("HeadScaleDamage", 3, "How much should head damage be scaled by?", nil, {
	data = {min = 0, max = 10.0, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("ArmsScaleDamage", 0.4, "How much should arms damage be scaled by?", nil, {
	data = {min = 0, max = 10.0, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("LegsScaleDamage", 0.5, "How much should legs damage be scaled by?", nil, {
	data = {min = 0, max = 10.0, decimals = 1},
	category = "Localized damage"
})

ix.config.Add("StomachScaleDamage", 0.8, "How much should stomach damage be scaled by?", nil, {
	data = {min = 0, max = 10.0, decimals = 1},
	category = "Localized damage"
})

function LegBreak(ply,duration)
	if !RUNSPEED and !WALKSPEED then
		RUNSPEED = ply:GetRunSpeed()
		WALKSPEED = ply:GetWalkSpeed()
	end

	if !ply.legshot then
		ply.legshot = true
		ply:SetRunSpeed(RUNSPEED/3)
		ply:SetWalkSpeed(WALKSPEED/3)
		timer.Simple(duration,function() ply:SetRunSpeed(RUNSPEED) ply:SetWalkSpeed(WALKSPEED) ply.legshot = false end)
	end
end

function PLUGIN:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if (ix.config.Get("localizedDamage")) then
		if ( hitgroup == HITGROUP_STOMACH ) then
			dmginfo:ScaleDamage( ix.config.Get("StomachScaleDamage", 0.8 ) )
		elseif ( hitgroup == HITGROUP_LEFTARM ) or ( hitgroup == HITGROUP_RIGHTARM ) then
			dmginfo:ScaleDamage( ix.config.Get("ArmsScaleDamage", 0.4) )
		end
		if ( ply:GetNetVar("resistance") == true ) then -- This is for another plugin I will upload when I have time
			if ( hitgroup == HITGROUP_HEAD ) then
				dmginfo:ScaleDamage( ix.config.Get("HeadScaleDamage", 3)/2 )
			elseif ( hitgroup == HITGROUP_LEFTLEG ) or ( hitgroup == HITGROUP_RIGHTLEG ) then
				dmginfo:ScaleDamage( ix.config.Get("LegsScaleDamage", 0.5) )
				LegBreak( ply, ix.config.Get("legBreakDuration", 10)/3 )
			end
		elseif ( hitgroup == HITGROUP_HEAD ) then
			dmginfo:ScaleDamage( ix.config.Get("HeadScaleDamage", 3) )
		elseif ( hitgroup == HITGROUP_LEFTLEG ) or ( hitgroup == HITGROUP_RIGHTLEG ) then
			dmginfo:ScaleDamage( ix.config.Get("LegsScaleDamage", 0.5) )
			LegBreak( ply, ix.config.Get("legBreakDuration", 10) )
		end
	end
end
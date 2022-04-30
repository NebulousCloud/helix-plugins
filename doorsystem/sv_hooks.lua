local PLUGIN = PLUGIN

local function opendoor(ply, door)
	if ( door:GetClass() == "func_door" ) then
		for k, v in pairs(PLUGIN.doors) do
			for m, a in pairs(v) do
				for _, access in pairs(PLUGIN.access) do
					if ( a.access == _ ) then
						local snd = access.snd
					end
				end
			end
		end
		
		ply:SetAction("Opening...", 0.5)
		ply:DoStaredAction(door, function()
			door:Fire("open")
			if ( snd ) then
				door:EmitSound(snd)
			end
		end, 0.5)
	end
end

local function debug(door)
	for k, v in pairs(PLUGIN.doors) do 
		if ( game.GetMap() == k ) then
			print('correct map')
		end
		
		for m, a in pairs(v) do
			if ( k == door:MapCreationID() ) then
				print('correct door')
			end
		end
	end
end 

function PLUGIN:PlayerUseDoor( ply, door )
	if ( ply:IsCombine() ) then
		debug(door)
		for k, v in pairs(PLUGIN.doors) do
			if ( game.GetMap() == k ) then
				for _, a in pairs(v) do
					if ( door:MapCreationID() == a.id ) then
						for _, access in pairs(PLUGIN.access) do
							if ( a.access == _ ) then
								if ( access.checkAccess(ply) ) then
									opendoor(ply, door)
								else
									if ( door:GetClass() == "func_door" ) then
										door:EmitSound("buttons/combine_button_locked.wav")
									end
									ply:ChatNotify("You are not allowed to open this door.")
									return
								end
							end
						end
					else
						print("Door - " .. door:MapCreationID() .. " does not have a setup ID")
					end
				end
			end
		end
	end
end
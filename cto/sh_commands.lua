
local PLUGIN = PLUGIN

do
	local COMMAND = {}
	COMMAND.description = "Remotely disable a Combine camera - IDs are shown on the HUD."
	COMMAND.arguments = {
		ix.type.number
	}

	function COMMAND:OnRun(client, ID)
		local camera = Entity(ID)

		if (!IsEntity(camera) or camera:GetClass() != "npc_combine_camera") then
			client:Notify("There is no Combine camera with that ID!")

			return
		end

		if (camera:GetSequenceName(camera:GetSequence()) != "idlealert") then
			client:Notify("That camera is already disabled!")

			return
		end

		client:Notify("Disabling C-i" .. camera:EntIndex() .. "...")

		camera:Fire("Disable")
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsCombine() and (Schema:IsCombineRank(client:Name(), "SCN") or Schema:IsCombineRank(client:Name(), "OfC") or Schema:IsCombineRank(client:Name(), "EpU") or Schema:IsCombineRank(client:Name(), "DvL") or Schema:IsCombineRank(client:Name(), "SeC") or client:Team() == FACTION_OTA)
	end

	ix.command.Add("CameraDisable", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Remotely enable a Combine camera - IDs are shown on the HUD."
	COMMAND.arguments = {
		ix.type.number
	}

	function COMMAND:OnRun(client, ID)
		local camera = Entity(ID)

		if (!IsEntity(camera) or camera:GetClass() != "npc_combine_camera") then
			client:Notify("There is no Combine camera with that ID!")

			return
		end

		if (camera:GetSequenceName(camera:GetSequence()) != "idle") then
			client:Notify("That camera is already enabled!")

			return
		end

		client:Notify("Enabling C-i" .. camera:EntIndex() .. "...")

		camera:Fire("Enable")
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsCombine() and (Schema:IsCombineRank(client:Name(), "SCN") or Schema:IsCombineRank(client:Name(), "OfC") or Schema:IsCombineRank(client:Name(), "EpU") or Schema:IsCombineRank(client:Name(), "DvL") or Schema:IsCombineRank(client:Name(), "SeC") or client:Team() == FACTION_OTA)
	end

	ix.command.Add("CameraEnable", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Update the sociostability status of the city."
	COMMAND.arguments = {
		ix.type.string
	}
	COMMAND.argumentNames = {"Socio-Status (green | blue | yellow | red | black)"}

	function COMMAND:OnRun(client, socioStatus)
		local tryingFor = string.upper(socioStatus)

		if (!PLUGIN.sociostatusColors[tryingFor]) then
			client:Notify("That is not a valid sociostatus!")
		else
			local players = {}

			local pitches = {
				BLUE = 95,
				YELLOW = 90,
				RED = 85,
				BLACK = 80
			}

			local pitch = pitches[tryingFor] or 100
		
			for k, v in ipairs(player.GetAll()) do
				if (v:IsCombine() and !v:GetNetVar("IsBiosignalGone", false)) then
					players[#players + 1] = v

					timer.Simple(k / 4, function()
						if (IsValid(v)) then
							v:EmitSound("npc/roller/code2.wav", 75, pitch)
						end
					end)
				end
			end

			PLUGIN.socioStatus = tryingFor

			Schema:AddCombineDisplayMessage("ALERT! Sociostatus updated to " .. tryingFor .. "!", PLUGIN.sociostatusColors[tryingFor])
			
			net.Start("RecalculateHUDObjectives")
				net.WriteString(PLUGIN.socioStatus)
				net.WriteTable(Schema.CombineObjectives)
			net.Send(players)
		end
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsCombine() and (Schema:IsCombineRank(client:Name(), "SCN") or Schema:IsCombineRank(client:Name(), "OfC") or Schema:IsCombineRank(client:Name(), "EpU") or Schema:IsCombineRank(client:Name(), "DvL") or Schema:IsCombineRank(client:Name(), "SeC") or client:Team() == FACTION_OTA)
	end

	ix.command.Add("SetSocioStatus", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Turn your biosignal on or off. Will alert all other units."
	COMMAND.arguments = {
		ix.type.bool
	}

	function COMMAND:OnRun(client, bEnable)
		local result = PLUGIN:SetPlayerBiosignal(client, bEnable)

		if (result == PLUGIN.ERROR_ALREADY_ENABLED) then
			client:Notify("Your biosignal is already enabled!")
		elseif (result == PLUGIN.ERROR_ALREADY_DISABLED) then
			client:Notify("Your biosignal is already disabled!")
		end
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsCombine() and ix.config.Get("useBiosignalSystem")
	end

	ix.command.Add("SetBiosignalStatus", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Turn a character's biosignal on or off. Will alert other units."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.bool
	}

	function COMMAND:OnRun(client, target, bEnable)
		local result = PLUGIN:SetPlayerBiosignal(target, bEnable)
	
		if (result == PLUGIN.ERROR_NOT_COMBINE) then
			client:Notify(target:Name() .. " is not the Combine!")
		elseif (result == PLUGIN.ERROR_ALREADY_ENABLED) then
			client:Notify(target:Name() .. "'s biosignal is already enabled!")
		elseif (result == PLUGIN.ERROR_ALREADY_DISABLED) then
			client:Notify(target:Name() .. "'s biosignal is already disabled!")
		else
			client:Notify("You have " .. (bEnable and "enabled" or "disabled") .. " " .. target:Name() .. "'s biosignal.")
		end
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsAdmin() and ix.config.Get("useBiosignalSystem")
	end

	ix.command.Add("CharSetBiosignalStatus", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Set whether a Citizen has CID tags on their clothes."
	COMMAND.arguments = {
		ix.type.player,
		ix.type.bool
	}

	function COMMAND:OnRun(client, target, hasTags)
		if (hasTags and !target:GetCharacter():GetData("IsCIDTagGone")) then
			client:Notify(target:Name() .. " already has CID tags!")
		elseif (!hasTags and target:GetCharacter():GetData("IsCIDTagGone")) then
			client:Notify(target:Name() .. " already has no CID tags!")
		else
			client:GetCharacter():SetData("IsCIDTagGone", !hasTags)

			client:Notify("You have " .. (hasTags and "added" or "removed") .. " " .. target:Name() .. "'s CID tags.")
		end
	end

	function COMMAND:OnCheckAccess(client)
		return client:IsAdmin() and ix.config.Get("useTagSystem")
	end

	ix.command.Add("CharSetHasTags", COMMAND)
end

do
	local COMMAND = {}
	COMMAND.description = "Request assistance from Civil Protection."
	COMMAND.arguments = ix.type.text

	function COMMAND:OnRun(client, message)
		local character = client:GetCharacter()
		local inventory = character:GetInventory()

		if (inventory:HasItem("request_device") or client:IsCombine() or client:Team() == FACTION_ADMIN) then
			if (!client:IsRestricted()) then
				Schema:AddCombineDisplayMessage("@cRequest")

				PLUGIN:DispatchRequestSignal(client, message)

				ix.chat.Send(client, "request", message)
				ix.chat.Send(client, "request_eavesdrop", message)
			else
				return "@notNow"
			end
		else
			return "@needRequestDevice"
		end
	end

	ix.command.Add("Request", COMMAND)
end

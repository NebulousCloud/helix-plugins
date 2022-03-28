
local PLUGIN = PLUGIN

PLUGIN.cameraData = PLUGIN.cameraData or {}
PLUGIN.fixedCameras = PLUGIN.fixedCameras or false
PLUGIN.outputEntity = PLUGIN.outputEntity or nil
PLUGIN.socioStatus = PLUGIN.socioStatus or "GREEN"

util.AddNetworkString("UpdateBiosignalCameraData")
util.AddNetworkString("RecalculateHUDObjectives")
util.AddNetworkString("CombineRequestSignal")

function PLUGIN:SafelyPrepareCamera(combineCamera)
	if (!IsValid(self.outputEntity)) then
		self.outputEntity = ents.Create("base_entity")
		self.outputEntity:SetName("__ixCTOhook")

		function self.outputEntity:AcceptInput(inputName, activator, called, data)
			if (data == "OnFoundPlayer") then
				PLUGIN:CombineCameraFoundPlayer(called, activator)
			end
		end

		self.outputEntity:Spawn()
		self.outputEntity:Activate()
	end

	combineCamera:Fire("addoutput", "OnFoundPlayer __ixCTOhook:PLUGIN:OnFoundPlayer:0:-1")
	self.cameraData[combineCamera] = {}
end

function PLUGIN:CombineCameraFoundPlayer(combineCamera, client)
	if (self.cameraData[combineCamera] and client:GetMoveType() != MOVETYPE_NOCLIP) then
		if (!self.cameraData[combineCamera][client]) then
			self.cameraData[combineCamera][client] = {}
		end
	end
end

function PLUGIN:DoPostBiosignalLoss(client)
	client:SetNetVar("IsBiosignalGone", true)

	local location = client:GetArea() != "" and client:GetArea() or "unknown location"
	local digits = string.match(client:Name(), "%d%d%d%d?%d?") or 0

	-- Alert all other units.
	Schema:AddCombineDisplayMessage("Downloading lost biosignal...", Color(255, 255, 255, 255))
	Schema:AddCombineDisplayMessage("WARNING! Biosignal lost for protection team unit " .. digits .. " at " .. location .. "...", Color(255, 0, 0, 255))

	local soundQueue = {
		"npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav",
		"npc/overwatch/radiovoice/lostbiosignalforunit.wav"
	}

	if (digits) then
		local englishDigits = {
			["0"] = "zero",
			["1"] = "one",
			["2"] = "two",
			["3"] = "three",
			["4"] = "four",
			["5"] = "five",
			["6"] = "six",
			["7"] = "seven",
			["8"] = "eight",
			["9"] = "nine"
		}

		for i = 1, string.len(digits) do
			local voNum = englishDigits[string.sub(digits, i, i)]

			soundQueue[#soundQueue + 1] = "npc/overwatch/radiovoice/" .. voNum .. ".wav"
		end

		soundQueue[#soundQueue + 1] = "npc/overwatch/radiovoice/remainingunitscontain.wav"
		soundQueue[#soundQueue + 1] = "npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"

		for _, player in ipairs(player.GetAll()) do
			if (player:IsCombine() and player != client and !player:GetNetVar("IsBiosignalGone")) then
				ix.util.EmitQueuedSounds(player, soundQueue)
			end
		end
	end
end

function PLUGIN:SetPlayerBiosignal(client, bEnable)
	if (client:IsCombine()) then
		local isDisabledAlready = client:GetNetVar("IsBiosignalGone")

		if (bEnable and !isDisabledAlready) then
			return self.ERROR_ALREADY_ENABLED
		elseif (!bEnable and isDisabledAlready) then
			return self.ERROR_ALREADY_DISABLED
		else
			if (bEnable) then
				client:SetNetVar("IsBiosignalGone", false)

				local location = client:GetArea() != "" and client:GetArea() or "unknown location"

				client:AddCombineDisplayMessage("Connection restored...", Color(0, 255, 0, 255)) -- Alert this unit.

				local digits = string.match(client:Name(), "%d%d%d%d?%d?") or 0

				-- Alert all units.
				Schema:AddCombineDisplayMessage("Downloading found biosignal...", Color(255, 255, 255, 255))
				Schema:AddCombineDisplayMessage("ALERT! Noncohesive biosignal found for protection team unit " .. digits.." at " .. location .. "...", Color(0, 255, 0, 255))

				local soundQueue = {
					"npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav",
					"npc/overwatch/radiovoice/engagingteamisnoncohesive.wav",
					"npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"
				}

				for _, player in ipairs(player.GetAll()) do
					if (player:IsCombine() and !player:GetNetVar("IsBiosignalGone")) then
						ix.util.EmitQueuedSounds(player, soundQueue)
					end
				end
			else
				client:AddCombineDisplayMessage("ERROR! Shutting down...", Color(255, 0, 0, 255)) -- Alert this unit.

				self:DoPostBiosignalLoss(client)
			end

			return self.ERROR_NONE
		end
	else
		return self.ERROR_NOT_COMBINE
	end
end

function PLUGIN:DispatchRequestSignal(client, text)
	local players = {}
	local soundQueue = {
		"npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav",
		"npc/overwatch/radiovoice/allteamsrespondcode3.wav",
		"npc/metropolice/vo/off" .. math.random(1, 4) .. ".wav"
	}

	for _, player in ipairs(player.GetAll()) do
		if (player:IsCombine() and !player:GetNetVar("IsBiosignalGone")) then
			players[#players + 1] = player

			ix.util.EmitQueuedSounds(player, soundQueue)
		end
	end

	net.Start("CombineRequestSignal")
		net.WriteEntity(client)
		net.WriteString(text)
	net.Send(players)

	Schema:AddCombineDisplayMessage("Assistance request received...", Color(175, 125, 100, 255))
end


local PLUGIN = PLUGIN

PLUGIN.biosignalLocations = PLUGIN.biosignalLocations or {}
PLUGIN.requestLocations = PLUGIN.requestLocations or {}

PLUGIN.cameraData = PLUGIN.cameraData or {}
PLUGIN.hudObjectives = PLUGIN.hudObjectives or {}
PLUGIN.socioStatus = PLUGIN.socioStatus or "GREEN"

PLUGIN.terminalMaterialIdx = PLUGIN.terminalMaterialIdx or 0
PLUGIN.terminalsToDraw = PLUGIN.terminalsToDraw or {}

function PLUGIN:UpdateBiosignalLocations()
	local curTime = CurTime()
	local client = LocalPlayer()

	-- Clear expired requests.
	for i, data in ipairs(self.requestLocations) do
		if (curTime - data.time >= ix.config.Get("expireRequests")) then
			self.requestLocations[i] = nil
		end
	end

	-- Clear active biosignals and expired lost biosignals.
	for unit, data in pairs(self.biosignalLocations) do
		if (!IsValid(unit) or !unit:IsCombine() or (!client:GetNetVar("IsBiosignalGone") and !unit:GetNetVar("IsBiosignalGone")) or curTime - data.time >= 120) then
			self.biosignalLocations[unit] = nil
		end
		
		data.isLost = true
	end

	-- Add active biosignals, update camera data.
	if (!client:GetNetVar("IsBiosignalGone", false)) then
		for _, v in pairs(player.GetAll()) do
			if (v:IsCombine() and v != client and !v:GetNetVar("IsBiosignalGone", false) and v:Alive()) then
				local physBone = v:LookupBone("ValveBiped.Bip01_Head1")
				local position = nil

				if (physBone) then
					local bonePosition = v:GetBonePosition(physBone)

					if (bonePosition) then
						position = bonePosition + Vector(0, 0, 16)
					end
				else
					position = v:GetPos() + Vector(0, 0, 80)
				end

				self.biosignalLocations[v] = {
					pos = position,
					time = curTime,
					isLost = false,
					isKnockedOut = v:GetLocalVar("ragdoll"),
					digits = string.match(v:Name(), "%d%d%d%d?%d?") or "???"
				}
			end
		end
	end
end

net.Receive("CombineRequestSignal", function()
	local client = net.ReadEntity()
	local text = net.ReadString()

	if (IsValid(client)) then
		local physBone = client:LookupBone("ValveBiped.Bip01_Head1")
		local position = nil

		if (physBone) then
			local bonePosition = client:GetBonePosition(physBone)

			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 16)
			end
		else
			position = client:GetPos() + Vector(0, 0, 80)
		end

		table.insert(PLUGIN.requestLocations, {
			time = CurTime(),
			pos = position,
			text = text
		})
	end
end)

net.Receive("UpdateBiosignalCameraData", function()
	local data = net.ReadTable()
	local newCameraData = {}
	
	for entIndex, players in pairs(data) do
		local combineCamera = Entity(entIndex)
		
		if (IsValid(combineCamera)) then
			newCameraData[combineCamera] = players
		end
	end
	
	PLUGIN.cameraData = newCameraData
end)

net.Receive("RecalculateHUDObjectives", function()
	local status = net.ReadString()
	local objectives = net.ReadTable()
	local lines = {}

	if (status) then
		PLUGIN.socioStatus = status
	end

	if (objectives and objectives.text) then
		for k, v in pairs(string.Split(objectives.text, "\n")) do
			if (string.StartWith(v, "^")) then
				table.insert(lines, "<:: " .. string.sub(v, 2) .. " ::>")
			end
		end

		PLUGIN.hudObjectives = lines
	end

	PLUGIN:UpdateBiosignalLocations()
end)

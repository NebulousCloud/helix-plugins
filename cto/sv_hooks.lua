
local PLUGIN = PLUGIN

-- Yuck. No wonder Clockwork had low FPS, with plugins like these.
function PLUGIN:Tick()
	local curTime = CurTime()
	local networkedCameraData = {}
	
	if (!self.nextCameraTick or curTime >= self.nextCameraTick) then
		for combineCamera, data in pairs(self.cameraData) do
			if (!IsValid(combineCamera)) then
				self.cameraData[combineCamera] = nil
			elseif (self:isCameraEnabled(combineCamera)) then
				local camPos = combineCamera:GetPos()

				for client, _ in pairs(data) do
					if (!IsValid(client)) then
						data[client] = nil
					else
						if (camPos:Distance(client:GetPos()) > 450 or !combineCamera:IsLineOfSightClear(client)) then
							data[client] = nil
						elseif (#data[client] < 1) then
							local violations = {}
							local walkSpeed = ix.config.Get("walkSpeed")
							if (client:KeyDown(IN_SPEED) and client:GetVelocity():LengthSqr() >= (walkSpeed * walkSpeed)) then
								violations[#violations + 1] = self.VIOLATION_RUNNING
							end
							
							if (!client:OnGround() and client:WaterLevel() <= 0) then
								violations[#violations + 1] = self.VIOLATION_JUMPING
							end

							if (client:Crouching()) then
								violations[#violations + 1] = self.VIOLATION_CROUCHING
							end

							if (client:GetLocalVar("ragdoll")) then
								violations[#violations + 1] = self.VIOLATION_FALLEN_OVER
							end

							if (#violations > 0) then
								if (!client:IsCombine() and !client:GetNetVar("IsBiosignalGone")) then
									data[client] = violations

									combineCamera:Fire("SetIdle")
									combineCamera:Fire("SetAngry")

									Schema:AddCombineDisplayMessage("Movement violation(s) sighted by C-i" .. combineCamera:EntIndex() .. "...", Color(255, 128, 0, 255))
								end
							end
						end
					end
				end

				networkedCameraData[combineCamera:EntIndex()] = data
			else
				networkedCameraData[combineCamera:EntIndex()] = 0
			end
		end

		local receivers = {}

		for _, player in ipairs(player.GetAll()) do
			if (player:IsCombine() and !player:GetNetVar("IsBiosignalGone")) then
				receivers[#receivers + 1] = player
			end
		end

		net.Start("UpdateBiosignalCameraData")
			net.WriteTable(networkedCameraData)
		net.Send(receivers)

		self.nextCameraTick = curTime + 1
	end

	if (!self.nextBiosignalUpdate or curTime >= self.nextBiosignalUpdate) then
		local receivers = {}

		for _, player in ipairs(player.GetAll()) do
			if (player:IsCombine() and !player:GetNetVar("IsBiosignalGone")) then
				receivers[#receivers + 1] = player
			end
		end

		net.Start("RecalculateHUDObjectives")
			net.WriteString(self.socioStatus)
			net.WriteTable(Schema.CombineObjectives)
		net.Send(receivers)

		self.nextBiosignalUpdate = curTime + math.random(1, 3)
	end
end

function PLUGIN:PlayerSpawn(client)
	if (client:IsCombine()) then
		net.Start("RecalculateHUDObjectives")
			net.WriteString(self.socioStatus)
			net.WriteTable(Schema.CombineObjectives)
		net.Send(client)

		if (client:GetNetVar("IsBiosignalGone")) then
			if (ix.config.Get("useBiosignalSystem")) then
				client:Notify("Note: Your character currently has no biosignal.")
			else
				client:SetNetVar("IsBiosignalGone", false)
			end
		end
	end

	if (!self.fixedCameras) then
		for combineCamera, data in pairs(self.cameraData) do
			if (!combineCamera:HasSpawnFlags(SF_NPC_WAIT_FOR_SCRIPT)) then -- This is documented as the "Start Inactive" flag by Valve for combine cameras.
				combineCamera:Fire("Enable")
			end
		end

		self.fixedCameras = true
	end
end

function PLUGIN:OnCharacterFallover(client, entity, bFallenOver)
	if (client:IsCombine() and !client:GetNetVar("IsBiosignalGone")) then
		if (bFallenOver) then
			local location = client:GetArea() != "" and client:GetArea() or "unknown location"
			local digits = string.match(client:Name(), "%d%d%d%d?%d?") or 0

			Schema:AddCombineDisplayMessage("Downloading trauma packet...", Color(255, 255, 255, 255))
			Schema:AddCombineDisplayMessage("WARNING! Protection team unit " .. digits .. " lost consciousness at " .. location .. "...", Color(255, 0, 0, 255))
		end
	end
end

function Schema:PlayerDeath(client, inflictor, attacker)
	if (client:IsCombine()) then
		local location = client:GetArea() != "" and client:GetArea() or "unknown location"

		if (!client:GetNetVar("IsBiosignalGone")) then
			PLUGIN:DoPostBiosignalLoss(client)
		end

		if (IsValid(client.ixScanner) and client.ixScanner:Health() > 0) then
			client.ixScanner:TakeDamage(999)
		end
	end
end

function Schema:GetPlayerDeathSound(client)
	if (client:IsCombine()) then
		local sound = "npc/metropolice/die" .. math.random(1, 4) .. ".wav"

		if (!client:GetNetVar("IsBiosignalGone")) then
			for _, player in ipairs(player.GetAll()) do
				if (player:IsCombine() and !player:GetNetVar("IsBiosignalGone")) then
					player:EmitSound(sound)
				end
			end
		end

		return sound
	end
end

function PLUGIN:OnEntityCreated(entity)
	if (entity:GetClass() == "npc_combine_camera") then
		if (self.cameraData[entity] == nil) then
			self:SafelyPrepareCamera(entity)
		end
	end
end

function PLUGIN:SetupPlayerVisibility(client)
	for _, terminal in pairs(ents.FindByClass("ix_ctocameraterminal")) do
		local camera = terminal:GetNWEntity("camera")

		if (IsValid(camera) and client:IsLineOfSightClear(terminal)) then
			AddOriginToPVS(camera:GetPos() + Vector("0 0 -10"))
		end
	end
end

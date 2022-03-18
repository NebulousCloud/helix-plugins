
local PLUGIN = PLUGIN

function PLUGIN:PostPlayerDeath(client)
	if (client.rappelling) then
		self:EndRappel(client)
	end
end

function PLUGIN:PlayerLoadout(client)
	if (client.rappelling) then
		self:EndRappel(client)
	end
end

function PLUGIN:DoAnimationEvent(client)
	if (client:GetNetVar("forcedSequence") == client:LookupSequence("rappelloop")) then
		return ACT_INVALID
	end
end

function PLUGIN:OnPlayerHitGround(client, inWater, onFloater, speed)
	if (client.rappelling and client.rappelPos.z - client:GetPos().z > 64) then
		self:EndRappel(client)

		if (SERVER) then
			client:EmitSound("npc/combine_soldier/zipline_hitground" .. math.random(2) .. ".wav")
		end

		if (speed >= 196) then
			client:ViewPunch(Angle(7, 0, 0))
		end
	end
end

function PLUGIN:PlayerTick(client, moveData)
	if (client:HasWeapon("rappel_gear")) then
		local onGround = client:OnGround()

		if (onGround and !client.wasOnGround) then
			client.wasOnGround = true
		elseif (!onGround and client.wasOnGround) then
			client.wasOnGround = false

			if (!client.rappelling and moveData:KeyDown(IN_WALK) and client:GetMoveType() != MOVETYPE_NOCLIP) then
				self:StartRappel(client)
			end
		end
	end
end

function PLUGIN:Move(client, moveData)
	if (client.rappelling) then
		local vel = moveData:GetVelocity()

		local dir = (client.rappelPos - client:GetPos()) * 0.1

		vel.x = (vel.x + dir.x) * 0.95
		vel.y = (vel.y +  dir.y) * 0.95

		local rappelFalling = false

		if (!client:OnGround() and (client:EyePos().z) < client.rappelPos.z) then
			rappelFalling = true

			if (moveData:KeyDown(IN_WALK)) then
				moveData:SetForwardSpeed(0)
				moveData:SetSideSpeed(0)

				vel.z = math.max(vel.z - 16, -128)
			else
				vel.z = math.max(vel.z - 16, -512)
			end
		end

		moveData:SetVelocity(vel)

		if (rappelFalling) then
			if (SERVER) then
				local sequence = client:LookupSequence("rappelloop")

				if (sequence != -1) then
					client:SetNetVar("forcedSequence", sequence)
				end

				if (!client.oneTimeRappelSound) then
					client.oneTimeRappelSound = true

					client:EmitSound("npc/combine_soldier/zipline" .. math.random(2) .. ".wav")
				end
			end

			if (client:WaterLevel() >= 1) then
				self:EndRappel(client)
			end
		else
			if (SERVER) then
				local sequence = client:LookupSequence("rappelloop")

				if (sequence != 1 and client:GetNetVar("forcedSequence") == sequence) then
					client:SetNetVar("forcedSequence", nil)
				end
			end

			local origin = moveData:GetOrigin()

			if (math.Distance(origin.x, origin.y, client.rappelPos.x, client.rappelPos.y) > 256) then
				self:EndRappel(client)
			end
		end
	end
end

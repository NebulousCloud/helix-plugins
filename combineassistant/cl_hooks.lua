
function PLUGIN:PlayerSwitchWeapon(client, oldWeapon, newWeapon)
	if (!client:IsCombine()) then return end
	if (!ix.option.Get("caAutomaticActionsEnabled")) then return end
	if (!IsFirstTimePredicted()) then return end

	if (newWeapon:GetClass() == "ix_stunstick") then
		local text = ix.option.Get("caStunstickUnholsterAction")
		if (!text or text == "") then return end

		self:PlayerCLSay("/me " .. text)
	elseif (oldWeapon:GetClass() == "ix_stunstick") then
		local text = ix.option.Get("caStunstickHolsterAction")
		if (!text or text == "") then return end

		self:PlayerCLSay("/me " .. text)
	end
end

function PLUGIN:KeyPress(client, key)
	if (!client:IsCombine()) then return end
	if (!ix.option.Get("caAutomaticActionsEnabled")) then return end
	if (!IsFirstTimePredicted()) then return end

	local weapon = client:GetActiveWeapon()
	if (!IsValid(weapon)) then return end

	if (weapon:GetClass() != "ix_stunstick") then return end

	if (key == IN_RELOAD) then
		timer.Create("ixToggleRaise" .. client:SteamID(), ix.config.Get("weaponRaiseTime") + 0.1, 1, function()
			if (!client:KeyDown(IN_RELOAD)) then return end

			local weapon = client:GetActiveWeapon()
			if (!IsValid(weapon)) then return end

			if (weapon:GetClass() != "ix_stunstick") then return end

			if (client:GetNetVar("raised")) then
				local text = ix.option.Get("caStunstickRaiseAction")
				if (!text or text == "") then return end

				self:PlayerCLSay("/me " .. text)
			else
				local text = ix.option.Get("caStunstickLowerAction")
				if (!text or text == "") then return end

				self:PlayerCLSay("/me " .. text)
			end
		end)
	elseif (key == IN_ATTACK and client:KeyDown(IN_WALK) and client:GetNetVar("raised") and weapon:GetNextPrimaryFire() <= CurTime()) then
		if (weapon:GetActivated()) then
			local text = ix.option.Get("caStunstickOffAction")
			if (!text or text == "") then return end

			self:PlayerCLSay("/me " .. text)
		else
			local text = ix.option.Get("caStunstickOnAction")
			if (!text or text == "") then return end

			self:PlayerCLSay("/me " .. text)
		end
	elseif (key == IN_ATTACK2 and weapon:GetNextPrimaryFire() <= CurTime()) then
		local data = {}
			data.start = LocalPlayer():GetShootPos()
			data.endpos = data.start + LocalPlayer():GetAimVector() * 72
			data.filter = LocalPlayer()
			data.mins = Vector(-8, -8, -30)
			data.maxs = Vector(8, 8, 10)
		local trace = util.TraceHull(data)
		local entity = trace.Entity

		if (!entity or !entity:IsValid()) then return end

		if (entity:IsPlayer()) then
			local text = ix.option.Get("caStunstickPushAction")
			if (!text or text == "") then return end

			local description = entity:GetCharacter():GetDescription() != "" and entity:GetCharacter():GetDescription() or entity:IsPlayer() and entity:GetName() or ""
			if (#description > 30) then
				description = description:utf8sub(1, 27).."..."
			end

			if (description != "" and description != entity:GetName()) then
				description = "[" .. description .. "]"
			end
			
			self:PlayerCLSay("/me " .. string.format(text, description and description != "" and description or "the individual in front of them"))
		elseif (entity:IsDoor()) then
			local text = ix.option.Get("caStunstickKnockAction")
			if (!text or text == "") then return end

			self:PlayerCLSay("/me " .. text)
		end
	end
end

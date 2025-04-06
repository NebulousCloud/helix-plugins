
-- Running on tick to avoid some HUD conflicts.
function PLUGIN:Tick()
	local client = LocalPlayer()

	for ent, bDraw in pairs(self.terminalsToDraw) do
		if (IsValid(ent) and bDraw) then
			local scrw, scrh = ScrW(), ScrH()

			local camera = ent:GetNWEntity("camera")

			if (IsValid(camera) and camera:GetClass() == "npc_combine_camera") then
				local bonePos, boneAngles = camera:GetBonePosition(camera:LookupBone("Combine_Camera.bone1"))
				local camPos, camAngles = camera:GetBonePosition(camera:LookupBone("Combine_Camera.Lens"))

				boneAngles.roll = boneAngles.roll + 90

				local bulbColor = camera:GetChildren()[1]:GetColor()
				local statusText = "All Clear"
				local signalText = "[512x256/p15@TR42/036]#=i" .. camera:EntIndex() .. "y=" .. math.floor(boneAngles.yaw) .. "&r=" .. math.floor(boneAngles.roll)
				if (bulbColor.g == 128) then
					statusText = "Watching..."
				elseif (bulbColor.g == 0) then
					statusText = "Violation!"
				end

				render.PushRenderTarget(ent.tex)
					if (self:isCameraEnabled(camera)) then
						if (ent.lastCamOutputTime == nil or RealTime() - ent.lastCamOutputTime >= (1 / 15)) then
							render.RenderView({
								origin = camPos + (boneAngles:Forward() * 2.8),
								angles = boneAngles,
								fov = 90,
								aspect = 2,
								x = 0,
								y = 0,
								w = 512,
								h = 256,
								drawviewmodel = false,
								drawviewer = true
							})

							ent.lastCamOutputTime = RealTime()
						end
					else
						render.Clear(0, 0, 0, 255, false, true)
						statusText = "Disabled"
						signalText = "no signal(?)"
						bulbColor = Color(255, 0, 0)
					end

					cam.Start2D()
						draw.SimpleText("<:: C-i" .. camera:EntIndex() .. " ::>", "BudgetLabel", 4, 6)
						draw.SimpleText("<:: " .. statusText .. " ::>", "BudgetLabel", 4, 6 + draw.GetFontHeight("BudgetLabel"), bulbColor)
						draw.SimpleText(signalText, "BudgetLabel", 4, 252 - draw.GetFontHeight("BudgetLabel"))
						draw.SimpleText("*", "CloseCaption_Normal", 256, 126, bulbColor, 1, 1)
					cam.End2D()
				render.PopRenderTarget()

				ent.mat:SetTexture("$basetexture", ent.tex)
				ent:SetSubMaterial(1, "!" .. ent.mat:GetName())
			else
				ent:SetSubMaterial(1, "models/props_combine/combine_interface_disp")
			end
		end
	end
end

function PLUGIN:HUDPaint()
	local client = LocalPlayer()

	if (client:IsCombine()) then
		local colorRed = Color(255, 0, 0, 255)
		local colorObject = Color(150, 150, 200, 255)
		local fontHeight = draw.GetFontHeight("BudgetLabel")

		local curTime = CurTime()

		local lowDetailBox = math.floor(ScrW() / 16)
		local halfScrVector = Vector(ScrW() / 2, ScrH() / 2)
		local lowDetailText = "<...>"

		local requestColor = Color(175, 125, 100, 255)

		local bUnobstruct = ix.config.Get("biosignalUnobstruct")
		local biosignalDist = ix.config.Get("biosignalDistance")

		local beholder = client
		local beholderEyePos = beholder:EyePos()

		local biosignalExpiry = ix.config.Get("expireBiosignals")

		local socioColor = self.sociostatusColors[self.socioStatus] or color_white

		local info = {x = ScrW() - 8, y = 8}

		if (self.socioStatus == "BLACK") then
			local tsin = TimedSin(1, 0, 255, 0)
			socioColor = Color(tsin, tsin, tsin)
		end

		socioColor = Color(socioColor.r, socioColor.g, socioColor.b, 255)

		draw.SimpleText("<:: Sociostatus = " .. self.socioStatus .. " ::>", "BudgetLabel", info.x, info.y, socioColor, TEXT_ALIGN_RIGHT)
		info.y = info.y + fontHeight

		for k, v in ipairs(self.hudObjectives) do
			local textColor = Color(color_white.r, color_white.g, color_white.b, 255)

			draw.SimpleText(v, "BudgetLabel", info.x, info.y, textColor, TEXT_ALIGN_RIGHT)

			info.y = info.y + fontHeight
		end

		-- Draw unit biosignals.
		for unit, data in pairs(self.biosignalLocations) do
			if (!IsValid(unit) or curTime - data.time >= biosignalExpiry) then
				self.biosignalLocations[unit] = nil
			elseif (!(!data.isLost and unit:GetMoveType() == MOVETYPE_NOCLIP)) then
				local toScreen = data.pos:ToScreen()

				-- Check against visibility configuration.
				if (!data.isLost) and ((!bUnobstruct and !beholder:IsLineOfSightClear(unit)) or (biosignalDist > 0 and beholderEyePos:Distance(unit:GetPos()) > biosignalDist)) then
					toScreen.visible = false
				end

				if (toScreen.visible) then
					local text = "<:: " .. data.digits .. " ::>"
					local color = team.GetColor(unit:Team()) or color_white

					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					if (showDetail) then
						text = "<:: " .. unit:Name() .. " ::>"
					end

					local timeSince = math.Round(curTime - data.time, 2)
					timeSince = timeSince .. string.rep(0, (string.len(math.floor(timeSince)) + 3) - string.len(timeSince))

					if (data.isLost) then
						local text2 = "<:: Lost " .. timeSince .. "s ::>"

						local timeUntil = math.Round((biosignalExpiry - (curTime - data.time)), 2)
						timeUntil = timeUntil .. string.rep(0, (string.len(math.floor(timeUntil)) + 3) - string.len(timeUntil))

						draw.SimpleText(text, "BudgetLabel", toScreen.x, toScreen.y, color, 1, 1)
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText(text2, "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText("<:: Removing " .. timeUntil .. "s ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
					else
						local text2 = "<:: Received " .. timeSince .. "s ::>"
						draw.SimpleText(text, "BudgetLabel", toScreen.x, toScreen.y, color, 1, 1)
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText(showDetail and text2 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, color_white, 1, 1)

						if (data.isKnockedOut) then
							toScreen.y = toScreen.y + fontHeight
							draw.SimpleText("<:: Unconscious ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
						end
					end
				end
			end
		end

		local requestExpiry = ix.config.Get("expireRequests")

		-- Draw help requests.
		for i, data in ipairs(self.requestLocations) do
			if (curTime - data.time >= requestExpiry) then
				self.requestLocations[i] = nil
			else
				local toScreen = data.pos:ToScreen()

				if (toScreen.visible) then
					local text2 = "<:: " .. data.text .. " ::>"

					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					local timeUntil = math.Round((requestExpiry - (curTime - data.time)), 2)
					timeUntil = timeUntil .. string.rep(0, (string.len(math.floor(timeUntil)) + 3) - string.len(timeUntil))

					draw.SimpleText("<:: Assistance Request ::>", "BudgetLabel", toScreen.x, toScreen.y, requestColor, 1, 1)
					toScreen.y = toScreen.y + fontHeight
					draw.SimpleText(showDetail and text2 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, color_white, 1, 1)
					toScreen.y = toScreen.y + fontHeight
					draw.SimpleText("<:: Removing " .. timeUntil .. "s ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
				end
			end
		end

		-- Draw cameras.
		for combineCamera, data in pairs(self.cameraData) do
			if (IsValid(combineCamera)) then
				local toScreen = combineCamera:GetPos():ToScreen()

				local violations = {}

				if (type(data) == "table") then
					for player, vios in pairs(data) do
						for i, vio in ipairs(vios) do
							if (vio == self.VIOLATION_RUNNING) then
								violations[#violations + 1] = "<:: 1xRunning ::>"
							elseif (vio == self.VIOLATION_JUMPING) then
								violations[#violations + 1] = "<:: 1xJumping ::>"
							elseif (vio == self.VIOLATION_CROUCHING) then
								violations[#violations + 1] = "<:: 1xDucking ::>"
							elseif (vio == self.VIOLATION_FALLEN_OVER) then
								violations[#violations + 1] = "<:: 1xLaying ::>"
							end
						end
					end
				end

				if (#violations <= 0) and
				((!bUnobstruct and !beholder:IsLineOfSightClear(combineCamera))
				or (biosignalDist > 0 and beholderEyePos:Distance(combineCamera:GetPos()) > biosignalDist)) then
					toScreen.visible = false
				end

				if (toScreen.visible) then
					local text1 = "<:: C-i" .. combineCamera:EntIndex() .. " ::>"
					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)

					draw.SimpleText(showDetail and text1 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, colorObject, 1, 1)

					if (type(data) == "table") then
						local text2 = "<:: " .. table.Count(data) .. " Within Sights ::>"

						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText(showDetail and text2 or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, color_white, 1, 1)

						if (#violations > 0) then
							toScreen.y = toScreen.y + fontHeight
							draw.SimpleText("<:: Violations Within Sights ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)

							for i, violation in ipairs(violations) do
								toScreen.y = toScreen.y + fontHeight
								draw.SimpleText(showDetail and violation or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, color_white, 1, 1)
							end
						end
					else
						toScreen.y = toScreen.y + fontHeight
						draw.SimpleText("<:: Disabled ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)
					end
				end
			end
		end

		local maximumDistance = ix.config.Get("citizenDistance")

		-- If we are using suit zoom.
		if (client:GetFOV() < 40) then
			maximumDistance = maximumDistance * 3
		end

		-- Draw movement violations.
		for _, v in pairs(player.GetAll()) do
			if (v:GetCharacter() and (!v:IsCombine() or v:GetNetVar("IsBiosignalGone", false)) and beholderEyePos:Distance(v:GetPos()) <= maximumDistance and v:GetMoveType() != MOVETYPE_NOCLIP) then
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

				local toScreen = position:ToScreen()

				if (toScreen.visible and beholder:IsLineOfSightClear(v)) then
					local showDetail = (Vector(toScreen.x, toScreen.y):Distance(halfScrVector) <= lowDetailBox)
					local CID = v:GetCharacter():GetData("cid", "UNKNOWN")

					if (ix.config.Get("useTagSystem") and beholderEyePos:Distance(v:GetPos()) <= (maximumDistance / 6) and !v:GetCharacter():GetData("IsCIDTagGone") and CID != "") then
						local text = "<:: c#" .. CID .. " ::>"
						local color = team.GetColor(v:Team()) or color_white

						draw.SimpleText(showDetail and text or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, color, 1, 1)
						toScreen.y = toScreen.y + fontHeight
					end

					local violations = {}

					if (v:IsRunning()) then violations[#violations + 1] = "<:: 1xRunning ::>" end
					if (!v:OnGround() and client:WaterLevel() <= 0) then violations[#violations + 1] = "<:: 1xJumping ::>" end
					if (v:Crouching()) then violations[#violations + 1] = "<:: 1xDucking ::>" end
					if (v:GetLocalVar("ragdoll")) then violations[#violations + 1] = "<:: 1xLaying ::>"	end

					if (#violations > 0) then
						draw.SimpleText("<:: Possible Violation ::>", "BudgetLabel", toScreen.x, toScreen.y, colorRed, 1, 1)

						for i, violation in ipairs(violations) do
							toScreen.y = toScreen.y + fontHeight
							draw.SimpleText(showDetail and violation or lowDetailText, "BudgetLabel", toScreen.x, toScreen.y, color_white, 1, 1)
						end
					end
				end
			end
		end
	end
end

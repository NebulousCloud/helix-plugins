PLUGIN.name = "Better Description Display"
PLUGIN.author = "Vex"
PLUGIN.description = "A better description display for when you look at people."

if (CLIENT) then
	function PLUGIN:ShouldPopulateEntityInfo(entity)
		if (entity:IsPlayer()) then
			return false
		end
	end

	function PLUGIN:LoadFonts(font, genericFont)
		surface.CreateFont("ixDescFont", {
			font = font,
			size = 16,
			extended = true,
			weight = 800
		})
	end

	local range = ix.config.Get("chatRange", 280)

	function PLUGIN:HUDPaint()
		local client = LocalPlayer()

		if (!client:GetCharacter()) then
			return
		end

		local entity = LocalPlayer():GetEyeTrace().Entity

		if (entity:IsPlayer()) then
			local entPos = entity:GetPos()
			local distance = client:GetPos():Distance(entPos)

			if (distance < range) then
				local w, h = ScrW(), ScrH()
				local name = hook.Run("GetCharacterName", entity) or entity:GetName()
				local description = ix.util.WrapText(entity:GetCharacter():GetDescription(), w * 0.75, "ixDescFont")
				local teamColor = team.GetColor(entity:Team())
				local alpha = 255

				surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha)
				surface.SetFont("ixGenericFont")

				ix.util.DrawText(name, w / 2, 12, ColorAlpha(teamColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)

				surface.SetFont("ixDescFont")
				for i, v in pairs(description) do
					ix.util.DrawText(v, w / 2, 14 + (18 * i), Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
				end
			end
		end
	end
end

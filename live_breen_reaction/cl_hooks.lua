
local ambientColors = {
	["GREEN"] = Color(50, 50, 50),
	["BLUE"] = Color(50, 50, 255),
	["YELLOW"] = Color(150, 150, 0),
	["RED"] = Color(150, 0, 0),
	["BLACK"] = Color(150, 0, 0)
}

function PLUGIN:CharacterLoaded(character)
	if (character:IsCombine()) then
		vgui.Create("ixLiveBreenReaction")
	elseif (IsValid(ix.gui.breenReaction)) then
		ix.gui.breenReaction:Remove()
	end
end

-- Override the CTO RecalculateHUDObjectives net receiver to allow us to do shit when sociostatus changes.
function PLUGIN:InitializedPlugins()
	local CTO = ix.plugin.Get("cto")
	if (!CTO) then return end

	net.Receive("RecalculateHUDObjectives", function()
		local status = net.ReadString()
		local objectives = net.ReadTable()
		local lines = {}

		if (status) then
			CTO.socioStatus = status
		end

		if (objectives and objectives.text) then
			for k, v in pairs(string.Split(objectives.text, "\n")) do
				if (string.StartWith(v, "^")) then
					table.insert(lines, "<:: " .. string.sub(v, 2) .. " ::>")
				end
			end

			CTO.hudObjectives = lines
		end

		CTO:UpdateBiosignalLocations()

		----------

		local breenReaction = ix.gui.breenReaction
		if (!IsValid(breenReaction)) then return end

		breenReaction:UpdateAmbientLight(ambientColors[status] or ambientColors["GREEN"])
	end)
end

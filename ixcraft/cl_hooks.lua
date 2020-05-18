
local PLUGIN = PLUGIN

function PLUGIN:BuildCraftingMenu()
	if (table.IsEmpty(self.craft.GetCategories(LocalPlayer()))) then
		return false
	end
end

function PLUGIN:PopulateRecipeTooltip(tooltip, recipe)
	local canCraft, failString, c, d, e, f = recipe:OnCanCraft(LocalPlayer())

	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(recipe.category..": "..(recipe.GetName and recipe:GetName() or L(recipe.name)))
	name:SetMaxWidth(math.max(name:GetMaxWidth(), ScrW() * 0.5))
	name:SizeToContents()

	if (!canCraft) then
		if (failString:sub(1, 1) == "@") then
			failString = L(failString:sub(2), c, d, e, f)
		end

		local errorRow = tooltip:AddRow("errorRow")
		errorRow:SetText(L(failString))
		errorRow:SetBackgroundColor(Color(255,24,0))
		errorRow:SizeToContents()
	end

	local description = tooltip:AddRow("description")
	description:SetText(recipe.GetDescription and recipe:GetDescription() or L(recipe.description))
	description:SizeToContents()

	if (recipe.tools) then
		local tools = tooltip:AddRow("tools")
		tools:SetText(L("CraftTools"))
		tools:SetBackgroundColor(Color(150,150,25))
		tools:SizeToContents()

		local toolString = ""

		for _, v in pairs(recipe.tools) do
			local itemTable = ix.item.Get(v)
			local itemName = v

			if (itemTable) then
			    itemName = itemTable.name
			end

			toolString = toolString..itemName..", "
		end

		if (toolString != "") then
			local tools = tooltip:AddRow("toolList")
			tools:SetText("- "..string.sub(toolString, 0, #toolString-2))
			tools:SizeToContents()
		end
	end

	local requirements = tooltip:AddRow("requirements")
	requirements:SetText(L("CraftRequirements"))
	requirements:SetBackgroundColor(Color(25,150,150))
	requirements:SizeToContents()

	local requirementString = ""

	for k, v in pairs(recipe.requirements) do
		local itemTable = ix.item.Get(k)
		local itemName = k

		if (itemTable) then
		    itemName = itemTable.name
		end

		requirementString = requirementString..v.."x "..itemName..", "
	end

	if (requirementString != "") then
		local requirement = tooltip:AddRow("ingredientList")
		requirement:SetText("- "..string.sub(requirementString, 0, #requirementString-2))
		requirement:SizeToContents()
	end

	local result = tooltip:AddRow("result")
	result:SetText(L("CraftResults"))
	result:SetBackgroundColor(derma.GetColor("Warning", tooltip))
	result:SizeToContents()

	local resultString = ""

	for k, v in pairs(recipe.results) do
		local itemTable = ix.item.Get(k)
		local itemName = k
		local amount = v

		if (itemTable) then
		    itemName = itemTable.name
		end

		if (istable(v)) then
			if (v["min"] and v["max"]) then
				amount = v["min"].."-"..v["max"]
			else
				amount = v[1].."-"..v[#v]
			end
		end

		resultString = resultString..amount.."x "..itemName..", "
	end

	if (resultString != "") then
		local result = tooltip:AddRow("resultList")
		result:SetText("- "..string.sub(resultString, 0, #resultString-2))
		result:SizeToContents()
	end

	if (recipe.PopulateTooltip) then
		recipe:PopulateTooltip(tooltip)
	end
end

function PLUGIN:PopulateStationTooltip(tooltip, station)
	local name = tooltip:AddRow("name")
	name:SetImportant()
	name:SetText(station.GetName and station:GetName() or L(station.name))
	name:SetMaxWidth(math.max(name:GetMaxWidth(), ScrW() * 0.5))
	name:SizeToContents()

	local description = tooltip:AddRow("description")
	description:SetText(station.GetDescription and station:GetDescription() or L(station.description))
	description:SizeToContents()

	if (station.PopulateTooltip) then
		station:PopulateTooltip(tooltip)
	end
end

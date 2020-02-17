surface.CreateFont("WastelandTiny", {
	font = "Bahnschrift SemiLight Condensed", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("WastelandMedium", {
	font = "Bahnschrift SemiLight Condensed", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 26,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("WastelandStandard", {
	font = "Bahnschrift SemiLight Condensed", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 35,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local PANEL = {}

function PANEL:Init()
	self.infolabel = self:Add("DLabel")
	self.infolabel:Dock(TOP)
	self.infolabel:SetContentAlignment(5)
	self.infolabel:SetExpensiveShadow(1, Color(0, 0, 0, 255))
	self.infolabel:SetText("Hover over the icon of an item to get more information about it.")
	self.infolabel:SetFont("WastelandMedium")
	ix.gui.crafting = self
	self:SetSize(ScrW() / 2, ScrH() / 1.5)
	self:Center()
	self.CraftingList = self:Add("DScrollPanel")
	self.CraftingList:Dock(FILL)
	local w, h = self:GetSize()

	for k, v in pairs(STORED_RECIPES) do
		--printTable(v)
		if v["blueprint"] then
			local data = LocalPlayer():GetCharacter():GetData("blueprints", {})

			--print(v["blueprint"])
			if table.HasValue(data, v["blueprint"]) then
				local item = self:AddItem(v["name"], v["model"], v["desc"], v["req"], v["results"], v["skill"], v["blueprint"], v["guns"], v["entity"])
				item.id = v["id"]
			end
		end

		if not v["blueprint"] then
			local item = self:AddItem(v["name"], v["model"], v["desc"], v["req"], v["results"], v["skill"], v["guns"], v["entity"])
			item.id = v["id"]
		end
	end
end

function PANEL:AddItem(name, icon, desc, req, results, skill, blueprint, guns, entity)
	self.test = self:Add("CraftingListItem")
	self.test:SetItem(name, icon, desc, req, results, skill, blueprint or false, guns or false, entity or false)
	self.CraftingList:AddItem(self.test)
	--self.test:DockMargin(0,0,0,5)

	return self.test
end

vgui.Register("CraftingListFrame", PANEL, "DPanel")
local PANEL = {}

function PANEL:Init()
	local size = self:GetParent():GetSize()
	self:SetWide(size / 2)
	self:SetTall(size / 8)
	self:Dock(TOP)
	local w, h = self:GetSize()
	self.spawnicon = self:Add("SpawnIcon")
	self.spawnicon:SetSize(72, 72)
	self.spawnicon:SetPos(5, 5)
	self:SetModel("icon")
	self.labelitem = self:Add("DLabel")
	self.labelitem:Dock(TOP)
	self.labelitem:SetFont("WastelandStandard")
	self.labelitem:SetText("")
	self.labelitem:SetAutoStretchVertical(true)
	self.labelitem:DockMargin(120, 0, 0, 0)
	self.labelitemdesc = self:Add("DLabel")
	self.labelitemdesc:Dock(TOP)
	self.labelitemdesc:SetFont("WastelandMedium")
	self.labelitemdesc:SetText("")
	self.labelitemdesc:SetAutoStretchVertical(true)
	self.labelitemdesc:DockMargin(120, 0, 0, 0)
	self.labelitemreq = self:Add("DLabel")
	self.labelitemreq:Dock(TOP)
	self.labelitemreq:SetFont("WastelandMedium")
	self.labelitemreq:SetText("")
	self.labelitemreq:SetAutoStretchVertical(true)
	self.labelitemreq:DockMargin(120, 0, 0, 0)
	self.craftbutton = self:Add("DButton")
	self.craftbutton:SetText("")
	self.craftbutton:AlignRight(-365)
	self.craftbutton:AlignTop(20)
	self.craftbutton:SetSize(150, 40)

	function self.craftbutton:Paint(w2, h2)
		local col

		if self:GetParent():HasRequirements() then
			col = Color(0, 150, 0, 150)
		else
			col = Color(75, 75, 75, 150)
		end

		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, w2, h2)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(0, 0, w2, h2)
		draw.SimpleTextOutlined("Craft", "WastelandStandard", w2 - 100, h2 / 18, Color(255, 255, 255, 255), 5, 5, 1, Color(0, 0, 0, 255))
	end

	function self.craftbutton:DoClick()
		surface.PlaySound("UI/buttonclick.wav")

		timer.Simple(SoundDuration("UI/buttonclick.wav") - 0.1, function()
			surface.PlaySound("UI/buttonclickrelease.wav")
		end)
		local parent = self:GetParent()
		print(parent)
		print(parent.id)
		netstream.Start("ixCraftItem", {parent.id})
	end
end

function PANEL:SetItem(name, icon, desc, req, results, skill, blueprint, guns, entity)
	--creating identifiers
	self.labelitem:SetText(name)
	self.spawnicon:SetModel(icon)
	self.description = desc
	self.labelitemdesc:SetText(desc)
	self.requirements = req
	local realreqd = {}

	for k, v in pairs(self.requirements) do
		local item = ix.item.Get(k)
		realreqd[#realreqd + 1] = item.name .. " (" .. v .. "x)"
	end

	self.labelitemreq:SetText("Requirements: " .. table.concat(realreqd, ", "))
	self.results = results
	self.skill = skill
	self.blueprint = blueprint
	self.guns = guns
	self.entity = entity
	--self.item = ix.items.list[item]
	self.spawnicon:SetHelixTooltip(function(tooltip)
		local title = tooltip:AddRow("title")
		title:SetImportant()
		title:SetText(self.labelitem:GetText())
		title:SetBackgroundColor(ix.config.Get("color"))
		title:SizeToContents()
		local description = tooltip:AddRow("description")
		description:SetText(self.labelitemdesc:GetText())
		description:SizeToContents()
		local requirements = tooltip:AddRow("requirements")
		local realreq = {}

		for k, v in pairs(self.requirements) do
			local item = ix.item.Get(k)
			realreq[#realreq + 1] = item.name .. " (" .. v .. "x)"
		end

		requirements:SetText("Requirements: " .. table.concat(realreq, ", "))
		local missing = {}
		local inv = LocalPlayer():GetCharacter():GetInventory()

		for k, v in pairs(self.requirements) do
			if inv:GetItemCount(k) < v then
				print(inv:GetItemCount(k))
				local i = ix.item.Get(k)
				missing[#missing + 1] = i.name
			end
		end

		if #missing > 0 then
			requirements:SetBackgroundColor(derma.GetColor("Warning", tooltip))
		else
			requirements:SetBackgroundColor(derma.GetColor("Success", tooltip))
		end

		--requirements:SizeToContents()
		if #realreq >= 4 then
			requirements:SizeToContents()
			requirements:SetTall(56)
		else
			requirements:SizeToContents()
		end

		local results = tooltip:AddRow("results")
		local realres = {}

		for k, v in pairs(self.results) do
			local item = ix.item.Get(k)
			realres[#realres + 1] = item.name .. " (" .. v .. "x)"
		end

		results:SetText("Results: " .. table.concat(realres, ", "))

		if self.skill then
			local skill = tooltip:AddRow("skill")
			local skillist = {}

			for k, v in pairs(self.skill) do
				local attrib = ix.attributes.list[k]
				skillist[#skillist + 1] = attrib.name .. " (" .. v .. ")"
			end

			skill:SetText("Required Skills: " .. table.concat(skillist, ", "))
			skill:SizeToContents()
			local skillslist = {}

			for k, v in pairs(self.skill) do
				if LocalPlayer():GetCharacter():GetAttribute(k, 0) < v then
					skillslist[#skillslist + 1] = k
				end
			end

			if #skillslist > 0 then
				skill:SetBackgroundColor(derma.GetColor("Error", tooltip))
			else
				skill:SetBackgroundColor(derma.GetColor("Success", tooltip))
			end
		else
			local skill = tooltip:AddRow("skill")
			skill:SetText("No Required Skills")
			skill:SizeToContents()
		end

		if self.blueprint then
			local bp = tooltip:AddRow("blueprint")
			bp:SetColor(ix.config.Get("color"))
			bp:SetText("Unlocked by Blueprint")
			bp:SizeToContents()
		end
	end)

end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 175)
	surface.DrawRect(0, 0, w, h)

end

function PANEL:HasRequirements()
	local inv = LocalPlayer():GetCharacter():GetInventory()
	local missing = {}
	for k, v in pairs(self.requirements) do
		if inv:GetItemCount(k) < v then
			local i = ix.item.Get(k)
			missing[#missing + 1] = i.name
		end
	end

	if #missing > 0 then
		return false
	else
		return true
	end

	return true
end

vgui.Register("CraftingListItem", PANEL, "DPanel")

hook.Add("CreateMenuButtons", "ixCrafting", function(tabs)
	tabs["crafting"] = function(container)
		container:Add("CraftingListFrame")
	end
end)
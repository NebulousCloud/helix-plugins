local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
	self:SetSize(720, 720)
	self:Center()
	self:SetBackgroundBlur(true)
	self:SetDeleteOnClose(true)

	self:MakePopup()
	self:SetTitle("Bodygroup Manager")

	self.saveButton = self:Add("DButton")
	self.saveButton:Dock(BOTTOM)
	self.saveButton:DockMargin(0, 4, 0, 0)
	self.saveButton:SetText("Save Changes")
	self.saveButton.DoClick = function()
		local bodygroups = {}
		for _, v in pairs(self.bodygroupIndex) do
			table.insert(bodygroups, v.index, v.value)
		end

		net.Start("ixBodygroupTableSet")
			net.WriteEntity(self.target)
			net.WriteTable(bodygroups)
		net.SendToServer()
	end

	self.model = self:Add("DModelPanel")
	self.model.rotating = true
	self.model:SetSize(700, 700)
	self.model:SetPos(-200, 0)
	self.model:SetModel(Model("models/props_junk/watermelon01.mdl"))

	self.bodygroups = {}

	function self.model:LayoutEntity(Entity)
		Entity:SetAngles(Angle(0,45,0))
		local sequence = Entity:SelectWeightedSequence(ACT_IDLE)

		if (sequence <= 0) then
			sequence = Entity:LookupSequence("idle_unarmed")
		end

		if (sequence > 0) then
			Entity:ResetSequence(sequence)
		else
			local found = false

			for _, v in ipairs(Entity:GetSequenceList()) do
				if ((v:lower():find("idle") or v:lower():find("fly")) and v != "idlenoise") then
					Entity:ResetSequence(v)
					found = true

					break
				end
			end

			if (!found) then
				Entity:ResetSequence(4)
			end
		end

	end

	PLUGIN.viewer = self

end

function PANEL:SetTarget(target)
	self.target = target
	self:PopulateBodygroupOptions()
	self:SetTitle(target:GetName())
end

function PANEL:PopulateBodygroupOptions()
	self.bodygroupBox = {}
	self.bodygroupName = {}
	self.bodygroupPrevious = {}
	self.bodygroupNext = {}
	self.bodygroupIndex = {}
	self.scrollBar = vgui.Create("DScrollPanel", self)
	self.scrollBar:Dock(FILL)

	for k, v in pairs(self.target:GetBodyGroups()) do
		-- Disregard the model bodygroup.
		if !(v.id == 0) then
			local index = v.id

			self.bodygroupBox[v.id] = self.scrollBar:Add("DPanel")
			self.bodygroupBox[v.id]:Dock(TOP)
			self.bodygroupBox[v.id]:DockMargin(300, 20, 20, 0)
			self.bodygroupBox[v.id]:SetHeight(50)

			self.bodygroupName[v.id] = self.bodygroupBox[v.id]:Add("DLabel")
			self.bodygroupName[v.id].index = v.id
			self.bodygroupName[v.id]:SetText(v.name:gsub("^%l", string.upper))
			self.bodygroupName[v.id]:SetFont("ixMediumFont")
			self.bodygroupName[v.id]:Dock(LEFT)
			self.bodygroupName[v.id]:DockMargin(30, 0, 0, 0)
			self.bodygroupName[v.id]:SetWidth(200)

			self.bodygroupNext[v.id] = self.bodygroupBox[v.id]:Add("DButton")
			self.bodygroupNext[v.id].index = v.id
			self.bodygroupNext[v.id]:Dock(RIGHT)
			self.bodygroupNext[v.id]:SetText("Next")
			self.bodygroupNext[v.id].DoClick = function()
				local index = v.id
				if (self.model.Entity:GetBodygroupCount(index) - 1) <= self.bodygroupIndex[index].value then
					return
				end

				self.bodygroupIndex[index].value = self.bodygroupIndex[index].value + 1
				self.bodygroupIndex[index]:SetText(self.bodygroupIndex[index].value)
				self.model.Entity:SetBodygroup(index, self.bodygroupIndex[index].value)
			end

			self.bodygroupIndex[v.id] = self.bodygroupBox[v.id]:Add("DLabel")
			self.bodygroupIndex[v.id].index = v.id
			self.bodygroupIndex[v.id].value = self.target:GetBodygroup(index)
			self.bodygroupIndex[v.id]:SetText(self.bodygroupIndex[v.id].value)
			self.bodygroupIndex[v.id]:SetFont("ixMediumFont")
			self.bodygroupIndex[v.id]:Dock(RIGHT)
			self.bodygroupIndex[v.id]:SetContentAlignment(5)

			self.bodygroupPrevious[v.id] = self.bodygroupBox[v.id]:Add("DButton")
			self.bodygroupPrevious[v.id].index = v.id
			self.bodygroupPrevious[v.id]:Dock(RIGHT)
			self.bodygroupPrevious[v.id]:SetText("Previous")
			self.bodygroupPrevious[v.id].DoClick = function()
				local index = v.id
				if 0 == self.bodygroupIndex[index].value then
					return
				end
				self.bodygroupIndex[index].value = self.bodygroupIndex[index].value - 1
				self.bodygroupIndex[index]:SetText(self.bodygroupIndex[index].value)
				self.model.Entity:SetBodygroup(index, self.bodygroupIndex[index].value)

			end

			self.model.Entity:SetBodygroup(index, self.target:GetBodygroup(index))
		end
	end
end

function PANEL:SetViewModel(model)
	self.playerModel = model
	if model then
		self.model:SetModel(Model(model))
	end
end

vgui.Register("ixBodygroupView", PANEL, "DFrame")

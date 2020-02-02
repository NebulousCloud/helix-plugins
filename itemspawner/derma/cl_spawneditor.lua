
local PLUGIN = PLUGIN

local PANEL = {}

function PANEL:Init()
	self:SetSize(600, 240)
	self:Center()
	self:SetBackgroundBlur(true)
	self:SetDeleteOnClose(true)
	self:MakePopup()
end

function PANEL:Setup(item)
	self:SetTitle("Editing "..item.title)

	self.title = self:Add("DPanel")
	self.title:Dock(TOP)
	self.title:SetHeight(40)
	self.title:DockMargin(10, 10, 10, 10)

	self.delay = self:Add("DPanel")
	self.delay:Dock(TOP)
	self.delay:SetHeight(40)
	self.delay:DockMargin(10, 10, 10, 10)

	self.rare = self:Add("DPanel")
	self.rare:Dock(TOP)
	self.rare:SetHeight(40)
	self.rare:DockMargin(10, 10, 10, 10)

	self.save = self:Add("DPanel")
	self.save:Dock(BOTTOM)

	self.title.label = self.title:Add("DLabel")
	self.title.label:SetWide(80)
	self.title.label:DockMargin(20, 0, 0, 0)
	self.title.label:SetText("Label:")
	self.title.label:Dock(LEFT)
	self.title.label:SetFont("ixMediumFont")

	self.title.input = self.title:Add("DTextEntry")
	self.title.input:SetText(item.title)
	self.title.input:SetFont("ixMediumFont")
	self.title.input:Dock(FILL)

	self.delay.label = self.delay:Add("DLabel")
	self.delay.label:SetWide(80)
	self.delay.label:DockMargin(20, 0, 0, 0)
	self.delay.label:SetText("Delay:")
	self.delay.label:Dock(LEFT)
	self.delay.label:SetFont("ixMediumFont")

	self.delay.input = self.delay:Add("DTextEntry")
	self.delay.input:SetText(item.delay)
	self.delay.input:SetFont("ixMediumFont")
	self.delay.input:Dock(FILL)

	self.rare.label = self.rare:Add("DLabel")
	self.rare.label:SetWide(80)
	self.rare.label:DockMargin(20, 0, 0, 0)
	self.rare.label:SetText("Rare %:")
	self.rare.label:Dock(LEFT)
	self.rare.label:SetFont("ixMediumFont")

	self.rare.input = self.rare:Add("DTextEntry")
	self.rare.input:SetText(item.rarity)
	self.rare.input:SetFont("ixMediumFont")
	self.rare.input:Dock(FILL)

	self.save.button = self.save:Add("DButton")
	self.save.button:SetText("Save Changes")
	self.save.button:Dock(FILL)
	self.save.button.DoClick = function()
		local changes = {
			item.ID,
			self.title.input:GetValue(),
			self.delay.input:GetValue(),
			self.rare.input:GetValue()
		}
		net.Start("ixItemSpawnerChanges")
			net.WriteTable(changes)
		net.SendToServer()
	end

end

vgui.Register("ixItemSpawnerEditor", PANEL, "DFrame")

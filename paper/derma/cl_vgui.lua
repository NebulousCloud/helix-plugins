local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 700)	
	self:MakePopup()
	self:Center()
	self:SetTitle("Paper")

	self.controls = self:Add("DPanel")
	self.controls:Dock(BOTTOM)
	self.controls:SetTall(30)
	self.controls:DockMargin(0, 5, 0, 0)

	self.contents = self:Add("DTextEntry")
	self.contents:Dock(FILL)
	self.contents:SetMultiline(true)
	self.contents:SetEditable(false)

	self.confirm = self.controls:Add("DButton")
	self.confirm:Dock(RIGHT)
	self.confirm:SetDisabled(true)
	self.confirm:SetText(L("Finish"))

	self.controls.Paint = function(this, w, h)
		local text = self.contents:GetValue()
		draw.SimpleText(Format("Number of Characters: %s/2000", string.len(text)), "DermaDefault", 10, h/2, color_white, TEXT_ALIGN_LEFT, 1)
	end

	self.confirm.DoClick = function(this)
		local text = self.contents:GetValue()
		netstream.Start("paperSendText", self.id, text)
		self:Close()
	end
end

function PANEL:allowEdit(bool)
	if (bool == true) then
		self.contents:SetEditable(true)
		self.confirm:SetDisabled(false)
	else
		self.contents:SetEditable(false)
		self.confirm:SetDisabled(true)
	end
end

function PANEL:setText(text)
	self.contents:SetValue(text)
end

vgui.Register("paperRead", PANEL, "DFrame")
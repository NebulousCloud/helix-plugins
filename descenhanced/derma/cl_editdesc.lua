local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 700)	
	self:MakePopup()
	self:Center()
	self:SetTitle("Description détaillée")

	self.controls = self:Add("DPanel")
	self.controls:Dock(BOTTOM)
	self.controls:SetTall(30)
	self.controls:DockMargin(0, 5, 0, 0)

	self.contents = self:Add("DTextEntry")
	self.contents:Dock(FILL)
	self.contents:SetMultiline(true)
	self.contents:SetEditable(true)
	
	self.photo = self.controls:Add("DTextEntry")
	self.photo:Dock(FILL)
	self.photo:SetMultiline(true)
	self.photo:SetEditable(true)

	self.confirm = self.controls:Add("DButton")
	self.confirm:Dock(RIGHT)
	self.confirm:SetDisabled(false)
	self.confirm:SetText("Finish")
	
	
	self.confirm.DoClick = function(this)
		local text = self.contents:GetValue()
		local url = self.photo:GetValue()
		local character = LocalPlayer():GetCharacter()
		netstream.Start("descriptionSendText", text, url)
		print (url)
		self:Close()
	end

	self.controls.Paint = function(this, w, h)
		local text = self.contents:GetValue()
		local url = self.photo:GetValue()
		draw.SimpleText(Format(string.len(text)), "DermaDefault", 10, h/2, color_white, TEXT_ALIGN_LEFT, 1)
		draw.SimpleText(Format(string.len(url)), "DermaDefault", 10, h/2, color_white, TEXT_ALIGN_LEFT, 1)
	end
end

function PANEL:setText(text, url)
	self.contents:SetValue(text or "Place your description")
	self.photo:SetValue(url or "Place your link")
end

vgui.Register("descriptionEn", PANEL, "DFrame")
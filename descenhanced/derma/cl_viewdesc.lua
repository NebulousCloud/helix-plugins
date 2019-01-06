local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 700)	
	self:MakePopup()
	self:Center()
	self:SetTitle("Enhanced Description")

	self.controls = self:Add("DPanel")
	self.controls:Dock(BOTTOM)
	self.controls:SetTall(30)
	self.controls:DockMargin(0, 5, 0, 0)

	self.contents = self:Add("DTextEntry")
	self.contents:Dock(FILL)
	self.contents:SetMultiline(true)
	self.contents:SetEditable(false)
	
	self.test = self.controls:Add("DTextEntry")
	self.test:SetMultiline(true)
	self.test:SetSize(0,0)
	self.test:SetEditable(false)
	
	self.photo = self.controls:Add("DButton")
	self.photo:Dock(FILL)
	self.photo:SetText("See the picture of this character")
	self.photo:SetDisabled(false)

	self.confirm = self.controls:Add("DButton")
	self.confirm:Dock(RIGHT)
	self.confirm:SetDisabled(true)
	self.confirm:SetText("Finish")
	
	self.photo.DoClick = function (this)
		if (IsValid(PicturePanel)) then
			PicturePanel:Close()
			PicturePanel:Remove()
		end
		local url = self.test:GetValue()
		PicturePanel = vgui.Create("PictureDesc")
		PicturePanel:Populate(tostring(url))
		print (url)
		PicturePanel:MakePopup()
	end

	self.controls.Paint = function(this, w, h)
		local text = self.contents:GetValue()
		local url = self.test:GetValue()
	end
end

function PANEL:setText(text, url)
	self.contents:SetValue(text or "")
	self.test:SetText(url or "No Image found")
	url = url
end

vgui.Register("descriptionEnView", PANEL, "DFrame")
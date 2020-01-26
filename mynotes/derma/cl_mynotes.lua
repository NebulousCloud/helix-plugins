
local PLUGIN = PLUGIN

DEFINE_BASECLASS("DPanel")
local PANEL = {}

function PANEL:Init()
	if (IsValid(PLUGIN.panel)) then
		return
	end

	local character = LocalPlayer():GetCharacter()

	self:SetTitle(L("mynotes", character:GetName()))
	self:SetBackgroundBlur(true)
	self:SetDeleteOnClose(true)

	self:SetSize(400, 400)

	self.textEntry = self:Add("DTextEntry")
	self.textEntry:SetMultiline(true)
	self.textEntry:Dock(FILL)
	self.textEntry.SetRealValue = function(this, text)
		this:SetValue(text)
		this:SetCaretPos(text:len())
	end

	self.textEntry.Think = function(this)
		local text = this:GetValue()

		if (text:len() > PLUGIN.maxLength) then
			this:SetRealValue(text:sub(1, PLUGIN.maxLength))
			surface.PlaySound("common/talk.wav")
		end
	end

	self.button = self:Add("DButton")
	self.button:SetText(L("save"))
	self.button:Dock(BOTTOM)
	self.button.DoClick = function(this)
		net.Start("ixEditMyNotes")
			net.WriteString(self.textEntry:GetValue():sub(1, PLUGIN.maxLength))
		net.SendToServer()
	end

	self:MakePopup()
	self:Center()

	PLUGIN.panel = self
end

function PANEL:Populate(text)
	self.textEntry:SetText(text)
end

vgui.Register("ixMyNotes", PANEL, "DFrame")

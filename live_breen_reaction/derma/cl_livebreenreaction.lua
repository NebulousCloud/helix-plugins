
local overlayMat = Material("effects/combine_binocoverlay")


local PANEL = {}

function PANEL:Init()
	if (IsValid(ix.gui.breenReaction)) then
		ix.gui.breenReaction:Remove()
	end

	local CTO = ix.plugin.Get("cto")

	self:SetSize(300, 221)
	self:SetPos(ScrW() - self:GetWide() - 50, 50)

	ix.gui.breenReaction = self

	local title = self:Add("DLabel")
	title:Dock(TOP)
	title:DockMargin(5, 5, 5, 5)
	title:SetTall(30)
	title:SetText("LIVE DR. BREEN REACTION")
	title:SetFont("ixMediumFont")
	title:SetTextColor(color_white)
	title:SetContentAlignment(5)
	title.Paint = function(this, width, height)
		surface.SetDrawColor(Color(255, 0, 0))
		surface.DrawRect(0, 0, width, height)
	end

	-- Background
	self.barrierModelPanel = self:Add("DModelPanel")
	self.barrierModelPanel:Dock(FILL)
	self.barrierModelPanel:DockMargin(5, 0, 5, 5)
	self.barrierModelPanel:SetModel("models/props_combine/combine_barricade_med03b.mdl")
	self.barrierModelPanel:SetFOV(20)
	self.barrierModelPanel.Entity:SetPos(Vector(-150, -150, -25))
	self.barrierModelPanel.Entity:SetAngles(Angle(0, 45, 0))
	self.barrierModelPanel.LayoutEntity = function(this, entity) end

	-- Plant
	self.plantModelPanel = self.barrierModelPanel:Add("DModelPanel")
	self.plantModelPanel:Dock(FILL)
	self.plantModelPanel:SetModel("models/props/cs_office/plant01.mdl")
	self.plantModelPanel:SetFOV(20)
	self.plantModelPanel.Entity:SetPos(Vector(-80, -120, -15))
	self.plantModelPanel.Entity:SetAngles(Angle(0, 40, 0))
	self.plantModelPanel.LayoutEntity = function(this, entity) end

	-- Chair
	self.chairModelPanel = self.plantModelPanel:Add("DModelPanel")
	self.chairModelPanel:Dock(FILL)
	self.chairModelPanel:SetModel("models/props_combine/breenchair.mdl")
	self.chairModelPanel:SetFOV(20)
	self.chairModelPanel.Entity:SetPos(Vector(-12, -12, -17))
	self.chairModelPanel.Entity:SetAngles(Angle(0, 45, 0))
	self.chairModelPanel.LayoutEntity = function(this, entity) end

	-- The man himself
	self.breenModelPanel = self.chairModelPanel:Add("DModelPanel")
	self.breenModelPanel:Dock(FILL)
	self.breenModelPanel:SetModel("models/breen.mdl")
	self.breenModelPanel:SetFOV(20)
	self.breenModelPanel.Entity:SetPos(Vector(0, 0, -23))
	self.breenModelPanel.Entity:SetAngles(Angle(0, 45, 0))
	self.breenModelPanel.Entity:SetSequence(self.breenModelPanel.Entity:LookupSequence("idle02"))
	self.breenModelPanel.LayoutEntity = function(this, entity)
		this:RunAnimation()
		
		entity:SetFlexWeight(0, 1) -- right_lid_raiser
		entity:SetFlexWeight(1, 1) -- left_lid_raiser
		
		if (!CTO) then return end
		
		if (CTO.socioStatus == "GREEN") then
			-- HAPPY
			entity:SetFlexScale(1)
			entity:SetFlexWeight(42, 1) -- smile
		elseif (CTO.socioStatus == "BLUE") then
			-- NEUTRAL
			entity:SetFlexScale(1)
		elseif (CTO.socioStatus == "YELLOW") then
			-- ANNOYED
			entity:SetFlexScale(1.5)
			entity:SetFlexWeight(12, 1) -- right_outer_raiser
			entity:SetFlexWeight(13, 1) -- left_outer_raiser
			entity:SetFlexWeight(14, 1) -- right_lowerer
			entity:SetFlexWeight(15, 1) -- left_lowerer
			entity:SetFlexWeight(18, 1) -- wrinkler
		elseif (CTO.socioStatus == "RED") then
			-- ANGRY
			entity:SetFlexScale(1.5)
			entity:SetFlexWeight(12, 1) -- right_outer_raiser
			entity:SetFlexWeight(13, 1) -- left_outer_raiser
			entity:SetFlexWeight(14, 1) -- right_lowerer
			entity:SetFlexWeight(15, 1) -- left_lowerer
			entity:SetFlexWeight(18, 1) -- wrinkler
			entity:SetFlexWeight(35, 1) -- bite
			entity:SetFlexWeight(38, 1) -- jaw_clencher
		elseif (CTO.socioStatus == "BLACK") then
			-- VERY ANGRY
			entity:SetFlexScale(2)
			entity:SetFlexWeight(12, 1) -- right_outer_raiser
			entity:SetFlexWeight(13, 1) -- left_outer_raiser
			entity:SetFlexWeight(14, 1) -- right_lowerer
			entity:SetFlexWeight(15, 1) -- left_lowerer
			entity:SetFlexWeight(18, 1) -- wrinkler
			entity:SetFlexWeight(35, 1) -- bite
			entity:SetFlexWeight(38, 1) -- jaw_clencher
			entity:SetFlexWeight(39, 1) -- jaw_clencher
		end
	end

	-- make breen look up
	self.breenModelPanel.Entity:SetPoseParameter("head_pitch", -10)

	-- make breen's eyes look at the camera
	self.breenModelPanel.Entity:SetEyeTarget(Vector(100, 100, 30))

	-- make breen blink
	self:CreateBlinkTimer()
end

function PANEL:CreateBlinkTimer()
	timer.Simple(math.random(1, 10), function()
		if (!IsValid(self.breenModelPanel) or !IsValid(self.breenModelPanel.Entity)) then
			timer.Remove("ixLiveBreenReactionBlink")

			return
		end

		self.breenModelPanel.Entity:SetFlexWeight(9, 1) -- blink

		self:CreateBlinkTimer(self.breenModelPanel)
	end)
end

function PANEL:UpdateAmbientLight(lightColor)
	self.barrierModelPanel:SetAmbientLight(lightColor)
	self.plantModelPanel:SetAmbientLight(lightColor)
	self.chairModelPanel:SetAmbientLight(lightColor)
	self.breenModelPanel:SetAmbientLight(lightColor)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(color_white)
	surface.DrawRect(0, 0, width, height)
end

function PANEL:PaintOver(width, height)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(overlayMat)
	surface.DrawTexturedRect(0, 0, width, height)
end

vgui.Register("ixLiveBreenReaction", PANEL, "DPanel")

if (IsValid(ix.gui.breenReaction)) then
	vgui.Create("ixLiveBreenReaction")
end

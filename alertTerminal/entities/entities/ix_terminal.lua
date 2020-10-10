AddCSLuaFile()

local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Request Terminal"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 1, "Emergency")
	self:NetworkVar("Bool", 2, "Debounce")
	self:NetworkVar("String", 1, "Name")
end



if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_smallmonitor001.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Sleep()
	end

	function ENT:SpawnFunction(client, trace)
		local vendor = ents.Create("ix_terminal")
		
		vendor:SetPos(trace.HitPos + Vector(0, 0, 48))
		vendor:SetAngles(Angle(0, (vendor:GetPos() - client:GetPos()):Angle().y - 180, 0))
		vendor:Spawn()
		vendor:Activate()

		
		PLUGIN:SaveTerminals()
		return vendor
	end

	function ENT:Use(client)
if (client:GetArea()) then
		area = string.upper(client:GetArea()) or "UNKNOWN"
	end
		if (!self:GetNetVar("Emergency") and !client:IsCombine()) then
		self:SetNetVar("Emergency", true)
		self:SetNetVar("Debounce", false)
		self:SetNetVar("Name", client:GetName())
		ix.chat.Send(client, "alert", area)
		self:EmitSound("buttons/combine_button1.wav")
		elseif (client:IsCombine() and self:GetNetVar("Emergency")) then
		self:SetNetVar("Emergency", false)
		self:EmitSound("buttons/combine_button2.wav")
		elseif (client:IsCombine() and !self:GetNetVar("Emergency")) then
		self:EmitSound("buttons/combine_button_locked.wav")
		elseif (!client:IsCombine() and self:GetNetVar("Emergency")) then
		self:EmitSound("buttons/combine_button_locked.wav")
		end
	end

	function ENT:OnRemove()
	self:SetNetVar("Emergency", false)
	self:StopSound("ambient/alarms/combine_bank_alarm_loop4.wav")
		if (!ix.shuttingDown) then
		PLUGIN:SaveTerminals()
		end
	end
else
	

	local color_red = Color(100, 20, 20, 255)
	local color_blue = Color(0, 50, 100, 255)
	local color_black = Color(60, 60, 60, 255)

	local staticOverly = Material("effects/com_shield002a")
	local biOverlay = Material("effects/combine_binocoverlay")
	

	function ENT:Draw()
	local area = "UNKNOWN"
	
	if (LocalPlayer():GetArea()) then
		area = string.upper(LocalPlayer():GetArea()) or "UNKNOWN"
	end
		self:DrawModel()

		local position = self:GetPos()

		--[[if (LocalPlayer():GetPos():DistToSqr(position) > self.MaxRenderDistance) then
			return
		end]]--

		local angles = self:GetAngles()
		local forward, right, up = self:GetForward(), self:GetRight(), self:GetUp()

		angles:RotateAroundAxis(angles:Up(), 90)
		angles:RotateAroundAxis(angles:Forward(), 90)

		cam.Start3D2D(position + forward * 12.8 + right * 7 + up * 18.9, angles, 0.06)
			--[[render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)]]--

			local width = 280
			local smallWidth = 20
			local height = 250
			local halfWidth = width / 2
			local halfHeight = height / 2

			surface.SetFont( "ix3D2DSmallerFontStatic" )
			surface.SetTextColor( 255, 255, 255 )
			surface.SetTextPos( 15, 10 ) 
			surface.DrawText( "CMB:TMN.C17#".. string.upper(area))
			
			if (!self:GetNetVar("Emergency")) then
			
			self:StopSound("ambient/alarms/combine_bank_alarm_loop4.wav")

			draw.DrawText("WELCOME CITIZEN", "ix3D2DSmallFontStatic", halfWidth, 35, Color(255,255,255), TEXT_ALIGN_CENTER)

			draw.DrawText("BE WISE, BE SAFE, BE AWARE", "ix3D2DSmallerFontStatic", halfWidth, 60, Color(255,255,255), TEXT_ALIGN_CENTER)

			draw.DrawText("REQUEST CIVIL\nPROTECTION", "ix3D2DSmallishFontStatic", halfWidth, 100, Color(255,0,0), TEXT_ALIGN_CENTER)
			
			surface.SetMaterial(staticOverly)
			surface.SetDrawColor(0,25,100,20)
			surface.DrawTexturedRect(0, 0, width,height)
			surface.DrawRect(0,0,width,height)
			
			surface.SetMaterial(biOverlay)
			surface.SetDrawColor(0,50,50,150)
			surface.DrawRect(0,0,width,height)
			surface.DrawTexturedRect(0, 0, width,height)

			else
			
			local alpha = TimedSin(0.75, 90, 255, 150)
			

			draw.DrawText("EMERGENCY DECLARED", "ix3D2DSmallFontStatic", halfWidth, 35, Color(255,255,255,alpha), TEXT_ALIGN_CENTER)

			draw.DrawText("STAY WHERE YOU ARE", "ix3D2DSmallFontStatic", halfWidth, 65, Color(255,255,255,alpha), TEXT_ALIGN_CENTER)

			draw.DrawText("PROTECTION TEAM INBOUND", "ix3D2DSmallFontStatic", halfWidth, 95, Color(255,255,255,alpha), TEXT_ALIGN_CENTER)

			draw.DrawText("REPORTER: ".. string.upper(self:GetNetVar("Name")), "ix3D2DSmallFontStatic", halfWidth, 135, Color(255,255,255,alpha), TEXT_ALIGN_CENTER)

			surface.SetMaterial(staticOverly)
			surface.SetDrawColor(255,25,0,20)
			surface.DrawTexturedRect(0, 0, width,height)
			surface.DrawRect(0,0,width,height)

			surface.SetMaterial(biOverlay)
			surface.SetDrawColor(100,10,0,50)
			surface.DrawRect(0,0,width,height)
			surface.DrawTexturedRect(0, 0, width,height)

			if (!self:GetNetVar("Debounce")) then
				debounce = false
			
			else
				debounce = true
			end
			
			if (!debounce) then
			self:EmitSound("ambient/alarms/combine_bank_alarm_loop4.wav",350)
			debounce = true
			end
			end

			--[[render.PopFilterMin()
			render.PopFilterMag()]]--
		cam.End3D2D()
	end
end

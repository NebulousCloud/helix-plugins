
include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_interface001.mdl")

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:PhysicsUpdate(physicsObject)
	if (!self:IsPlayerHolding() and !self:IsConstrained()) then
		physicsObject:SetVelocity(Vector(0, 0, 0))
		physicsObject:Sleep()
	end
end

function ENT:OnOptionSelected(client, option, data)
	if (!client:IsCombine()) then
		client:Notify("You are not the Combine!")

		return
	end

	if (option == "Disable") then
		self:SetNWEntity("camera", self)
		self:EmitSound("weapons/ar2/ar2_reload_push.wav", 60)
	else
		local camID = string.sub(option, string.len("View C-i") + 1)
		local combineCamera = Entity(camID)

		if (IsValid(combineCamera) and combineCamera:GetClass() == "npc_combine_camera") then
			self:SetNWEntity("camera", combineCamera)
			self:EmitSound("weapons/ar2/ar2_reload_rotate.wav", 60)
		end
	end
end

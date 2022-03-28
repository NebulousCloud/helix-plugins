
local PLUGIN = PLUGIN

include("shared.lua")

function ENT:CreateTexMat()
	PLUGIN.terminalMaterialIdx = PLUGIN.terminalMaterialIdx + 1

	self.tex = GetRenderTarget("ctouniquert" .. PLUGIN.terminalMaterialIdx, 512, 256, false)
	self.mat = CreateMaterial("ctouniquemat" .. PLUGIN.terminalMaterialIdx, "UnlitGeneric", {
		["$basetexture"] = self.tex,
	})
end

function ENT:Think()
	if (!self.tex or !self.mat) then
		self:CreateTexMat()
	end

	PLUGIN.terminalsToDraw[self] = LocalPlayer():IsLineOfSightClear(self)
end

function ENT:Draw()
	self:DrawModel()
end

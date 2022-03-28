
include("shared.lua")

function ENT:CreateTexMat()
	ixCTO.terminalMaterialIdx = ixCTO.terminalMaterialIdx + 1

	self.tex = GetRenderTarget("ctouniquert" .. ixCTO.terminalMaterialIdx, 512, 256, false)
	self.mat = CreateMaterial("ctouniquemat" .. ixCTO.terminalMaterialIdx, "UnlitGeneric", {
		["$basetexture"] = self.tex,
	})
end

function ENT:Think()
	if (!self.tex or !self.mat) then
		self:CreateTexMat()
	end

	ixCTO.terminalsToDraw[self] = LocalPlayer():IsLineOfSightClear(self)
end

function ENT:Draw()
	self:DrawModel()
end

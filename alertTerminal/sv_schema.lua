
local PLUGIN = PLUGIN

function PLUGIN:SaveTerminals()
	local data = {}

	for _, v in ipairs(ents.FindByClass("ix_terminal")) do
		data[#data + 1] = {v:GetPos(), v:GetAngles()}
	end

	ix.data.Set("terminals", data)
end

function PLUGIN:LoadTerminals()
	for _, v in ipairs(ix.data.Get("terminals") or {}) do
		local vendor = ents.Create("ix_terminal")

		vendor:SetPos(v[1])
		vendor:SetAngles(v[2])
		vendor:Spawn()
	end
end
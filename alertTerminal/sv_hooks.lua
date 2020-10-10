
local PLUGIN = PLUGIN

function PLUGIN:LoadData()
	self:LoadTerminals()

	Schema.CombineObjectives = ix.data.Get("combineObjectives", {}, false, true)
end

function PLUGIN:SaveData()
	self:SaveTerminals()
end
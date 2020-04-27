
local PLUGIN = PLUGIN

function PLUGIN:OnLoaded()
	for _, path in ipairs(self.paths or {}) do
		ix.craft.LoadFromDir(path.."/recipes", "recipe")
		ix.craft.LoadFromDir(path.."/stations", "station")
	end
end

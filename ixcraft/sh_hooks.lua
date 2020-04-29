
local PLUGIN = PLUGIN

function PLUGIN:OnLoaded()
	for _, path in ipairs(self.paths or {}) do
		self.craft.LoadFromDir(path.."/recipes", "recipe")
		self.craft.LoadFromDir(path.."/stations", "station")
	end
end

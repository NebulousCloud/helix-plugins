
local PLUGIN = PLUGIN

local STATION = ix.meta.station or {}
STATION.__index = STATION
STATION.name = "undefined"
STATION.description = "undefined"
STATION.uniqueID = "undefined"

function STATION:GetModel()
	return self.model
end

ix.meta.station = STATION

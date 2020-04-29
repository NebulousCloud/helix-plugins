
local PLUGIN = PLUGIN
PLUGIN.meta = PLUGIN.meta or {}

local STATION = PLUGIN.meta.station or {}
STATION.__index = STATION
STATION.name = "undefined"
STATION.description = "undefined"
STATION.uniqueID = "undefined"

function STATION:GetModel()
	return self.model
end

PLUGIN.meta.station = STATION


local PLUGIN = PLUGIN

PLUGIN.name = "Consulcast"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Adds ambient industrial (beta) announcement broadcasts to the city."
PLUGIN.schema = "HL2 RP"
PLUGIN.license = [[
Copyright 2022 wowm0d
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
]]

ix.config.Add("consulcastDelay", 300, "How long of a delay inbetween Consulcasts in seconds.", function()
	if (SERVER) then
		PLUGIN:OnLoaded()
	end
end, {
	data = {min = 1, max = 3600},
	category = "server"
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")


local PLUGIN = PLUGIN

net.Receive("ixItemSpawnerManager", function()
	local items = net.ReadTable()
	local panel = vgui.Create("ixItemSpawnerManager")
	panel:Populate(items)
end)


net.Receive("ixItemSpawnerManager", function()
	vgui.Create("ixItemSpawnerManager"):Populate(net.ReadTable())
end)

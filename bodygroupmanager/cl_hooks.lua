
net.Receive("ixBodygroupView", function()
	vgui.Create("ixBodygroupView"):Display(net.ReadEntity())
end)

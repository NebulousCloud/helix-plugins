
net.Receive("ixBodygroupView", function()
    local target = net.ReadEntity()
    local panel = vgui.Create("ixBodygroupView")
    panel:Display(target)
end)

net.Receive("SBMOpenMenu", function()
    local target = net.ReadPlayer()
    vgui.Create("ixCambiadorBodygroups"):Fill(target)
end)
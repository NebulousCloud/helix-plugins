util.AddNetworkString("SBMOpenMenu")
util.AddNetworkString("SBMSaveBodygroups")


net.Receive("SBMSaveBodygroups", function(_, ply)
    local target = net.ReadPlayer()
    local tblBodygroups = net.ReadTable()
    local skin = net.ReadUInt(5)
    local playerColor = net.ReadVector()


    if (!target or !target:IsPlayer() or !target:GetCharacter()) then return end

    for id, val in ipairs(tblBodygroups) do
        target:SetBodygroup(id, val)
    end

    target:SetSkin(skin)
    target:GetCharacter():SetData("groups", tblBodygroups)
    target:SetPlayerColor(playerColor)

    target:GetCharacter():SetData("SBMPlayerColor", playerColor)

end)
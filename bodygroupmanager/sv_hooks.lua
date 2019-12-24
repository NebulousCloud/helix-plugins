util.AddNetworkString("ixBodygroupTableSet")

ix.log.AddType("bodygroupEditor", function(client, target)
    return string.format("%s has changed %s's bodygroups.", client:GetName(), target:GetName())
end)

net.Receive("ixBodygroupTableSet", function(length, client)
    local target = net.ReadEntity()
    local bodygroups = net.ReadTable()
    if (client:IsAdmin()) then
        for k, v in pairs(bodygroups) do
            target:SetBodygroup(k, v)
        end
        ix.log.Add(client, "bodygroupEditor", client, target)
    end
end)

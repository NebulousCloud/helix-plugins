util.AddNetworkString("ixBodygroupView")
util.AddNetworkString("ixBodygroupTableSet")

ix.log.AddType("bodygroupEditor", function(client, target)
    return string.format("%s has changed %s's bodygroups.", client:GetName(), target:GetName())
end)

net.Receive("ixBodygroupTableSet", function(length, client)
    if (!ix.command.HasAccess(client, "CharEditBodygroup")) then
        return
    end

    local target = net.ReadEntity()

    if (!IsValid(target) or !target:IsPlayer() or !target:GetCharacter()) then
        return
    end

    local bodygroups = net.ReadTable()

    for k, v in pairs(bodygroups) do
        target:SetBodygroup(tonumber(k) or 0, tonumber(v) or 0)
    end

    ix.log.Add(client, "bodygroupEditor", target)
end)

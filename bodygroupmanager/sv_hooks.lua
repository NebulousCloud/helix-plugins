local PLUGIN = PLUGIN

netstream.Hook("ixBodygroupTableSet", function(client, target, bodygroups)
    ix.log.Add(client, "editbodygroup", target)
    for k, v in pairs(bodygroups) do
        target.player:SetBodygroup(k, v)
    end
end)

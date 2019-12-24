local PLUGIN = PLUGIN

netstream.Hook("ixBodygroupTableSet", function(client, target, bodygroups)
    if (client:IsAdmin()) then
        for k, v in pairs(bodygroups) do
            target.player:SetBodygroup(k, v)
        end
    end
end)

local PLUGIN = PLUGIN

net.Receive("helix_setcrowinventorysize", function()
    if LocalPlayer():Team() == FACTION_BIRD then
        local character = LocalPlayer():GetCharacter()
        local inventory = character:GetInventory()
        if ix.config.Get("birdInventory", true) then
            inventory:SetSize(2,1)
        end

        local hull = Vector(10, 10, 10)
        LocalPlayer():SetHull(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
        LocalPlayer():SetHullDuck(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
    end
end)

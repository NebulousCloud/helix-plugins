FACTION.name = "Bird"
FACTION.description = "A regular bird surviving on scrap and food."
FACTION.color = Color(128, 128, 128, 255)
FACTION.isDefault = false
FACTION.bAllowDatafile = false

FACTION.models = {
	"models/crow.mdl",
	"models/pigeon.mdl"
}

function FACTION:OnSpawn(client)
	local character = client:GetCharacter()
	local inventory = character:GetInventory()
    timer.Simple(.1, function()
        local hull = Vector(10, 10, 10)
        client:SetHull(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
        client:SetHullDuck(-Vector(hull.x / 2, hull.y / 2, 0), Vector(hull.x / 2, hull.y / 2, hull.z))
        client:SetViewOffset(Vector(0,0,10))
        client:SetViewOffsetDucked(Vector(0,0,10))
        client:SetCurrentViewOffset(Vector(0,10,0))
		if ix.config.Get("birdInventory", true) then
			inventory:SetSize(2,1)
		end
        if CLIENT then return end
        client:SetWalkSpeed(25)
        client:SetRunSpeed(50)
        client:SetMaxHealth(ix.config.Get("birdHealth", 2))
        client:SetHealth(ix.config.Get("birdHealth", 2))
        client:Give("ix_bird")
        client:StripWeapon("ix_hands")
    end)
end

FACTION_BIRD = FACTION.index

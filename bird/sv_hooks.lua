local PLUGIN = PLUGIN

function PLUGIN:PrePlayerLoadedCharacter(client, character, currentChar)
    if (IsValid(currentChar) and currentChar:GetFaction() != FACTION_ZOMBIE and currentChar:GetFaction() != FACTION_BIRD) then return end
    client:SetMaxHealth(100)
    client:SetViewOffset(Vector(0,0,64))
    client:SetViewOffsetDucked(Vector(0, 0, 32))
    client:ResetHull()
    client:SetWalkSpeed(ix.config.Get("walkSpeed"))
    client:SetRunSpeed(ix.config.Get("runSpeed"))
end

function PLUGIN:PlayerSpawn(client)
    if client:Team() == FACTION_BIRD then
        timer.Simple(.1, function()
            client:SetWalkSpeed(25)
            client:SetRunSpeed(50)
            client:SetMaxHealth(ix.config.Get("birdHealth", 2))
            client:SetHealth(ix.config.Get("birdHealth", 2))
            client:Give("ix_bird")
            client:StripWeapon("ix_hands")
        end)
    end
end

function PLUGIN:CanPlayerDropItem(client, item)
    if client:Team() == FACTION_BIRD and !ix.config.Get("birdAllowItemInteract", true) then
        return false
    end
end

function PLUGIN:CanPlayerTakeItem(client, item)
    if client:Team() == FACTION_BIRD and !ix.config.Get("birdAllowItemInteract", true) then
        return false
    end
end

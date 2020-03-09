PLUGIN.name = "Legs wyjebnik"
PLUGIN.author = "Lechu2375"
PLUGIN.description = "Now hitting right in the legs causes injures."
PLUGIN.license =  "MIT not for use on Kaktusownia"
if SERVER then
    local legs = {
        [HITGROUP_LEFTLEG] = true,
        [HITGROUP_RIGHTLEG] = true
    }
    local resFactions = {  --table with factions enums that should be resistant to these effects
        [FACTION_OTA] = true
    }
    function PLUGIN:ScalePlayerDamage(ply,hitgroup,dmginfo )
        local char = ply:GetCharacter()
        if char then
            if resFactions[char:GetFaction()] then return end
            if legs[hitgroup] then
                local chance = math.random(1,100)
                if (chance<=40) then
                    ply:SetRagdolled(true, 10)   
                    --else -- negotiable, I havent tested this.
                    -- char:AddBoost("legShoot","stm",-50)   
                    --  char:AddBoost("legShoot","stamina",-60)     
                end
            end
        end
    end
end
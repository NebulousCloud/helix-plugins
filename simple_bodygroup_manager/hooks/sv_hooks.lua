function PLUGIN:PlayerButtonDown(ply, button)
    if (!ply:GetCharacter()) then return end

    if (button == SBM.config.keyOptions.key) then
        if (SBM.banned[ply:SteamID()]) then return end
        if (!ix.config.Get("allowKeyUseBGManager") and !SBM.config.keyOptions.factionBypass[ix.faction.Get(ply:GetCharacter():GetFaction()).uniqueID]) then return end
        net.Start("SBMOpenMenu")
            net.WritePlayer(ply)
        net.Send(ply)
    end
end
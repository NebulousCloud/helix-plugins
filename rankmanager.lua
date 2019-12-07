--[[

    Overwatch Rank Manager for Helix

    Installation:
    
    1. Edit the OWRankManager.rankTable table to fit your rank needs.
    2. Place this Lua file into your schema plugin directory.
    3. Enable allowRankManager in your server config

]]


PLUGIN.name = "Overwatch Rank Manager"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows Overwatch to manage ranks."

OWRankManager = OWRankManager or {}

ix.lang.AddTable("english", {
    allowRankManager = "Allow Overwatch Rank Manager",
    cmdRankDemote = "Demote an active Overwatch functionary.",
    cmdRankPromote = "Promote an active Overwatch functionary.",
    cRankConfigDisabled = "Rank Management is currently disabled.",
    cRankPromotion = "%s has promoted %s to %s.",
    cRankDemotion = "%s has demoted %s to %s.",
    cRankMaxRank = "%s is already the maximum rank.",
    cRankMinRank = "%s is already the minimum rank.",
    cRankInvalidRank = "%s is an invalid rank, cannot promote/demote.",
    cRankInvalidFaction = "%s is not in a valid faction."
})

ix.config.Add("allowRankManager", false, "Enable/Disable Overwatch ability to manage ranks.", nil, {
    category = "Overwatch"
})

--[[ Uses faction uniqueID => ix.faction.indices[player:GetFaction()].uniqueID ]]--
OWRankManager.rankTable = {
    ['metropolice'] = {"00", "10", "20", "30", "40", "50", "60", "70", "80", "90", "RL"},
    ['ota'] = {"OWS", "OWC", "EOW", "EOC"  }
}

OWRankManager.FindFaction = function(player)
    local playerUniqueID = ix.faction.indices[player:GetFaction()].uniqueID
    for k, v in pairs(OWRankManager.rankTable) do
        if playerUniqueID == k then return v end
    end
    return false
end

ix.command.Add("RankPromote", {
    description = "@cmdRankPromote",
    arguments = {
        ix.type.character,
        bit.bor(ix.type.string, ix.type.optional)
    },
    OnRun = function(self, client, target, rank)
        if client:IsDispatch() then
            --[[ Overwatch : allowRankManager ]]--
            if ix.config.Get("allowRankManager") then
                local ranks = OWRankManager.FindFaction(target)
                local originalName = target:GetName()
                if ranks then

                    for _, v in ipairs(ranks) do
                        local search = v

                        if string.find(target:GetName(), search) then
                            local newKey = table.KeyFromValue(ranks, search) + 1

                            if !(#ranks < newKey) then
                                local newRank = ranks[table.KeyFromValue(ranks, search) + 1]
                                local newName = string.gsub(target:GetName(), search, newRank)
                                target:SetName(newName:gsub('#', '#'))

                                for _1, v1 in ipairs(player.GetAll()) do
                                    if (self:OnCheckAccess(v1) or v1 == target:GetPlayer()) then
                                        v1:NotifyLocalized("cRankPromotion", client:GetName(), originalName, newName)
                                    end
                                end

                                --[[ Break out of the OnRun function or else it loops till error ]]--
                                return
                            else
                                client:NotifyLocalized("cRankMaxRank", target:GetName())
                                return
                            end
                        end
                    end
                    client:NotifyLocalized("cRankInvalidRank", target:GetName())

                else
                    client:NotifyLocalized("cRankInvalidFaction", target:GetName())
                    return
                end
            else
                return "@cRankConfigDisabled"
            end
        else
            return "@notNow"
        end
    end
})

ix.command.Add("RankDemote", {
    description = "@cmdRankDemote",
    arguments = {
        ix.type.character,
        bit.bor(ix.type.string, ix.type.optional)
    },
    OnRun = function(self, client, target, rank)
        if client:IsDispatch() then
            --[[ Overwatch : allowRankManager ]]--
            if ix.config.Get("allowRankManager") then
                local ranks = OWRankManager.FindFaction(target)
                local originalName = target:GetName()
                if ranks then

                    for _, v in ipairs(ranks) do
                        local search = v

                        if string.find(target:GetName(), search) then
                            local newKey = table.KeyFromValue(ranks, search) - 1

                            if !(1 > newKey) then
                                local newRank = ranks[table.KeyFromValue(ranks, search) - 1]
                                local newName = string.gsub(target:GetName(), search, newRank)
                                target:SetName(newName:gsub('#', '#'))

                                for _1, v1 in ipairs(player.GetAll()) do
                                    if (self:OnCheckAccess(v1) or v1 == target:GetPlayer()) then
                                        v1:NotifyLocalized("cRankDemotion", client:GetName(), originalName, newName)
                                    end
                                end

                                --[[ Break out of the OnRun function or else it loops till error ]]--
                                return
                            else
                                client:NotifyLocalized("cRankMinRank", target:GetName())
                                return
                            end
                        end
                    end
                    client:NotifyLocalized("cRankInvalidRank", target:GetName())

                else
                    client:NotifyLocalized("cRankInvalidFaction", target:GetName())
                    return
                end
            else
                client:NotifyLocalized("cRankConfigDisabled")
            end
        else
            return "@notNow"
        end
    end
})

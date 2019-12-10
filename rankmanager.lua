--[[

    Overwatch Rank Manager for Helix

    Installation:
    
    1. Edit the self.rankTable variable within PLUGIN:OnLoaded() to fit your rank needs.
    2. Place this Lua file into your schema plugin directory.
    3. Enable allowRankManager in your server config

]]

local PLUGIN = PLUGIN

PLUGIN.name = "Overwatch Rank Manager"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows Overwatch to manage ranks."
PLUGIN.rankTable = PLUGIN.rankTable or {}

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
    cRankInvalidFaction = "%s is not in a valid faction.",
    cRankInvalidInput = "%s is not a valid rank."
})

ix.config.Add("allowRankManager", false, "Enable/Disable Overwatch ability to manage ranks.", nil, {
    category = "Overwatch"
})

function PLUGIN:OnLoaded()
    timer.Simple(0, function()
        self.rankTable = {
            [FACTION_MPF] = {"00", "10", "20", "30", "40", "50", "60", "70", "80", "90", "RL"},
            [FACTION_OTA] = {"OWS", "OWC", "EOW", "EOC"  }
        }
    end)
end

ix.command.Add("RankPromote", {
    description = "@cmdRankPromote",
    arguments = {
        ix.type.character,
        bit.bor(ix.type.string, ix.type.optional)
    },
    OnCheckAccess = function(self, client)
        return client:IsDispatch()
    end,
    OnRun = function(self, client, target, optRank)
        local faction = target:GetFaction()
        local ranks = PLUGIN.rankTable[faction]
        local name = target:GetName()
        local newKey, inputRank

        -- Overwatch : Allow Rank Manager [True:False]
        if ix.config.Get("allowRankManager") then
            local originalName = target:GetName()

            -- Checks if player is in a valid faction from self.rankTable
            if (ranks) then
                for _, v in ipairs(ranks) do
                    if string.find(name, v) then

                        if optRank then
                            inputRank = table.KeyFromValue(ranks, string.upper(optRank))
                            if !inputRank then
                                return "@cRankInvalidInput", optRank
                            end
                        end

                        if inputRank then
                            newKey = inputRank
                        else
                            newKey = table.KeyFromValue(ranks, v) + 1
                        end

                        if !(#ranks < newKey) then
                            local newRank = ranks[newKey]
                            local newName = string.gsub(target:GetName(), v, newRank)
                            target:SetName(newName:gsub('#', '#'))

                            for _1, v1 in ipairs(player.GetAll()) do
                                if (self:OnCheckAccess(v1) or v1 == target:GetPlayer()) then
                                    v1:NotifyLocalized("cRankPromotion", client:GetName(), originalName, newName)
                                end
                            end

                            -- Break out of the OnRun function or else it loops till error
                            return
                        else
                            return "@cRankMaxRank", target:GetName()
                        end
                    end
                end
                return "@cRankInvalidRank", target:GetName()
            else
                return "@cRankInvalidFaction", target:GetName()
            end
        else
            return "@cRankConfigDisabled"
        end
    end
})

ix.command.Add("RankDemote", {
    description = "@cmdRankDemote",
    arguments = {
        ix.type.character,
        bit.bor(ix.type.string, ix.type.optional)
    },
    OnCheckAccess = function(self, client)
        return client:IsDispatch()
    end,
    OnRun = function(self, client, target, optRank)
        local faction = target:GetFaction()
        local ranks = PLUGIN.rankTable[faction]
        local name = target:GetName()
        local newKey, inputRank

        -- Overwatch : Allow Rank Manager [True:False]
        if ix.config.Get("allowRankManager") then
            local originalName = target:GetName()

            -- Checks if player is in a valid faction from self.rankTable
            if (ranks) then
                for _, v in ipairs(ranks) do
                    if string.find(name, v) then

                        if optRank then
                            inputRank = table.KeyFromValue(ranks, string.upper(optRank))
                            if !inputRank then
                                return "@cRankInvalidInput", optRank
                            end
                        end

                        if inputRank then
                            newKey = inputRank
                        else
                            newKey = table.KeyFromValue(ranks, v) - 1
                        end

                        if !(1 > newKey) then
                            local newRank = ranks[newKey]
                            local newName = string.gsub(target:GetName(), v, newRank)
                            target:SetName(newName:gsub('#', '#'))

                            for _1, v1 in ipairs(player.GetAll()) do
                                if (self:OnCheckAccess(v1) or v1 == target:GetPlayer()) then
                                    v1:NotifyLocalized("cRankDemotion", client:GetName(), originalName, newName)
                                end
                            end

                            -- Break out of the OnRun function or else it loops till error
                            return
                        else
                            return "@cRankMinRank", target:GetName()
                        end
                    end
                end

                return "@cRankInvalidRank", target:GetName()
            else
                return "@cRankInvalidFaction", target:GetName()
            end
        else
            return "@cRankConfigDisabled"
        end
    end
})

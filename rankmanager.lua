--[[

    Overwatch Rank Manager for Helix

    Installation:
        1. Edit the self.rankTable variable within PLUGIN:OnLoaded() to fit your rank needs.
        2. Place this Lua file into your schema plugin directory.

]]

local PLUGIN = PLUGIN

PLUGIN.name = "Overwatch Rank Manager"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows Overwatch to manage ranks."
PLUGIN.rankTable = PLUGIN.rankTable or {}

ix.lang.AddTable("english", {
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
    OnRun = function(self, client, target, rank)
        local ranks = PLUGIN.rankTable[target:GetFaction()]

        -- Checks if player is in a valid faction from rankTable
        if (istable(ranks)) then
            local name = target:GetName()
            local newRank

            if (rank) then
                newRank = table.KeyFromValue(ranks, string.upper(rank))

                if (!newRank) then
                    return "@cRankInvalidInput", rank
                end
            else
                if (string.find(name, ranks[#ranks])) then
                    return "@cRankMaxRank", name
                end

                for k, v in ipairs(ranks) do
                    if (string.find(name, v)) then
                        newRank = next(ranks, k)

                        break
                    end
                end
            end

            if (newRank) then
                newRank = ranks[newRank]

                local newName = name:gsub("%:([%w]+)%.",
                    string.format(":%s.", newRank)
                )

                target:SetName(newName)

                for _, v in ipairs(player.GetAll()) do
                    if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
                        v:NotifyLocalized("cRankPromotion", client:GetName(), name, newName)
                    end
                end
            else
                return "@cRankInvalidRank", name
            end
        else
            return "@cRankInvalidFaction", target:GetName()
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
    OnRun = function(self, client, target, rank)
        local ranks = PLUGIN.rankTable[target:GetFaction()]

        -- Checks if player is in a valid faction from rankTable
        if (istable(ranks)) then
            local name = target:GetName()
            local newRank

            if (rank) then
                newRank = table.KeyFromValue(ranks, string.upper(rank))

                if (!newRank) then
                    return "@cRankInvalidInput", rank
                end
            else
                if (string.find(name, ranks[1])) then
                    return "@cRankMinRank", name
                end

                for k, v in ipairs(ranks) do
                    if (string.find(name, v)) then
                        newRank = math.Clamp(k - 1, 1, #ranks)

                        break
                    end
                end
            end

            if (newRank) then
                newRank = ranks[newRank]

                local newName = name:gsub("%:([%w]+)%.",
                    string.format(":%s.", newRank)
                )

                target:SetName(newName)

                for _, v in ipairs(player.GetAll()) do
                    if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
                        v:NotifyLocalized("cRankDemotion", client:GetName(), name, newName)
                    end
                end
            else
                return "@cRankInvalidRank", name
            end
        else
            return "@cRankInvalidFaction", target:GetName()
        end
    end
})

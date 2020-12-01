
local PLUGIN = PLUGIN

PLUGIN.name = "Overwatch Rank Manager"
PLUGIN.author = "Gary Tate, wowm0d"
PLUGIN.description = "Allows Overwatch to manage ranks."
PLUGIN.schema = "HL2 RP"
PLUGIN.version = "1.3"
PLUGIN.readme = [[
Overwatch Rank Manager for Helix
---
Installation:
- Edit the PLUGIN.rankTable variable at line 50 to fit your rank needs.
- Place rankmanager.Lua file into your Schema's Plugin directory.

Support for this plugin can be found here: https://discord.gg/mntpDMU
]]
PLUGIN.license = [[
The MIT License (MIT)
Copyright (c) 2019 Gary Tate
Copyright (c) 2020 wowm0d
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.lang.AddTable("english", {
	cmdCharRankDemote = "Demote an active Overwatch functionary.",
	cmdCharRankPromote = "Promote an active Overwatch functionary.",
	cmdCharRankSet = "Set the rank of an active Overwatch functionary.",
	cRankPromotion = "%s has promoted %s to %s.",
	cRankDemotion = "%s has demoted %s to %s.",
	cRankSet = "%s has set %s's rank to %s.",
	cRankMaxRank = "%s is already the maximum rank.",
	cRankMinRank = "%s is already the minimum rank.",
	cRankSameRank = "%s is already %s rank.",
	cRankInvalidRank = "%s is an invalid rank, cannot change their rank.",
	cRankInvalidFaction = "%s is not in a valid faction.",
	cRankInvalidInput = "'%s' is not a valid rank."
})

function PLUGIN:CanPlayerSetRanks(client)
	if (client:IsDispatch()) then
		return true
	end
end

if (SERVER) then
	timer.Simple(0, function()
		PLUGIN.rankTable = {
			[FACTION_MPF] = {"00", "10", "20", "30", "40", "50", "60", "70", "80", "90", "RL"},
			[FACTION_OTA] = {"OWS", "OWC", "EOW", "EOC"}
		}

		-- Ignore Below --

		PLUGIN.rankMap = {}

		for _, ranks in next, PLUGIN.rankTable do
			PLUGIN.rankMap[ranks] = {}

			for index, rank in next, ranks do
				PLUGIN.rankMap[ranks][rank:lower()] = index
			end
		end
	end)
end

ix.command.Add("CharRankSet", {
	description = "@cmdCharRankSet",
	arguments = {
		ix.type.character,
		ix.type.string
	},
	OnCheckAccess = function(_, client)
		return hook.Run("CanPlayerSetRanks", client) == true
	end,
	OnRun = function(self, client, target, rank)
		local targetRanks = PLUGIN.rankTable[target:GetFaction()]

		if (!targetRanks) then
			return "@cRankInvalidFaction", target:GetName()
		end

		local newRank = PLUGIN.rankMap[targetRanks][rank:lower()]

		if (!newRank) then
			return "@cRankInvalidInput", rank
		end

		local name = target:GetName()

		for index, rank in next, targetRanks do
			if (string.find(name, "[%D+]" .. rank .. "[%D+]")) then
				if (newRank == index) then
					return "@cRankSameRank", name, rank
				end

				newRank = targetRanks[newRank]

				target:SetName(string.gsub(name, "([%D+])" .. rank .. "([%D+])", "%1" .. newRank .. "%2"))

				for _, v in next, player.GetAll() do
					if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
						v:NotifyLocalized("cRankSet", client:GetName(), name, newRank)
					end
				end

				return
			end
		end

		return "@cRankInvalidRank", name
	end
})

ix.command.Add("CharRankPromote", {
	description = "@cmdCharRankPromote",
	arguments = ix.type.character,
	OnCheckAccess = function(_, client)
		return hook.Run("CanPlayerSetRanks", client) == true
	end,
	OnRun = function(self, client, target)
		local targetRanks = PLUGIN.rankTable[target:GetFaction()]

		if (!targetRanks) then
			return "@cRankInvalidFaction", target:GetName()
		end

		local name = target:GetName()

		for index, rank in next, targetRanks do
			if (string.find(name, "[%D+]" .. rank .. "[%D+]")) then
				if (index == #targetRanks) then
					return "@cRankMaxRank", name
				end

				local newRank = targetRanks[index + 1]

				target:SetName(string.gsub(name, "([%D+])" .. rank .. "([%D+])", "%1" .. newRank .. "%2"))

				for _, v in next, player.GetAll() do
					if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
						v:NotifyLocalized("cRankPromotion", client:GetName(), name, newRank)
					end
				end

				return
			end
		end

		return "@cRankInvalidRank", name
	end
})

ix.command.Add("CharRankDemote", {
	description = "@cmdCharRankDemote",
	arguments = ix.type.character,
	OnCheckAccess = function(_, client)
		return hook.Run("CanPlayerSetRanks", client) == true
	end,
	OnRun = function(self, client, target)
		local targetRanks = PLUGIN.rankTable[target:GetFaction()]

		if (!targetRanks) then
			return "@cRankInvalidFaction", target:GetName()
		end

		local name = target:GetName()

		for index, rank in next, targetRanks do
			if (string.find(name, "[%D+]" .. rank .. "[%D+]")) then
				if (index == 1) then
					return "@cRankMinRank", name
				end

				local newRank = targetRanks[index - 1]

				target:SetName(string.gsub(name, "([%D+])" .. rank .. "([%D+])", "%1" .. newRank .. "%2"))

				for _, v in next, player.GetAll() do
					if (self:OnCheckAccess(v) or v == target:GetPlayer()) then
						v:NotifyLocalized("cRankDemotion", client:GetName(), name, newRank)
					end
				end

				return
			end
		end

		return "@cRankInvalidRank", name
	end
})

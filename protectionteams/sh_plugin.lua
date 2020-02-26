
local PLUGIN = PLUGIN

PLUGIN.name = "Protection Teams"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Adds joinable squads to the tab menu."
PLUGIN.schema = "HL2 RP"
PLUGIN.license = [[
Copyright 2020 wowm0d
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
]]

PLUGIN.teams = {}

function PLUGIN:GetRecievers()
	local recievers = {}

	for _, client in pairs(player.GetAll()) do
		if (client:IsCombine()) then
			table.insert(recievers, client)
		end
	end

	return recievers
end

ix.util.Include("cl_plugin.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

ix.command.Add("PTCreate", {
	description = "@cmdPTCreate",
	arguments = bit.bor(ix.type.number, ix.type.optional),
	OnRun = function(self, client, index)
		if (!client:IsCombine()) then
			return "@CannotUseTeamCommands"
		end

		if (!index) then
			return client:RequestString("@cmdPTCreate", "@cmdCreatePTDesc", function(text) ix.command.Run(client, "PTCreate", {text}) end, "")
		end

		return PLUGIN:CreateTeam(client, index)
	end
})

ix.command.Add("PTJoin", {
	description = "@cmdPTJoin",
	arguments = ix.type.number,
	OnRun = function(self, client, index)
		if (!client:IsCombine()) then
			return "@CannotUsePTCommands"
		end

		return PLUGIN:JoinTeam(client, index)
	end
})

ix.command.Add("PTLeave", {
	description = "@cmdPTLeave",
	OnRun = function(self, client)
		if (!client:IsCombine()) then
			return "@CannotUsePTCommands"
		end

		return PLUGIN:LeaveTeam(client)
	end
})

ix.command.Add("PTLead", {
	description = "@cmdPTLead",
	arguments = bit.bor(ix.type.player, ix.type.optional),
	OnRun = function(self, client, target)
		if (!client:IsCombine()) then
			return "@CannotUseTeamCommands"
		end

		local index

		if (target == client or !target) then
			index = client.curTeam

			if (!PLUGIN.teams[index]) then return "@NoCurrentTeam" end

			if (!PLUGIN.teams[index]["owner"]) then
				target = client
			else
				return "@TeamAlreadyHasOwner"
			end
		elseif (target) then
			index = target.curTeam

			if (!PLUGIN.teams[index]) then return "@TargetNoCurrentTeam" end

			if (client.curTeam != target.curTeam and !client:IsDispatch()) then return "@TargetNotSameTeam" end

			if (!client.isTeamOwner and !client:IsDispatch()) then return "@CannotPromoteTeamMembers" end
		end

		if (target == client or !target) then
			if (PLUGIN:SetTeamOwner(index, target)) then
				return "@TeamOwnerAssume"
			end
		end

		return PLUGIN:SetTeamOwner(index, target)
	end
})

ix.command.Add("PTKick", {
	description = "@cmdPTKick",
	arguments = ix.type.player,
	OnRun = function(self, client, target)
		if (!client:IsCombine()) then
			return "@CannotUseTeamCommands"
		end

		local index = target.curTeam

		if (!PLUGIN.teams[index]) then return "@TargetNoCurrentTeam" end

		if (client.curTeam != target.curTeam and !client:IsDispatch()) then return "@TargetNotSameTeam" end

		if (!client.isTeamOwner and !client:IsDispatch()) then return "@CannotKickTeamMembers" end

		PLUGIN:LeaveTeam(target)

		return "@KickedFromTeam", target:GetName()
	end
})

ix.command.Add("PTReassign", {
	description = "@cmdPTReassign",
	arguments = ix.type.number,
	OnRun = function(self, client, newIndex)
		if (!client:IsCombine()) then
			return "@CannotUseTeamCommands"
		end

		local index = client.curTeam

		if (!index) then
			return "@CannotUseTeamCommands"
		end

		if (!PLUGIN.teams[index]) then
			return "@TeamNonExistent", tostring(index)
		end

		if (!client.isTeamOwner and !client:IsDispatch()) then return "@CannotReassignTeamIndex" end

		return PLUGIN:ReassignTeam(index, newIndex)
	end
})

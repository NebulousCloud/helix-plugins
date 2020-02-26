
local PLUGIN = PLUGIN

util.AddNetworkString("ixPTSync")
util.AddNetworkString("ixPTCreate")
util.AddNetworkString("ixPTDelete")
util.AddNetworkString("ixPTJoin")
util.AddNetworkString("ixPTLeave")
util.AddNetworkString("ixPTOwner")
util.AddNetworkString("ixPTReassign")

function PLUGIN:CreateTeam(client, index, bNetworked)
	if (IsValid(client) and client.curTeam) then
		return "@AlreadyHasTeam"
	end

	if (self.teams[index]) then
		return "@TeamAlreadyExists", tostring(index)
	end

	if (index > 99 or index < 1) then
		return "@TeamMustClamp"
	end

	self.teams[index] = {
		owner = client,
		members = {client}
	}

	if (IsValid(client)) then
		client.curTeam = index
		client.isTeamOwner = true
	end

	if (!bNetworked) then
		net.Start("ixPTCreate")
			net.WriteUInt(index, 8)
			net.WriteEntity(client)
		net.Send(self:GetReceivers())
	end

	hook.Run("OnCreateTeam", client, index)

	return "@TeamCreated", tostring(index)
end

function PLUGIN:ReassignTeam(index, newIndex, bNetworked)
	if (newIndex > 99 or newIndex < 1) then
		return "@TeamMustClamp"
	end

	if (self.teams[newIndex]) then
		return "@TeamAlreadyExists", tostring(index)
	end

	local curTeam = self.teams[index]

	self:DeleteTeam(index, true)

	self:CreateTeam(curTeam["owner"], newIndex, true)

	self.teams[newIndex]["members"] = curTeam["members"]

	for _, client in pairs(curTeam["members"]) do
		client.curTeam = newIndex
	end

	if (!bNetworked) then
		net.Start("ixPTReassign")
			net.WriteUInt(index, 8)
			net.WriteUInt(newIndex, 8)
		net.Send(self:GetReceivers())
	end

	hook.Run("OnReassignTeam", index, newIndex)

	return "@TeamReassigned", tostring(index), tostring(newIndex)
end

function PLUGIN:SetTeamOwner(index, client, bNetworked)
	local curOwner = self.teams[index]["owner"]

	if (IsValid(curOwner)) then
		curOwner.isTeamOwner = nil
	end

	self.teams[index]["owner"] = client

	if (IsValid(client)) then
		client.isTeamOwner = true
	end

	if (!bNetworked) then
		net.Start("ixPTOwner")
			net.WriteUInt(index, 8)
			net.WriteEntity(client)
		net.Send(self:GetReceivers())
	end

	hook.Run("OnSetTeamOwner", client, index)

	if (IsValid(client)) then
		return "@TeamOwnerSet", client:GetName()
	end
end

function PLUGIN:DeleteTeam(index, bNetworked)
	self.teams[index] = nil

	for _, client in pairs(self:GetReceivers()) do
		if (client.curTeam == index) then
			client.curTeam = nil

			if (client.isTeamOwner) then
				client.isTeamOwner = nil
			end
		end
	end

	if (!bNetworked) then
		net.Start("ixPTDelete")
			net.WriteUInt(index, 8)
		net.Send(self:GetReceivers())
	end

	hook.Run("OnDeleteTeam", index)
end

function PLUGIN:JoinTeam(client, index, bNetworked)
	if (client.curTeam) then
		return "@TeamMustLeave"
	end

	if (index > 99 or index < 1) then
		return "@TeamMustClamp"
	end

	if (!self.teams[index]) then
		return "@TeamNonExistent", tostring(index)
	end

	table.insert(self.teams[index]["members"], client)

	client.curTeam = index

	if (!bNetworked) then
		net.Start("ixPTJoin")
			net.WriteUInt(index, 8)
			net.WriteEntity(client)
		net.Send(self:GetReceivers())
	end

	hook.Run("OnJoinTeam", client, index)

	return "@JoinedTeam", index
end

function PLUGIN:LeaveTeam(client, bNetworked)
	if (!client.curTeam) then
		return "@NoCurrentTeam"
	end

	local index = client.curTeam
	local curTeam = self.teams[index]

	if (curTeam) then
		table.RemoveByValue(self.teams[index]["members"], client)

		client.curTeam = nil

		if (!bNetworked) then
			net.Start("ixPTLeave")
				net.WriteUInt(index, 8)
				net.WriteEntity(client)
			net.Send(self:GetReceivers())
		end

		if (client.isTeamOwner) then
			self:SetTeamOwner(index, nil)
		end

		hook.Run("OnLeaveTeam", client, index)

		return "@LeftTeam", index
	end
end

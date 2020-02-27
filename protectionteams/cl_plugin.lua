
local PLUGIN = PLUGIN

function PLUGIN:UpdateTeamMenu()
	if (IsValid(ix.gui.teams) and IsValid(ix.gui.menu)) then
		local subpanel = nil
		local tabs = {}
		hook.Run("CreateMenuButtons", tabs)

		for k, v in pairs(ix.gui.menu.subpanels) do
			if v.subpanelName == "tabProtectionTeam" then
				subpanel = v
				break
			end
		end

		if (ix.gui.teams:IsVisible() and ix.gui.menu:GetActiveTab() == "tabProtectionTeam") then
			ix.gui.teams:Remove()
			tabs["tabProtectionTeam"](ix.gui.menu:GetActiveSubpanel())
		elseif (subpanel) then
			ix.gui.teams:Remove()
			tabs["tabProtectionTeam"](subpanel)
		end
	end
end

function PLUGIN:CreateTeam(client, index)
	self.teams[index] = {
		owner = client,
		members = {client}
	}

	client.curTeam = index
	client.isTeamOwner = true

	hook.Run("OnCreateTeam", client, index)
end

function PLUGIN:ReassignTeam(index, newIndex)
	local curTeam = self.teams[index]

	self:DeleteTeam(index)

	self:CreateTeam(curTeam["owner"], newIndex)

	self.teams[newIndex]["members"] = curTeam["members"]

	for _, client in pairs(curTeam["members"]) do
		client.curTeam = newIndex
	end

	hook.Run("OnReassignTeam", index, newIndex)
end

function PLUGIN:DeleteTeam(index)
	self.teams[index] = nil

	for _, client in pairs(self:GetReceivers()) do
		if (client.curTeam == index) then
			client.curTeam = nil

			if (client.isTeamOwner) then
				client.isTeamOwner = nil
			end
		end
	end

	hook.Run("OnDeleteTeam", index)
end

function PLUGIN:LeaveTeam(client, index)
	table.RemoveByValue(self.teams[index]["members"], client)

	client.curTeam = nil

	hook.Run("OnLeaveTeam", client, index)
end

function PLUGIN:JoinTeam(client, index)
	table.insert(self.teams[index]["members"], client)

	client.curTeam = index

	hook.Run("OnJoinTeam", client, index)
end

function PLUGIN:SetTeamOwner(index, client)
	local curOwner = self.teams[index]["owner"]

	if (IsValid(curOwner)) then
		curOwner.isTeamOwner = nil
	end

	self.teams[index]["owner"] = client

	if (IsValid(client)) then
		client.isTeamOwner = true
	end

	hook.Run("OnSetTeamOwner", client, index)
end

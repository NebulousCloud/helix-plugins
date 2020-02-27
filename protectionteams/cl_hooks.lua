
local PLUGIN = PLUGIN

function PLUGIN:OnCreateTeam(client, index)
	self:UpdateTeamMenu()
end

function PLUGIN:OnReassignTeam(index, newIndex)
	self:UpdateTeamMenu()
end

function PLUGIN:OnDeleteTeam(index)
	self:UpdateTeamMenu()
end

function PLUGIN:OnLeaveTeam(client, index)
	self:UpdateTeamMenu()
end

function PLUGIN:OnJoinTeam(client, index)
	self:UpdateTeamMenu()
end

function PLUGIN:OnSetTeamOwner(client, index)
	self:UpdateTeamMenu()
end

function PLUGIN:PopulateCharacterInfo(client, character, container)
	if (LocalPlayer():IsCombine() and client.curTeam) then
		local curTeam = container:AddRowAfter("name", "curTeam")
		curTeam:SetText(L("TeamStatus", client.curTeam, client.isTeamOwner and L("TeamOwnerStatus") or L("TeamMemberStatus")))
		curTeam:SetBackgroundColor(client.isTeamOwner and Color(50,150,100) or Color(50,100,150))
	end
end

net.Receive("ixPTSync", function()
	local bTeams = net.ReadBool()

	if (!bTeams) then
		PLUGIN.teams = {}

		for _, client in pairs(player.GetAll()) do
			client.curTeam = nil
			client.isTeamOwner = nil
		end

		return
	end

	local teams = net.ReadTable()

	PLUGIN.teams = teams

	for index, teamTbl in pairs(teams) do
		for _, client in pairs(teamTbl["members"]) do
			client.curTeam = index
		end

		local owner = teamTbl["owner"]

		if (IsValid(owner)) then
			owner.isTeamOwner = true
		end
	end
end)

net.Receive("ixPTCreate", function()
	local index = net.ReadUInt(8)
	local client = net.ReadEntity()

	PLUGIN:CreateTeam(client, index)
end)

net.Receive("ixPTDelete", function()
	local index = net.ReadUInt(8)

	PLUGIN:DeleteTeam(index)
end)

net.Receive("ixPTLeave", function()
	local index = net.ReadUInt(8)
	local client = net.ReadEntity()

	PLUGIN:LeaveTeam(client, index)
end)

net.Receive("ixPTJoin", function()
	local index = net.ReadUInt(8)
	local client = net.ReadEntity()

	PLUGIN:JoinTeam(client, index)
end)

net.Receive("ixPTOwner", function()
	local index = net.ReadUInt(8)
	local client = net.ReadEntity()

	PLUGIN:SetTeamOwner(index, client)
end)

net.Receive("ixPTReassign", function()
	local index = net.ReadUInt(8)
	local newIndex = net.ReadUInt(8)

	PLUGIN:ReassignTeam(index, newIndex)
end)

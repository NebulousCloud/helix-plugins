
local PLUGIN = PLUGIN

local backgroundColor = Color(0, 0, 0, 66)

local PANEL = {}

function PANEL:Init()
	if (IsValid(ix.gui.teams)) then
		ix.gui.teams:Remove()
	end

	ix.gui.teams = self

	self:Dock(FILL)

	self.teams = {}
	self.teamButtons = {}
	self.teamSubpanels = {}

	self.teamsPanel = self:Add("ixHelpMenuCategories")
	self.teamsPanel.Paint = function(this, width, height)
		surface.SetDrawColor(backgroundColor)
		surface.DrawRect(0, 0, width, height)
	end

	self.teamButtonPanel = self.teamsPanel:Add("DScrollPanel")
	self.teamButtonPanel:Dock(FILL)

	self.canvasPanel = self:Add("EditablePanel")
	self.canvasPanel:Dock(FILL)

	local teams = {}
	hook.Run("PopulateTeamMenu", teams)

	for k, v in pairs(teams) do
		self:AddTeam(k)
		self.teams[k] = v
	end

	local createButton = self.teamsPanel:Add("ixMenuButton")
	createButton:SetText("tabCreateTeam")
	createButton:SizeToContents()
	createButton:SetZPos(-99)
	createButton:Dock(BOTTOM)
	createButton.DoClick = function()
		ix.command.Send("PTCreate")
	end

	self.teamsPanel:SizeToContents()

	if (LocalPlayer().curTeam) then
		if (IsValid(createButton)) then
			createButton:Remove()
		end

		local leaveButton = self.teamsPanel:Add("ixMenuButton")
		leaveButton:SetText("tabLeaveTeam")
		leaveButton:SizeToContents()
		leaveButton:Dock(BOTTOM)
		leaveButton.DoClick = function()
			ix.command.Send("PTLeave")
		end
	end

	if (self.teams[ix.gui.lastTeamMenuTab] or LocalPlayer().curTeam) then
		local lastTab = self.teams[ix.gui.lastTeamMenuTab] and ix.gui.lastTeamMenuTab or LocalPlayer().curTeam
		self:OnCategorySelected(lastTab)
	end
end

function PANEL:AddTeam(name)
	local button = self.teamButtonPanel:Add("ixMenuButton")
	button:SetText(L("TeamName", name))
	button:SetBackgroundColor(ix.config.Get("color"))
	button.backgroundAlpha = 255
	button:SizeToContents()
	button:Dock(TOP)
	button.DoClick = function(this)
		self:OnCategorySelected(name)
	end
	button.DoRightClick = function(this)
		if ((LocalPlayer().curTeam != name or !LocalPlayer().isTeamOwner) and !LocalPlayer():IsDispatch()) then return end

		local reassignMenu = DermaMenu(this)

		reassignMenu:AddOption(L("TeamReassign"), function()
			Derma_StringRequest(L("cmdPTReassign"), L("cmdReassignPTDesc"), name, function(text) ix.command.Send("PTReassign", text, name) end)
		end)

		reassignMenu:Open()
		this.Menu = reassignMenu
	end

	local panel = self.canvasPanel:Add("DScrollPanel")
	panel:SetVisible(false)
	panel:Dock(FILL)

	-- reverts functionality back to a standard panel in the case that a category will manage its own scrolling
	panel.DisableScrolling = function()
		panel:GetCanvas():SetVisible(false)
		panel:GetVBar():SetVisible(false)
		panel.OnChildAdded = function() end
	end

	button.Paint = function(this, width, height)
		local alpha = panel:IsVisible() and this.backgroundAlpha or this.currentBackgroundAlpha
		surface.SetDrawColor(ColorAlpha(ix.config.Get("color"), alpha))
		surface.DrawRect(0, 0, width, height)
	end

	self.teamSubpanels[name] = panel

	return button
end

function PANEL:OnCategorySelected(name)
	local panel = self.teamSubpanels[name]

	if (!IsValid(panel)) then
		return
	end

	if (!panel.bPopulated) then
		self.teams[name](panel)
		panel.bPopulated = true
	end

	if (IsValid(self.activeTeam)) then
		self.activeTeam:SetVisible(false)
	end

	panel:SetVisible(true)

	self.activeTeam = panel
	ix.gui.lastTeamMenuTab = name

	self:OnTeamSelected(name)
end

function PANEL:OnTeamSelected(index)
	if (LocalPlayer().curTeam != index and !LocalPlayer().curTeam) then
		if (IsValid(self.joinButton)) then
			self.joinButton:Remove()
		end

		self.joinButton = self.teamsPanel:Add("ixMenuButton")
		self.joinButton:SetText("tabJoinTeam")
		self.joinButton:SizeToContents()
		self.joinButton:Dock(BOTTOM)
		self.joinButton.DoClick = function(this)
			ix.command.Send("PTJoin", index)
		end
	end
end

vgui.Register("ixTeamMenu", PANEL, "EditablePanel")

hook.Add("CreateMenuButtons", "ixTeamMenu", function(tabs)
	if (!LocalPlayer():IsCombine()) then return end

	tabs["tabProtectionTeam"] = function(container)
		container:Add("ixTeamMenu")
	end
end)

hook.Add("PopulateTeamMenu", "ixTeamMenu", function(tabs)
	if (!PLUGIN.teams or table.IsEmpty(PLUGIN.teams)) then return end

	for k, v in pairs(PLUGIN.teams) do
		tabs[k] = function(container)
			container:DisableScrolling()

			local panel = container:Add("DScrollPanel")
			panel:Dock(FILL)

			local memberList = {}

			for k2, v2 in pairs(v["members"]) do
				if (v2.isTeamOwner) then
					memberList[#memberList + 1] = {
						client = v2,
						owner = 1
					}
				else
					memberList[#memberList + 1] = {
						client = v2,
						owner = 99
					}
				end
			end

			for k2, v2 in SortedPairsByMemberValue(memberList, "owner", false) do
				local member = panel:Add("ixMenuButton")
				member:SetFont("ixMenuButtonFont")
				member:SetText(v2.client:Name() or "Unknown")
				member:SizeToContents()
				member:Dock(TOP)
				member.Paint = function(this, width, height)
					derma.SkinFunc("DrawImportantBackground", 0, 0, width, height, ColorAlpha(this.backgroundColor, this.currentBackgroundAlpha))
				end
				member.DoRightClick = function(this)
					if (!LocalPlayer():IsDispatch()) then
						if (!LocalPlayer().isTeamOwner or LocalPlayer().curTeam != k) then return end
					end

					local interactMenu = DermaMenu(this)
					local member = interactMenu:AddOption(v2.client:Name())
					member:SetContentAlignment(5)
					member.Paint = function(this, width, height) end

					local spacer = interactMenu:AddSpacer()
					spacer.Paint = function(this, width, height)
						surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
						surface.DrawRect( 0, 0, width, height )
					end

					interactMenu:AddOption(L("TeamTransferOwner"), function()
						ix.command.Send("PTLead", v2.client:Name())
					end):SetIcon( "icon16/award_star_gold_1.png" )

					interactMenu:AddOption(L("TeamKickMember"), function()
						ix.command.Send("PTKick", v2.client:Name())
					end):SetIcon( "icon16/cross.png" )

					interactMenu:Open()
					this.Menu = interactMenu
				end

				if (v2.client.isTeamOwner) then
					member.backgroundColor = Color(50,150,100)
				end
			end
		end
	end
end)

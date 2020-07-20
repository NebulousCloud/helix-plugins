PLUGIN.name = "Door Extensions"
PLUGIN.author = "Zoephix"
PLUGIN.description = "A extension for the doors plugin, adding easy commands that target every door."
PLUGIN.license = [[
Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

© Copyright 2020 by Zoephix

This plugin is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/]]

ix.lang.AddTable("english", {
	cmdDoorsSetUnownable = "Makes every door unownable.",
	cmdDoorsSetOwnable = "Makes every door ownable.",
	cmdDoorsSetDisabled = "Disallows any commands to be ran on every door.",
	cmdDoorsSetHidden = "Hides the description of every door, but still allows it to be ownable.",
})

ix.lang.AddTable("dutch", {
	cmdDoorsSetUnownable = "Maakt elke deur onkoopbaar.",
	cmdDoorsSetOwnable = "Maakt elke deur koopbaar.",
	cmdDoorsSetDisabled = "Staat niet toe dat opdrachten op elke deur worden uitgevoerd.",
	cmdDoorsSetHidden = "Verbergt de beschrijving van elke deur, maar laat deze toch koopbaar zijn.",
})

local PLUGIN = PLUGIN

function PLUGIN:InitializedPlugins()
	local doorPlugin = ix.plugin.Get("doors")

	if (!doorPlugin) then return end

	ix.command.Add("DoorSetUnownableAll", {
		description = "@cmdDoorsSetUnownable",
		privilege = "Manage Doors",
		adminOnly = true,
		arguments = ix.type.text,
		OnRun = function(self, client, arguments)
			-- Get every door entity
			for _, entity in pairs(ents.GetAll()) do
				-- Validate it is a door.
				if (IsValid(entity) and entity:IsDoor() and !entity:GetNetVar("disabled")) then
					-- Set it so it is unownable.
					entity:SetNetVar("ownable", nil)

					doorPlugin:CallOnDoorChildren(entity, function(child)
						child:SetNetVar("ownable", nil)
			end)

			doorPlugin:SaveDoorData()
				end
			end

			-- Tell the player they have made the doors unownable.
			return ix.util.Notify("You have made every door unownable.", client)
		end
	})

	ix.command.Add("DoorSetOwnableAll", {
		description = "@cmdDoorsSetOwnable",
		privilege = "Manage Doors",
		adminOnly = true,
		arguments = ix.type.text,
		OnRun = function(self, client, arguments)
			-- Get every door entity
			for _, entity in pairs(ents.GetAll()) do
				-- Validate it is a door.
				if (IsValid(entity) and entity:IsDoor() and !entity:GetNetVar("disabled")) then
					-- Set it so it is ownable.
					entity:SetNetVar("ownable", true)

					doorPlugin:CallOnDoorChildren(entity, function(child)
						child:SetNetVar("ownable", true)
			end)

			doorPlugin:SaveDoorData()
				end
			end

			-- Tell the player they have made the doors ownable.
			return ix.util.Notify("You have made every door ownable.", client)
		end
	})

	ix.command.Add("DoorSetDisabledAll", {
		description = "@cmdDoorsSetDisabled",
		privilege = "Manage Doors",
		adminOnly = true,
		arguments = ix.type.bool,
		OnRun = function(self, client, bDisabled)
			-- Get every door entity
			for _, entity in pairs(ents.GetAll()) do
				-- Validate it is a door.
				if (IsValid(entity) and entity:IsDoor()) then

					-- Set it so it is ownable.
					entity:SetNetVar("disabled", bDisabled)

					doorPlugin:CallOnDoorChildren(entity, function(child)
						child:SetNetVar("disabled", bDisabled)
			end)

			doorPlugin:SaveDoorData()
				end
			end

			-- Tell the player they have made the doors (un)disabled.
			if (bDisabled) then
				return ix.util.Notify("You have disabled every door.", client)
			else
				return ix.util.Notify("You have undisabled every door.", client)
			end
		end
	})

	ix.command.Add("DoorSetHiddenAll", {
		description = "@cmdDoorsSetHidden",
		privilege = "Manage Doors",
		adminOnly = true,
		arguments = ix.type.bool,
		OnRun = function(self, client, bHidden)
			-- Get every door entity
			for _, entity in pairs(ents.GetAll()) do
				-- Validate it is a door.
				if (IsValid(entity) and entity:IsDoor()) then

					entity:SetNetVar("visible", !bHidden)

					doorPlugin:CallOnDoorChildren(entity, function(child)
						child:SetNetVar("visible", !bHidden)
			end)

			doorPlugin:SaveDoorData()
				end
			end

			-- Tell the player they have made the doors (un)hidden.
			if (bHidden) then
				return ix.util.Notify("You have made every door hidden.", client)
			else
				return ix.util.Notify("You have made every door no longer hidden.", client)
			end
		end
	})
end

PLUGIN.name = "Door Extensions"
PLUGIN.author = "Zoephix"
PLUGIN.description = "A extension for the doors plugin, adding easy commands that target every door."
PLUGIN.license = [[
Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

© Copyright 2020 by Zoephix

This plugin is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/]]

local PLUGIN = PLUGIN

-- Variables for the door data.
local variables = {
	"disabled",
	"ownable",
	"visible"
}

function PLUGIN:CallOnDoorChildren(entity, callback)
	local parent

	if (entity.ixChildren) then
		parent = entity
	elseif (entity.ixParent) then
		parent = entity.ixParent
	end

	if (IsValid(parent)) then
		callback(parent)

		for k, _ in pairs(parent.ixChildren) do
			local child = ents.GetMapCreatedEntity(k)

			if (IsValid(child)) then
				callback(child)
			end
		end
	end
end

ix.command.Add("DoorSetUnownableAll", {
	description = "@cmdDoorSetUnownable",
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

				PLUGIN:CallOnDoorChildren(entity, function(child)
					child:SetNetVar("ownable", nil)
                end)
                
                PLUGIN:SaveDoorData()
			end
		end

		-- Tell the player they have made the doors unownable.
		return ix.util.Notify("You have made every door unownable.", client)
	end
})

ix.command.Add("DoorSetOwnableAll", {
	description = "@cmdDoorSetOwnable",
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

				PLUGIN:CallOnDoorChildren(entity, function(child)
					child:SetNetVar("ownable", true)
                end)
                
                PLUGIN:SaveDoorData()
			end
		end

		-- Tell the player they have made the doors ownable.
		return ix.util.Notify("You have made every door ownable.", client)
	end
})

ix.command.Add("DoorSetDisabledAll", {
	description = "@cmdDoorSetDisabled",
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

				PLUGIN:CallOnDoorChildren(entity, function(child)
					child:SetNetVar("disabled", bDisabled)
                end)
                
                PLUGIN:SaveDoorData()
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
	description = "@cmdDoorSetHidden",
	privilege = "Manage Doors",
	adminOnly = true,
	arguments = ix.type.bool,
	OnRun = function(self, client, bHidden)
		-- Get every door entity
		for _, entity in pairs(ents.GetAll()) do
			-- Validate it is a door.
			if (IsValid(entity) and entity:IsDoor()) then

				entity:SetNetVar("visible", !bHidden)
				
				PLUGIN:CallOnDoorChildren(entity, function(child)
					child:SetNetVar("visible", !bHidden)
                end)
                
                PLUGIN:SaveDoorData()
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

if (SERVER) then
	-- Called after the entities have loaded.
	function PLUGIN:LoadData()
		-- Restore the saved door information.
		local data = self:GetData()

		if (!data) then return end

		-- Loop through all of the saved doors.
		for k, v in pairs(data) do
			-- Get the door entity from the saved ID.
			local entity = ents.GetMapCreatedEntity(k)

			-- Check it is a valid door in-case something went wrong.
			if (IsValid(entity) and entity:IsDoor()) then
				-- Loop through all of our door variables.
				for k2, v2 in pairs(v) do
					if (k2 == "children") then
						entity.ixChildren = v2

						for index, _ in pairs(v2) do
							local door = ents.GetMapCreatedEntity(index)

							if (IsValid(door)) then
								door.ixParent = entity
							end
						end
					else
						entity:SetNetVar(k2, v2)
					end
				end
			end
		end
	end

	-- Called before the gamemode shuts down.
	function PLUGIN:SaveDoorData()
		-- Create an empty table to save information in.
		local data = {}
		local doors = {}

		for k, v in ipairs(ents.GetAll()) do
			if (v:IsDoor()) then
				doors[v:MapCreationID()] = v
			end
		end

		local doorData

		-- Loop through doors with information.
		for k, v in pairs(doors) do
			-- Another empty table for actual information regarding the door.
			doorData = {}

			-- Save all of the needed variables to the doorData table.
			for k2, v2 in ipairs(variables) do
				local value = v:GetNetVar(v2)

				if (value) then
					doorData[v2] = v:GetNetVar(v2)
				end
			end
			
			-- Add the door to the door information.
			if (table.Count(doorData) > 0) then
				data[k] = doorData
			end
		end
		self:SetData(data)
	end
end


local PLUGIN = PLUGIN

PLUGIN.name = "Player Flags"
PLUGIN.author = "SleepyMode"
PLUGIN.description = "Allows flags to be assigned to players rather than characters."
PLUGIN.license = [[This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>]]

CAMI.RegisterPrivilege({
	Name = "Helix - Manage Player Flags",
	MinAccess = "superadmin"
})

--[[-------------------------------------------------------------------------
Functions
---------------------------------------------------------------------------]]

if (SERVER) then
	function PLUGIN:SetPlayerFlags(client, flags)
		client:SetData("playerFlags", flags)
	end

	function PLUGIN:GivePlayerFlags(client, flags)
		local addedFlags = ""

		for i = 1, #flags do
			local flag = flags[i]
			local info = ix.flag.list[flag]

			if (info) then
				if (!self:HasPlayerFlags(client, flag)) then
					addedFlags = addedFlags .. flag
				end

				if (info.callback) then
					info.callback(client, true)
				end
			end
		end

		if (addedFlags != "") then
			self:SetPlayerFlags(client, self:GetPlayerFlags(client) .. addedFlags)
		end
	end

	function PLUGIN:TakePlayerFlags(client, flags)
		local oldFlags = self:GetPlayerFlags(client)
		local newFlags = oldFlags

		for i = 1, #flags do
			local flag = flags[i]
			local info = ix.flag.list[flag]

			if (info and info.callback) then
				info.callback(client, false)
			end

			newFlags = newFlags:gsub(flag, "")
		end

		if (newFlags != oldFlags) then
			self:SetPlayerFlags(client, newFlags)
		end
	end

	function PLUGIN:ClearPlayerFlags(client)
		self:TakePlayerFlags(client, self:GetPlayerFlags(client))
	end

	function PLUGIN:GivePlayerAllFlags(client)
		for flag, info in pairs(ix.flag.list) do
			self:GivePlayerFlags(client, flag)
		end
	end
end

function PLUGIN:GetPlayerFlags(client)
	return client:GetData("playerFlags", "")
end

function PLUGIN:HasPlayerFlags(client, flags)
	local bHasFlag = hook.Run("PlayerHasFlags", client, flags)

	if (bHasFlag == true) then
		return true
	end

	local flagList = self:GetPlayerFlags(client)

	for i = 1, #flags do
		if (flagList:find(flags[i], 1, true)) then
			return true
		end
	end

	return false
end

--[[-------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]

function PLUGIN:CharacterHasFlags(character, flags)
	if (self:HasPlayerFlags(character:GetPlayer(), flags)) then
		return true
	end
end

function PLUGIN:PostPlayerLoadout(client)
	local flags = self:GetPlayerFlags(client)

	for i = 1, #flags do
		local flag = flags[i]
		local info = ix.flag.list[flag]

		if (info and info.callback) then
			info.callback(client, true)
		end
	end
end


--[[-------------------------------------------------------------------------
Commands
---------------------------------------------------------------------------]]

ix.command.Add("PlyGiveFlag", {
	-- Neatly enough cmdCharGiveFlag never mentions any characters.
	description = "@cmdCharGiveFlag",
	privilege = "Helix - Manage Player Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.player,
		bit.bor(ix.type.string, ix.type.optional)
	},
	OnRun = function(self, client, target, flags)
		if (!flags) then
			local available = ""

			for k, _ in SortedPairs(ix.flag.list) do
				if (!PLUGIN:HasPlayerFlags(target, k)) then
					available = available .. k
				end
			end

			return client:RequestString("@flagGiveTitle", "@cmdCharGiveFlag", function(text)
				ix.command.Run(client, "PlyGiveFlag", {target:GetName(), text})
			end, available)
		end

		PLUGIN:GivePlayerFlags(target, flags)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("flagGive", client:SteamName(), target:SteamName(), flags)
			end
		end
	end
})

ix.command.Add("PlyTakeFlag", {
	-- Neatly enough cmdCharGiveFlag never mentions any characters.
	description = "@cmdCharTakeFlag",
	privilege = "Helix - Manage Player Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.player,
		bit.bor(ix.type.string, ix.type.optional)
	},
	OnRun = function(self, client, target, flags)
		if (!flags) then
			return client:RequestString("@flagTakeTitle", "@cmdCharTakeFlag", function(text)
				ix.command.Run(client, "PlyTakeFlag", {target:GetName(), text})
			end, PLUGIN:GetPlayerFlags(target))
		end

		PLUGIN:TakePlayerFlags(target, flags)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:NotifyLocalized("flagTake", client:SteamName(), flags, target:SteamName())
			end
		end
	end
})

ix.command.Add("PlyGiveAllFlags", {
	description = "Gives a player all available flags.",
	privilege = "Helix - Manage Player Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.player
	},
	OnRun = function(self, client, target)
		for flag, info in pairs(ix.flag.list) do
			PLUGIN:GivePlayerFlags(target, flag)
		end

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:Notify(client:SteamName() .. " has given " .. target:SteamName() .. " all available flags!")
			end
		end
	end
})

ix.command.Add("PlyClearFlags", {
	description = "Removes all flags from a player.",
	privilege = "Helix - Manage Player Flags",
	superAdminOnly = true,
	arguments = {
		ix.type.player
	},
	OnRun = function(self, client, target)
		PLUGIN:ClearPlayerFlags(target)

		for _, v in ipairs(player.GetAll()) do
			if (self:OnCheckAccess(v) or v == target) then
				v:Notify(client:SteamName() .. " has cleared all flags of " .. target:SteamName() .. "!")
			end
		end
	end
})

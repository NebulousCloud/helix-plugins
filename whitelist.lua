local PLUGIN = PLUGIN

PLUGIN.name = "Whitelist"
PLUGIN.author = "wildflowericecoffee"
PLUGIN.description = "Adds a server whitelist"
PLUGIN.readme = [[
This plugin adds a configurable server whitelist, letting only the players you allow to connect to your server.
The whitelist is disabled by default, to turn it on simply go to the "config" tab in-game.
]]
PLUGIN.license = [[
Copyright 2021 wildflowericecoffee

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("whitelistEnabled", false, "Enables the server whitelist.", nil, {
    category = "Whitelist"
})

if SERVER then
    function PLUGIN:LoadData()
        self.allowed = self:GetData() or {}
    end

    function PLUGIN:SaveData()
        self:SetData(self.allowed)
    end

    function PLUGIN:CheckPassword(steamID64)
        local steamID = util.SteamIDFrom64(steamID64)

        if ix.config.Get("whitelistEnabled") and not self.allowed[steamID] then
            return false, "Sorry, you are not whitelisted for " .. GetHostName()
        end
    end

    function PLUGIN:PlayerAuthed(client, steamID, uniqueID)
        if ix.config.Get("whitelistEnabled") and not self.allowed[steamID] then
            game.KickID(uniqueID, "Sorry, you are not whitelisted for " .. GetHostName())
        end
    end
end

ix.command.Add("WhitelistAdd", {
    description = "Adds a SteamID to the whitelist",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    arguments = ix.type.string,
    OnRun = function(self, client, steamID)
        if not steamID:match("STEAM_(%d+):(%d+):(%d+)") then
            return "Invalid SteamID!"
        end

        if PLUGIN.allowed[steamID] then
            return "This SteamID is already whitelisted"
        else
            PLUGIN.allowed[steamID] = true

            return "Added SteamID to the whitelist"
        end
    end
})

ix.command.Add("WhitelistRemove", {
    description = "Removes a SteamID from the whitelist",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    arguments = ix.type.string,
    OnRun = function(self, client, steamID)
        if not steamID:match("STEAM_(%d+):(%d+):(%d+)") then
            return "Invalid SteamID!"
        end

        if not PLUGIN.allowed[steamID] then
            return "This SteamID is not whitelisted"
        else
            PLUGIN.allowed[steamID] = nil

            return "Removed SteamID from the whitelist"
        end
    end
})

ix.command.Add("WhitelistClear", {
    description = "Clears the whitelist",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    OnRun = function(self)
        PLUGIN.allowed = {}

        return "Cleared the whitelist"
    end
})

ix.command.Add("WhitelistAddAll", {
    description = "Whitelists all current players",
    privilege = "Manage Server Whitelist",
    superAdminOnly = true,
    OnRun = function(self)
        for _, client in ipairs(player.GetHumans()) do
            if IsValid(client) then
                PLUGIN.allowed[client:SteamID()] = true
            end
        end

        return "Added all current players to the whitelist"
    end
})

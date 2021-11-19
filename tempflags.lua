local PLUGIN = PLUGIN
PLUGIN.name = "Temporary Flags"
PLUGIN.author = "wildflowericecoffee"
PLUGIN.description = "Gives a player flags that expire after time."

PLUGIN.readme = [[
This plugin allows server staff to temporarily give flags to a player that automatically expire over time.
To use this, you need the 'Player Flags' plugin installed and enabled, which can be found here: https://plugins.gethelix.co/player-flags/.
]]
PLUGIN.license = [[
Copyright 2021 wildflowericecoffee

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local plyFlagsPlugin = ix.plugin.Get("sh_playerflags")

local constantTable = {
    s = 1,          -- seconds
    m = 60,         -- minutes
    h = 3600,       -- hours
    d = 86400,      -- days
    w = 604800,     -- weeks
    n = 2592000,    -- months
    y = 31536000    -- years
}

function PLUGIN:LengthToSeconds(length)
    local constant = length:sub(-1)
    local multiplier = length:sub(1, -2)

    return tonumber(multiplier) * tonumber(constantTable[constant])
end

if SERVER then
    function PLUGIN:CheckTempFlags(client)
        local tempFlags = client:GetData("tempFlags", "")
        local timestamp = client:GetData("tempFlagsExpire")

        if not timestamp then return end

        if os.time() > timestamp then
            plyFlagsPlugin:TakePlayerFlags(client, tempFlags)

            client:SetData("tempFlags", nil)
            client:SetData("tempFlagsExpire", nil)

            client:Notify(
                ("Your '%s' flags expired on: %s"):format(
                    tempFlags,
                    os.date("%H:%M:%S - %d/%m/%Y", timestamp)
                )
            )
        end
    end

    function PLUGIN:PlayerLoadout(client)
        if not plyFlagsPlugin then return end

        self:CheckTempFlags(client)
    end

    function PLUGIN:SaveData()
        if not plyFlagsPlugin then return end

        for _, client in ipairs(player.GetAll()) do
            self:CheckTempFlags(client)
        end
    end
end

ix.command.Add("PlyGiveTempFlag", {
    description = "Gives a player temporary flags.",
    privilege = "Helix - Manage Player Flags",
    adminOnly = true,
    arguments = {
        ix.type.player,
        ix.type.string,
        ix.type.string
    },
    syntax = "<player target> <string flags> <string length (number)(s/m/h/d/w/n/y)>",
    OnRun = function(self, client, target, flags, length)
        if not plyFlagsPlugin then 
            return "The 'Player Flags' plugin is not installed or disabled!"
        end

        local length = length:match("(%d+[smhdwny])")

        if not length then
            return "Invalid length!"
        end

        local timestamp = os.time() + PLUGIN:LengthToSeconds(length)
        local date = os.date("%H:%M:%S - %d/%m/%Y", timestamp)

        plyFlagsPlugin:GivePlayerFlags(target, flags)

        target:SetData("tempFlags", flags)
        target:SetData("tempFlagsExpire", timestamp)

        ix.util.Notify(
            ("%s has given '%s' flags to %s until: %s"):format(
                client:Name(),
                flags,
                target:Name(),
                date
            )
        )
    end
})

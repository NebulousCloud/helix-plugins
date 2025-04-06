local PLUGIN = PLUGIN

PLUGIN.name = "Simple Bodygroup Manager"
PLUGIN.description = "Allow clients to modify their bodygroups and staff to modify user's easily"
PLUGIN.author = "Bena"
PLUGIN.schema = "Any"
PLUGIN.license = [[
Copyright 2024 Bena

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


]]


-- Global so that we can use this wherever we want even if outside the plugin
SBM = SMB or ix.data.Get("sbmData", {})
SBM.config = SBM.config or {}
SBM.banned = SBM.banned or {} -- List of STEAMIDs that no matter what will not be able to use the menu without interacting with the entity
SBM.config.keyOptions = {
    factionBypass = { -- Factions that would be able to use the menu by using the key even if the 'allowKeyUse' setting above is set to false by adding its unique id
        ministerio = true -- Just an example of how to add factions. Just add the uniqueID
    },
    key = KEY_F9

}


ix.command.Add("ForbidKey", {
    description = "@cmdBanKeyUseSBMDesc",
    adminOnly = true,
    arguments = ix.type.player,
    argumentNames = {"Target"},
    OnRun = function(self, client, target)
        if (!target) then return end

        if (SBM.banned[target:SteamID()]) then
            SBM.banned[target:SteamID()] = nil
            for _, ply in player.Iterator() do
                if !ply:IsAdmin() then continue end
                ply:NotifyLocalized("cmdBanKeyUseSBMUnbanned", client:SteamName(), target:Name())
            end
        else
            SBM.banned[target:SteamID()] = true
            for _, ply in player.Iterator() do
                if !ply:IsAdmin() then continue end
                ply:NotifyLocalized("cmdBanKeyUseSBMBanned", client:SteamName(), target:Name())
            end
        end

        PLUGIN:SaveData()
    end
})

ix.command.Add("EditUserBodygroups", {
    description = "@cmdEditUserBodygroups",
    adminOnly = true,
    arguments = ix.type.player,
    argumentNames = {"Target"},
    OnRun = function(self, client, target)
        if (!target) then return end

        net.Start("SBMOpenMenu")
            net.WritePlayer(target)
        net.Send(client)

    end
})

-- Serverside plugin
ix.util.Include("sv_plugin.lua")

-- Configs
ix.util.Include("sh_configs.lua")

-- Nets
ix.util.Include("net/sv_net.lua")
ix.util.Include("net/cl_net.lua")

-- Hooks
ix.util.Include("hooks/sv_hooks.lua")

-- Dermas
ix.util.Include("derma/cl_bgmanager.lua")


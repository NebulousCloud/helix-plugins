local PLUGIN = PLUGIN or {}

PLUGIN.name = "Bodygroup Manager"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows players and administration to have an easier time customising bodygroups."

if SERVER then
    util.AddNetworkString("ixBodygroupView")
end

ix.command.Add("CharEditBodygroup", {
    description = "cmdEditBodygroup",
    adminOnly = true,
    arguments = {
        ix.type.character
    },
    OnRun = function(self, client, target)
        net.Start("ixBodygroupView")
            net.WriteTable(target)
        net.Send(client)
    end
})

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

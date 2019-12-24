local PLUGIN = PLUGIN or {}

PLUGIN.name = "Bodygroup Manager"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows players and administration to have an easier time customising bodygroups."

ix.command.Add("CharEditBodygroup", {
    description = "cmdEditBodygroup",
    adminOnly = true,
    arguments = {
        ix.type.character
    },
    OnRun = function(self, client, target)
        if !netstream then
            ErrorNoHalt("Bodygroupmanager requires Netstream to run.")
            return
        end
        netstream.Start(client, "ixBodygroupView", target)
    end
})

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

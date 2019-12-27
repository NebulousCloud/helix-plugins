local PLUGIN = PLUGIN

PLUGIN.name = "Bodygroup Manager"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows players and administration to have an easier time customising bodygroups."

ix.lang.AddTable("english", {
    cmdEditBodygroup = "Customise the bodygroups of a target."
})

ix.command.Add("CharEditBodygroup", {
    description = "cmdEditBodygroup",
    adminOnly = true,
    arguments = {
        bit.bor(ix.type.player, ix.type.optional)
    },
    OnRun = function(self, client, target)
        net.Start("ixBodygroupView")
            net.WriteEntity(target or client)
        net.Send(client)
    end
})

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

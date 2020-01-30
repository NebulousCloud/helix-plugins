local PLUGIN = PLUGIN

PLUGIN.name = "Item Spawner System"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Allows staff to select item spawn points with great configuration."

PLUGIN.spawner = PLUGIN.spawner or {}
PLUGIN.items = PLUGIN.items or {}
PLUGIN.spawner.positions = PLUGIN.spawner.positions or {}

CAMI.RegisterPrivilege({
	Name = "Helix - Item Spawner",
	MinAccess = "superadmin"
})

PLUGIN.items.common = {
	"pistol"
}

PLUGIN.items.rare = {
	"shotgun"
}

ix.util.Include("sh_config.lua")
ix.util.Include("sh_commands.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")

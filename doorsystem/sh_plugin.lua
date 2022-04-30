local PLUGIN = PLUGIN

PLUGIN.name = "Door System"
PLUGIN.description = "Adds a simply configurable door system."
PLUGIN.author = "Skay™#2752"

--[[ DOOR SYSTEM TEMPLATE

   ["mapname"] = { -- use status in console
		{
			id = 3965, -- Map Creation ID of the door
			name = "Yo CP's come in boys.", -- Display name of the door
			access = 1 -- Access of the door
		},
	}

]]

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sh_entity.lua")
PLUGIN.access = {
	[1] = {
		name = "Universal Access 1",
		color= Color(0, 100, 255),
		checkAccess = function(ply)
			return ( ply:Team() == FACTION_MPF or ply:Team() == FACTION_OTA )
		end,
		snd = "buttons/combine_button2.wav"
	},
	[2] = {
		name = "Universal Access 2",
		color = Color(30, 220, 200),
		checkAccess = function(ply)
			return ( ply:Team() == FACTION_OTA )
		end,
		snd = "buttons/combine_button7.wav"
	},
	[3] = {
		name = "Universal Access 3", -- Name of the door access to be displayed
		color = Color(255, 0, 0), -- Color of the display
		checkAccess = function(ply)
			return ( ply:Team() == FACTION_OTA )
		end, -- Factions that are allowed to use the door
		snd = "buttons/combine_button1.wav" -- Sound on opening the door
	},
}


PLUGIN.doors = {
	["rp_city17_conflictstudios"] = {
		{
			id = 3965, -- Map Creation ID of the door
			name = "Yo CP's come in boys.", -- Display name of the door
			access = 1 -- Access of the door
		},
		{
			id = 3966,
			name = "cat",
			access = 1
		},
		{	
			id = 4110,
			name = "drugs",
			access = 2	
		}
	},
	["rp_nc_d47_v2"] = {
		{
			id = 2380,
			name = "hi",
			access = 1
		}
	}
}

concommand.Add("printtable", function(ply)
	PrintTable(PLUGIN.doors)
	
	for k, v in pairs(PLUGIN.doors) do
		print(k.." - k")
		for _, a in pairs(v) do
			timer.Simple(5, function()
				PrintTable(v)
			end)
		end
	end
end)
local PLUGIN = PLUGIN

PLUGIN.name = "Detailed Descriptions"
PLUGIN.author = "Zoephix"
PLUGIN.description = "Adds the ability for players to create detailed descriptions, which can be examined."
PLUGIN.license = [[ 
This script is part of the "Detailed Descriptions" plugin by Zoephix.

© Copyright 2020: Zoephix.
You are allowed to use, modify and redistribute this script.
However, you are not allowed to sell this script nor profit from this script in any way.
You are not allowed to claim this script as being your own work, do not remove the credits. ]]

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

ix.lang.AddTable("english", {
	cmdCharDetDesc = "Sets your detailed description.",
	cmdSelfExamine = "Examines your detailed description.",
})

ix.lang.AddTable("dutch", {
	cmdCharDetDesc = "Stelt je gedetailleerde beschrijving in.",
	cmdSelfExamine = "Examineert je gedetailleerde beschrijving.",
})

ix.command.Add("SelfExamine", {
	description = "@cmdSelfExamine",
	adminOnly = true,
	OnRun = function(self, client, text, scale)
		local textEntryData = client:GetCharacter():GetData("textDetDescData", nil) or "No detailed description found."
		local textEntryDataURL = client:GetCharacter():GetData("textDetDescDataURL", nil) or "No detailed description found."

		net.Start("ixOpenDetailedDescriptions")
			net.WriteEntity(client)
			net.WriteString(textEntryData)
			net.WriteString(textEntryDataURL)
		net.Send(client)
	end
})

ix.command.Add("CharDetDesc", {
	description = "@cmdCharDetDesc",
	adminOnly = true,
	OnRun = function(self, client, text, scale)
		net.Start("ixSetDetailedDescriptions")
			net.WriteString(client:SteamName())
		net.Send(client)
	end
})
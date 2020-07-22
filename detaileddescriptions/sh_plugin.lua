local PLUGIN = PLUGIN

PLUGIN.name = "Detailed Descriptions"
PLUGIN.author = "Zoephix"
PLUGIN.description = "Adds the ability for players to create detailed descriptions, which can be examined."
PLUGIN.license = [[
Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)

© Copyright 2020 by Zoephix

This plugin is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/]]

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

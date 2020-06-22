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
	description = "@cmdCharDetDesc",
	adminOnly = true,
	OnRun = function(self, client, text, scale)
		local textEntryData = tostring(client:GetCharacter():GetData("textDetDescData"))
		local textEntryDataURL = tostring(client:GetCharacter():GetData("textDetDescDataURL"))
	
		net.Start("OpenDetailedDescriptions")
		net.WriteString(client:SteamName())
		net.WriteString(client:Name())
		if (textEntryData == "nil") then
			net.WriteString("No detailed description found")
			net.WriteString("No detailed description found")
		else
			net.WriteString(textEntryData)
			net.WriteString(textEntryDataURL)
		end
		net.Send(client)
	end
})

ix.command.Add("CharDetDesc", {
	description = "@cmdCharDetDesc",
	adminOnly = true,
	OnRun = function(self, client, text, scale)
		net.Start("SetDetailedDescriptions")
			net.WriteString(client:SteamName())
		net.Send(client)
	end
})

function PLUGIN:KeyPress(client, key)
	local entity = client:GetEyeTrace().Entity

	if (key == IN_USE and IsValid(entity) and entity:IsPlayer()) then
	if !(client:GetPos():Distance(entity:GetPos()) <= 100) then return end
		if (CLIENT) then
			ix.menu.Open({Examine = function()
				local entity = client:GetEyeTrace().Entity
				
				net.Start("ExamineDetailedDescriptions")
					net.WriteEntity(entity)
					net.WriteEntity(client)
				net.SendToServer()
			end}, entity)
		end
	end
end
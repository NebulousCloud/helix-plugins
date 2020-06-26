util.AddNetworkString("OpenDetailedDescriptions")
util.AddNetworkString("SetDetailedDescriptions")
util.AddNetworkString("EditDetailedDescriptions")

net.Receive("EditDetailedDescriptions", function()
	local textEntryURL = net.ReadString()
	local text = net.ReadString()
	local toUse = net.ReadString()
	
	for key, toEdit in pairs(player.GetAll()) do
		if toEdit:SteamName() == toUse then
			toEdit:GetCharacter():SetData("textDetDescData", text)
			toEdit:GetCharacter():SetData("textDetDescDataURL", textEntryURL)
		end
	end
end)

function PLUGIN:OnPlayerOptionSelected(client, callingClient, option)
	if (option == "Examine") then
		local toSet = client:SteamName()
		local toSetDisplay = client:Name()
		local textEntryData = tostring(client:GetCharacter():GetData("textDetDescData"))
		local textEntryDataURL = tostring(client:GetCharacter():GetData("textDetDescDataURL"))

		net.Start("OpenDetailedDescriptions")
		net.WriteString(toSet)
		net.WriteString(toSetDisplay)
		if (textEntryData == "nil") then
			net.WriteString("No detailed description found")
			net.WriteString("No detailed description found")
		else
			net.WriteString(textEntryData)
			net.WriteString(textEntryDataURL)
		end
		net.Send(callingClient)
	end
end
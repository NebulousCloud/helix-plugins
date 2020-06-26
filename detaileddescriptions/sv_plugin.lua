util.AddNetworkString("ixOpenDetailedDescriptions")
util.AddNetworkString("ixSetDetailedDescriptions")
util.AddNetworkString("ixEditDetailedDescriptions")

net.Receive("ixEditDetailedDescriptions", function()
	local textEntryURL = net.ReadString()
	local text = net.ReadString()
	local callingClientSteamName = net.ReadString()
	
	for key, client in pairs(player.GetAll()) do
		if client:SteamName() == callingClientSteamName then
			client:GetCharacter():SetData("textDetDescData", text)
			client:GetCharacter():SetData("textDetDescDataURL", textEntryURL)
		end
	end
end)

function PLUGIN:OnPlayerOptionSelected(client, callingClient, option)
	if (option == "Examine") then
		local textEntryData = client:GetCharacter():GetData("textDetDescData", nil) or "No detailed description found."
		local textEntryDataURL = client:GetCharacter():GetData("textDetDescDataURL", nil) or "No detailed description found."

		net.Start("ixOpenDetailedDescriptions")
			net.WriteEntity(client)
			net.WriteString(textEntryData)
			net.WriteString(textEntryDataURL)
		net.Send(callingClient)
	end
end
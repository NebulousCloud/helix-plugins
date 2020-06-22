util.AddNetworkString("OpenDetailedDescriptions")
util.AddNetworkString("SetDetailedDescriptions")
util.AddNetworkString("EditDetailedDescriptions")
util.AddNetworkString("ExamineDetailedDescriptions")

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

net.Receive("ExamineDetailedDescriptions", function()
	local entity = net.ReadEntity()
	local client = net.ReadEntity()
	local toSet = entity:SteamName()
	local toSetDisplay = entity:Name()
	local textEntryData = tostring(entity:GetCharacter():GetData("textDetDescData"))
	local textEntryDataURL = tostring(entity:GetCharacter():GetData("textDetDescDataURL"))
	
	if !(client:GetPos():Distance(entity:GetPos()) <= 100) then return end

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
	net.Send(client)
end)
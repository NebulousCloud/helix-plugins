
function PLUGIN:PopulateCharacterInfo(client, character, container)
	if (client:Alive() and client:GetNetVar("IsAFK")) then
		local panel = container:AddRow("afk")
		panel:SetText(L("charAFK"))
		panel:SetBackgroundColor(Color(30, 30, 30, 255))
		panel:SizeToContents()
		panel:Dock(BOTTOM)
	end
end

net.Receive("ixOpenDetailedDescriptions", function()
	local client = net.ReadEntity()
	local textEntryData = net.ReadString()
	local textEntryDataURL = net.ReadString()
	
	local Frame = vgui.Create("DFrame")
	Frame:Center()
	Frame:SetPos(Frame:GetPos() - 150, 250, 0)
	Frame:SetSize(350, 500)
	Frame:SetTitle("Detailed Description - " .. client:Name())
	Frame:MakePopup()

	local List = vgui.Create("DListView", Frame)
	List:Dock( FILL )
	List:DockMargin( 0, 0, 0, 5 )
	List:SetMultiSelect(false)
	
	local textEntry = vgui.Create("DTextEntry", List)
	textEntry:Dock( FILL )
	textEntry:DockMargin( 0, 0, 0, 0 )
	textEntry:SetMultiline(true)
	textEntry:SetVerticalScrollbarEnabled(true)

	textEntry:SetText(textEntryData)
	
	local DButton = vgui.Create("DButton", List)
	if (textEntryDataURL == "No detailed description found.") then
		DButton:SetDisabled(true)
	else
		DButton:SetTextColor(Color(0, 0, 0, 255))
	end
	DButton:SetText("View Reference Picture")
	DButton:Dock( BOTTOM )
	DButton:DockMargin( 0, 0, 0, 0 )
	
	DButton.DoClick = function()
		gui.OpenURL(textEntryDataURL)
	end
end)

net.Receive("ixSetDetailedDescriptions", function()
	local callingClientSteamName = net.ReadString()
	
	local Frame = vgui.Create("DFrame")
	Frame:Center()
	Frame:SetPos(Frame:GetPos() - 150, 250, 0)
	Frame:SetSize(350, 500)
	Frame:SetTitle("Edit Detailed Description")
	Frame:MakePopup()

	local List = vgui.Create("DListView", Frame)
	List:Dock( FILL )
	List:DockMargin( 0, 0, 0, 5 )
	List:SetMultiSelect(false)
	
	local textEntry = vgui.Create("DTextEntry", List)
	textEntry:Dock( FILL )
	textEntry:DockMargin( 0, 0, 0, 0 )
	textEntry:SetMultiline(true)
	textEntry:SetVerticalScrollbarEnabled(true)
	
	if (LocalPlayer():GetCharacter():GetData("textDetDescData")) then
		textEntry:SetText(LocalPlayer():GetCharacter():GetData("textDetDescData"))
	end
	
	local DButton = vgui.Create("DButton", List)
	DButton:DockMargin( 0, 0, 0, 0 )
	DButton:Dock( BOTTOM )
	DButton:SetText("Edit")
	DButton:SetTextColor(Color(0, 0, 0, 255))
	
	local textEntryURL = vgui.Create("DTextEntry", List)
	textEntryURL:Dock( BOTTOM )
	textEntryURL:DockMargin( 0, 0, 0, 0 )
	textEntryURL:SetValue("Reference Image URL")
	
	if (LocalPlayer():GetCharacter():GetData("textDetDescDataURL")) then
		textEntryURL:SetValue(LocalPlayer():GetCharacter():GetData("textDetDescDataURL"))
		textEntryURL:SetText(LocalPlayer():GetCharacter():GetData("textDetDescDataURL"))
	end
	
	DButton.DoClick = function()
		net.Start("ixEditDetailedDescriptions")
			net.WriteString(textEntryURL:GetValue())
			net.WriteString(textEntry:GetValue())
			net.WriteString(callingClientSteamName)
		net.SendToServer()
		Frame:Remove()
	end
end)

function PLUGIN:GetPlayerEntityMenu(client, options)
	options["Examine"] = true
end
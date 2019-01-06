local function ixActMenu()
	local animation = {"/Actstand","/Actsit","/Actsitwall","/Actcheer","/Actlean","/Actinjured","/Actarrestwall","/Actarrest","/Actthreat","/Actdeny","/Actmotion","/Actwave","/Actpant","/ActWindow"}
	local animationdesc = {"Stand here","Sit","Sit against a wall","Cheer","Lean against a wall","Lay on the ground injured","Face a wall","Put your hands on your head","Threat","Deny","Motion","Wave","Pant","Lay against a window"}
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( 500, 300 )
	frame:SetTitle( "Utilitary Menu" )
	frame:MakePopup()
	frame:Center()

	local left = vgui.Create( "DScrollPanel", frame )
	left:Dock( LEFT )
	left:SetWidth( frame:GetWide() / 2 - 7 )
	left:SetPaintBackground( true )
	left:DockMargin( 0, 0, 4, 0 )

	local right = vgui.Create( "DScrollPanel", frame )
	right:Dock( FILL )
	right:SetPaintBackground( true )

	for i = 1, 14 do
		local but = vgui.Create( "DButton", frame )
		but:SetText( animationdesc [i] )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 24 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", animation [i])
		end
		right:AddItem( but )
	end
	
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "".. LocalPlayer():GetCharacter():GetName() )
		Perso:SetSize( 36, 21 )
		left:AddItem( Perso )
		
		local faction = ix.faction.indices[LocalPlayer():GetCharacter():GetFaction()]
		
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "Faction : ".. faction.name )
		Perso:SetSize( 36, 20 )
		left:AddItem( Perso )
		
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "Tokens : ".. ix.currency.Get(LocalPlayer():GetCharacter():GetMoney()) )
		Perso:SetSize( 36, 20 )
		left:AddItem( Perso )
		
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "Health : ".. LocalPlayer():Health() )
		Perso:SetSize( 36, 20 )
		left:AddItem( Perso )
		
		local Perso = vgui.Create( "DLabel", frame )
		Perso:Dock( TOP )
		Perso:DockMargin( 8, 0, 0, 0 )
		Perso:SetFont("ixSmallFont")
		Perso:SetText( "Armor : ".. LocalPlayer():Armor() )
		Perso:SetSize( 36, 20 )
		left:AddItem( Perso )
		
		local but = vgui.Create( "DButton", frame )
		but:SetText( "Description" )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 50 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", "/chardesc")
		end
		left:AddItem( but )
		
				local but = vgui.Create( "DButton", frame )
		but:SetText( "Enhanced Description" )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 50 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", "/selfdesc")
		end
		left:AddItem( but )
	
		local but = vgui.Create( "DButton", frame )
		but:SetText( "Fall over" )
		but:SetFont("ixSmallFont")
		but:SetSize( 36, 50 )
		but:Dock( TOP )
		but.DoClick = function()
			frame:Close()
			RunConsoleCommand("say", "/charfallover")
		end
		left:AddItem( but )
end
usermessage.Hook("ixActMenu", ixActMenu)

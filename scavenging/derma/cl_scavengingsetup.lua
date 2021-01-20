local PLUGIN = PLUGIN;
local PANEL = {};

function PANEL:Init()
	if( IsValid( PLUGIN.Panel ) ) then
		PLUGIN.Panel:Remove();
	end

	self:SetSize( 180, 90 );
	self:Center();
	self:SetBackgroundBlur( true );
	self:SetDeleteOnClose( true );
	self:SetTitle( "Scavenging: Setup" );

	self.Save = self:Add( "DButton" );
	self.Save:Dock( BOTTOM );
	self.Save:DockMargin( 0, 4, 0, 0 )
	self.Save:SetText( "Finalize" );
	self.Save.DoClick = function()
		local name, data = self.ComboBox:GetSelected();
		if( name ) then
			net.Start( "ixScavengingSetupFinalize" );
				net.WriteEntity( self.Entity );
				net.WriteString( name );
			net.SendToServer();
		end
		self:Close();
	end

	self.ComboBox = self:Add( "DComboBox" );
	self.ComboBox:SetDisabled( false );
	self.ComboBox:Dock( FILL );

	self:MakePopup();
	PLUGIN.Panel = self;
end

function PANEL:Setup( entity, tabl )
	if( !entity or !tabl ) then
		self:Close();
	end
	self.Entity = entity;
	self.List = tabl;
	for name, _ in pairs( self.List ) do
		self.ComboBox:AddChoice( name, nil, false, nil );
	end
end

function PANEL:OnRemove()
	PLUGIN.Panel = nil;
end

vgui.Register( "ixScavengingSetup", PANEL, "DFrame" );

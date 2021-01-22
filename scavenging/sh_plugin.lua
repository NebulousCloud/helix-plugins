PLUGIN.name = "Scavenging"; 
PLUGIN.author = "Rune Knight";
PLUGIN.description = "Adds an usable and configurable entity which players can use for purposes such as gathering items and credits.";
PLUGIN.license = [[Copyright 2021 Rune Knight

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.]];

--[[
	STEAM: https://steamcommunity.com/profiles/76561198028996329/
	DISCORD: Rune Knight#5972
]]

-- Configuration:
-- If false, this means that no more item spawning. This does not mean prevention of looking into the entity's inventory.
ix.config.Add( "scavengingEnabled", true, "Should players be allowed to scavenge at all?", nil, {
	category = "Scavenging"
});

-- This is compares table.Count( player.GetAll() ) to this number. If it's under that number, then scavenging is disabled as if like above.
ix.config.Add( "scavengingPlayerMinimum", 5, "If there is not this many players (has to be equal or greater), then scavenging will be prevented.", nil, {
	data = { min = 1, max = 60 },
	category = "Scavenging"
});

-- When you scavenge, this is how long (in seconds) you'll have to wait to complete scavenging.
ix.config.Add( "scavengingDelay", 5, "If a character begins to scavenge, how long will they have to wait until they finish?", nil, {
	data = { min = 1, max = 60 },
	category = "Scavenging"
});

-- After finishing scavenging, you can do it again after this amount of seconds.
ix.config.Add( "scavengingCooldown", 1800, "Once something is scavenged, how long until it can be scavenged again?", nil, {
	data = { min = 30, max = 7200 },
	category = "Scavenging";
});

function PLUGIN:GetScavengingEnabled()
	return ix.config.Get( "scavengingEnabled", true );
end

function PLUGIN:GetScavengingPlayerMinimum()
	return ix.config.Get( "scavengingPlayerMinimum", 5 );
end

function PLUGIN:GetScavengingDelay()
	return ix.config.Get( "scavengingDelay", 5 );
end

function PLUGIN:GetScavengingCooldown()
	return ix.config.Get( "scavengingCooldown", 1800 );
end

-- Privileges:
CAMI.RegisterPrivilege({
	Name = "Scavenging: Setup",
	MinAccess = "superadmin"
});

CAMI.RegisterPrivilege({
	Name = "Scavenging: Change Display Name",
	MinAccess = "superadmin"
});

CAMI.RegisterPrivilege({
	Name = "Scavenging: Change Display Description",
	MinAccess = "superadmin"
});

CAMI.RegisterPrivilege({
	Name = "Scavenging: Change Model",
	MinAccess = "superadmin"
});

-- Files:
ix.util.Include( "cl_plugin.lua" );
ix.util.Include( "sv_configuration.lua" );
ix.util.Include( "sv_plugin.lua" );

-- Context Menu:
properties.Add( "scavenging_changedisplayname", {
	MenuLabel = "Change Display Name",
	Order = 401,
	MenuIcon = "icon16/pencil.png",
	Filter = function( self, entity, client )
		if( entity:GetClass() != "ix_scavengingpile" ) then return end;
		if( !gamemode.Call( "CanProperty", client, "scavenging_changedisplayname", entity ) ) then return end;
		if( !CAMI.PlayerHasAccess( client, "Scavenging: Change Display Name", nil ) ) then return end;
		return true;
	end,
	Action = function( self, entity )
		Derma_StringRequest( "Change Display Name", "", "", function( text )
			self:MsgStart();
				net.WriteEntity( entity );
				net.WriteString( text );
			self:MsgEnd();
		end )
	end,
	Receive = function( self, length, client )
		local entity = net.ReadEntity();
		local string = net.ReadString();
		if( !IsValid( entity ) ) then return end;
		if( !self:Filter( entity, client ) ) then return end;
		if( !entity.Vars.Configured ) then return end;
		-- Logging:
		ix.log.Add( client, "scavengingChangeVariable", "display name", entity:GetInventoryID(), entity:GetDisplayName(), string );
		-- Main:
		entity:SetDisplayName( string );
	end
});

properties.Add( "scavenging_changedisplaydescription", {
	MenuLabel = "Change Display Description",
	Order = 401,
	MenuIcon = "icon16/pencil.png",
	Filter = function( self, entity, client )
		if( entity:GetClass() != "ix_scavengingpile" ) then return end;
		if( !gamemode.Call( "CanProperty", client, "scavenging_changedisplaydescription", entity ) ) then return end;
		if( !CAMI.PlayerHasAccess( client, "Scavenging: Change Display Description", nil ) ) then return end;
		return true;
	end,
	Action = function( self, entity )
		Derma_StringRequest( "Change Display Description", "", "", function( text )
			self:MsgStart();
				net.WriteEntity( entity );
				net.WriteString( text );
			self:MsgEnd();
		end )
	end,
	Receive = function( self, length, client )
		local entity = net.ReadEntity();
		local string = net.ReadString();
		if( !IsValid( entity ) ) then return end;
		if( !self:Filter( entity, client ) ) then return end;
		if( !entity.Vars.Configured ) then return end;
		-- Logging:
		ix.log.Add( client, "scavengingChangeVariable", "display description", entity:GetInventoryID(), entity:GetDisplayName(), string );
		-- Main:
		entity:SetDisplayDescription( string );
	end
});

properties.Add( "scavenging_changemodel", {
	MenuLabel = "Change Model",
	Order = 401,
	MenuIcon = "icon16/pencil.png",
	Filter = function( self, entity, client )
		if( entity:GetClass() != "ix_scavengingpile" ) then return end;
		if( !gamemode.Call( "CanProperty", client, "scavenging_changemodel", entity ) ) then return end;
		if( !CAMI.PlayerHasAccess( client, "Scavenging: Change Model", nil ) ) then return end;
		return true;
	end,
	Action = function( self, entity )
		Derma_StringRequest( "Change Model", "", "", function( text )
			self:MsgStart();
				net.WriteEntity( entity );
				net.WriteString( text );
			self:MsgEnd();
		end )
	end,
	Receive = function( self, length, client )
		local entity = net.ReadEntity();
		local string = net.ReadString();
		if( !IsValid( entity ) ) then return end;
		if( !self:Filter( entity, client ) ) then return end;
		if( !util.IsValidModel( string ) ) then return end;
		if( !entity.Vars.Configured ) then return end;
		-- Logging:
		ix.log.Add( client, "scavengingChangeVariable", "model", entity:GetInventoryID(), entity:GetDisplayName(), string );
		-- Main:
		entity:SetModel( string );
		entity:SetSolid( SOLID_VPHYSICS );
		entity:PhysicsInit( SOLID_VPHYSICS );
		-- Physics:
		local physics = entity:GetPhysicsObject();
		physics:EnableMotion( false );
		physics:Sleep();
	end
});
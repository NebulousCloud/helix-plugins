local PLUGIN = PLUGIN;
ix = ix or {};
ix.Scavenging = ix.Scavenging or {};
ix.Scavenging.InformationTables = ix.Scavenging.InformationTables or {};

-- Network:
util.AddNetworkString( "ixScavengingSetup" );
util.AddNetworkString( "ixScavengingSetupFinalize" );

net.Receive( "ixScavengingSetupFinalize", function( len, client )
	-- Variables:
	local entity = net.ReadEntity();
	local name = net.ReadString();
	-- Checks:
	if( !IsValid( entity ) ) then return end;
	if( entity:GetClass() != "ix_scavengingpile" ) then return end;
	if( !ix.Scavenging.InformationTables[name] ) then return end;
	if( !entity:GetVars() ) then return end;
	if( !CAMI.PlayerHasAccess( client, "Scavenging: Setup", nil ) ) then return end;
	if( entity:GetConfigured() ) then return end;

	-- Variables:
	local model = ix.Scavenging.InformationTables[name]["StartingModel"];
	-- Main:
	entity:SetModel( model );
	entity:SetSolid( SOLID_VPHYSICS );
	entity:PhysicsInit( SOLID_VPHYSICS );
	-- Physics:
	local physics = entity:GetPhysicsObject();
	physics:EnableMotion( false );
	physics:Sleep();
	-- Main:
	entity:SetConfigured( true );
	entity:SetTableName( name );
	local tabl = entity:CreateInventory( name );
	entity:SetDisplayName( ix.Scavenging.InformationTables[name]["Display Name"] );
	entity:SetDisplayDescription( ix.Scavenging.InformationTables[name]["Display Description"] );
	-- Logging:
	ix.log.Add( client, "scavengingSetup", entity:GetInventoryID(), entity:GetDisplayName() );
	-- Saving:
	PLUGIN:SaveData();
end)

-- Data:
function PLUGIN:SaveData()
	local data = {};
	for _, v in pairs( ents.FindByClass( "ix_scavengingpile" ) ) do
		data[#data + 1] = {
			Model = v:GetModel(),
			Position = v:GetPos(),
			Angles = v:GetAngles(),
			DisplayName = v:GetDisplayName(),
			DisplayDescription = v:GetDisplayDescription(),
			Vars = v.Vars
		};
	end
	self:SetData( data );
end

function PLUGIN:LoadData()
	local data = self:GetData();
	for _, v in pairs( data ) do
		if( !v.Vars.Configured ) then continue end;
		local ent = ents.Create( "ix_scavengingpile" );
		ent:SetPos( v["Position"] );
		ent:SetAngles( v["Angles"] );
		ent:Spawn(); -- Runs the entity's Initialize().
		ent:SetModel( v["Model"] );
		ent:PhysicsInit( SOLID_VPHYSICS );
		ent:SetSolid( SOLID_VPHYSICS );
		-- Physics:
		local physics = ent:GetPhysicsObject();
		physics:EnableMotion( false );
		physics:Sleep();
		-- Variables:
		ent:SetDisplayName( v["DisplayName"] );
		ent:SetDisplayDescription( v["DisplayDescription"] );
		ent.Vars = v.Vars;
		-- Inventories:
		ix.item.RestoreInv( ent:GetInventoryID(), self.Loot[ent:GetTableName()]["Inventory Width"], self.Loot[ent:GetTableName()]["Inventory Height"], 
		function( inventory )
			inventory.vars.isBag = true;
			inventory.vars.isContainer = true;
		end)
		-- Just in case.
		if( !ix.item.inventories[ent:GetInventoryID()] ) then
			local tabl = PLUGIN:CreateInventory( ent:GetTableName() );
			ent:SetInventoryID( tabl["InventoryID"] );
		end
	end
	PLUGIN:SaveData();
end

-- Logging:
ix.log.AddType( "scavengingOpen", function( client, ... )
	local arg = { ... };
	return string.format( "%s opened scavenging container #%d, '%s'.", client:Name(), arg[1], arg[2] );
end)

ix.log.AddType( "scavengingClose", function( client, ... )
	local arg = { ... };
	return string.format( "%s closed scavenging container #%d, '%s'.", client:Name(), arg[1], arg[2] );
end)

ix.log.AddType( "scavengingSetup", function( client, ... )
	local arg = { ... };
	return string.format( "%s completed setup for scavenging container #%d, now '%s'.", client:Name(), arg[1], arg[2] );
end)

ix.log.AddType( "scavengingScavenging", function( client, ... )
	local arg = { ... };
	return string.format( "%s completed scavenging for scavenging container #%d, '%s'.", client:Name(), arg[1], arg[2] );
end)

ix.log.AddType( "scavengingChangeVariable", function( client, ... )
	local arg = { ... };
	return string.format( "%s changed the %s of scavenging container #%d, '%s' to '%s'.", client:Name(), arg[1], arg[2], arg[3], arg[4] );
end)

--[[
	This is for compatibility with other plugins.
]]
function PLUGIN:SetInventoryTable( name, content )
	ix.Scavenging.InformationTables[name] = content;
end
ix.Scavenging.SetInventoryTable = PLUGIN.SetInventoryTable;


PLUGIN.AddInformationTable = PLUGIN.SetInventoryTable;
ix.Scavenging.AddInformationTable = PLUGIN.AddInformationTable;

-- Registering Inventories:
do
    for name, info in pairs( ix.Scavenging.InformationTables ) do
        ix.inventory.Register( "ix_scavengingpile_" .. name, info["Inventory Width"], info["Inventory Height"], true );
    end
end

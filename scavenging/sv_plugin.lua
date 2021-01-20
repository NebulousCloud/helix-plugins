local PLUGIN = PLUGIN;

-- Network:
util.AddNetworkString( "ixScavengingSetup" );
util.AddNetworkString( "ixScavengingSetupFinalize" );

-- Utility:
function PLUGIN:CanUse( client, character, entity )
	return true;
end

function PLUGIN:CanScavenge( client, character, entity )
	if( !self:GetScavengingEnabled() ) then
		return "Scavenging is currently disabled.";
	end
	if( table.Count( player.GetAll() ) < self:GetScavengingPlayerMinimum() ) then
		return "There is not enough players on.";
	end
	if( !self:IsEntityOffCooldown( entity ) ) then
		return "Try again in " .. tostring( self:GetRemainingCooldown( entity ) ) .. " seconds.";
	end
	if( !character:GetInventory():HasItem( "scavengingkit" ) ) then
		return "You don't have a scavenging kit.";
	end
	return true;
end

-- Inventories:
function PLUGIN:ShouldCreateInventory( name, fullpath )
	if( !name and !fullpath ) then return end;
	return true;
end

function PLUGIN:CreateInventory( name, fullpath )
	-- Checks:
	if( !self:ShouldCreateInventory( name, fullpath ) ) then return end;
	-- Vars:
	local preset = fullpath or "ix_scavengingpile_" .. name;
	local tabl = {};
	-- Inventory:
	ix.inventory.New( 0, preset, function( inventory )
		inventory.vars.isBag = true;
		inventory.vars.isContainer = true;
		tabl["Inventory"] = inventory;
		tabl["InventoryID"] = inventory:GetID();
	end);
	-- Returns:
	return tabl;
end

function PLUGIN:ShouldRemoveInventory( id )
	-- Checks:
	if( !id or id == 0 or !ix.item.inventories[id] ) then return end;
	if( ix.shuttingDown ) then return end;
	-- Return:
	return true;
end

function PLUGIN:RemoveInventory( id )
	-- Checks:
	if( !self:ShouldRemoveInventory( id ) ) then return end;
	-- Main:
	ix.item.inventories[id] = nil;
	local query = mysql:Delete( "ix_items" );
		query:Where( "inventory_id", id );
	query:Execute();
	query = mysql:Delete( "ix_inventories" );
		query:Where( "inventory_id", id );
	query:Execute();
end

-- Entities:
function PLUGIN:GetRemainingCooldown( entity )
	return math.Round( math.Clamp( ( entity.Vars.LastUsedTime + self:GetScavengingCooldown() ) - CurTime(), 0, self:GetScavengingCooldown() ) );
end

function PLUGIN:IsEntityOffCooldown( entity )
	if( self:GetRemainingCooldown( entity ) == 0 ) then
		return true;
	end
	return false;
end

function PLUGIN:ShouldSetup( client, entity )
	-- Checks:
	if( !entity or !entity.Vars ) then 
		return "This entity has invalid variables. This is actually bad.";
	end
	if( !CAMI.PlayerHasAccess( client, "Scavenging: Setup", nil ) ) then 
		return "You don't have permission to perform setup.";
	end
	if( entity.Vars.Configured ) then return end;
	-- Return:
	return true;
end

function PLUGIN:Setup( client, entity )
	-- Checks:
	if( self:ShouldSetup( client, entity ) != true ) then return end;
	-- Variables:
	local tabl = {};
	for name, _ in pairs( PLUGIN.Loot ) do
		tabl[name] = true;
	end
	-- Main:
	net.Start( "ixScavengingSetup" );
		net.WriteEntity( entity );
		net.WriteTable( tabl );
	net.Send( client );
end

net.Receive( "ixScavengingSetupFinalize", function( len, client )
	-- Variables:
	local entity = net.ReadEntity();
	local name = net.ReadString();
	-- Checks:
	if( !IsValid( entity ) ) then return end;
	if( entity:GetClass() != "ix_scavengingpile" ) then return end;
	if( !PLUGIN.Loot[name] ) then return end;
	if( PLUGIN:ShouldSetup( client, entity ) != true ) then return end; -- It'll return nil, text, or true. We don't want true.
	-- Variables:
	local model = PLUGIN.Loot[name]["StartingModel"];
	-- Main:
	entity:SetModel( model );
	entity:SetSolid( SOLID_VPHYSICS );
	entity:PhysicsInit( SOLID_VPHYSICS );
	-- Physics:
	local physics = entity:GetPhysicsObject();
	physics:EnableMotion( false );
	physics:Sleep();
	-- Main:
	entity.Vars.TableName = name;
	entity:SetDisplayName( PLUGIN.Loot[name]["Display Name"] );
	entity:SetDisplayDescription( PLUGIN.Loot[name]["Display Description"] );
	entity.Vars.Configured = true;
	local tabl = PLUGIN:CreateInventory( name );
	entity:SetInventoryID( tabl["InventoryID"] );
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

-- Registering Inventories:
do
    for name, info in pairs( PLUGIN.Loot ) do
        ix.inventory.Register( "ix_scavengingpile_" .. name, info["Inventory Width"], info["Inventory Height"], true );
    end
end

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
   This is an precaution for any fuck-ups in the configuration.
]]
for name, content in pairs( PLUGIN.Loot ) do
    -- Display Name:
    if( !content["Display Name"] ) then
        PLUGIN.Loot[name]["Display Name"] = "No Display Name Found";
    end
    -- Display Description:
    if( !content["Display Description"] ) then
        PLUGIN.Loot[name]["Display Description"] = "No Display Description Found";
    end
    -- StartingModel:
    if( !content["StartingModel"] ) then
        PLUGIN.Loot[name]["StartingModel"] = "models/hunter/blocks/cube025x025x025.mdl";
    end
    -- Inventory Width:
    if( !content["Inventory Width"] ) then
        PLUGIN.Loot[name]["Inventory Width"] = 1;
    end
    -- Inventory Height:
    if( !content["Inventory Height"] ) then
        PLUGIN.Loot[name]["Inventory Height"] = 1;
    end
    -- Usage Message:
    if( !content["Usage Message"] ) then
        PLUGIN.Loot[name]["Usage Message"] = function( client, character, entity, ShouldScavenge )
            if( ShouldScavenge ) then
                return "Scavenging...";
            end
            return "Checking...";
        end
    end
    -- Amount of Spawned Items:
    if( !content["Amount of Spawned Items"] ) then
        PLUGIN.Loot[name]["Amount of Spawned Items"] = function( client, character, entity )
            return 1;
        end
    end
    -- Amount of Spawned Credits:
    if( !content["Amount of Spawned Credits"] ) then
        PLUGIN.Loot[name]["Amount of Spawned Credits"] = function( client, character, entity )
            return 0;
        end
    end
    -- Possible Items:
    if( !content["Possible Items"] ) then
        PLUGIN.Loot[name]["Possible Items"] = function( client, character, entity )
            local Items = { 
                [1] = {
                    ["ItemID"] = "water",
                    ["Data"] = {},
                    ["Chance"] = 1
                },
                [2] = {
                    ["ItemID"] = "request_device",
                    ["Data"] = {},
                    ["Chance"] = 1
                }
            };
            return Items;
        end
    end
end
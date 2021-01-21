AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

local PLUGIN = PLUGIN;

function ENT:Initialize()
	-- Initialize:
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );
	self:SetUseType( SIMPLE_USE );
	-- Physics:
	local physics = self:GetPhysicsObject();
	physics:EnableMotion( false );
	physics:Sleep();
	-- Variables:
	self.Vars = {};
	self.Vars.Configured = false;
	self.Vars.RemainingCooldown = 0;
	self.Vars.TableName = nil; -- 
	self.Vars.Money = 0;
	self.Vars.InventoryID = 0;
	self:SetDisplayName( "Default Display Name" );
	self:SetDisplayDescription( "Default Display Description" );
end

-- Information:
function ENT:GetVars()
	return self.Vars;
end

function ENT:SetVars( tabl )
	self.Vars = tabl;
end

function ENT:GetConfigured()
	return self.Vars.Configured;
end

function ENT:SetConfigured( bool )
	self.Vars.Configured = bool;
end

function ENT:GetRemainingCooldown()
	return self.Vars.RemainingCooldown;
end

function ENT:SetRemainingCooldown( num )
	self.Vars.RemainingCooldown = num;
end

function ENT:GetTableName()
	return self.Vars.TableName;
end

function ENT:SetTableName( str )
	self.Vars.TableName = str;
end

function ENT:GetMoney()
	return self.Vars.Money;
end

function ENT:SetMoney( num )
	self.Vars.Money = num;
end

function ENT:GetInventoryID()
	return self.Vars.InventoryID;
end

function ENT:SetInventoryID( num )
	self.Vars.InventoryID = num;
end

-- Inventory:
function ENT:GetInventory()
	return ix.item.inventories[self:GetInventoryID()];
end

function ENT:CreateInventory()
	ix.inventory.New( 0, "ix_scavengingpile_" .. self.Vars.TableName, function( inventory )
		inventory.vars.isBag = true;
		inventory.vars.isContainer = true;
		self:SetInventoryID( inventory:GetID() ); -- Can we even use "self"?
	end);
end

function ENT:RemoveInventory()
	ix.item.inventories[self:GetInventoryID()] = nil;
	local query = mysql:Delete( "ix_items" );
		query:Where( "inventory_id", self:GetInventoryID() );
	query:Execute();
	query = mysql:Delete( "ix_inventories" );
		query:Where( "inventory_id", self:GetInventoryID() );
	query:Execute();
	self:SetInventoryID( 0 );
end

function ENT:OpenInventory( client )
	ix.log.Add( client, "scavengingOpen", self:GetInventoryID(), self:GetDisplayName() );
	ix.storage.Open( client, self:GetInventory(), {
		name = self:GetDisplayName(),
		entity = self,
		data = { 
			money = self:GetMoney()
		},
		OnPlayerClose = function()
			ix.log.Add( client, "scavengingClose", self:GetInventoryID(), self:GetDisplayName() );
		end,
		searchTime = 0, 
	});
end

-- Spawning/Removal:
function ENT:SpawnFunction( client, trace )
	local ent = ents.Create( "ix_scavengingpile" );
	ent:SetPos( trace.HitPos + Vector( 0, 0, 0 ) );
	ent:SetAngles( Angle( 0, ( ent:GetPos() - client:GetPos() ):Angle().y, 0 ) );
	ent:Spawn();
	ent:Activate();
	return ent;
end

function ENT:OnRemove()
	--[[
		The entity is only properly removed if done by any method that isn't shutting down the server.
	]]
	-- Checks:
	if( ix.shuttingDown ) then return end;
	-- Main:
	self:RemoveInventory();
	-- Saving:
	PLUGIN:SaveData();
end

-- Setup:
function ENT:Setup( client )
	--[[
		nil		return;
		false 	return;
		string 	return & client:Notify();
		true	return true;
	]]
	-- Checks:
	if( !self:GetVars() ) then
		return "This entity does not have any variables.";
	elseif( !CAMI.PlayerHasAccess( client, "Scavenging: Setup", nil ) ) then 
		return "You don't have permission to perform setup.";
	end
	if( !self:GetConfigured() ) then
		-- Getting Names:
		local tabl = {};
		for name, _ in pairs( ix.Scavenging.InformationTables ) do
			tabl[name] = true;
		end
		-- Sending to Client:
		net.Start( "ixScavengingSetup" );
			net.WriteEntity( self );
			net.WriteTable( tabl );
		net.Send( client );
		return false;
	end
	return true;
end

-- CanUse/CanScavenge:
function ENT:CanUse( client, character )
	return true;
end

function ENT:CanScavenge( client, character )
	if( !PLUGIN:GetScavengingEnabled() ) then
		return "Scavenging is currently disabled.";
	end
	if( table.Count( player.GetAll() ) < PLUGIN:GetScavengingPlayerMinimum() ) then
		return "There is not enough players on.";
	end
	if( self:GetRemainingCooldown() != 0 ) then
		return "Try again in " .. tostring( self:GetRemainingCooldown() ) .. " seconds.";
	end
	if( !character:GetInventory():HasItem( "scavengingkit" ) ) then
		return "You don't have a scavenging kit.";
	end
	return true;
end

-- Main:
function ENT:Use( client )
	-- Checks:
	local character = client:GetCharacter();
	if( !character ) then return end;
	local stabl = ix.Scavenging.InformationTables;
	if( !stabl ) then
		client:Notify( "Unable to find main Information Table." );
	end
	-- Setup:
	local ret = self:Setup( client );
	if( !ret ) then
		return;
	elseif( ix.util.GetTypeFromValue( ret ) == ix.type.string ) then
		client:Notify( ret );
		return;
	end
	-- Checks 2:
	local tabl = stabl[self:GetTableName()];
	if( !tabl ) then
		client:Notify( "Unable to find specific Information Table: '" .. self:GetTableName() .. "'." );
	end
	-- CanUse:
	if( !tabl["CanUse"] or tabl["CanUse"]( client, character, self ) == nil ) then
		local ret = self:CanUse( client, character );
		if( !ret ) then return;
		elseif( ix.util.GetTypeFromValue( ret ) == ix.type.string ) then
			client:Notify( ret );
			return;
		end
	else
		local ret = tabl["CanUse"]( client, character, self );
		if( !ret ) then return;
		elseif( ix.util.GetTypeFromValue( ret ) == ix.type.string ) then
			client:Notify( ret );
			return;
		end
	end
	-- CanScavenge:
	local ShouldScavenge = true;
	if( !tabl["CanScavenge"] or tabl["CanScavenge"]( client, character, self ) == nil ) then
		ShouldScavenge = self:CanScavenge( client, character );
	else
		ShouldScavenge = tabl["CanScavenge"]( client, character, self );
	end
	-- Allowing/Disallowing Viewing:
	if( ( !ShouldScavenge or ShouldScavenge != true ) ) then 
		if( table.Count( self:GetInventory():GetItems() ) == 0 and self:GetMoney() == 0 ) then
			if( ix.util.GetTypeFromValue( ShouldScavenge ) == ix.type.string ) then
				client:Notify( ShouldScavenge );
			end
			return;
		end
		ShouldScavenge = false;
	end
	-- Vars:
	local UsageMessage = tabl["Usage Message"]( client, character, self, ShouldScavenge );
	local SItems = tabl["Amount of Spawned Items"]( client, character, self );
	local SCredits = tabl["Amount of Spawned Credits"]( character, character, self );
	local PItems = tabl["Possible Items"]( character, character, self );
	-- Main:
	client:SetAction( UsageMessage, PLUGIN:GetScavengingDelay() );
	client:DoStaredAction( self, function()
		if( ShouldScavenge ) then
			if( tabl["PerformScavenge"] ) then
				tabl["PerformScavenge"]( client, character, self, ShouldScavenge );
			else
				local ItemsToSpawn = {};
				local PossibleItems = {};
				-- Compiling:
				for _, info in pairs( PItems ) do
					local ItemID = info["ItemID"];
					local Data = info["Data"] or {};
					local Chance = info["Chance"] or 1;
					for i = 1, Chance do
						local Next = table.Count( PossibleItems ) + 1;
						PossibleItems[Next] = {
							["ItemID"] = ItemID,
							["Data"] = Data,
						};
					end
				end
				-- Randomly Selecting:
				for i = 1, SItems do
					local Next = table.Count( ItemsToSpawn ) + 1;
					local Selected = table.Random( PossibleItems );
					ItemsToSpawn[Next] = Selected;
				end
				-- Spawning:
				for _, info in pairs( ItemsToSpawn ) do
					if( !self:GetInventory():Add( info["ItemID"], 1, info["Data"] ) ) then
						local item = ix.item.Spawn( info["ItemID"], self:GetPos(), nil, nil, info["Data"] );
					end
				end
				if( SCredits and ix.util.GetTypeFromValue( SCredits ) == ix.type.number and math.max( 0, self:GetMoney() + SCredits ) != 0 ) then
					self:SetMoney( self:GetMoney() + SCredits );
				end
				self:SetRemainingCooldown( PLUGIN:GetScavengingCooldown() );
			end
			-- Logging:
			ix.log.Add( client, "scavengingScavenging", self:GetInventoryID(), self:GetDisplayName() );
		end
		self:OpenInventory( client );
	end, PLUGIN:GetScavengingDelay(), function()
		client:SetAction();
	end, 96 );
end

function ENT:Think()
	self:SetRemainingCooldown( math.max( 0, self:GetRemainingCooldown() - 1 ) );
	self:NextThink( CurTime() + 1 );
	return true;
end
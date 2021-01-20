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
	self.FirstTime = true;
	self.Vars = {};
	self.Vars.LastUsedTime = CurTime() - PLUGIN:GetScavengingCooldown();
	self.Vars.Money = 0;
	self.Vars.InventoryID = 0;
	self.Vars.TableName = "error";
	self:SetDisplayName( "Default Display Name" );
	self:SetDisplayDescription( "Default Display Description" );
	self.Vars.Configured = false;
end

-- Variables:
function ENT:GetInventoryID()
	return self.Vars.InventoryID;
end

function ENT:SetInventoryID( number )
	self.Vars.InventoryID = number;
end

function ENT:GetMoney()
	return self.Vars.Money;
end

function ENT:SetMoney( number )
	self.Vars.Money = number;
end

function ENT:GetTableName()
	return self.Vars.TableName;
end

-- Spawning/Removal:
function ENT:SpawnFunction( client, trace )
	-- Positioning:
	local ent = ents.Create( "ix_scavengingpile" );
	ent:SetPos( trace.HitPos + Vector( 0, 0, 0 ) );
	ent:SetAngles( Angle( 0, ( ent:GetPos() - client:GetPos() ):Angle().y, 0 ) );
	ent:Spawn();
	ent:Activate();
	-- Saving:
	PLUGIN:SaveData();
	return ent;
end

function ENT:OnRemove()
	-- Checks:
	if( !PLUGIN:ShouldRemoveInventory( self:GetInventoryID() ) ) then return end;
	-- Inventory:
	PLUGIN:RemoveInventory( self:GetInventoryID() );
	-- Saving:
	PLUGIN:SaveData();
end

-- Inventory:
function ENT:GetInventory()
	-- Checks:
	if( !self:GetInventoryID() or self:GetInventoryID() == 0 ) then return end;
	-- Return:
	return ix.item.inventories[self:GetInventoryID()];
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

-- Main:
function ENT:Use( client )
	-- Setup:
	local ret = PLUGIN:ShouldSetup( self );
	if( ret ) then 
		if( ix.util.GetTypeFromValue( ret ) == ix.type.string ) then
			client:Notify( ret );
			return;
		end
		PLUGIN:Setup( self, client );
		return;
	end
	if( self.FirstTime ) then
		self.FirstTime = false;
		self.Vars.LastUsedTime = CurTime() - PLUGIN:GetScavengingCooldown();
	end
	-- Variables:
	local character = client:GetCharacter();
	local tabl = PLUGIN.Loot[self:GetTableName()];
	-- Checks:
	if( !character ) then return end;
	if( !tabl ) then return end;
	-- CanUse:
	if( !tabl["CanUse"] or tabl["CanUse"]( client, character, self ) == nil ) then
		local ret = PLUGIN:CanUse( client, character, self );
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
		ShouldScavenge = PLUGIN:CanScavenge( client, character, self );
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
	local message = tabl["Usage Message"]( client, character, self, ShouldScavenge );
	local amount = tabl["Amount of Spawned Items"]( client, character, self );
	local credit = tabl["Amount of Spawned Credits"]( character, character, entity );
	local items = tabl["Possible Items"]( character, character, self );
	-- Main:
	client:SetAction( message, PLUGIN:GetScavengingDelay() );
	client:DoStaredAction( self, function()
		if( ShouldScavenge ) then
			if( tabl["PerformScavenge"] ) then
				local ret = tabl["PerformScavenge"]( client, character, self, ShouldScavenge );
			else
				local ItemsToSpawn = {};
				local PossibleItems = {};
				-- Compiling:
				for _, info in pairs( items ) do
					local ItemID = info["ItemID"];
					local Data = info["Data"] or {};
					local Chance = info["Chance"] or 1;
					for i = 1, amount do
						local Next = table.Count( PossibleItems ) + 1;
						PossibleItems[Next] = {
							["ItemID"] = ItemID,
							["Data"] = Data,
							["Chance"] = Chance
						};
					end
				end
				-- Randomly Selecting:
				for i = 1, amount do
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
				-- Variables:
				self.Vars.LastUsedTime = CurTime();
			end
			if( credit and ix.util.GetTypeFromValue( credit ) == ix.type.number and math.max( 0, self:GetMoney() + credit ) != 0 ) then
				self:SetMoney( self:GetMoney() + credit );
			end
			-- Logging:
			ix.log.Add( client, "scavengingScavenging", self:GetInventoryID(), self:GetDisplayName() );
		end
		self:OpenInventory( client );
	end, PLUGIN:GetScavengingDelay(), function()
		client:SetAction();
	end, 96 );
end
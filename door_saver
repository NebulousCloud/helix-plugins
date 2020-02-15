
local PLUGIN = PLUGIN
PLUGIN.name = "DoorSaver"
PLUGIN.author = "Taxin2012"
PLUGIN.description = "Saves purchased by players doors."
PLUGIN.license = [[Copyright 2019 Taxin2012
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.]]

PLUGIN.DOORS_BUFFER = PLUGIN.DOORS_BUFFER or {}
PLUGIN.DOORS_ACCESS_BUFFER = PLUGIN.DOORS_ACCESS_BUFFER or {}
PLUGIN.DOORS_TITLES_BUFFER = PLUGIN.DOORS_TITLES_BUFFER or {}


if SERVER then
	local DOORS_PL = ix.plugin.Get( "doors" )

	if not DOORS_PL then
		ErrorNoHalt( "Error: No Doors plugin found!\n" )
		return
	end

	function PLUGIN:LoadData()
		local data = self:GetData() or {}
		if data then 
			self.DOORS_BUFFER = data.doors_buff or {}
			self.DOORS_ACCESS_BUFFER = data.doors_acc_buff or {}
			self.DOORS_TITLES_BUFFER = data.titles or {}

			for k, v in next, self.DOORS_BUFFER do
				local door = ents.GetMapCreatedEntity( k )
				if door and door:IsValid() and not door:GetNetVar( "disabled" ) then
					local name = self.DOORS_TITLES_BUFFER[ k ]
					if name then
						door:SetNetVar( "title", name )
					end

					door:SetNetVar( "ownable", nil )

					DOORS_PL:CallOnDoorChildren( door, function( child )
						child:SetNetVar( "ownable", nil )
					end )

					door:Fire( "Lock" )
				end
			end
		end
	end

	function PLUGIN:SaveDoors()
		local data = {
			doors_buff = self.DOORS_BUFFER,
			doors_acc_buff = self.DOORS_ACCESS_BUFFER,
			titles = self.DOORS_TITLES_BUFFER
		}
		self:SetData( data )
	end
	
	function PLUGIN:SaveData()
		self:SaveDoors()	
	end

	function PLUGIN:OnPlayerPurchaseDoor( ply, ent, isBuy )
		local char = ply:GetCharacter()
		if char then
			local door_id = ent:MapCreationID()
			if door_id then
				if isBuy then
					self.DOORS_BUFFER[ door_id ] = char:GetID()
				else
					self.DOORS_BUFFER[ door_id ] = nil
					self.DOORS_ACCESS_BUFFER[ door_id ] = nil
				end
			end
		end

		self:SaveDoors()
	end

	function PLUGIN:PrePlayerLoadedCharacter( ply, curChar, prevChar )
		if prevChar then
			local prevID = prevChar:GetID()
			for k, v in next, self.DOORS_BUFFER do
				if v == prevID then
					local door = ents.GetMapCreatedEntity( k )
					if door and door:IsValid() and not door:GetNetVar( "disabled" ) then
						self.DOORS_ACCESS_BUFFER[ k ] = door.ixAccess
						self.DOORS_TITLES_BUFFER[ k ] = door:GetNetVar( "title", door:GetNetVar( "name", "Purchased" ) )

						door:SetNetVar( "ownable", nil )

						DOORS_PL:CallOnDoorChildren( door, function( child )
							child:SetNetVar( "ownable", nil )
						end )
					end
				end
			end
		end

		local HaveDoor = false

		local curID = curChar:GetID()
		for k, v in next, self.DOORS_BUFFER do
			if v == curID then
				local door = ents.GetMapCreatedEntity( k )
				if door and door:IsValid() and not door:GetNetVar( "disabled" ) then
					door:SetNetVar( "ownable", true )

					door:SetDTEntity( 0, ply )
					
					if prevChar then
						local access = self.DOORS_ACCESS_BUFFER[ k ]

						if access then
							for k, v in next, access do
								if k and k:IsValid() and k:GetCharacter() then
									door.ixAccess[ k ] = v
								end
							end

							door.ixAccess[ ply ] = DOOR_OWNER
						end
					else
						door.ixAccess = {
							[ ply ] = DOOR_OWNER
						}
					end

					DOORS_PL:CallOnDoorChildren(door, function(child)
						child:SetNetVar( "ownable", true )

						child:SetDTEntity( 0, ply )
					end)

					local doors = curChar:GetVar( "doors" ) or {}
						doors[ #doors + 1 ] = door
					curChar:SetVar( "doors", doors, true )

					HaveDoor = true
				end
			end
		end

		if HaveDoor then
			self:SaveDoors()
		end
	end

	function PLUGIN:PlayerDisconnected( ply )
		local char = ply:GetCharacter()
		if char then
			local HaveDoor = false

			local charID = char:GetID()
			for k, v in next, self.DOORS_BUFFER do
				if v == charID then
					local door = ents.GetMapCreatedEntity( k )
					if door and door:IsValid() and not door:GetNetVar( "disabled" ) then
						self.DOORS_ACCESS_BUFFER[ k ] = door.ixAccess
						self.DOORS_TITLES_BUFFER[ k ] = door:GetNetVar( "title", door:GetNetVar( "name", "Purchased" ) )

						door:SetNetVar( "ownable", nil )

						DOORS_PL:CallOnDoorChildren( door, function( child )
							child:SetNetVar( "ownable", nil )
						end )

						HaveDoor = true
					end
				end
			end

			if HaveDoor then
				self:SaveDoors()
			end
		end
	end

	function PLUGIN:CharacterDeleted( ply, id )
		local HaveDoor = false

		for k, v in next, self.DOORS_BUFFER do
			if v == id then
				local door = ents.GetMapCreatedEntity( k )
				if door and door:IsValid() and not door:GetNetVar( "disabled" ) then
					self.DOORS_BUFFER[ k ] = nil
					self.DOORS_ACCESS_BUFFER[ k ] = nil
					self.DOORS_TITLES_BUFFER[ k ] = nil
					door:RemoveDoorAccessData()

					HaveDoor = true
				end
			end
		end

		if HaveDoor then
			self:SaveDoors()
		end
	end
end

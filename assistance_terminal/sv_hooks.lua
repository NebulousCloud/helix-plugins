
function PLUGIN:SaveData( )
	local data = { }

	for _, v in ipairs( ents.FindByClass( "ix_assistance_terminal" ) ) do
		data[#data + 1] = {
			v:GetPos( ),
			v:GetAngles( )
		}
	end

	ix.data.Set( "assistanceTerminals", data )
end

function PLUGIN:LoadData( )
	for _, v in ipairs( ix.data.Get( "assistanceTerminals" ) or {} ) do
		local entity = ents.Create( "ix_assistance_terminal" )

		entity:SetPos( v[1] )
		entity:SetAngles( v[2] )
		entity:Spawn( )

		local physicsObject = entity:GetPhysicsObject( )
		
		if ( IsValid( physicsObject ) ) then
			physicsObject:EnableMotion( false )
		end
	end
end

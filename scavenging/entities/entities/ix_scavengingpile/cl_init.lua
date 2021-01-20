include( "shared.lua" );

ENT.PopulateEntityInfo = true;

function ENT:OnPopulateEntityInfo( tooltip )
    -- If you're seriously putting this as your entity displays, then what did you expect?
    if( self:GetDisplayName() == "Default Display Name" and self:GetDisplayDescription() == "Default Display Description" ) then return end;

    local title = tooltip:AddRow( "name" );
    title:SetImportant();
    title:SetText( self:GetDisplayName() );
    title:SetBackgroundColor( ix.config.Get( "color" ) );
    title:SizeToContents();

    local description = tooltip:AddRow( "description" );
    description:SetText( self:GetDisplayDescription() );
    description:SizeToContents();
end
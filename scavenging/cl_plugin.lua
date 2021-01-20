local PLUGIN = PLUGIN;

-- Context Menu:
net.Receive( "ixScavengingSetup", function()
    PLUGIN.Panel = vgui.Create( "ixScavengingSetup" );
    PLUGIN.Panel:Setup( net.ReadEntity(), net.ReadTable() );
end)

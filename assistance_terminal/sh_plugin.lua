
PLUGIN.name = "Assistance Terminals"
PLUGIN.description = "Adds assistance terminals that citizens can use to request Combine officers to their location."
PLUGIN.author = "VictorK"

ix.util.Include( "cl_plugin.lua" )
ix.util.Include( "sv_hooks.lua" )

function PLUGIN:InitializedChatClasses( )
    local CLASS = { }
    CLASS.format = "Incoming Assistance Terminal request: #%s | %s"

    function CLASS:CanHear( speaker, listener )
        return listener:IsCombine( )
    end

    function CLASS:OnChatAdd( speaker, text, bAnonymous, data )
        chat.AddText( Color( 175, 125, 100 ), string.format( self.format, text, data[1] ) )
    end

    ix.chat.Register( "terminal_request", CLASS )
end

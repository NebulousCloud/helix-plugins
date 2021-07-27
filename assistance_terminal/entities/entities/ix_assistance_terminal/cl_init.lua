
include( "shared.lua" )

local noise = Material( "overlays/camcorder_noise" )
local overlay = Material( "effects/combine_binocoverlay" )

function ENT:Think( )
    if ( self:GetNetVar( "alarmLights" ) ) then
        local dynamicLight = DynamicLight( self:EntIndex( ) )

        if (dynamicLight) then
            dynamicLight.pos = self:GetPos( ) + self:GetForward( ) * 50

            dynamicLight.r = 200
            dynamicLight.g = 0
            dynamicLight.b = 0

            dynamicLight.brightness = 1
            dynamicLight.Decay = 900
            dynamicLight.DieTime = CurTime( )
            dynamicLight.Size = 750
        end
    end
end

local combineLogoParts = { 
    { 
        { x = 200, y = 77.5 },
        { x = 370, y = 164.5 },
        { x = 278, y = 160 }
    },
    { 
        { x = 126, y = 151.5 },
        { x = 205.3, y = 230 },
        { x = 212, y = 322.6 }
    },
    { 
        { x = 200, y = 293 },
        { x = 370, y = 293 },
        { x = 370, y = 322.6 },
        { x = 212, y = 322.6 }
    },
    { 
        { x = 338, y = 162 },
        { x = 370, y = 164.5 },
        { x = 370, y = 300 },
        { x = 338, y = 300 }
    },
    { 
        { x = 200, y = 77.5 },
        { x = 282, y = 164 },
        { x = 235, y = 175 },
        { x = 207, y = 232 },
        { x = 126, y = 151.5 }
    }
}

-- Helper function from the wiki.
local function draw_Circle( x, y, radius, seg )
    local cir = {  }

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

function ENT:Draw( )
    self:DrawModel( )
    
    if ( LocalPlayer( ):GetPos( ):Distance( self:GetPos( ) ) > 1000 ) then return end
    
    local area = LocalPlayer( ):GetArea( )

    if ( !area or area == "" ) then
        area = "Unknown Location"
    end

    local angle = self:GetAngles( )
    angle:RotateAroundAxis( angle:Right( ), -90 )
    angle:RotateAroundAxis( angle:Up( ), 90 )

    cam.Start3D2D( self:GetPos( ) + self:GetForward( ) * 13 + self:GetRight( ) * 8.5 + self:GetUp( ) * 20, angle, 0.0364 )

        surface.SetDrawColor( 50, 50, 50, 255 )
        surface.DrawRect( 0, 0, 496, 502 )

        surface.SetDrawColor( 0, 0, 255, 75 )
        surface.DrawRect( 0, 0, 496, 40 )

        draw.SimpleText( "ASSISTANCE TERMINAL", "terminal_title", 248, 20, Color( 255, 255, 225, 50 + math.abs( math.sin( CurTime( ) ) ) * 300 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        surface.SetDrawColor( 44, 44, 44, 255 )
        
        surface.SetDrawColor( 0, 0, 0, 200 )
        surface.DrawRect( 0, 452, 496, 50 )
        draw.SimpleText( area, "terminal_location", 248, 477, Color( 255, 255, 225, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        
        if ( self:GetNetVar( "alarm" ) ) then
            surface.SetDrawColor( 255, 0, 0, 255 )
            surface.DrawRect( 0, 80, 496, 120 )
            draw.SimpleText( "OFFICERS HAVE BEEN DISPATCHED", "terminal_requestText", 248, 105, Color( 0, 25, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( "REQUESTER: #" .. self:GetNetVar( "requester", 0 ), "terminal_requestText", 248, 140, Color( 255, 255, 0, 50 + math.abs( math.sin( CurTime( ) ) ) * 300 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( "REMAIN IN PLACE", "terminal_requestText", 248, 175, Color( 255, 255, 0, 50 + math.abs( math.sin( CurTime( ) ) ) * 300 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
            -- Combine Logo. If you want to put a non-solid color background here, you need to change the logo to a material.
            surface.SetDrawColor( 176, 124, 32, 255 )
            draw.NoTexture( )
            surface.DrawPoly( combineLogoParts[1] )
            surface.DrawPoly( combineLogoParts[2] )
            surface.DrawPoly( combineLogoParts[3] )
            surface.DrawPoly( combineLogoParts[4] )
            
            draw_Circle( 271.5, 227.3, 94, 100 )
            
            surface.SetDrawColor( 50, 50, 50, 255 )
            draw_Circle( 271.5, 227.3, 65, 100 )
            
            surface.SetDrawColor( 176, 124, 32, 255 )
            draw_Circle( 271.5, 227.3, 52, 100 )
            
            surface.SetDrawColor( 50, 50, 50, 255 )
            surface.DrawPoly( combineLogoParts[5] )

            draw.SimpleText( "INSERT ID CARD TO", "terminal_infoText", 248, 375, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            draw.SimpleText( "REQUEST ASSISTANCE", "terminal_infoText", 248, 405, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( noise )
        surface.DrawTexturedRect( 0, 0, 496, 502 )
        
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.SetMaterial( overlay )
        surface.DrawTexturedRect( 0, 0, 496, 502 )
    cam.End3D2D( )
end

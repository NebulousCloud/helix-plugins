local PLUGIN = PLUGIN

local classes = {
   ["func_door"] = true,
   ["prop_door_rotating"] = true
}

local function DrawDoorAccess(ply)
    
    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 150)) do
        for a, b in pairs(PLUGIN.doors) do
            if ( game.GetMap() == a ) then
                for stuff, stuff2 in pairs(b) do
                    if ( classes[v:GetClass()] ) and ( tostring(stuff2.id) == v:MapCreationID() ) then
                        local pos = v.LocalToWorld(v, v:OBBCenter()):ToScreen()

                        draw.DrawText(stuff2.name, "BudgetLabel", pos.x, pos.y, ColorAlpha(color_white, 255), TEXT_ALIGN_CENTER)

                        if ( stuff2.access ) then
                            for c, d in pairs(PLUGIN.access) do
                                if ( stuff2.access == c ) then
                                    draw.DrawText(d.name, "BudgetLabel", pos.x, pos.y - 30, ColorAlpha(d["color"], 255), TEXT_ALIGN_CENTER)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function PLUGIN:HUDPaint()
   local ply = LocalPlayer()
   local char = ply:GetCharacter()

   if not ( ply or char ) then return end
   
   if not ( ply:IsCombine() ) then return end

   DrawDoorAccess(ply)
end
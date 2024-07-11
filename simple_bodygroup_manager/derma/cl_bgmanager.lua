local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() * 0.5, ScrH() * 0.6)
    self:Center()
    self:SetTitle("")
    self:SetDraggable(true)
    self:MakePopup()

    self.Paint = function(_, w, h)
        draw.RoundedBox(15,0,0,w,h, ix.config.Get("colorFondoBGManager"))
    end
end

function PANEL:Fill(target)
    local client = target or LocalPlayer()

    local headerTitle = self:Add("DLabel")
    headerTitle:SetColor(ix.config.Get("colorEnfasisBGManager"))
    headerTitle:Dock(TOP)
    headerTitle:DockMargin(10,0,0,25)
    headerTitle:SetFont("ixBigFont")
    headerTitle:SetText("Simple Bodygroup Manager: " .. client:Name())
    headerTitle:SetContentAlignment(5)
    headerTitle:SizeToContents()

    local displayCharacter = self:Add("DAdjustableModelPanel")
    displayCharacter:Dock(LEFT)
    displayCharacter:SetSize(ScrW() * 0.25 , ScrH() * 0.6)
    displayCharacter:SetModel(client:GetModel())
    displayCharacter.LayoutEntity = function(ent) return end
    displayCharacter:SetFOV(50)

    displayCharacter.Entity:SetSkin(client:GetSkin())

    local colorJugador = client:GetPlayerColor()
    displayCharacter.Entity.GetPlayerColor = function() return colorJugador end

    for i = 0, client:GetNumBodyGroups() - 1 do
        displayCharacter:GetEntity():SetBodygroup(i, client:GetBodygroup(i))
    end

    displayCharacter.Entity:SetAngles(Angle(0, 180, 0))
    displayCharacter:SetDirectionalLight(BOX_BACK, color_white)

    -- Forzamos un click izquierdo en el panel para que se muestre el modelo desde un inicio
    displayCharacter:OnMousePressed(MOUSE_LEFT)
    timer.Simple(0.1, function()
        displayCharacter:OnMouseReleased(MOUSE_LEFT)
    end)

    local contenedorBg = self:Add("DScrollPanel")
    contenedorBg:SetWide(self:GetWide() * 0.25)
    contenedorBg:Dock(FILL)

    local barraContenedor = contenedorBg:GetVBar()
    barraContenedor.btnGrip.Paint = function(_, w, h)
        draw.RoundedBox(30,0,0,w * 0.2,h,ix.config.Get("colorEnfasisBGManager"))
    end
    contenedorBg.Paint = function(_, w, h)
        draw.RoundedBox(15,0,0,w,h,Color(49, 49, 49, 100))
    end


    local skinLabel = contenedorBg:Add("ixLabel")
    skinLabel:Dock(TOP)
    skinLabel:DockMargin(10, 10, 0, 5)
    skinLabel:SetFont("ixMediumFont")
    skinLabel:SetText("Skin")
    skinLabel:SetTextColor(ix.config.Get("colorEnfasisBGManager"))
    skinLabel:SetContentAlignment(7)

    local skinSlider = contenedorBg:Add("DNumSlider")
    skinSlider:Dock(TOP)
    skinSlider:SetContentAlignment(7)
    skinSlider:DockMargin(10, 10, 0, 5)
    skinSlider:SetMin(0)
    skinSlider:SetMax(client:SkinCount())
    skinSlider:SetDecimals(0)
    skinSlider.OnValueChanged = function(_, val)
        displayCharacter.Entity:SetSkin(val)
    end

    for _, subPanel in ipairs(skinSlider:GetChildren()) do
        if (subPanel:GetName() != "DLabel") then continue end
        subPanel:ToggleVisible()
    end

    for _, bgData in ipairs(client:GetBodyGroups()) do
        if (#bgData.submodels < 1) then continue end
        local nombreBodygroup = contenedorBg:Add("ixLabel")
        nombreBodygroup:Dock(TOP)
        nombreBodygroup:DockMargin(10, 10, 0, 5)
        nombreBodygroup:SetFont("ixMediumFont")
        nombreBodygroup:SetText(bgData.name)
        nombreBodygroup:SetTextColor(ix.config.Get("colorEnfasisBGManager"))
        nombreBodygroup:SetContentAlignment(7)

        local bgBarra = contenedorBg:Add("DNumSlider")
        bgBarra:Dock(TOP)
        bgBarra:SetContentAlignment(7)
        bgBarra:DockMargin(10, 10, 0, 5)
        bgBarra:SetMin()
        bgBarra:SetMax(bgData.num - 1)
        bgBarra:SetDecimals(0)

        -- Para cada barra, ponemos default el valor que tiene actualmente el jugador
        bgBarra:SetValue(client:GetBodygroup(bgData.id))

        -- Ocultamos el título y scratch de la barra deslizadora
        for _, subPanel in ipairs(bgBarra:GetChildren()) do
            if (subPanel:GetName() != "DLabel") then continue end
            subPanel:SetVisible(false)
        end

        -- 
        bgBarra.OnValueChanged = function(_, val)
            displayCharacter.Entity:SetBodygroup(bgData.id, val)
        end
    end



    local buttonContainer = self:Add("DPanel")
    buttonContainer:Dock(BOTTOM)
    buttonContainer:DockMargin(0, 10, 0, 10)
    buttonContainer.Paint = function() return end

    local button = buttonContainer:Add("DButton")
    button:Dock(FILL)
    button:SetText("Save")
    button:SetFont("ixMediumFont")
    button:SetContentAlignment(5)
    button:SizeToContents()

    button.Paint = function(_, w, h)
        draw.RoundedBox(5,0,0,w,h, ix.config.Get("saveButtonColor"))
    end

    button.DoClick = function()
        local tblBodygroups = {}
        for i = 0, displayCharacter.Entity:GetNumBodyGroups() - 1 do
            tblBodygroups[i] = displayCharacter.Entity:GetBodygroup(i)
        end

        net.Start("SBMSaveBodygroups")
            net.WritePlayer(target)
            net.WriteTable(tblBodygroups)
        net.SendToServer()

        if (LocalPlayer() == client) then
            LocalPlayer():NotifyLocalized("selfBodygroupsModified")
        else
            LocalPlayer():NotifyLocalized("userBodygroupsModified", client:Name())
        end

        self:Remove()
    end
end


vgui.Register("ixCambiadorBodygroups", PANEL, "DFrame")
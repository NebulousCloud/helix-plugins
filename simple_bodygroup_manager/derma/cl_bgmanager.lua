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

    self.headerTitle = self:Add("DLabel")
    self.headerTitle:SetColor(ix.config.Get("colorEnfasisBGManager"))
    self.headerTitle:Dock(TOP)
    self.headerTitle:DockMargin(10,0,0,25)
    self.headerTitle:SetFont("ixBigFont")
    self.headerTitle:SetText("Modifying the bodygroups of: " .. client:Name())
    self.headerTitle:SetContentAlignment(5)
    self.headerTitle:SizeToContents()

    self.displayCharacter = self:Add("DAdjustableModelPanel")
    self.displayCharacter:Dock(LEFT)
    self.displayCharacter:SetSize(ScrW() * 0.25 , ScrH() * 0.6)
    self.displayCharacter:SetModel(client:GetModel())
    self.displayCharacter.LayoutEntity = function(ent) return end
    self.displayCharacter:SetFOV(50)

    self.displayCharacter.Entity:SetSkin(client:GetSkin())

    local colorJugador = client:GetPlayerColor()
    self.displayCharacter.Entity.GetPlayerColor = function() return colorJugador end

    for i = 0, client:GetNumBodyGroups() - 1 do
        self.displayCharacter:GetEntity():SetBodygroup(i, client:GetBodygroup(i))
    end

    self.displayCharacter.Entity:SetAngles(Angle(0, 180, 0))
    self.displayCharacter:SetDirectionalLight(BOX_BACK, color_white)

    -- Forzamos un click izquierdo en el panel para que se muestre el modelo desde un inicio
    self.displayCharacter:OnMousePressed(MOUSE_LEFT)
    timer.Simple(0.1, function()
        self.displayCharacter:OnMouseReleased(MOUSE_LEFT)
    end)

    self.contenedorBg = self:Add("DScrollPanel")
    self.contenedorBg:SetWide(self:GetWide() * 0.25)
    self.contenedorBg:Dock(FILL)

    self.barraContenedor = self.contenedorBg:GetVBar()
    self.barraContenedor.btnGrip.Paint = function(_, w, h)
        draw.RoundedBox(30,0,0,w * 0.2,h,ix.config.Get("colorEnfasisBGManager"))
    end
    self.contenedorBg.Paint = function(_, w, h)
        draw.RoundedBox(15,0,0,w,h,Color(49, 49, 49, 100))
    end


    self.skinLabel = self.contenedorBg:Add("ixLabel")
    self.skinLabel:Dock(TOP)
    self.skinLabel:DockMargin(10, 10, 0, 5)
    self.skinLabel:SetFont("ixMediumFont")
    self.skinLabel:SetText("Skin")
    self.skinLabel:SetTextColor(ix.config.Get("colorEnfasisBGManager"))
    self.skinLabel:SetContentAlignment(7)

    self.skinSlider = self.contenedorBg:Add("DNumSlider")
    self.skinSlider:Dock(TOP)
    self.skinSlider:SetContentAlignment(7)
    self.skinSlider:DockMargin(10, 10, 0, 5)
    self.skinSlider:SetMin(0)
    self.skinSlider:SetMax(client:SkinCount())
    self.skinSlider:SetValue(client:GetSkin())
    self.skinSlider:SetDecimals(0)
    self.skinSlider.OnValueChanged = function(_, val)
        self.displayCharacter.Entity:SetSkin(val)
    end

    for _, subPanel in ipairs(self.skinSlider:GetChildren()) do
        if (subPanel:GetName() != "DLabel") then continue end
        subPanel:ToggleVisible()
    end

    for _, bgData in ipairs(client:GetBodyGroups()) do
        if (#bgData.submodels < 1) then continue end
        local nombreBodygroup = self.contenedorBg:Add("ixLabel")
        nombreBodygroup:Dock(TOP)
        nombreBodygroup:DockMargin(10, 10, 0, 5)
        nombreBodygroup:SetFont("ixMediumFont")
        nombreBodygroup:SetText(bgData.name)
        nombreBodygroup:SetTextColor(ix.config.Get("colorEnfasisBGManager"))
        nombreBodygroup:SetContentAlignment(7)

        local bgBarra = self.contenedorBg:Add("DNumSlider")
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

        -- Realtime update of the bodygroups in the preview
        bgBarra.OnValueChanged = function(_, val)
            self.displayCharacter.Entity:SetBodygroup(bgData.id, val)
        end
    end



    self.buttonContainer = self:Add("DPanel")
    self.buttonContainer:Dock(BOTTOM)
    self.buttonContainer:DockMargin(0, 10, 0, 10)
    self.buttonContainer.Paint = function() return end

    self.button = self.buttonContainer:Add("DButton")
    self.button:Dock(FILL)
    self.button:SetText("Save")
    self.button:SetFont("ixMediumFont")
    self.button:SetContentAlignment(5)
    self.button:SizeToContents()

    self.button.Paint = function(_, w, h)
        draw.RoundedBox(5,0,0,w,h, ix.config.Get("saveButtonColor"))
    end

    self.button.DoClick = function()
        local tblBodygroups = {}
        for i = 0, self.displayCharacter.Entity:GetNumBodyGroups() - 1 do
            tblBodygroups[i] = self.displayCharacter.Entity:GetBodygroup(i)
        end

        net.Start("SBMSaveBodygroups")
            net.WritePlayer(target)
            net.WriteTable(tblBodygroups)
            net.WriteUInt(self.displayCharacter.Entity:GetSkin(), 5)
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
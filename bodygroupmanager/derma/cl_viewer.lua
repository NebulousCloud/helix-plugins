local PLUGIN = PLUGIN or {}

local PANEL = {}

function PANEL:Init()
    --self:SetText("Bodygroup Manager")
    self:SetSize(720, 720)
    self:Center()
    self:SetBackgroundBlur(true)
    self:SetDeleteOnClose(true)

    self:MakePopup()
    self:SetTitle("Bodygroup Manager")

    self.clipboard = self:Add("DButton")
	self.clipboard:Dock(BOTTOM)
	self.clipboard:DockMargin(0, 4, 0, 0)
    self.clipboard:SetText("Save Changes")
    self.clipboard.DoClick = function()
        local bodygroups = {}
        for _, v in pairs(self.bodygroupIndex) do
            table.insert(bodygroups, v.index, v.value)
        end
        netstream.Start("ixBodygroupTableSet", self.target, bodygroups)
    end

    self.model = self:Add("DModelPanel")
    self.model.rotating = true
    self.model:SetSize(700, 700)
    self.model:SetPos(-200, 0)
    self.model:SetModel(Model("models/props_junk/watermelon01.mdl"))

    self.bodygroups = {}

    function self.model:LayoutEntity(Entity)
        Entity:SetAngles(Angle(0,45,0))
        local sequence = Entity:SelectWeightedSequence(ACT_IDLE)

        if (sequence <= 0) then
            sequence = Entity:LookupSequence("idle_unarmed")
        end

        if (sequence > 0) then
            Entity:ResetSequence(sequence)
        else
            local found = false

            for _, v in ipairs(Entity:GetSequenceList()) do
                if ((v:lower():find("idle") or v:lower():find("fly")) and v != "idlenoise") then
                    Entity:ResetSequence(v)
                    found = true

                    break
                end
            end

            if (!found) then
                Entity:ResetSequence(4)
            end
        end

    end

    PLUGIN.viewer = self

end

function PANEL:SetTarget(target)
    self.target = target
    self:PopulateBodygroupOptions()
    self:SetTitle(target.player:Name())
end

function PANEL:PopulateBodygroupOptions()
    self.bodygroupBox = {}
    self.bodygroupName = {}
    self.bodygroupPrevious = {}
    self.bodygroupNext = {}
    self.bodygroupIndex = {}

    for k, v in pairs(self.target.player:GetBodyGroups()) do
        if !(v.id == 0) then
            local index = v.id

            self.bodygroupBox[v.id] = self:Add("DPanel")
            self.bodygroupBox[v.id]:SetPos(325, (75*index) + 25)
            self.bodygroupBox[v.id]:SetSize(375, 50)

            -- Disregard the model bodygroup.
            self.bodygroupName[v.id] = self:Add("DLabel")
            self.bodygroupName[v.id].index = v.id
            self.bodygroupName[v.id]:SetText(v.name)
            self.bodygroupName[v.id]:SetColor(Color(255,255,255))
            self.bodygroupName[v.id]:SetFont("ixMediumFont")
            self.bodygroupName[v.id]:SetPos(350, (75*index))
            self.bodygroupName[v.id]:SetSize(400, 100)

            self.bodygroupPrevious[v.id] = self:Add("DButton")
            self.bodygroupPrevious[v.id].index = v.id
            self.bodygroupPrevious[v.id]:SetPos(450, (75*index) + 35)
            self.bodygroupPrevious[v.id]:SetSize(75, 30)
            self.bodygroupPrevious[v.id]:SetText("Previous")
            self.bodygroupPrevious[v.id].DoClick = function()
                local index = v.id
                if 0 == self.bodygroupIndex[index].value then
                    return
                end
                self.bodygroupIndex[index].value = self.bodygroupIndex[index].value - 1
                self.bodygroupIndex[index]:SetText(self.bodygroupIndex[index].value)
                self.model.Entity:SetBodygroup(index, self.bodygroupIndex[index].value)

            end


            self.bodygroupNext[v.id] = self:Add("DButton")
            self.bodygroupNext[v.id].index = v.id
            self.bodygroupNext[v.id]:SetPos(590, (75*index) + 35)
            self.bodygroupNext[v.id]:SetSize(75, 30)
            self.bodygroupNext[v.id]:SetText("Next")
            self.bodygroupNext[v.id].DoClick = function()
                local index = v.id
                if (self.model.Entity:GetBodygroupCount(index) - 1) <= self.bodygroupIndex[index].value then
                    return
                end
                
                self.bodygroupIndex[index].value = self.bodygroupIndex[index].value + 1
                self.bodygroupIndex[index]:SetText(self.bodygroupIndex[index].value)
                self.model.Entity:SetBodygroup(index, self.bodygroupIndex[index].value)
            end

            self.bodygroupIndex[v.id] = self:Add("DLabel")
            self.bodygroupIndex[v.id].index = v.id
            self.bodygroupIndex[v.id].value = self.target.player:GetBodygroup(index)
            self.bodygroupIndex[v.id]:SetText(self.bodygroupIndex[v.id].value)
            self.bodygroupIndex[v.id]:SetFont("ixMediumFont")
            self.bodygroupIndex[v.id]:SetColor(Color(255,255,255))
            self.bodygroupIndex[v.id]:SetPos(550, (75*index))
            self.bodygroupIndex[v.id]:SetSize(100, 100)

            self.model.Entity:SetBodygroup(index, self.target.player:GetBodygroup(index))
        end
    end
end

function PANEL:SetViewModel(model)
    self.playerModel = model
    if model then
        self.model:SetModel(Model(model))
    end
end

vgui.Register("ixBodygroupView", PANEL, "DFrame")

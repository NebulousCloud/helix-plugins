PLUGIN.name = "Container Spawn Menu"
PLUGIN.description = "Adds a spawn menu to spawn containers."
PLUGIN.author = "wildflowericecoffee"
PLUGIN.readme = [[
This plugin adds a spawn menu for all the helix containers.
To open it, type `/ContainerSpawnMenu` ingame.
]]
PLUGIN.license = [[
Copyright 2021 wildflowericecoffee
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

if SERVER then
    util.AddNetworkString("ixContainerMenu")
    util.AddNetworkString("ixContainerMenuCallback")

    net.Receive("ixContainerMenuCallback", function(_, client)
        local model = net.ReadString()

        if hook.Run("PlayerSpawnProp", client, model) == false then return end

        local entity = ents.Create("prop_physics")
        entity:SetModel(model)
        entity:SetPos(client:GetItemDropPos(entity))

        hook.Run("PlayerSpawnedProp", client, model, entity)
    end)
else
    net.Receive("ixContainerMenu", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Select a container")
        frame:SetSize(ScrW() * 0.75, ScrH() * 0.75)
        frame:Center()
        frame:MakePopup()

        local scroll = frame:Add("DScrollPanel")
        scroll:Dock(FILL)

        local layout = scroll:Add("DIconLayout")
        layout:Dock(FILL)

        for model, data in pairs(ix.container.stored) do
            local icon = layout:Add("DModelPanel")
            icon:SetSize(250, 250)
            icon:SetModel(model)

            local label = icon:Add("DLabel")
            label:Dock(FILL)
            label:SetContentAlignment(2)
            label:SetFont("ixNoticeFont")
            label:SetText(("%s (%dx%d)"):format(data.name, data.width, data.height))

            icon.DoClick = function()
                net.Start("ixContainerMenuCallback")
                    net.WriteString(model)
                net.SendToServer()
            end
        end
    end)
end

ix.command.Add("ContainerSpawnMenu", {
    adminOnly = true,
    OnRun = function(self, client)
        if not ix.plugin.Get("containers") then
            return "The container plugin is disabled or not installed!"
        end

        net.Start("ixContainerMenu")
        net.Send(client)
    end
})

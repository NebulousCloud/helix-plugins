local PLUGIN = PLUGIN

PLUGIN.name = "T-Pose Fixer"
PLUGIN.author = "DoopieWop"
PLUGIN.description = "Attempts to fix T-Posing for models."
PLUGIN.license = [[
MIT License

Copyright (c) 2025 DoopieWop

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
PLUGIN.cached = PLUGIN.cached or {}

local translations = {
    male_shared = "citizen_male",
    female_shared = "citizen_female",
    police_animations = "metrocop",
    combine_soldier_anims = "overwatch",
    vortigaunt_anims = "vortigaunt",
    m_anm = "player",
    f_anm = "player",
}

local og = ix.anim.SetModelClass
function ix.anim.SetModelClass(model, class)
    if (!ix.anim[class]) then return end

    PLUGIN.cached[model:lower()] = class

    og(model, class)
end

local function UpdateAnimationTable(client)
	local baseTable = ix.anim[client.ixAnimModelClass] or {}
	
    client.ixAnimTable = baseTable[client.ixAnimHoldType]
	client.ixAnimGlide = baseTable["glide"]
end

function PLUGIN:PlayerModelChanged(ply, model)
    timer.Simple(0, function()
        if not IsValid(ply) then
            return
        end

        model = model:lower()

        if not self.cached[model] then
            local submodels = ply:GetSubModels()
            for k, v in ipairs(submodels) do
                local class = v.name:gsub(".*/([^/]+)%.%w+$", "%1"):lower()
                if translations[class] then
                    ix.anim.SetModelClass(model, translations[class])
                    break
                end
            end
        end
        
        ply.ixAnimModelClass = ix.anim.GetModelClass(model)

    	UpdateAnimationTable(ply)
    end)

    return true
end

function PLUGIN:OnReloaded()
    for k, v in pairs(self.cached) do
        ix.anim.SetModelClass(k, v)
    end
end

if SERVER then
    util.AddNetworkString("TPoseFixerSync")

    function PLUGIN:PlayerInitialSpawn(client)
        net.Start("TPoseFixerSync")
            net.WriteTable(self.cached)
        net.Send(client)
    end
else
    net.Receive("TPoseFixerSync", function()
        for k, v in pairs(net.ReadTable()) do
            ix.anim.SetModelClass(k, v)
        end
    end)
end

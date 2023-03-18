local PLUGIN = PLUGIN

PLUGIN.name = "T-Pose Fixer"
PLUGIN.author = "DoopieWop"
PLUGIN.description = "Attempts to fix T-Posing for models."
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

    PLUGIN.cached[model] = class

    og(model, class)
end

if SERVER then
    util.AddNetworkString("TPoseFixerUpdate")
    util.AddNetworkString("TPoseFixerSync")

    local PMETA = FindMetaTable("Player")
    local EMETA = FindMetaTable("Entity")
    
    function PMETA:SetModel(model)
        EMETA.SetModel(self, model)

        if not PLUGIN.cached[model] then
            local submodels = self:GetSubModels()
            for k, v in pairs(submodels) do
                local class = v.name:gsub(".*/([^/]+)%.%w+$", "%1"):lower()
                if translations[class] then
                    ix.anim.SetModelClass(model, translations[class])

                    net.Start("TPoseFixerUpdate")
                        net.WriteString(model)
                        net.WriteString(translations[class])
                    net.Broadcast()

                    break
                end
            end
        end
    end

    function PLUGIN:PlayerInitialSpawn(client)
        net.Start("TPoseFixerSync")
            net.WriteTable(PLUGIN.cached)
        net.Send(client)
    end
else
    net.Receive("TPoseFixerUpdate", function()
        local model = net.ReadString()
        local class = net.ReadString()

        ix.anim.SetModelClass(model, class)
    end)

    net.Receive("TPoseFixerSync", function()
        for k, v in pairs(net.ReadTable()) do
            ix.anim.SetModelClass(k, v)
        end
    end)
end

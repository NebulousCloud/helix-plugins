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

local function UpdateAnimationTable(client)
	local baseTable = ix.anim[client.ixAnimModelClass] or {}
	
    client.ixAnimTable = baseTable[client.ixAnimHoldType]
	client.ixAnimGlide = baseTable["glide"]
end

function PLUGIN:PlayerModelChanged(ply, model)
    if not IsValid(ply) then return end

    -- timer since the model is not set yet
    timer.Simple(0, function()
        if not IsValid(ply) then return end

        if not self.cached[model] then
            local submodels = ply:GetSubModels()
            for k, v in pairs(submodels) do
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

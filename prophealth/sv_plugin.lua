local PLUGIN = PLUGIN

-- Helper function: Initializes HP and returns the value
-- Returns: maxHP (number)
local function InitPropHealth(entity)
    local minHP = ix.config.Get("propsMinHP", 50)
    local multiplier = ix.config.Get("propsHPMultiplier", 5)
    local phys = entity:GetPhysicsObject()
    
    local hp = minHP

    if (IsValid(phys)) then
        hp = math.max(minHP, phys:GetMass() * multiplier)
    end
    
    -- Sync both Max and Current HP
    entity:SetNetVar("propMaxHP", hp)
    entity:SetNetVar("propHP", hp)

    return hp
end

function PLUGIN:EntityTakeDamage(entity, dmgInfo)
    -- Filter: Only physics props, ignore map props
    if (entity:GetClass() ~= "prop_physics") then return end
    if (entity:CreatedByMap()) then return end

    -- Fetch current state
    local curHP = entity:GetNetVar("propHP")
    local maxHP = entity:GetNetVar("propMaxHP")

    -- Lazy Initialization (if prop spawned before plugin was added or bug)
    if (not curHP) then
        maxHP = InitPropHealth(entity)
        curHP = maxHP
    end

    -- Calculate Damage
    curHP = curHP - dmgInfo:GetDamage()

    -- State Handling
    if (curHP <= 0) then
        -- Destruction
        if (ix.config.Get("propsExplode", false)) then
            local effectData = EffectData()
            effectData:SetOrigin(entity:GetPos())
            util.Effect("Explosion", effectData)
        end
        
        entity:Remove()
    else
        -- Apply Health Update
        entity:SetNetVar("propHP", curHP)
    end
end

-- Optimization: Pre-calculate HP on spawn to avoid overhead during combat
function PLUGIN:PlayerSpawnedProp(client, model, entity)
    InitPropHealth(entity)
end
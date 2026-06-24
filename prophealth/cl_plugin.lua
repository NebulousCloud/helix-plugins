local PLUGIN = PLUGIN

local math_floor = math.floor
local math_max = math.max

local function PropHealthThink(row)
    local entity = row.ixEntity
    local tooltip = row.ixTooltip

    if (not IsValid(entity)) then return end

    -- Fetch vars
    local hp = math_max(0, entity:GetNetVar("propHP", 0))
    local maxHP = entity:GetNetVar("propMaxHP", 100)

    if (row.ixLastHP == hp and row.ixLastMax == maxHP) then return end

    -- Update cache
    row.ixLastHP = hp
    row.ixLastMax = maxHP

    -- Update UI
    local text = L("propHealth") .. ": " .. math_floor(hp) .. " / " .. math_floor(maxHP)
    row:SetText(text)
    row:SizeToContents()
    
    if (tooltip) then tooltip:SizeToContents() end
end

function PLUGIN:PopulateEntityInfo(entity, tooltip)
    -- Check class string first (fastest check)
    if (entity:GetClass() ~= "prop_physics") then return end
    
    -- Check NetVar existence
    if (not entity:GetNetVar("propHP")) then return end

    local row = tooltip:AddRow("health")
    row:SetBackgroundColor(Color(200, 50, 50))

    -- Store references on the panel object itself
    row.ixEntity = entity
    row.ixTooltip = tooltip
    
    -- Initialize cache variables
    row.ixLastHP = -1 
    row.ixLastMax = -1

    -- Assign the static Think function (Zero allocation)
    row.Think = PropHealthThink
    PropHealthThink(row)
end
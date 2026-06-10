local PLUGIN = PLUGIN
local charMeta = ix.meta.character

local cachedDamage
local cachedCauseDeath
local cachedMinHealth
local cachedNourishmentLoss
local cachedThirstLoss
local cachedEnabled

local function RefreshConfigCache()
    cachedDamage = ix.config.Get("hungerAndThirstDamage", 2)
    cachedCauseDeath = ix.config.Get("causeDeath", false)
    cachedMinHealth = ix.config.Get("hungerAndThirstMinHealth", 10)
    cachedNourishmentLoss = ix.config.Get("nourishmentLossAmount", 1)
    cachedThirstLoss = ix.config.Get("thirstLossAmount", 1)
    cachedEnabled = ix.config.Get("hungerAndThirstEnabled", false)
end

RefreshConfigCache()

function charMeta:GetHunger()
    return self:GetData("hunger", ix.config.Get("startNourishment", 30))
end

function charMeta:GetThirst()
    return self:GetData("thirst", ix.config.Get("startHydration", 30))
end

function charMeta:SetHunger(value)
    value = math.Clamp(value, 0, 100)

    self:SetData("hunger", value)

    local client = self:GetPlayer()
    if (IsValid(client)) then
        client:SetLocalVar("hunger", value)
    end
end

function charMeta:SetThirst(value)
    value = math.Clamp(value, 0, 100)

    self:SetData("thirst", value)

    local client = self:GetPlayer()
    if (IsValid(client)) then
        client:SetLocalVar("thirst", value)
    end
end

function charMeta:AddHunger(amount)
    self:SetHunger(self:GetHunger() + amount)
end

function charMeta:AddThirst(amount)
    self:SetThirst(self:GetThirst() + amount)
end

function PLUGIN:SetupTimers(client, character)
    if (!cachedEnabled) then return end
    local steamID = client:SteamID64()

    timer.Remove("ixHunger_" .. steamID)
    timer.Remove("ixThirst_" .. steamID)

    timer.Create("ixHunger_" .. steamID, ix.config.Get("nourishmentLossTime", 60), 0, function()
        if (!IsValid(client)) then return end

        local char = client:GetCharacter()
        if (!char) then return end

        self:HungerTick(client, char)
    end)

    timer.Create("ixThirst_" .. steamID, ix.config.Get("thirstLossTime", 45), 0, function()
        if (!IsValid(client)) then return end

        local char = client:GetCharacter()
        if (!char) then return end

        self:ThirstTick(client, char)
    end)
end

function PLUGIN:SetupAllTimers()
    for _, v in ipairs(player.GetAll()) do
        local character = v:GetCharacter()

        if (character) then
            self:SetupTimers(v, character)
        end
    end
end

function PLUGIN:RemoveAllTimers()
    for _, v in ipairs(player.GetAll()) do
        timer.Remove("ixHunger_" .. v:SteamID64())
        timer.Remove("ixThirst_" .. v:SteamID64())
    end
end

function PLUGIN:PlayerLoadedCharacter(client, character)
    self:SetupTimers(client, character)

    client:SetLocalVar("hunger", character:GetHunger())
    client:SetLocalVar("thirst", character:GetThirst())
end

function PLUGIN:HungerAndThirstEnabled()
    RefreshConfigCache()
    self:SetupAllTimers()
end

function PLUGIN:HungerAndThirstTimersUpdated()
    self:HungerAndThirstEnabled()
end

function PLUGIN:HungerAndThirstConfigUpdated()
    RefreshConfigCache()
end

function PLUGIN:HungerAndThirstDisabled()
    RefreshConfigCache()
    self:RemoveAllTimers()
end

function PLUGIN:PlayerDeath(client)
    local character = client:GetCharacter()

    if (character) then
        character:SetHunger(ix.config.Get("startNourishment", 30))
        character:SetThirst(ix.config.Get("startHydration", 30))
        self:SetupTimers(client, character)
    end
end

local function ApplyDamageIfPossible(client, currentValue)
    if (currentValue <= 0) then
        if (cachedCauseDeath) then
            client:TakeDamage(cachedDamage)
        else
            local healthAboveMin = client:Health() - cachedMinHealth
            if (healthAboveMin > 0) then
                client:TakeDamage(math.min(cachedDamage, healthAboveMin))
            end
        end
    end
end

function PLUGIN:HungerTick(client, character)
    if (!cachedEnabled) then return end
    if (!client:Alive() or client:GetMoveType() == MOVETYPE_NOCLIP) then return end

    character:AddHunger(-cachedNourishmentLoss)
    ApplyDamageIfPossible(client, character:GetHunger())
end

function PLUGIN:ThirstTick(client, character)
    if (!cachedEnabled) then return end
    if (!client:Alive() or client:GetMoveType() == MOVETYPE_NOCLIP) then return end

    character:AddThirst(-cachedThirstLoss)
    ApplyDamageIfPossible(client, character:GetThirst())
end
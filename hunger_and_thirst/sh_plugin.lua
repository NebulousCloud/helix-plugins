local PLUGIN = PLUGIN

PLUGIN.name = "Hunger and Thirst"
PLUGIN.author = "Heawi"
PLUGIN.description = "Adds hunger and thirst needs to players, with ways to fill them using items. Check sh_exampleItem.lua to see how to modify your food items to work with this plugin"

ix.config.Add("hungerAndThirstEnabled", false, "Whether hunger and thirst is enabled or not.", function()
    if (ix.config.Get("hungerAndThirstEnabled")) then
        hook.Run("HungerAndThirstEnabled")
    else
        hook.Run("HungerAndThirstDisabled")
    end
end, {category = "Hunger and Thirst"})

ix.config.Add("causeDeath", false, "Whether player can die from dehydration or hunger", function()
    hook.Run("HungerAndThirstConfigUpdated")
end, {category = "Hunger and Thirst"})

ix.config.Add("startNourishment", 30, "The amount of nourishment people have on spawn", nil, {
    data = {min = 0, max = 100},
    category = "Hunger and Thirst"
})

ix.config.Add("startHydration", 30, "The amount of hydration people have on spawn", nil, {
    data = {min = 0, max = 100},
    category = "Hunger and Thirst"
})

ix.config.Add("nourishmentLossTime", 60, "The amount of time until player loses set amount of nourishment", function()
    hook.Run("HungerAndThirstTimersUpdated")
end, {
    data = {min = 0, max = 600},
    category = "Hunger and Thirst"
})

ix.config.Add("nourishmentLossAmount", 1, "The amount of nourishment player loses per set loss time", function()
    hook.Run("HungerAndThirstConfigUpdated")
end, {
    data = {min = 0, max = 100},
    category = "Hunger and Thirst"
})

ix.config.Add("thirstLossTime", 45, "The amount of time until player loses set amount of hydration", function()
    hook.Run("HungerAndThirstTimersUpdated")
end, {
    data = {min = 0, max = 600},
    category = "Hunger and Thirst"
})

ix.config.Add("thirstLossAmount", 1, "The amount of hydration player loses per set loss time", function()
    hook.Run("HungerAndThirstConfigUpdated")
end, {
    data = {min = 0, max = 100},
    category = "Hunger and Thirst"
})

ix.config.Add("hungerAndThirstDamage", 2, "How much damage player takes per tick when at 0 nutrition or hydration", function()
    hook.Run("HungerAndThirstConfigUpdated")
end, {
    data = {min = 0, max = 100},
    category = "Hunger and Thirst"
})

ix.config.Add("hungerAndThirstMinHealth", 10, "The minimum health a player can be reduced to from hunger or thirst (when causeDeath is disabled)", function()
    hook.Run("HungerAndThirstConfigUpdated")
end, {
    data = {min = 1, max = 100},
    category = "Hunger and Thirst"
})

ix.char.RegisterVar("hunger", {
    field = "hunger",
    fieldType = ix.type.number,
    default = 50,
    isLocal = false,
    bNoDisplay = true
})

ix.char.RegisterVar("thirst", {
    field = "thirst",
    fieldType = ix.type.number,
    default = 50,
    isLocal = false,
    bNoDisplay = true
})

function PLUGIN:InitializedConfig()
    if (ix.config.Get("hungerAndThirstEnabled")) then
        hook.Run("HungerAndThirstEnabled")
    else
        hook.Run("HungerAndThirstDisabled")
    end
end

ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")
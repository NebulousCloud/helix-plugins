--[[
    This is an example item demonstrating how to restore hunger and thirst.
    - AddHunger(amount) restores nourishment
    - AddThirst(amount) restores hydration
]]

ITEM.name = "Melon"
ITEM.model = Model("models/props_junk/watermelon01.mdl")
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A green fruit, it has a hard outer shell."
ITEM.category = "Consumables"
ITEM.permit = "consumables"

ITEM.functions.Eat = {
    OnRun = function(itemTable)
        local client = itemTable.player
        local character = client:GetCharacter()

        if (character) then
            character:AddHunger(20) -- Adds nourishment
            character:AddThirst(10) -- Adds hydration
        end

        return true
    end,
}

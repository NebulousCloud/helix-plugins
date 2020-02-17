local PLUGIN = PLUGIN

PLUGIN.name = "Custom Items"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Enables staff members to create custom items."

ix.command.Add("CreateCustomItem", {
    description = "@cmdCreateCustomItem",
    superAdminOnly = true,
    arguments = {
        ix.type.string,
        ix.type.string,
        ix.type.string
    },
    OnRun = function(self, client, name, model, description)
        client:GetCharacter():GetInventory():Add("customitem", 1, {
            name = name,
            model = model,
            description = description
        })
    end
})

local PLUGIN = PLUGIN

PLUGIN.name = "Custom Scripts"
PLUGIN.author = "Gary Tate"
PLUGIN.description = "Enables staff members to create custom scripts."

ix.command.Add("CreateCustomScript", {
    description = "@cmdCreateCustomScript",
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

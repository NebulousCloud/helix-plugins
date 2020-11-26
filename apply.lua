PLUGIN.name = "Apply Command"
PLUGIN.author = "Kean"
PLUGIN.description = "Adds a Apply command. That need to apply your data."

ix.command.Add("Apply", {
    description = "Adds a Apply command. That need to apply your data.",
    OnRun = function(self, client)
        ix.chat.Send(client, "ic", "Мои данные: #" .. client:GetCharacter():GetData("cid") .. ', ' .. client:GetCharacter():GetName())
    end
})

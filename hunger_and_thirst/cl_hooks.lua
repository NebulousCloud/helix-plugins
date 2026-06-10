local PLUGIN = PLUGIN

function PLUGIN:InitializedPlugins()
    ix.bar.Add(function()
        local hunger = LocalPlayer():GetLocalVar("hunger", 100)
        return hunger / 100
    end, Color(200, 120, 40), nil, "hunger", true)

    ix.bar.Add(function()
        local thirst = LocalPlayer():GetLocalVar("thirst", 100)
        return thirst / 100
    end, Color(40, 120, 200), nil, "thirst", true)
end

function PLUGIN:Shutdown()
    ix.bar.Remove("hunger")
    ix.bar.Remove("thirst")
end
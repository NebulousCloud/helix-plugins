PLUGIN.name = "Spawnmenu & Context Menu Perms"
PLUGIN.author = "Syn"
PLUGIN.description = "Blocks spawnmenu from anyone without proper flags or without admin & blocks context menu from anyone without admin."
PLUGIN.license = [[
    Copyright 2022 Syn105

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

CAMI.RegisterPrivilege({
	Name = "Helix - Spawnmenu & Context Menu Perms",
	MinAccess = "admin"
})

if (CLIENT) then
    local flags = {
        ["c"] = true,
        ["C"] = true,
        ["e"] = true,
        ["n"] = true,
        ["r"] = true,
        ["t"] = true
    }

    function PLUGIN:SpawnMenuOpen()
        if CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Admin Context Options", nil) then return true end
        local charFlags = {}

        for i = 1, #LocalPlayer():GetCharacter():GetFlags() do
            charFlags[#charFlags + 1] = LocalPlayer():GetCharacter():GetFlags()[i]
        end

        for _, flag in pairs(charFlags or {}) do
            if flags[flag] then
                return true
            end
        end

        return false
    end

    function PLUGIN:ContextMenuOpen()
        if CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Admin Context Options", nil) then return true end
        return false
    end
end
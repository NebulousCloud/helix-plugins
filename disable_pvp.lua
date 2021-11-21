
local PLUGIN = PLUGIN

PLUGIN.name = "Toggle PVP"
PLUGIN.author = "dave"
PLUGIN.description = "Allows administrators to toggle S2K."
PLUGIN.license = [[
Copyright 2021 dave
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("S2K Enabled", true, "Whether or not corpses remain on the map after a player dies and respawns.", nil, {
	category = "Server"
})

--[[
	THIS WILL ONLY WORK !!PROPERLY!! IF YOU DO NOT HAVE ANY OTHER PLUGINS THAT AFFECT EntityTakeDamage()!!!
]]

function PLUGIN:EntityTakeDamage(target, dmgInfo)
	if ix.config.Get("S2K Enabled", false) and dmgInfo:GetAttacker():IsPlayer() and target:IsPlayer() then
		dmgInfo:SetDamage(0)
	end

end
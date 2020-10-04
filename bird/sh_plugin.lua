local PLUGIN = PLUGIN

PLUGIN.name = "Bird"
PLUGIN.author = "Arny"
PLUGIN.description = "Adds the Bird faction, along with some other bird stuff."
PLUGIN.license = [[
Copyright 2020 Arny
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.util.Include("sh_hooks.lua")
ix.util.Include("sv_hooks.lua")

ix.config.Add("birdAllowItemInteract", true, "Allow a bird to interact with items.", nil, {
	category = "Bird"
})

ix.config.Add("birdDeathSounds", true, "Play sounds upon bird injure/death.", nil, {
	category = "Bird"
})

ix.config.Add("birdRecogniseEachother", true, "Can birds recognise eachother?.", nil, {
	category = "Bird"
})

ix.config.Add("birdInventory", true, "Shrink the birds inventory? (reconnect/server restart may be required)", nil, {
	category = "Bird"
})

ix.config.Add("birdFlightSpeed", 100, "The speed at which a bird can fly.", nil, {
	data = {min = 0, max = 100},
	category = "Bird"
})

ix.config.Add("birdHealth", 2, "The default health of birds.", nil, {
	data = {min = 1, max = 100},
	category = "Bird"
})

ix.config.Add("birdChat", true, "Allow the birds to talk?", nil, {
	category = "Bird"
})

ix.config.Add("birdActions", true, "Allow the birds use /me and /it?", nil, {
	category = "Bird"
})

ix.config.Add("birdOOC", true, "Allow the birds use OOC?", nil, {
	category = "Bird"
})

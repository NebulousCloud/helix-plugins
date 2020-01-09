
local PLUGIN = PLUGIN

PLUGIN.name = "Local Event"
PLUGIN.author = "Ice Bear#2034"
PLUGIN.description = "Adds in a new /LocalEvent command only heard from a certain distance, it appears in yellow rather than orange."
PLUGIN.license = [[
Copyright 2019-2020 DevAppeared
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- Configuration registration.
ix.config.Add("localEventDistance", 560, "The maximum distance people can hear a local event, default is the standard yelling range.", nil, {
	data = {min = 10, max = 5000, decimals = 1},
	category = "chat"
})

-- Command registration.
ix.command.Add("LocalEvent", {
	description = "Make something perform an action that only those in a certain distance can see.",
	arguments = ix.type.text,
	superAdminOnly = true,
	OnRun = function(self, client, text)
		ix.chat.Send(client, "localevent", text)
	end
})

-- Chat registration.
ix.chat.Register("localevent", {
	CanHear = ix.config.Get("localEventRange", 560),
	OnChatAdd = function(self, speaker, text)
		chat.AddText(Color(255, 255, 0), text)
	end,
	indicator = "chatPerforming"
})


local PLUGIN = PLUGIN

PLUGIN.name = "My Notes"
PLUGIN.author = "`impulse"
PLUGIN.description = "Adds a personal notepad so people can save stuff they want to remember."
PLUGIN.license = [[
Copyright 2020 Igor Radovanovic

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
PLUGIN.readme = [[
Adds a personal notepad that players can use to save stuff they want to remember.

## Customizing
If you find the standard `1024` character limit for personal notes too short, you can increase it by changing `PLUGIN.maxLength` in `sh_plugin.lua` to something higher. You should keep this under a few thousand characters.
]]

PLUGIN.maxLength = 1024

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")

ix.command.Add("MyNotes", {
	description = "@cmdMyNotes",
	OnRun = function(self, client)
		local status = PLUGIN:SendNotes(client)

		if (isnumber(status)) then
			return "@mynotesCooldown", status
		end
	end
})


local PLUGIN = PLUGIN

PLUGIN.name = "Better Local Event"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Adds a local event command for events in a specified radius."
PLUGIN.readme = [[
Adds a local event command for events in a specified radius.

Support for this plugin can be found here: https://discord.gg/mntpDMU
]]
PLUGIN.license = [[
Copyright 2020 wowm0d
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.lang.AddTable("english", {
	cmdLocalEvent = "Make something perform an action that can be seen at a specified radius."
})

if (CLIENT) then
	function PLUGIN:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
		if (bDrawingDepth or bDrawingSkybox) then
			return
		end

		if (ix.chat.currentCommand == "localevent") then
			render.SetColorMaterial()
			render.DrawSphere(LocalPlayer():GetPos(), -(tonumber(ix.chat.currentArguments[2]) or 500), 30, 30, Color(255, 150, 0, 100))
		end
	end
end

do
	local COMMAND = {}
	COMMAND.description = "@cmdLocalEvent"
	COMMAND.arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional)}
	COMMAND.superAdminOnly = true

	function COMMAND:OnRun(client, event, radius)
		ix.chat.Send(client, "localevent", event, nil, nil, {range = radius})
	end

	ix.command.Add("LocalEvent", COMMAND)
end

do
	local CLASS = {}
	CLASS.color = Color(255, 150, 0)
	CLASS.superAdminOnly = true
	CLASS.indicator = "chatPerforming"

	function CLASS:CanHear(speaker, listener, data)
		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.range and data.range ^ 2 or 250000)
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, text)
	end

	ix.chat.Register("localevent", CLASS)
end

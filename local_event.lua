
local PLUGIN = PLUGIN

PLUGIN.name = "Better Local Event"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Adds a better /localevent command for events in a specfic radius."
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
			local arguments = ix.chat.currentArguments
			local range = tonumber(arguments[2])
			local pos = LocalPlayer():GetPos()

			if (range) then
				range = -range
			else
			    range = -500
			end

			render.SetColorMaterial()
			render.DrawSphere(pos, range, 30, 30, Color(255, 150, 0, 100))
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
		return (speaker:GetPos() - listener:GetPos()):LengthSqr() <= (data.range and data.range^2 or 250000)
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, text)
	end

	ix.chat.Register("localevent", CLASS)
end

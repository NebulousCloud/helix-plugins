
PLUGIN.name = "Message Flash"
PLUGIN.description = "Flashes the client's Garry's Mod application when a message is posted in the chat."
PLUGIN.author = "Aspect™"
PLUGIN.readme = [[
Many people have been in this situation: You are playing in a server, and you are waiting for something, so you decide to tab out for just a bit, to do something else. Before you know it, someone has approached you and has been waiting for you to reply to his message for several minutes.
	
This plugin flashes your Garry's Mod application to alert you when you receive a message, allowing you to jump back into the roleplay when needed.]]
PLUGIN.license = [[
MIT License

Copyright (c) 2021 Aspect™

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

ix.lang.AddTable("english", {
	optFlashWindow = "Flash Window",
	optdFlashWindow = "Whether your Garry's Mod Application should flash when a message is posted in the chat."
})

ix.option.Add("flashWindow", ix.type.bool, true, {
	category = "chat"
})

if (CLIENT) then
	function PLUGIN:MessageReceived(client, info)
		if (ix.option.Get("flashWindow", true) and system.IsWindows() and !system.HasFocus()) then
			system.FlashWindow()
		end
	end
end

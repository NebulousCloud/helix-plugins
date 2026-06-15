PLUGIN.name = "Improved Voice Commands"
PLUGIN.description = "Let's users string multiple voice commands together."
PLUGIN.author = "DoopieWop"
PLUGIN.schema = "HL2 RP"
PLUGIN.license = [[
Copyright 2022 DoopieWop

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

ix.config.Add("experimentalModeVC", false, "This won't always work as expected!!! Adjusts voice command texts to \"fit\" to the rest of the text. If the text continues after a voice command it will remove the end symbol etc.", nil, {category = PLUGIN.name})
ix.config.Add("separatorVC", "|", "Separator symbol between voice commands and text. Leave empty for using spaces as separator. (Using spaces might cause unforseen consequences, 10-8 Standing By will not be recognized, instead it will use the 10-8 voice command and then play the Standing By voice command.", nil, {category = PLUGIN.name})
ix.config.Add("radioVCAllow", true, "Allow voice commands to be used on the radio. This will playback the voice commands on all the recevers.", nil, {category = PLUGIN.name})
ix.config.Add("radioVCVolume", 60, "Sets the volume, radio voice commands are played back for receivers. This is lower than normal as it's coming through a radio.", nil, {category = PLUGIN.name, data = {min = 0, max = 200}})
ix.config.Add("radioVCClientOnly", false, "If set to true, radio voice commands receivers will hear the voice commands only clientside, so nobody around them can hear it.", nil, {category = PLUGIN.name})

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")
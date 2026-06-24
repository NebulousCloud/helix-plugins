local PLUGIN = PLUGIN

PLUGIN.name = "Prop Health"
PLUGIN.author = "Max_auCube"
PLUGIN.description = "Add HP to props."

PLUGIN.license = [[

MIT License

Copyright (c) 2026 Max_auCube

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

PLUGIN.readme = [[
Prop Health Plugin for Helix

This lightweight plugin adds a dynamic health and destruction system to all physics props.

Features:

    - Mass-Based Health: A prop's maximum health is automatically calculated based on its physical weight (Mass * Config Multiplier). Heavier objects like concrete barriers are much harder to destroy than wooden crates.

    - Explosive Destruction: When health reaches zero, the prop creates an explosion effect before being removed. **Can be Disabled**

    - Real-Time Tooltip: Looking at a prop displays a live health counter in the standard Helix interaction menu that updates instantly during combat.

Configuration: You can adjust 'propsMinHP' (default 50) and 'propsHPMultiplier' (default 5) in your server configuration to balance durability.

*AI usage note: Code quality improvements.*
]]

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

ix.lang.AddTable("english", {
	propHealth = "Health"
})

ix.lang.AddTable("french", {
	propHealth = "Santé"
})

ix.config.Add("propsHPMultiplier", 5, "Multiplier for props HP.", nil, {
	data = {min = 0, max = 10},
	category = "Prop Health"
})

ix.config.Add("propsMinHP", 50, "Minimal HP for props.", nil, {
	data = {min = 0, max = 1000},
	category = "Prop Health"
})

ix.config.Add("propsExplode", true, "Toggles explosion effects on prop destruction.", nil, {
	category = "Prop Health"
})


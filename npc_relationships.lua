
local PLUGIN = PLUGIN

PLUGIN.name = "NPC Relationships"
PLUGIN.author = "dave"
PLUGIN.description = "Allows certain NPCs to be friendly to certain player factions. Supports VJBase NPCs."
PLUGIN.license = [[
Copyright 2021 dave
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
PLUGIN.readme = [[
	Thank you to FlorianLeChat and pedrosantos53 for various comments and advice.
]]

if CLIENT then return end -- if we're on the client, stop

local friendlyNPCs = {
	npc_zombie = true,
	npc_vj_nmrih_runfemalez = true,
	npc_vj_nmrih_runmalez = true,
	npc_vj_nmrih_runsoldierz = true,
	npc_vj_nmrih_walkfemalez = true,
	npc_vj_nmrih_walkmalez = true,
	npc_vj_nmrih_walksoldierz = true,
	npc_vj_nmrih_childz = true,
}

local friendlyFaction = FACTION_ZOMBIES -- change this to the faction you want your npcs to be friendly to

local friendlyClasses = { -- vjbase classes to make friendly if the player is a zombie
						  -- if not using vjbase, leave as is
	"CLASS_ZOMBIE",
}

function PLUGIN:OnEntityCreated(ent)
	if !friendlyNPCs[ent:GetClass()] then return end -- if the entity is not the specified class

	for _, ply in ipairs(player.GetAll()) do -- get all players
		if !ply:GetCharacter() then continue end -- if player is not loaded

		if ply:Team() != friendlyFaction then ply.VJ_NPC_Class = {nil}; continue end -- if not a friendly faction

		ent:AddEntityRelationship(ply, D_LI, 99) -- make ent friendly to ply

		ply.VJ_NPC_Class = friendlyClasses -- support for vjbase

	end
end

function PLUGIN:CharacterLoaded(char)
	for _, ent in ipairs(ents.FindByClass("npc_*")) do -- get all npcs
		if !friendlyNPCs[ent:GetClass()] then continue end -- if the entity is not the specified class

		for _, ply in ipairs(player.GetAll()) do -- get all players
			if ply:GetCharacter() and ply:Team() == friendlyFaction then -- if player is loaded and is a friendly faction
				ent:AddEntityRelationship(ply, D_LI, 99) -- make ent friendly to ply

				ply.VJ_NPC_Class = friendlyClasses -- support for vjbase

			elseif ply:GetCharacter() then -- if not a friendly faction
				ent:AddEntityRelationship(ply, D_HT, 99) -- make ent hostile to ply

				ply.VJ_NPC_Class = {nil} -- support for vjbase

			end
		end
	end
end

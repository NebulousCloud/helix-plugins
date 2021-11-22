
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

if SERVER then -- if on server

local zombieNPCs = {
	"npc_zombie",
	"npc_vj_nmrih_runfemalez",
	"npc_vj_nmrih_runmalez",
	"npc_vj_nmrih_runsoldierz",
	"npc_vj_nmrih_walkfemalez",
	"npc_vj_nmrih_walkmalez",
	"npc_vj_nmrih_walksoldierz",
	"npc_vj_nmrih_childz",

}

local friendlyFaction = FACTION_ZOMBIES -- change this to the faction you want your npcs to be friendly to

local friendlyClasses = { -- vjbase classes to make friendly if the player is a zombie
						  -- if not using vjbase, leave as is
	"CLASS_ZOMBIE",

}

function SetRelationship(ent, ply, relationship) -- function to set relationship
	ent:AddEntityRelationship(ply, relationship, 99) -- make ent friendly to ply
	
end

function PLUGIN:OnEntityCreated(ent)

	if !ent:IsNPC() then return end -- if not an npc

	for i, class in ipairs(zombieNPCs) do -- get all friendly classes
		if ent:GetClass() != class then continue end -- if the entity is not the specified class

		for i, Ply in ipairs(player.GetAll()) do -- get all players
			if !Ply:GetCharacter() then continue end -- if player is not loaded

			if Ply:Team() != friendlyFaction then Ply.VJ_NPC_Class = {nil}; continue end -- if not a friendly faction

			if !SERVER then continue end -- if not the server (likely unneeded, for insurance)

			SetRelationship(ent,Ply,D_LI) -- make the entity friendly

			Ply.VJ_NPC_Class = friendlyClasses -- support for vjbase

		end
	end
end

function PLUGIN:CharacterLoaded(char)

	for i, ent in pairs(ents.GetAll()) do -- get all entities
		for v, class in ipairs(zombieNPCs) do -- get all friendly classes 
			if !ent:IsNPC() then continue end --if not an npc

			if ent:GetClass() != class then continue end -- if the entity is not the specified class

			for i, Ply in ipairs(player.GetAll()) do -- get all players
				if Ply:GetCharacter() and Ply:Team() == friendlyFaction then -- if player is loaded and is a friendly faction
					SetRelationship(ent,Ply,D_LI) -- make the entity friendly

					Ply.VJ_NPC_Class = friendlyClasses -- support for vjbase

				elseif Ply:GetCharacter() then -- if not a friendly faction
					SetRelationship(ent,Ply,D_HT) -- make the entity hostile

					Ply.VJ_NPC_Class = {nil} -- support for vjbase

				end
			end	
		end
	end
end

end


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

if SERVER then

function SetRelationship(ent, ply, relationship)
	ent:AddEntityRelationship(ply, relationship, 99)
	
end

function PLUGIN:OnEntityCreated(ent)
	if !ent:IsNPC() then return end -- if not an npc, return
		for i, class in ipairs(zombieNPCs) do -- get all friendly classes
			if ent:GetClass() != class then continue end --
				for i, Ply in ipairs(player.GetAll()) do
					if !Ply:GetCharacter() then continue end
					if Ply:Team() != friendlyFaction then Ply.VJ_NPC_Class = {nil}; continue end
						if !SERVER then continue end
						SetRelationship(ent,Ply,D_LI)
						Ply.VJ_NPC_Class = friendlyClasses
				end
		end

end

function PLUGIN:CharacterLoaded(char)
	for i, ent in pairs(ents.GetAll()) do
		for v, class in ipairs(zombieNPCs) do
			if !ent:IsNPC() then continue end
				if ent:GetClass() != class then continue end
					for i, Ply in ipairs(player.GetAll()) do
						if Ply:GetCharacter() and Ply:Team() == friendlyFaction then
							SetRelationship(ent,Ply,D_LI)
							Ply.VJ_NPC_Class = friendlyClasses
						elseif Ply:GetCharacter() then
							SetRelationship(ent,Ply,D_HT)
							Ply.VJ_NPC_Class = {nil}
						end
					end
				
			
		end
	end
end

end

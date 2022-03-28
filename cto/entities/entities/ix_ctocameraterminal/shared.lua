
DEFINE_BASECLASS("base_gmodentity")

ENT.Type = "anim"
ENT.Author = "Aspect™ & Trudeau"
ENT.PrintName = "Camera Terminal"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.UsableInVehicle = true

function ENT:GetEntityMenu(client)
	local options = {}
	
	options["Disable"] = true

	for _, v in pairs(ents.FindByClass("npc_combine_camera")) do
		options["View C-i" .. v:EntIndex()] = true
	end

	return options
end

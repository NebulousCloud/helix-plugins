
RECIPE.name = "Watermelon"
RECIPE.description = "Craft a watermelon."
RECIPE.model = "models/props_junk/watermelon01.mdl"
RECIPE.category = "Watermelon"
RECIPE.requirements = {
	["water"] = 1
}
RECIPE.results = {
	["melon"] = 1
}
RECIPE.tools = {
	"cid"
}
RECIPE.flag = "V"

RECIPE:PostHook("OnCanCraft", function(recipeTable, client)
	for _, v in pairs(ents.FindByClass("ix_station_workbench")) do
		if (client:GetPos():DistToSqr(v:GetPos()) < 100 * 100) then
			return true
		end
	end

	return false, "You need to be near a workbench."
end)

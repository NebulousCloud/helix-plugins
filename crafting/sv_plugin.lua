netstream.Hook("ixCraftItem", function(ply, data, data2)
	local requirements
	local results
	local skills
	local guns
	local id = data[1]
	local missing = {}
	local char = ply:GetChar()
	local inv = char:GetInventory()
	local recipes = STORED_RECIPES

	for k, v in pairs(recipes) do
		if v["id"] == id then
			requirements = v["req"]
			results = v["results"]
			skills = v["skills"]
			guns = v["guns"] or false
		end
	end

	for k, v in pairs(requirements) do
		if inv:GetItemCount(k) < v then
			print(inv:GetItemCount(k))
			local i = ix.item.Get(k)
			missing[#missing + 1] = i.name
		end
	end

	if #missing > 0 then
		ply:Notify("You do not have enough items to complete this recipe! You need more of: " .. table.concat(missing, ", "))

		return false
	end

	if skills then
		for k, v in pairs(skills) do
			if ply:GetCharacter():GetAttribute(k, 0) < v then
				ply:Notify("You do not have enough skill to craft this item.")

				return false
			end
		end
	end

	ply:Notify("You have successfully crafted this recipe.")

	for k, v in pairs(requirements) do

		for i = 1, v do
			
			local item = inv:HasItem(k)
			if !item.isTool then
				item:Remove()
			end
		end
	end

	for k, v in pairs(results) do
		inv:Add(k, v)
	end
	ply:GetCharacter():UpdateAttrib("eng", 0.1)
	if guns then
		ply:GetCharacter():UpdateAttrib("guns", 1)
	end
	ix.log.AddRaw(ply:Name() .. " has crafted a recipe and received: " .. table.concat(results, ", "))
end)
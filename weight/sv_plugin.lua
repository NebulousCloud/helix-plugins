function ix.weight.CalculateWeight(character) -- Calculates the total weight of all items a character is carrying.
	local inventory = character:GetInventory()

	local weight = 0

	for i, v in pairs(inventory:GetItems()) do
		if (v:GetWeight()) then
			weight = weight + v:GetWeight()
		end
	end

	return weight
end

function ix.weight.Update(character) -- Updates the specified character's current carry weight.
	character:SetData("carry", ix.weight.CalculateWeight(character))
end

function PLUGIN:CharacterLoaded(character) -- This is just a safety net to make sure the carry weight data is up-to-date.
	ix.weight.Update(character)
end

function PLUGIN:CanTransferItem(item, old, inv) -- When a player attempts to take an item out of a container.
	if (inv.owner and item:GetWeight() and (old and old.owner != inv.owner)) then
		local character = ix.char.loaded[inv.owner]

		if (!character:CanCarry(item)) then
			character:GetPlayer():NotifyLocalized("You are carrying too much weight to take that.")
			return false
		end
	end
end

function PLUGIN:OnItemTransferred(item, old, new)
	if (item:GetWeight()) then
		if (old.owner and !new.owner) then -- Removing item from inventory.
			ix.weight.Update(ix.char.loaded[old.owner])
		elseif (!old.owner and new.owner) then -- Adding item to inventory.
			ix.weight.Update(ix.char.loaded[new.owner])
		end
	end
end

function PLUGIN:InventoryItemAdded(old, new, item)
	if (item:GetWeight()) then
		if (!old and new.owner) then -- When an item is directly created in their inventory.
			ix.weight.Update(ix.char.loaded[new.owner])
		end
	end
end

function PLUGIN:CanPlayerTakeItem(client, item)
	local character = client:GetCharacter()

	local itm = item:GetItemTable()

	if (itm:GetWeight()) then
		if (!character:CanCarry(itm)) then
			client:NotifyLocalized("You are carrying too much weight to pick that up.")
			return false
		end
	end
end

function PLUGIN:CanPlayerTradeWithVendor(client, entity, uniqueID, selling)
	if (!selling) then
		local item = ix.item.list[uniqueID]

		if (item:GetWeight() and !client:GetCharacter():CanCarry(item)) then
			client:NotifyLocalized("You are carrying too much weight to buy that.")
			return false
		end
	end
end

function PLUGIN:CharacterVendorTraded(client, entity, uniqueID, selling)
	client:GetCharacter():UpdateWeight()
end

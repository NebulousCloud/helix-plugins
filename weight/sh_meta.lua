-- ITEM META START --
local ITEM = ix.meta.item or {}

function ITEM:GetWeight()
	return self:GetData("weight", nil) or self.weight or nil
end

function ITEM:DropWeight(w)
	if (self.player) then
		local weight = w or self:GetWeight()

		if (weight) then
			self.player:GetCharacter():DropWeight(weight)
		end
	end
end

ix.meta.item = ITEM
-- ITEM META END --

-- CHARACTER META START --
local CHAR = ix.meta.character or {}

function CHAR:Overweight()
	return self:GetData("carry", 0) > ix.weight.BaseWeight(self)
end

function CHAR:CanCarry(item)
	return ix.weight.CanCarry(item:GetWeight(), self:GetData("carry", 0), self)
end

function CHAR:UpdateWeight()
	ix.weight.Update(self)
end

-- these are primarily intended as internally used functions, you shouldn't use them in your own code --
function CHAR:AddCarry(item)
	self:SetData("carry", math.max(self:GetData("carry", 0) + item:GetWeight(), 0))
end

function CHAR:RemoveCarry(item)
	self:SetData("carry", math.max(self:GetData("carry", 0) - item:GetWeight(), 0))
end
-- these are primarily intended as internally used functions, you shouldn't use them in your own code --

function CHAR:DropWeight(weight)
	self:SetData("carry", math.max(self:GetData("carry", 0) - weight, 0))
end

ix.meta.char = CHAR
-- CHARACTER META END --

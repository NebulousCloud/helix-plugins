
local PLUGIN = PLUGIN

function PLUGIN:GetWarmthText(amount)
	if (amount > 75) then
		return L("warmthWarm")
	elseif (amount > 50) then
		return L("warmthChilly")
	elseif (amount > 25) then
		return L("warmthCold")
	else
		return L("warmthFreezing")
	end
end

function PLUGIN:WarmthEnabled()
	ix.bar.Add(function()
		local character = LocalPlayer():GetCharacter()

		if (character) then
			local warmth = character:GetWarmth()
			return warmth / 100, self:GetWarmthText(warmth)
		end

		return false
	end, Color(200, 50, 40), nil, "warmth")
end

function PLUGIN:WarmthDisabled()
	ix.bar.Remove("warmth")
end

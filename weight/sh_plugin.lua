PLUGIN.name = "Weight"
PLUGIN.author = "Vex"
PLUGIN.description = "Allows for weight to be added to items."

ix.weight = ix.weight or {}

ix.config.Add("maxWeight", 30, "The maximum weight in Kilograms someone can carry in their inventory.", nil, {
	data = {min = 1, max = 100},
	category = "Weight"
})

ix.config.Add("maxOverWeight", 20, "The maximum amount of weight in Kilograms they can go over their weight limit, this should be less than maxWeight to prevent issues.", nil, {
	data = {min = 1, max = 100},
	category = "Weight"
})

ix.util.Include("sh_meta.lua")
ix.util.Include("sv_plugin.lua")

function ix.weight.WeightString(weight, imperial)
	if (imperial) then
		if (weight < 0.453592) then -- Filthy imperial system; Why do I allow their backwards thinking?
			return math.Round(weight * 35.274, 2).." oz"
		else
			return math.Round(weight * 2.20462, 2).." lbs"
		end
	else
		if (weight < 1) then -- The superior units of measurement.
			return math.Round(weight * 1000, 2).." g"
		else
			return math.Round(weight, 2).." kg"
		end
	end
end

function ix.weight.CanCarry(weight, carry) -- Calculate if you are able to carry something.
	local max = ix.config.Get("maxWeight", 30) + ix.config.Get("maxOverWeight", 20)

	return (weight + carry) <= max
end

if (CLIENT) then
	ix.option.Add("imperial", ix.type.bool, false, {
		category = "Weight"
	})

	function PLUGIN:PopulateItemTooltip(tooltip, item)
		local weight = item:GetWeight()

		if (weight) then
			local row = tooltip:AddRowAfter("description", "weight")
				row:SetText(ix.weight.WeightString(weight, ix.option.Get("imperial", false)))
				row:SetExpensiveShadow(1, color_black)
				row:SizeToContents()
		end
	end

	hook.Add("CreateMenuButtons", "ixInventory", function(tabs) -- We use the same special ID because the idea is to completely override it.
		if (hook.Run("CanPlayerViewInventory") == false) then
			return
		end

		tabs["inv"] = {
			bDefault = true,
			Create = function(info, container)
				local canvas = container:Add("DTileLayout")
				local canvasLayout = canvas.PerformLayout
				canvas.PerformLayout = nil -- we'll layout after we add the panels instead of each time one is added
				canvas:SetBorder(0)
				canvas:SetSpaceX(2)
				canvas:SetSpaceY(2)
				canvas:Dock(FILL)

				ix.gui.menuInventoryContainer = canvas

				local panel = canvas:Add("ixInventory")
				panel:SetPos(0, 0)
				panel:SetDraggable(false)
				panel:SetSizable(false)
				panel:SetTitle(nil)
				panel.bNoBackgroundBlur = true
				panel.childPanels = {}

				local inventory = LocalPlayer():GetCharacter():GetInventory()

				if (inventory) then
					panel:SetInventory(inventory)
				end

				ix.gui.inv1 = panel

				if (ix.option.Get("openBags", true)) then
					for _, v in pairs(inventory:GetItems()) do
						if (!v.isBag) then
							continue
						end

						v.functions.View.OnClick(v)
					end
				end

				local character = LocalPlayer():GetCharacter()
				local carry = character:GetData("carry", 0)
				local color = ix.config.Get("color")
				local maxWeight = ix.config.Get("maxWeight", 30)

				local w, h = panel:GetSize()

				panel:SetTall(h + 25)

				w = w - 10

				local weight = panel:Add("DPanel")
					weight:SetPos(5, h - 4)
					weight:SetSize(w, 24)
					weight.Paint = function(self, w, h)
						surface.SetDrawColor(35, 35, 35, 85)
						surface.DrawRect(1, 1, w, h)

						surface.SetDrawColor(0, 0, 0, 250)
						surface.DrawOutlinedRect(0, 0, w, h)
					end
					local bar = weight:Add("DPanel")
						bar:SetSize(w, 24)
						bar.Paint = function(self)
							surface.SetDrawColor(color)
							surface.DrawRect(4, 4, math.min(((w - 8) / maxWeight) * carry, w - 8), 16)
						end
					local barO = weight:Add("DPanel")
						barO:SetSize(w, 24)
						barO.Paint = function(self)
							surface.SetDrawColor(Color(205, 50, 50))
							if (carry > maxWeight) then
								surface.DrawRect(4, 4, math.min(((w - 8) / maxWeight) * (carry - maxWeight), w - 8), 16)
							end
						end
					local barT = weight:Add("DLabel")
						barT:SetSize(w, 24)
						barT:SetContentAlignment(5)
						barT.Think = function()
							carry = character:GetData("carry", 0)
							if (ix.option.Get("imperial", false)) then
								barT:SetText(math.Round(carry * 2.20462, 2).." lbs / "..math.Round(maxWeight * 2.20462, 2).." lbs")
							else
								barT:SetText(math.Round(carry, 2).." kg / "..maxWeight.." kg")
							end
						end

				canvas.PerformLayout = canvasLayout
				canvas:Layout()
			end
		}
	end)
end


local PLUGIN = PLUGIN

PLUGIN.name = "Physical Entity Info"
PLUGIN.author = "wowm0d"
PLUGIN.description = "Changes entity hover info drawing."
PLUGIN.license = [[
Copyright 2020 wowm0d
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
PLUGIN.readme = [[
Makes entity hover info a physical point in the world to draw from.

Support for this plugin can be found here: https://discord.gg/mntpDMU
]]

if (CLIENT) then
	local overridenEntities = {
		["ix_item"] = true,
		["ix_container"] = true,
		["ix_money"] = true,
		["ix_vendor"] = true,
		["ix_shipment"] = true
	}

	local drawInfo = {}

	function PLUGIN:ShouldPopulateEntityInfo(entity)
		if (overridenEntities[entity:GetClass()] or entity:IsPlayer()) then
			drawInfo[entity:EntIndex()] = drawInfo[entity:EntIndex()] or {alpha = 0}

			drawInfo[entity:EntIndex()].time = CurTime()

			return false
		end
	end

	function PLUGIN:HUDPaint()
		local genericHeight = draw.GetFontHeight("ixGenericFont")
		local descHeight = draw.GetFontHeight("ixItemDescFont")

		for k, v in pairs(drawInfo) do
			-- [[ Alpha Handling ]] --

			local time = (CurTime() - v.time)

			if (v.alpha) then
			    if (v.time) then
			    	if (time < 0.5) then
			    		v.alpha = Lerp(time, v.alpha, 1)
			    	else
			    		v.alpha = Lerp(time - 0.5, v.alpha, 0)

			    		if (v.alpha == 0) then
						    drawInfo[k] = nil

						    continue
						end
			    	end
			    end
			end

			drawInfo[k] = v

			-- [[ Entity Info Handling ]] --

			local entity = ents.GetByIndex(k)

			if (IsValid(entity)) then
				local position = select(1, entity:GetBonePosition(entity:LookupBone("ValveBiped.Bip01_Spine4") or -1)) or entity:LocalToWorld(entity:OBBCenter())
				local x, y = position:ToScreen().x, position:ToScreen().y

				local entityClass = entity:GetClass()

				if (entityClass == "ix_item" and entity.GetItemTable) then
					local itemTable = entity:GetItemTable()

					local itemName = (itemTable.GetName and itemTable:GetName() or itemTable.name) or ""

					ix.util.DrawText(itemName, x, y-(genericHeight/2), ColorAlpha(ix.config.Get("color"), v.alpha*255), 1, 1)

					local descriptionText = ix.util.WrapText((itemTable.GetDescription and itemTable:GetDescription() or itemTable.description) or "", 300, "ixItemDescFont")

					for i, _ in pairs(descriptionText) do
						ix.util.DrawText(descriptionText[i], x, y+(descHeight*i)-(genericHeight/2), ColorAlpha(color_white, v.alpha*255), 1, 1, "ixItemDescFont")
					end

					continue
				end

				if (entityClass == "ix_container") then
					local definition = ix.container.stored[entity:GetModel():lower()]
					local bLocked = entity:GetLocked()

					local iconHeight = draw.GetFontHeight("ixIconsSmall")
					local iconText = bLocked and "P" or "Q"

					ix.util.DrawText(iconText or "", x, y-iconHeight-(genericHeight/2), ColorAlpha(bLocked and Color(200, 38, 19) or Color(135, 211, 124), v.alpha*200), 1, 1, "ixIconsSmall")

					ix.util.DrawText(entity:GetDisplayName() or "", x, y-(genericHeight/2), ColorAlpha(ix.config.Get("color"), v.alpha*255), 1, 1)

					ix.util.DrawText(definition.description or "", x, y+descHeight-(genericHeight/2), ColorAlpha(color_white, v.alpha*255), 1, 1, "ixItemDescFont")

					continue
				end

				if (entityClass == "ix_money") then
					ix.util.DrawText(ix.currency.Get(entity:GetAmount()) or "", x, y-(genericHeight/2), ColorAlpha(ix.config.Get("color"), v.alpha*255), 1, 1)

					continue
				end

				if (entityClass == "ix_vendor") then
					ix.util.DrawText(entity:GetDisplayName() or "", x, y-(genericHeight/2), ColorAlpha(ix.config.Get("color"), v.alpha*255), 1, 1)

					local descriptionText = entity:GetDescription()

					if (descriptionText != "") then
						ix.util.DrawText(entity:GetDescription() or "", x, y+descHeight-(genericHeight/2), ColorAlpha(color_white, v.alpha*255), 1, 1, "ixItemDescFont")
					end

					continue
				end

				if (entityClass == "ix_shipment") then
					ix.util.DrawText(L("shipment") or "", x, y-(genericHeight/2), ColorAlpha(ix.config.Get("color"), v.alpha*255), 1, 1)

					local owner = ix.char.loaded[entity:GetNetVar("owner", 0)]

					if (owner) then
						ix.util.DrawText(L("shipmentDesc", owner:GetName()) or "", x, y+descHeight-(genericHeight/2), ColorAlpha(color_white, v.alpha*255), 1, 1, "ixItemDescFont")
					end

					continue
				end

				if (entity:IsPlayer()) then
					local character = entity:GetCharacter()

					if (character) then
						local name = hook.Run("GetCharacterName", entity) or character:GetName()

						ix.util.DrawText(name or "", x, y-(genericHeight/2), ColorAlpha(team.GetColor(entity:Team()), v.alpha*255), 1, 1)

						if (entity:IsRestricted()) then
							ix.util.DrawText(L("tiedUp") or "", x, y+(descHeight)-(genericHeight/2), ColorAlpha(Color(230,180,0), v.alpha*255), 1, 1, "ixItemDescFont")
							y = y + descHeight
						elseif (entity:GetNetVar("tying")) then
							ix.util.DrawText(L("beingTied") or "", x, y+(descHeight)-(genericHeight/2), ColorAlpha(Color(230,180,0), v.alpha*255), 1, 1, "ixItemDescFont")
							y = y + descHeight
						elseif (entity:GetNetVar("untying")) then
							ix.util.DrawText(L("beingUntied") or "", x, y+(descHeight)-(genericHeight/2), ColorAlpha(Color(230,180,0), v.alpha*255), 1, 1, "ixItemDescFont")
							y = y + descHeight
						end

						local injureText, injureTextColor = hook.Run("GetInjuredText", entity)

						if (injureText) then
							ix.util.DrawText(L(injureText) or "", x, y+(descHeight)-(genericHeight/2), ColorAlpha(injureTextColor, v.alpha*255), 1, 1, "ixItemDescFont")
							y = y + descHeight
						end

						local descriptionText = ix.util.WrapText(character:GetDescription() or "", 300, "ixItemDescFont")

						for i, _ in pairs(descriptionText) do
							ix.util.DrawText(descriptionText[i], x, y+(descHeight*i)-(genericHeight/2), ColorAlpha(color_white, v.alpha*255), 1, 1, "ixItemDescFont")
						end

						continue
					end
				end
			else
			    drawInfo[k] = nil

			    continue
			end
		end
	end
end

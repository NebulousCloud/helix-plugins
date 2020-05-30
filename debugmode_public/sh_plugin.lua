PLUGIN.name = "Better Debug"
PLUGIN.author = "Tesko"
PLUGIN.description = "Simple Better Debugging"
PLUGIN.license = [[https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode]]
PLUGIN.readme = [[
	You can enable the debug mode in the server settings
	--
	There are 2 new console commands:
	bettergetpos -- prints position in the console and gives copies it into the clipboard as vector
	bettergetangles -- prints angles in the console and gives copies it into the clipboard as vector
	--
	1 New function
	printDebugMsg(info,text) -- info = What Plugin or line ? Text is text
	# Debug # Drug Plugin line 24 # This is a debug print where you see your info string thing
]]

ix.config.Add("Debug Mode",false, "Toggle debug mode.", nil, {
	category = "Debug"
})

ix.config.Add("Debug Prints",false, "Toggle debug prints.", nil, {
	category = "Debug"
})

ix.config.Add("Extended Debug Mode",false, "Toggle Extended Debug Mode.", nil, {
	category = "Debug"
})

if SERVER then
	function printDebugMsg(info,text)
		if ix.config.Get("Debug Prints") then
			print("# Debug # " .. tostring(info) .. " # " .. tostring(text))
		end
	end
elseif CLIENT then
	function printDebugMsg(info,text)
		if ix.config.Get("Debug Prints") then
			print("# Debug # " .. tostring(info) .. " # " .. tostring(text))
		end
	end
end

if CLIENT then
	concommand.Add("bettergetpos",function()
		local coord = string.Split(tostring(LocalPlayer():GetPos())," ")
		print(coord[1])
		print(coord[2])
		print(coord[3])
		local xvar = "Vector("..coord[1]..","..coord[2]..","..coord[3].."),"
		SetClipboardText(xvar)
		print(xvar)
	end)
	concommand.Add("bettergetangles",function()
		local coord = string.Split(tostring(LocalPlayer():GetAngles())," ")
		print(coord[1])
		print(coord[2])
		print(coord[3])
		local xvar = "Angle("..coord[1]..","..coord[2]..","..coord[3].."),"
		SetClipboardText(xvar)
		print(xvar)
	end)
end

local function DrawTextBackground(x, y, text, font, backgroundColor, padding)
	font = font or "ixSubTitleFont"
	padding = padding or 8
	backgroundColor = backgroundColor or Color(88, 88, 88, 255)

	surface.SetFont(font)
	local textWidth, textHeight = surface.GetTextSize(text)
	local width, height = textWidth + padding * 2, textHeight + padding * 2

	ix.util.DrawBlurAt(x, y, width, height)
	surface.SetDrawColor(0, 0, 0, 40)
	surface.DrawRect(x, y, width, height)

	derma.SkinFunc("DrawImportantBackground", x, y, width, height, backgroundColor)

	surface.SetTextColor(color_white)
	surface.SetTextPos(x + padding, y + padding)
	surface.DrawText(text)

	return height
end

function GetEndMoney(money,sum)
	return money - sum
end

function PLUGIN:HUDPaint()
	local id = LocalPlayer():GetArea()
	local area = ix.area.stored[id]
	if id == nil then
		id = "Nothing"
	end
	local height = ScrH()
	local viewmdl
	local view = LocalPlayer():GetEyeTrace().Entity
	if ix.config.Get("Extended Debug Mode") then
		PrintTable(LocalPlayer():GetEyeTrace())
	end
	if view == nil then return end
	if tostring(view) == "[NULL Entity]" then return end
	if view == nil then
		view = "Nothing"
	else
		viewmdl = view:GetModel()
	end
	local y
	if (!ix.area.bEditing) then
		y = 64
	else
		y = 256
	end
	local viewvar
	if view:IsVehicle() then
		if tostring(view:GetClass()) == "gmod_sent_vehicle_fphysics_base" then
			viewvar = list.Get( "simfphys_vehicles" )[ view:GetSpawn_List() ].Name
		else
			viewvar = "Can't find name"
		end
	else
		viewvar = view.PrintName
	end
	if ix.config.Get("Debug Mode") then
		y = y + DrawTextBackground(64, y, L("Debug Mode"), nil, ix.config.Get("color"))
		y = y + DrawTextBackground(64, y, L("You can disable it in the server configuration"), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Current Area: "..tostring(id)..""), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Looking Entity: "..tostring(view)..""), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Looking Model: "..tostring(viewmdl)..""), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Looking Printname: "..tostring(viewvar)..""), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Looking Class: "..tostring(view:GetClass())..""), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Looking Position: "..tostring(view:GetPos())), "ixSmallTitleFont")
		y = y + DrawTextBackground(64, y, L("Looking Angle: "..tostring(view:GetAngles())), "ixSmallTitleFont")
	end
end

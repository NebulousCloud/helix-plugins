
local PLUGIN = PLUGIN

PLUGIN.waypoints = {}

function PLUGIN:HUDPaint()
	local height = draw.GetFontHeight("BudgetLabel")
	local clientPos = LocalPlayer():EyePos()

	for k, waypoint in pairs(self.waypoints) do
		if (waypoint.time < CurTime()) then
			continue
		end

		local screenPos = waypoint.pos:ToScreen()
		local color = waypoint.color
		local text = "<:: "..waypoint.text.." ::>"
		local x, y = screenPos.x, screenPos.y

		surface.SetDrawColor(color)
		surface.DrawLine(x + 15, y, x - 15, y)
		surface.DrawLine(x, y + 15, x, y - 15)
		surface.DrawOutlinedRect(x - 8, y - 8, 17, 17)
		if (LocalPlayer():IsLineOfSightClear(waypoint.pos)) then
			surface.DrawOutlinedRect(x - 5, y - 5, 11, 11)
		end

		surface.SetFont("BudgetLabel")
		surface.SetTextColor(color)
		local width = surface.GetTextSize(text)
		surface.SetTextPos(x - width / 2, y + 17)
		surface.DrawText(text)

		if (!waypoint.noDistance) then
			local distanceText = tostring(math.Round(clientPos:Distance(waypoint.pos) * 0.01905, 2)).."m"
			width = surface.GetTextSize(distanceText)
			surface.SetTextPos(x - width / 2, y - (15 + height))
			surface.DrawText(distanceText)
		end
	end
end

net.Receive("SetupWaypoints", function()
	local data = net.ReadTable()

	PLUGIN.waypoints = data or {}
end)

net.Receive("UpdateWaypoint", function()
	local data = net.ReadTable()

	PLUGIN.waypoints[data[1]] = data[2]
end)

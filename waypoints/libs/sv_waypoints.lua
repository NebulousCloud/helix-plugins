
local PLUGIN = PLUGIN

Schema.waypoints = Schema.waypoints or {}

function Schema.waypoints:AddWaypoint(position, text, color, time, addedBy)
	local waypoint = {}
	waypoint.pos = position + Vector(0, 0, 30)
	waypoint.text = text
	waypoint.color = color
	waypoint.addedBy = addedBy
	waypoint.time = CurTime() + time

	PLUGIN:AddWaypoint(waypoint)
end

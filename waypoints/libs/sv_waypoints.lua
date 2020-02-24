
local PLUGIN = PLUGIN

function Schema:AddWaypoint(position, text, color, time, addedBy, ...)
	position:Add(Vector(0, 0, 30))
	color = color or color_white
	time = time or 8

	local waypoint = {
		pos = position,
		text = text,
		color = color,
		addedBy = addedBy,
		arguments = {...},
		time = CurTime() + time
    }

	PLUGIN:AddWaypoint(waypoint)
end

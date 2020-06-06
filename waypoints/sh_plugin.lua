
local PLUGIN = PLUGIN

PLUGIN.name = "Waypoints"
PLUGIN.author = "Gr4ss"
PLUGIN.description = "Gives the ability to allow some factions to see/add/remove/update waypoints."
PLUGIN.license = [[
(c) 2016 by Gr4Ss (greengr4ss@gmail.com)
This plugin is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/
]]
PLUGIN.readme = [[
A small plugin that allow some factions to use waypoints. To just list the features:
- Add one or more of the following to a faction's file (what they do is quite self-explanatory):
  - FACTION.canSeeWaypoints = true
  - FACTION.canAddWaypoints = true
  - FACTION.canRemoveWaypoints = true
  - FACTION.canUpdateWaypoints = true
- Players can still remove/update their own waypoints without their faction having Remove/Update permissions.
- Makes it easy to add waypoints script-wise with a global library function (in case you for example want to create a waypoint where a player died).
- Waypoints can have some text.
- Waypoints can have different colors and can be made to last for a certain amount of time.
- Waypoint markers draw through walls and include a distance to them in meters. It is also possible to add waypoints without a distance marker.
- Waypoints will visually change a bit when a player can see the actual location.
- Players joining will see waypoints created before they joined if they should see them. Everything updates quite nicely.
- No texture download needed, waypoint is just drawn with lines and rectangles.

Support for this plugin can be found here: https://discord.gg/mntpDMU
]]

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

ix.command.Add("WaypointAdd", {
	description = "@cmdWaypointAdd",
	arguments = {ix.type.string, ix.type.number, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, text, time, color)
		local faction = ix.faction.Get(client:Team())

		if (!faction or !faction.canAddWaypoints) then
			return "@cannotAddWaypoints"
		end

		if (color) then
			local colorName = string.lower(color)
			color = PLUGIN:GetWaypointColor(colorName)

			if (!color) then
				return "@invalidWaypointColor", colorName, PLUGIN:ListColors()
			end
		else
			color = faction.color or color_white
		end

		local position = client:GetEyeTraceNoCursor().HitPos

		position:Add(Vector(0, 0, 30))

		local waypoint = {
			pos = position,
			text = text,
			color = color,
			addedBy = client,
			time = CurTime() + time
	    }

		PLUGIN:AddWaypoint(waypoint)
		return "@addedWaypoint"
	end
})

ix.command.Add("WaypointAddND", {
	description = "@cmdWaypointAddND",
	arguments = {ix.type.string, ix.type.number, bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, text, time, color)
		local faction = ix.faction.Get(client:Team())

		if (!faction or !faction.canAddWaypoints) then
			return "@cannotAddWaypoints"
		end

		if (color) then
			local colorName = string.lower(color)
			color = PLUGIN:GetWaypointColor(colorName)

			if (!color) then
				return "@invalidWaypointColor", colorName, PLUGIN:ListColors()
			end
		else
			color = faction.color or color_white
		end

		local position = client:GetEyeTraceNoCursor().HitPos

		position:Add(Vector(0, 0, 30))

		local waypoint = {
			pos = position,
			noDistance = true,
			text = text,
			color = color,
			addedBy = client,
			time = CurTime() + time
	    }

		PLUGIN:AddWaypoint(waypoint)
		return "@addedWaypoint"
	end
})

ix.command.Add("WaypointUpdate", {
	description = "@cmdWaypointUpdate",
	arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional), bit.bor(ix.type.string, ix.type.optional)},
	OnRun = function(self, client, text, time, color)
		local pos = client:GetEyeTraceNoCursor().HitPos
		pos:Add(Vector(0, 0, 30))

		local index = nil
		local minDistanceSqr = nil

		local faction = ix.faction.Get(client:Team())
		local onlyOwnWaypoints = !(faction and faction.canUpdateWaypoints)

		for k, point in pairs(PLUGIN.waypoints) do
			if (onlyOwnWaypoints and point.addedBy != client) then
				continue
			end

			if (!index) then
				index = k
				minDistanceSqr = point.pos:DistToSqr(pos)
			else
				local dist = point.pos:DistToSqr(pos)

				if (dist < minDistanceSqr) then
					index = k
					minDistanceSqr = dist
				end
			end
		end

		if (!index) then
			return "@noWaypointsToUpdate"
		elseif (index and minDistanceSqr > 40000) then
			return "@noWaypointsNearToUpdate"
		end

		if (color) then
			local colorName = string.lower(color)
			color = PLUGIN:GetWaypointColor(colorName)

			if (!color) then
				return "@invalidWaypointColor", colorName, PLUGIN:ListColors()
			end
		else
			color = PLUGIN.waypoints[index].color or faction.color or color_white
		end

		if (time) then
			time = CurTime() + time
		else
			time = PLUGIN.waypoints[index].time
		end

		local waypoint = {
			pos = PLUGIN.waypoints[index].pos,
			noDistance = PLUGIN.waypoints[index].noDistance,
			text = text,
			color = color,
			addedBy = PLUGIN.waypoints[index].addedBy,
			time = time
	    }

		PLUGIN:UpdateWaypoint(index, waypoint)
		return "@updatedWaypoint"
	end
})

ix.command.Add("WaypointRemove", {
	description = "@cmdWaypointRemove",
	OnRun = function(self, client)
		local trace = client:GetEyeTraceNoCursor()
		local pos = trace.HitPos
		pos:Add(Vector(0, 0, 30))

		local index = nil
		local minDistanceSqr = nil

		local faction = ix.faction.Get(client:Team())
		local onlyOwnWaypoints = !(faction and faction.canRemoveWaypoints)

		for k, point in pairs(PLUGIN.waypoints) do
			if (onlyOwnWaypoints and point.addedBy != client) then
				continue
			end

			if (!index) then
				index = k
				minDistanceSqr = point.pos:DistToSqr(pos)
			else
				local dist = point.pos:DistToSqr(pos)

				if (dist < minDistanceSqr) then
					index = k
					minDistanceSqr = dist
				end
			end
		end

		if (!index) then
			return "@noWaypointsToRemove"
		elseif (index and minDistanceSqr > 40000) then
			return "@noWaypointsNearToRemove"
		end

		PLUGIN:UpdateWaypoint(index, nil)
		return "@removedWaypoint"
	end
})

ix.command.Add("WaypointRemoveAll", {
	description = "@cmdWaypointRemoveAll",
	OnRun = function(self, client)
		local faction = ix.faction.Get(client:Team())

		if (!faction or !faction.canRemoveWaypoints) then
			return "@cannotRemoveWaypoints"
		end

		if (table.Count(PLUGIN.waypoints) > 0) then
			PLUGIN:RemoveWaypoints()
			return "@removedAllWaypoints"
		else
			return "@noWaypointsSet"
		end
	end
})

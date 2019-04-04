
local PLUGIN = PLUGIN

function PLUGIN:GetAFK()
	local target = nil
	for _, v in ipairs(player.GetAll()) do
		if (v.isAFK and (!target or target.isAFK > v.isAFK) and !v:IsAdmin()) then
			target = v
			break
		end
	end

	if (target and CurTime() - target.isAFK > 60) then
		return target
	end
end

function PLUGIN:KickAFK(target, byAdmin)
	if (target) then
		target:Kick("You were kicked for being AFK")

		if (byAdmin) then
			ix.util.NotifyLocalized("kickedAdminAFK", nil, byAdmin:Name(), target:Name())
		else
			ix.util.NotifyLocalized("kickedAFK", nil, target:Name())
		end
	end
end

function PLUGIN:Update(client)
	local aimVector = client:GetAimVector()
	local posVector = client:GetPos()

	if (client.ixLastAimVector ~= aimVector or client.ixLastPosition ~= posVector) then
		client.ixLastAimVector = aimVector
		client.ixLastPosition = posVector

		client.isAFK = nil
		client:SetNetVar("IsAFK", false)
	else
		client.isAFK = CurTime()
		client:SetNetVar("IsAFK", true)
	end
end

timer.Create("ixAntiAFK", 60, 0, function()
	if (player.GetCount() >= game.MaxPlayers()) then
		PLUGIN:KickAFK(PLUGIN:GetAFK())
	end
end)
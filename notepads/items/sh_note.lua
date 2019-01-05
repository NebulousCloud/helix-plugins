ITEM.name = "Notepad"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "You can write about it at last! If you can write, that is."
ITEM.price = 0

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = { -- sorry, for name order.
	name = "Use",
	tip = "useTip",
	icon = "icon16/pencil.png",
	OnRun = function(item)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.HitPos) then
			local note = ents.Create("ix_note")
			note:SetPos(trace.HitPos + trace.HitNormal * 10)
			note:Spawn()

			hook.Run("OnNoteSpawned", note, item)
		end

		return true
	end,
}

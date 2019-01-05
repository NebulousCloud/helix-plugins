ITEM.name = "Paper"
ITEM.model = "models/props_c17/paper01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "A scrunched up piece of paper you can write on! If you can write that is."
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
			local paper = ents.Create("ix_paper")
			paper:SetPos(trace.HitPos + trace.HitNormal * 10)
			paper:Spawn()

			hook.Run("OnPaperSpawned", paper, item)
		end

		return true
	end,
}

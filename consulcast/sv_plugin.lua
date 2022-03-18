
local PLUGIN = PLUGIN

PLUGIN.consulcasts = {
	["industrial17/c17_pa0.wav"] = "The true citizen knows that duty is the greatest gift.",
	["industrial17/c17_pa1.wav"] = "The true citizen appreciates the comforts of City 17, but uses discretion.",
	["industrial17/c17_pa2.wav"] = "The true citizen's identiband is kept clean and visible at all times.",
	["industrial17/c17_pa3.wav"] = "The true citizen's job is the opposite of slavery.",
	["industrial17/c17_pa4.wav"] = "The true citizen conserves valuable oxygen."
}

PLUGIN.speakers = {
	["rp_industrial17_v1"] = {3319, 3320, 3321, 3322, 3323, 3324, 3325, 3476, 4976}
}

function PLUGIN:InitPostEntity()
	if (self.speakers[game.GetMap()]) then
		self.speakerEnts = {}

		for _, v in next, self.speakers[game.GetMap()] do
			table.insert(self.speakerEnts, ents.GetMapCreatedEntity(v))
		end
	else
		ix.plugin.SetUnloaded("consulcast", true, true)
	end
end

local lastCast

function PLUGIN:OnLoaded()
	timer.Create("consulcast", ix.config.Get("consulcastDelay"), 0, function()
		local message, soundPath

		repeat
			message, soundPath = table.Random(self.consulcasts)
		until (soundPath ~= lastCast)

		lastCast = soundPath

		for _, v in next, self.speakerEnts do
			v:EmitSound(soundPath, 85, nil, nil, nil, nil, 57)
		end

		ix.chat.Send(nil, "consulcast", message)
	end)
end

function PLUGIN:OnUnload()
	timer.Remove("consulcast")
end

ix.chat.Register("consulcast", {
	CanSay = function(_, speaker)
		return not IsValid(speaker)
	end,
	CanHear = function(_, _, listener)
		for _, v in next, PLUGIN.speakerEnts do
			local speakerPos = v:GetPos()

			local recipientFilter = RecipientFilter()
			recipientFilter:AddPAS(speakerPos)

			if (table.HasValue(recipientFilter:GetPlayers(), listener) and listener:EyePos():Distance(speakerPos) <= 2500) then
				return true
			end
		end

		return false
	end
})

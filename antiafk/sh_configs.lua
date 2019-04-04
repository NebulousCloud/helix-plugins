
ix.config.Add("afkTime", 300, "The amount of seconds it takes for someone to be flagged as AFK.", function(oldValue, newValue)
	if (SERVER) then
		for _, v in ipairs(player.GetAll()) do
			if (v:GetCharacter()) then
				timer.Adjust("ixAntiAFK"..v:SteamID64(), newValue)
			end
		end
	end
end, {
	data = {min = 60, max = 3600},
	category = "antiafk"
})

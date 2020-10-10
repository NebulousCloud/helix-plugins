do
	local CLASS = {}
	CLASS.color = Color(150, 0, 0)
	CLASS.format = "DISPATCH broadcasts, \"%s REPORTS 62 ALARMS, RESPOND. LOCATION: %s\""

	function CLASS:CanHear(speaker, listener)
		return listener:IsCombine() or speaker:Team() == FACTION_ADMIN
	end

	function CLASS:OnChatAdd(speaker, text)
		chat.AddText(self.color, string.format(self.format, speaker:Name(), text))
		surface.PlaySound("ambient/alarms/klaxon1.wav")
	end

	ix.chat.Register("alert", CLASS)
end
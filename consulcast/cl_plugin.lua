
local PLUGIN = PLUGIN

ix.chat.Register("consulcast", {
	format = "PA system broadcasts \"%s\"",
	color = Color(175, 54, 45),
	CanSay = function(_, speaker)
		return not IsValid(speaker)
	end,
	OnChatAdd = function(self, _, text)
		chat.AddText(self.color, string.format(self.format, text))
	end
})

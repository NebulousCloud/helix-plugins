
local PLUGIN = PLUGIN

PLUGIN.name = "Disable Character Swap"
PLUGIN.author = "Zak"
PLUGIN.description = "Prevents players from switching characters when enabled."

ix.config.Add("charSwapDisabled", false, "Should switching characters be disabled?", nil, {
	category = "characters"
})

ix.lang.AddTable("english", {
	cmdToggleCharSwap = "Toggle character swapping."
})

do
	local COMMAND = {
		description = "@cmdToggleCharSwap",
		superAdminOnly = true
	}

	function COMMAND:OnRun(client, language)
		local newValue = !ix.config.Get("charSwapDisabled")

		ix.config.Set("charSwapDisabled", newValue)
		ix.util.Notify(newValue and "Character swapping is now disabled." or "Character swapping has been re-enabled. You are free to switch characters.")
	end

	ix.command.Add("ToggleCharSwap", COMMAND)
end

if (SERVER) then
	function PLUGIN:CanPlayerUseCharacter(client, character)
		local currentCharacter = client:GetCharacter()

		if (currentCharacter and ix.config.Get("charSwapDisabled") == true and !client:IsAdmin()) then
			return false
		end
	end
end

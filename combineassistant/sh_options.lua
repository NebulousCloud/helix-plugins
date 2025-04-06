
ix.option.Add("caAutomaticActionsEnabled", ix.type.bool, false, {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end,
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caRadioReplyAffirmative", ix.type.string, "10-4.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caRadioReplyNegative", ix.type.string, "10-2.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caRadioReportArea", ix.type.string, "Reporting 10-20 at %s.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caRadioReportCivCount", ix.type.string, "Reporting 10-91d count at %s.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickUnholsterAction", ix.type.string, "unclips their stunstick from their belt, holding it firmly in their hand.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickHolsterAction", ix.type.string, "clips their stunstick onto their belt.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickRaiseAction", ix.type.string, "raises their stunstick up to shoulder level.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickLowerAction", ix.type.string, "lowers their stunstick down, holding it by their hips.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickOffAction", ix.type.string, "clicks their stunstick, turning it off. A brief zapping sound is heard as it dies off.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickOnAction", ix.type.string, "clicks their stunstick, turning it on. Small sparks fly off as it comes to life, emitting a brief zapping sound.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickPushAction", ix.type.string, "pushes %s with their stunstick.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caStunstickKnockAction", ix.type.string, "knocks on the door in front of them with their stunstick.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caSearchInstructions", ix.type.string, "Spread your legs apart and rest your hands down your sides. Don't turn around, and no sudden movements.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caTieAction", ix.type.string, "takes a hold of a pair of zip-ties and attempts to restrain %s.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})

ix.option.Add("caUntieAction", ix.type.string, "reveals their service knife, slicing %s's zip-ties, freeing them.", {
	category = "Combine Assistant",
	hidden = function()
		return !LocalPlayer():IsCombine()
	end
})


ix.config.Add("biosignalUnobstruct", true, "Whether or not biosignals/cameras should be visible through walls. Requests, losses, violations, etc are exempt.", nil, {
	category = "Combine Technology Overlay"
})

ix.config.Add("biosignalDistance", 0, "The maximum distance to see biosignals/cameras. Requests, losses, violations, etc are exempt. Set to 0 for infinite.", nil, {
	data = {min = 0, max = 20000},
	category = "Combine Technology Overlay"
})

ix.config.Add("expireBiosignals", 120, "Time in seconds until a lost biosignal disappears.", nil, {
	data = {min = 10, max = 3600},
	category = "Combine Technology Overlay"
})

ix.config.Add("expireRequests", 60, "Time in seconds until a request disappears.", nil, {
	data = {min = 10, max = 3600},
	category = "Combine Technology Overlay"
})

ix.config.Add("useTagSystem", true, "Whether or not to use the CID tag visor system.", nil, {
	category = "Combine Technology Overlay"
})

ix.config.Add("citizenDistance", 2048, "The maximum distance to see movement violations and CID tags.", nil, {
	data = {min = 64, max = 65536},
	category = "Combine Technology Overlay"
})

ix.config.Add("useBiosignalSystem", true, "Whether or not to use the biosignal system.", nil, {
	category = "Combine Technology Overlay"
})

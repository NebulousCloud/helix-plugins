PLUGIN.name = "Vocoder"
PLUGIN.description = "Adds vocoder sounds for Overwatch soldiers."
PLUGIN.author = "sanny"

if (SERVER) then
    resource.AddWorkshop("2291046370")
end

sound.Add({
    name = "Vocoder.On",
    channel = CHAN_STATIC,
    volume = 1,
    level = 60,
    sound = {
        "vocoder/on1.wav",
        "vocoder/on2.wav",
        "vocoder/on3.wav",
        "vocoder/on4.wav",
        "vocoder/on5.wav",
        "vocoder/on6.wav",
    }
})

sound.Add({
    name = "Vocoder.Off",
    channel = CHAN_STATIC,
    volume = 1,
    level = 60,
    sound = {
        "vocoder/off1.wav",
        "vocoder/off2.wav",
        "vocoder/off3.wav",
        "vocoder/off4.wav",
        "vocoder/off5.wav",
        "vocoder/off6.wav",
        "vocoder/off7.wav",
        "vocoder/off8.wav",
    }
})

if (CLIENT) then
    return
end

function PLUGIN:PlayerMessageSend(speaker, chatType, text, anonymous, receivers, rawText)
	if (chatType == "ic" or chatType == "w" or chatType == "y" or chatType == "dispatch") then
		local class = Schema.voices.GetClass(speaker)

		for k, v in ipairs(class) do
			local info = Schema.voices.Get(v, rawText)

			if (info) then
				local volume = 80

				if (chatType == "w") then
					volume = 60
				elseif (chatType == "y") then
					volume = 150
				end

				if (info.sound) then
					if (info.global) then
						netstream.Start(nil, "PlaySound", info.sound)
					else
						local sounds = {info.sound}

						if (speaker:IsCombine()) then
							speaker.bTypingBeep = nil

							if (speaker:Team() == FACTION_MPF) then
								sounds[#sounds + 1] = "NPC_MetroPolice.Radio.Off"
							else
								sounds[#sounds + 1] = "Vocoder.Off"
							end
						end


						ix.util.EmitQueuedSounds(speaker, sounds, nil, nil, volume)
					end
				end

				if (speaker:IsCombine()) then
					return string.format("<:: %s ::>", info.text)
				else
					return info.text
				end
			end
		end

		if (speaker:IsCombine()) then
			return string.format("<:: %s ::>", text)
		end
	end
end

netstream.Hook("PlayerChatTextChanged", function(client, key)
	if (client:IsCombine() and !client.bTypingBeep
	and (key == "y" or key == "w" or key == "r" or key == "t")) then
		if (client:Team() == FACTION_MPF) then
			client:EmitSound("NPC_MetroPolice.Radio.On")
		else
			client:EmitSound("Vocoder.On")
		end

		client.bTypingBeep = true
	end
end)

netstream.Hook("PlayerFinishChat", function(client)
	if (client:IsCombine() and client.bTypingBeep) then
		if (client:Team() == FACTION_MPF) then
			client:EmitSound("NPC_MetroPolice.Radio.Off")
		else
			client:EmitSound("Vocoder.Off")
		end

		client.bTypingBeep = nil
	end
end)